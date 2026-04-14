Received: from out-184.mta0.migadu.com (out-184.mta0.migadu.com [91.218.175.184])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EC7503E51E8
	for <lvs-devel@vger.kernel.org>; Tue, 14 Apr 2026 12:09:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=91.218.175.184
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776168564; cv=none; b=vBVcexbAytFyl5bmn5IZlNxka46dFccsgVyjIOsV44ePnwHTCuMx8Mw9diEUaGHQSw/941BKvPTusi9lHVtzj3NeE5YmPA+dP0k+7RbBlUUicWiHKVzhnnCcpnFLDLd9gZd+8CyCLYaGr8iFnq6qINrZfA82QpgUFND+lKcOi1Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776168564; c=relaxed/simple;
	bh=v1fK/1cChZ6rrt99Qr8LYZy9YUmvcWvPUtcVecbwhLI=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=ECAXckD96+WETwdFEHs0Yd7PUjEDtYvpvhb/3nI81QUUkMADpIBgbcVvwFIAA2YE52jwDvTMMD+fYVrG28Tb5UjdkMoB4WB+MKh9VWuOrtRIi3akmlL2wQQ31MWG0MG4Qs7m8NP13HDdatyVnk32QTpy2H/uDcbyfW7gsjJgElA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev; spf=pass smtp.mailfrom=linux.dev; dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b=Mhd4qYrp; arc=none smtp.client-ip=91.218.175.184
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b="Mhd4qYrp"
Message-ID: <927be094-315b-48ab-8e89-45bbe9183d5b@linux.dev>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linux.dev; s=key1;
	t=1776168559;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=QVtXc7JLuD25nmtQ2i0cFNoD/wmAUFxwAuqwgL+A5s0=;
	b=Mhd4qYrpk0vHcZ6XtlaxOCrsqiOVGVafokFS+/nVPJBuE8TZTDC7yeH4F27Gugz4qkBBGr
	l1wk4HFGFCIMQJiB83Mp4skTGCxIKO+Ewzp7RlFrmRK8i9bXmir72e7NkHW5EbHEvsbvQu
	ofP0rK18INZLsc9rOuFm4wVulFrJxqs=
Date: Tue, 14 Apr 2026 20:09:05 +0800
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Subject: Re: [syzbot] [lvs?] BUG: sleeping function called from invalid
 context in ip_vs_conn_expire
To: syzbot <syzbot+504e778ddaecd36fdd17@syzkaller.appspotmail.com>,
 coreteam@netfilter.org, davem@davemloft.net, edumazet@google.com,
 fw@strlen.de, horms@verge.net.au, ja@ssi.bg, kuba@kernel.org,
 linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org,
 netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, pabeni@redhat.com,
 pablo@netfilter.org, phil@nwl.cc, syzkaller-bugs@googlegroups.com
References: <69de1743.a00a0220.475f0.0040.GAE@google.com>
X-Report-Abuse: Please report any abuse attempt to abuse@migadu.com and include these headers.
From: Jiayuan Chen <jiayuan.chen@linux.dev>
In-Reply-To: <69de1743.a00a0220.475f0.0040.GAE@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
X-Migadu-Flow: FLOW_OUT


On 4/14/26 6:30 PM, syzbot wrote:

[...]

> if you fix the issue, please add the following tag to the commit:
> Reported-by: syzbot+504e778ddaecd36fdd17@syzkaller.appspotmail.com
>
> BUG: sleeping function called from invalid context at kernel/locking/spinlock_rt.c:48



The problem occurs under PREEMPT_RT. conn_tab_lock pair with spin_lock 
has the problem:

     conn_tab_lock(...) -> hlist_bl_lock -> preempt_disable()  ==> 
disables preemption
     spin_lock(&cp->lock) -> rt_mutex  ==> sleepable under RT, but 
preemption is already disabled by conn_tab_lock


> in_atomic(): 1, irqs_disabled(): 0, non_block: 0, pid: 16, name: ktimers/0
> preempt_count: 2, expected: 0
> RCU nest depth: 3, expected: 3
> 8 locks held by ktimers/0/16:
>   #0: ffffffff8de5f260 (local_bh){.+.+}-{1:3}, at: __local_bh_disable_ip+0x3c/0x420 kernel/softirq.c:163
>   #1: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: __local_bh_disable_ip+0x3c/0x420 kernel/softirq.c:163
>   #2: ffff8880b8826360 (&base->expiry_lock){+...}-{3:3}, at: spin_lock include/linux/spinlock_rt.h:45 [inline]
>   #2: ffff8880b8826360 (&base->expiry_lock){+...}-{3:3}, at: timer_base_lock_expiry kernel/time/timer.c:1502 [inline]
>   #2: ffff8880b8826360 (&base->expiry_lock){+...}-{3:3}, at: __run_timer_base+0x120/0x9f0 kernel/time/timer.c:2384
>   #3: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acquire include/linux/rcupdate.h:300 [inline]
>   #3: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock include/linux/rcupdate.h:838 [inline]
>   #3: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: __rt_spin_lock kernel/locking/spinlock_rt.c:50 [inline]
>   #3: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: rt_spin_lock+0x1e0/0x400 kernel/locking/spinlock_rt.c:57
>   #4: ffffc90000157a80 ((&cp->timer)){+...}-{0:0}, at: call_timer_fn+0xd4/0x5e0 kernel/time/timer.c:1745
>   #5: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acquire include/linux/rcupdate.h:300 [inline]
>   #5: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock include/linux/rcupdate.h:838 [inline]
>   #5: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: ip_vs_conn_unlink net/netfilter/ipvs/ip_vs_conn.c:315 [inline]
>   #5: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: ip_vs_conn_expire+0x257/0x2390 net/netfilter/ipvs/ip_vs_conn.c:1260
>   #6: ffffffff8de5f260 (local_bh){.+.+}-{1:3}, at: __local_bh_disable_ip+0x3c/0x420 kernel/softirq.c:163
>   #7: ffff888068d4c3f0 (&cp->lock#2){+...}-{3:3}, at: spin_lock include/linux/spinlock_rt.h:45 [inline]
>   #7: ffff888068d4c3f0 (&cp->lock#2){+...}-{3:3}, at: ip_vs_conn_unlink net/netfilter/ipvs/ip_vs_conn.c:324 [inline]
>   #7: ffff888068d4c3f0 (&cp->lock#2){+...}-{3:3}, at: ip_vs_conn_expire+0xd4a/0x2390 net/netfilter/ipvs/ip_vs_conn.c:1260
> Preemption disabled at:
> [<ffffffff898a6358>] bit_spin_lock include/linux/bit_spinlock.h:38 [inline]
> [<ffffffff898a6358>] hlist_bl_lock+0x18/0x110 include/linux/list_bl.h:149
> CPU: 0 UID: 0 PID: 16 Comm: ktimers/0 Tainted: G        W    L      syzkaller #0 PREEMPT_{RT,(full)}
> Tainted: [W]=WARN, [L]=SOFTLOCKUP
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 03/18/2026
> Call Trace:
>   <TASK>
>   dump_stack_lvl+0xe8/0x150 lib/dump_stack.c:120
>   __might_resched+0x329/0x480 kernel/sched/core.c:9162
>   __rt_spin_lock kernel/locking/spinlock_rt.c:48 [inline]
>   rt_spin_lock+0xc2/0x400 kernel/locking/spinlock_rt.c:57
>   spin_lock include/linux/spinlock_rt.h:45 [inline]
>   ip_vs_conn_unlink net/netfilter/ipvs/ip_vs_conn.c:324 [inline]
>   ip_vs_conn_expire+0xd4a/0x2390 net/netfilter/ipvs/ip_vs_conn.c:1260
>   call_timer_fn+0x192/0x5e0 kernel/time/timer.c:1748
>   expire_timers kernel/time/timer.c:1799 [inline]
>   __run_timers kernel/time/timer.c:2374 [inline]
>   __run_timer_base+0x6a3/0x9f0 kernel/time/timer.c:2386
>   run_timer_base kernel/time/timer.c:2395 [inline]
>   run_timer_softirq+0xb7/0x170 kernel/time/timer.c:2405
>   handle_softirqs+0x1de/0x6d0 kernel/softirq.c:622
>   __do_softirq kernel/softirq.c:656 [inline]
>   run_ktimerd+0x69/0x100 kernel/softirq.c:1151
>   smpboot_thread_fn+0x541/0xa50 kernel/smpboot.c:160
>   kthread+0x388/0x470 kernel/kthread.c:436
>   ret_from_fork+0x514/0xb70 arch/x86/kernel/process.c:158
>   ret_from_fork_asm+0x1a/0x30 arch/x86/entry/entry_64.S:245
>   </TASK>
>
