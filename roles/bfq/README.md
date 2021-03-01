# sourcejedi.bfq #

Enable the BFQ I/O scheduler.  Applies to all possible block devices, including NVMe.

I believe BFQ improves fairness between latency-sensitive and throughput-sensitive tasks.  According to the author, most software and hardware favours large I/Os.  BFQ aims to rebalance this.  By default its heuristics favour low latencies, but throughput is also very good in most cases.

BFQ is written by Paolo Valente, with support from Linaro (ARM open source group).

https://algo.ing.unimo.it/people/paolo/disk_sched/

## Requirements

* Linux kernel 5.0+
* udev

## BFQ hot takes

Switching to a more complex I/O scheduler doesn't generally make your device faster.  BFQ can improve how responsive the system is *when you have other I/O happening at the same time*.

BFQ has some great tests to demonstrate this improvement.  See the website.

Linux 5.2+ is even better, for [improving responsiveness when switching to BFQ](https://lwn.net/Articles/784267/).

If you run out of memory, or otherwise trigger thrashing, that will be *unpleasant* regardless of BFQ.  BFQ seemed to ease the pain a little, in a test where my system starts swapping to disk.  [Another user](https://discuss.getsol.us/d/369-massive-performance-improvements-for-emmc-with-bfq-default-for-solus) has also found this useful.

I believe Linux I/O schedulers cannot really differentiate between *write* operations, unless the applications are submitting uncached writes (`O_DIRECT`), or perhaps synchronous writes.  (They can still favour reads over cached writes :-).

An I/O scheduler cannot fix ext4 "waiting for an indefinite amount of time in journal_finish_inode_data_buffers()" [while another task writes a large file](https://lore.kernel.org/linux-fsdevel/20190620151839.195506-1-zwisler@google.com/T/#m87dd524377b23e45f6911ee5a6df8ef77a64def4).  Patches have been submitted for ext4, hopefully in time for Linux 5.3 :-).

Other problems, more or less dramatic, may still exist with Linux filesystems and memory management.


## License

This role is licensed GPLv3.  Please open an issue if this creates any problem.
