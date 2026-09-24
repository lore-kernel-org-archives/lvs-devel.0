Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 48A6D47ECDF;
	Thu, 24 Sep 2026 12:12:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790251947; cv=none; b=Ic87/js17qAq+UvAm3wfBnW8UBIWnlIJViqqqSQaXPJu9I14ss5sb+zKmqJMWC8eyrb3mR+bHZO1vM6/ppVfbaq4/fzmOrzvkwLitxKeTh1cgIP7kGmpZdsiXcaLhZJ6SNXZUNU8983TcQmaxKdZ6ReJOdAMSxErLM+zh0bkyYI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790251947; c=relaxed/simple;
	bh=vAy2pvXTH6ZIFeMujx6Ru6kRQxkhNMs2yIOwyR+G0/I=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=i3+kE99g0JrxyeXS+qDZRf/wkO8cJ9+LVtk79gT9W+9Bff4y8hqRZ0cqaeyiiXjwygZyP82ptT7SaIMDZ1RCIgaHnbWmyircjBF6BzBPQu//VgxVYzdnT2AEqhFAPa+IpgHNMbCh2XI/IWC6kgbllnKT5JRRR96rtaV6IgjYmN4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=puobdpe8; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="puobdpe8"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 17A15213B3;
	Thu, 24 Sep 2026 15:12:09 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=maFDGWCxqU67IjjROICrZqAghus8taCEGoRg6hRMkns=; b=puobdpe8BwGj
	Lu3/XCVpBKcRE6ldG8n9Owg1jGv+lL22Lbpy17smNonYGEBKwiqqUFZ6teYuQRcs
	BlgeYC9ganRBrjIVICSqiayfDccHP5MDGzCYAaYdsogEDjv3aCAsXhF3OPl0wD4N
	nkuaYVE30caMNFdqKdw89mrnk4oLcU/B0Wlg2UXPGlX/tp5LdF9r5nxqYGoRIHlq
	05vU9fOc7i6L4GxBhlOy2rpqPfq5IBCwcT2Gd/R2vEVCvYZ1CtWHJoG4to2UYFpd
	iZxXlP5hS+VRods6TRyhQyKYVCHUoCrrWBA4ertaHwH4PKvm1HSNJFLVH43u682F
	q8xPaqcRe6uK1c6NnU01s3T4Rex4AEPm2bIyvJ2bIciVYg0l+EaLweXcfLazJSat
	dZJAn4K0aAAcBkiEGm5yf9ZMnZK0lvvU2IFwKLiE0X7WdTQTaPAqybgoVWaCMAcx
	HOQ9RmSHXkvnsP0q5VoytghriPekfJrGeAazZjTYTl1CkiWX5gHrq1Kwa33GEFKA
	ptIfw32PnBz+yjw0Jc0zIPA9+R6MNh3sQbnaYbRAmrasdfIhmCbQbHi8He88WBGN
	nppnTNvVc69I2in5PSb7LIq6qodciPE9OJj7q7FoLFOaSEW5UoP5Me8PDfORCbkM
	yPhMmSr7lmrZIbqSWlTS0j5EaLFYTKM=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 24 Sep 2026 15:12:08 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 3102060507;
	Thu, 24 Sep 2026 15:12:11 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68OCBtMb048998;
	Thu, 24 Sep 2026 15:11:56 +0300
Date: Thu, 24 Sep 2026 15:11:55 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Zihan Xi <zihanx@nebusec.ai>
cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org, horms@verge.net.au, pablo@netfilter.org,
        fw@strlen.de, phil@nwl.cc, davem@davemloft.net, edumazet@google.com,
        kuba@kernel.org, pabeni@redhat.com
Subject: Re: [PATCH nf v4 1/3] ipvs: wait the running timer cb on conn
 deletion
In-Reply-To: <dfc9f33299baa890537aacdc3082c85e1a6eccc9.1790146910.git.zihanx@nebusec.ai>
Message-ID: <5afea8e9-5250-8ee4-e1ea-4e16289f4447@ssi.bg>
References: <cover.1790146910.git.zihanx@nebusec.ai> <dfc9f33299baa890537aacdc3082c85e1a6eccc9.1790146910.git.zihanx@nebusec.ai>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Wed, 23 Sep 2026, Zihan Xi wrote:

> From: Julian Anastasov <ja@ssi.bg>
> 
> Sashiko reports for problem when deleting connections.
> 
> If connection timer expires, its callback can not be
> concurrently running but if connection is deleted
> the callback can be running on another CPU even
> after all references are released. Before now we
> continued with the connection freeing, risking the
> callback to access the deleted connection after it
> is freed. As ip_vs_conn_del*() run under RCU lock
> there is no risk accessing a freed connection by
> concurrent timer callback as Sashiko warns, may
> be only if our timer expires and we try to delete
> the cp->control chain.
> 
> Fix that by failing the ip_vs_conn_unlink() call after
> refcnt is restored to 1 allowing the timer callback
> to be scheduled for new execution which should happen
> after the detected running callback finishes.
> 
> One of two things can happen when we detect the
> running callback:
> 
> 1. the concurrent timer callback can see refcnt 0 and
> do nothing, so we will schedule new timer callback to
> expire the connection after the running one finishes
> 
> 2. the concurrent timer callback can see refcnt 1 and
> to expire the connection as usually, in this case we
> will see refcnt 0 and will do nothing
> 
> Add explicit rcu_read_lock() while deleting the cp->control
> chain to protect from concurrent timer callback for ct to
> expire it before us.
> 
> During such races, try to keep 0 in cp->timeout as it is
> a request for deleting our cp->control chain immediately.
> 
> Link: https://sashiko.dev/#/patchset/cover.1789435989.git.zihanx%40nebusec.ai
> Fixes: f9200a52eedf ("ipvs: avoid expiring many connections from timer")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

	Sashiko reports for refcount problem:

https://sashiko.dev/#/patchset/cover.1790146910.git.zihanx%40nebusec.ai

	Will send new version...

pw-bot: changes-requested

> ---
>  net/netfilter/ipvs/ip_vs_conn.c | 103 +++++++++++++++++---------------
>  1 file changed, 54 insertions(+), 49 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 6fa3e1dc534c3..32cfc02aa2912 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -313,17 +313,34 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
>  /* Try to unlink ip_vs_conn from conn_tab.
>   * returns bool success.
>   */
> -static inline bool ip_vs_conn_unlink(struct ip_vs_conn *cp)
> +static inline bool ip_vs_conn_unlink(struct ip_vs_conn *cp, bool my_cb)
>  {
>  	struct netns_ipvs *ipvs = cp->ipvs;
>  	struct hlist_bl_head *head, *head2;
>  	u32 hash_key, hash_key2;
>  	struct ip_vs_rht *t;
> -	bool ret = false;
>  	bool use2;
>  
> +	if (!refcount_dec_if_one(&cp->refcnt))
> +		return false;
> +
>  	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
> -		return refcount_dec_if_one(&cp->refcnt);
> +		return true;
> +
> +	/* Revalidate after conn is excluded from traffic:
> +	 * - not controlling other conns
> +	 * - no pending/running timer callback
> +	 *
> +	 * And the winner is ...
> +	 */
> +	if (atomic_read(&cp->n_control) ||
> +	    (!timer_delete(&cp->timer) && !my_cb)) {
> +		/* Not me? Give the timer callback another chance, even
> +		 * if one is concurrently running during the conn deletion.
> +		 */
> +		refcount_inc(&cp->refcnt);
> +		return false;
> +	}
>  
>  	rcu_read_lock();
>  	local_bh_disable();
> @@ -337,15 +354,11 @@ static inline bool ip_vs_conn_unlink(struct ip_vs_conn *cp)
>  		      false /* new_hash2 */, &head, &head2);
>  
>  	if (cp->flags & IP_VS_CONN_F_HASHED) {
> -		/* Decrease refcnt and unlink conn only if we are last user */
> -		if (use2 == ip_vs_conn_use_hash2(cp) &&
> -		    refcount_dec_if_one(&cp->refcnt)) {
> -			hlist_bl_del_rcu(&cp->hn0.node);
> -			if (use2)
> -				hlist_bl_del_rcu(&cp->hn1.node);
> -			cp->flags &= ~IP_VS_CONN_F_HASHED;
> -			ret = true;
> -		}
> +		/* Unlink conn as we are the last user */
> +		hlist_bl_del_rcu(&cp->hn0.node);
> +		if (use2)
> +			hlist_bl_del_rcu(&cp->hn1.node);
> +		cp->flags &= ~IP_VS_CONN_F_HASHED;
>  	}
>  
>  	conn_tab_unlock(head, head2);
> @@ -353,7 +366,7 @@ static inline bool ip_vs_conn_unlink(struct ip_vs_conn *cp)
>  	local_bh_enable();
>  	rcu_read_unlock();
>  
> -	return ret;
> +	return true;
>  }
>  
>  
> @@ -1319,34 +1332,29 @@ static void ip_vs_conn_rcu_free(struct rcu_head *head)
>  	kmem_cache_free(ip_vs_conn_cachep, cp);
>  }
>  
> -/* Try to delete connection while not holding reference */
> +/* Try to delete connection while not holding reference.
> + * It can be called concurrently and always under RCU lock.
> + */
>  static void ip_vs_conn_del(struct ip_vs_conn *cp)
>  {
> -	if (timer_delete(&cp->timer)) {
> -		/* Drop cp->control chain too */
> -		if (cp->control)
> -			cp->timeout = 0;
> -		ip_vs_conn_expire(&cp->timer);
> -	}
> -}
> +	struct timer_list *t = (void *)((unsigned long)(&cp->timer) | 1UL);
>  
> -/* Try to delete connection while holding reference */
> -static void ip_vs_conn_del_put(struct ip_vs_conn *cp)
> -{
> -	if (timer_delete(&cp->timer)) {
> -		/* Drop cp->control chain too */
> -		if (cp->control)
> -			cp->timeout = 0;
> -		__ip_vs_conn_put(cp);
> -		ip_vs_conn_expire(&cp->timer);
> -	} else {
> -		__ip_vs_conn_put(cp);
> -	}
> +	/* Drop cp->control chain too */
> +	if (cp->control)
> +		cp->timeout = 0;
> +	ip_vs_conn_expire(t);
>  }
>  
> +/* Connection is removed in the following steps:
> + * - timer expires or connection is deleted
> + * - there should be no more references (n_control>0 and refcnt>1)
> + * - there should be no pending timer or a running timer callback (on deletion)
> + */
>  static void ip_vs_conn_expire(struct timer_list *t)
>  {
> -	struct ip_vs_conn *cp = timer_container_of(cp, t, timer);
> +	bool my_cb = !((unsigned long)t & 1);
> +	struct timer_list *t2 = (void *)((unsigned long)t & ~1UL);
> +	struct ip_vs_conn *cp = timer_container_of(cp, t2, timer);
>  	struct netns_ipvs *ipvs = cp->ipvs;
>  
>  	/*
> @@ -1356,26 +1364,21 @@ static void ip_vs_conn_expire(struct timer_list *t)
>  		goto expire_later;
>  
>  	/* Unlink conn if not referenced anymore */
> -	if (likely(ip_vs_conn_unlink(cp))) {
> +	if (likely(ip_vs_conn_unlink(cp, my_cb))) {
>  		struct ip_vs_conn *ct = cp->control;
>  
> -		/* delete the timer if it is activated by other users */
> -		timer_delete(&cp->timer);
> -
>  		/* does anybody control me? */
>  		if (ct) {
> -			bool has_ref = !cp->timeout && __ip_vs_conn_get(ct);
> -
> +			rcu_read_lock();
>  			ip_vs_control_del(cp);
>  			/* Drop CTL or non-assured TPL if not used anymore */
> -			if (has_ref && !atomic_read(&ct->n_control) &&
> +			if (!cp->timeout && !atomic_read(&ct->n_control) &&
>  			    (!(ct->flags & IP_VS_CONN_F_TEMPLATE) ||
>  			     !(ct->state & IP_VS_CTPL_S_ASSURED))) {
>  				IP_VS_DBG(4, "drop controlling connection\n");
> -				ip_vs_conn_del_put(ct);
> -			} else if (has_ref) {
> -				__ip_vs_conn_put(ct);
> +				ip_vs_conn_del(ct);
>  			}
> +			rcu_read_unlock();
>  		}
>  
>  		if ((cp->flags & IP_VS_CONN_F_NFCT) &&
> @@ -1410,13 +1413,15 @@ static void ip_vs_conn_expire(struct timer_list *t)
>  		  refcount_read(&cp->refcnt),
>  		  atomic_read(&cp->n_control));
>  
> -	refcount_inc(&cp->refcnt);
> -	cp->timeout = 60*HZ;
> +	if (__ip_vs_conn_get(cp)) {
> +		if (cp->timeout || atomic_read(&cp->n_control))
> +			cp->timeout = 60 * HZ;
>  
> -	if (ipvs->sync_state & IP_VS_STATE_MASTER)
> -		ip_vs_sync_conn(ipvs, cp, sysctl_sync_threshold(ipvs));
> +		if (ipvs->sync_state & IP_VS_STATE_MASTER)
> +			ip_vs_sync_conn(ipvs, cp, sysctl_sync_threshold(ipvs));
>  
> -	__ip_vs_conn_put_timer(cp);
> +		__ip_vs_conn_put_timer(cp);
> +	}
>  }
>  
>  /* Modify timer, so that it expires as soon as possible.
> -- 
> 2.43.0

Regards

--
Julian Anastasov <ja@ssi.bg>

