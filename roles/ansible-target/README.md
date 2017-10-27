# ansible-target #

This role performs the boostrapping that can only be done using the raw module.
I thought this could be a useful exercise, but I haven't found any actual use for it.

It supports Linux distributions based on the `apt` and `dnf` package managers.

Specifically, it is used to install `python2` and `python2-dnf` on Fedora Linux.
It will install `libselinux-python`, as described in the Ansible
[install doc](https://docs.ansible.com/ansible/latest/intro_installation.html).

Also if the Ansible apt module is to be used, it will automatically install python-apt.
I find this cleaner than the bootstrap which is built in to the Ansible apt module.


## Requirements

Since this is an ansible role, you need to be able to connect to the target using Ansible.
So you probably had to configure SSH first, huh.

I prefer to start with a script that installs Ansible locally,
so I can use Ansible to configure SSH.


## Example playbook

    # Bootstrap starting with the raw module
    - hosts: all
      gather_facts: no  # do not try to run setup module to start with
      roles:
        - ansible-target

