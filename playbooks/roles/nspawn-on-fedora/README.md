
nspawn doesn't work on Fedora.

This contains everything I use to work around it.

Be aware that nspawn does not benefit from SELinux confinement.
https://bugzilla.redhat.com/show_bug.cgi?id=1416540

## Per-nspawn settings

See `example.nspawn`, this shows how to work around firewalld.

## Creating nspawns

When you create a Fedora install using dnf, it will try to label the files.
This cannot possibly work.
You must run `restorecon -R` on the install before you can run it.

And for Debian images, dbus is required to support `machinectl login`
but it may not be installed by default.
See test-nspawn-bootstrap.yml.
