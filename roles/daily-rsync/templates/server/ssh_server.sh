#!/bin/sh

# Client command: rsync --rsh="ssh -l $SSH_USERNAME" "$SSH_HOST"::"$RSYNC_MODULE"
# The client command will launch the rsh, and pass it an rsync server command.
# The rsync server command is always "rsync --server --daemon ."
# The "." parameter is only there to satisfy the centralized option parsing code.
# It is not used for anything in this mode of rsync.
# https://unix.stackexchange.com/questions/504301/can-we-use-rsyncd-conf-to-restrict-rsync-over-ssh
#
# This script is used to prevent the client running arbitrary commands on the server.
# We ignore the specified rsync server command, and run our own.
#
COMMAND1="$(echo "$SSH_ORIGINAL_COMMAND" | cut -d " " -f 1)"
case "$COMMAND1" in
rsync)
    exec /usr/bin/rsync --server --daemon --config=./rsyncd.conf . \
        || exit 1
    ;;
esac

case "$SSH_ORIGINAL_COMMAND" in
rdiff-backup)
    exec ~/rdiff-backup.sh || exit 1
    ;;
esac

echo "Unknown command: $SSH_ORIGINAL_COMMAND"
exit 1
