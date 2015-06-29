From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCHv2 3.10.81] ipvs: fix crash if scheduler is changed
Date: Mon, 29 Jun 2015 21:52:03 +0300
Message-ID: <1435603923-6342-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Alexander Vasiliev <a.vasylev@404-group.com>

I overlooked the svc->sched_data usage from schedulers
when the services were converted to RCU in 3.10. Now
the rare ipvsadm -E command can change the scheduler
but due to the reverse order of ip_vs_bind_scheduler
and ip_vs_unbind_scheduler we provide new sched_data
to the old scheduler resulting in a crash.

To fix it without changing the scheduler methods we
have to use synchronize_rcu() only for the editing case.
It means all svc->scheduler readers should expect a
NULL value. To avoid breakage for the service listing
and ipvsadm -R we can use the "none" name to indicate
that scheduler is not assigned, a state when we drop
new connections.

Reported-by: Alexander Vasiliev <a.vasylev@404-group.com>
Fixes: ceec4c381681 ("ipvs: convert services to rcu")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_core.c  | 16 +++++++--
 net/netfilter/ipvs/ip_vs_ctl.c   | 78 +++++++++++++++++++++++++---------------
 net/netfilter/ipvs/ip_vs_sched.c | 12 +++----
 3 files changed, 69 insertions(+), 37 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 1c6a71c..72957fb 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -305,7 +305,13 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 		 * return *ignored=0 i.e. ICMP and NF_DROP
 		 */
 		sched = rcu_dereference(svc->scheduler);
-		dest = sched->schedule(svc, skb);
+		if (sched) {
+			/* read svc->sched_data after svc->scheduler */
+			smp_rmb();
+			dest = sched->schedule(svc, skb);
+		} else {
+			dest = NULL;
+		}
 		if (!dest) {
 			IP_VS_DBG(1, "p-schedule: no dest found.\n");
 			kfree(param.pe_data);
@@ -452,7 +458,13 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	}
 
 	sched = rcu_dereference(svc->scheduler);
-	dest = sched->schedule(svc, skb);
+	if (sched) {
+		/* read svc->sched_data after svc->scheduler */
+		smp_rmb();
+		dest = sched->schedule(svc, skb);
+	} else {
+		dest = NULL;
+	}
 	if (dest == NULL) {
 		IP_VS_DBG(1, "Schedule: no dest found.\n");
 		return NULL;
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 9e6c2a0..d883b2c 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -814,15 +814,16 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	__ip_vs_dst_cache_reset(dest);
 	spin_unlock_bh(&dest->dst_lock);
 
-	sched = rcu_dereference_protected(svc->scheduler, 1);
 	if (add) {
 		ip_vs_start_estimator(svc->net, &dest->stats);
 		list_add_rcu(&dest->n_list, &svc->destinations);
 		svc->num_dests++;
-		if (sched->add_dest)
+		sched = rcu_dereference_protected(svc->scheduler, 1);
+		if (sched && sched->add_dest)
 			sched->add_dest(svc, dest);
 	} else {
-		if (sched->upd_dest)
+		sched = rcu_dereference_protected(svc->scheduler, 1);
+		if (sched && sched->upd_dest)
 			sched->upd_dest(svc, dest);
 	}
 }
@@ -1061,7 +1062,7 @@ static void __ip_vs_unlink_dest(struct ip_vs_service *svc,
 		struct ip_vs_scheduler *sched;
 
 		sched = rcu_dereference_protected(svc->scheduler, 1);
-		if (sched->del_dest)
+		if (sched && sched->del_dest)
 			sched->del_dest(svc, dest);
 	}
 }
@@ -1146,11 +1147,14 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 	ip_vs_use_count_inc();
 
 	/* Lookup the scheduler by 'u->sched_name' */
-	sched = ip_vs_scheduler_get(u->sched_name);
-	if (sched == NULL) {
-		pr_info("Scheduler module ip_vs_%s not found\n", u->sched_name);
-		ret = -ENOENT;
-		goto out_err;
+	if (strcmp(u->sched_name, "none")) {
+		sched = ip_vs_scheduler_get(u->sched_name);
+		if (!sched) {
+			pr_info("Scheduler module ip_vs_%s not found\n",
+				u->sched_name);
+			ret = -ENOENT;
+			goto out_err;
+		}
 	}
 
 	if (u->pe_name && *u->pe_name) {
@@ -1204,10 +1208,12 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 	spin_lock_init(&svc->stats.lock);
 
 	/* Bind the scheduler */
-	ret = ip_vs_bind_scheduler(svc, sched);
-	if (ret)
-		goto out_err;
-	sched = NULL;
+	if (sched) {
+		ret = ip_vs_bind_scheduler(svc, sched);
+		if (ret)
+			goto out_err;
+		sched = NULL;
+	}
 
 	/* Bind the ct retriever */
 	RCU_INIT_POINTER(svc->pe, pe);
@@ -1255,17 +1261,20 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 static int
 ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
 {
-	struct ip_vs_scheduler *sched, *old_sched;
+	struct ip_vs_scheduler *sched = NULL, *old_sched;
 	struct ip_vs_pe *pe = NULL, *old_pe = NULL;
 	int ret = 0;
 
 	/*
 	 * Lookup the scheduler, by 'u->sched_name'
 	 */
-	sched = ip_vs_scheduler_get(u->sched_name);
-	if (sched == NULL) {
-		pr_info("Scheduler module ip_vs_%s not found\n", u->sched_name);
-		return -ENOENT;
+	if (strcmp(u->sched_name, "none")) {
+		sched = ip_vs_scheduler_get(u->sched_name);
+		if (!sched) {
+			pr_info("Scheduler module ip_vs_%s not found\n",
+				u->sched_name);
+			return -ENOENT;
+		}
 	}
 	old_sched = sched;
 
@@ -1293,14 +1302,20 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
 
 	old_sched = rcu_dereference_protected(svc->scheduler, 1);
 	if (sched != old_sched) {
+		if (old_sched) {
+			ip_vs_unbind_scheduler(svc, old_sched);
+			RCU_INIT_POINTER(svc->scheduler, NULL);
+			/* Wait all svc->sched_data users */
+			synchronize_rcu();
+		}
 		/* Bind the new scheduler */
-		ret = ip_vs_bind_scheduler(svc, sched);
-		if (ret) {
-			old_sched = sched;
-			goto out;
+		if (sched) {
+			ret = ip_vs_bind_scheduler(svc, sched);
+			if (ret) {
+				ip_vs_scheduler_put(sched);
+				goto out;
+			}
 		}
-		/* Unbind the old scheduler on success */
-		ip_vs_unbind_scheduler(svc, old_sched);
 	}
 
 	/*
@@ -2022,6 +2037,7 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
 		const struct ip_vs_iter *iter = seq->private;
 		const struct ip_vs_dest *dest;
 		struct ip_vs_scheduler *sched = rcu_dereference(svc->scheduler);
+		char *sched_name = sched ? sched->name : "none";
 
 		if (iter->table == ip_vs_svc_table) {
 #ifdef CONFIG_IP_VS_IPV6
@@ -2030,18 +2046,18 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
 					   ip_vs_proto_name(svc->protocol),
 					   &svc->addr.in6,
 					   ntohs(svc->port),
-					   sched->name);
+					   sched_name);
 			else
 #endif
 				seq_printf(seq, "%s  %08X:%04X %s %s ",
 					   ip_vs_proto_name(svc->protocol),
 					   ntohl(svc->addr.ip),
 					   ntohs(svc->port),
-					   sched->name,
+					   sched_name,
 					   (svc->flags & IP_VS_SVC_F_ONEPACKET)?"ops ":"");
 		} else {
 			seq_printf(seq, "FWM  %08X %s %s",
-				   svc->fwmark, sched->name,
+				   svc->fwmark, sched_name,
 				   (svc->flags & IP_VS_SVC_F_ONEPACKET)?"ops ":"");
 		}
 
@@ -2456,13 +2472,15 @@ static void
 ip_vs_copy_service(struct ip_vs_service_entry *dst, struct ip_vs_service *src)
 {
 	struct ip_vs_scheduler *sched;
+	char *sched_name;
 
 	sched = rcu_dereference_protected(src->scheduler, 1);
+	sched_name = sched ? sched->name : "none";
 	dst->protocol = src->protocol;
 	dst->addr = src->addr.ip;
 	dst->port = src->port;
 	dst->fwmark = src->fwmark;
-	strlcpy(dst->sched_name, sched->name, sizeof(dst->sched_name));
+	strlcpy(dst->sched_name, sched_name, sizeof(dst->sched_name));
 	dst->flags = src->flags;
 	dst->timeout = src->timeout / HZ;
 	dst->netmask = src->netmask;
@@ -2888,6 +2906,7 @@ static int ip_vs_genl_fill_service(struct sk_buff *skb,
 	struct nlattr *nl_service;
 	struct ip_vs_flags flags = { .flags = svc->flags,
 				     .mask = ~0 };
+	char *sched_name;
 
 	nl_service = nla_nest_start(skb, IPVS_CMD_ATTR_SERVICE);
 	if (!nl_service)
@@ -2906,8 +2925,9 @@ static int ip_vs_genl_fill_service(struct sk_buff *skb,
 	}
 
 	sched = rcu_dereference_protected(svc->scheduler, 1);
+	sched_name = sched ? sched->name : "none";
 	pe = rcu_dereference_protected(svc->pe, 1);
-	if (nla_put_string(skb, IPVS_SVC_ATTR_SCHED_NAME, sched->name) ||
+	if (nla_put_string(skb, IPVS_SVC_ATTR_SCHED_NAME, sched_name) ||
 	    (pe && nla_put_string(skb, IPVS_SVC_ATTR_PE_NAME, pe->name)) ||
 	    nla_put(skb, IPVS_SVC_ATTR_FLAGS, sizeof(flags), &flags) ||
 	    nla_put_u32(skb, IPVS_SVC_ATTR_TIMEOUT, svc->timeout / HZ) ||
diff --git a/net/netfilter/ipvs/ip_vs_sched.c b/net/netfilter/ipvs/ip_vs_sched.c
index 4dbcda6..21b6b51 100644
--- a/net/netfilter/ipvs/ip_vs_sched.c
+++ b/net/netfilter/ipvs/ip_vs_sched.c
@@ -74,7 +74,7 @@ void ip_vs_unbind_scheduler(struct ip_vs_service *svc,
 
 	if (sched->done_service)
 		sched->done_service(svc);
-	/* svc->scheduler can not be set to NULL */
+	/* svc->scheduler can be set to NULL only by caller */
 }
 
 
@@ -148,21 +148,21 @@ void ip_vs_scheduler_put(struct ip_vs_scheduler *scheduler)
 
 void ip_vs_scheduler_err(struct ip_vs_service *svc, const char *msg)
 {
-	struct ip_vs_scheduler *sched;
+	struct ip_vs_scheduler *sched = rcu_dereference(svc->scheduler);
+	char *sched_name = sched ? sched->name : "none";
 
-	sched = rcu_dereference(svc->scheduler);
 	if (svc->fwmark) {
 		IP_VS_ERR_RL("%s: FWM %u 0x%08X - %s\n",
-			     sched->name, svc->fwmark, svc->fwmark, msg);
+			     sched_name, svc->fwmark, svc->fwmark, msg);
 #ifdef CONFIG_IP_VS_IPV6
 	} else if (svc->af == AF_INET6) {
 		IP_VS_ERR_RL("%s: %s [%pI6c]:%d - %s\n",
-			     sched->name, ip_vs_proto_name(svc->protocol),
+			     sched_name, ip_vs_proto_name(svc->protocol),
 			     &svc->addr.in6, ntohs(svc->port), msg);
 #endif
 	} else {
 		IP_VS_ERR_RL("%s: %s %pI4:%d - %s\n",
-			     sched->name, ip_vs_proto_name(svc->protocol),
+			     sched_name, ip_vs_proto_name(svc->protocol),
 			     &svc->addr.ip, ntohs(svc->port), msg);
 	}
 }
-- 
1.9.3

