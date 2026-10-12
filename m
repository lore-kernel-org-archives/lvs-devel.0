Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BA5D94AA3E6
	for <lvs-devel@vger.kernel.org>; Mon, 12 Oct 2026 15:44:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.199
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791819880; cv=none; b=K9lbM3zxg3zMDfJxhy75JpNUXU6OW6wWR51w/ol/qgBkGj2cxxZO4fnv9qXTDiLFoy4IGbic+zl21JwJfKhRyzsPbndAKuHiw9DZkj7JxS8+DGFNssxuHJyGUaI4wYCU85huPD2HKr5jXdiY3HktSROy84GPayRMr8HHuLoc0Sk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791819880; c=relaxed/simple;
	bh=bR1O7d6qQN9Efb4Kbpe+rTLzsK7TGqxLRmmK6Ui3Ass=;
	h=MIME-Version:Date:Message-ID:Subject:From:To:Content-Type; b=Yyyupp7REvqf/GsHcY3HPhlCLYDuMtTDBb6I6e8jYR6W+i61Ie0CyAd6f2s9DRw15XChOa8mRwdkm2XFO+4NuaoihEJXPIvkPYUgUlsvQTkSUKVSBTBbx1lpNH9/O8grb5oScZ8DIFreOnLsvegmnt5QjbSh0MMTfkHXOAZvuFI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com; arc=none smtp.client-ip=209.85.167.199
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-oi1-f199.google.com with SMTP id 5614622812f47-4dab94dc3e7so3611856b6e.0
        for <lvs-devel@vger.kernel.org>; Mon, 12 Oct 2026 08:44:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791819878; x=1792424678;
        h=content-type:to:from:subject:message-id:date:mime-version
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=GPDFFFGSrqI9ZKgzKXufTUNby0rH4X7Rocq6YYaTbNU=;
        b=dqrt2NvH0Ki9Cqpik+Ug1xO5+X5fW3v8jnXmly0lqs1QapD+FSLkUybKggOfv+3dg0
         2F1y1Q8/YwPPhAk8lU9kXfTMpqV4vS1UavuUgMeiSpYRxBou9dwjXriRgudFMzd6yRor
         rs74lu+2MZcj9CMRssbphLj9ccxayuocrfOL2mrZ3Y0AbiH2akUQHqdvxQ5gT5Jaz8ND
         3eJ7a/mzwpRZ/qXqMzLHjVnnnZH8gRlKCutrM1B96N8nIiRVwImj8cf3jOXmBN+8fpLY
         ccdLLmoqlWAfjqMjYMZd/YCqgI0rz/FLT4gFqz7zSgU7cAr3QxVgqyEI9RAgh8xHobJb
         9Y9A==
X-Forwarded-Encrypted: i=1; AKwUvBydWjzLmbhqYg8mjhMs9WXChL/dUpxUS0F/1OLdOm+IdfsgTwe+e8OAQk/qigYHTLBgblF0ENJ/y6Y=@vger.kernel.org
X-Gm-Message-State: AFq9FYIdKZ9riV3rF56cPcl9Msw5jNY4L5e1O/fPhC428dfbJvhmnmjx
	QsqYeEW85wjA/7/JPt34hiBP1lf1o61zSvtdpnmaoJSvV+i8x1CkEyOBZrRxW8G8Rarx+kokW9/
	9I2osUA+nU8l8JWt6jT39v39QdaEP/k8hEaBA21YtZhEW8M4Y9ctezvfpJNU=
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a05:6808:680a:b0:4fb:6402:a8ca with SMTP id
 5614622812f47-50c4e685340mr10902686b6e.21.1791819877745; Mon, 12 Oct 2026
 08:44:37 -0700 (PDT)
Date: Mon, 12 Oct 2026 08:44:37 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <6acd0065.a150a118.27e199.004d.GAE@google.com>
Subject: [syzbot] [lvs?] INFO: rcu detected stall in ip_vs_estimation_kthread (2)
From: syzbot <syzbot+022ec9322756662013b5@syzkaller.appspotmail.com>
To: coreteam@netfilter.org, davem@davemloft.net, edumazet@kernel.org, 
	fw@strlen.de, horms@verge.net.au, ja@ssi.bg, kuba@kernel.org, 
	linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, 
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, pabeni@redhat.com, 
	pablo@netfilter.org, phil@nwl.cc, syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"

Hello,

syzbot found the following issue on:

HEAD commit:    7b63ef2d55f2 Merge tag 'for-7.3-rc6-tag' of git://git.kern..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=16feaa8e580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=23e5acac5c98285f
dashboard link: https://syzkaller.appspot.com/bug?extid=022ec9322756662013b5
compiler:       Debian clang version 22.1.8 (++20260613092233+e80beda6e255-1~exp1~20260613092250.77), Debian LLD 22.1.8

Unfortunately, I don't have any reproducer for this issue yet.

Downloadable assets:
disk image: https://storage.googleapis.com/syzbot-assets/6a3c98d82e9c/disk-7b63ef2d.raw.xz
vmlinux: https://storage.googleapis.com/syzbot-assets/3d921ef6c68c/vmlinux-7b63ef2d.xz
kernel image: https://storage.googleapis.com/syzbot-assets/9d4e9981e5b9/bzImage-7b63ef2d.xz

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+022ec9322756662013b5@syzkaller.appspotmail.com

rcu: INFO: rcu_preempt detected stalls on CPUs/tasks:
rcu: 	Tasks blocked on level-0 rcu_node (CPUs 0-1): P5285/3:b..l
rcu: 	(detected by 0, t=10503 jiffies, g=348101, q=1610 ncpus=2)
task:syz-executor    state:R  running task     stack:28200 pid:5285  tgid:5285  ppid:32677  task_flags:0x400040 flags:0x00080002
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5533 [inline]
 __schedule+0x17db/0x58f0 kernel/sched/core.c:7284
 preempt_schedule_common+0x7f/0xd0 kernel/sched/core.c:7463
 preempt_schedule_thunk+0x16/0x40 arch/x86/entry/thunk.S:12
 __raw_spin_unlock include/linux/spinlock_api_smp.h:201 [inline]
 _raw_spin_unlock+0x41/0x50 kernel/locking/spinlock.c:213
 spin_unlock include/linux/spinlock.h:401 [inline]
 filemap_map_pages+0x1aba/0x2170 mm/filemap.c:3997
 do_fault_around mm/memory.c:5958 [inline]
 do_read_fault mm/memory.c:5991 [inline]
 do_fault mm/memory.c:6134 [inline]
 do_pte_missing+0x20ae/0x34b0 mm/memory.c:4700
 handle_pte_fault mm/memory.c:6558 [inline]
 __handle_mm_fault mm/memory.c:6707 [inline]
 handle_mm_fault+0x1a53/0x3750 mm/memory.c:6876
 do_user_addr_fault+0xa4f/0x1340 arch/x86/mm/fault.c:1343
 handle_page_fault arch/x86/mm/fault.c:1483 [inline]
 exc_page_fault+0x6a/0xc0 arch/x86/mm/fault.c:1536
 asm_exc_page_fault+0x26/0x30 arch/x86/include/asm/idtentry.h:595
RIP: 0033:0x7f5254b3f7c0
RSP: 002b:00007f5254f4fc58 EFLAGS: 00010202
RAX: 0000000000000000 RBX: 00007f5254f4fc60 RCX: 00007f5254bc6c4c
RDX: 0000000000000000 RSI: 0000000000000018 RDI: 00007f5254f4fc60
RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000001
R10: 000055557d62f7d0 R11: 0000000000000246 R12: 0000000000000001
R13: 00000000000927c0 R14: 00000000001e199a R15: 00007f5254f4fe40
 </TASK>
rcu: rcu_preempt kthread starved for 737 jiffies! g348101 f0x0 RCU_GP_WAIT_FQS(5) ->state=R ->cpu=1
rcu: 	Unless rcu_preempt kthread gets sufficient CPU time, OOM is now expected behavior.
rcu: RCU grace-period kthread stack dump:
task:rcu_preempt     state:R  running task     stack:27496 pid:17    tgid:17    ppid:2      task_flags:0x208040 flags:0x00080000
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5533 [inline]
 __schedule+0x17db/0x58f0 kernel/sched/core.c:7284
 __schedule_loop kernel/sched/core.c:7361 [inline]
 schedule+0x164/0x2b0 kernel/sched/core.c:7376
 schedule_timeout+0x152/0x2c0 kernel/time/sleep_timeout.c:99
 rcu_gp_fqs_loop+0x30c/0x11f0 kernel/rcu/tree.c:2122
 rcu_gp_kthread+0x9e/0x2b0 kernel/rcu/tree.c:2330
 kthread+0x38b/0x480 kernel/kthread.c:436
 ret_from_fork+0x514/0xb70 arch/x86/kernel/process.c:158
 ret_from_fork_asm+0x1a/0x30 arch/x86/entry/entry_64.S:245
 </TASK>
rcu: Stack dump where RCU GP kthread last ran:
Sending NMI from CPU 0 to CPUs 1:
NMI backtrace for cpu 1
CPU: 1 UID: 0 PID: 2226 Comm: ipvs-e:321:0 Tainted: G             L      syzkaller #0 PREEMPT(full) 
Tainted: [L]=SOFTLOCKUP
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 09/16/2026
RIP: 0010:netif_skb_features+0xc5/0xf20 net/core/dev.c:3914
Code: 4c 89 74 24 10 49 8b 45 00 48 89 44 24 18 48 8d 98 b8 00 00 00 48 89 d8 48 c1 e8 03 48 b9 00 00 00 00 00 fc ff df 80 3c 08 00 <74> 08 48 89 df e8 b1 57 85 f8 4c 8b 33 48 8b 44 24 10 48 8d b8 d0
RSP: 0018:ffffc90000a17da0 EFLAGS: 00000246
RAX: 1ffff1100547bc17 RBX: ffff88802a3de0b8 RCX: dffffc0000000000
RDX: 8000000000000300 RSI: 0000000000000100 RDI: ffff8881d9ce2dc0
RBP: ffffc90000a17ea0 R08: 0000000000000100 R09: 1ffffffff20f4ccf
R10: dffffc0000000000 R11: fffffbfff20f4cd0 R12: dffffc0000000000
R13: ffff8881d9ce2dd0 R14: ffff8881d9ce2dc0 R15: ffff88802a3de000
FS:  0000000000000000(0000) GS:ffff888124dc6000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f5254b3f7c0 CR3: 000000007eb18000 CR4: 00000000003526f0
Call Trace:
 <IRQ>
 validate_xmit_skb+0xa0/0x1820 net/core/dev.c:4095
 __dev_queue_xmit+0xb01/0x3920 net/core/dev.c:4945
 dev_queue_xmit include/linux/netdevice.h:3464 [inline]
 neigh_hh_output include/net/neighbour.h:544 [inline]
 neigh_output include/net/neighbour.h:558 [inline]
 ip_finish_output2+0xbda/0x10b0 net/ipv4/ip_output.c:236
 NF_HOOK_COND include/linux/netfilter.h:314 [inline]
 ip_output+0x29f/0x450 net/ipv4/ip_output.c:437
 synproxy_send_client_synack+0x89b/0xde0 net/netfilter/nf_synproxy_core.c:487
 nft_synproxy_eval_v4+0x362/0x4e0 net/netfilter/nft_synproxy.c:59
 nft_synproxy_do_eval+0x389/0x5d0 net/netfilter/nft_synproxy.c:142
 expr_call_ops_eval net/netfilter/nf_tables_core.c:237 [inline]
 nft_do_chain+0x48d/0x1b10 net/netfilter/nf_tables_core.c:285
 nft_do_chain_ipv4+0x195/0x290 net/netfilter/nft_chain_filter.c:24
 nf_hook_entry_hookfn include/linux/netfilter.h:165 [inline]
 nf_hook_slow+0xc5/0x220 net/netfilter/core.c:619
 nf_hook include/linux/netfilter.h:280 [inline]
 NF_HOOK+0x21f/0x3c0 include/linux/netfilter.h:323
 NF_HOOK+0x336/0x3c0 include/linux/netfilter.h:325
 __netif_receive_skb_one_core net/core/dev.c:6297 [inline]
 __netif_receive_skb net/core/dev.c:6410 [inline]
 process_backlog+0xa6b/0x18b0 net/core/dev.c:6761
 __napi_poll+0xaa/0x330 net/core/dev.c:7830
 napi_poll net/core/dev.c:7893 [inline]
 net_rx_action+0x61d/0xf50 net/core/dev.c:8050
 handle_softirqs+0x226/0x860 kernel/softirq.c:645
 __do_softirq kernel/softirq.c:679 [inline]
 invoke_softirq kernel/softirq.c:519 [inline]
 __irq_exit_rcu+0xcb/0x220 kernel/softirq.c:758
 irq_exit_rcu+0x9/0x30 kernel/softirq.c:775
 instr_sysvec_apic_timer_interrupt arch/x86/kernel/apic/apic.c:1062 [inline]
 sysvec_apic_timer_interrupt+0xa6/0xc0 arch/x86/kernel/apic/apic.c:1062
 </IRQ>
 <TASK>
 asm_sysvec_apic_timer_interrupt+0x1a/0x20 arch/x86/include/asm/idtentry.h:674
RIP: 0010:finish_task_switch+0x413/0xc60 kernel/sched/core.c:5384
Code: 04 00 00 41 c7 84 24 20 0e 00 00 00 00 00 00 e9 db 06 00 00 49 83 c4 48 4c 89 e7 e8 47 e0 53 0a e8 22 2f 3a 00 fb 4c 8b 65 c8 <49> 8d bc 24 18 17 00 00 48 89 f8 48 c1 e8 03 42 0f b6 04 30 84 c0
RSP: 0018:ffffc90003c477e0 EFLAGS: 00000206
RAX: 000000000001ad27 RBX: ffff8880b873c8e0 RCX: 8000000000000001
RDX: 0000000000000000 RSI: ffffffff8e41727c RDI: ffffffff8c6dad80
RBP: ffffc90003c47830 R08: ffffffff907a667f R09: 1ffffffff20f4ccf
R10: dffffc0000000000 R11: fffffbfff20f4cd0 R12: ffff888033593e80
R13: ffff8880b873c8a8 R14: dffffc0000000000 R15: 1ffff110170e791c
 context_switch kernel/sched/core.c:5536 [inline]
 __schedule+0x17e3/0x58f0 kernel/sched/core.c:7284
 __schedule_loop kernel/sched/core.c:7361 [inline]
 schedule+0x164/0x2b0 kernel/sched/core.c:7376
 schedule_timeout+0x152/0x2c0 kernel/time/sleep_timeout.c:99
 ip_vs_estimation_kthread+0x29ef/0x3950 net/netfilter/ipvs/ip_vs_est.c:216
 kthread+0x38b/0x480 kernel/kthread.c:436
 ret_from_fork+0x514/0xb70 arch/x86/kernel/process.c:158
 ret_from_fork_asm+0x1a/0x30 arch/x86/entry/entry_64.S:245
 </TASK>


---
This report is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this issue. See:
https://goo.gl/tpsmEJ#status for how to communicate with syzbot.

If the report is already addressed, let syzbot know by replying with:
#syz fix: exact-commit-title

If you want to overwrite report's subsystems, reply with:
#syz set subsystems: new-subsystem
(See the list of subsystem names on the web dashboard)

If the report is a duplicate of another one, reply with:
#syz dup: exact-subject-of-another-report

If you want to undo deduplication, reply with:
#syz undup
