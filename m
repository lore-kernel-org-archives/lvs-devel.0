From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 17/34] ipvs: preparations for using rcu in schedulers
Date: Fri, 29 Mar 2013 13:11:34 +0900
Message-ID: <1364530311-11512-18-git-send-email-horms@verge.net.au>
References: <1364530311-11512-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1364530311-11512-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

Allow schedulers to use rcu_dereference when
returning destination on lookup. The RCU read-side critical
section will allow ip_vs_bind_dest to get dest refcnt as
preparation for the step where destinations will be
deleted without an IP_VS_WAIT_WHILE guard that holds the
packet processing during update.

	Add new optional scheduler methods add_dest,
del_dest and upd_dest. For now the methods are called
together with update_service but update_service will be
removed in a following change.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             |    6 ++++++
 net/netfilter/ipvs/ip_vs_core.c |    6 ++++++
 net/netfilter/ipvs/ip_vs_ctl.c  |    8 ++++++++
 3 files changed, 20 insertions(+)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 43886bb..d91385c 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -805,6 +805,12 @@ struct ip_vs_scheduler {
 	int (*done_service)(struct ip_vs_service *svc);
 	/* scheduler updating service */
 	int (*update_service)(struct ip_vs_service *svc);
+	/* dest is linked */
+	int (*add_dest)(struct ip_vs_service *svc, struct ip_vs_dest *dest);
+	/* dest is unlinked */
+	int (*del_dest)(struct ip_vs_service *svc, struct ip_vs_dest *dest);
+	/* dest is updated */
+	int (*upd_dest)(struct ip_vs_service *svc, struct ip_vs_dest *dest);
 
 	/* selecting a server from the given service */
 	struct ip_vs_dest* (*schedule)(struct ip_vs_service *svc,
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 4fc749c..939ad11 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -301,8 +301,10 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 		 * template is not available.
 		 * return *ignored=0 i.e. ICMP and NF_DROP
 		 */
+		rcu_read_lock();
 		dest = svc->scheduler->schedule(svc, skb);
 		if (!dest) {
+			rcu_read_unlock();
 			IP_VS_DBG(1, "p-schedule: no dest found.\n");
 			kfree(param.pe_data);
 			*ignored = 0;
@@ -318,6 +320,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 		 * when the template expires */
 		ct = ip_vs_conn_new(&param, &dest->addr, dport,
 				    IP_VS_CONN_F_TEMPLATE, dest, skb->mark);
+		rcu_read_unlock();
 		if (ct == NULL) {
 			kfree(param.pe_data);
 			*ignored = -1;
@@ -446,8 +449,10 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 		return NULL;
 	}
 
+	rcu_read_lock();
 	dest = svc->scheduler->schedule(svc, skb);
 	if (dest == NULL) {
+		rcu_read_unlock();
 		IP_VS_DBG(1, "Schedule: no dest found.\n");
 		return NULL;
 	}
@@ -468,6 +473,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 		cp = ip_vs_conn_new(&p, &dest->addr,
 				    dest->port ? dest->port : pptr[1],
 				    flags, dest, skb->mark);
+		rcu_read_unlock();
 		if (!cp) {
 			*ignored = -1;
 			return NULL;
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 182d958..d64f800 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -825,6 +825,11 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	if (add) {
 		list_add(&dest->n_list, &svc->destinations);
 		svc->num_dests++;
+		if (svc->scheduler->add_dest)
+			svc->scheduler->add_dest(svc, dest);
+	} else {
+		if (svc->scheduler->upd_dest)
+			svc->scheduler->upd_dest(svc, dest);
 	}
 
 	/* call the update_service, because server weight may be changed */
@@ -1071,6 +1076,9 @@ static void __ip_vs_unlink_dest(struct ip_vs_service *svc,
 	list_del(&dest->n_list);
 	svc->num_dests--;
 
+	if (svcupd && svc->scheduler->del_dest)
+		svc->scheduler->del_dest(svc, dest);
+
 	/*
 	 *  Call the update_service function of its scheduler
 	 */
-- 
1.7.10.4

