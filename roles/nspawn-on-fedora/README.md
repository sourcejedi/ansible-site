# nspawn-on-fedora #

systemd-nspawn does not work as advertised on Fedora Linux 25.
We may hope this improves in the future.

This project contains everything I use to work around it.

Be aware that this ansible role removes SELinux confinement from systemd-machined.service.
There are alternative suggestions about fixing the policy in bug [1416540](https://bugzilla.redhat.com/show_bug.cgi?id=1416540).
systemd-nspawn@.service, which actually runs the containers, has no confinement in the first place.

## Settings used on individual nspawns

Please also see `example.nspawn`.  This is a configuration file that I copy for each nspawn I create.

* Work around lack of integration with Fedora's firewalld.
* Don't run unmodified guests in a user namespace; they will probably fail (including Fedora 25).

## Creating nspawns

When you create a Fedora guest using dnf, it will try to label the files.
This cannot possibly work.
You must run `restorecon -R` on the install before you can run it.


## Requirements

systemd, SELinux.

## Role variables

`nspawn_on_fedora__machines_directory` overrides systemd-nspawn@.service, to load machine images from a different directory.
This could be useful if your root filesystem is small, and you have more space on your /home filesystem.

Documentation suggests you can symlink individual machine images.
Unfortunately this fails in v231 (Fedora 25).  The bug is fixed in v233.

## Example playbook

- hosts: all
  vars:
    nspawn_on_fedora__machines_directory: "/home/nspawn"
  roles:
    - { role: sourcejedi.nspawn-on-fedora

## License

This role is licensed GPLv3, please open an issue if this creates any problem.
