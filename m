Received: from mail-il1-f206.google.com (mail-il1-f206.google.com [209.85.166.206])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4A20E19B59E
	for <lvs-devel@vger.kernel.org>; Mon, 24 Jun 2024 15:27:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.166.206
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1719242840; cv=none; b=Q5QUXMThP5FY1wvEXqLRJNptbqZMaiGZ/kOatsNQtD+LaBO7RCuVcmS4l+J+zDllygpOcq0PVRsngGnDXk5BkR88S4QG1vKiDBuU8K4agAzYeDKk/XP4dtV18NNDEWkDze+q404tP1tSZejDIKdJKVDYdu30RoL2A7wgvqdxoSk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1719242840; c=relaxed/simple;
	bh=tzhoTUjn/DIergVJmRXfSBnxf5kvQx64qSKgWfdacmM=;
	h=MIME-Version:Date:Message-ID:Subject:From:To:Content-Type; b=kruqBvNk0jbweznqFPOEuyBIbDLx6YfDNJ0RQT+AnIUdpxRGrxDSoCLdk9/hKeRvZkltFCE8rOXGwlHtoBJGWqgBSzpygCM3VVdf/EycBhkOxfUZP6P+DnW4QbwX3zMu501hjKv6lPW47b1FzLSPVgsPRsf9bF4ySjlF61v7+QY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com; arc=none smtp.client-ip=209.85.166.206
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-il1-f206.google.com with SMTP id e9e14a558f8ab-37492fe22cdso34907085ab.0
        for <lvs-devel@vger.kernel.org>; Mon, 24 Jun 2024 08:27:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1719242838; x=1719847638;
        h=to:from:subject:message-id:date:mime-version:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=uv9QZyvFNQpJEReELh0/Si6IkTCCXel7hEP3gP0lOkQ=;
        b=bGC2wM+cDQV6KrW+VOfsnI2W2IeH93Islsas19SC4x3iSgedXILJ/6twQh2CzKEGgX
         LCWI5esJPe0BxT8sqE+wMdtv5F4Y0hnWY+e4yxqg6Kas2mOZCz8HD6N0tBBT0FVGa5bD
         cII6v0BrirM3CyOvWIDKpIE3VIguDrriudOgx9aWwb/E+NQnDJRsuP8sGaQEp1aSEvO7
         hfnAohQMYM+UBRw14cZkGTTselN2tccEr4kauGcvveV/fvgHDWKGB7/Zf04s+99oYsqo
         ALVRLFgK2en0PsLnS4oHtsGl4NQtzhqgsUY0Kb8Ws6bXoBYw0/NWoyjw0HCU7C9Hp8Xz
         WQ+w==
X-Forwarded-Encrypted: i=1; AJvYcCUSubUBMpUxdrDvRSlA2wQoISAKChrW1FroR3AFvBbOvUJeAYUpa2TwG8ukDQRF5+q0RQPEg/TjqFbpLkr//mTiN171vqtEbw+H
X-Gm-Message-State: AOJu0YxuGvX5nB3gJEljuVI/KCHzWFtN/NVAX8YX3mmIq5Cxs9759xrU
	RYoNGryhS+HixbmcTl6I10z4bEMnEsguLjlA6Q+7HGUTl2CjzpF2kXzJMkrxgek6J/2dmcbBm8Z
	MN6e6Wc66tcDa6co/KCWdEICds2xScspCVFja1JSZoU7glEEhrqJh2mo=
X-Google-Smtp-Source: AGHT+IHEFj6JqrLDueAmnhIgvoBTRDCAK+g+ykmP/vctpJEyM0cQhmmCV5CRQCnajRFiwgRwjrYIAxdj3wGOMJKH4MaybYmYQQx1
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a92:c54a:0:b0:375:cfd0:393d with SMTP id
 e9e14a558f8ab-3763a2510c6mr5302435ab.2.1719242838497; Mon, 24 Jun 2024
 08:27:18 -0700 (PDT)
Date: Mon, 24 Jun 2024 08:27:18 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <000000000000abf2f0061ba46a1a@google.com>
Subject: [syzbot] [lvs?] possible deadlock in start_sync_thread
From: syzbot <syzbot+e929093395ec65f969c7@syzkaller.appspotmail.com>
To: coreteam@netfilter.org, davem@davemloft.net, edumazet@google.com, 
	horms@verge.net.au, ja@ssi.bg, kadlec@netfilter.org, kuba@kernel.org, 
	linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, 
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, pabeni@redhat.com, 
	pablo@netfilter.org, syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"

Hello,

syzbot found the following issue on:

HEAD commit:    3226607302ca selftests: net: change shebang to bash in amt..
git tree:       net-next
console output: https://syzkaller.appspot.com/x/log.txt?x=12a2683e980000
kernel config:  https://syzkaller.appspot.com/x/.config?x=e78fc116033e0ab7
dashboard link: https://syzkaller.appspot.com/bug?extid=e929093395ec65f969c7
compiler:       Debian clang version 15.0.6, GNU ld (GNU Binutils for Debian) 2.40

Unfortunately, I don't have any reproducer for this issue yet.

Downloadable assets:
disk image: https://storage.googleapis.com/syzbot-assets/125c85863435/disk-32266073.raw.xz
vmlinux: https://storage.googleapis.com/syzbot-assets/4477ecab2e1f/vmlinux-32266073.xz
kernel image: https://storage.googleapis.com/syzbot-assets/43e28f6ce879/bzImage-32266073.xz

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+e929093395ec65f969c7@syzkaller.appspotmail.com

======================================================
WARNING: possible circular locking dependency detected
6.10.0-rc4-syzkaller-00837-g3226607302ca #0 Not tainted
------------------------------------------------------
syz-executor.4/10811 is trying to acquire lock:
ffffffff8f5e6f48 (rtnl_mutex){+.+.}-{3:3}, at: start_sync_thread+0xdc/0x2dc0 net/netfilter/ipvs/ip_vs_sync.c:1761

but task is already holding lock:
ffff88805ba95750 (&smc->clcsock_release_lock){+.+.}-{3:3}, at: smc_setsockopt+0x1c3/0xe50 net/smc/af_smc.c:3064

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #2 (&smc->clcsock_release_lock){+.+.}-{3:3}:
       lock_acquire+0x1ed/0x550 kernel/locking/lockdep.c:5754
       __mutex_lock_common kernel/locking/mutex.c:608 [inline]
       __mutex_lock+0x136/0xd70 kernel/locking/mutex.c:752
       smc_switch_to_fallback+0x35/0xd00 net/smc/af_smc.c:902
       smc_sendmsg+0x11f/0x530 net/smc/af_smc.c:2779
       sock_sendmsg_nosec net/socket.c:730 [inline]
       __sock_sendmsg+0x221/0x270 net/socket.c:745
       __sys_sendto+0x3a4/0x4f0 net/socket.c:2192
       __do_sys_sendto net/socket.c:2204 [inline]
       __se_sys_sendto net/socket.c:2200 [inline]
       __x64_sys_sendto+0xde/0x100 net/socket.c:2200
       do_syscall_x64 arch/x86/entry/common.c:52 [inline]
       do_syscall_64+0xf3/0x230 arch/x86/entry/common.c:83
       entry_SYSCALL_64_after_hwframe+0x77/0x7f

-> #1 (sk_lock-AF_INET){+.+.}-{0:0}:
       lock_acquire+0x1ed/0x550 kernel/locking/lockdep.c:5754
       lock_sock_nested+0x48/0x100 net/core/sock.c:3543
       do_ip_setsockopt+0x1a2d/0x3cd0 net/ipv4/ip_sockglue.c:1078
       ip_setsockopt+0x63/0x100 net/ipv4/ip_sockglue.c:1417
       do_sock_setsockopt+0x3af/0x720 net/socket.c:2312
       __sys_setsockopt+0x1ae/0x250 net/socket.c:2335
       __do_sys_setsockopt net/socket.c:2344 [inline]
       __se_sys_setsockopt net/socket.c:2341 [inline]
       __x64_sys_setsockopt+0xb5/0xd0 net/socket.c:2341
       do_syscall_x64 arch/x86/entry/common.c:52 [inline]
       do_syscall_64+0xf3/0x230 arch/x86/entry/common.c:83
       entry_SYSCALL_64_after_hwframe+0x77/0x7f

-> #0 (rtnl_mutex){+.+.}-{3:3}:
       check_prev_add kernel/locking/lockdep.c:3134 [inline]
       check_prevs_add kernel/locking/lockdep.c:3253 [inline]
       validate_chain+0x18e0/0x5900 kernel/locking/lockdep.c:3869
       __lock_acquire+0x1346/0x1fd0 kernel/locking/lockdep.c:5137
       lock_acquire+0x1ed/0x550 kernel/locking/lockdep.c:5754
       __mutex_lock_common kernel/locking/mutex.c:608 [inline]
       __mutex_lock+0x136/0xd70 kernel/locking/mutex.c:752
       start_sync_thread+0xdc/0x2dc0 net/netfilter/ipvs/ip_vs_sync.c:1761
       do_ip_vs_set_ctl+0x442/0x13d0 net/netfilter/ipvs/ip_vs_ctl.c:2732
       nf_setsockopt+0x295/0x2c0 net/netfilter/nf_sockopt.c:101
       smc_setsockopt+0x275/0xe50 net/smc/af_smc.c:3072
       do_sock_setsockopt+0x3af/0x720 net/socket.c:2312
       __sys_setsockopt+0x1ae/0x250 net/socket.c:2335
       __do_sys_setsockopt net/socket.c:2344 [inline]
       __se_sys_setsockopt net/socket.c:2341 [inline]
       __x64_sys_setsockopt+0xb5/0xd0 net/socket.c:2341
       do_syscall_x64 arch/x86/entry/common.c:52 [inline]
       do_syscall_64+0xf3/0x230 arch/x86/entry/common.c:83
       entry_SYSCALL_64_after_hwframe+0x77/0x7f

other info that might help us debug this:

Chain exists of:
  rtnl_mutex --> sk_lock-AF_INET --> &smc->clcsock_release_lock

 Possible unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(&smc->clcsock_release_lock);
                               lock(sk_lock-AF_INET);
                               lock(&smc->clcsock_release_lock);
  lock(rtnl_mutex);

 *** DEADLOCK ***

1 lock held by syz-executor.4/10811:
 #0: ffff88805ba95750 (&smc->clcsock_release_lock){+.+.}-{3:3}, at: smc_setsockopt+0x1c3/0xe50 net/smc/af_smc.c:3064

stack backtrace:
CPU: 0 PID: 10811 Comm: syz-executor.4 Not tainted 6.10.0-rc4-syzkaller-00837-g3226607302ca #0
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 06/07/2024
Call Trace:
 <TASK>
 __dump_stack lib/dump_stack.c:88 [inline]
 dump_stack_lvl+0x241/0x360 lib/dump_stack.c:114
 check_noncircular+0x36a/0x4a0 kernel/locking/lockdep.c:2187
 check_prev_add kernel/locking/lockdep.c:3134 [inline]
 check_prevs_add kernel/locking/lockdep.c:3253 [inline]
 validate_chain+0x18e0/0x5900 kernel/locking/lockdep.c:3869
 __lock_acquire+0x1346/0x1fd0 kernel/locking/lockdep.c:5137
 lock_acquire+0x1ed/0x550 kernel/locking/lockdep.c:5754
 __mutex_lock_common kernel/locking/mutex.c:608 [inline]
 __mutex_lock+0x136/0xd70 kernel/locking/mutex.c:752
 start_sync_thread+0xdc/0x2dc0 net/netfilter/ipvs/ip_vs_sync.c:1761
 do_ip_vs_set_ctl+0x442/0x13d0 net/netfilter/ipvs/ip_vs_ctl.c:2732
 nf_setsockopt+0x295/0x2c0 net/netfilter/nf_sockopt.c:101
 smc_setsockopt+0x275/0xe50 net/smc/af_smc.c:3072
 do_sock_setsockopt+0x3af/0x720 net/socket.c:2312
 __sys_setsockopt+0x1ae/0x250 net/socket.c:2335
 __do_sys_setsockopt net/socket.c:2344 [inline]
 __se_sys_setsockopt net/socket.c:2341 [inline]
 __x64_sys_setsockopt+0xb5/0xd0 net/socket.c:2341
 do_syscall_x64 arch/x86/entry/common.c:52 [inline]
 do_syscall_64+0xf3/0x230 arch/x86/entry/common.c:83
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7f42d8a7d0a9
Code: 28 00 00 00 75 05 48 83 c4 28 c3 e8 e1 20 00 00 90 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 c7 c1 b0 ff ff ff f7 d8 64 89 01 48
RSP: 002b:00007f42d98870c8 EFLAGS: 00000246 ORIG_RAX: 0000000000000036
RAX: ffffffffffffffda RBX: 00007f42d8bb3f80 RCX: 00007f42d8a7d0a9
RDX: 000000000000048b RSI: 0000000000000000 RDI: 0000000000000003
RBP: 00007f42d8aec074 R08: 0000000000000018 R09: 0000000000000000
R10: 0000000020000200 R11: 0000000000000246 R12: 0000000000000000
R13: 000000000000000b R14: 00007f42d8bb3f80 R15: 00007ffde628d3a8
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
