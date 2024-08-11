#!/bin/sh

{#
 # jinja2 template of a bash script.
 # bash is already hateful; this combination is probably better avoided :-P.
 #}
DIR={{ daily_rsync__dir | quote }}/{{ inventory_hostname | quote }}

SCRIPT_DIR="$(dirname "$0")"
SCRIPT_DIR="$(realpath "$SCRIPT_DIR")"

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

backup() {
	local HOME_DIR="$1" &&
	local BORG_REPO="$2" &&

	borg_init "$BORG_REPO" &&

	export BORG_REPO &&

	cd "$HOME_DIR"
	log_cmd borg create '::{now}' . \
		$BORG_PROGRESS $BORG_STATS \
		-C lz4 \
		--one-file-system \
		--patterns-from="$SCRIPT_DIR"/patterns.lst &&

	# Prune old backups to save space
	log_cmd borg prune $BORG_STATS \
		--keep-daily 21 --keep-weekly 6 \
		--keep-monthly 12 --keep-yearly -1
}

# borgbackup run #

DST="$DIR"/borgbackup

cd "$SRC" || exit 1
for i in *; do
	backup "$SRC/$i" "$DST/$i" || ERR=1
done

# exit with status #
exit $ERR
