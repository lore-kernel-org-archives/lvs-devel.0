Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0C09734BA42;
	Mon, 27 Apr 2026 22:37:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777329458; cv=none; b=S2F4oXLrydO7yvs3LBu06dnaW9nedoxbW4mVwpmX6YtDx2pESlgYQs1kOz2PD7VOXDDuH0FD9lgDyACHE11PbzXX/jgQcmW8YGGWzSz4JtaSyhybNlM9puYNFjRoN8Ti/R+ugDI4UV0YHhoeGHUZtWBZKixN5u9jh8mHZSTjBMA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777329458; c=relaxed/simple;
	bh=nO/Tj8iF5nAyPzBtqgI5qS/OofEA68ZcXTqD/4QaZmk=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=UA0OG8Hry8VW+l6hqdI45zWj4u2L7hP4kPpsVxasTMqwbEHx9+BbtP8tihOepLdHsBCe1tggUx9UW0x+bVqhH17MnGDc+7KYsCF0/P0wwdGfIa1LPLcQ3SKxtOTJUjviQd56p9dnPterVatXdiz/iPr1KqzF+2Ec9dWpWx0uSe4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=ARlm0zc0; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="ARlm0zc0"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id DB929210CD;
	Tue, 28 Apr 2026 01:37:24 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=OXylDqCnyDvdyturebTNJsAAJcB2rcEPlzI5Tom6Q/4=; b=ARlm0zc0Wgbc
	YspFirgkui+5YwGbzndgra0A3GsWlq6+kTgbq5GUwYCCsLMAz1CNag/VyvB5Cycf
	Lw8u0ItNED19jsvcltHk9co/eDPo5mNOIjL+fHbQOaxJlBn1k6UlB38xEHwPIdGj
	Ft3fJMHdD6Aj+SQ+j6/QLMX5gUKK7UOrHoAVs+Y13OsaoXO7jSN1KDC5qxTdxfjD
	txkrFKAVfKLxNgvnZE5KR9ClPcjxvVXatuxYQiB+NR3ZbClv/j1qoTl0LsCaZodJ
	1nVlj9E2soHomGleajYo2wFT5y9cM5ABr0IIsHb/BRCM1h5g9EktMHNv61VmAp+S
	JD5wQozRlPf/IzEcj/cbDbSIk2vnVjAg3YoblBfBr1g6awtUxFXKadVV7tGwJL+v
	JoYFQWZTUAdsfJP2Eb+LakyfyML466w1IE4COcqo4yNNKXowpIKuDv5/tKTMf3M+
	0P7RsweYHXqsXeYeWaLZeBnG9piADVwyWJ11X71IkCZwH6TTpvhnn0+6ynXWzQHD
	trCQOC+PnQdxe7+mt7zExiyLpZIJzNqKVgEWvC52KbHF0XjBtrkP/unZErdiqZ3h
	tUMgpLJyi02qU1Hhhqh3j9lKvFfM8CSY5sM1jwWMcCN3WB95OTV0vEoLEMCXhWjV
	c6c3VG0mL9GLoh7hhROjr6aYlqCH8LI=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 28 Apr 2026 01:37:23 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id E595A628C8;
	Tue, 28 Apr 2026 01:37:19 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63RMb8Jl078439;
	Tue, 28 Apr 2026 01:37:09 +0300
Date: Tue, 28 Apr 2026 01:37:08 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: syzbot <syzbot+217f1db9c791e27fe54a@syzkaller.appspotmail.com>
cc: coreteam@netfilter.org, davem@davemloft.net, edumazet@google.com,
        fw@strlen.de, horms@verge.net.au, kuba@kernel.org,
        linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org,
        netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
        pabeni@redhat.com, pablo@netfilter.org, phil@nwl.cc,
        syzkaller-bugs@googlegroups.com
Subject: Re: [syzbot] [lvs?] UBSAN: shift-out-of-bounds in
 ip_vs_rht_desired_size
In-Reply-To: <69ef9c80.050a0220.18b4f.0005.GAE@google.com>
Message-ID: <415b384c-e797-dc05-cf61-ac407dc08978@ssi.bg>
References: <69ef9c80.050a0220.18b4f.0005.GAE@google.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 27 Apr 2026, syzbot wrote:

> Hello,
> 
> syzbot found the following issue on:
> 
> HEAD commit:    e728258debd5 Merge tag 'net-7.1-rc1' of git://git.kernel.o..
> git tree:       net-next
> console output: https://syzkaller.appspot.com/x/log.txt?x=169022ce580000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=ca77bfc4078c8193
> dashboard link: https://syzkaller.appspot.com/bug?extid=217f1db9c791e27fe54a
> compiler:       Debian clang version 21.1.8 (++20251221033036+2078da43e25a-1~exp1~20251221153213.50), Debian LLD 21.1.8
> 
> Unfortunately, I don't have any reproducer for this issue yet.
> 
> Downloadable assets:
> disk image: https://storage.googleapis.com/syzbot-assets/24195bde5d1d/disk-e728258d.raw.xz
> vmlinux: https://storage.googleapis.com/syzbot-assets/78131d1b0e14/vmlinux-e728258d.xz
> kernel image: https://storage.googleapis.com/syzbot-assets/836d0dd78c10/bzImage-e728258d.xz
> 
> IMPORTANT: if you fix the issue, please add the following tag to the commit:
> Reported-by: syzbot+217f1db9c791e27fe54a@syzkaller.appspotmail.com
> 
> wlan0: No active IBSS STAs - trying to scan for other IBSS networks with same SSID (merge)
> ------------[ cut here ]------------
> UBSAN: shift-out-of-bounds in ./include/linux/log2.h:57:13
> shift exponent 64 is too large for 64-bit type 'unsigned long'
> CPU: 1 UID: 0 PID: 77 Comm: kworker/u8:4 Not tainted syzkaller #0 PREEMPT(full) 
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 04/18/2026
> Workqueue: events_unbound conn_resize_work_handler
> Call Trace:
>  <TASK>
>  dump_stack_lvl+0xe8/0x150 lib/dump_stack.c:120
>  ubsan_epilogue+0xa/0x30 lib/ubsan.c:233
>  __ubsan_handle_shift_out_of_bounds+0x385/0x410 lib/ubsan.c:494
>  __roundup_pow_of_two include/linux/log2.h:57 [inline]

	Looks like roundup_pow_of_two() is called for 0.
Will provide fix for this...

>  ip_vs_rht_desired_size+0x2cf/0x410 net/netfilter/ipvs/ip_vs_core.c:240
>  ip_vs_conn_desired_size net/netfilter/ipvs/ip_vs_conn.c:765 [inline]
>  conn_resize_work_handler+0x1b6/0x14c0 net/netfilter/ipvs/ip_vs_conn.c:822
>  process_one_work kernel/workqueue.c:3302 [inline]
>  process_scheduled_works+0xb5d/0x1860 kernel/workqueue.c:3385
>  worker_thread+0xa53/0xfc0 kernel/workqueue.c:3466
>  kthread+0x388/0x470 kernel/kthread.c:436
>  ret_from_fork+0x514/0xb70 arch/x86/kernel/process.c:158
>  ret_from_fork_asm+0x1a/0x30 arch/x86/entry/entry_64.S:245
>  </TASK>
> ---[ end trace ]---
> Kernel panic - not syncing: UBSAN: panic_on_warn set ...
> CPU: 1 UID: 0 PID: 77 Comm: kworker/u8:4 Not tainted syzkaller #0 PREEMPT(full) 
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 04/18/2026
> Workqueue: events_unbound conn_resize_work_handler
> Call Trace:
>  <TASK>
>  vpanic+0x56c/0xa60 kernel/panic.c:650
>  panic+0xc5/0xd0 kernel/panic.c:787
>  check_panic_on_warn+0x89/0xb0 kernel/panic.c:524
>  __ubsan_handle_shift_out_of_bounds+0x385/0x410 lib/ubsan.c:494
>  __roundup_pow_of_two include/linux/log2.h:57 [inline]
>  ip_vs_rht_desired_size+0x2cf/0x410 net/netfilter/ipvs/ip_vs_core.c:240
>  ip_vs_conn_desired_size net/netfilter/ipvs/ip_vs_conn.c:765 [inline]
>  conn_resize_work_handler+0x1b6/0x14c0 net/netfilter/ipvs/ip_vs_conn.c:822
>  process_one_work kernel/workqueue.c:3302 [inline]
>  process_scheduled_works+0xb5d/0x1860 kernel/workqueue.c:3385
>  worker_thread+0xa53/0xfc0 kernel/workqueue.c:3466
>  kthread+0x388/0x470 kernel/kthread.c:436
>  ret_from_fork+0x514/0xb70 arch/x86/kernel/process.c:158
>  ret_from_fork_asm+0x1a/0x30 arch/x86/entry/entry_64.S:245
>  </TASK>
> Kernel Offset: disabled
> Rebooting in 86400 seconds..

Regards

--
Julian Anastasov <ja@ssi.bg>

