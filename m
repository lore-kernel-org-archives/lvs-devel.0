From: syzbot <syzbot+3e9695f147fb529aa9bc@syzkaller.appspotmail.com>
Subject: KMSAN: uninit-value in ip_vs_lblc_check_expire
Date: Mon, 23 Apr 2018 06:28:01 -0700
Message-ID: <000000000000c66d94056a84011d@google.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"; delsp="yes"
Content-Transfer-Encoding: 7bit
To: coreteam@netfilter.org, davem@davemloft.net, fw@strlen.de, horms@verge.net.au, ja@ssi.bg, kadlec@blackhole.kfki.hu, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, pablo@netfilter.org, syzkaller-bugs@googlegroups.com, wensong@linux-vs.org

Hello,

syzbot hit the following crash on  
https://github.com/google/kmsan.git/master commit
d2d741e5d1898dfde1a75ea3d29a9a3e2edf0617 (Sun Apr 22 15:05:22 2018 +0000)
kmsan: add initialization for shmem pages
syzbot dashboard link:  
https://syzkaller.appspot.com/bug?extid=3e9695f147fb529aa9bc

So far this crash happened 3 times on  
https://github.com/google/kmsan.git/master.
Unfortunately, I don't have any reproducer for this crash yet.
Raw console output:  
https://syzkaller.appspot.com/x/log.txt?id=5822255644803072
Kernel config: https://syzkaller.appspot.com/x/.config?id=328654897048964367
compiler: clang version 7.0.0 (trunk 329391)

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+3e9695f147fb529aa9bc@syzkaller.appspotmail.com
It will help syzbot understand when the bug is fixed. See footer for  
details.
If you forward the report, please keep this part and the footer.

kernel msg: ebtables bug: please report to author: bad policy
==================================================================
BUG: KMSAN: uninit-value in ip_vs_lblc_check_expire+0xe62/0xf10  
net/netfilter/ipvs/ip_vs_lblc.c:315
CPU: 0 PID: 11383 Comm: syz-executor3 Not tainted 4.16.0+ #86
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  <IRQ>
  __dump_stack lib/dump_stack.c:17 [inline]
  dump_stack+0x185/0x1d0 lib/dump_stack.c:53
  kmsan_report+0x142/0x240 mm/kmsan/kmsan.c:1067
  __msan_warning_32+0x6c/0xb0 mm/kmsan/kmsan_instr.c:683
  ip_vs_lblc_check_expire+0xe62/0xf10 net/netfilter/ipvs/ip_vs_lblc.c:315
  call_timer_fn+0x26a/0x5a0 kernel/time/timer.c:1326
  expire_timers kernel/time/timer.c:1363 [inline]
  __run_timers+0xda7/0x11c0 kernel/time/timer.c:1666
  run_timer_softirq+0x43/0x70 kernel/time/timer.c:1692
  __do_softirq+0x56d/0x93d kernel/softirq.c:285
  invoke_softirq kernel/softirq.c:365 [inline]
  irq_exit+0x202/0x240 kernel/softirq.c:405
  exiting_irq+0xe/0x10 arch/x86/include/asm/apic.h:541
  smp_apic_timer_interrupt+0x64/0x90 arch/x86/kernel/apic/apic.c:1055
  apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:857
  </IRQ>
RIP: 0010:native_restore_fl arch/x86/include/asm/irqflags.h:37 [inline]
RIP: 0010:arch_local_irq_restore arch/x86/include/asm/irqflags.h:78 [inline]
RIP: 0010:vprintk_emit+0xcb2/0xff0 kernel/printk/printk.c:1899
RSP: 0018:ffff8801c2a1f0d8 EFLAGS: 00000296 ORIG_RAX: ffffffffffffff12
RAX: 0000000000000296 RBX: ffff8801574c4418 RCX: 0000000000040000
RDX: ffffc900033a6000 RSI: 00000000000001bf RDI: 00000000000001c0
RBP: ffff8801c2a1f1f8 R08: 000000219bfd8445 R09: ffff8801fd6d615d
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
R13: ffffffff8b300430 R14: 0000000000000000 R15: 0000000000000000
  vprintk_default+0x90/0xa0 kernel/printk/printk.c:1955
  vprintk_func+0x517/0x700 kernel/printk/printk_safe.c:379
  printk+0x1b6/0x1f0 kernel/printk/printk.c:1991
  translate_table+0x474/0x5e10 net/bridge/netfilter/ebtables.c:846
  do_replace_finish+0x1258/0x2ea0 net/bridge/netfilter/ebtables.c:1002
  do_replace+0x707/0x770 net/bridge/netfilter/ebtables.c:1141
  do_ebt_set_ctl+0x2ab/0x3c0 net/bridge/netfilter/ebtables.c:1518
  nf_sockopt net/netfilter/nf_sockopt.c:106 [inline]
  nf_setsockopt+0x476/0x4d0 net/netfilter/nf_sockopt.c:115
  ip_setsockopt+0x24b/0x2b0 net/ipv4/ip_sockglue.c:1261
  udp_setsockopt+0x108/0x1b0 net/ipv4/udp.c:2406
  ipv6_setsockopt+0x30c/0x340 net/ipv6/ipv6_sockglue.c:917
  udpv6_setsockopt+0x110/0x1c0 net/ipv6/udp.c:1422
  sock_common_setsockopt+0x136/0x170 net/core/sock.c:2975
  SYSC_setsockopt+0x4b8/0x570 net/socket.c:1849
  SyS_setsockopt+0x76/0xa0 net/socket.c:1828
  do_syscall_64+0x309/0x430 arch/x86/entry/common.c:287
  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
RIP: 0033:0x455389
RSP: 002b:00007f470c9e3c68 EFLAGS: 00000246 ORIG_RAX: 0000000000000036
RAX: ffffffffffffffda RBX: 00007f470c9e46d4 RCX: 0000000000455389
RDX: 0000000000000080 RSI: 0000000000000000 RDI: 0000000000000013
RBP: 000000000072bea0 R08: 0000000000000dd0 R09: 0000000000000000
R10: 0000000020000dc0 R11: 0000000000000246 R12: 00000000ffffffff
R13: 000000000000051d R14: 00000000006fab58 R15: 0000000000000000

Uninit was created at:
  kmsan_save_stack_with_flags mm/kmsan/kmsan.c:278 [inline]
  kmsan_alloc_meta_for_pages+0x161/0x3a0 mm/kmsan/kmsan.c:814
  kmsan_alloc_page+0x82/0xe0 mm/kmsan/kmsan.c:868
  __alloc_pages_nodemask+0xf5b/0x5dc0 mm/page_alloc.c:4283
  alloc_pages_current+0x6b5/0x970 mm/mempolicy.c:2055
  alloc_pages include/linux/gfp.h:494 [inline]
  kmalloc_order mm/slab_common.c:1164 [inline]
  kmalloc_order_trace+0xb9/0x390 mm/slab_common.c:1175
  kmalloc_large include/linux/slab.h:446 [inline]
  __kmalloc+0x332/0x350 mm/slub.c:3778
  kmalloc include/linux/slab.h:517 [inline]
  ip_vs_lblc_init_svc+0x57/0x310 net/netfilter/ipvs/ip_vs_lblc.c:355
  ip_vs_bind_scheduler+0xa4/0x1e0 net/netfilter/ipvs/ip_vs_sched.c:51
  ip_vs_add_service+0xa91/0x1d70 net/netfilter/ipvs/ip_vs_ctl.c:1265
  do_ip_vs_set_ctl+0x25c8/0x2790 net/netfilter/ipvs/ip_vs_ctl.c:2457
  nf_sockopt net/netfilter/nf_sockopt.c:106 [inline]
  nf_setsockopt+0x476/0x4d0 net/netfilter/nf_sockopt.c:115
  ip_setsockopt+0x24b/0x2b0 net/ipv4/ip_sockglue.c:1261
  raw_setsockopt+0x2e5/0x350 net/ipv4/raw.c:870
  sock_common_setsockopt+0x136/0x170 net/core/sock.c:2975
  SYSC_setsockopt+0x4b8/0x570 net/socket.c:1849
  SyS_setsockopt+0x76/0xa0 net/socket.c:1828
  do_syscall_64+0x309/0x430 arch/x86/entry/common.c:287
  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
==================================================================


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
