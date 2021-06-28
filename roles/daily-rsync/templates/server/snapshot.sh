#!/bin/sh

{#
 # jinja2 template of a bash script.
 # bash is already hateful; this combination is probably better avoided :-P.
 #}
DIR={{ daily_rsync__dir | quote }}/{{ inventory_hostname | quote }}

# rdiff-backup makes some effort to check for competing accesses,
# but I've had problems with it anyway :'-(.  Use a lock file.
#
# I am happy to have it wait, rather than log a failure.
#
# So far we are only locking on the rdiff-backup repo. We are not
# trying to lock $SRC against being modified while we read it.
#
LOCK="$DIR"/lock
if [ "$LOCKED" != "$LOCK" ]; then
    export LOCKED="$LOCK"
    exec flock "$LOCK" "$0" "$@"
fi

ERR=0
SRC="$DIR"/tmp
cd "$SRC" || exit

# rdiff-backup #
DST="$DIR"/rdiff-backup
for i in *; do
    nice rdiff-backup --tempdir /var/tmp/ \
                      -- "$SRC/$i" "$DST/$i" || ERR=1
done

# borgbackup functions #

# Show details when run from a terminal (idea stolen from bup).
# Otherwise, only show errors.
if tty >/dev/null; then
	readonly BORG_PROGRESS="--progress"
	readonly BORG_STATS="--stats --info"
else
	readonly BORG_PROGRESS=
	readonly BORG_STATS=
fi

# Removed - logging hook
log_cmd() {
	"$@"
}
# end removed

# If the borg repo does not exist, create it - atomically.
# If interrupted, just leaves a small randomly-named directory lying around
borg_init() {
	local BORG_REPO="$1" &&

	if [ ! -e "$BORG_REPO" ]; then
		T=$(mktemp --dry-run "$BORG_REPO".tmp.XXXXXX) &&
		borg init --encryption=none "$T" &&

		# Avoid a prompt about the repo having being relocated.
		borg config --cache "$T" previous_location "$BORG_REPO" &&

		mv "$T" "$BORG_REPO"
	fi
}

backup_home() {
	local HOME_DIR="$1" &&
	local BORG_REPO="$2" &&

	borg_init "$BORG_REPO" &&

	export BORG_REPO &&

	# Exclusions:
	#
	# Firefox profile tends to churn a whole lot (but see below).
	#
	# Thunderbird has an index for searching messages, which shows up.
	# This is due to the size of the blocks borg uses (megabytes?),
	# although enabling compression helps a bit.
	# We're allowed to drop the index - it will be rebuilt.
	#
	# On Debian, there may be an icedove profile which is half-migrated
	# to thunderbird, but still uses the old location.
	#
	# Nowadays GNOME logs activity and indexes it, that shows up as well.
	#
	log_cmd borg create '::{now}' "$HOME_DIR" \
		$BORG_PROGRESS $BORG_STATS \
		-C lz4 \
		--one-file-system \
		--exclude "$HOME_DIR"/.cache \
		--exclude "$HOME_DIR"/.mozilla/firefox \
		--exclude "$HOME_DIR"/.thunderbird/*/global-messages-db.sqlite \
		--exclude "$HOME_DIR"/.icedove/*/global-messages-db.sqlite \
		--exclude "$HOME_DIR"/.local/share/zeitgeist/fts.index \
		--exclude "$HOME_DIR"/.local/share/tracker &&

	# Prune old backups to save space
	log_cmd borg prune $BORG_STATS \
		--keep-daily 21 --keep-weekly 6 \
		--keep-monthly 12 --keep-yearly -1
}

# Save bookmarkbackups from the firefox profile.
# Firefox Sync doesn't e.g. protect against malice,
# and I have a lot of bookmarks I want to keep.
backup_firefox_bookmarks() {
	local HOME_DIR="$1" &&
	local BORG_REPO="$2".firefox-bookmarks &&
	export BORG_REPO &&

	if [ ! -d "$HOME_DIR"/.mozilla ]; then
		return 0
	fi &&

	borg_init "$BORG_REPO" &&

	log_cmd borg create $BORG_PROGRESS $BORG_STATS '::{now}' \
		"$HOME_DIR"/.mozilla/firefox/*/bookmarkbackups &&

	log_cmd borg prune $BORG_STATS \
		--keep-daily 21 --keep-weekly 6 \
		--keep-monthly 12 --keep-yearly -1
}

# Note if any one backup step fails, we keep going.
# However an error should be printed, which works well for the cron job case.
# Also make sure to point out if there was an error (like rsync does :).
backup() {
	local err=0

	backup_home "$1" "$2" ||
		err=1
	backup_firefox_bookmarks "$1" "$2" ||
		err=1

	return $err
}

# borgbackup run #

DST="$DIR"/borgbackup
for i in *; do
	backup "$SRC/$i" "$DST/$i" || ERR=1
done

# exit with status #
exit $ERR
