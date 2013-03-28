From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 12/15] ipvs: convert locks used in persistence engines
Date: Thu, 28 Mar 2013 14:39:41 +0900
Message-ID: <1364449184-26672-13-git-send-email-horms@verge.net.au>
References: <1364449184-26672-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1364449184-26672-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

Allow the readers to use RCU lock and for
PE module registrations use global mutex instead of
spinlock. All PE modules need to use synchronize_rcu
in their module exit handler.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_pe.c     |   43 +++++++++++--------------------------
 net/netfilter/ipvs/ip_vs_pe_sip.c |    1 +
 2 files changed, 14 insertions(+), 30 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_pe.c b/net/netfilter/ipvs/ip_vs_pe.c
index 5cf859c..5d9774c 100644
--- a/net/netfilter/ipvs/ip_vs_pe.c
+++ b/net/netfilter/ipvs/ip_vs_pe.c
@@ -13,8 +13,8 @@
 /* IPVS pe list */
 static LIST_HEAD(ip_vs_pe);
 
-/* lock for service table */
-static DEFINE_SPINLOCK(ip_vs_pe_lock);
+/* semaphore for IPVS PEs. */
+static DEFINE_MUTEX(ip_vs_pe_mutex);
 
 /* Bind a service with a pe */
 void ip_vs_bind_pe(struct ip_vs_service *svc, struct ip_vs_pe *pe)
@@ -36,9 +36,8 @@ struct ip_vs_pe *__ip_vs_pe_getbyname(const char *pe_name)
 	IP_VS_DBG(10, "%s(): pe_name \"%s\"\n", __func__,
 		  pe_name);
 
-	spin_lock_bh(&ip_vs_pe_lock);
-
-	list_for_each_entry(pe, &ip_vs_pe, n_list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(pe, &ip_vs_pe, n_list) {
 		/* Test and get the modules atomically */
 		if (pe->module &&
 		    !try_module_get(pe->module)) {
@@ -47,14 +46,14 @@ struct ip_vs_pe *__ip_vs_pe_getbyname(const char *pe_name)
 		}
 		if (strcmp(pe_name, pe->name)==0) {
 			/* HIT */
-			spin_unlock_bh(&ip_vs_pe_lock);
+			rcu_read_unlock();
 			return pe;
 		}
 		if (pe->module)
 			module_put(pe->module);
 	}
+	rcu_read_unlock();
 
-	spin_unlock_bh(&ip_vs_pe_lock);
 	return NULL;
 }
 
@@ -83,22 +82,13 @@ int register_ip_vs_pe(struct ip_vs_pe *pe)
 	/* increase the module use count */
 	ip_vs_use_count_inc();
 
-	spin_lock_bh(&ip_vs_pe_lock);
-
-	if (!list_empty(&pe->n_list)) {
-		spin_unlock_bh(&ip_vs_pe_lock);
-		ip_vs_use_count_dec();
-		pr_err("%s(): [%s] pe already linked\n",
-		       __func__, pe->name);
-		return -EINVAL;
-	}
-
+	mutex_lock(&ip_vs_pe_mutex);
 	/* Make sure that the pe with this name doesn't exist
 	 * in the pe list.
 	 */
 	list_for_each_entry(tmp, &ip_vs_pe, n_list) {
 		if (strcmp(tmp->name, pe->name) == 0) {
-			spin_unlock_bh(&ip_vs_pe_lock);
+			mutex_unlock(&ip_vs_pe_mutex);
 			ip_vs_use_count_dec();
 			pr_err("%s(): [%s] pe already existed "
 			       "in the system\n", __func__, pe->name);
@@ -106,8 +96,8 @@ int register_ip_vs_pe(struct ip_vs_pe *pe)
 		}
 	}
 	/* Add it into the d-linked pe list */
-	list_add(&pe->n_list, &ip_vs_pe);
-	spin_unlock_bh(&ip_vs_pe_lock);
+	list_add_rcu(&pe->n_list, &ip_vs_pe);
+	mutex_unlock(&ip_vs_pe_mutex);
 
 	pr_info("[%s] pe registered.\n", pe->name);
 
@@ -118,17 +108,10 @@ EXPORT_SYMBOL_GPL(register_ip_vs_pe);
 /* Unregister a pe from the pe list */
 int unregister_ip_vs_pe(struct ip_vs_pe *pe)
 {
-	spin_lock_bh(&ip_vs_pe_lock);
-	if (list_empty(&pe->n_list)) {
-		spin_unlock_bh(&ip_vs_pe_lock);
-		pr_err("%s(): [%s] pe is not in the list. failed\n",
-		       __func__, pe->name);
-		return -EINVAL;
-	}
-
+	mutex_lock(&ip_vs_pe_mutex);
 	/* Remove it from the d-linked pe list */
-	list_del(&pe->n_list);
-	spin_unlock_bh(&ip_vs_pe_lock);
+	list_del_rcu(&pe->n_list);
+	mutex_unlock(&ip_vs_pe_mutex);
 
 	/* decrease the module use count */
 	ip_vs_use_count_dec();
diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/ip_vs_pe_sip.c
index 12475ef..00cc024 100644
--- a/net/netfilter/ipvs/ip_vs_pe_sip.c
+++ b/net/netfilter/ipvs/ip_vs_pe_sip.c
@@ -172,6 +172,7 @@ static int __init ip_vs_sip_init(void)
 static void __exit ip_vs_sip_cleanup(void)
 {
 	unregister_ip_vs_pe(&ip_vs_sip_pe);
+	synchronize_rcu();
 }
 
 module_init(ip_vs_sip_init);
-- 
1.7.10.4
