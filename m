Received: from mail-oo1-f79.google.com (mail-oo1-f79.google.com [209.85.161.79])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8947C3D5225
	for <lvs-devel@vger.kernel.org>; Tue, 14 Apr 2026 10:30:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.79
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776162636; cv=none; b=PiU95hBXbYRYnEVduCDIa6012nE579+WEtdXAQOzL5tEsxOCVkqsfhbngG0CEUi6GGWm+G+1X58/GyPinMNvjZK9Ejd7aHViNemz198+vuO5PwVkZPsEjuxHS8uqq9bBvYHHbkunWe2otr6BW3GaNBEPgZIzub1wcByvUoXXwhc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776162636; c=relaxed/simple;
	bh=FCSBefH/oTmdgHdyyArq8Sd+rdXE9JmhilR3WYZJjdE=;
	h=MIME-Version:Date:Message-ID:Subject:From:To:Content-Type; b=HWuLSPO4sBwqFK1FZD1izTCw5VJ16hgGqvQAVtplhP5dyLynM3G2w632A9FFNQxy412m0+T0y66phqQA0BkJYGd9sicbBaGirOZbc7pynNt42f7icrV0O1dWIKFeStctXsXLcW8MEYjJARUDIkPvKK+X0n6ZS3lU/VED+SFsAqk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com; arc=none smtp.client-ip=209.85.161.79
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-oo1-f79.google.com with SMTP id 006d021491bc7-6853c2438b9so10258508eaf.3
        for <lvs-devel@vger.kernel.org>; Tue, 14 Apr 2026 03:30:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1776162627; x=1776767427;
        h=to:from:subject:message-id:date:mime-version:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=H9YZZSGezJHiuJUYElsZmyJ9oq+8X/IHgJLyoXz58+k=;
        b=PvnkS2nFoFfVl/PuUh0bMbQEJTTSmiPaqUhdohR9s0Gu0KDoMZyqMJCDpT9LniYqCo
         7feXxRtLRA9faRKeHDfNtdvVtnkwhzjRzp+ZHMau1gG5KM3R1enXAB2SAvXDYswEkmRs
         GxTzlLMhZteDcRMbYw0NSnNrwjiMuAZW6lPUHG0bkhfGY/jxIstdISo+KXc895QNMxGS
         +i09HYuOLf02q3iJ2ya+G2lxuQiXXOQjCQcOCCtdeGJ9Knqa1b98oociPKz+uEe0Fz66
         bgh6v63DgIg/E/Gl5wacNIWL02yUQn3SwtX8mGdwq6Hm19nsqJL8IVEhGyG6P+LQJQIP
         jhpw==
X-Forwarded-Encrypted: i=1; AFNElJ/HaKj/q0dPRaMl1iZ1ZyE/JiEpEtnMOOUeIP5lOzq7T9HLDye8GCe440eD+sISMZ4tU6SxsYPHa2o=@vger.kernel.org
X-Gm-Message-State: AOJu0Yyd9D9BPVkTOKrQyvjbXbSRxdy/1u6dDzehCPXW3oSELpKxH4Np
	ieYmaVTvtVf4fhAZeRDaNiOCTzbf8uXzI29Gja41zJY/YgENHXXqqBFJoVEIulMG1F6N7Qva2gu
	W9JCAZ9pKkqncAVKcSLrWd7i43b4lr3HyT2jvFJarhODRR0U5UowKK6VS5ss=
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a05:6820:16a5:b0:682:7662:ccfa with SMTP id
 006d021491bc7-691bfecef49mr821814eaf.49.1776162627631; Tue, 14 Apr 2026
 03:30:27 -0700 (PDT)
Date: Tue, 14 Apr 2026 03:30:27 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <69de1743.a00a0220.475f0.0040.GAE@google.com>
Subject: [syzbot] [lvs?] BUG: sleeping function called from invalid context in ip_vs_conn_expire
From: syzbot <syzbot+504e778ddaecd36fdd17@syzkaller.appspotmail.com>
To: coreteam@netfilter.org, davem@davemloft.net, edumazet@google.com, 
	fw@strlen.de, horms@verge.net.au, ja@ssi.bg, kuba@kernel.org, 
	linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, 
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, pabeni@redhat.com, 
	pablo@netfilter.org, phil@nwl.cc, syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"

Hello,

syzbot found the following issue on:

HEAD commit:    1c7cc4904160 Add linux-next specific files for 20260413
git tree:       linux-next
console output: https://syzkaller.appspot.com/x/log.txt?x=10327cd2580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=56c2b36de3316f1b
dashboard link: https://syzkaller.appspot.com/bug?extid=504e778ddaecd36fdd17
compiler:       Debian clang version 21.1.8 (++20251221033036+2078da43e25a-1~exp1~20251221153213.50), Debian LLD 21.1.8

Unfortunately, I don't have any reproducer for this issue yet.

Downloadable assets:
disk image: https://storage.googleapis.com/syzbot-assets/91a765b703da/disk-1c7cc490.raw.xz
vmlinux: https://storage.googleapis.com/syzbot-assets/da75a3061146/vmlinux-1c7cc490.xz
kernel image: https://storage.googleapis.com/syzbot-assets/d55367ced048/bzImage-1c7cc490.xz

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+504e778ddaecd36fdd17@syzkaller.appspotmail.com

BUG: sleeping function called from invalid context at kernel/locking/spinlock_rt.c:48
in_atomic(): 1, irqs_disabled(): 0, non_block: 0, pid: 16, name: ktimers/0
preempt_count: 2, expected: 0
RCU nest depth: 3, expected: 3
8 locks held by ktimers/0/16:
 #0: ffffffff8de5f260 (local_bh){.+.+}-{1:3}, at: __local_bh_disable_ip+0x3c/0x420 kernel/softirq.c:163
 #1: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: __local_bh_disable_ip+0x3c/0x420 kernel/softirq.c:163
 #2: ffff8880b8826360 (&base->expiry_lock){+...}-{3:3}, at: spin_lock include/linux/spinlock_rt.h:45 [inline]
 #2: ffff8880b8826360 (&base->expiry_lock){+...}-{3:3}, at: timer_base_lock_expiry kernel/time/timer.c:1502 [inline]
 #2: ffff8880b8826360 (&base->expiry_lock){+...}-{3:3}, at: __run_timer_base+0x120/0x9f0 kernel/time/timer.c:2384
 #3: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acquire include/linux/rcupdate.h:300 [inline]
 #3: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock include/linux/rcupdate.h:838 [inline]
 #3: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: __rt_spin_lock kernel/locking/spinlock_rt.c:50 [inline]
 #3: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: rt_spin_lock+0x1e0/0x400 kernel/locking/spinlock_rt.c:57
 #4: ffffc90000157a80 ((&cp->timer)){+...}-{0:0}, at: call_timer_fn+0xd4/0x5e0 kernel/time/timer.c:1745
 #5: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acquire include/linux/rcupdate.h:300 [inline]
 #5: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock include/linux/rcupdate.h:838 [inline]
 #5: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: ip_vs_conn_unlink net/netfilter/ipvs/ip_vs_conn.c:315 [inline]
 #5: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: ip_vs_conn_expire+0x257/0x2390 net/netfilter/ipvs/ip_vs_conn.c:1260
 #6: ffffffff8de5f260 (local_bh){.+.+}-{1:3}, at: __local_bh_disable_ip+0x3c/0x420 kernel/softirq.c:163
 #7: ffff888068d4c3f0 (&cp->lock#2){+...}-{3:3}, at: spin_lock include/linux/spinlock_rt.h:45 [inline]
 #7: ffff888068d4c3f0 (&cp->lock#2){+...}-{3:3}, at: ip_vs_conn_unlink net/netfilter/ipvs/ip_vs_conn.c:324 [inline]
 #7: ffff888068d4c3f0 (&cp->lock#2){+...}-{3:3}, at: ip_vs_conn_expire+0xd4a/0x2390 net/netfilter/ipvs/ip_vs_conn.c:1260
Preemption disabled at:
[<ffffffff898a6358>] bit_spin_lock include/linux/bit_spinlock.h:38 [inline]
[<ffffffff898a6358>] hlist_bl_lock+0x18/0x110 include/linux/list_bl.h:149
CPU: 0 UID: 0 PID: 16 Comm: ktimers/0 Tainted: G        W    L      syzkaller #0 PREEMPT_{RT,(full)} 
Tainted: [W]=WARN, [L]=SOFTLOCKUP
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 03/18/2026
Call Trace:
 <TASK>
 dump_stack_lvl+0xe8/0x150 lib/dump_stack.c:120
 __might_resched+0x329/0x480 kernel/sched/core.c:9162
 __rt_spin_lock kernel/locking/spinlock_rt.c:48 [inline]
 rt_spin_lock+0xc2/0x400 kernel/locking/spinlock_rt.c:57
 spin_lock include/linux/spinlock_rt.h:45 [inline]
 ip_vs_conn_unlink net/netfilter/ipvs/ip_vs_conn.c:324 [inline]
 ip_vs_conn_expire+0xd4a/0x2390 net/netfilter/ipvs/ip_vs_conn.c:1260
 call_timer_fn+0x192/0x5e0 kernel/time/timer.c:1748
 expire_timers kernel/time/timer.c:1799 [inline]
 __run_timers kernel/time/timer.c:2374 [inline]
 __run_timer_base+0x6a3/0x9f0 kernel/time/timer.c:2386
 run_timer_base kernel/time/timer.c:2395 [inline]
 run_timer_softirq+0xb7/0x170 kernel/time/timer.c:2405
 handle_softirqs+0x1de/0x6d0 kernel/softirq.c:622
 __do_softirq kernel/softirq.c:656 [inline]
 run_ktimerd+0x69/0x100 kernel/softirq.c:1151
 smpboot_thread_fn+0x541/0xa50 kernel/smpboot.c:160
 kthread+0x388/0x470 kernel/kthread.c:436
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
