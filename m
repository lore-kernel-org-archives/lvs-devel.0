From: Julian Anastasov <ja@ssi.bg>
Subject: Re: INFO: task hung in stop_sync_thread (2)
Date: Thu, 29 Mar 2018 23:10:58 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1803292252160.4780@ja.home.ssi.bg>
References: <000000000000878b6a05688805c5@google.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <000000000000878b6a05688805c5@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: syzbot <syzbot+5fe074c01b2032ce9618@syzkaller.appspotmail.com>
Cc: coreteam@netfilter.org, davem@davemloft.net, fw@strlen.de, horms@verge.net.au, kadlec@blackhole.kfki.hu, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, pablo@netfilter.org, syzkaller-bugs@googlegroups.com, wensong@linux-vs.org


	Hello,

On Thu, 29 Mar 2018, syzbot wrote:

> syzbot hit the following crash on net-next commit
> 5d22d47b9ed96eddb35821dc2cc4f629f45827f7 (Tue Mar 27 17:33:21 2018 +0000)
> Merge branch 'sfc-filter-locking'
> syzbot dashboard link:
> https://syzkaller.appspot.com/bug?extid=5fe074c01b2032ce9618
> 
> Unfortunately, I don't have any reproducer for this crash yet.
> Raw console output:
> https://syzkaller.appspot.com/x/log.txt?id=6119456711376896
> Kernel config: https://syzkaller.appspot.com/x/.config?id=4372867303600475372
> compiler: gcc (GCC) 7.1.1 20170620
> 
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+5fe074c01b2032ce9618@syzkaller.appspotmail.com
> It will help syzbot understand when the bug is fixed. See footer for details.
> If you forward the report, please keep this part and the footer.
> 
> IPVS: sync thread started: state = BACKUP, mcast_ifn = syz_tun, syncid = 4, id
> IPVS: = 0
> IPVS: stopping backup sync thread 25415 ...
> INFO: task syz-executor7:25421 blocked for more than 120 seconds.

	I think, I know what happens: start_sync_thread holds
rtnl_lock while calling kthread_stop on error. The backup kthread is
signalled and it tries to rtnl_lock in sock_release => lockup.
I think, my fix will solve both reports, only that there is no
reproducer for this one to test the fix with test command.

>      Not tainted 4.16.0-rc6+ #284
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> syz-executor7   D23688 25421   4408 0x00000004
> Call Trace:
> context_switch kernel/sched/core.c:2862 [inline]
> __schedule+0x8fb/0x1ec0 kernel/sched/core.c:3440
> schedule+0xf5/0x430 kernel/sched/core.c:3499
> schedule_timeout+0x1a3/0x230 kernel/time/timer.c:1777
> do_wait_for_common kernel/sched/completion.c:86 [inline]
> __wait_for_common kernel/sched/completion.c:107 [inline]
> wait_for_common kernel/sched/completion.c:118 [inline]
> wait_for_completion+0x415/0x770 kernel/sched/completion.c:139
> kthread_stop+0x14a/0x7a0 kernel/kthread.c:530
> stop_sync_thread+0x3d9/0x740 net/netfilter/ipvs/ip_vs_sync.c:1996
> do_ip_vs_set_ctl+0x2b1/0x1cc0 net/netfilter/ipvs/ip_vs_ctl.c:2394
> nf_sockopt net/netfilter/nf_sockopt.c:106 [inline]
> nf_setsockopt+0x67/0xc0 net/netfilter/nf_sockopt.c:115
> ip_setsockopt+0x97/0xa0 net/ipv4/ip_sockglue.c:1253
> sctp_setsockopt+0x2ca/0x63e0 net/sctp/socket.c:4154
> sock_common_setsockopt+0x95/0xd0 net/core/sock.c:3039
> SYSC_setsockopt net/socket.c:1850 [inline]
> SyS_setsockopt+0x189/0x360 net/socket.c:1829
> do_syscall_64+0x281/0x940 arch/x86/entry/common.c:287
> entry_SYSCALL_64_after_hwframe+0x42/0xb7
> RIP: 0033:0x454889
> RSP: 002b:00007fc927626c68 EFLAGS: 00000246 ORIG_RAX: 0000000000000036
> RAX: ffffffffffffffda RBX: 00007fc9276276d4 RCX: 0000000000454889
> RDX: 000000000000048c RSI: 0000000000000000 RDI: 0000000000000017
> RBP: 000000000072bf58 R08: 0000000000000018 R09: 0000000000000000
> R10: 0000000020000000 R11: 0000000000000246 R12: 00000000ffffffff
> R13: 000000000000051c R14: 00000000006f9b40 R15: 0000000000000001
> 
> Showing all locks held in the system:
> 2 locks held by khungtaskd/868:
> #0:  (rcu_read_lock){....}, at: [<00000000a1a8f002>]
> check_hung_uninterruptible_tasks kernel/hung_task.c:175 [inline]
> #0:  (rcu_read_lock){....}, at: [<00000000a1a8f002>] watchdog+0x1c5/0xd60
> kernel/hung_task.c:249
> #1:  (tasklist_lock){.+.+}, at: [<0000000037c2f8f9>]
> debug_show_all_locks+0xd3/0x3d0 kernel/locking/lockdep.c:4470
> 1 lock held by rsyslogd/4247:
> #0:  (&f->f_pos_lock){+.+.}, at: [<000000000d8d6983>] __fdget_pos+0x12b/0x190
> fs/file.c:765
> 2 locks held by getty/4338:
> #0:  (&tty->ldisc_sem){++++}, at: [<00000000bee98654>]
> ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
> #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000c1d180aa>]
> n_tty_read+0x2ef/0x1a40 drivers/tty/n_tty.c:2131
> 2 locks held by getty/4339:
> #0:  (&tty->ldisc_sem){++++}, at: [<00000000bee98654>]
> ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
> #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000c1d180aa>]
> n_tty_read+0x2ef/0x1a40 drivers/tty/n_tty.c:2131
> 2 locks held by getty/4340:
> #0:  (&tty->ldisc_sem){++++}, at: [<00000000bee98654>]
> ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
> #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000c1d180aa>]
> n_tty_read+0x2ef/0x1a40 drivers/tty/n_tty.c:2131
> 2 locks held by getty/4341:
> #0:  (&tty->ldisc_sem){++++}, at: [<00000000bee98654>]
> ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
> #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000c1d180aa>]
> n_tty_read+0x2ef/0x1a40 drivers/tty/n_tty.c:2131
> 2 locks held by getty/4342:
> #0:  (&tty->ldisc_sem){++++}, at: [<00000000bee98654>]
> ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
> #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000c1d180aa>]
> n_tty_read+0x2ef/0x1a40 drivers/tty/n_tty.c:2131
> 2 locks held by getty/4343:
> #0:  (&tty->ldisc_sem){++++}, at: [<00000000bee98654>]
> ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
> #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000c1d180aa>]
> n_tty_read+0x2ef/0x1a40 drivers/tty/n_tty.c:2131
> 2 locks held by getty/4344:
> #0:  (&tty->ldisc_sem){++++}, at: [<00000000bee98654>]
> ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
> #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000c1d180aa>]
> n_tty_read+0x2ef/0x1a40 drivers/tty/n_tty.c:2131
> 3 locks held by kworker/0:5/6494:
> #0:  ((wq_completion)"%s"("ipv6_addrconf")){+.+.}, at: [<00000000a062b18e>]
> work_static include/linux/workqueue.h:198 [inline]
> #0:  ((wq_completion)"%s"("ipv6_addrconf")){+.+.}, at: [<00000000a062b18e>]
> set_work_data kernel/workqueue.c:619 [inline]
> #0:  ((wq_completion)"%s"("ipv6_addrconf")){+.+.}, at: [<00000000a062b18e>]
> set_work_pool_and_clear_pending kernel/workqueue.c:646 [inline]
> #0:  ((wq_completion)"%s"("ipv6_addrconf")){+.+.}, at: [<00000000a062b18e>]
> process_one_work+0xb12/0x1bb0 kernel/workqueue.c:2084
> #1:  ((addr_chk_work).work){+.+.}, at: [<00000000278427d5>]
> process_one_work+0xb89/0x1bb0 kernel/workqueue.c:2088
> #2:  (rtnl_mutex){+.+.}, at: [<00000000066e35ac>] rtnl_lock+0x17/0x20
> net/core/rtnetlink.c:74
> 1 lock held by syz-executor7/25421:
> #0:  (ipvs->sync_mutex){+.+.}, at: [<00000000d414a689>]
> do_ip_vs_set_ctl+0x277/0x1cc0 net/netfilter/ipvs/ip_vs_ctl.c:2393
> 2 locks held by syz-executor7/25427:
> #0:  (rtnl_mutex){+.+.}, at: [<00000000066e35ac>] rtnl_lock+0x17/0x20
> net/core/rtnetlink.c:74
> #1:  (ipvs->sync_mutex){+.+.}, at: [<00000000e6d48489>]
> do_ip_vs_set_ctl+0x10f8/0x1cc0 net/netfilter/ipvs/ip_vs_ctl.c:2388

	Above is start_sync_thread() waiting kthread to stop...

> 1 lock held by syz-executor7/25435:
> #0:  (rtnl_mutex){+.+.}, at: [<00000000066e35ac>] rtnl_lock+0x17/0x20
> net/core/rtnetlink.c:74
> 1 lock held by ipvs-b:2:0/25415:
> #0:  (rtnl_mutex){+.+.}, at: [<00000000066e35ac>] rtnl_lock+0x17/0x20
> net/core/rtnetlink.c:74

	backup kthread needs rtnl_lock to stop...

> 
> =============================================
> 
> NMI backtrace for cpu 1
> CPU: 1 PID: 868 Comm: khungtaskd Not tainted 4.16.0-rc6+ #284
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google
> 01/01/2011
> Call Trace:
> __dump_stack lib/dump_stack.c:17 [inline]
> dump_stack+0x194/0x24d lib/dump_stack.c:53
> nmi_cpu_backtrace+0x1d2/0x210 lib/nmi_backtrace.c:103
> nmi_trigger_cpumask_backtrace+0x123/0x180 lib/nmi_backtrace.c:62
> arch_trigger_cpumask_backtrace+0x14/0x20 arch/x86/kernel/apic/hw_nmi.c:38
> trigger_all_cpu_backtrace include/linux/nmi.h:138 [inline]
> check_hung_task kernel/hung_task.c:132 [inline]
> check_hung_uninterruptible_tasks kernel/hung_task.c:190 [inline]
> watchdog+0x90c/0xd60 kernel/hung_task.c:249
> kthread+0x33c/0x400 kernel/kthread.c:238
> ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:406
> Sending NMI from CPU 1 to CPUs 0:
> NMI backtrace for cpu 0 skipped: idling at native_safe_halt+0x6/0x10
> arch/x86/include/asm/irqflags.h:54
> 
> 
> ---
> This bug is generated by a dumb bot. It may contain errors.
> See https://goo.gl/tpsmEJ for details.
> Direct all questions to syzkaller@googlegroups.com.
> 
> syzbot will keep track of this bug report.
> If you forgot to add the Reported-by tag, once the fix for this bug is merged
> into any tree, please reply to this email with:
> #syz fix: exact-commit-title
> To mark this as a duplicate of another syzbot report, please reply with:
> #syz dup: exact-subject-of-another-report
> If it's a one-off invalid bug report, please reply with:
> #syz invalid
> Note: if the crash happens again, it will cause creation of a new bug report.
> Note: all commands must start from beginning of the line in the email body.

Regards
