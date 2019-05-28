From: syzbot <syzbot+7e2e50c8adfccd2e5041@syzkaller.appspotmail.com>
Subject: memory leak in start_sync_thread
Date: Tue, 28 May 2019 11:28:05 -0700
Message-ID: <0000000000006d7e520589f6d3a9@google.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"; delsp="yes"
Content-Transfer-Encoding: 7bit
To: coreteam@netfilter.org, davem@davemloft.net, fw@strlen.de, horms@verge.net.au, ja@ssi.bg, kadlec@blackhole.kfki.hu, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, pablo@netfilter.org, syzkaller-bugs@googlegroups.com, wensong@linux-vs.org

Hello,

syzbot found the following crash on:

HEAD commit:    cd6c84d8 Linux 5.2-rc2
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=132bd44aa00000
kernel config:  https://syzkaller.appspot.com/x/.config?x=64479170dcaf0e11
dashboard link: https://syzkaller.appspot.com/bug?extid=7e2e50c8adfccd2e5041
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=114b1354a00000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=14b7ad26a00000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+7e2e50c8adfccd2e5041@syzkaller.appspotmail.com

d started: state = MASTER, mcast_ifn = syz_tun, syncid = 0, id = 0
BUG: memory leak
unreferenced object 0xffff8881206bf700 (size 32):
   comm "syz-executor761", pid 7268, jiffies 4294943441 (age 20.470s)
   hex dump (first 32 bytes):
     00 40 7c 09 81 88 ff ff 80 45 b8 21 81 88 ff ff  .@|......E.!....
     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
   backtrace:
     [<0000000057619e23>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:55 [inline]
     [<0000000057619e23>] slab_post_alloc_hook mm/slab.h:439 [inline]
     [<0000000057619e23>] slab_alloc mm/slab.c:3326 [inline]
     [<0000000057619e23>] kmem_cache_alloc_trace+0x13d/0x280 mm/slab.c:3553
     [<0000000086ce5479>] kmalloc include/linux/slab.h:547 [inline]
     [<0000000086ce5479>] start_sync_thread+0x5d2/0xe10  
net/netfilter/ipvs/ip_vs_sync.c:1862
     [<000000001a9229cc>] do_ip_vs_set_ctl+0x4c5/0x780  
net/netfilter/ipvs/ip_vs_ctl.c:2402
     [<00000000ece457c8>] nf_sockopt net/netfilter/nf_sockopt.c:106 [inline]
     [<00000000ece457c8>] nf_setsockopt+0x4c/0x80  
net/netfilter/nf_sockopt.c:115
     [<00000000942f62d4>] ip_setsockopt net/ipv4/ip_sockglue.c:1258 [inline]
     [<00000000942f62d4>] ip_setsockopt+0x9b/0xb0 net/ipv4/ip_sockglue.c:1238
     [<00000000a56a8ffd>] udp_setsockopt+0x4e/0x90 net/ipv4/udp.c:2616
     [<00000000fa895401>] sock_common_setsockopt+0x38/0x50  
net/core/sock.c:3130
     [<0000000095eef4cf>] __sys_setsockopt+0x98/0x120 net/socket.c:2078
     [<000000009747cf88>] __do_sys_setsockopt net/socket.c:2089 [inline]
     [<000000009747cf88>] __se_sys_setsockopt net/socket.c:2086 [inline]
     [<000000009747cf88>] __x64_sys_setsockopt+0x26/0x30 net/socket.c:2086
     [<00000000ded8ba80>] do_syscall_64+0x76/0x1a0  
arch/x86/entry/common.c:301
     [<00000000893b4ac8>] entry_SYSCALL_64_after_hwframe+0x44/0xa9

BUG: memory leak
unreferenced object 0xffff8881206bf700 (size 32):
   comm "syz-executor761", pid 7268, jiffies 4294943441 (age 21.530s)
   hex dump (first 32 bytes):
     00 40 7c 09 81 88 ff ff 80 45 b8 21 81 88 ff ff  .@|......E.!....
     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
   backtrace:
     [<0000000057619e23>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:55 [inline]
     [<0000000057619e23>] slab_post_alloc_hook mm/slab.h:439 [inline]
     [<0000000057619e23>] slab_alloc mm/slab.c:3326 [inline]
     [<0000000057619e23>] kmem_cache_alloc_trace+0x13d/0x280 mm/slab.c:3553
     [<0000000086ce5479>] kmalloc include/linux/slab.h:547 [inline]
     [<0000000086ce5479>] start_sync_thread+0x5d2/0xe10  
net/netfilter/ipvs/ip_vs_sync.c:1862
     [<000000001a9229cc>] do_ip_vs_set_ctl+0x4c5/0x780  
net/netfilter/ipvs/ip_vs_ctl.c:2402
     [<00000000ece457c8>] nf_sockopt net/netfilter/nf_sockopt.c:106 [inline]
     [<00000000ece457c8>] nf_setsockopt+0x4c/0x80  
net/netfilter/nf_sockopt.c:115
     [<00000000942f62d4>] ip_setsockopt net/ipv4/ip_sockglue.c:1258 [inline]
     [<00000000942f62d4>] ip_setsockopt+0x9b/0xb0 net/ipv4/ip_sockglue.c:1238
     [<00000000a56a8ffd>] udp_setsockopt+0x4e/0x90 net/ipv4/udp.c:2616
     [<00000000fa895401>] sock_common_setsockopt+0x38/0x50  
net/core/sock.c:3130
     [<0000000095eef4cf>] __sys_setsockopt+0x98/0x120 net/socket.c:2078
     [<000000009747cf88>] __do_sys_setsockopt net/socket.c:2089 [inline]
     [<000000009747cf88>] __se_sys_setsockopt net/socket.c:2086 [inline]
     [<000000009747cf88>] __x64_sys_setsockopt+0x26/0x30 net/socket.c:2086
     [<00000000ded8ba80>] do_syscall_64+0x76/0x1a0  
arch/x86/entry/common.c:301
     [<00000000893b4ac8>] entry_SYSCALL_64_after_hwframe+0x44/0xa9

BUG: memory leak
unreferenced object 0xffff8881206bf700 (size 32):
   comm "syz-executor761", pid 7268, jiffies 4294943441 (age 22.630s)
   hex dump (first 32 bytes):
     00 40 7c 09 81 88 ff ff 80 45 b8 21 81 88 ff ff  .@|......E.!....
     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
   backtrace:
     [<0000000057619e23>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:55 [inline]
     [<0000000057619e23>] slab_post_alloc_hook mm/slab.h:439 [inline]
     [<0000000057619e23>] slab_alloc mm/slab.c:3326 [inline]
     [<0000000057619e23>] kmem_cache_alloc_trace+0x13d/0x280 mm/slab.c:3553
     [<0000000086ce5479>] kmalloc include/linux/slab.h:547 [inline]
     [<0000000086ce5479>] start_sync_thread+0x5d2/0xe10  
net/netfilter/ipvs/ip_vs_sync.c:1862
     [<000000001a9229cc>] do_ip_vs_set_ctl+0x4c5/0x780  
net/netfilter/ipvs/ip_vs_ctl.c:2402
     [<00000000ece457c8>] nf_sockopt net/netfilter/nf_sockopt.c:106 [inline]
     [<00000000ece457c8>] nf_setsockopt+0x4c/0x80  
net/netfilter/nf_sockopt.c:115
     [<00000000942f62d4>] ip_setsockopt net/ipv4/ip_sockglue.c:1258 [inline]
     [<00000000942f62d4>] ip_setsockopt+0x9b/0xb0 net/ipv4/ip_sockglue.c:1238
     [<00000000a56a8ffd>] udp_setsockopt+0x4e/0x90 net/ipv4/udp.c:2616
     [<00000000fa895401>] sock_common_setsockopt+0x38/0x50  
net/core/sock.c:3130
     [<0000000095eef4cf>] __sys_setsockopt+0x98/0x120 net/socket.c:2078
     [<000000009747cf88>] __do_sys_setsockopt net/socket.c:2089 [inline]
     [<000000009747cf88>] __se_sys_setsockopt net/socket.c:2086 [inline]
     [<000000009747cf88>] __x64_sys_setsockopt+0x26/0x30 net/socket.c:2086
     [<00000000ded8ba80>] do_syscall_64+0x76/0x1a0  
arch/x86/entry/common.c:301
     [<00000000893b4ac8>] entry_SYSCALL_64_after_hwframe+0x44/0xa9

BUG: memory leak
unreferenced object 0xffff8881206bf700 (size 32):
   comm "syz-executor761", pid 7268, jiffies 4294943441 (age 23.720s)
   hex dump (first 32 bytes):
     00 40 7c 09 81 88 ff ff 80 45 b8 21 81 88 ff ff  .@|......E.!....
     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
   backtrace:
     [<0000000057619e23>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:55 [inline]
     [<0000000057619e23>] slab_post_alloc_hook mm/slab.h:439 [inline]
     [<0000000057619e23>] slab_alloc mm/slab.c:3326 [inline]
     [<0000000057619e23>] kmem_cache_alloc_trace+0x13d/0x280 mm/slab.c:3553
     [<0000000086ce5479>] kmalloc include/linux/slab.h:547 [inline]
     [<0000000086ce5479>] start_sync_thread+0x5d2/0xe10  
net/netfilter/ipvs/ip_vs_sync.c:1862
     [<000000001a9229cc>] do_ip_vs_set_ctl+0x4c5/0x780  
net/netfilter/ipvs/ip_vs_ctl.c:2402
     [<00000000ece457c8>] nf_sockopt net/netfilter/nf_sockopt.c:106 [inline]
     [<00000000ece457c8>] nf_setsockopt+0x4c/0x80  
net/netfilter/nf_sockopt.c:115
     [<00000000942f62d4>] ip_setsockopt net/ipv4/ip_sockglue.c:1258 [inline]
     [<00000000942f62d4>] ip_setsockopt+0x9b/0xb0 net/ipv4/ip_sockglue.c:1238
     [<00000000a56a8ffd>] udp_setsockopt+0x4e/0x90 net/ipv4/udp.c:2616
     [<00000000fa895401>] sock_common_setsockopt+0x38/0x50  
net/core/sock.c:3130
     [<0000000095eef4cf>] __sys_setsockopt+0x98/0x120 net/socket.c:2078
     [<000000009747cf88>] __do_sys_setsockopt net/socket.c:2089 [inline]
     [<000000009747cf88>] __se_sys_setsockopt net/socket.c:2086 [inline]
     [<000000009747cf88>] __x64_sys_setsockopt+0x26/0x30 net/socket.c:2086
     [<00000000ded8ba80>] do_syscall_64+0x76/0x1a0  
arch/x86/entry/common.c:301
     [<00000000893b4ac8>] entry_SYSCALL_64_after_hwframe+0x44/0xa9

BUG: memory leak
unreferenced object 0xffff8881206bf700 (size 32):
   comm "syz-executor761", pid 7268, jiffies 4294943441 (age 25.770s)
   hex dump (first 32 bytes):
     00 40 7c 09 81 88 ff ff 80 45 b8 21 81 88 ff ff  .@|......E.!....
     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
   backtrace:
     [<0000000057619e23>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:55 [inline]
     [<0000000057619e23>] slab_post_alloc_hook mm/slab.h:439 [inline]
     [<0000000057619e23>] slab_alloc mm/slab.c:3326 [inline]
     [<0000000057619e23>] kmem_cache_alloc_trace+0x13d/0x280 mm/slab.c:3553
     [<0000000086ce5479>] kmalloc include/linux/slab.h:547 [inline]
     [<0000000086ce5479>] start_sync_thread+0x5d2/0xe10  
net/netfilter/ipvs/ip_vs_sync.c:1862
     [<000000001a9229cc>] do_ip_vs_set_ctl+0x4c5/0x780  
net/netfilter/ipvs/ip_vs_ctl.c:2402
     [<00000000ece457c8>] nf_sockopt net/netfilter/nf_sockopt.c:106 [inline]
     [<00000000ece457c8>] nf_setsockopt+0x4c/0x80  
net/netfilter/nf_sockopt.c:115
     [<00000000942f62d4>] ip_setsockopt net/ipv4/ip_sockglue.c:1258 [inline]
     [<00000000942f62d4>] ip_setsockopt+0x9b/0xb0 net/ipv4/ip_sockglue.c:1238
     [<00000000a56a8ffd>] udp_setsockopt+0x4e/0x90 net/ipv4/udp.c:2616
     [<00000000fa895401>] sock_common_setsockopt+0x38/0x50  
net/core/sock.c:3130
     [<0000000095eef4cf>] __sys_setsockopt+0x98/0x120 net/socket.c:2078
     [<000000009747cf88>] __do_sys_setsockopt net/socket.c:2089 [inline]
     [<000000009747cf88>] __se_sys_setsockopt net/socket.c:2086 [inline]
     [<000000009747cf88>] __x64_sys_setsockopt+0x26/0x30 net/socket.c:2086
     [<00000000ded8ba80>] do_syscall_64+0x76/0x1a0  
arch/x86/entry/common.c:301
     [<00000000893b4ac8>] entry_SYSCALL_64_after_hwframe+0x44/0xa9

BUG: memory leak
unreferenced object 0xffff8881206bf700 (size 32):
   comm "syz-executor761", pid 7268, jiffies 4294943441 (age 26.850s)
   hex dump (first 32 bytes):
     00 40 7c 09 81 88 ff ff 80 45 b8 21 81 88 ff ff  .@|......E.!....
     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
   backtrace:
     [<0000000057619e23>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:55 [inline]
     [<0000000057619e23>] slab_post_alloc_hook mm/slab.h:439 [inline]
     [<0000000057619e23>] slab_alloc mm/slab.c:3326 [inline]
     [<0000000057619e23>] kmem_cache_alloc_trace+0x13d/0x280 mm/slab.c:3553
     [<0000000086ce5479>] kmalloc include/linux/slab.h:547 [inline]
     [<0000000086ce5479>] start_sync_thread+0x5d2/0xe10  
net/netfilter/ipvs/ip_vs_sync.c:1862
     [<000000001a9229cc>] do_ip_vs_set_ctl+0x4c5/0x780  
net/netfilter/ipvs/ip_vs_ctl.c:2402
     [<00000000ece457c8>] nf_sockopt net/netfilter/nf_sockopt.c:106 [inline]
     [<00000000ece457c8>] nf_setsockopt+0x4c/0x80  
net/netfilter/nf_sockopt.c:115
     [<00000000942f62d4>] ip_setsockopt net/ipv4/ip_sockglue.c:1258 [inline]
     [<00000000942f62d4>] ip_setsockopt+0x9b/0xb0 net/ipv4/ip_sockglue.c:1238
     [<00000000a56a8ffd>] udp_setsockopt+0x4e/0x90 net/ipv4/udp.c:2616
     [<00000000fa895401>] sock_common_setsockopt+0x38/0x50  
net/core/sock.c:3130
     [<0000000095eef4cf>] __sys_setsockopt+0x98/0x120 net/socket.c:2078
     [<000000009747cf88>] __do_sys_setsockopt net/socket.c:2089 [inline]
     [<000000009747cf88>] __se_sys_setsockopt net/socket.c:2086 [inline]
     [<000000009747cf88>] __x64_sys_setsockopt+0x26/0x30 net/socket.c:2086
     [<00000000ded8ba80>] do_syscall_64+0x76/0x1a0  
arch/x86/entry/common.c:301
     [<00000000893b4ac8>] entry_SYSCALL_64_after_hwframe+0x44/0xa9

BUG: memory leak
unreferenced object 0xffff8881206bf700 (size 32):
   comm "syz-executor761", pid 7268, jiffies 4294943441 (age 27.940s)
   hex dump (first 32 bytes):
     00 40 7c 09 81 88 ff ff 80 45 b8 21 81 88 ff ff  .@|......E.!....
     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
   backtrace:
     [<0000000057619e23>] kmemleak_alloc_recursive  
include/linux/kmemleak.h:55 [inline]
     [<0000000057619e23>] slab_post_alloc_hook mm/slab.h:439 [inline]
     [<0000000057619e23>] slab_alloc mm/slab.c:3326 [inline]
     [<0000000057619e23>] kmem_cache_alloc_trace+0x13d/0x280 mm/slab.c:3553
     [<0000000086ce5479>] kmalloc include/linux/slab.h:547 [inline]
     [<0000000086ce5479>] start_sync_thread+0x5d2/0xe10  
net/netfilter/ipvs/ip_vs_sync.c:1862
     [<000000001a9229cc>] do_ip_vs_set_ctl+0x4c5/0x780  
net/netfilter/ipvs/ip_vs_ctl.c:2402
     [<00000000ece457c8>] nf_sockopt net/netfilter/nf_sockopt.c:106 [inline]
     [<00000000ece457c8>] nf_setsockopt+0x4c/0x80  
net/netfilter/nf_sockopt.c:115
     [<00000000942f62d4>] ip_setsockopt net/ipv4/ip_sockglue.c:1258 [inline]
     [<00000000942f62d4>] ip_setsockopt+0x9b/0xb0 net/ipv4/ip_sockglue.c:1238
     [<00000000a56a8ffd>] udp_setsockopt+0x4e/0x90 net/ipv4/udp.c:2616
     [<00000000fa895401>] sock_common_setsockopt+0x38/0x50  
net/core/sock.c:3130
     [<0000000095eef4cf>] __sys_setsockopt+0x98/0x120 net/socket.c:2078
     [<000000009747cf88>] __do_sys_setsockopt net/socket.c:2089 [inline]
     [<000000009747cf88>] __se_sys_setsockopt net/socket.c:2086 [inline]
     [<000000009747cf88>] __x64_sys_setsockopt+0x26/0x30 net/socket.c:2086
     [<00000000ded8ba80>] do_syscall_64+0x76/0x1a0  
arch/x86/entry/common.c:301
     [<00000000893b4ac8>] entry_SYSCALL_64_after_hwframe+0x44/0xa9

executing program


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#status for how to communicate with syzbot.
syzbot can test patches for this bug, for details see:
https://goo.gl/tpsmEJ#testing-patches
