From: syzbot <syzbot+7810ed2e0cb359580c17@syzkaller.appspotmail.com>
Subject: Re: INFO: task hung in do_ip_vs_set_ctl (2)
Date: Thu, 12 Apr 2018 23:23:01 -0700
Message-ID: <0000000000006fa5b10569b4e796@google.com>
References: <94eb2c059ce0bca273056940d77d@google.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <94eb2c059ce0bca273056940d77d@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"; delsp="yes"
Content-Transfer-Encoding: 7bit
To: coreteam@netfilter.org, davem@davemloft.net, fw@strlen.de, horms@verge.net.au, ja@ssi.bg, kadlec@blackhole.kfki.hu, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, pablo@netfilter.org, syzkaller-bugs@googlegroups.com, wensong@linux-vs.org

syzbot has found reproducer for the following crash on net-next commit
17dec0a949153d9ac00760ba2f5b78cb583e995f (Wed Apr 4 02:15:32 2018 +0000)
Merge branch 'userns-linus' of  
git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace
syzbot dashboard link:  
https://syzkaller.appspot.com/bug?extid=7810ed2e0cb359580c17

So far this crash happened 2 times on net-next, upstream.
C reproducer: https://syzkaller.appspot.com/x/repro.c?id=5922062967242752
syzkaller reproducer:  
https://syzkaller.appspot.com/x/repro.syz?id=5359824032235520
Raw console output:  
https://syzkaller.appspot.com/x/log.txt?id=6352399027404800
Kernel config:  
https://syzkaller.appspot.com/x/.config?id=-2735707888269579554
compiler: gcc (GCC) 8.0.1 20180301 (experimental)

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+7810ed2e0cb359580c17@syzkaller.appspotmail.com
It will help syzbot understand when the bug is fixed.

INFO: task syzkaller402106:4498 blocked for more than 120 seconds.
       Not tainted 4.16.0+ #1
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
syzkaller402106 D22184  4498   4494 0x00000000
Call Trace:
  context_switch kernel/sched/core.c:2848 [inline]
  __schedule+0x807/0x1e40 kernel/sched/core.c:3490
  schedule+0xef/0x430 kernel/sched/core.c:3549
  schedule_preempt_disabled+0x10/0x20 kernel/sched/core.c:3607
  __mutex_lock_common kernel/locking/mutex.c:833 [inline]
  __mutex_lock+0xe38/0x17f0 kernel/locking/mutex.c:893
  mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:908
  do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
  nf_sockopt net/netfilter/nf_sockopt.c:106 [inline]
  nf_setsockopt+0x7d/0xd0 net/netfilter/nf_sockopt.c:115
  ip_setsockopt+0xd8/0xf0 net/ipv4/ip_sockglue.c:1253
  tcp_setsockopt+0x93/0xe0 net/ipv4/tcp.c:2888
  sock_common_setsockopt+0x9a/0xe0 net/core/sock.c:3039
  smc_setsockopt+0xc7/0x120 net/smc/af_smc.c:1289
  __sys_setsockopt+0x1bd/0x390 net/socket.c:1903
  SYSC_setsockopt net/socket.c:1914 [inline]
  SyS_setsockopt+0x34/0x50 net/socket.c:1911
  do_syscall_64+0x29e/0x9d0 arch/x86/entry/common.c:287
  entry_SYSCALL_64_after_hwframe+0x42/0xb7
RIP: 0033:0x445959
RSP: 002b:00007f2770618db8 EFLAGS: 00000246 ORIG_RAX: 0000000000000036
RAX: ffffffffffffffda RBX: 00000000006dac24 RCX: 0000000000445959
RDX: 000000000000048c RSI: 0000000000000000 RDI: 0000000000000003
RBP: 00000000006dac20 R08: 0000000000000018 R09: 0000000000000000
R10: 0000000020000140 R11: 0000000000000246 R12: 0000000000000000
R13: 00007ffd81ae8f6f R14: 00007f27706199c0 R15: 0000000000000001

Showing all locks held in the system:
3 locks held by kworker/0:0/4:
  #0: 000000007346131c ((wq_completion)"%s"("ipv6_addrconf")){+.+.}, at:  
__write_once_size include/linux/compiler.h:215 [inline]
  #0: 000000007346131c ((wq_completion)"%s"("ipv6_addrconf")){+.+.}, at:  
arch_atomic64_set arch/x86/include/asm/atomic64_64.h:34 [inline]
  #0: 000000007346131c ((wq_completion)"%s"("ipv6_addrconf")){+.+.}, at:  
atomic64_set include/asm-generic/atomic-instrumented.h:40 [inline]
  #0: 000000007346131c ((wq_completion)"%s"("ipv6_addrconf")){+.+.}, at:  
atomic_long_set include/asm-generic/atomic-long.h:57 [inline]
  #0: 000000007346131c ((wq_completion)"%s"("ipv6_addrconf")){+.+.}, at:  
set_work_data kernel/workqueue.c:617 [inline]
  #0: 000000007346131c ((wq_completion)"%s"("ipv6_addrconf")){+.+.}, at:  
set_work_pool_and_clear_pending kernel/workqueue.c:644 [inline]
  #0: 000000007346131c ((wq_completion)"%s"("ipv6_addrconf")){+.+.}, at:  
process_one_work+0xaef/0x1b50 kernel/workqueue.c:2116
  #1: 00000000894403a3 ((addr_chk_work).work){+.+.}, at:  
process_one_work+0xb46/0x1b50 kernel/workqueue.c:2120
  #2: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
2 locks held by khungtaskd/877:
  #0: 00000000706bfe1c (rcu_read_lock){....}, at:  
check_hung_uninterruptible_tasks kernel/hung_task.c:175 [inline]
  #0: 00000000706bfe1c (rcu_read_lock){....}, at: watchdog+0x1ff/0xf60  
kernel/hung_task.c:249
  #1: 00000000761e40d2 (tasklist_lock){.+.+}, at:  
debug_show_all_locks+0xde/0x34a kernel/locking/lockdep.c:4470
2 locks held by getty/4464:
  #0: 00000000f90a9320 (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 000000005dd151b8 (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x321/0x1cc0 drivers/tty/n_tty.c:2131
2 locks held by getty/4465:
  #0: 00000000737b5b26 (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 0000000017bb1ae5 (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x321/0x1cc0 drivers/tty/n_tty.c:2131
2 locks held by getty/4466:
  #0: 00000000badd071e (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 00000000a46de9fa (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x321/0x1cc0 drivers/tty/n_tty.c:2131
2 locks held by getty/4467:
  #0: 00000000112731eb (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 00000000166cdec3 (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x321/0x1cc0 drivers/tty/n_tty.c:2131
2 locks held by getty/4468:
  #0: 00000000d9915e26 (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 00000000abf02ab1 (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x321/0x1cc0 drivers/tty/n_tty.c:2131
2 locks held by getty/4469:
  #0: 0000000041b9a2d2 (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 000000003dbb7393 (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x321/0x1cc0 drivers/tty/n_tty.c:2131
2 locks held by getty/4470:
  #0: 00000000dd811911 (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 00000000c9586a34 (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x321/0x1cc0 drivers/tty/n_tty.c:2131
1 lock held by syzkaller402106/4498:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4517:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4523:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4535:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4537:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4548:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4553:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4564:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4571:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4581:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4588:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4598:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4603:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4615:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4620:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4631:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4511:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4514:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4526:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4530:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4542:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4546:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4558:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4562:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4574:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4578:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4590:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4594:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4606:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4610:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4622:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4626:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4501:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4518:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4522:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4533:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4539:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4550:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4556:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4567:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4572:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4582:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4586:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4597:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4602:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4612:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4617:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4628:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4506:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4515:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4527:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4531:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4543:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4547:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4559:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4563:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4575:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4579:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4591:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4595:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4607:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4611:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4623:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4627:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4503:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4519:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4524:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4534:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4538:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4549:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4554:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4566:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4569:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4580:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4585:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4596:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4601:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4613:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4619:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4630:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
2 locks held by syzkaller402106/4508:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
  #1: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x562/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2388
1 lock held by syzkaller402106/4513:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4525:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4529:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4541:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4545:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4557:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4561:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4573:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4577:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4589:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4593:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4605:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4609:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4621:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4625:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4507:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4516:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4521:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4532:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4540:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4551:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4555:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4565:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4570:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4583:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4587:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4599:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4604:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4614:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4618:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4629:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4509:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4512:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4520:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4528:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4536:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4544:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4552:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4560:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4568:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4576:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4584:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4592:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4600:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4608:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by syzkaller402106/4616:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74
1 lock held by syzkaller402106/4624:
  #0: 00000000bfa7d99e (ipvs->sync_mutex){+.+.}, at:  
do_ip_vs_set_ctl+0x339/0x1d30 net/netfilter/ipvs/ip_vs_ctl.c:2393
1 lock held by ipvs-b:0:0/4510:
  #0: 00000000ddc85278 (rtnl_mutex){+.+.}, at: rtnl_lock+0x17/0x20  
net/core/rtnetlink.c:74

=============================================

NMI backtrace for cpu 1
CPU: 1 PID: 877 Comm: khungtaskd Not tainted 4.16.0+ #1
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:17 [inline]
  dump_stack+0x1b9/0x29f lib/dump_stack.c:53
  nmi_cpu_backtrace.cold.4+0x19/0xce lib/nmi_backtrace.c:103
  nmi_trigger_cpumask_backtrace+0x151/0x192 lib/nmi_backtrace.c:62
  arch_trigger_cpumask_backtrace+0x14/0x20 arch/x86/kernel/apic/hw_nmi.c:38
  trigger_all_cpu_backtrace include/linux/nmi.h:138 [inline]
  check_hung_task kernel/hung_task.c:132 [inline]
  check_hung_uninterruptible_tasks kernel/hung_task.c:190 [inline]
  watchdog+0xc10/0xf60 kernel/hung_task.c:249
  kthread+0x345/0x410 kernel/kthread.c:238
  ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:411
Sending NMI from CPU 1 to CPUs 0:
NMI backtrace for cpu 0
CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.16.0+ #1
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:timekeeping_delta_to_ns kernel/time/timekeeping.c:351 [inline]
RIP: 0010:timekeeping_get_ns kernel/time/timekeeping.c:362 [inline]
RIP: 0010:ktime_get+0x308/0x430 kernel/time/timekeeping.c:764
RSP: 0018:ffff8801db007b98 EFLAGS: 00000002
RAX: 000000002930e468 RBX: 0000023e54000000 RCX: 0000000000000017
RDX: ffffed003b600f79 RSI: ffffffff8166cd99 RDI: 0000000000000004
RBP: ffff8801db007c90 R08: ffffffff88a752c0 R09: 0000000000000000
R10: ffffed0043fff001 R11: ffff88021fff8017 R12: dffffc0000000000
R13: 000000000006509e R14: ffff8801db007c68 R15: ffffffff88b172a0
FS:  0000000000000000(0000) GS:ffff8801db000000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000000090e000 CR3: 00000001b130f000 CR4: 00000000001406f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
  <IRQ>
  tick_nohz_irq_enter kernel/time/tick-sched.c:1124 [inline]
  tick_irq_enter+0xbc/0x3f0 kernel/time/tick-sched.c:1145
  irq_enter+0xb6/0xd0 kernel/softirq.c:346
  scheduler_ipi+0x39b/0xa30 kernel/sched/core.c:1768
  smp_reschedule_interrupt+0xed/0x660 arch/x86/kernel/smp.c:277
  reschedule_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:886
  </IRQ>
RIP: 0010:native_safe_halt+0x6/0x10 arch/x86/include/asm/irqflags.h:54
RSP: 0018:ffffffff88a07c38 EFLAGS: 00000282 ORIG_RAX: ffffffffffffff02
RAX: dffffc0000000000 RBX: 1ffffffff1140f8a RCX: 0000000000000000
RDX: 1ffffffff1162e58 RSI: 0000000000000001 RDI: ffffffff88b172c0
RBP: ffffffff88a07c38 R08: ffffffff88a752c0 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
R13: ffffffff88a07cf0 R14: ffffffff88b172b0 R15: 0000000000000000
  arch_safe_halt arch/x86/include/asm/paravirt.h:94 [inline]
  default_idle+0xc2/0x440 arch/x86/kernel/process.c:354
  arch_cpu_idle+0x10/0x20 arch/x86/kernel/process.c:345
  default_idle_call+0x6d/0x90 kernel/sched/idle.c:93
  cpuidle_idle_call kernel/sched/idle.c:151 [inline]
  do_idle+0x2f4/0x3c0 kernel/sched/idle.c:241
  cpu_startup_entry+0x104/0x120 kernel/sched/idle.c:346
  rest_init+0xe1/0xe4 init/main.c:437
  start_kernel+0x887/0x8ae init/main.c:717
  x86_64_start_reservations+0x29/0x2b arch/x86/kernel/head64.c:443
  x86_64_start_kernel+0x76/0x79 arch/x86/kernel/head64.c:424
  secondary_startup_64+0xa5/0xb0 arch/x86/kernel/head_64.S:242
Code: ff ff 0f b6 8d 18 ff ff ff 48 ba 00 00 00 00 00 fc ff df 48 03 95 08  
ff ff ff 48 0f af d8 48 8b 85 10 ff ff ff 48 01 d8 48 d3 e8 <48> 03 85 20  
ff ff ff 48 c7 02 00 00 00 00 48 c7 42 08 00 00 00

