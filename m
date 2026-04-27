Received: from mail-oo1-f80.google.com (mail-oo1-f80.google.com [209.85.161.80])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 87E3D3DEACC
	for <lvs-devel@vger.kernel.org>; Mon, 27 Apr 2026 17:27:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.80
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777310851; cv=none; b=oCbg0ErF0EUl3QZk3Rzq0aYZueu7PMQytXTRGSEmJzb7j38iBUIsRE9aLIBCnhWAS8oZdbYZhHy+UUxKfsDLeiX24t+zlRrDRHrXxx8RQooLBgvBxo1xlRU9DZlplFQfWUX13JedLg3qsgqqYm3W4j2pYXiGjoQaobeVXkQ8Rh0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777310851; c=relaxed/simple;
	bh=cshR2R8EYWLHnttddvuQPhrhTqxK3mfBoXOPWgeDAtI=;
	h=MIME-Version:Date:Message-ID:Subject:From:To:Content-Type; b=fE3+lWIk8M8IlB79ngd3gPqW1OKcyYMMsOCxbXVimynBLYjUJEG9xVWpMTg86mWEcvzBCf0noEmcpLJgLoZ/NT9gg517Uk0mgOQDt1EPpLJRhNwn9/fgqvag+gn4PvgpI21vMguqlNueH1Sg9QhtiOcfcPYwwR3aWoXCd49He4I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com; arc=none smtp.client-ip=209.85.161.80
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-oo1-f80.google.com with SMTP id 006d021491bc7-696266291d6so3269061eaf.1
        for <lvs-devel@vger.kernel.org>; Mon, 27 Apr 2026 10:27:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1777310848; x=1777915648;
        h=to:from:subject:message-id:date:mime-version:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=CYjopPpYaJxYSiyLuTK+YXWn9hsUD1ElXWVwEnYsnlo=;
        b=UzOra+G1nEjPQmnalBz9jij3KT377UtMM2I5GaPCzVRxWHUrxyePBY2IEB8m0gPeRl
         +PvIStY31elXgYJXJ6UVYic+qa8owGY2xiGBMYZSxa10yye7qIrK77ToUikMq+WxFBjW
         zVI8ben9KbCC4eGB0eZn4ohO0slO9HGGeFSbaaojKVaQ8KJKnp2vMIYNywzLOyF0a4Wu
         NgLQwc3qI9ZsUy41LrFFxraMzj2dWvi1+z+urCOVWMgFEGtzj8IEOV2UuVJLgGzw1x1I
         q5nSIbU+My7KSB6NiJ2an7bTa20xF6U9Ae6P3AaCS+oZ9E/GsudRT3IEQsgMohIvoiTA
         DZ5Q==
X-Forwarded-Encrypted: i=1; AFNElJ9T1fkqtMXYkURiprKx0s1axHP3LilD66xf0OxnWOxtogFSLm45b/m35gTT4hKF1JiknIEuJYVYz8c=@vger.kernel.org
X-Gm-Message-State: AOJu0YzTb3sTevgkhH0ElOT47douAmiUqmzDcSCPEPR9YKTGSsEmr3R5
	ITtaV7ZgGc6lK1NYjf0qUOmBWIrM0iJiyPVJ6eo9LdExNjrjYxRuuOS/OXsfKwjOu2PuGhxqhAE
	g0f4ISRJc1WS/vFgcoNrjrXas4qVG+0VsqN+Y+ilmUhUkiDZwoYiB0U7YjSk=
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a05:6820:1987:b0:696:21ad:a4f0 with SMTP id
 006d021491bc7-69621ada98fmr10066287eaf.36.1777310848618; Mon, 27 Apr 2026
 10:27:28 -0700 (PDT)
Date: Mon, 27 Apr 2026 10:27:28 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <69ef9c80.050a0220.18b4f.0005.GAE@google.com>
Subject: [syzbot] [lvs?] UBSAN: shift-out-of-bounds in ip_vs_rht_desired_size
From: syzbot <syzbot+217f1db9c791e27fe54a@syzkaller.appspotmail.com>
To: coreteam@netfilter.org, davem@davemloft.net, edumazet@google.com, 
	fw@strlen.de, horms@verge.net.au, ja@ssi.bg, kuba@kernel.org, 
	linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, 
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, pabeni@redhat.com, 
	pablo@netfilter.org, phil@nwl.cc, syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"

Hello,

syzbot found the following issue on:

HEAD commit:    e728258debd5 Merge tag 'net-7.1-rc1' of git://git.kernel.o..
git tree:       net-next
console output: https://syzkaller.appspot.com/x/log.txt?x=169022ce580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=ca77bfc4078c8193
dashboard link: https://syzkaller.appspot.com/bug?extid=217f1db9c791e27fe54a
compiler:       Debian clang version 21.1.8 (++20251221033036+2078da43e25a-1~exp1~20251221153213.50), Debian LLD 21.1.8

Unfortunately, I don't have any reproducer for this issue yet.

Downloadable assets:
disk image: https://storage.googleapis.com/syzbot-assets/24195bde5d1d/disk-e728258d.raw.xz
vmlinux: https://storage.googleapis.com/syzbot-assets/78131d1b0e14/vmlinux-e728258d.xz
kernel image: https://storage.googleapis.com/syzbot-assets/836d0dd78c10/bzImage-e728258d.xz

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+217f1db9c791e27fe54a@syzkaller.appspotmail.com

wlan0: No active IBSS STAs - trying to scan for other IBSS networks with same SSID (merge)
------------[ cut here ]------------
UBSAN: shift-out-of-bounds in ./include/linux/log2.h:57:13
shift exponent 64 is too large for 64-bit type 'unsigned long'
CPU: 1 UID: 0 PID: 77 Comm: kworker/u8:4 Not tainted syzkaller #0 PREEMPT(full) 
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 04/18/2026
Workqueue: events_unbound conn_resize_work_handler
Call Trace:
 <TASK>
 dump_stack_lvl+0xe8/0x150 lib/dump_stack.c:120
 ubsan_epilogue+0xa/0x30 lib/ubsan.c:233
 __ubsan_handle_shift_out_of_bounds+0x385/0x410 lib/ubsan.c:494
 __roundup_pow_of_two include/linux/log2.h:57 [inline]
 ip_vs_rht_desired_size+0x2cf/0x410 net/netfilter/ipvs/ip_vs_core.c:240
 ip_vs_conn_desired_size net/netfilter/ipvs/ip_vs_conn.c:765 [inline]
 conn_resize_work_handler+0x1b6/0x14c0 net/netfilter/ipvs/ip_vs_conn.c:822
 process_one_work kernel/workqueue.c:3302 [inline]
 process_scheduled_works+0xb5d/0x1860 kernel/workqueue.c:3385
 worker_thread+0xa53/0xfc0 kernel/workqueue.c:3466
 kthread+0x388/0x470 kernel/kthread.c:436
 ret_from_fork+0x514/0xb70 arch/x86/kernel/process.c:158
 ret_from_fork_asm+0x1a/0x30 arch/x86/entry/entry_64.S:245
 </TASK>
---[ end trace ]---
Kernel panic - not syncing: UBSAN: panic_on_warn set ...
CPU: 1 UID: 0 PID: 77 Comm: kworker/u8:4 Not tainted syzkaller #0 PREEMPT(full) 
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 04/18/2026
Workqueue: events_unbound conn_resize_work_handler
Call Trace:
 <TASK>
 vpanic+0x56c/0xa60 kernel/panic.c:650
 panic+0xc5/0xd0 kernel/panic.c:787
 check_panic_on_warn+0x89/0xb0 kernel/panic.c:524
 __ubsan_handle_shift_out_of_bounds+0x385/0x410 lib/ubsan.c:494
 __roundup_pow_of_two include/linux/log2.h:57 [inline]
 ip_vs_rht_desired_size+0x2cf/0x410 net/netfilter/ipvs/ip_vs_core.c:240
 ip_vs_conn_desired_size net/netfilter/ipvs/ip_vs_conn.c:765 [inline]
 conn_resize_work_handler+0x1b6/0x14c0 net/netfilter/ipvs/ip_vs_conn.c:822
 process_one_work kernel/workqueue.c:3302 [inline]
 process_scheduled_works+0xb5d/0x1860 kernel/workqueue.c:3385
 worker_thread+0xa53/0xfc0 kernel/workqueue.c:3466
 kthread+0x388/0x470 kernel/kthread.c:436
 ret_from_fork+0x514/0xb70 arch/x86/kernel/process.c:158
 ret_from_fork_asm+0x1a/0x30 arch/x86/entry/entry_64.S:245
 </TASK>
Kernel Offset: disabled
Rebooting in 86400 seconds..


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
