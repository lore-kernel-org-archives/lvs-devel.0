Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 43347189F43;
	Sat, 14 Feb 2026 15:17:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771082278; cv=none; b=taeMfAvgQEiSbKyj3iu7F56TvVbnzH/rA2H3QMu3NYTNLOmCO8xEsAou5GlMLnjsdHy1FQaDGR7YAcg6wJBvWE8NxXJFyeUSQzze/7XdJ3MmXj1YYUjy0JdKZNwLew1QV7n+u/Lxy4Z5JSOxzyL3xBP7kBQF9K2iJrJ9kJ3WIzc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771082278; c=relaxed/simple;
	bh=BxyoGBXLKGdmtN9ri17uOhBVH5ThPhTsEnqBkCisJuI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=MGWri5DcbapoBvau7GD/rLNkU+KO/FwXBR3K1bVwUvy3lUsKrpE02VNHdMwMISju4BMAzPqBgLGaGju2FahWAaS3ZYB8aZJrW6ZnQ2xt2dmVUvthGydNTEqnRXclAxHMKG5LpS1HA1Fldnmgy8Dn5riufCElY01aL7cQh58m/uM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=Z/nmAHzp; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="Z/nmAHzp"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 689A621D6D;
	Sat, 14 Feb 2026 17:17:48 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=XhIyr/dv1oRX8rqqq9SfJV+/BRMIGevUcG+ALFFgjuE=; b=Z/nmAHzprgjI
	Yt4ivkljj21dbmXXdpbMaMmRUslWPcYU1qSPtUY9lDoWWJoOFzzrNuovOpEVU19t
	EAfu/QiN5tCnnYN4LBXnquTflgxfoYnfZx/5gjgIi8x1h7MoFKPTMiKWvhKpJEqR
	+gg919oHJ1/pLrGC0w+/zvnZKCtg5x1xCtg8As3W/sM5b+9E15BtrUJpbMEiQAYS
	M7u1Yt/NucN4BIRG8TN7gvJAkBZkzZVJ9sJ8LbYGPhY9cQNdfaT5xXlDf2Rdq4J9
	kaBJa6BlVazRaqzvKnM7LM0GdBaYtuxCV0nqpG6bJDEGuh4swXKneYo6xYAff9+C
	wmCodoJV5Ktb98KajpDebCHYC++pkn/ncFgzQHNI0nxVPOVcWCLZUHzTv6K6vc+o
	uK99qxuLoNNbWzgPxM1HVLFtNw136YCS8xEqg/52lQ31/gYZmvNCvn0GqRlbqdqb
	HJ+e7tSwc7R/nb1nz6H/yh8lkU0A7PHRYFtx4NPWaPP3FbDLQCndmPIHuBcV7jCz
	oCm9cD60WdKbP2lkt6lfvBITDrDd/Fc0w3hACBkJza8R2yqbxze6ulAiHD/KxUqk
	8ewv4FjL8jvQJkO/qFNTDuCLpUqoj4/yujzryUuRbmE7NNIRmfwxtft7C+W3mI5H
	1Y1HO9qJBA2qFkyKFIqOS79/GbfomHA=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat, 14 Feb 2026 17:17:46 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 39DAC61B7A;
	Sat, 14 Feb 2026 17:17:46 +0200 (EET)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 61EFCvDt019350;
	Sat, 14 Feb 2026 17:12:57 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 61EFCvmI019349;
	Sat, 14 Feb 2026 17:12:57 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>
Subject: [PATCH nf-next 2/6] ipvs: some service readers can use RCU
Date: Sat, 14 Feb 2026 17:12:26 +0200
Message-ID: <20260214151230.18970-3-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260214151230.18970-1-ja@ssi.bg>
References: <20260214151230.18970-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Some places walk the services under mutex but they can just use RCU:

* ip_vs_dst_event() uses ip_vs_forget_dev() which uses its own lock
  to modify dest
* ip_vs_genl_dump_services(): ip_vs_genl_fill_service() just fills skb
* ip_vs_genl_parse_service(): move RCU lock to callers
  ip_vs_genl_set_cmd(), ip_vs_genl_dump_dests() and ip_vs_genl_get_cmd()
* ip_vs_genl_dump_dests(): just fill skb

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Reviewed-by: Dust Li <dust.li@linux.alibaba.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 47 +++++++++++++++++-----------------
 1 file changed, 23 insertions(+), 24 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index d871273ce917..b9eaf048a29f 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1758,23 +1758,21 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
 	if (event != NETDEV_DOWN || !ipvs)
 		return NOTIFY_DONE;
 	IP_VS_DBG(3, "%s() dev=%s\n", __func__, dev->name);
-	mutex_lock(&ipvs->service_mutex);
+	rcu_read_lock();
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		hlist_for_each_entry(svc, &ipvs->svc_table[idx], s_list) {
-			list_for_each_entry(dest, &svc->destinations,
-					    n_list) {
+		hlist_for_each_entry_rcu(svc, &ipvs->svc_table[idx], s_list)
+			list_for_each_entry_rcu(dest, &svc->destinations,
+						n_list)
 				ip_vs_forget_dev(dest, dev);
-			}
-		}
 
-		hlist_for_each_entry(svc, &ipvs->svc_fwm_table[idx], f_list) {
-			list_for_each_entry(dest, &svc->destinations,
-					    n_list) {
+		hlist_for_each_entry_rcu(svc, &ipvs->svc_fwm_table[idx], f_list)
+			list_for_each_entry_rcu(dest, &svc->destinations,
+						n_list)
 				ip_vs_forget_dev(dest, dev);
-			}
-		}
 	}
+	rcu_read_unlock();
 
+	mutex_lock(&ipvs->service_mutex);
 	spin_lock_bh(&ipvs->dest_trash_lock);
 	list_for_each_entry(dest, &ipvs->dest_trash, t_list) {
 		ip_vs_forget_dev(dest, dev);
@@ -3317,9 +3315,9 @@ static int ip_vs_genl_fill_service(struct sk_buff *skb,
 			goto nla_put_failure;
 	}
 
-	sched = rcu_dereference_protected(svc->scheduler, 1);
+	sched = rcu_dereference(svc->scheduler);
 	sched_name = sched ? sched->name : "none";
-	pe = rcu_dereference_protected(svc->pe, 1);
+	pe = rcu_dereference(svc->pe);
 	if (nla_put_string(skb, IPVS_SVC_ATTR_SCHED_NAME, sched_name) ||
 	    (pe && nla_put_string(skb, IPVS_SVC_ATTR_PE_NAME, pe->name)) ||
 	    nla_put(skb, IPVS_SVC_ATTR_FLAGS, sizeof(flags), &flags) ||
@@ -3373,9 +3371,9 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
 	struct net *net = sock_net(skb->sk);
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	mutex_lock(&ipvs->service_mutex);
+	rcu_read_lock();
 	for (i = 0; i < IP_VS_SVC_TAB_SIZE; i++) {
-		hlist_for_each_entry(svc, &ipvs->svc_table[i], s_list) {
+		hlist_for_each_entry_rcu(svc, &ipvs->svc_table[i], s_list) {
 			if (++idx <= start)
 				continue;
 			if (ip_vs_genl_dump_service(skb, svc, cb) < 0) {
@@ -3386,7 +3384,7 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
 	}
 
 	for (i = 0; i < IP_VS_SVC_TAB_SIZE; i++) {
-		hlist_for_each_entry(svc, &ipvs->svc_fwm_table[i], f_list) {
+		hlist_for_each_entry_rcu(svc, &ipvs->svc_fwm_table[i], f_list) {
 			if (++idx <= start)
 				continue;
 			if (ip_vs_genl_dump_service(skb, svc, cb) < 0) {
@@ -3397,7 +3395,7 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
 	}
 
 nla_put_failure:
-	mutex_unlock(&ipvs->service_mutex);
+	rcu_read_unlock();
 	cb->args[0] = idx;
 
 	return skb->len;
@@ -3453,13 +3451,11 @@ static int ip_vs_genl_parse_service(struct netns_ipvs *ipvs,
 		usvc->fwmark = 0;
 	}
 
-	rcu_read_lock();
 	if (usvc->fwmark)
 		svc = __ip_vs_svc_fwm_find(ipvs, usvc->af, usvc->fwmark);
 	else
 		svc = __ip_vs_service_find(ipvs, usvc->af, usvc->protocol,
 					   &usvc->addr, usvc->port);
-	rcu_read_unlock();
 	*ret_svc = svc;
 
 	/* If a full entry was requested, check for the additional fields */
@@ -3586,7 +3582,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
 	struct net *net = sock_net(skb->sk);
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	mutex_lock(&ipvs->service_mutex);
+	rcu_read_lock();
 
 	/* Try to find the service for which to dump destinations */
 	if (nlmsg_parse_deprecated(cb->nlh, GENL_HDRLEN, attrs, IPVS_CMD_ATTR_MAX, ip_vs_cmd_policy, cb->extack))
@@ -3598,7 +3594,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
 		goto out_err;
 
 	/* Dump the destinations */
-	list_for_each_entry(dest, &svc->destinations, n_list) {
+	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
 		if (++idx <= start)
 			continue;
 		if (ip_vs_genl_dump_dest(skb, dest, cb) < 0) {
@@ -3611,7 +3607,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
 	cb->args[0] = idx;
 
 out_err:
-	mutex_unlock(&ipvs->service_mutex);
+	rcu_read_unlock();
 
 	return skb->len;
 }
@@ -3914,9 +3910,12 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 	if (cmd == IPVS_CMD_NEW_SERVICE || cmd == IPVS_CMD_SET_SERVICE)
 		need_full_svc = true;
 
+	/* We use function that requires RCU lock (hlist_bl) */
+	rcu_read_lock();
 	ret = ip_vs_genl_parse_service(ipvs, &usvc,
 				       info->attrs[IPVS_CMD_ATTR_SERVICE],
 				       need_full_svc, &svc);
+	rcu_read_unlock();
 	if (ret)
 		goto out;
 
@@ -4036,7 +4035,7 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 	if (!msg)
 		return -ENOMEM;
 
-	mutex_lock(&ipvs->service_mutex);
+	rcu_read_lock();
 
 	reply = genlmsg_put_reply(msg, info, &ip_vs_genl_family, 0, reply_cmd);
 	if (reply == NULL)
@@ -4104,7 +4103,7 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 out_err:
 	nlmsg_free(msg);
 out:
-	mutex_unlock(&ipvs->service_mutex);
+	rcu_read_unlock();
 
 	return ret;
 }
-- 
2.53.0


