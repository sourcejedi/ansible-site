I created this role specifically for nspawn-debian-unstable.
So it allows updates from unstable (if available),
and reboots overnight.


Except, something is odd.
This role seems to have missed the steps below,
it certainly is not working on test-nspawn "jessie".


https://help.ubuntu.com/community/AutomaticSecurityUpdates

To enable it, do:

sudo dpkg-reconfigure --priority=low unattended-upgrades

(it's an interactive dialog) which will create /etc/apt/apt.conf.d/20auto-upgrades with the following contents:

APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
