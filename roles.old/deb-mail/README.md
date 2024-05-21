# deb-mail #

Install exim4.

Mail to the root user is redirected according to the ansible variable
`deb_mail_root_forward`.  This may contain multiple entries, separated
by commas.

---

cron & at packages recommend a traditional "mail" setup.
They send results by mail - and thus far, in no other way.

Since Debian 9, the installer does not include a mail setup.

When reproducing systems which rely on mail,
one must remember to install the mail setup.

Used for backup scripts.

Mail is also used by smartd and icinga.
