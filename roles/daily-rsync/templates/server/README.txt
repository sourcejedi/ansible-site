# Automated backups from other machines

One directory per machine.  Directory contents:

tmp/*/              files from the last backup
rdiff-backup/*/     snapshots in rdiff-backup format [1]
borgbackup/*/       snapshots in borgbackup format [2]

All symlink files are "munged" by rsync.  This is necessary for rsync
security.  To undo this, use the script bundled with rsync
(/usr/share/doc/rsync/support/munge-symlinks).

[1] https://rdiff-backup.net/
[2] https://www.borgbackup.org/
