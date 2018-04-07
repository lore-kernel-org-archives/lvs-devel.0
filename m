From: syzbot <syzbot+7810ed2e0cb359580c17@syzkaller.appspotmail.com>
Subject: INFO: task hung in do_ip_vs_set_ctl (2)
Date: Sat, 07 Apr 2018 04:55:01 -0700
Message-ID: <94eb2c059ce0bca273056940d77d@google.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"; delsp="yes"
Content-Transfer-Encoding: 7bit
To: coreteam@netfilter.org, davem@davemloft.net, fw@strlen.de, horms@verge.net.au, ja@ssi.bg, kadlec@blackhole.kfki.hu, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, pablo@netfilter.org, syzkaller-bugs@googlegroups.com, wensong@linux-vs.org

Hello,

syzbot hit the following crash on upstream commit
3fd14cdcc05a682b03743683ce3a726898b20555 (Fri Apr 6 19:15:41 2018 +0000)
Merge tag 'mtd/for-4.17' of git://git.infradead.org/linux-mtd
syzbot dashboard link:  
https://syzkaller.appspot.com/bug?extid=7810ed2e0cb359580c17

Unfortunately, I don't have any reproducer for this crash yet.
Raw console output:  
https://syzkaller.appspot.com/x/log.txt?id=5452586266132480
Kernel config:  
https://syzkaller.appspot.com/x/.config?id=-5813481738265533882
compiler: gcc (GCC) 8.0.1 20180301 (experimental)

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+7810ed2e0cb359580c17@syzkaller.appspotmail.com
It will help syzbot understand when the bug is fixed. See footer for  
details.
If you forward the report, please keep this part and the footer.

IPVS: stopping backup sync thread 25820 ...
IPVS: sync thread started: state = BACKUP, mcast_ifn = lo, syncid = 0, id =  
0
IPVS: sync thread started: state = BACKUP, mcast_ifn = bridge0, syncid = 5,  
id = 0
IPVS: stopping backup sync thread 25825 ...
INFO: task syz-executor4:25814 blocked for more than 120 seconds.
       Not tainted 4.16.0+ #4
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
syz-executor4   D23496 25814   4577 0x00000004
Call Trace:
  context_switch kernel/sched/core.c:2848 [inline]
  __schedule+0x807/0x1e40 kernel/sched/core.c:3490
  schedule+0xef/0x430 kernel/sched/core.c:3549
  schedule_preempt_disabled+0x10/0x20 kernel/sched/core.c:3607
  __mutex_lock_common kernel/locking/mutex.c:833 [inline]
  __mutex_lock+0xe38/0x17f0 kernel/locking/mutex.c:893
  mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:908
  do_ip_vs_set_ctl+0x562/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2388
  nf_sockopt net/netfilter/nf_sockopt.c:106 [inline]
  nf_setsockopt+0x7d/0xd0 net/netfilter/nf_sockopt.c:115
  ip_setsockopt+0xd8/0xf0 net/ipv4/ip_sockglue.c:1253
  udp_setsockopt+0x62/0xa0 net/ipv4/udp.c:2413
  ipv6_setsockopt+0x149/0x170 net/ipv6/ipv6_sockglue.c:917
  udpv6_setsockopt+0x62/0xa0 net/ipv6/udp.c:1424
  sock_common_setsockopt+0x9a/0xe0 net/core/sock.c:3039
  __sys_setsockopt+0x1bd/0x390 net/socket.c:1903
  SYSC_setsockopt net/socket.c:1914 [inline]
  SyS_setsockopt+0x34/0x50 net/socket.c:1911
  do_syscall_64+0x29e/0x9d0 arch/x86/entry/common.c:287
  entry_SYSCALL_64_after_hwframe+0x42/0xb7
RIP: 0033:0x455259
RSP: 002b:00007f2f6a5c0c68 EFLAGS: 00000246 ORIG_RAX: 0000000000000036
RAX: ffffffffffffffda RBX: 00007f2f6a5c16d4 RCX: 0000000000455259
RDX: 000000000000048b RSI: 0000000000000000 RDI: 0000000000000019
RBP: 000000000072bea0 R08: 0000000000000018 R09: 0000000000000000
R10: 0000000020000100 R11: 0000000000000246 R12: 00000000ffffffff
R13: 0000000000000520 R14: 00000000006faba0 R15: 0000000000000000

Showing all locks held in the system:
3 locks held by kworker/1:0/18:
  #0: 000000005979db97 ((wq_completion)"events"){+.+.}, at:  
__write_once_size include/linux/compiler.h:215 [inline]
  #0: 000000005979db97 ((wq_completion)"events"){+.+.}, at:  
arch_atomic64_set arch/x86/include/asm/atomic64_64.h:34 [inline]
  #0: 000000005979db97 ((wq_completion)"events"){+.+.}, at: atomic64_set  
include/asm-generic/atomic-instrumented.h:40 [inline]
  #0: 000000005979db97 ((wq_completion)"events"){+.+.}, at: atomic_long_set  
include/asm-generic/atomic-long.h:57 [inline]
  #0: 000000005979db97 ((wq_completion)"events"){+.+.}, at: set_work_data  
kernel/workqueue.c:617 [inline]
  #0: 000000005979db97 ((wq_completion)"events"){+.+.}, at:  
set_work_pool_and_clear_pending kernel/workqueue.c:644 [inline]
  #0: 000000005979db97 ((wq_completion)"events"){+.+.}, at:  
process_one_work+0xaef/0x1b50 kernel/workqueue.c:2116
  #1: 0000000034433a79 (deferred_process_work){+.+.}, at:  
process_one_work+0xb46/0x1b50 kernel/workqueue.c:2120
  #2: 00000000c152a7e0 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
3 locks held by kworker/1:1/25:
  #0: 0000000004c9dcc7 ((wq_completion)"%s"("ipv6_addrconf")){+.+.}, at:  
__write_once_size include/linux/compiler.h:215 [inline]
  #0: 0000000004c9dcc7 ((wq_completion)"%s"("ipv6_addrconf")){+.+.}, at:  
arch_atomic64_set arch/x86/include/asm/atomic64_64.h:34 [inline]
  #0: 0000000004c9dcc7 ((wq_completion)"%s"("ipv6_addrconf")){+.+.}, at:  
atomic64_set include/asm-generic/atomic-instrumented.h:40 [inline]
  #0: 0000000004c9dcc7 ((wq_completion)"%s"("ipv6_addrconf")){+.+.}, at:  
atomic_long_set include/asm-generic/atomic-long.h:57 [inline]
  #0: 0000000004c9dcc7 ((wq_completion)"%s"("ipv6_addrconf")){+.+.}, at:  
set_work_data kernel/workqueue.c:617 [inline]
  #0: 0000000004c9dcc7 ((wq_completion)"%s"("ipv6_addrconf")){+.+.}, at:  
set_work_pool_and_clear_pending kernel/workqueue.c:644 [inline]
  #0: 0000000004c9dcc7 ((wq_completion)"%s"("ipv6_addrconf")){+.+.}, at:  
process_one_work+0xaef/0x1b50 kernel/workqueue.c:2116
  #1: 00000000fcc18889 ((addr_chk_work).work){+.+.}, at:  
process_one_work+0xb46/0x1b50 kernel/workqueue.c:2120
  #2: 00000000c152a7e0 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
2 locks held by khungtaskd/882:
  #0: 000000009c9e6fd6 (rcu_read_lock){....}, at:  
check_hung_uninterruptible_tasks kernel/hung_task.c:175 [inline]
  #0: 000000009c9e6fd6 (rcu_read_lock){....}, at: watchdog+0x1ff/0xf60  
kernel/hung_task.c:249
  #1: 0000000086407811 (tasklist_lock){.+.+}, at:  
debug_show_all_locks+0xde/0x34a kernel/locking/lockdep.c:4470
2 locks held by getty/4501:
  #0: 0000000055d02921 (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 000000008595151e (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x321/0x1cc0 drivers/tty/n_tty.c:2131
2 locks held by getty/4502:
  #0: 00000000edb0964a (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 00000000b6f18e79 (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x321/0x1cc0 drivers/tty/n_tty.c:2131
2 locks held by getty/4503:
  #0: 000000002383a0c1 (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 000000004c0469cb (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x321/0x1cc0 drivers/tty/n_tty.c:2131
2 locks held by getty/4504:
  #0: 00000000f3591a78 (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 00000000148d6bd9 (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x321/0x1cc0 drivers/tty/n_tty.c:2131
2 locks held by getty/4505:
  #0: 000000007c3caa91 (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 00000000da492356 (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x321/0x1cc0 drivers/tty/n_tty.c:2131
2 locks held by getty/4506:
  #0: 000000006efbca4d (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 0000000070306487 (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x321/0x1cc0 drivers/tty/n_tty.c:2131
2 locks held by getty/24388:
  #0: 000000003730ef1a (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 00000000de906401 (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x321/0x1cc0 drivers/tty/n_tty.c:2131
2 locks held by syz-executor4/25814:
  #0: 00000000c152a7e0 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
  #1: 000000008674f843 (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x562/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2388
1 lock held by syz-executor4/25826:
  #0: 000000008674f843 (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syz-executor4/25834:
  #0: 00000000c152a7e0 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by ipvs-b:3:0/25825:
  #0: 00000000c152a7e0 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74

=============================================

NMI backtrace for cpu 0
CPU: 0 PID: 882 Comm: khungtaskd Not tainted 4.16.0+ #4
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1b9/0x294 lib/dump_stack.c:113
  nmi_cpu_backtrace.cold.4+0x19/0xce lib/nmi_backtrace.c:103
  nmi_trigger_cpumask_backtrace+0x151/0x192 lib/nmi_backtrace.c:62
  arch_trigger_cpumask_backtrace+0x14/0x20 arch/x86/kernel/apic/hw_nmi.c:38
  trigger_all_cpu_backtrace include/linux/nmi.h:138 [inline]
  check_hung_task kernel/hung_task.c:132 [inline]
  check_hung_uninterruptible_tasks kernel/hung_task.c:190 [inline]
  watchdog+0xc10/0xf60 kernel/hung_task.c:249
  kthread+0x345/0x410 kernel/kthread.c:238
  ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:411
Sending NMI from CPU 0 to CPUs 1:
NMI backtrace for cpu 1 skipped: idling at native_safe_halt+0x6/0x10  
arch/x86/include/asm/irqflags.h:54


---
This bug is generated by a dumb bot. It may contain errors.
See https://goo.gl/tpsmEJ for details.
Direct all questions to syzkaller@googlegroups.com.

syzbot will keep track of this bug report.
If you forgot to add the Reported-by tag, once the fix for this bug is  
merged
into any tree, please reply to this email with:
#syz fix: exact-commit-title
To mark this as a duplicate of another syzbot report, please reply with:
#syz dup: exact-subject-of-another-report
If it's a one-off invalid bug report, please reply with:
#syz invalid
Note: if the crash happens again, it will cause creation of a new bug  
report.
Note: all commands must start from beginning of the line in the email body.
