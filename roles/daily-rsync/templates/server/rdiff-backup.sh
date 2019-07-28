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
DST="$DIR"/data

cd "$SRC" || exit
for i in *; do
    nice rdiff-backup --tempdir /var/tmp/ \
                      -- "$SRC/$i" "$DST/$i" || ERR=1
done

exit $ERR
