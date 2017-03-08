# sourcejedi.google-chrome #

Install the Google Chrome web browser.

## Status

This role works fine on my systems (Fedora 25, Debian jessie).  However it will break at some point; see below.


## Signing keys

This role verifies the known fingerprints of Google code signing keys, inspired by Dockerfile best practices.  If you like to cross-check the current fingerprints, simply visit the [Google Linux Software Repositories](https://www.google.com/linuxrepositories/) page.

Installing Chrome provides a cron job, which we rely on to install any new keys.

However the role itself will break, when the current Packages Signing Authority expires.

```
$ gpg files/linux_signing_key.pub
pub  1024D/7FAC5991 2007-03-08 Google, Inc. Linux Package Signing Key <linux-packages-keymaster@google.com>
sub  2048g/C07CB649 2007-03-08
pub  4096R/D38B4796 2016-04-12 Google Inc. (Linux Packages Signing Authority) <linux-packages-keymaster@google.com>
sub  4096R/640DB551 2016-04-12 [expires: 2019-04-12]
```

Possible improvement: provide an option which refetches `linux_signing_keys.pub`, for use by developers.  This option will fail *during* a key transition, instead of *after*.  (`get_url force=yes` - it's a small file - so I can pick up the transition the next time I run the role.  The option should work in --check mode, if at all possible).


## Role Variables

To download updates from a shared cache, you can use the variable `google_chrome__yum_proxy`.  This variable applies to systems using the yum or dnf package managers.  It sets `proxy` in `local-google-chome.repo`, as needed for PackageKit (e.g. GNOME Software).  We consider `proxy` in dnf.conf to be obsolete, because it is deliberately ignored by PackageKit.

There is no variable for systems using apt.  You can instead set `Acquire::http::Proxy` in apt.conf.  The setting will be respected both by apt and PackgeKit.


## License

This role is licensed GPLv3, please open an issue if this creates any problem.

Terms of Service apply:

* [https://www.google.com/chrome/](Google Chrome site).  You can view terms of service and download Chrome manually.
* [https://www.google.com/intl/en/chrome/browser/privacy/eula_text.html](Google Chrome Terms of Service), "Printer-friendly version".

Google Chrome may include executable code from multiple parties, with specific sections in the Terms of Service.  Chrome may also use Google online services.  The terms do not require Google to notify you of any changes.

For open source code, without third-party components, look for the [Chromium Browser](https://www.chromium.org/).
