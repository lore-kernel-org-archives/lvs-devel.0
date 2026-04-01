Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 75D8233263A;
	Wed,  1 Apr 2026 06:39:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775025556; cv=none; b=k40gH9SEkLZOj2wsa2jkATbMnN1rsrUTfvNR6KARcD4vgwbgZ811OdVlhYme/UJfesx2UXfCwTwV7G3xglBFljbezxpThzDkDIhTgZIlpB1Yz8BAqOFwDtVGjOpyl6BZ/32ixYpE7IqTbFrlwjL8Xlp7Ju53/UUTFP3srJJAVwE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775025556; c=relaxed/simple;
	bh=J1rh6Z8uKOL6Ovp78qgOAnceKk0H/6gUsiwkLa7iRB0=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=jLUj/jNMi13md0iwh2eNopYLerNcCtfNYeJKI6Ee8YapZdD9oD5aJljToxPVjklMEwf9ufbvV1Y8P7QFp/ter7ncEj+dRn/7Ap3WItVzc6Q0UZPOdpJxyi6eMKT4HbIuoFQ3beDC4bDSA2UQpdDCCNzVjJHYjp5y+tkdY3l27ks=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=RnoGDCie; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="RnoGDCie"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 49B2C21C4C;
	Wed, 01 Apr 2026 09:39:00 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=ulQKfyzZTDVBx3LYjMgDeLrn+Tv6/SadMQfGCiS17S8=; b=RnoGDCieHuh6
	x69hMUXiW+7Pps5w0WqJqRc67q8u0R2mxVIEVda4M2AXw2GeG3wYQiN9yE5HYiWP
	7OM2agh8LSP1pk2pYN4SCF68s0XCXWBJpiq2YE7SnGAqZo/JXxrzzTqHRwgOUD4m
	ihoZNbQqNf7+yp8BZa0JxpMjQscDG0V60dG+fOZLB0+UXRh/eM3r5Na3AVS7kNGR
	f+jRIcl338BXPwJlYFiRTJ2/kWJwkdc3j+zap+mM5CNzc8fJRV55vu6jN7bc4XKv
	xLxmI/alyEjWO4tVA2ADvtO7gAHLD2Baj79BiJErrY7A5szhqmXI8Zs0LgIcjk8N
	uEBqFQAh0TjjpCjZZ9TdVmsHA3SA6GEj8N0KHpJXUhqz1+k/fBp/jyqZd1FivuFc
	j479VMSFZLdpTK+KV2r0KhyxnR7TL0eBS21/E8M8iniDP1Hd9a8qCDDCvVFme7GR
	Q9ZWszVxXyN4H8m/jE2mWydljlSJpzI6wTWN/UMV0UqlrsG/8ufyEWnAiva6Wj4O
	WtM2Z3rCCaPCkyLze3R1R8Y4qZKcXxU3uvH9vR4+m99Bzm2pDOPqc1JnCaRmsfDG
	/xQ9CsXXWZGM6hXTdYqi3IB/N7OtTmQcNVuSzItep5YFJlQTfFN9GOyy1jme825L
	KfTCC7lF29lP/2r/6pv1yGeVTbVug38=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 01 Apr 2026 09:38:59 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id C5D90608EB;
	Wed,  1 Apr 2026 09:38:56 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 6316cqk0007681;
	Wed, 1 Apr 2026 09:38:52 +0300
Date: Wed, 1 Apr 2026 09:38:52 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Weiming Shi <bestswngs@gmail.com>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>, Phil Sutter <phil@nwl.cc>,
        netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        Xiang Mei <xmei5@asu.edu>
Subject: Re: [PATCH net] ipvs: fix NULL deref in ip_vs_add_service error
 path
In-Reply-To: <20260401041611.3302189-2-bestswngs@gmail.com>
Message-ID: <55c32c6e-8126-8a85-9ddb-1ecebedf2b67@ssi.bg>
References: <20260401041611.3302189-2-bestswngs@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Wed, 1 Apr 2026, Weiming Shi wrote:

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
> Fix by recovering the scheduler pointer from svc->scheduler before
> cleanup when the local sched variable has been cleared.  This also
> prevents a latent module refcount leak: without the recovery,
> ip_vs_scheduler_put(sched) receives NULL and skips the module_put(),
> so the scheduler module could never be unloaded if the kernel survived
> past the dereference.
> 
> Fixes: 05f00505a89a ("ipvs: fix crash if scheduler is changed")
> Reported-by: Xiang Mei <xmei5@asu.edu>
> Signed-off-by: Weiming Shi <bestswngs@gmail.com>
> ---
>  net/netfilter/ipvs/ip_vs_ctl.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 35642de2a0fee..e0c978def9749 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1497,6 +1497,8 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
>  	if (ret_hooks >= 0)
>  		ip_vs_unregister_hooks(ipvs, u->af);
>  	if (svc != NULL) {
> +		if (!sched)
> +			sched = rcu_dereference_protected(svc->scheduler, 1);

	Good catch. But may be it should be enough if
we just remove the sched = NULL after successful
ip_vs_bind_scheduler(), what do you think? ip_vs_unbind_scheduler()
already detects if the scheduler is installed.

>  		ip_vs_unbind_scheduler(svc, sched);
>  		ip_vs_service_free(svc);

Regards

--
Julian Anastasov <ja@ssi.bg>

