From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 16/34] ipvs: change ip_vs_sched_lock to mutex
Date: Fri, 29 Mar 2013 13:11:33 +0900
Message-ID: <1364530311-11512-17-git-send-email-horms@verge.net.au>
References: <1364530311-11512-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1364530311-11512-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

The global list with schedulers ip_vs_schedulers
is accessed only from user context - configuration and
scheduler module [un]registration. Use ip_vs_sched_mutex
instead.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sched.c |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sched.c b/net/netfilter/ipvs/ip_vs_sched.c
index d6bf20d..7f11d3d 100644
--- a/net/netfilter/ipvs/ip_vs_sched.c
+++ b/net/netfilter/ipvs/ip_vs_sched.c
@@ -35,8 +35,8 @@ EXPORT_SYMBOL(ip_vs_scheduler_err);
  */
 static LIST_HEAD(ip_vs_schedulers);
 
-/* lock for service table */
-static DEFINE_SPINLOCK(ip_vs_sched_lock);
+/* semaphore for schedulers */
+static DEFINE_MUTEX(ip_vs_sched_mutex);
 
 
 /*
@@ -92,7 +92,7 @@ static struct ip_vs_scheduler *ip_vs_sched_getbyname(const char *sched_name)
 
 	IP_VS_DBG(2, "%s(): sched_name \"%s\"\n", __func__, sched_name);
 
-	spin_lock_bh(&ip_vs_sched_lock);
+	mutex_lock(&ip_vs_sched_mutex);
 
 	list_for_each_entry(sched, &ip_vs_schedulers, n_list) {
 		/*
@@ -106,14 +106,14 @@ static struct ip_vs_scheduler *ip_vs_sched_getbyname(const char *sched_name)
 		}
 		if (strcmp(sched_name, sched->name)==0) {
 			/* HIT */
-			spin_unlock_bh(&ip_vs_sched_lock);
+			mutex_unlock(&ip_vs_sched_mutex);
 			return sched;
 		}
 		if (sched->module)
 			module_put(sched->module);
 	}
 
-	spin_unlock_bh(&ip_vs_sched_lock);
+	mutex_unlock(&ip_vs_sched_mutex);
 	return NULL;
 }
 
@@ -192,10 +192,10 @@ int register_ip_vs_scheduler(struct ip_vs_scheduler *scheduler)
 	/* increase the module use count */
 	ip_vs_use_count_inc();
 
-	spin_lock_bh(&ip_vs_sched_lock);
+	mutex_lock(&ip_vs_sched_mutex);
 
 	if (!list_empty(&scheduler->n_list)) {
-		spin_unlock_bh(&ip_vs_sched_lock);
+		mutex_unlock(&ip_vs_sched_mutex);
 		ip_vs_use_count_dec();
 		pr_err("%s(): [%s] scheduler already linked\n",
 		       __func__, scheduler->name);
@@ -208,7 +208,7 @@ int register_ip_vs_scheduler(struct ip_vs_scheduler *scheduler)
 	 */
 	list_for_each_entry(sched, &ip_vs_schedulers, n_list) {
 		if (strcmp(scheduler->name, sched->name) == 0) {
-			spin_unlock_bh(&ip_vs_sched_lock);
+			mutex_unlock(&ip_vs_sched_mutex);
 			ip_vs_use_count_dec();
 			pr_err("%s(): [%s] scheduler already existed "
 			       "in the system\n", __func__, scheduler->name);
@@ -219,7 +219,7 @@ int register_ip_vs_scheduler(struct ip_vs_scheduler *scheduler)
 	 *	Add it into the d-linked scheduler list
 	 */
 	list_add(&scheduler->n_list, &ip_vs_schedulers);
-	spin_unlock_bh(&ip_vs_sched_lock);
+	mutex_unlock(&ip_vs_sched_mutex);
 
 	pr_info("[%s] scheduler registered.\n", scheduler->name);
 
@@ -237,9 +237,9 @@ int unregister_ip_vs_scheduler(struct ip_vs_scheduler *scheduler)
 		return -EINVAL;
 	}
 
-	spin_lock_bh(&ip_vs_sched_lock);
+	mutex_lock(&ip_vs_sched_mutex);
 	if (list_empty(&scheduler->n_list)) {
-		spin_unlock_bh(&ip_vs_sched_lock);
+		mutex_unlock(&ip_vs_sched_mutex);
 		pr_err("%s(): [%s] scheduler is not in the list. failed\n",
 		       __func__, scheduler->name);
 		return -EINVAL;
@@ -249,7 +249,7 @@ int unregister_ip_vs_scheduler(struct ip_vs_scheduler *scheduler)
 	 *	Remove it from the d-linked scheduler list
 	 */
 	list_del(&scheduler->n_list);
-	spin_unlock_bh(&ip_vs_sched_lock);
+	mutex_unlock(&ip_vs_sched_mutex);
 
 	/* decrease the module use count */
 	ip_vs_use_count_dec();
-- 
1.7.10.4

