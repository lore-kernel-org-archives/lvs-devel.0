From: Simon Horman <horms@verge.net.au>
Subject: [patch nf-next] IPVS: convert __ip_vs_sched_lock to a spinlock
Date: Fri, 20 Aug 2010 23:52:50 +0900
Message-ID: <20100820145249.GB11781@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Stephen Hemminger <shemminger@vyatta.com>, Eric Dumazet <eric.dumazet@gmail.com>, Changli Gao <xiaosuo@gmail.com>, yao zhao <dragonlinux@gmail.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

Also rename __ip_vs_sched_lock to ip_vs_sched_lock.

Signed-off-by: Simon Horman <horms@verge.net.au>

--- 

Compile tested only
Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_sched.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_sched.c	2010-08-20 23:43:29.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_sched.c	2010-08-20 23:46:02.000000000 +0900
@@ -35,7 +35,7 @@
 static LIST_HEAD(ip_vs_schedulers);
 
 /* lock for service table */
-static DEFINE_RWLOCK(__ip_vs_sched_lock);
+static DEFINE_SPINLOCK(ip_vs_sched_lock);
 
 
 /*
@@ -108,7 +108,7 @@ static struct ip_vs_scheduler *ip_vs_sch
 
 	IP_VS_DBG(2, "%s(): sched_name \"%s\"\n", __func__, sched_name);
 
-	read_lock_bh(&__ip_vs_sched_lock);
+	spin_lock_bh(&ip_vs_sched_lock);
 
 	list_for_each_entry(sched, &ip_vs_schedulers, n_list) {
 		/*
@@ -122,14 +122,14 @@ static struct ip_vs_scheduler *ip_vs_sch
 		}
 		if (strcmp(sched_name, sched->name)==0) {
 			/* HIT */
-			read_unlock_bh(&__ip_vs_sched_lock);
+			spin_unlock_bh(&ip_vs_sched_lock);
 			return sched;
 		}
 		if (sched->module)
 			module_put(sched->module);
 	}
 
-	read_unlock_bh(&__ip_vs_sched_lock);
+	spin_unlock_bh(&ip_vs_sched_lock);
 	return NULL;
 }
 
@@ -184,10 +184,10 @@ int register_ip_vs_scheduler(struct ip_v
 	/* increase the module use count */
 	ip_vs_use_count_inc();
 
-	write_lock_bh(&__ip_vs_sched_lock);
+	spin_lock_bh(&ip_vs_sched_lock);
 
 	if (!list_empty(&scheduler->n_list)) {
-		write_unlock_bh(&__ip_vs_sched_lock);
+		spin_unlock_bh(&ip_vs_sched_lock);
 		ip_vs_use_count_dec();
 		pr_err("%s(): [%s] scheduler already linked\n",
 		       __func__, scheduler->name);
@@ -200,7 +200,7 @@ int register_ip_vs_scheduler(struct ip_v
 	 */
 	list_for_each_entry(sched, &ip_vs_schedulers, n_list) {
 		if (strcmp(scheduler->name, sched->name) == 0) {
-			write_unlock_bh(&__ip_vs_sched_lock);
+			spin_unlock_bh(&ip_vs_sched_lock);
 			ip_vs_use_count_dec();
 			pr_err("%s(): [%s] scheduler already existed "
 			       "in the system\n", __func__, scheduler->name);
@@ -211,7 +211,7 @@ int register_ip_vs_scheduler(struct ip_v
 	 *	Add it into the d-linked scheduler list
 	 */
 	list_add(&scheduler->n_list, &ip_vs_schedulers);
-	write_unlock_bh(&__ip_vs_sched_lock);
+	spin_unlock_bh(&ip_vs_sched_lock);
 
 	pr_info("[%s] scheduler registered.\n", scheduler->name);
 
@@ -229,9 +229,9 @@ int unregister_ip_vs_scheduler(struct ip
 		return -EINVAL;
 	}
 
-	write_lock_bh(&__ip_vs_sched_lock);
+	spin_lock_bh(&ip_vs_sched_lock);
 	if (list_empty(&scheduler->n_list)) {
-		write_unlock_bh(&__ip_vs_sched_lock);
+		spin_unlock_bh(&ip_vs_sched_lock);
 		pr_err("%s(): [%s] scheduler is not in the list. failed\n",
 		       __func__, scheduler->name);
 		return -EINVAL;
@@ -241,7 +241,7 @@ int unregister_ip_vs_scheduler(struct ip
 	 *	Remove it from the d-linked scheduler list
 	 */
 	list_del(&scheduler->n_list);
-	write_unlock_bh(&__ip_vs_sched_lock);
+	spin_unlock_bh(&ip_vs_sched_lock);
 
 	/* decrease the module use count */
 	ip_vs_use_count_dec();
