From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH RFC net-next 03/14] ipvs: some service readers can use RCU
Date: Tue, 15 Aug 2023 20:30:20 +0300
Message-ID: <20230815173031.168344-4-ja@ssi.bg>
References: <20230815173031.168344-1-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
        t=1692120736; bh=P48NNIbmKmKcUAIbpzuvb8YDGYAzwDxo+kEi4DdF/5U=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References;
        b=vbBpwtdjeDK5byZZ4+xvrDb5EMI7c2hTio/JeihI4XY3rfIF7lq6AYiW7LV1DNzeS
         bmeYGSbygNRvc9qYiDF4W+4TXvgVJw60FezAjOutdVfyr9fVYY5qdHdLpA9vmgIJ2M
         SwuAAgKOZtBTgs/HnWbo8nqW7UVfFImFjCBqiL+Y=
In-Reply-To: <20230815173031.168344-1-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, "Paul E . McKenney" <paulmck@kernel.org>, rcu@vger.kernel.org, Dust Li <dust.li@linux.alibaba.com>, Jiejian Wu <jiejian@linux.alibaba.com>, Jiri Wiesner <jwiesner@suse.de>

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
index e5ae4fac8ec9..276fdc31e938 100644
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
@@ -3314,9 +3312,9 @@ static int ip_vs_genl_fill_service(struct sk_buff *skb,
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
@@ -3370,9 +3368,9 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
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
@@ -3383,7 +3381,7 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
 	}
 
 	for (i = 0; i < IP_VS_SVC_TAB_SIZE; i++) {
-		hlist_for_each_entry(svc, &ipvs->svc_fwm_table[i], f_list) {
+		hlist_for_each_entry_rcu(svc, &ipvs->svc_fwm_table[i], f_list) {
 			if (++idx <= start)
 				continue;
 			if (ip_vs_genl_dump_service(skb, svc, cb) < 0) {
@@ -3394,7 +3392,7 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
 	}
 
 nla_put_failure:
-	mutex_unlock(&ipvs->service_mutex);
+	rcu_read_unlock();
 	cb->args[0] = idx;
 
 	return skb->len;
@@ -3450,13 +3448,11 @@ static int ip_vs_genl_parse_service(struct netns_ipvs *ipvs,
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
@@ -3583,7 +3579,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
 	struct net *net = sock_net(skb->sk);
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	mutex_lock(&ipvs->service_mutex);
+	rcu_read_lock();
 
 	/* Try to find the service for which to dump destinations */
 	if (nlmsg_parse_deprecated(cb->nlh, GENL_HDRLEN, attrs, IPVS_CMD_ATTR_MAX, ip_vs_cmd_policy, cb->extack))
@@ -3595,7 +3591,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
 		goto out_err;
 
 	/* Dump the destinations */
-	list_for_each_entry(dest, &svc->destinations, n_list) {
+	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
 		if (++idx <= start)
 			continue;
 		if (ip_vs_genl_dump_dest(skb, dest, cb) < 0) {
@@ -3608,7 +3604,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
 	cb->args[0] = idx;
 
 out_err:
-	mutex_unlock(&ipvs->service_mutex);
+	rcu_read_unlock();
 
 	return skb->len;
 }
@@ -3914,9 +3910,12 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
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
2.41.0


