Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F4093320F;
	Fri,  2 May 2025 22:16:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1746224174; cv=none; b=deOXzUcsRk3SsNlV/KZOkD28gESqhNILEVexQKKpkzs+vZxyrPyH5QKWorwdTy2CEJ7ntBtJt6CfhKJ1rnrbxlFSnTZli1XVvZV3mEVBuZaliC/5AdEfHgbyCkiVrabH1KosoTsiXiXGxkNxQ7me9IEZ8HBiLTnwJOiK5mdphAA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1746224174; c=relaxed/simple;
	bh=YbIgEoWZ+RDbdv/qNR2kvQ/QsB+i63R4L9kxQgvqDSI=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=DE915aOylP9eC97bBwVSdB52JPqcUgpLKvHPwb/6sVHhgbKPAew1Ep4rW1DPDXrgEXwAYtLqbodNToXDma0hzUp4TchCDZEoNW3zM6iKYPSPmHc/GdgdSJh7Pnea5Cc5cjTPJk+VUGbWKYwzd/VLRqhpm3YOs/lm8V3Jy+tbe+c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=emae7WEZ; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="emae7WEZ"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id E1DB520196;
	Sat,  3 May 2025 01:16:05 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=GV5jrpCeKAbrT1H1amlypy3VO6Qao+dT06uekrv1lr4=; b=emae7WEZg8jY
	mX2N3BEU26n9sa4PtsCMXAhoUO0syALZlDBibW4Ownage8AkLcA1t2iY/52bR9eX
	6Bzs08CwTYT6P89xZ0yoBQCl+5IKtIt/vF0uvmF+y+EKQ7Hd+GSYy4mPHfqxpx+3
	Da3XIUMdp6/Vefu5lQTwWMWw0/5k+rrLTuXz0M/7LH74SUot/+r8Xq6Pw9lx+MOH
	LVn4hBys+yNfnDw6dmuMRpIwWHe83W8WkqdqK0Ww4ppD1zgF4+sTjatc4DZxxJSX
	rzJ23L5trl1j7shaqZyXcUNNCJuyof2SZM8RrNP5QnWjSdEWIBewSVFfVZimoXVb
	8p83XEgAmz+8OJk5Zp6Hv9goUE036ApOxHYMm5OQM73fKYS8fN5DYcfDr+TjpbrX
	DVxF4a22QYIuIQY9eCJcsrJsJsRvginLheo+LCsf/iHlxZ3itaauN+A0OBxZceym
	i3YWx5EMXnuCPzKRtE3zCdtvkbfazAerRlHqItbMKNy9lEQA8IMxS3W8/vTguosw
	qDNgg6he5+O4toKPRAbI/WCpkr4iYxAYkWa/tmKr6YVyl6g28RkFT2A6GhaLOds1
	kpLn13qHjJsfylMMwJsr7xTvBuibXs0TxetmmTJfLRCCigVOuxr2aywQYLMzVEN0
	fW8dQ6YxF79qV/mr+rI6PPpYoAb76Zg=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat,  3 May 2025 01:16:04 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 3600961BC1;
	Sat,  3 May 2025 01:16:03 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.17.1) with ESMTP id 542MFvKL069117;
	Sat, 3 May 2025 01:15:58 +0300
Date: Sat, 3 May 2025 01:15:57 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: syzbot <syzbot+04b9a82855c8aed20860@syzkaller.appspotmail.com>
cc: coreteam@netfilter.org, davem@davemloft.net, edumazet@google.com,
        horms@verge.net.au, kadlec@netfilter.org, kuba@kernel.org,
        linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org,
        netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
        pabeni@redhat.com, pablo@netfilter.org,
        syzkaller-bugs@googlegroups.com
Subject: Re: [syzbot] [lvs?] KMSAN: uninit-value in do_output_route4
In-Reply-To: <68138dfa.050a0220.14dd7d.0017.GAE@google.com>
Message-ID: <70eb95f5-6fe9-1905-70b7-709eacd48b19@ssi.bg>
References: <68138dfa.050a0220.14dd7d.0017.GAE@google.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Thu, 1 May 2025, syzbot wrote:

> Hello,
> 
> syzbot found the following issue on:
> 
> HEAD commit:    bc3372351d0c Merge tag 'for-6.15-rc3-tag' of git://git.ker..
> git tree:       upstream
> console output: https://syzkaller.appspot.com/x/log.txt?x=12d64574580000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=fca45111586bf9a6
> dashboard link: https://syzkaller.appspot.com/bug?extid=04b9a82855c8aed20860
> compiler:       Debian clang version 15.0.6, Debian LLD 15.0.6
> userspace arch: i386
> 
> Unfortunately, I don't have any reproducer for this issue yet.
> 
> Downloadable assets:
> disk image: https://storage.googleapis.com/syzbot-assets/01b8968610a1/disk-bc337235.raw.xz
> vmlinux: https://storage.googleapis.com/syzbot-assets/528a97652269/vmlinux-bc337235.xz
> kernel image: https://storage.googleapis.com/syzbot-assets/768ed51bbb66/bzImage-bc337235.xz
> 
> IMPORTANT: if you fix the issue, please add the following tag to the commit:
> Reported-by: syzbot+04b9a82855c8aed20860@syzkaller.appspotmail.com
> 
> =====================================================
> BUG: KMSAN: uninit-value in do_output_route4+0x42c/0x4d0 net/netfilter/ipvs/ip_vs_xmit.c:147
>  do_output_route4+0x42c/0x4d0 net/netfilter/ipvs/ip_vs_xmit.c:147
>  __ip_vs_get_out_rt+0x403/0x21d0 net/netfilter/ipvs/ip_vs_xmit.c:330
>  ip_vs_tunnel_xmit+0x205/0x2380 net/netfilter/ipvs/ip_vs_xmit.c:1136
>  ip_vs_in_hook+0x1aa5/0x35b0 net/netfilter/ipvs/ip_vs_core.c:2063
>  nf_hook_entry_hookfn include/linux/netfilter.h:154 [inline]
>  nf_hook_slow+0xf7/0x400 net/netfilter/core.c:626
>  nf_hook include/linux/netfilter.h:269 [inline]
>  __ip_local_out+0x758/0x7e0 net/ipv4/ip_output.c:118
>  ip_local_out net/ipv4/ip_output.c:127 [inline]
>  ip_send_skb+0x6a/0x3c0 net/ipv4/ip_output.c:1501
>  udp_send_skb+0xfda/0x1b70 net/ipv4/udp.c:1195
>  udp_sendmsg+0x2fe3/0x33c0 net/ipv4/udp.c:1483
>  inet_sendmsg+0x1fc/0x280 net/ipv4/af_inet.c:851
>  sock_sendmsg_nosec net/socket.c:712 [inline]
>  __sock_sendmsg+0x267/0x380 net/socket.c:727
>  ____sys_sendmsg+0x91b/0xda0 net/socket.c:2566
>  ___sys_sendmsg+0x28d/0x3c0 net/socket.c:2620
>  __sys_sendmmsg+0x41d/0x880 net/socket.c:2702
>  __compat_sys_sendmmsg net/compat.c:360 [inline]
>  __do_compat_sys_sendmmsg net/compat.c:367 [inline]
>  __se_compat_sys_sendmmsg net/compat.c:364 [inline]
>  __ia32_compat_sys_sendmmsg+0xc8/0x140 net/compat.c:364
>  ia32_sys_call+0x3ffa/0x41f0 arch/x86/include/generated/asm/syscalls_32.h:346
>  do_syscall_32_irqs_on arch/x86/entry/syscall_32.c:83 [inline]
>  __do_fast_syscall_32+0xb0/0x110 arch/x86/entry/syscall_32.c:306
>  do_fast_syscall_32+0x38/0x80 arch/x86/entry/syscall_32.c:331
>  do_SYSENTER_32+0x1f/0x30 arch/x86/entry/syscall_32.c:369
>  entry_SYSENTER_compat_after_hwframe+0x84/0x8e
> 
> Uninit was created at:
>  slab_post_alloc_hook mm/slub.c:4167 [inline]
>  slab_alloc_node mm/slub.c:4210 [inline]
>  __kmalloc_cache_noprof+0x8fa/0xe00 mm/slub.c:4367
>  kmalloc_noprof include/linux/slab.h:905 [inline]
>  ip_vs_dest_dst_alloc net/netfilter/ipvs/ip_vs_xmit.c:61 [inline]
>  __ip_vs_get_out_rt+0x35d/0x21d0 net/netfilter/ipvs/ip_vs_xmit.c:323
>  ip_vs_tunnel_xmit+0x205/0x2380 net/netfilter/ipvs/ip_vs_xmit.c:1136
>  ip_vs_in_hook+0x1aa5/0x35b0 net/netfilter/ipvs/ip_vs_core.c:2063
>  nf_hook_entry_hookfn include/linux/netfilter.h:154 [inline]
>  nf_hook_slow+0xf7/0x400 net/netfilter/core.c:626
>  nf_hook include/linux/netfilter.h:269 [inline]
>  __ip_local_out+0x758/0x7e0 net/ipv4/ip_output.c:118
>  ip_local_out net/ipv4/ip_output.c:127 [inline]
>  ip_send_skb+0x6a/0x3c0 net/ipv4/ip_output.c:1501
>  udp_send_skb+0xfda/0x1b70 net/ipv4/udp.c:1195
>  udp_sendmsg+0x2fe3/0x33c0 net/ipv4/udp.c:1483
>  inet_sendmsg+0x1fc/0x280 net/ipv4/af_inet.c:851
>  sock_sendmsg_nosec net/socket.c:712 [inline]
>  __sock_sendmsg+0x267/0x380 net/socket.c:727
>  ____sys_sendmsg+0x91b/0xda0 net/socket.c:2566
>  ___sys_sendmsg+0x28d/0x3c0 net/socket.c:2620
>  __sys_sendmmsg+0x41d/0x880 net/socket.c:2702
>  __compat_sys_sendmmsg net/compat.c:360 [inline]
>  __do_compat_sys_sendmmsg net/compat.c:367 [inline]
>  __se_compat_sys_sendmmsg net/compat.c:364 [inline]
>  __ia32_compat_sys_sendmmsg+0xc8/0x140 net/compat.c:364
>  ia32_sys_call+0x3ffa/0x41f0 arch/x86/include/generated/asm/syscalls_32.h:346
>  do_syscall_32_irqs_on arch/x86/entry/syscall_32.c:83 [inline]
>  __do_fast_syscall_32+0xb0/0x110 arch/x86/entry/syscall_32.c:306
>  do_fast_syscall_32+0x38/0x80 arch/x86/entry/syscall_32.c:331
>  do_SYSENTER_32+0x1f/0x30 arch/x86/entry/syscall_32.c:369
>  entry_SYSENTER_compat_after_hwframe+0x84/0x8e
> 
> CPU: 0 UID: 0 PID: 22408 Comm: syz.4.5165 Not tainted 6.15.0-rc3-syzkaller-00019-gbc3372351d0c #0 PREEMPT(undef) 
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 02/12/2025
> =====================================================

	I hopefully addressed this report with patch titled
"ipvs: fix uninit-value for saddr in do_output_route4".

Regards

--
Julian Anastasov <ja@ssi.bg>

