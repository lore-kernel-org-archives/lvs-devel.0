Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="CqLLstQS"
Received: from mg.ssi.bg (mg.ssi.bg [193.238.174.37])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 34C5ACA
	for <lvs-devel@vger.kernel.org>; Tue, 12 Dec 2023 08:30:35 -0800 (PST)
Received: from mg.bb.i.ssi.bg (localhost [127.0.0.1])
	by mg.bb.i.ssi.bg (Proxmox) with ESMTP id C89101DE61;
	Tue, 12 Dec 2023 18:30:33 +0200 (EET)
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mg.bb.i.ssi.bg (Proxmox) with ESMTPS id AF6411E1EB;
	Tue, 12 Dec 2023 18:30:33 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id 9F9AE3C07D4;
	Tue, 12 Dec 2023 18:30:12 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1702398612; bh=6oS6oaiXaH8VvLRUr8oQsy8y5zEHQigzNWQOB4Hy/zM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=CqLLstQSigIAzOSRX6FJAwhG3qopzVykWsVEqTkKYBA4fCgfEVbzgMkIz7kc/ds4r
	 Wy1HaUpPF15MsEEUGaipQqpLb8dQvuAvjcbk2ykGzrkmhfmmfBq2ppcpBoDfp5LKLj
	 TJNgDaXuJlailitNTXrS8mDe5rXBmePu5PRCmlwk=
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.17.1/8.17.1) with ESMTP id 3BCGQUo2094058;
	Tue, 12 Dec 2023 18:26:30 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.17.1/8.17.1/Submit) id 3BCGQUKS094057;
	Tue, 12 Dec 2023 18:26:30 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org, Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>,
        Jiri Wiesner <jwiesner@suse.de>
Subject: [PATCHv2 RFC net-next 03/14] ipvs: some service readers can use RCU
Date: Tue, 12 Dec 2023 18:24:33 +0200
Message-ID: <20231212162444.93801-4-ja@ssi.bg>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20231212162444.93801-1-ja@ssi.bg>
References: <20231212162444.93801-1-ja@ssi.bg>
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
2.43.0


