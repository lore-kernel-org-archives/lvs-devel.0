Received: from out30-111.freemail.mail.aliyun.com (out30-111.freemail.mail.aliyun.com [115.124.30.111])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 525E318A6A7;
	Fri, 24 Oct 2025 02:21:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=115.124.30.111
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1761272487; cv=none; b=b2Qi1LSgTpLyJeZVU0EadOkPlJ+ALvW9IU7/Fv/9zd0Bi97Zw+AY9lMZVWlNdZUZSwn0yr2pKw6z8XGhWa0vGtADdvSAfI9S4OtNreRY7/mfLoO1qzYKprceEJz+NzBbQ+xc1VKAS+yybF2HeJkL9Wxsm62CZGD6+oxFOsNFrRU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1761272487; c=relaxed/simple;
	bh=9r2koSF36jE9MkgN6kFyte8dlM8nq3azJeHpl2qxQBQ=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=NFGu/tZp3+q1ndwYRC7SDW+QGtVdTXzgt8OZE0cpXQXbbH07g3Kp/0PGHJn9k+5r2EBLS70KR9ijizO4KiTFVyEGnUMDL3xYfRyVFHd5OgljbKmAGo3lxHkMUvLQPLh//Xh9NCN3/bhT3PJqXhq5kj4s4h0OjmElFEh3XCANQeo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com; spf=pass smtp.mailfrom=linux.alibaba.com; dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b=JYe3+kr4; arc=none smtp.client-ip=115.124.30.111
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b="JYe3+kr4"
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1761272475; h=Date:From:To:Subject:Message-ID:MIME-Version:Content-Type;
	bh=vegTbyzQwgetuNbwLhZjZCKV0EXnxbZxEznM1T+Yfmk=;
	b=JYe3+kr40Au1wJYObuHv0uDlAI9B+RPMAOxEvDZIt6Yn/vKJ9P2zGwlEoORpxDYfgdwDnwj34gvbHojqwTgmUkgHfG876GhcpDAUdso8/RFw5nwqGULzy+Pc9RTJ9uWiddYJKf0QaJnfWXtzlZbjpmfTKQgqQSdtzzKGHZ8bStg=
Received: from localhost(mailfrom:dust.li@linux.alibaba.com fp:SMTPD_---0WqshndM_1761272474 cluster:ay36)
          by smtp.aliyun-inc.com;
          Fri, 24 Oct 2025 10:21:14 +0800
Date: Fri, 24 Oct 2025 10:21:14 +0800
From: Dust Li <dust.li@linux.alibaba.com>
To: Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: Re: [PATCHv6 net-next 03/14] ipvs: some service readers can use RCU
Message-ID: <aPrimkqc9leCCZQf@linux.alibaba.com>
Reply-To: dust.li@linux.alibaba.com
References: <20251019155711.67609-1-ja@ssi.bg>
 <20251019155711.67609-4-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20251019155711.67609-4-ja@ssi.bg>

On 2025-10-19 18:57:00, Julian Anastasov wrote:
>Some places walk the services under mutex but they can just use RCU:
>
>* ip_vs_dst_event() uses ip_vs_forget_dev() which uses its own lock
>  to modify dest
>* ip_vs_genl_dump_services(): ip_vs_genl_fill_service() just fills skb
>* ip_vs_genl_parse_service(): move RCU lock to callers
>  ip_vs_genl_set_cmd(), ip_vs_genl_dump_dests() and ip_vs_genl_get_cmd()
>* ip_vs_genl_dump_dests(): just fill skb
>
>Signed-off-by: Julian Anastasov <ja@ssi.bg>

Reviewed-by: Dust Li <dust.li@linux.alibaba.com>

Best regards,
Dust


>---
> net/netfilter/ipvs/ip_vs_ctl.c | 47 +++++++++++++++++-----------------
> 1 file changed, 23 insertions(+), 24 deletions(-)
>
>diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
>index 2fb9034b4f53..b18d08d79bcb 100644
>--- a/net/netfilter/ipvs/ip_vs_ctl.c
>+++ b/net/netfilter/ipvs/ip_vs_ctl.c
>@@ -1759,23 +1759,21 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
> 	if (event != NETDEV_DOWN || !ipvs)
> 		return NOTIFY_DONE;
> 	IP_VS_DBG(3, "%s() dev=%s\n", __func__, dev->name);
>-	mutex_lock(&ipvs->service_mutex);
>+	rcu_read_lock();
> 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
>-		hlist_for_each_entry(svc, &ipvs->svc_table[idx], s_list) {
>-			list_for_each_entry(dest, &svc->destinations,
>-					    n_list) {
>+		hlist_for_each_entry_rcu(svc, &ipvs->svc_table[idx], s_list)
>+			list_for_each_entry_rcu(dest, &svc->destinations,
>+						n_list)
> 				ip_vs_forget_dev(dest, dev);
>-			}
>-		}
> 
>-		hlist_for_each_entry(svc, &ipvs->svc_fwm_table[idx], f_list) {
>-			list_for_each_entry(dest, &svc->destinations,
>-					    n_list) {
>+		hlist_for_each_entry_rcu(svc, &ipvs->svc_fwm_table[idx], f_list)
>+			list_for_each_entry_rcu(dest, &svc->destinations,
>+						n_list)
> 				ip_vs_forget_dev(dest, dev);
>-			}
>-		}
> 	}
>+	rcu_read_unlock();
> 
>+	mutex_lock(&ipvs->service_mutex);
> 	spin_lock_bh(&ipvs->dest_trash_lock);
> 	list_for_each_entry(dest, &ipvs->dest_trash, t_list) {
> 		ip_vs_forget_dev(dest, dev);
>@@ -3318,9 +3316,9 @@ static int ip_vs_genl_fill_service(struct sk_buff *skb,
> 			goto nla_put_failure;
> 	}
> 
>-	sched = rcu_dereference_protected(svc->scheduler, 1);
>+	sched = rcu_dereference(svc->scheduler);
> 	sched_name = sched ? sched->name : "none";
>-	pe = rcu_dereference_protected(svc->pe, 1);
>+	pe = rcu_dereference(svc->pe);
> 	if (nla_put_string(skb, IPVS_SVC_ATTR_SCHED_NAME, sched_name) ||
> 	    (pe && nla_put_string(skb, IPVS_SVC_ATTR_PE_NAME, pe->name)) ||
> 	    nla_put(skb, IPVS_SVC_ATTR_FLAGS, sizeof(flags), &flags) ||
>@@ -3374,9 +3372,9 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
> 	struct net *net = sock_net(skb->sk);
> 	struct netns_ipvs *ipvs = net_ipvs(net);
> 
>-	mutex_lock(&ipvs->service_mutex);
>+	rcu_read_lock();
> 	for (i = 0; i < IP_VS_SVC_TAB_SIZE; i++) {
>-		hlist_for_each_entry(svc, &ipvs->svc_table[i], s_list) {
>+		hlist_for_each_entry_rcu(svc, &ipvs->svc_table[i], s_list) {
> 			if (++idx <= start)
> 				continue;
> 			if (ip_vs_genl_dump_service(skb, svc, cb) < 0) {
>@@ -3387,7 +3385,7 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
> 	}
> 
> 	for (i = 0; i < IP_VS_SVC_TAB_SIZE; i++) {
>-		hlist_for_each_entry(svc, &ipvs->svc_fwm_table[i], f_list) {
>+		hlist_for_each_entry_rcu(svc, &ipvs->svc_fwm_table[i], f_list) {
> 			if (++idx <= start)
> 				continue;
> 			if (ip_vs_genl_dump_service(skb, svc, cb) < 0) {
>@@ -3398,7 +3396,7 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
> 	}
> 
> nla_put_failure:
>-	mutex_unlock(&ipvs->service_mutex);
>+	rcu_read_unlock();
> 	cb->args[0] = idx;
> 
> 	return skb->len;
>@@ -3454,13 +3452,11 @@ static int ip_vs_genl_parse_service(struct netns_ipvs *ipvs,
> 		usvc->fwmark = 0;
> 	}
> 
>-	rcu_read_lock();
> 	if (usvc->fwmark)
> 		svc = __ip_vs_svc_fwm_find(ipvs, usvc->af, usvc->fwmark);
> 	else
> 		svc = __ip_vs_service_find(ipvs, usvc->af, usvc->protocol,
> 					   &usvc->addr, usvc->port);
>-	rcu_read_unlock();
> 	*ret_svc = svc;
> 
> 	/* If a full entry was requested, check for the additional fields */
>@@ -3587,7 +3583,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
> 	struct net *net = sock_net(skb->sk);
> 	struct netns_ipvs *ipvs = net_ipvs(net);
> 
>-	mutex_lock(&ipvs->service_mutex);
>+	rcu_read_lock();
> 
> 	/* Try to find the service for which to dump destinations */
> 	if (nlmsg_parse_deprecated(cb->nlh, GENL_HDRLEN, attrs, IPVS_CMD_ATTR_MAX, ip_vs_cmd_policy, cb->extack))
>@@ -3599,7 +3595,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
> 		goto out_err;
> 
> 	/* Dump the destinations */
>-	list_for_each_entry(dest, &svc->destinations, n_list) {
>+	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
> 		if (++idx <= start)
> 			continue;
> 		if (ip_vs_genl_dump_dest(skb, dest, cb) < 0) {
>@@ -3612,7 +3608,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
> 	cb->args[0] = idx;
> 
> out_err:
>-	mutex_unlock(&ipvs->service_mutex);
>+	rcu_read_unlock();
> 
> 	return skb->len;
> }
>@@ -3915,9 +3911,12 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
> 	if (cmd == IPVS_CMD_NEW_SERVICE || cmd == IPVS_CMD_SET_SERVICE)
> 		need_full_svc = true;
> 
>+	/* We use function that requires RCU lock */
>+	rcu_read_lock();
> 	ret = ip_vs_genl_parse_service(ipvs, &usvc,
> 				       info->attrs[IPVS_CMD_ATTR_SERVICE],
> 				       need_full_svc, &svc);
>+	rcu_read_unlock();
> 	if (ret)
> 		goto out;
> 
>@@ -4037,7 +4036,7 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
> 	if (!msg)
> 		return -ENOMEM;
> 
>-	mutex_lock(&ipvs->service_mutex);
>+	rcu_read_lock();
> 
> 	reply = genlmsg_put_reply(msg, info, &ip_vs_genl_family, 0, reply_cmd);
> 	if (reply == NULL)
>@@ -4105,7 +4104,7 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
> out_err:
> 	nlmsg_free(msg);
> out:
>-	mutex_unlock(&ipvs->service_mutex);
>+	rcu_read_unlock();
> 
> 	return ret;
> }
>-- 
>2.51.0
>
