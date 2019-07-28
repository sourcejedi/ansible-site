# deb-mail #

Install default-mta and bsd-mailx.

FIXME this is insufficient, save for those who log in as root.
(There is a config for this on Debian, and presumably Ubuntu,
but they use different default MTAs!)

---

cron & at packages recommend a traditional "mail" setup.
They send results by mail - and thus far, in no other way.

Since Debian 9, the installer does not include a mail setup.

When reproducing systems which rely on mail,
one must remember to install the mail setup.

Used for backup scripts.

Mail is also used by smartd and icinga.
