Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E98FC34D3B2;
	Fri,  3 Apr 2026 15:09:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775228987; cv=none; b=Fr/3LLTZtza9zIe0ubbxSwFBKygCHgXypKUQTOnAc96gfTYL6cEwVW12FetmS3IajOQNhG6JqMBjO/WlZfpi6QeLrg4zcpuhG/GA/EmqPRXNLdX/R2g8OmdEHw+wbIQvzw2j9Kw0/qaH9ebYaUVUKB2rHoGck9R8JPBFbG1FinU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775228987; c=relaxed/simple;
	bh=dzw39lTHOtbmWCTxz7JcXvT0Hqgw0nWp17MXJ0dRIbg=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=oSRflbnKmm3uIOsSgebAInbn3tOKs8OCxz05kY6sAAUUhKZdvtqBAjiGYnSELoG/xfnXuZx2g7R+U6s/xK9DcGjk+z3HZ0qbtShFP6qaeiOXnY1EnyBDbAlb49mDTxIQti3D3P8pIJmukhkgXzD77KRl4vK3c4Re2vC9l2mq5cA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mIEKPtK3; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mIEKPtK3"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 04AA4C2BCAF;
	Fri,  3 Apr 2026 15:09:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1775228986;
	bh=dzw39lTHOtbmWCTxz7JcXvT0Hqgw0nWp17MXJ0dRIbg=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=mIEKPtK31JGGZt8EQzXoTc4oZzV0Yi935aoVir3YEjx0RQBqkRWLTYXO8QcaX2wMN
	 I46ND0ihvBBWVUgJIreALPPtc1Tx2MBkYkY47Pb0n+AQNPZSRZvuHTIiFgtW7c7TYB
	 jZa5Dd5z92a4hIlyNff6pv3cnUA/hmJJL2fA8VUJcpEIMbQ05RrB2O0X77w0wiN40B
	 jkb51AixPgUgQPBqKW4sPLcfCAq9E1T0fEtddJjl885JTv7/3gf1u6PP/sNrYzN7ln
	 HqZwJO1Hno/s+jK0tWBm3HcXyR1jJfLdK4upu6tgoBojc8wBjbW8//2UbMy61gxV9o
	 3W6URSkw/rFKQ==
Date: Fri, 3 Apr 2026 16:09:41 +0100
From: Simon Horman <horms@kernel.org>
To: Weiming Shi <bestswngs@gmail.com>
Cc: Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	"David S . Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, Xiang Mei <xmei5@asu.edu>
Subject: Re: [PATCH net v2] ipvs: fix NULL deref in ip_vs_add_service error
 path
Message-ID: <20260403150941.GI113102@horms.kernel.org>
References: <20260401075800.3344266-2-bestswngs@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260401075800.3344266-2-bestswngs@gmail.com>

On Wed, Apr 01, 2026 at 03:58:01PM +0800, Weiming Shi wrote:
> When ip_vs_bind_scheduler() succeeds in ip_vs_add_service(), the local
> variable sched is set to NULL.  If ip_vs_start_estimator() subsequently
> fails, the out_err cleanup calls ip_vs_unbind_scheduler(svc, sched)
> with sched == NULL.  ip_vs_unbind_scheduler() passes the cur_sched NULL
> check (because svc->scheduler was set by the successful bind) but then
> dereferences the NULL sched parameter at sched->done_service, causing a
> kernel panic at offset 0x30 from NULL.
> 
>  Oops: general protection fault, probably for non-canonical address 0xdffffc0000000006: 0000 [#1] PREEMPT SMP KASAN NOPTI
>  KASAN: null-ptr-deref in range [0x0000000000000030-0x0000000000000037]
>  RIP: 0010:ip_vs_unbind_scheduler (net/netfilter/ipvs/ip_vs_sched.c:69)
>  Call Trace:
>   <TASK>
>   ip_vs_add_service.isra.0 (net/netfilter/ipvs/ip_vs_ctl.c:1500)
>   do_ip_vs_set_ctl (net/netfilter/ipvs/ip_vs_ctl.c:2809)
>   nf_setsockopt (net/netfilter/nf_sockopt.c:102)
>   ip_setsockopt (net/ipv4/ip_sockglue.c:1427)
>   raw_setsockopt (net/ipv4/raw.c:850)
>   do_sock_setsockopt (net/socket.c:2322)
>   __sys_setsockopt (net/socket.c:2339)
>   __x64_sys_setsockopt (net/socket.c:2350)
>   do_syscall_64 (arch/x86/entry/syscall_64.c:94)
>   entry_SYSCALL_64_after_hwframe (arch/x86/entry/entry_64.S:130)
>   </TASK>
> 
> Fix by simply not clearing the local sched variable after a successful
> bind.  ip_vs_unbind_scheduler() already detects whether a scheduler is
> installed via svc->scheduler, and keeping sched non-NULL ensures the
> error path passes the correct pointer to both ip_vs_unbind_scheduler()
> and ip_vs_scheduler_put().
> 
> Fixes: 05f00505a89a ("ipvs: fix crash if scheduler is changed")
> Reported-by: Xiang Mei <xmei5@asu.edu>
> Signed-off-by: Weiming Shi <bestswngs@gmail.com>

Acked-by: Simon Horman <horms@kernel.org>

