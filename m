Received: from mail.netfilter.org (mail.netfilter.org [217.70.190.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 014B423EABF;
	Mon, 24 Nov 2025 21:00:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.190.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1764018022; cv=none; b=C/bwyNHhypaXldMoHd8DGTLIren8bZJ3NkXIpU2Ft1a24e+u62jD82sXFZH3GutPta0x97U3Jh0Hh9FVK47UM8P3iXBKoc2uQcR/P14upAi1kh4qno2HRCpMqUuWqUPlq392TfcFktUPYyIMLneS9zU4xOUkBFsluKhcJ/mUjc4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1764018022; c=relaxed/simple;
	bh=9SW0KYPwRTbffYrQF50VPyxRBxd0xsGNwuDnhqtleUU=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=VPcnjtVw2649+rIwceDxCqfsss9sPQchKHgyZ2DBntYjehK/6IhCaC0smgHyqJRUiAzdC3iRAzJ0Z/0DZ5LP+RF5ACI4X33oWK0Y7HaCHC0Z7EL2YxI+kLS3+Hbqp/IK8ijcnBfWULST6WE8yqQK5eiU4BtnGkN2o1d0lvgpSLA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org; spf=pass smtp.mailfrom=netfilter.org; dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b=aDUj/7Ps; arc=none smtp.client-ip=217.70.190.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netfilter.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b="aDUj/7Ps"
Received: from netfilter.org (mail-agni [217.70.190.124])
	by mail.netfilter.org (Postfix) with ESMTPSA id 3E17F602A7;
	Mon, 24 Nov 2025 22:00:10 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1764018010;
	bh=7c6+uUngnOs+NqvPAbPciw6aU7an3EUgEWKqeQClbV8=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=aDUj/7PsvIP8Hv5SuzYuDBQB/Qq09XYds7Klr2+qRlQfP1lmhe1z9I+Cev59FZJ7n
	 IwixEW17OVYYrl6Pn2M0cQf/+ig8mtZo4jVnwhXzYc6ts6mztRIijkGMNAP1l0sb4S
	 1DOlSkN+LHZJBGh2xp9MTR3tMj9ZZLQo/jtIqCAH59FMRxLbgvgSq0caqcMpDCO+i/
	 vgz7nz4lud1IquV1tn1PfOtEJVqlSCpF0X/VRoR6jXzuXhiMEmeDQSF3DOUbGTX+fE
	 MHU0wJn/7qVzVEsKJ80bISu9rlxSXTfbkzZIXTs8ZkUH48QxkhX+mbXaUHNWJu0/Yj
	 cIIJlkldLGxmg==
Date: Mon, 24 Nov 2025 22:00:07 +0100
From: Pablo Neira Ayuso <pablo@netfilter.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Dust Li <dust.li@linux.alibaba.com>,
	Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: Re: [PATCHv6 net-next 03/14] ipvs: some service readers can use RCU
Message-ID: <aSTHJAR5aXml2ms0@calendula>
References: <20251019155711.67609-1-ja@ssi.bg>
 <20251019155711.67609-4-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20251019155711.67609-4-ja@ssi.bg>

Hi Julian,

Comments below.

On Sun, Oct 19, 2025 at 06:57:00PM +0300, Julian Anastasov wrote:
> Some places walk the services under mutex but they can just use RCU:
> 
> * ip_vs_dst_event() uses ip_vs_forget_dev() which uses its own lock
>   to modify dest
> * ip_vs_genl_dump_services(): ip_vs_genl_fill_service() just fills skb
> * ip_vs_genl_parse_service(): move RCU lock to callers
>   ip_vs_genl_set_cmd(), ip_vs_genl_dump_dests() and ip_vs_genl_get_cmd()
> * ip_vs_genl_dump_dests(): just fill skb
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  net/netfilter/ipvs/ip_vs_ctl.c | 47 +++++++++++++++++-----------------
>  1 file changed, 23 insertions(+), 24 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 2fb9034b4f53..b18d08d79bcb 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1759,23 +1759,21 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
>  	if (event != NETDEV_DOWN || !ipvs)
>  		return NOTIFY_DONE;
>  	IP_VS_DBG(3, "%s() dev=%s\n", __func__, dev->name);
> -	mutex_lock(&ipvs->service_mutex);
> +	rcu_read_lock();

Control plane can still add destinations to svc->destinations that can
be skipped by the rcu walk. I think it should be possible to trigger
leaks with a sufficiently large list, given concurrent updates can
happen. ip_vs_forget_dev() has its own lock, but this is a per-dest
lock which is taken during the list walk.

>  	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
> -		hlist_for_each_entry(svc, &ipvs->svc_table[idx], s_list) {
> -			list_for_each_entry(dest, &svc->destinations,
> -					    n_list) {
> +		hlist_for_each_entry_rcu(svc, &ipvs->svc_table[idx], s_list)
> +			list_for_each_entry_rcu(dest, &svc->destinations,
> +						n_list)
>  				ip_vs_forget_dev(dest, dev);
> -			}
> -		}
>  
> -		hlist_for_each_entry(svc, &ipvs->svc_fwm_table[idx], f_list) {
> -			list_for_each_entry(dest, &svc->destinations,
> -					    n_list) {
> +		hlist_for_each_entry_rcu(svc, &ipvs->svc_fwm_table[idx], f_list)
> +			list_for_each_entry_rcu(dest, &svc->destinations,
> +						n_list)
>  				ip_vs_forget_dev(dest, dev);
> -			}
> -		}
>  	}
> +	rcu_read_unlock();
>  
> +	mutex_lock(&ipvs->service_mutex);
>  	spin_lock_bh(&ipvs->dest_trash_lock);
>  	list_for_each_entry(dest, &ipvs->dest_trash, t_list) {
>  		ip_vs_forget_dev(dest, dev);
> @@ -3318,9 +3316,9 @@ static int ip_vs_genl_fill_service(struct sk_buff *skb,
>  			goto nla_put_failure;
>  	}
>  
> -	sched = rcu_dereference_protected(svc->scheduler, 1);
> +	sched = rcu_dereference(svc->scheduler);
>  	sched_name = sched ? sched->name : "none";
> -	pe = rcu_dereference_protected(svc->pe, 1);
> +	pe = rcu_dereference(svc->pe);
>  	if (nla_put_string(skb, IPVS_SVC_ATTR_SCHED_NAME, sched_name) ||
>  	    (pe && nla_put_string(skb, IPVS_SVC_ATTR_PE_NAME, pe->name)) ||
>  	    nla_put(skb, IPVS_SVC_ATTR_FLAGS, sizeof(flags), &flags) ||
> @@ -3374,9 +3372,9 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
>  	struct net *net = sock_net(skb->sk);
>  	struct netns_ipvs *ipvs = net_ipvs(net);
>  
> -	mutex_lock(&ipvs->service_mutex);
> +	rcu_read_lock();

Here I can see this is safe, because this is netlink path.

>  	for (i = 0; i < IP_VS_SVC_TAB_SIZE; i++) {
> -		hlist_for_each_entry(svc, &ipvs->svc_table[i], s_list) {
> +		hlist_for_each_entry_rcu(svc, &ipvs->svc_table[i], s_list) {
>  			if (++idx <= start)
>  				continue;
>  			if (ip_vs_genl_dump_service(skb, svc, cb) < 0) {
> @@ -3387,7 +3385,7 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
>  	}
>  
>  	for (i = 0; i < IP_VS_SVC_TAB_SIZE; i++) {
> -		hlist_for_each_entry(svc, &ipvs->svc_fwm_table[i], f_list) {
> +		hlist_for_each_entry_rcu(svc, &ipvs->svc_fwm_table[i], f_list) {
>  			if (++idx <= start)
>  				continue;
>  			if (ip_vs_genl_dump_service(skb, svc, cb) < 0) {
> @@ -3398,7 +3396,7 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
>  	}
>  
>  nla_put_failure:
> -	mutex_unlock(&ipvs->service_mutex);
> +	rcu_read_unlock();
>  	cb->args[0] = idx;
>  
>  	return skb->len;
> @@ -3454,13 +3452,11 @@ static int ip_vs_genl_parse_service(struct netns_ipvs *ipvs,
>  		usvc->fwmark = 0;
>  	}
>  
> -	rcu_read_lock();
>  	if (usvc->fwmark)
>  		svc = __ip_vs_svc_fwm_find(ipvs, usvc->af, usvc->fwmark);
>  	else
>  		svc = __ip_vs_service_find(ipvs, usvc->af, usvc->protocol,
>  					   &usvc->addr, usvc->port);
> -	rcu_read_unlock();
>  	*ret_svc = svc;
>  
>  	/* If a full entry was requested, check for the additional fields */
> @@ -3587,7 +3583,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
>  	struct net *net = sock_net(skb->sk);
>  	struct netns_ipvs *ipvs = net_ipvs(net);
>  
> -	mutex_lock(&ipvs->service_mutex);
> +	rcu_read_lock();
>  
>  	/* Try to find the service for which to dump destinations */
>  	if (nlmsg_parse_deprecated(cb->nlh, GENL_HDRLEN, attrs, IPVS_CMD_ATTR_MAX, ip_vs_cmd_policy, cb->extack))
> @@ -3599,7 +3595,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
>  		goto out_err;
>  
>  	/* Dump the destinations */
> -	list_for_each_entry(dest, &svc->destinations, n_list) {
> +	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
>  		if (++idx <= start)
>  			continue;
>  		if (ip_vs_genl_dump_dest(skb, dest, cb) < 0) {
> @@ -3612,7 +3608,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
>  	cb->args[0] = idx;
>  
>  out_err:
> -	mutex_unlock(&ipvs->service_mutex);
> +	rcu_read_unlock();
>  
>  	return skb->len;
>  }
> @@ -3915,9 +3911,12 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
>  	if (cmd == IPVS_CMD_NEW_SERVICE || cmd == IPVS_CMD_SET_SERVICE)
>  		need_full_svc = true;
>  
> +	/* We use function that requires RCU lock */
> +	rcu_read_lock();

This is ip_vs_genl_set_cmd path and the new per-netns mutex is held.

I think __ip_vs_service_find() can now just access this mutex to check
if it is held, using fourth parameter:

        list_for_each_entry_rcu(..., lockdep_is_held(&ipvs->service_mutex))

Then this rcu_read_lock() after mutex_lock(&ipvs->service_mutex) can
be removed. I suspect you added it to quiet a rcu debugging splat.

>  	ret = ip_vs_genl_parse_service(ipvs, &usvc,
>  				       info->attrs[IPVS_CMD_ATTR_SERVICE],
>  				       need_full_svc, &svc);
> +	rcu_read_unlock();
>  	if (ret)
>  		goto out;
>  
