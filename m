Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 255F825C6EA;
	Tue,  6 May 2025 17:20:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1746552050; cv=none; b=QLNoHQpX845afLQuOosleWYfKqJNkGhph1gA2IRaK++VOYZeHt7TU6hADj/GFog9R7HsXNLIXxiz31shqIxTufLs4q+9DxiicLmJG4wn6k7XiEpo03HOyEkvvdZynVSZ7OWje3ty6QYvSafCiW/cgmLlgsoYWyOUQQ0rOYQ6lHs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1746552050; c=relaxed/simple;
	bh=Jrl24qKIrJcrTt9cLE88QccwkTInmMzCHE8X6UhcXG8=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=lzghjQNPeRaHERvfJESmNhIIyRmdfGOYOQIKmgu69K2yD1333O88Th3xdCjN59IPTls548GZ6pFLtxOzunWeErGo+yyBcByNY27j5Z3wteG9QStcpRqv8jxN3Fwa1RPrfqCQ6i4Yo7NqCGbeWb6CBLRzRcRGelvYkknqjY/6/Gw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KKaXvcIP; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KKaXvcIP"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 02907C4CEE4;
	Tue,  6 May 2025 17:20:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1746552050;
	bh=Jrl24qKIrJcrTt9cLE88QccwkTInmMzCHE8X6UhcXG8=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=KKaXvcIP8WnYVbGMkEgX543fbXo8iiZ/bSzVhgvCnQgCBO4yJmJxo3EJHmZ0LlOWR
	 4o+qBof/HmYLlC3qCrg3D8QfL97n0a00hwMulg6mA/twsT64bXgeCoUfvcxZ5NteCk
	 M/v+W5LnS+TYF5URhXUje0VFlbiieeEBgutOwAk3oT71zW4o6uLKYIAsSdjVuPTS9H
	 CCc1vPJkmJbhhEqR31mTJiM6GVR96m0fLxsB9WxM+nY4b9sKeDb9afG+aVs+vENXyp
	 325+ERFRWGqm9QZKc/w3hSCf/Lhi2nDIoHzzXgKMxBeWymiwUNu1k9CcHlOsHvbC9z
	 jAb80j6IyPcxQ==
Date: Tue, 6 May 2025 18:20:46 +0100
From: Simon Horman <horms@kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org
Subject: Re: [PATCH nf] ipvs: fix uninit-value for saddr in do_output_route4
Message-ID: <20250506172046.GX3339421@horms.kernel.org>
References: <20250502220118.68234-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20250502220118.68234-1-ja@ssi.bg>

On Sat, May 03, 2025 at 01:01:18AM +0300, Julian Anastasov wrote:
> syzbot reports for uninit-value for the saddr argument [1].
> commit 4754957f04f5 ("ipvs: do not use random local source address for
> tunnels") already implies that the input value of saddr
> should be ignored but the code is still reading it which can prevent
> to connect the route. Fix it by changing the argument to ret_saddr.
> 
> [1]
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
> 
> Reported-by: syzbot+04b9a82855c8aed20860@syzkaller.appspotmail.com
> Closes: https://lore.kernel.org/netdev/68138dfa.050a0220.14dd7d.0017.GAE@google.com/
> Fixes: 4754957f04f5 ("ipvs: do not use random local source address for tunnels")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Acked-by: Simon Horman <horms@kernel.org>


