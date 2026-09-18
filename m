Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DA5FF519E0B;
	Fri, 18 Sep 2026 16:50:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789750217; cv=none; b=NmwnvC0hsMM9bYCsHbC90NXarakAdRccjFdXOus3g+L64FCp0hq3ifETayuq95j09hVXizvGHa646YK+NTN7oLNfZLc7JHJKlZhmir+LRJHZkqt4mw3OKeawJ25Dg1Waah9c8IczYMzbdDwW8OYleKCRb0e5bJeNX0ZYZXEDHH0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789750217; c=relaxed/simple;
	bh=G3uymknwnCUX6QlaDxhK9oRLkJMvsnDoCJ+9BL3HgBc=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=Je91uI4jdQrfTm8aSxfDtbEvEy3DYDps59BVzHCbbWkL20yNU4vY0gfem9RxWBqFwCG8IumxaquJCWesCWX5cn23GEngzYVaSFH7GiKtEu2sqUuUTCIFURHuKrGo4RNLtTfgCnuESunUW1oq+PJwBlIYTp3NTnR9YhoULIY/iOk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=0kpGbTwT; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="0kpGbTwT"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 9A979213A3;
	Fri, 18 Sep 2026 19:50:02 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=XW/GAKietqt6MAAjngo9iNxQ26sGvvnaGq/MzOwjy64=; b=0kpGbTwTLzoF
	G/VpevEwIZnN+W+s2AP1UGCDd+D9zAILtscAfwRr2W2/o/N3azcrPSJl/SOcZUz8
	gug/RrPgmnAI69Ihq78wKFdjv9YVvA+K7YMrebNLik0XlEZ3mWg7CbNrP4/Qhxlk
	p7Aq4wvjwavAG9Crafwve52HL32GPvWBGbVEjkIjdSrPgmYVaAfg100XFLnbgows
	OLquGCdVuYcd7MfBokXw/OU1fPYQrCp9fJ928kFfnJ2YUjfwq8uhVUdOyPTciCqB
	2pY4iFX0Zj+b+Mz02wkT69VrD2t1UCn+iCp6KByAWZOLpS4lZg5TVvn+rOuZi95Y
	Bn/60W7zkGMOjtPym3f2taKZClh4m7MWpvRCB4t7SDUB/ipV5NDHDMN1M9FPd/KR
	/+5484b2ujbAYtAhrpG9MyX3Hmi3UaINNlq2GMhDoIicKSA037dPQ2W852moyHeb
	1/kBcV9UsZ4UlEUWiedii73Own+Pzlma/r0GUYM3U7Gsd76XdibbTRotHfKekmIR
	fQSfeweVzmn6W76Wd6DJHi/mx3K6kkhGEY2bMrPKPp9fJwz/Hvc1AP4+dbyQJgqv
	3GKZIUJ/0W5oXYFz6xIJElgtjZy8dRYfp6UyUCIN6tWOjEjUrugxPkumyfspD7I4
	uzg7yMBafrJYJ9LtJy0bgZXAILejUtg=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri, 18 Sep 2026 19:50:02 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 98F5560B6D;
	Fri, 18 Sep 2026 19:50:04 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68IGnvX8069646;
	Fri, 18 Sep 2026 19:49:59 +0300
Date: Fri, 18 Sep 2026 19:49:57 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Zihan Xi <zihanx@nebusec.ai>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH net v2 1/2] ipvs: avoid stack overflow from recursive
 connection expiration
In-Reply-To: <20260917030301.5502-1-zihanx@nebusec.ai>
Message-ID: <c104a8ee-eebc-1e80-c685-3e22f23ffbc8@ssi.bg>
References: <cover.1789435989.git.zihanx@nebusec.ai> <20260917030301.5502-1-zihanx@nebusec.ai>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Thu, 17 Sep 2026, Zihan Xi wrote:

> When a controlled IPVS connection expires, its controller may be expired
> synchronously if it has no remaining controlled connections. A chain of
> controlled connections can then cause recursive calls to
> ip_vs_conn_expire() and exhaust the kernel stack during namespace cleanup.
> 
> Make ip_vs_conn_del_put() report whether it deleted the controller timer.
> When it succeeds, continue expiration with the controller instead of
> calling ip_vs_conn_expire() recursively. This keeps chain cleanup
> synchronous while using one stack frame for the whole chain.
> 
> Fixes: f9200a52eedf ("ipvs: avoid expiring many connections from timer")
> Cc: stable@vger.kernel.org
> Reported-by: Vega <vega@nebusec.ai>
> Assisted-by: LLM
> Co-developed-by: Luxing Yin <root@tr0jan.top>
> Signed-off-by: Luxing Yin <root@tr0jan.top>
> Signed-off-by: Zihan Xi <zihanx@nebusec.ai>

	Patch looks good to me for the nf tree, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

	Next time use "nf"/"nf-next" tag for the IPVS patches.

> ---
> changes in v2:
>   - Use a repeat path for controller cleanup so expiration stays
>     synchronous without recursive calls or extra timer ticks.
>   - v1 Link:
>     https://lore.kernel.org/all/cover.1789110326.git.zihanx@nebusec.ai/
> 
>  net/netfilter/ipvs/ip_vs_conn.c | 17 ++++++++++++-----
>  1 file changed, 12 insertions(+), 5 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 6fa3e1dc534c3..c7b88ce1765dc 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -1331,17 +1331,18 @@ static void ip_vs_conn_del(struct ip_vs_conn *cp)
>  }
>  
>  /* Try to delete connection while holding reference */
> -static void ip_vs_conn_del_put(struct ip_vs_conn *cp)
> +static bool ip_vs_conn_del_put(struct ip_vs_conn *cp)
>  {
>  	if (timer_delete(&cp->timer)) {
>  		/* Drop cp->control chain too */
>  		if (cp->control)
>  			cp->timeout = 0;
>  		__ip_vs_conn_put(cp);
> -		ip_vs_conn_expire(&cp->timer);
> -	} else {
> -		__ip_vs_conn_put(cp);
> +		return true;
>  	}
> +
> +	__ip_vs_conn_put(cp);
> +	return false;
>  }
>  
>  static void ip_vs_conn_expire(struct timer_list *t)
> @@ -1349,6 +1350,7 @@ static void ip_vs_conn_expire(struct timer_list *t)
>  	struct ip_vs_conn *cp = timer_container_of(cp, t, timer);
>  	struct netns_ipvs *ipvs = cp->ipvs;
>  
> +repeat:
>  	/*
>  	 *	do I control anybody?
>  	 */
> @@ -1358,6 +1360,7 @@ static void ip_vs_conn_expire(struct timer_list *t)
>  	/* Unlink conn if not referenced anymore */
>  	if (likely(ip_vs_conn_unlink(cp))) {
>  		struct ip_vs_conn *ct = cp->control;
> +		bool next = false;
>  
>  		/* delete the timer if it is activated by other users */
>  		timer_delete(&cp->timer);
> @@ -1372,7 +1375,7 @@ static void ip_vs_conn_expire(struct timer_list *t)
>  			    (!(ct->flags & IP_VS_CONN_F_TEMPLATE) ||
>  			     !(ct->state & IP_VS_CTPL_S_ASSURED))) {
>  				IP_VS_DBG(4, "drop controlling connection\n");
> -				ip_vs_conn_del_put(ct);
> +				next = ip_vs_conn_del_put(ct);
>  			} else if (has_ref) {
>  				__ip_vs_conn_put(ct);
>  			}
> @@ -1402,6 +1405,10 @@ static void ip_vs_conn_expire(struct timer_list *t)
>  		else
>  			call_rcu(&cp->rcu_head, ip_vs_conn_rcu_free);
>  		atomic_dec(&ipvs->conn_count);
> +		if (next) {
> +			cp = ct;
> +			goto repeat;
> +		}
>  		return;
>  	}
>  
> -- 
> 2.43.0

Regards

--
Julian Anastasov <ja@ssi.bg>

