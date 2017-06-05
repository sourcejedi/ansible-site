# nspawn-on-fedora #

systemd-nspawn does not work on Fedora Linux.

This project contains everything I use to work around it.

Be aware that this ansible role removes SELinux confinement from systemd-machined.service.
There are alternative suggestions about fixing the policy in bug [1416540](https://bugzilla.redhat.com/show_bug.cgi?id=1416540).
systemd-nspawn@.service, which actually runs the containers, has no confinement in the first place.

## Settings used on individual nspawns

Please see `example.nspawn`.

* Work around lack of integration with Fedora's firewalld.
* Guests such as Fedora 25 fail when run in a user namespace.

## Creating nspawns

When you create a Fedora guest using dnf, it will try to label the files.
This cannot possibly work.
You must run `restorecon -R` on the install before you can run it.
