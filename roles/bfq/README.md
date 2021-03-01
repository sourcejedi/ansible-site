# sourcejedi.bfq #

Enable the BFQ I/O scheduler.  Applies to all possible block devices, including NVMe.


## Requirements

* Linux kernel 5.0 or higher.  For faster models of NVMe device, Linux 5.3+ is recommended.
* udev


## BFQ

The BFQ homepage has various test results, papers etc:

[https://algo.ing.unimo.it/people/paolo/disk_sched/](https://algo.ing.unimo.it/people/paolo/disk_sched/)

> Chrome OS switched to BFQ for Chromebooks running chromeos-4.19 kernels [....]  Fedora switched to BFQ since F31 \[but not for NVMe SSDs\] [....]

> Several distributions and kernel variants switched to BFQ years ago: in Manjaro, Mageia, OpenMandriva, Sabayon.

Red Hat Enterprise Linux 8 specifically [recommends using BFQ](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/monitoring_and_managing_system_status_and_performance/setting-the-disk-scheduler_monitoring-and-managing-system-status-and-performance) for personal systems.  "This scheduler is suitable while copying large files and the system does not become unresponsive in this case."


### BFQ hot takes

Using a complex I/O scheduler doesn't generally make your device faster.  BFQ can improve how responsive the system is *when you have other I/O happening at the same time*.  The BFQ home page shows some tests for this.

If you run out of memory and start thrashing, that will be *unpleasant* regardless of BFQ.  BFQ seemed to ease the pain somewhat, in one test of mine where the system started swapping to (spinning) disk.  I don't like to generalize about this, because I have no explanation for it.   [Another user](https://discuss.getsol.us/d/369-massive-performance-improvements-for-emmc-with-bfq-default-for-solus) also found BFQ helpful when swapping.  Interestingly for my test, BFQ still helped even if I disabled the BFQ `low_latency` heuristic, although I think it did not help quite so much.

Linux I/O schedulers cannot separate write operations from different programs, unless the applications are submitting uncached writes (`O_DIRECT`), or perhaps synchronous writes.  This is because cached writes are submitted by a kernel flusher thread.  However schedulers like BFQ can still treat cached writes as less time-sensitive than read operations.

An I/O scheduler cannot fix filesystem limitations.  For example, ext4 "waiting for an indefinite amount of time in journal_finish_inode_data_buffers()" [while another task writes a large file](https://lore.kernel.org/linux-fsdevel/20190620151839.195506-1-zwisler@google.com/T/#m87dd524377b23e45f6911ee5a6df8ef77a64def4).  This problem was fixed in Linux 5.3.

Other problems, more or less dramatic, may still exist with Linux filesystems and memory management.

### What is the BFQ I/O scheduler?

I don't know. With modern hardware, it's hard to understand how *any* software can schedule I/O.

BFQ replaces the old CFQ scheduler.  BFQ is useful on both SSDs and spinning disks.  It can scale to much higher I/Os per second than CFQ ever did.[1][2]  This is partly because CFQ used the old, slower block layer (called "single-queue").

If you do not use BFQ, you probably use the kernel default scheduler.  The kernel default is the simple scheduler `mq-deadline`, or `none` if the device has multiple hardware queues.

<!--
BFQ helps improve response times, when another program is also accessing the storage device.

This means BFQ is more helpful on systems that spend more of their time accessing storage.  This is great for systems with slow storage :-).  But even with an SSD, the default I/O scheduler (`mq-deadline`) can cause very poor response times.

BFQ favours low response times by default, but still gives very good throughput in most cases.  It also has specific code for old-style spinning disk drives.

[The quest for low latency in block I/O](https://it-events.com/system/attachments/files/000/001/213/original/Paolo_Valente_new.pdf?1479375426)

Most storage achieves peak throughput only with sequential I/O.  Therefore software and hardware reorder I/O requests, to achieve maximum throughput.  This is the "elevator" policy.

The re-ordering tends to favour the sequential operation, and repeatedly delay other requested operations.  The `mq-deadline` scheduler sets a soft "deadline" for how long operations can be deferred in favour of sequential I/O.  The default deadline for reads is *half a second* (`read_expire`).

BFQ notices when other programs have been delayed, and enforces fairness between different programs.  `mq-deadline` does not attempt to enforce fairness.  This is a key reason why BFQ helps.  There are other aspects as well. -->


### Where you might want to *not* use BFQ

Linux kernel 5.3 fixes a problem on faster models of NVMe device.  In earlier versions, BFQ might effectively delegate scheduling to the fast device.  This meant you might not see expected benefits from using BFQ.  You might even see a large penalty (I do not know why).[3][4][5]

General advice on I/O schedulers remains frustratingly confusing.  At least to start with, BFQ focused more on personal devices.  On large servers, the situation seems much more complex.

BFQ developers have some interesting suggestions for servers.[6]

On large servers, Red Hat Enterprise Linux is popular.  RHEL suggested CFQ should only be applied to individual physical disks.[7]

CFQ defaults were not appropriate for expensive hardware RAID.  This is explicit in [cfq-iosched.txt](https://github.com/torvalds/linux/blob/v4.20/Documentation/block/cfq-iosched.txt).  The same reason applies to expensive centralized storage - "enterprise" priced SAN/NAS hardware.  On the other hand, BFQ and CFQ can work well with software RAID.

Partitioning server hardware into multiple busy virtual machines, also raises major problems.  It means you have (at least) two levels where I/O scheduling could happen.  Neither level has all the information, and the different levels could be in conflict.  Therefore RHEL 7 has a general recommendation to use `none` or `deadline` on virtual disks.

Whereas for the bottom level: "when using [RHEL 7] as a host for virtualized guests, the default cfq scheduler is usually ideal. This scheduler performs well on nearly all workloads. If, however, minimizing I/O latency is more important than maximizing I/O throughput on the guest workloads, it may be beneficial to use the deadline scheduler. The `deadline` is also the scheduler used by the `tuned` profile `virtual-host`."[8]

If you are using a *very* fast device, and you see CPU usage become a limiting factor, you might want to use one of the other schedulers instead of BFQ.  (`none`, or perhaps `kyber`, if your device is really fast.  `deadline` if your CPU is just too slow).

For more fine tuning than "CFQ (defaults) or not", it gets even harder to find clear information.  It feels strange to me, considering e.g. the defaults for `deadline` are unchanged since its creation, in 2002/3.


## References

[1] "The current version of BFQ can handle devices
performing at most ~30K IOPS; at most ~50 KIOPS on faster CPUs. These
are about the same limits as CFQ. There may be room for noticeable
improvements regarding these limits, but, given the overall
limitations of blk itself, I thought it was not the case to further
delay this new submission." [Paolo Valente, 2016](https://lwn.net/Articles/704648/)

[2] "This system reaches ~500 KIOPS with BFQ, against ~1 MIOPS with the other [current] I/O schedulers."  [Paolo Valente, 2019](http://archive.today/2019.07.18-105116/http://algo.ing.unimo.it/people/paolo/disk_sched/results.php)

[3] [Linux 5.0 I/O Scheduler Benchmarks](https://www.phoronix.com/scan.php?page=article&item=linux5-io-sched&num=2), from phoronix.com.

[4] "Under write load on a Samsung SSD 970 PRO, gnome-terminal starts in 1.5 seconds after this fix, against 15 seconds before the fix." [[PATCH BUGFIX IMPROVEMENT V3 1/1] block, bfq: check also in-flight I/O in dispatch plugging](https://lore.kernel.org/lkml/20190718070852.34568-2-paolo.valente@linaro.org/)

[5] My own attempt to understand the patch message in [4]: https://groups.google.com/forum/#!msg/bfq-iosched/OqtDMCR3UTE/VaawzRkNBQAJ

[6] https://www.linaro.org/blog/io-bandwidth-management-for-production-quality-services/

[7] Performance tuning guide for RHEL 7: [Section 8.1.1: I/O Schedulers](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/performance_tuning_guide/chap-red_hat_enterprise_linux-performance_tuning_guide-storage_and_file_systems#sect-Red_Hat_Enterprise_Linux-Performance_Tuning_Guide-Considerations-IO_Schedulers).

[8] [What is the suggested I/O scheduler to improve disk performance when using Red Hat Enterprise Linux \[versions 4-7\] with virtualization? - Red Hat Customer Portal](https://access.redhat.com/solutions/5427)


## License

This role is licensed as GPLv3.  Please open an issue if this creates any problem.
