Received: from mg.ssi.bg (mg.ssi.bg [193.238.174.37])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ABC7E144D27;
	Sun, 31 Mar 2024 14:07:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.37
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1711894045; cv=none; b=CykYZKykumR606CexxLgEHmvO/M4MNS1CrgQhcqwLC5762mt7aKqVWKEkqLqx5opRCw80LjDlSwkOu4l/y4+pOJG1UPOrSzyey0+4TEsGFXJnBl+hbJJQrDYqgIXAHZH2I8dfa2QLe1vhBO8HUT5Bfe5DaR7ZttxOW+c/Nyo0Jk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1711894045; c=relaxed/simple;
	bh=3Q/XkYHsvyTTpJ0Vi8xNH46X7LQQry/XQR9V/MnBCdc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=KrwGXeVHx8whMs/U1y/a9EJR35j9YYq8lSzxQyH71QNia48YR3sEM/EQ+bu1UjAvDmZYyQa90n/ZlUzCMcSNvchGRmEPE6FZBhWsSN4HSuSIdh1WF6y7WFxvq8weYdHeBRofmRxhkPJKkHOQR1probM4SbTP/FgmYipGCJB9ahU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=C6+GB5Tg; arc=none smtp.client-ip=193.238.174.37
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="C6+GB5Tg"
Received: from mg.ssi.bg (localhost [127.0.0.1])
	by mg.ssi.bg (Proxmox) with ESMTP id F0A8231DBD;
	Sun, 31 Mar 2024 17:07:21 +0300 (EEST)
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mg.ssi.bg (Proxmox) with ESMTPS id C868D31D4A;
	Sun, 31 Mar 2024 17:07:20 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id 704FD900DD4;
	Sun, 31 Mar 2024 17:07:04 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1711894024; bh=3Q/XkYHsvyTTpJ0Vi8xNH46X7LQQry/XQR9V/MnBCdc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=C6+GB5Tg52bXy0gI6yBfLx+YHEI0020wK07jBLG2WR8HFZZ7dGkeszq5U/B5NPLtm
	 8845JbCAVCiIj98Ad7cuIP4agamRDE7CbZToZdrmxugbLUaDD8y32XMWd+qgZtjQNI
	 sVGX79obfZn+HYz80W0/ewSpEUoZfHa+3Fe6UVQk=
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.17.1/8.17.1) with ESMTP id 42VE44lt077700;
	Sun, 31 Mar 2024 17:04:04 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.17.1/8.17.1/Submit) id 42VE44QM077699;
	Sun, 31 Mar 2024 17:04:04 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: [PATCHv3 net-next 03/14] ipvs: some service readers can use RCU
Date: Sun, 31 Mar 2024 17:03:50 +0300
Message-ID: <20240331140401.77657-4-ja@ssi.bg>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20240331140401.77657-1-ja@ssi.bg>
References: <20240331140401.77657-1-ja@ssi.bg>
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
---
 net/netfilter/ipvs/ip_vs_ctl.c | 47 +++++++++++++++++-----------------
 1 file changed, 23 insertions(+), 24 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 7189bf6bd371..268a71f6aa97 100644
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
@@ -3917,9 +3913,12 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 	if (cmd == IPVS_CMD_NEW_SERVICE || cmd == IPVS_CMD_SET_SERVICE)
 		need_full_svc = true;
 
+	/* We use function that requires RCU lock */
+	rcu_read_lock();
 	ret = ip_vs_genl_parse_service(ipvs, &usvc,
 				       info->attrs[IPVS_CMD_ATTR_SERVICE],
 				       need_full_svc, &svc);
+	rcu_read_unlock();
 	if (ret)
 		goto out;
 
@@ -4039,7 +4038,7 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 	if (!msg)
 		return -ENOMEM;
 
-	mutex_lock(&ipvs->service_mutex);
+	rcu_read_lock();
 
 	reply = genlmsg_put_reply(msg, info, &ip_vs_genl_family, 0, reply_cmd);
 	if (reply == NULL)
@@ -4107,7 +4106,7 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 out_err:
 	nlmsg_free(msg);
 out:
-	mutex_unlock(&ipvs->service_mutex);
+	rcu_read_unlock();
 
 	return ret;
 }
-- 
2.44.0


