Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CADAB280A51;
	Fri,  3 Apr 2026 15:50:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775231436; cv=none; b=JYJXVw1MulzrNtTJkrhpeK1+8Zf+KGqdA8GdKRiFc+Fp7kDEW2WJRmgWRXAO0NCwHwZ6JjJBEgpE6G7xtqqVMt/Qwu7jf9nhPzJl+WJVGodUCnoEb7O83B3k+Zejj9sLTMMkLDNSXMX+5+Z5/Rn01LchHs4e2Z1ODr42migieas=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775231436; c=relaxed/simple;
	bh=LY+xPNa22+WbSd7wyfRtnKVWdGr1NXJcepvxE9ed2Mw=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=NahyTV2BMCpThC9BM3bQxMRlgHD0Ea9zbF5x6KoJPRm/XuKYDOBsnX5Z8FdxiGhByGMDQ83Ge2GOlw2UzF3iOOm6GP9SwCYbt/AlMXmIFt0JrT4EqQVgYE58Cfc/kEMEMpr3mdr0LM7YFv+GVUV0eAKufgiGtklvyAGS0ntv+sE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=m5w1A24B; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="m5w1A24B"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 80A8A21C5B;
	Fri, 03 Apr 2026 18:50:29 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=O18+hfUNzACqcP51D6CnMotQefBBC43pIwM9YBC39KM=; b=m5w1A24BV94q
	elfFe5HTwW8v3Kusd3uKAFltnhN9FZKnir5NZ19XAzsMHYEaCvDt516BchsGJAL5
	OSZwjnoZ5L5bRRJgtQ188OAflXTrQkYoHM9HfH8W+Gs9D8ocYwI2rjityJ9bM/2Q
	5bRf2IZ7Xb43T0bl6HYuDf7vg9tzThpETF2ZbMzm7i68Dsz2xiKY3iEI+3RifDJW
	gnIysI4it4QeLQFoRUKX00adh8C/6TyrBmx9/m8v4TUgxWWFmRWCE8QhpAh45qn9
	6cuCUL16ipdviMS+DD4VRovrAX77YDxwaD1weWEziJdanI202j9RoGYXw5EN0n17
	XOkMrXalW76pCNH2Yeyay1yxnjYhwP/xgYktCfOanMBpRGrg8ztZdJvVZp3d7FYS
	bYrlf2e6d1QGQJtqo6puYuMgaTLviC3UqPVf6sekeF4Yjy7NNv3JuwvIPvmde6CF
	AWwgA+Fo4ucW8UC5qyTWuTjExjJVFExEvcqnMNkn21b+/p7vG79HQ+8eELNORcfv
	2Kk3byKNRFxIWY/b5NYpCNecMOVmJNvVwqmMe5glX5C/zoY9LTjhg40+UtI2k1J4
	PO+Fuu/EoynUugT1YYtpnjtjnhBC3DCTIjaxu7Nwl8O7i38m6QShhVeQNqNvQ/AO
	4/4vtv3g8ZsJwNYaSebin3Ovi14N7l8=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri, 03 Apr 2026 18:50:28 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id DD12660ADE;
	Fri,  3 Apr 2026 18:50:27 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 633FoOTq046122;
	Fri, 3 Apr 2026 18:50:24 +0300
Date: Fri, 3 Apr 2026 18:50:24 +0300 (EEST)
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
Subject: Re: [PATCH net v2] ipvs: fix NULL deref in ip_vs_add_service error
 path
In-Reply-To: <20260401075800.3344266-2-bestswngs@gmail.com>
Message-ID: <733280f5-ce3b-ea65-d9c5-471da6f601b3@ssi.bg>
References: <20260401075800.3344266-2-bestswngs@gmail.com>
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
> Fix by simply not clearing the local sched variable after a successful
> bind.  ip_vs_unbind_scheduler() already detects whether a scheduler is
> installed via svc->scheduler, and keeping sched non-NULL ensures the
> error path passes the correct pointer to both ip_vs_unbind_scheduler()
> and ip_vs_scheduler_put().
> 
> Fixes: 05f00505a89a ("ipvs: fix crash if scheduler is changed")
> Reported-by: Xiang Mei <xmei5@asu.edu>
> Signed-off-by: Weiming Shi <bestswngs@gmail.com>

	Looks good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

	But the problem popups in more recent kernels (6.2, not 4.2),
when the new error path is added after the ip_vs_start_estimator()
call in commit 705dd3444081 ("ipvs: use kthreads for stats estimation").

> ---
> v2: Remove "sched = NULL" instead of recovering it in out_err (Julian)
> 
>  net/netfilter/ipvs/ip_vs_ctl.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 35642de2a0fee..2aaf50f52c8e8 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1452,7 +1452,6 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
>  		ret = ip_vs_bind_scheduler(svc, sched);
>  		if (ret)
>  			goto out_err;
> -		sched = NULL;
>  	}
>  
>  	ret = ip_vs_start_estimator(ipvs, &svc->stats);
> -- 
> 2.43.0

Regards

--
Julian Anastasov <ja@ssi.bg>

