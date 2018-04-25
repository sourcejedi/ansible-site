# sourcejedi.atop #

`atop.service` provides daily logging of system and process activity for analyzing trends.
I like having it to log memory usage per process (and system-wide as well).

> https://lwn.net/Articles/387202/
>
> The normal installation of the atop package starts an atop daemon nightly. This daemon takes snapshots and writes them to a log file (/var/log/atop/atop_YYYYMMDD). The default snapshot interval for a logging atop is 10 minutes, but obviously this is configurable. Every logfile is preserved for a month (also configurable), so performance events a full month back can still be observed.
>
> The log file can be viewed using atop -r log_filename. The subcommand t forwards to the next sample in the atop logfile (i.e. 10 minutes by default), subcommand T rewinds one sample. Subcommand b branches to a specific time in the current logfile. All other subcommands to zoom in on specific resources also work. The logfile that the atop daemon creates can also be viewed using a sar-like interface using the command atopsar.

Unfortunately if you use the current Fedora package and suspend your laptop overnight, the log file won't be rotated.
So this role includes a script to work around the Fedora issue.

[https://bugzilla.redhat.com/show_bug.cgi?id=1571866](https://bugzilla.redhat.com/show_bug.cgi?id=1571866)


## Requirements

This should work to install and enable `atop.service`, on any distribution that has a package for it.
But it's probably most useful on Fedora.


## License

This role is licensed GPLv3, please open an issue if this creates any problem.
