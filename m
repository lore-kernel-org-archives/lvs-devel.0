Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 499221D7E4A;
	Wed,  3 Sep 2025 17:31:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1756920705; cv=none; b=soYsDT8bLH1gJB4Oh/8tFxHa2+P3Oy/Ae+1J7ew6o9KPu7EXNP4rmzqNql3SPwKAvJX7FEAGegiNTgLYVR3q4QheOeMymJAZS3h0rQy1rKSJM2XtYDpGdDFnQfbkckUbvrUZ6TXE/YBzhcYfgZs4y/pOFc/t02nSsbGij6lGc7o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1756920705; c=relaxed/simple;
	bh=MGDuGU/WgXkaUhODXaDaVYiIi64R8bWyI3/qcxxAYEo=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=Ecvs9S3ceXzGA5CzW6P5AHYFVJXyGn4Y49H3n7YMcqKcknRY5WptWm1jihqMAbB2/OInzdutvUZmct3oJHX6CNOZKf02kw0VhwiyS0VIKc8nPz/hbMau+SX3edq7GTvQqxBelvEWuKtQ2ohs8HFrSeCgMARXcJ4ZRRT0elkjin8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=vAtJ1TEO; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="vAtJ1TEO"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 65EDE24007;
	Wed,  3 Sep 2025 20:31:32 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=nPMh+2z3FdOgu+OB9tsiaQgbNXDUOZFqm8+7DccePVc=; b=vAtJ1TEO/tsF
	OnF33kodrVcuBsljHk/rm6jPwo0owkYumJ56+HylN4yjJY8VtYv4xMAH1N0OeEQx
	v0hQvmUFFEMfLdDIgoeF83fqezSpsTKjLUmsNLdYshTMf28Wvm60oFwNfHKVaYe6
	QmREdB8QWveKBvYaQ38nA3NIwr71AKkfVdV2DdZ/nunmFeLuDGR+yhiA7bxG9XXI
	3bQgNOfKjx2hvXM00ttihAtEzbPV846RtoKTz0rD+xZDiINoX0xDjwpPGKkrWQaj
	xKzFttE40jUTWqZ22DsjBfD31Ky8x0KmmwquyQiUkFXXVcg7d1/x+u3/3oJZ5hY8
	izlop+H2boSCdSzkuTbjd6ahB5W1kUYICBieq6OcFZg+jjT9lU+hQJ4JG8/ptsjg
	DuxDFHE3/zg+ukDwSGQ7st8ymY4CXfqYkpOOyh5Hf8+wnctIDGdwrTsl4YbBiuvR
	siY+/pfRdlu+8bkJarpM9WXZiy64S304sNBAHkyX2u9+h3lc1Dq5e9AxRqoaBrfz
	DNK8VsYXpstJHBM457uj3A3EB8k3U27nLBkNTuU2aqodMDvv6/gGRcsQwESj1AO8
	kO/FhE2T3RKS9/Brv6MKtJXFqfKyp2is7OAFA/CWYeqw4wyLqhp+xEKfXTxi5fVV
	ewb9f126nehhszDeUBjPt2rVT0vZRck=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed,  3 Sep 2025 20:31:30 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 3360C602E2;
	Wed,  3 Sep 2025 20:31:27 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 583HVMnx058850;
	Wed, 3 Sep 2025 20:31:23 +0300
Date: Wed, 3 Sep 2025 20:31:22 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Zhang Tengfei <zhtfdev@gmail.com>
cc: coreteam@netfilter.org, davem@davemloft.net, dsahern@kernel.org,
        edumazet@google.com, fw@strlen.de, horms@verge.net.au,
        kadlec@netfilter.org, kuba@kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, pabeni@redhat.com,
        pablo@netfilter.org,
        syzbot+1651b5234028c294c339@syzkaller.appspotmail.com
Subject: Re: [PATCH v3 nf-next] ipvs: Use READ_ONCE/WRITE_ONCE for
 ipvs->enable
In-Reply-To: <20250901134653.1308-1-zhtfdev@gmail.com>
Message-ID: <e8c59883-4f65-a07a-220c-ff2a5960d80e@ssi.bg>
References: <3a737b68-5a80-845d-ff36-6a1926b792a0@ssi.bg> <20250901134653.1308-1-zhtfdev@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 1 Sep 2025, Zhang Tengfei wrote:

> KCSAN reported a data-race on the `ipvs->enable` flag, which is
> written in the control path and read concurrently from many other
> contexts.
> 
> Following a suggestion by Julian, this patch fixes the race by
> converting all accesses to use `WRITE_ONCE()/READ_ONCE()`.
> This lightweight approach ensures atomic access and acts as a
> compiler barrier, preventing unsafe optimizations where the flag
> is checked in loops (e.g., in ip_vs_est.c).
> 
> Additionally, the `enable` checks in the fast-path hooks
> (`ip_vs_in_hook`, `ip_vs_out_hook`, `ip_vs_forward_icmp`) are
> removed. These are unnecessary since commit 857ca89711de
> ("ipvs: register hooks only with services"). The `enable=0`
> condition they check for can only occur in two rare and non-fatal
> scenarios: 1) after hooks are registered but before the flag is set,
> and 2) after hooks are unregistered on cleanup_net. In the worst
> case, a single packet might be mishandled (e.g., dropped), which
> does not lead to a system crash or data corruption. Adding a check
> in the performance-critical fast-path to handle this harmless
> condition is not a worthwhile trade-off.
> 
> Fixes: 857ca89711de ("ipvs: register hooks only with services")
> Reported-by: syzbot+1651b5234028c294c339@syzkaller.appspotmail.com
> Closes: https://syzkaller.appspot.com/bug?extid=1651b5234028c294c339
> Suggested-by: Julian Anastasov <ja@ssi.bg>
> Link: https://lore.kernel.org/lvs-devel/2189fc62-e51e-78c9-d1de-d35b8e3657e3@ssi.bg/
> Signed-off-by: Zhang Tengfei <zhtfdev@gmail.com>

	Looks good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
> v3:
> - Restore reference to commit 857ca89711de in commit message.
> - Add corresponding Fixes tag.
> v2:
> - Switched from atomic_t to the suggested READ_ONCE()/WRITE_ONCE().
> - Removed obsolete checks from the packet processing hooks.
> - Polished commit message based on feedback from maintainers.
> ---
>  net/netfilter/ipvs/ip_vs_conn.c |  4 ++--
>  net/netfilter/ipvs/ip_vs_core.c | 11 ++++-------
>  net/netfilter/ipvs/ip_vs_ctl.c  |  6 +++---
>  net/netfilter/ipvs/ip_vs_est.c  | 16 ++++++++--------
>  4 files changed, 17 insertions(+), 20 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 965f3c8e508..37ebb0cb62b 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -885,7 +885,7 @@ static void ip_vs_conn_expire(struct timer_list *t)
>  			 * conntrack cleanup for the net.
>  			 */
>  			smp_rmb();
> -			if (ipvs->enable)
> +			if (READ_ONCE(ipvs->enable))
>  				ip_vs_conn_drop_conntrack(cp);
>  		}
>  
> @@ -1439,7 +1439,7 @@ void ip_vs_expire_nodest_conn_flush(struct netns_ipvs *ipvs)
>  		cond_resched_rcu();
>  
>  		/* netns clean up started, abort delayed work */
> -		if (!ipvs->enable)
> +		if (!READ_ONCE(ipvs->enable))
>  			break;
>  	}
>  	rcu_read_unlock();
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index c7a8a08b730..5ea7ab8bf4d 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1353,9 +1353,6 @@ ip_vs_out_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *stat
>  	if (unlikely(!skb_dst(skb)))
>  		return NF_ACCEPT;
>  
> -	if (!ipvs->enable)
> -		return NF_ACCEPT;
> -
>  	ip_vs_fill_iph_skb(af, skb, false, &iph);
>  #ifdef CONFIG_IP_VS_IPV6
>  	if (af == AF_INET6) {
> @@ -1940,7 +1937,7 @@ ip_vs_in_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *state
>  		return NF_ACCEPT;
>  	}
>  	/* ipvs enabled in this netns ? */
> -	if (unlikely(sysctl_backup_only(ipvs) || !ipvs->enable))
> +	if (unlikely(sysctl_backup_only(ipvs)))
>  		return NF_ACCEPT;
>  
>  	ip_vs_fill_iph_skb(af, skb, false, &iph);
> @@ -2108,7 +2105,7 @@ ip_vs_forward_icmp(void *priv, struct sk_buff *skb,
>  	int r;
>  
>  	/* ipvs enabled in this netns ? */
> -	if (unlikely(sysctl_backup_only(ipvs) || !ipvs->enable))
> +	if (unlikely(sysctl_backup_only(ipvs)))
>  		return NF_ACCEPT;
>  
>  	if (state->pf == NFPROTO_IPV4) {
> @@ -2295,7 +2292,7 @@ static int __net_init __ip_vs_init(struct net *net)
>  		return -ENOMEM;
>  
>  	/* Hold the beast until a service is registered */
> -	ipvs->enable = 0;
> +	WRITE_ONCE(ipvs->enable, 0);
>  	ipvs->net = net;
>  	/* Counters used for creating unique names */
>  	ipvs->gen = atomic_read(&ipvs_netns_cnt);
> @@ -2367,7 +2364,7 @@ static void __net_exit __ip_vs_dev_cleanup_batch(struct list_head *net_list)
>  		ipvs = net_ipvs(net);
>  		ip_vs_unregister_hooks(ipvs, AF_INET);
>  		ip_vs_unregister_hooks(ipvs, AF_INET6);
> -		ipvs->enable = 0;	/* Disable packet reception */
> +		WRITE_ONCE(ipvs->enable, 0);	/* Disable packet reception */
>  		smp_wmb();
>  		ip_vs_sync_net_cleanup(ipvs);
>  	}
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 6a6fc447853..4c8fa22be88 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -256,7 +256,7 @@ static void est_reload_work_handler(struct work_struct *work)
>  		struct ip_vs_est_kt_data *kd = ipvs->est_kt_arr[id];
>  
>  		/* netns clean up started, abort delayed work */
> -		if (!ipvs->enable)
> +		if (!READ_ONCE(ipvs->enable))
>  			goto unlock;
>  		if (!kd)
>  			continue;
> @@ -1483,9 +1483,9 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
>  
>  	*svc_p = svc;
>  
> -	if (!ipvs->enable) {
> +	if (!READ_ONCE(ipvs->enable)) {
>  		/* Now there is a service - full throttle */
> -		ipvs->enable = 1;
> +		WRITE_ONCE(ipvs->enable, 1);
>  
>  		/* Start estimation for first time */
>  		ip_vs_est_reload_start(ipvs);
> diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
> index 15049b82673..93a925f1ed9 100644
> --- a/net/netfilter/ipvs/ip_vs_est.c
> +++ b/net/netfilter/ipvs/ip_vs_est.c
> @@ -231,7 +231,7 @@ static int ip_vs_estimation_kthread(void *data)
>  void ip_vs_est_reload_start(struct netns_ipvs *ipvs)
>  {
>  	/* Ignore reloads before first service is added */
> -	if (!ipvs->enable)
> +	if (!READ_ONCE(ipvs->enable))
>  		return;
>  	ip_vs_est_stopped_recalc(ipvs);
>  	/* Bump the kthread configuration genid */
> @@ -306,7 +306,7 @@ static int ip_vs_est_add_kthread(struct netns_ipvs *ipvs)
>  	int i;
>  
>  	if ((unsigned long)ipvs->est_kt_count >= ipvs->est_max_threads &&
> -	    ipvs->enable && ipvs->est_max_threads)
> +	    READ_ONCE(ipvs->enable) && ipvs->est_max_threads)
>  		return -EINVAL;
>  
>  	mutex_lock(&ipvs->est_mutex);
> @@ -343,7 +343,7 @@ static int ip_vs_est_add_kthread(struct netns_ipvs *ipvs)
>  	}
>  
>  	/* Start kthread tasks only when services are present */
> -	if (ipvs->enable && !ip_vs_est_stopped(ipvs)) {
> +	if (READ_ONCE(ipvs->enable) && !ip_vs_est_stopped(ipvs)) {
>  		ret = ip_vs_est_kthread_start(ipvs, kd);
>  		if (ret < 0)
>  			goto out;
> @@ -486,7 +486,7 @@ int ip_vs_start_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats)
>  	struct ip_vs_estimator *est = &stats->est;
>  	int ret;
>  
> -	if (!ipvs->est_max_threads && ipvs->enable)
> +	if (!ipvs->est_max_threads && READ_ONCE(ipvs->enable))
>  		ipvs->est_max_threads = ip_vs_est_max_threads(ipvs);
>  
>  	est->ktid = -1;
> @@ -663,7 +663,7 @@ static int ip_vs_est_calc_limits(struct netns_ipvs *ipvs, int *chain_max)
>  			/* Wait for cpufreq frequency transition */
>  			wait_event_idle_timeout(wq, kthread_should_stop(),
>  						HZ / 50);
> -			if (!ipvs->enable || kthread_should_stop())
> +			if (!READ_ONCE(ipvs->enable) || kthread_should_stop())
>  				goto stop;
>  		}
>  
> @@ -681,7 +681,7 @@ static int ip_vs_est_calc_limits(struct netns_ipvs *ipvs, int *chain_max)
>  		rcu_read_unlock();
>  		local_bh_enable();
>  
> -		if (!ipvs->enable || kthread_should_stop())
> +		if (!READ_ONCE(ipvs->enable) || kthread_should_stop())
>  			goto stop;
>  		cond_resched();
>  
> @@ -757,7 +757,7 @@ static void ip_vs_est_calc_phase(struct netns_ipvs *ipvs)
>  	mutex_lock(&ipvs->est_mutex);
>  	for (id = 1; id < ipvs->est_kt_count; id++) {
>  		/* netns clean up started, abort */
> -		if (!ipvs->enable)
> +		if (!READ_ONCE(ipvs->enable))
>  			goto unlock2;
>  		kd = ipvs->est_kt_arr[id];
>  		if (!kd)
> @@ -787,7 +787,7 @@ static void ip_vs_est_calc_phase(struct netns_ipvs *ipvs)
>  	id = ipvs->est_kt_count;
>  
>  next_kt:
> -	if (!ipvs->enable || kthread_should_stop())
> +	if (!READ_ONCE(ipvs->enable) || kthread_should_stop())
>  		goto unlock;
>  	id--;
>  	if (id < 0)
> -- 
> 2.34.1

Regards

--
Julian Anastasov <ja@ssi.bg>

