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

cd ~ || exit 1

COMMAND1="$(echo "$SSH_ORIGINAL_COMMAND" | cut -d " " -f 1)"
case "$COMMAND1" in
rsync)
    exec nice rsync --server --daemon --config=./rsyncd.conf . \
        || exit 1
    ;;
esac

case "$SSH_ORIGINAL_COMMAND" in
snapshot)
    # Run in the background, in case the client shuts down/loses connection.
    #
    # Don't use "at -f snapshot.sh", it fails silently.
    # Something non-obvious about how "at -f" works.
    #
    # at is chatty.  We have to supress the job number
    # & the warning that it uses /bin/sh :(
    #
    # Maybe we should switch to systemd-run?
    # I suppose we could also just use a daily cronjob,
    # but that seems a bit odd.

    echo ./snapshot.sh | at now 2>/dev/null
    RC=$?
    [ $RC = 0 ] || echo "at failed with exit status $RC"
    exit $RC
    ;;
esac

echo "Unknown command: $SSH_ORIGINAL_COMMAND"
exit 1
