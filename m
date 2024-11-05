Received: from ganesha.gnumonks.org (ganesha.gnumonks.org [213.95.27.120])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 205D71D278B;
	Tue,  5 Nov 2024 11:25:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.27.120
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1730805912; cv=none; b=rl4xDTgLNQ+ghBNKF4SzK/p4b0nGEKkEuRoWA+V5NSPE9yhdNqWnnnu0IgOWtJmdzr3d+gGHnSCXZB2SrxeQ0Uq5tEOjl8w2cODxB/Tx66cXllHBdoKWoNsIJwqVec0gk1Z80HTvcODfM94fYyXMyfdAVbI7L1hyJBFuHJI7GN8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1730805912; c=relaxed/simple;
	bh=eVKFimwSrLBVPc0u9ggjPX9a1NYiYheddPFbojKnoCM=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=OG3BxrHtRc5vRhAbkkSWLxLbaSoJ6gtfIo2/SJa4abzE0A1VKRbL1VSZbNTRRdIUp7m/Rc182znFhed+12+z9an+1ywFYklT7/h5UzLDYJNGa3omor0ynHTVJIAR8VJC+eiR6Jg3wcK5LR3qB8bzfpbkwsZ8Z4bZunfct28boig=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org; spf=pass smtp.mailfrom=gnumonks.org; arc=none smtp.client-ip=213.95.27.120
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gnumonks.org
Received: from [78.30.37.63] (port=54028 helo=gnumonks.org)
	by ganesha.gnumonks.org with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.94.2)
	(envelope-from <pablo@gnumonks.org>)
	id 1t8HgD-004Mns-HQ; Tue, 05 Nov 2024 12:25:04 +0100
Date: Tue, 5 Nov 2024 12:25:00 +0100
From: Pablo Neira Ayuso <pablo@netfilter.org>
To: Wenjia Zhang <wenjia@linux.ibm.com>, Jan Karcher <jaka@linux.ibm.com>,
	"D. Wythe" <alibuda@linux.alibaba.com>,
	Tony Lu <tonylu@linux.alibaba.com>,
	Wen Gu <guwen@linux.alibaba.com>, linux-s390@vger.kernel.org
Cc: syzbot <syzbot+e929093395ec65f969c7@syzkaller.appspotmail.com>,
	coreteam@netfilter.org, davem@davemloft.net, edumazet@google.com,
	horms@verge.net.au, ja@ssi.bg, kadlec@netfilter.org,
	kuba@kernel.org, linux-kernel@vger.kernel.org,
	lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, pabeni@redhat.com,
	syzkaller-bugs@googlegroups.com
Subject: Re: [syzbot] [lvs?] possible deadlock in start_sync_thread
Message-ID: <ZyoAjPBjtQA6jE-8@calendula>
References: <000000000000abf2f0061ba46a1a@google.com>
 <6725704b.050a0220.35b515.0180.GAE@google.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <6725704b.050a0220.35b515.0180.GAE@google.com>
X-Spam-Score: -1.7 (-)

Hi,

I am Cc'ing SHARED MEMORY COMMUNICATIONS (SMC) SOCKETS maintainers.

Similar issue already reported by syzkaller here:

https://lore.kernel.org/netdev/ZyIgRmJUbnZpzXNV@calendula/T/#mf1f03a65108226102d8567c9fb6bab98c072444c

related to smc->clcsock_release_lock.

I think this is a false possible lockdep considers smc->clcsock_release_lock
is a lock of the same class sk_lock-AF_INET.

Could you please advise?

Thanks.

On Fri, Nov 01, 2024 at 05:20:27PM -0700, syzbot wrote:
> syzbot has found a reproducer for the following issue on:
> 
> HEAD commit:    6c52d4da1c74 Merge tag 'for-linus' of git://git.kernel.org..
> git tree:       upstream
> console+strace: https://syzkaller.appspot.com/x/log.txt?x=12889630580000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=672325e7ab17fdf7
> dashboard link: https://syzkaller.appspot.com/bug?extid=e929093395ec65f969c7
> compiler:       Debian clang version 15.0.6, GNU ld (GNU Binutils for Debian) 2.40
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=1788e187980000
> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=14a4f2a7980000
> 
> Downloadable assets:
> disk image: https://storage.googleapis.com/syzbot-assets/70526f6a5c28/disk-6c52d4da.raw.xz
> vmlinux: https://storage.googleapis.com/syzbot-assets/8ca3cd20d331/vmlinux-6c52d4da.xz
> kernel image: https://storage.googleapis.com/syzbot-assets/9c4393fc9a08/bzImage-6c52d4da.xz
> 
> IMPORTANT: if you fix the issue, please add the following tag to the commit:
> Reported-by: syzbot+e929093395ec65f969c7@syzkaller.appspotmail.com
> 
> ======================================================
> WARNING: possible circular locking dependency detected
> 6.12.0-rc5-syzkaller-00181-g6c52d4da1c74 #0 Not tainted
> ------------------------------------------------------
> syz-executor158/5839 is trying to acquire lock:
> ffffffff8fcd3448 (rtnl_mutex){+.+.}-{3:3}, at: start_sync_thread+0xdc/0x2dc0 net/netfilter/ipvs/ip_vs_sync.c:1761
> 
> but task is already holding lock:
> ffff888034ac8aa8 (&smc->clcsock_release_lock){+.+.}-{3:3}, at: smc_setsockopt+0x1c3/0xe50 net/smc/af_smc.c:3056
> 
> which lock already depends on the new lock.
> 
> 
> the existing dependency chain (in reverse order) is:
> 
> -> #2 (&smc->clcsock_release_lock){+.+.}-{3:3}:
>        lock_acquire+0x1ed/0x550 kernel/locking/lockdep.c:5825
>        __mutex_lock_common kernel/locking/mutex.c:608 [inline]
>        __mutex_lock+0x136/0xd70 kernel/locking/mutex.c:752
>        smc_switch_to_fallback+0x35/0xdb0 net/smc/af_smc.c:902
>        smc_sendmsg+0x11f/0x530 net/smc/af_smc.c:2771
>        sock_sendmsg_nosec net/socket.c:729 [inline]
>        __sock_sendmsg+0x221/0x270 net/socket.c:744
>        __sys_sendto+0x39b/0x4f0 net/socket.c:2214
>        __do_sys_sendto net/socket.c:2226 [inline]
>        __se_sys_sendto net/socket.c:2222 [inline]
>        __x64_sys_sendto+0xde/0x100 net/socket.c:2222
>        do_syscall_x64 arch/x86/entry/common.c:52 [inline]
>        do_syscall_64+0xf3/0x230 arch/x86/entry/common.c:83
>        entry_SYSCALL_64_after_hwframe+0x77/0x7f
> 
> -> #1 (sk_lock-AF_INET){+.+.}-{0:0}:
>        lock_acquire+0x1ed/0x550 kernel/locking/lockdep.c:5825
>        lock_sock_nested+0x48/0x100 net/core/sock.c:3611
>        do_ip_setsockopt+0x1a2d/0x3cd0 net/ipv4/ip_sockglue.c:1078
>        ip_setsockopt+0x63/0x100 net/ipv4/ip_sockglue.c:1417
>        do_sock_setsockopt+0x3af/0x720 net/socket.c:2334
>        __sys_setsockopt+0x1a2/0x250 net/socket.c:2357
>        __do_sys_setsockopt net/socket.c:2366 [inline]
>        __se_sys_setsockopt net/socket.c:2363 [inline]
>        __x64_sys_setsockopt+0xb5/0xd0 net/socket.c:2363
>        do_syscall_x64 arch/x86/entry/common.c:52 [inline]
>        do_syscall_64+0xf3/0x230 arch/x86/entry/common.c:83
>        entry_SYSCALL_64_after_hwframe+0x77/0x7f
> 
> -> #0 (rtnl_mutex){+.+.}-{3:3}:
>        check_prev_add kernel/locking/lockdep.c:3161 [inline]
>        check_prevs_add kernel/locking/lockdep.c:3280 [inline]
>        validate_chain+0x18ef/0x5920 kernel/locking/lockdep.c:3904
>        __lock_acquire+0x1384/0x2050 kernel/locking/lockdep.c:5202
>        lock_acquire+0x1ed/0x550 kernel/locking/lockdep.c:5825
>        __mutex_lock_common kernel/locking/mutex.c:608 [inline]
>        __mutex_lock+0x136/0xd70 kernel/locking/mutex.c:752
>        start_sync_thread+0xdc/0x2dc0 net/netfilter/ipvs/ip_vs_sync.c:1761
>        do_ip_vs_set_ctl+0x442/0x13d0 net/netfilter/ipvs/ip_vs_ctl.c:2732
>        nf_setsockopt+0x295/0x2c0 net/netfilter/nf_sockopt.c:101
>        smc_setsockopt+0x275/0xe50 net/smc/af_smc.c:3064
>        do_sock_setsockopt+0x3af/0x720 net/socket.c:2334
>        __sys_setsockopt+0x1a2/0x250 net/socket.c:2357
>        __do_sys_setsockopt net/socket.c:2366 [inline]
>        __se_sys_setsockopt net/socket.c:2363 [inline]
>        __x64_sys_setsockopt+0xb5/0xd0 net/socket.c:2363
>        do_syscall_x64 arch/x86/entry/common.c:52 [inline]
>        do_syscall_64+0xf3/0x230 arch/x86/entry/common.c:83
>        entry_SYSCALL_64_after_hwframe+0x77/0x7f
> 
> other info that might help us debug this:
> 
> Chain exists of:
>   rtnl_mutex --> sk_lock-AF_INET --> &smc->clcsock_release_lock
> 
>  Possible unsafe locking scenario:
> 
>        CPU0                    CPU1
>        ----                    ----
>   lock(&smc->clcsock_release_lock);
>                                lock(sk_lock-AF_INET);
>                                lock(&smc->clcsock_release_lock);
>   lock(rtnl_mutex);
> 
>  *** DEADLOCK ***
> 
> 1 lock held by syz-executor158/5839:
>  #0: ffff888034ac8aa8 (&smc->clcsock_release_lock){+.+.}-{3:3}, at: smc_setsockopt+0x1c3/0xe50 net/smc/af_smc.c:3056
> 
> stack backtrace:
> CPU: 0 UID: 0 PID: 5839 Comm: syz-executor158 Not tainted 6.12.0-rc5-syzkaller-00181-g6c52d4da1c74 #0
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 09/13/2024
> Call Trace:
>  <TASK>
>  __dump_stack lib/dump_stack.c:94 [inline]
>  dump_stack_lvl+0x241/0x360 lib/dump_stack.c:120
>  print_circular_bug+0x13a/0x1b0 kernel/locking/lockdep.c:2074
>  check_noncircular+0x36a/0x4a0 kernel/locking/lockdep.c:2206
>  check_prev_add kernel/locking/lockdep.c:3161 [inline]
>  check_prevs_add kernel/locking/lockdep.c:3280 [inline]
>  validate_chain+0x18ef/0x5920 kernel/locking/lockdep.c:3904
>  __lock_acquire+0x1384/0x2050 kernel/locking/lockdep.c:5202
>  lock_acquire+0x1ed/0x550 kernel/locking/lockdep.c:5825
>  __mutex_lock_common kernel/locking/mutex.c:608 [inline]
>  __mutex_lock+0x136/0xd70 kernel/locking/mutex.c:752
>  start_sync_thread+0xdc/0x2dc0 net/netfilter/ipvs/ip_vs_sync.c:1761
>  do_ip_vs_set_ctl+0x442/0x13d0 net/netfilter/ipvs/ip_vs_ctl.c:2732
>  nf_setsockopt+0x295/0x2c0 net/netfilter/nf_sockopt.c:101
>  smc_setsockopt+0x275/0xe50 net/smc/af_smc.c:3064
>  do_sock_setsockopt+0x3af/0x720 net/socket.c:2334
>  __sys_setsockopt+0x1a2/0x250 net/socket.c:2357
>  __do_sys_setsockopt net/socket.c:2366 [inline]
>  __se_sys_setsockopt net/socket.c:2363 [inline]
>  __x64_sys_setsockopt+0xb5/0xd0 net/socket.c:2363
>  do_syscall_x64 arch/x86/entry/common.c:52 [inline]
>  do_syscall_64+0xf3/0x230 arch/x86/entry/common.c:83
>  entry_SYSCALL_64_after_hwframe+0x77/0x7f
> RIP: 0033:0x7f468bc1c369
> Code: 48 83 c4 28 c3 e8 37 17 00 00 0f 1f 80 00 00 00 00 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 c7 c1 b8 ff ff ff f7 d8 64 89 01 48
> RSP: 002b:00007ffe79331b18 EFLAGS: 00000246 ORIG_RAX: 0000000000000036
> RAX: ffffffffffffffda RBX: 00007ffe79331ce8 RCX: 00007f468bc1c369
> RDX: 000000000000048b RSI: 0000000000000000 RDI: 0000000000000005
> RBP: 00007f468bc8f610 R08: 0000000000000018 R09: 00007ffe79331ce8
> R10: 0000000020000000 R11: 0000000000000246 R12: 0000000000000001
> R13: 00007ffe79331cd8 R14: 0000000000000001 R15: 0000000000000001
>  </TASK>
> IPVS: Unkn
> 
> 
> ---
> If you want syzbot to run the reproducer, reply with:
> #syz test: git://repo/address.git branch-or-commit-hash
> If you attach or paste a git patch, syzbot will apply it before testing.
