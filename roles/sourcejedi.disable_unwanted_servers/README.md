# sourcejedi.disable_unwanted_servers

This role prevents network services being enabled
by accident, when you install certain packages.

## Motivation

A lot of users probably expect Ubuntu's
"[No Open Ports][no-open-ports]", and/or a firewall like Windows has.
This expectation has not been upheld.  See the list of services below.
Therefore, I suggest all of the following:

1. Use this role, or run
   `systemctl mask rpcbind minidlna minissdpd gdomap`.  It will prevent these
   network services from being started, e.g. when you install certain packages
   that recommend them.

2. Configure a firewall.  For an example (and some aspects to consider), see
   [sourcejedi.firewalld][sourcejedi__firewalld].

3. Look for unwanted network services on your system.  Run `sudo ss -utlp`
   (or `sudo netstat -nutlp`).  You can ignore services listening on
   localhost / [::1] / 127.0.0.1.

Note: Ubuntu's "No Open Ports" policy is no longer actively maintained.
There is no documentation about the exception for cups-browsed (UDP port 631).
And the policy has not been applied to the
[current media player app][rhythmbox-bug].

This role does not disable open ports in the media player, or other
GUI apps.

[no-open-ports]: https://wiki.ubuntu.com/SecurityTeam/Policies
[sourcejedi__firewalld]: https://github.com/sourcejedi/ansible-firewalld
[rhythmbox-bug]: https://bugs.launchpad.net/ubuntu/+source/rhythmbox/+bug/1771196

## Requirements

Operating system based on Debian/Ubuntu.

## Role variables

Each variable can be set to one of three possible values.

* `True` - `yes` in YAML - will *disable* the corresponding service.
* `False` - `no` in YAML - will *enable* the corresponding service.
* `None` - defining the variable as empty in Yaml - will leave the corresponding service unchanged.

The variables, and their default values, are:

    disable_service_avahi_daemon:

A lot of distributions (and users) allow Avahi (multicast DNS).
Ubuntu audited it for security at one point.  That said, if you have
a server that is directly exposed to the internet, you should disable
Avahi or have a firewall that blocks it.  Ubuntu Server does not install
Avahi.

    disable_service_gdomap: yes

gdomap - part of gnustep-base-runtime. Pulled in e.g. by unar, and by
Debian Desktop 7.  The service was disabled a long time ago, but there
was a bug when upgrading to Debian 10.0.  There is expected to be an
update in future, to forcibly disable it again, and fix the UDP
amplification bug which could be used for DRDoS attacks.

https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=939119

    disable_service_minissdpd: yes

minissdpd - used by libminiupnpc.  Debian Desktop 8 and 9 install this by
default, due to transmission-gtk.  As far as I can tell, this is not removed
during upgrade to Debian 10.  I consider this a very high risk as it runs as
root, without dropping capabilities or using a chroot jail.  Clearly, it was
not audited and secured like Avahi was.

https://unix.stackexchange.com/questions/442791/is-minissdpd-known-to-have-been-auditted-for-security-at-a-similar-level-to-avahi

    disable_service_minidlna: yes

minidlna - pulled in by kipi-plugins, e.g. by digikam.

    disable_service_rpcbind: yes

rpcbind was installed by default in Debian 8, for NFSv3 clients.
It is also pulled in by monitoring-plugins-standard (icinga).

    disable_service_nmbd: yes

nmbd - ancient network discovery in Samba.  I.e. for Windows XP
clients and below.  This service is not useful when Linux acts as a
client, only when it acts as a server.

Windows has deprecated SMBv1 since 2014, and started disabling it
by default in 2019.  If you are not using this, you should probably
disable it.

Some sysadmins have used this to advertise a Linux server to Windows
clients which support newer discovery protocols.  To be fair, Windows
does not implement the same multicast DNS protocol used by Avahi.
Using an alternative network discovery protocol is not always
convenient (or even possible).

    disable_service_cups_browsed:

cups-browsed: network printer discovery for CUPS.
It has four independently switchable functions:

1. Query printers using modern MDNS, aka "Avahi" aka "Bonjour" aka
   "Airprint".

2. Listen on UDP port 631 (ipp), for the legacy CUPS discovery protocol.

3. Query LDAP directory for printers.  This is not enabled by default.

4. Broadcast on UDP port 631 (ipp), for the legacy CUPS discovery protocol.
   This is not enabled by default.

Various instructions advise using this to discover network printers.[1]
It seems the main reason is an issue with GTK.  The issue is that GTK
can discover network printers on its own, but then fails to actually
print to them.[2][3]  Assuming this issue is solved, most systems
should be able to run without cups-browsed.

[1] https://wiki.debian.org/QuickPrintQueuesCUPS#IPP_Printers
[2] https://wiki.debian.org/CUPSDriverlessPrinting#CUPS_2.2.4_and_the_GTK_Print_Dialog
[3] https://wiki.debian.org/CUPSPrintQueues#Printing_and_GTK_Applications

This is enabled with default settings in Ubuntu and Debian.
On Fedora Workstation 26-30, this service is disabled by default.
If you are not using it, you might want to disable it.


## License

The role itself is licensed GPLv3.  Please open an issue if this creates any problem.
