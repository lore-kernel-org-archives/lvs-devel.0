Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 93F9D3E51F4;
	Tue, 14 Apr 2026 14:18:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776176341; cv=none; b=e4JG4/cVQ+rhTezgQKAQ9a17i9DZ2GD4noFlQB9W7XzPJhHTqf4B4pT+xW76lIamr6fRILpe/m3X0a1/ZkcKrEyt7neunynhXZwKPOSvxcGPyaS+SwcZOEtnDCGyQDbQNZ9dM2oWHSs6fhuuRH7pGKlSHMHYQ6nf24xCSOmX14I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776176341; c=relaxed/simple;
	bh=f3ZpNIpttJfNAhesSgdoZQhjdXLEQm8VaLJ6APaJ+yM=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=aOo5+9zcQQNUStFken/Pe9Sf3iMwvpGOJrAcpi/Us9rFzBEtOLUzD6wpys6HMFSS/P2yMvzC5gVqqCp1KMu+aII+6re0AH7v0adFfkc+Fh9HDxrduvfEIVqssgZ/Qd9MLCcssiFgLKuvTcVsvPTempEOxFyfkqvD50PiHa8awIA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=sxvhBH9b; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="sxvhBH9b"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id CDAAC21268;
	Tue, 14 Apr 2026 17:18:47 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=d8jYqCvvW93rQHP3RtDaZIoVV3Og+SmR4qdqyFTn6RE=; b=sxvhBH9bu4ox
	A304P1k2XV/svkew+ww5422B2l9nNC0qtYyMZ1KDb++kdrTEs7t1zOC3XS/9Fjvq
	bVrZJ8Gm/ZWXGkyzPyF19E3SZI0XJ7yv42fEb8JhzuJDI31/t8n9CAT96VbxUs8S
	C0HESGg69HrFVHarGbFGQTZEo2WqyWcar/Xo7KXBTMPnpZeOY8j4la4y1QVuirDe
	EtzSD1fWbx+kQ9BfD/EHqaWIny8Pn/532+dHNas8LGqfI2AJE3HTySiBgdcb2u2F
	yimg5u9Ct37Ym0Ik4Mam6hNfuTp5h1aQL2VM9eHca5v+r26tL3ilydeznh7gjaTG
	QrwLnnBjyTXK5/CPQMq+8wjatXf0nb2yvI5w8poGaybCtcB+xcpdc1yTfL/n98Oy
	AIlsrQTt3ZIpj3SnjvTu2z1EM/XJUdMS5/vw1RoCDGKYKEAwMp+Jx+kQw632ApPb
	N0RckcAXVNqUxozh+O6Ye0VMQ5SG2lB+X31DwBKJlsCGD/zYCRM6SGuiwm6sDM+t
	ozn5d96KDvC3MH2Xj/eZf/yaCGbj3swuNKojQfX44UR28bPA+y5BoRZUvPKnuHAJ
	EyJLpRzvl+JqIFBp93/Sv8pEIeUBo2aAwbDcVFz5CSCthOg74EvSnMZb/HpbVj3o
	Tqj++VLbCyaO2ZY6BQo9zTJ6eoAKu/M=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 14 Apr 2026 17:18:46 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id ABF746096A;
	Tue, 14 Apr 2026 17:18:44 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63EEIUKv049019;
	Tue, 14 Apr 2026 17:18:31 +0300
Date: Tue, 14 Apr 2026 17:18:30 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Jiayuan Chen <jiayuan.chen@linux.dev>
cc: syzbot <syzbot+504e778ddaecd36fdd17@syzkaller.appspotmail.com>,
        coreteam@netfilter.org, davem@davemloft.net, edumazet@google.com,
        fw@strlen.de, horms@verge.net.au, kuba@kernel.org,
        linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org,
        netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
        pabeni@redhat.com, pablo@netfilter.org, phil@nwl.cc,
        syzkaller-bugs@googlegroups.com
Subject: Re: [syzbot] [lvs?] BUG: sleeping function called from invalid
 context in ip_vs_conn_expire
In-Reply-To: <927be094-315b-48ab-8e89-45bbe9183d5b@linux.dev>
Message-ID: <1b162043-f8b5-402f-0db6-fdbab52f960f@ssi.bg>
References: <69de1743.a00a0220.475f0.0040.GAE@google.com> <927be094-315b-48ab-8e89-45bbe9183d5b@linux.dev>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="-1463811672-978217088-1776176316=:4042"

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-978217088-1776176316=:4042
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Tue, 14 Apr 2026, Jiayuan Chen wrote:

> 
> On 4/14/26 6:30 PM, syzbot wrote:
> 
> [...]
> 
> > if you fix the issue, please add the following tag to the commit:
> > Reported-by: syzbot+504e778ddaecd36fdd17@syzkaller.appspotmail.com
> >
> > BUG: sleeping function called from invalid context at
> > kernel/locking/spinlock_rt.c:48
> 
> 
> 
> The problem occurs under PREEMPT_RT. conn_tab_lock pair with spin_lock has the
> problem:
> 
>     conn_tab_lock(...) -> hlist_bl_lock -> preempt_disable()  ==> disables
> preemption
>     spin_lock(&cp->lock) -> rt_mutex  ==> sleepable under RT, but preemption
> is already disabled by conn_tab_lock

	I guess, spin_lock(&cp->lock) which sleeps under
PREEMPT_RT, should not be called under bit spinlock.
I'll check it soon...

> > in_atomic(): 1, irqs_disabled(): 0, non_block: 0, pid: 16, name: ktimers/0
> > preempt_count: 2, expected: 0
> > RCU nest depth: 3, expected: 3
> > 8 locks held by ktimers/0/16:
> >   #0: ffffffff8de5f260 (local_bh){.+.+}-{1:3}, at:
> >   __local_bh_disable_ip+0x3c/0x420 kernel/softirq.c:163
> >   #1: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at:
> >   __local_bh_disable_ip+0x3c/0x420 kernel/softirq.c:163
> >   #2: ffff8880b8826360 (&base->expiry_lock){+...}-{3:3}, at: spin_lock
> >   include/linux/spinlock_rt.h:45 [inline]
> >   #2: ffff8880b8826360 (&base->expiry_lock){+...}-{3:3}, at:
> >   timer_base_lock_expiry kernel/time/timer.c:1502 [inline]
> >   #2: ffff8880b8826360 (&base->expiry_lock){+...}-{3:3}, at:
> >   __run_timer_base+0x120/0x9f0 kernel/time/timer.c:2384
> >   #3: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acquire
> >   include/linux/rcupdate.h:300 [inline]
> >   #3: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock
> >   include/linux/rcupdate.h:838 [inline]
> >   #3: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: __rt_spin_lock
> >   kernel/locking/spinlock_rt.c:50 [inline]
> >   #3: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at:
> >   rt_spin_lock+0x1e0/0x400 kernel/locking/spinlock_rt.c:57
> >   #4: ffffc90000157a80 ((&cp->timer)){+...}-{0:0}, at:
> >   call_timer_fn+0xd4/0x5e0 kernel/time/timer.c:1745
> >   #5: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acquire
> >   include/linux/rcupdate.h:300 [inline]
> >   #5: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock
> >   include/linux/rcupdate.h:838 [inline]
> >   #5: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: ip_vs_conn_unlink
> >   net/netfilter/ipvs/ip_vs_conn.c:315 [inline]
> >   #5: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at:
> >   ip_vs_conn_expire+0x257/0x2390 net/netfilter/ipvs/ip_vs_conn.c:1260
> >   #6: ffffffff8de5f260 (local_bh){.+.+}-{1:3}, at:
> >   __local_bh_disable_ip+0x3c/0x420 kernel/softirq.c:163
> >   #7: ffff888068d4c3f0 (&cp->lock#2){+...}-{3:3}, at: spin_lock
> >   include/linux/spinlock_rt.h:45 [inline]
> >   #7: ffff888068d4c3f0 (&cp->lock#2){+...}-{3:3}, at: ip_vs_conn_unlink
> >   net/netfilter/ipvs/ip_vs_conn.c:324 [inline]
> >   #7: ffff888068d4c3f0 (&cp->lock#2){+...}-{3:3}, at:
> >   ip_vs_conn_expire+0xd4a/0x2390 net/netfilter/ipvs/ip_vs_conn.c:1260
> > Preemption disabled at:
> > [<ffffffff898a6358>] bit_spin_lock include/linux/bit_spinlock.h:38 [inline]
> > [<ffffffff898a6358>] hlist_bl_lock+0x18/0x110 include/linux/list_bl.h:149
> > CPU: 0 UID: 0 PID: 16 Comm: ktimers/0 Tainted: G        W    L
> > syzkaller #0 PREEMPT_{RT,(full)}
> > Tainted: [W]=WARN, [L]=SOFTLOCKUP
> > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> > Google 03/18/2026
> > Call Trace:
> >   <TASK>
> >   dump_stack_lvl+0xe8/0x150 lib/dump_stack.c:120
> >   __might_resched+0x329/0x480 kernel/sched/core.c:9162
> >   __rt_spin_lock kernel/locking/spinlock_rt.c:48 [inline]
> >   rt_spin_lock+0xc2/0x400 kernel/locking/spinlock_rt.c:57
> >   spin_lock include/linux/spinlock_rt.h:45 [inline]
> >   ip_vs_conn_unlink net/netfilter/ipvs/ip_vs_conn.c:324 [inline]
> >   ip_vs_conn_expire+0xd4a/0x2390 net/netfilter/ipvs/ip_vs_conn.c:1260
> >   call_timer_fn+0x192/0x5e0 kernel/time/timer.c:1748
> >   expire_timers kernel/time/timer.c:1799 [inline]
> >   __run_timers kernel/time/timer.c:2374 [inline]
> >   __run_timer_base+0x6a3/0x9f0 kernel/time/timer.c:2386
> >   run_timer_base kernel/time/timer.c:2395 [inline]
> >   run_timer_softirq+0xb7/0x170 kernel/time/timer.c:2405
> >   handle_softirqs+0x1de/0x6d0 kernel/softirq.c:622
> >   __do_softirq kernel/softirq.c:656 [inline]
> >   run_ktimerd+0x69/0x100 kernel/softirq.c:1151
> >   smpboot_thread_fn+0x541/0xa50 kernel/smpboot.c:160
> >   kthread+0x388/0x470 kernel/kthread.c:436
> >   ret_from_fork+0x514/0xb70 arch/x86/kernel/process.c:158
> >   ret_from_fork_asm+0x1a/0x30 arch/x86/entry/entry_64.S:245
> >   </TASK>

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-978217088-1776176316=:4042--

