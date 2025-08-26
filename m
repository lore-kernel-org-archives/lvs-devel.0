Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CE0DB21ADA4;
	Tue, 26 Aug 2025 16:07:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1756224437; cv=none; b=ssghMAP2HLdtKo9x3dhBCq4PjHmlaAGh74dPzRCLfAPjz7WaFkUUbadx1fBD9kNfeIKRCaWGhbx5DcU7HYqR7Wq6h8peNhSI8avVnit2xnGHQEO720NsOeVBrSZmfcpHJtDFD/yteQ2qApsxZt4UogeXmt8zFqxkFM6mhHgtluI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1756224437; c=relaxed/simple;
	bh=suOfog0pcsT1e7pupWg2vZgPmZkFQFqnCIBW+MzqzlA=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=lP9Vtr0sj5QJI9dYGBFGvHOLz8qRY3J+zJj+YXaIGd0nsc2uCbH+Q9Gzt1QSf7vcX/76Ob7w3T6KR4YhyH2hFE5PZpAvNKne1Kh1x7DulOjiPA8Qx3IGi+scAkaNGUcbx6wp3dYZxzYW7mrIP1b8HMSLfUL8XOO3qpaBFC3DAog=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=QuZrovKe; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="QuZrovKe"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id DFF0923FE7;
	Tue, 26 Aug 2025 18:57:00 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=k2NNNV1ImL2qQsvwGNgeyWeGYt6PRxVEPDc3n4VexwI=; b=QuZrovKen+Z1
	0C6M3dhwxiSkurLiY2shmMjq4q2dcVyPFIWce/01OK2fFpMt7RcDxKsk9pcalr4U
	Wupa498wmEAXIZhfEV+MZek85paVCq3ukGhhKWRVfs0hqvTgMkj0SyLFEMgUyxNs
	yxTDfRSXFosJgpXGCFvsSh2KS65Qxjrq3QA3bah7OtjLoSa20SKe46BxPiG19t5G
	l6iLbzBf8i21//rXjYSb7YB57vH2buAKbFR5Lm85aoNXTYcOqZwTHLPQSNWf+3PS
	a4paIa5BPDulbnULrHCbCj/NBD1oLFldAs8nr6+Mh2+ksR7MtyJ6z0JakofZyOSD
	iU6GLXJpRJxYyGumI+yj2+LAmY33Q4IR+QLZIWsEolIp2gLsqImUAaJuqXq5Yj4Z
	fxjSCN55yjlE3aMD0nuBEX6J1xq7InNw7wmybKV9jyGMwcIKw7x5wuTmggv5fai4
	XjHAKBrh88M+i+pF6qANNXhNhN8xO/WG2qVM1N1hxmP6jVoFjU1Gsaz4nrman+kX
	hYuHuPBYnbGiPPx2udsvRQ8bEmt/4BnvnnVQz9ctCvgMZaOvq6Fg+mpSBBpjWvFh
	N+XxsJiG9jvO+fo/3ejiSaq4GmPRfIJIu5LqXfPeaBJtQhBbpI2kthSI+P6xVglk
	sVAjFJCxAyFswACsUZ754t+QQaVw68g=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 26 Aug 2025 18:56:59 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 82D69652A4;
	Tue, 26 Aug 2025 18:56:56 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 57QFuk09041860;
	Tue, 26 Aug 2025 18:56:47 +0300
Date: Tue, 26 Aug 2025 18:56:46 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Zhang Tengfei <zhtfdev@gmail.com>
cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        "David S . Miller" <davem@davemloft.net>,
        David Ahern <dsahern@kernel.org>, Eric Dumazet <edumazet@google.com>,
        Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
        coreteam@netfilter.org,
        syzbot+1651b5234028c294c339@syzkaller.appspotmail.com
Subject: Re: [PATCH] net/netfilter/ipvs: Fix data-race in ip_vs_add_service
 / ip_vs_out_hook
In-Reply-To: <20250826133104.212975-1-zhtfdev@gmail.com>
Message-ID: <42c4ff11-ba18-2fed-1c01-02b080789c58@ssi.bg>
References: <20250826133104.212975-1-zhtfdev@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Tue, 26 Aug 2025, Zhang Tengfei wrote:

> A data-race was detected by KCSAN between ip_vs_add_service() which
> acts as a writer, and ip_vs_out_hook() which acts as a reader. This
> can lead to unpredictable behavior and crashes. One observed symptom
> is the "no destination available" error when processing packets.

	You can not solve the "no destination available" race
in IPVS itself. When service is added in ip_vs_add_service()
things happen in some order:

- hooks are registered (if first service)
- service is registered
- enable flag is set (if first service)

	All this is part of single IP_VS_SO_SET_ADD call.
You can reorder the above actions as you wish but without any
gain because the dests (real servers) are added with a
following IP_VS_SO_SET_ADDDEST call. There will be always a
gap between the both calls where packets can hit service
without any dests, with enable=0 or 1.

	One can stop the traffic with firewall rules until
all IPVS rules are added. It is decided by user space tools
when to route the traffic via IPVS (after or during
configuration).

> 
> The race occurs on the `enable` flag within the `netns_ipvs`
> struct. This flag was being written in the configuration path without
> any protection, while concurrently being read in the packet processing
> path. This lack of synchronization means a reader on one CPU could see a
> partially initialized service, leading to incorrect behavior.

	No, service is added with hlist_add_head_rcu() in
ip_vs_svc_hash() which commits all writes before adding svc
to list. This is also an answer for the concerns in your
paragraph below.

	If "partially initialized" refers to the missing
dests, then see above, they are added later with
IP_VS_SO_SET_ADDDEST.

> To fix this, convert the `enable` flag from a plain integer to an
> atomic_t. This ensures that all reads and writes to the flag are atomic.
> More importantly, using atomic_set() and atomic_read() provides the
> necessary memory barriers to guarantee that changes to other fields of
> the service are visible to the reader CPU before the service is marked
> as enabled.

	We use RCU for proper svc registration.

> Reported-by: syzbot+1651b5234028c294c339@syzkaller.appspotmail.com
> Closes: https://syzkaller.appspot.com/bug?extid=1651b5234028c294c339
> Signed-off-by: Zhang Tengfei <zhtfdev@gmail.com>
> ---
>  include/net/ip_vs.h             |  2 +-
>  net/netfilter/ipvs/ip_vs_conn.c |  4 ++--
>  net/netfilter/ipvs/ip_vs_core.c | 10 +++++-----
>  net/netfilter/ipvs/ip_vs_ctl.c  |  6 +++---
>  net/netfilter/ipvs/ip_vs_est.c  | 16 ++++++++--------
>  5 files changed, 19 insertions(+), 19 deletions(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 29a36709e7f3..58b2ad7906e8 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -895,7 +895,7 @@ struct ipvs_sync_daemon_cfg {
>  /* IPVS in network namespace */
>  struct netns_ipvs {
>  	int			gen;		/* Generation */
> -	int			enable;		/* enable like nf_hooks do */
> +	atomic_t	enable;		/* enable like nf_hooks do */
>  	/* Hash table: for real service lookups */
>  	#define IP_VS_RTAB_BITS 4
>  	#define IP_VS_RTAB_SIZE (1 << IP_VS_RTAB_BITS)
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 965f3c8e5089..5c97f85929b4 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -885,7 +885,7 @@ static void ip_vs_conn_expire(struct timer_list *t)
>  			 * conntrack cleanup for the net.
>  			 */
>  			smp_rmb();
> -			if (ipvs->enable)
> +			if (atomic_read(&ipvs->enable))

	This place is a valid user of this flag.
This is one of the reasons we should keep such flag.

>  				ip_vs_conn_drop_conntrack(cp);
>  		}
>  
> @@ -1439,7 +1439,7 @@ void ip_vs_expire_nodest_conn_flush(struct netns_ipvs *ipvs)
>  		cond_resched_rcu();
>  
>  		/* netns clean up started, abort delayed work */
> -		if (!ipvs->enable)
> +		if (!atomic_read(&ipvs->enable))
>  			break;
>  	}
>  	rcu_read_unlock();
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index c7a8a08b7308..84eed2e45927 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1353,7 +1353,7 @@ ip_vs_out_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *stat
>  	if (unlikely(!skb_dst(skb)))
>  		return NF_ACCEPT;
>  
> -	if (!ipvs->enable)

	The checks in the hooks are not needed anymore after
commit 857ca89711de ("ipvs: register hooks only with services")
because the hooks are registered when the first service is
added.

	So, you can not see enable=0 in hooks anymore which
was possible before first service was added. Or it is
possible for small time between adding the hooks and setting
the flag but it is irrelevant because there are no dests yet.

> +	if (!atomic_read(&ipvs->enable))
>  		return NF_ACCEPT;
>  
>  	ip_vs_fill_iph_skb(af, skb, false, &iph);
> @@ -1940,7 +1940,7 @@ ip_vs_in_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *state
>  		return NF_ACCEPT;
>  	}
>  	/* ipvs enabled in this netns ? */
> -	if (unlikely(sysctl_backup_only(ipvs) || !ipvs->enable))
> +	if (unlikely(sysctl_backup_only(ipvs) || !atomic_read(&ipvs->enable)))
>  		return NF_ACCEPT;
>  
>  	ip_vs_fill_iph_skb(af, skb, false, &iph);
> @@ -2108,7 +2108,7 @@ ip_vs_forward_icmp(void *priv, struct sk_buff *skb,
>  	int r;
>  
>  	/* ipvs enabled in this netns ? */
> -	if (unlikely(sysctl_backup_only(ipvs) || !ipvs->enable))
> +	if (unlikely(sysctl_backup_only(ipvs) || !atomic_read(&ipvs->enable)))
>  		return NF_ACCEPT;
>  
>  	if (state->pf == NFPROTO_IPV4) {
> @@ -2295,7 +2295,7 @@ static int __net_init __ip_vs_init(struct net *net)
>  		return -ENOMEM;
>  
>  	/* Hold the beast until a service is registered */
> -	ipvs->enable = 0;
> +	atomic_set(&ipvs->enable, 0);
>  	ipvs->net = net;
>  	/* Counters used for creating unique names */
>  	ipvs->gen = atomic_read(&ipvs_netns_cnt);
> @@ -2367,7 +2367,7 @@ static void __net_exit __ip_vs_dev_cleanup_batch(struct list_head *net_list)
>  		ipvs = net_ipvs(net);
>  		ip_vs_unregister_hooks(ipvs, AF_INET);
>  		ip_vs_unregister_hooks(ipvs, AF_INET6);

	No new/flying packets after this point...

> -		ipvs->enable = 0;	/* Disable packet reception */

	It was an old method to disable reception but now
the flag helps for other purposes.

> +		atomic_set(&ipvs->enable, 0);	/* Disable packet reception */
>  		smp_wmb();
>  		ip_vs_sync_net_cleanup(ipvs);
>  	}
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 6a6fc4478533..ad7e1c387c1f 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -256,7 +256,7 @@ static void est_reload_work_handler(struct work_struct *work)
>  		struct ip_vs_est_kt_data *kd = ipvs->est_kt_arr[id];
>  
>  		/* netns clean up started, abort delayed work */
> -		if (!ipvs->enable)

	Such checks in slow path just speedup the cleanup.

> +		if (!atomic_read(&ipvs->enable))
>  			goto unlock;
>  		if (!kd)
>  			continue;
> @@ -1483,9 +1483,9 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
>  
>  	*svc_p = svc;
>  
> -	if (!ipvs->enable) {
> +	if (!atomic_read(&ipvs->enable)) {
>  		/* Now there is a service - full throttle */
> -		ipvs->enable = 1;
> +		atomic_set(&ipvs->enable, 1);
>  
>  		/* Start estimation for first time */
>  		ip_vs_est_reload_start(ipvs);
> diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
> index 15049b826732..c5aa2660de92 100644
> --- a/net/netfilter/ipvs/ip_vs_est.c
> +++ b/net/netfilter/ipvs/ip_vs_est.c
> @@ -231,7 +231,7 @@ static int ip_vs_estimation_kthread(void *data)
>  void ip_vs_est_reload_start(struct netns_ipvs *ipvs)
>  {
>  	/* Ignore reloads before first service is added */
> -	if (!ipvs->enable)
> +	if (!atomic_read(&ipvs->enable))
>  		return;
>  	ip_vs_est_stopped_recalc(ipvs);
>  	/* Bump the kthread configuration genid */
> @@ -306,7 +306,7 @@ static int ip_vs_est_add_kthread(struct netns_ipvs *ipvs)
>  	int i;
>  
>  	if ((unsigned long)ipvs->est_kt_count >= ipvs->est_max_threads &&
> -	    ipvs->enable && ipvs->est_max_threads)
> +	    atomic_read(&ipvs->enable) && ipvs->est_max_threads)
>  		return -EINVAL;
>  
>  	mutex_lock(&ipvs->est_mutex);
> @@ -343,7 +343,7 @@ static int ip_vs_est_add_kthread(struct netns_ipvs *ipvs)
>  	}
>  
>  	/* Start kthread tasks only when services are present */
> -	if (ipvs->enable && !ip_vs_est_stopped(ipvs)) {
> +	if (atomic_read(&ipvs->enable) && !ip_vs_est_stopped(ipvs)) {
>  		ret = ip_vs_est_kthread_start(ipvs, kd);
>  		if (ret < 0)
>  			goto out;
> @@ -486,7 +486,7 @@ int ip_vs_start_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats)
>  	struct ip_vs_estimator *est = &stats->est;
>  	int ret;
>  
> -	if (!ipvs->est_max_threads && ipvs->enable)
> +	if (!ipvs->est_max_threads && atomic_read(&ipvs->enable))
>  		ipvs->est_max_threads = ip_vs_est_max_threads(ipvs);
>  
>  	est->ktid = -1;
> @@ -663,7 +663,7 @@ static int ip_vs_est_calc_limits(struct netns_ipvs *ipvs, int *chain_max)
>  			/* Wait for cpufreq frequency transition */
>  			wait_event_idle_timeout(wq, kthread_should_stop(),
>  						HZ / 50);
> -			if (!ipvs->enable || kthread_should_stop())
> +			if (!atomic_read(&ipvs->enable) || kthread_should_stop())
>  				goto stop;
>  		}
>  
> @@ -681,7 +681,7 @@ static int ip_vs_est_calc_limits(struct netns_ipvs *ipvs, int *chain_max)
>  		rcu_read_unlock();
>  		local_bh_enable();
>  
> -		if (!ipvs->enable || kthread_should_stop())
> +		if (!atomic_read(&ipvs->enable) || kthread_should_stop())
>  			goto stop;
>  		cond_resched();
>  
> @@ -757,7 +757,7 @@ static void ip_vs_est_calc_phase(struct netns_ipvs *ipvs)
>  	mutex_lock(&ipvs->est_mutex);
>  	for (id = 1; id < ipvs->est_kt_count; id++) {
>  		/* netns clean up started, abort */
> -		if (!ipvs->enable)
> +		if (!atomic_read(&ipvs->enable))
>  			goto unlock2;
>  		kd = ipvs->est_kt_arr[id];
>  		if (!kd)
> @@ -787,7 +787,7 @@ static void ip_vs_est_calc_phase(struct netns_ipvs *ipvs)
>  	id = ipvs->est_kt_count;
>  
>  next_kt:
> -	if (!ipvs->enable || kthread_should_stop())
> +	if (!atomic_read(&ipvs->enable) || kthread_should_stop())
>  		goto unlock;
>  	id--;
>  	if (id < 0)
> -- 

	In summary, the checks in fast path (in hooks) are
useless/obsolete while the other checks in slow path do not need
atomic operations. Such races are normal to happen because
service and its dests are not added in same atomic transaction.

Regards

--
Julian Anastasov <ja@ssi.bg>

