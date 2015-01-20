From: Chris Caputo <ccaputo@alt.net>
Subject: [PATCH 2/3] IPVS: add wlib & wlip schedulers
Date: Tue, 20 Jan 2015 23:21:26 +0000 (UTC)
Message-ID: <Pine.LNX.4.64.1501202316450.8217@nacho.alt.net>
References: <Pine.LNX.4.44.0501260832210.17893-100000@nacho.alt.net>
	<Pine.LNX.4.61.0502010007060.1148@penguin.linux-vs.org>
	<Pine.LNX.4.64.1501172217420.8217@nacho.alt.net>
	<alpine.LFD.2.11.1501192342190.2687@ja.home.ssi.bg>
Reply-To: Chris Caputo <ccaputo-dated-1432164087.fb7974@alt.net>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alt.net;
	s=default; x=1422400887; h=Comment:DomainKey-Signature:Received:
	Received:Received:Date:To:cc:Subject:In-Reply-To:Message-ID:
	References:MIME-Version:Content-Type:From:Reply-To; bh=7hqRQe+7Z
	G3eLF+QEljkw+UExCz3tBLdNfeZs7tOW8s=; b=RSErxzlbs+eCO8xcKpVQs7+Rm
	ax2ghPO7AmkQO6GKtLU1B4afkEUQJLYJrcI7qqKRFHx2Zbezb1JuBaD97ajjluG2
	YZsMtKorwSV1HzMVrqw8XwCKpMKu95RKaEiq2D03ZI5hLCIKOKR3R5Wq7z7paWH0
	XORj97PEmfklBTjx54=
In-Reply-To: <alpine.LFD.2.11.1501192342190.2687@ja.home.ssi.bg>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 20 Jan 2015, Julian Anastasov wrote:
> > +                      (u64)dr * (u64)lwgt < (u64)lr * (u64)dwgt ||
[...]
> > +  	                   (dr == lr && dwgt > lwgt)) {
> 
> 	Above check is redundant.

I accepted your feedback and applied it to the below, except for this 
item.  I believe if dr and lr are zero (no traffic), we still want to 
choose the higher weight, thus a separate comparison is needed.

Thanks,
Chris

From: Chris Caputo <ccaputo@alt.net> 

IPVS wlib (Weighted Least Incoming Byterate) and wlip (Weighted Least Incoming 
Packetrate) schedulers, updated for 3.19-rc5.

Signed-off-by: Chris Caputo <ccaputo@alt.net>
---
diff -uprN linux-3.19-rc5-stock/net/netfilter/ipvs/Kconfig linux-3.19-rc5/net/netfilter/ipvs/Kconfig
--- linux-3.19-rc5-stock/net/netfilter/ipvs/Kconfig	2015-01-18 06:02:20.000000000 +0000
+++ linux-3.19-rc5/net/netfilter/ipvs/Kconfig	2015-01-20 08:08:28.883080285 +0000
@@ -240,6 +240,26 @@ config	IP_VS_NQ
 	  If you want to compile it in kernel, say Y. To compile it as a
 	  module, choose M here. If unsure, say N.
 
+config	IP_VS_WLIB
+	tristate "weighted least incoming byterate scheduling"
+	---help---
+	  The weighted least incoming byterate scheduling algorithm directs
+	  network connections to the server with the least incoming byterate
+	  normalized by the server weight.
+
+	  If you want to compile it in kernel, say Y. To compile it as a
+	  module, choose M here. If unsure, say N.
+
+config	IP_VS_WLIP
+	tristate "weighted least incoming packetrate scheduling"
+	---help---
+	  The weighted least incoming packetrate scheduling algorithm directs
+	  network connections to the server with the least incoming packetrate
+	  normalized by the server weight.
+
+	  If you want to compile it in kernel, say Y. To compile it as a
+	  module, choose M here. If unsure, say N.
+
 comment 'IPVS SH scheduler'
 
 config IP_VS_SH_TAB_BITS
diff -uprN linux-3.19-rc5-stock/net/netfilter/ipvs/Makefile linux-3.19-rc5/net/netfilter/ipvs/Makefile
--- linux-3.19-rc5-stock/net/netfilter/ipvs/Makefile	2015-01-18 06:02:20.000000000 +0000
+++ linux-3.19-rc5/net/netfilter/ipvs/Makefile	2015-01-20 08:08:28.883080285 +0000
@@ -33,6 +33,8 @@ obj-$(CONFIG_IP_VS_DH) += ip_vs_dh.o
 obj-$(CONFIG_IP_VS_SH) += ip_vs_sh.o
 obj-$(CONFIG_IP_VS_SED) += ip_vs_sed.o
 obj-$(CONFIG_IP_VS_NQ) += ip_vs_nq.o
+obj-$(CONFIG_IP_VS_WLIB) += ip_vs_wlib.o
+obj-$(CONFIG_IP_VS_WLIP) += ip_vs_wlip.o
 
 # IPVS application helpers
 obj-$(CONFIG_IP_VS_FTP) += ip_vs_ftp.o
diff -uprN linux-3.19-rc5-stock/net/netfilter/ipvs/ip_vs_wlib.c linux-3.19-rc5/net/netfilter/ipvs/ip_vs_wlib.c
--- linux-3.19-rc5-stock/net/netfilter/ipvs/ip_vs_wlib.c	1970-01-01 00:00:00.000000000 +0000
+++ linux-3.19-rc5/net/netfilter/ipvs/ip_vs_wlib.c	2015-01-20 08:09:00.177816054 +0000
@@ -0,0 +1,166 @@
+/* IPVS:        Weighted Least Incoming Byterate Scheduling module
+ *
+ * Authors:     Chris Caputo <ccaputo@alt.net> based on code by:
+ *
+ *                  Wensong Zhang <wensong@linuxvirtualserver.org>
+ *                  Peter Kese <peter.kese@ijs.si>
+ *                  Julian Anastasov <ja@ssi.bg>
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Changes:
+ *     Chris Caputo: Based code on ip_vs_wlc.c ip_vs_rr.c.
+ *
+ */
+
+/* The WLIB algorithm uses the results of the estimator's inbps
+ * calculations to determine which real server has the lowest incoming
+ * byterate.
+ *
+ * Real server weight is factored into the calculation.  An example way to
+ * use this is if you have one server that can handle 100 Mbps of input and
+ * another that can handle 1 Gbps you could set the weights to be 100 and 1000
+ * respectively.
+ */
+
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+
+#include <net/ip_vs.h>
+
+static int
+ip_vs_wlib_init_svc(struct ip_vs_service *svc)
+{
+	svc->sched_data = &svc->destinations;
+	return 0;
+}
+
+static int
+ip_vs_wlib_del_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest)
+{
+	struct list_head *p;
+
+	spin_lock_bh(&svc->sched_lock);
+	p = (struct list_head *)svc->sched_data;
+	/* dest is already unlinked, so p->prev is not valid but
+	 * p->next is valid, use it to reach previous entry.
+	 */
+	if (p == &dest->n_list)
+		svc->sched_data = p->next->prev;
+	spin_unlock_bh(&svc->sched_lock);
+	return 0;
+}
+
+/* Weighted Least Incoming Byterate scheduling */
+static struct ip_vs_dest *
+ip_vs_wlib_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
+		    struct ip_vs_iphdr *iph)
+{
+	struct list_head *p;
+	struct ip_vs_dest *dest, *last, *least = NULL;
+	int pass = 0;
+	u64 dr, lr = -1;
+	u32 dwgt, lwgt = 0;
+
+	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
+
+	/* We calculate the load of each dest server as follows:
+	 *        (dest inbps rate) / dest->weight
+	 *
+	 * The comparison of dr*lwght < lr*dwght is equivalent to that of
+	 * dr/dwght < lr/lwght if every weight is larger than zero.
+	 *
+	 * A server with weight=0 is quiesced and will not receive any
+	 * new connections.
+	 *
+	 * In case of inactivity, highest weight is winner.  And if that still makes
+	 * for a tie, round robin is used (which is why we remember our last
+	 * starting location in the linked list).
+	 */
+
+	spin_lock_bh(&svc->sched_lock);
+	p = (struct list_head *)svc->sched_data;
+	last = dest = list_entry(p, struct ip_vs_dest, n_list);
+
+	do {
+		list_for_each_entry_continue_rcu(dest,
+						 &svc->destinations,
+						 n_list) {
+			dwgt = (u32)atomic_read(&dest->weight);
+			if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
+			    dwgt > 0) {
+				spin_lock(&dest->stats.lock);
+				/* estimator's scaling doesn't matter */
+				dr = dest->stats.est.inbps;
+				spin_unlock(&dest->stats.lock);
+
+				if (!least ||
+				    dr * lwgt < lr * dwgt ||
+				    (!dr && !lr && dwgt > lwgt)) {
+					least = dest;
+					lr = dr;
+					lwgt = dwgt;
+				}
+			}
+
+			if (dest == last)
+				goto stop;
+		}
+		pass++;
+		/* Previous dest could be unlinked, do not loop forever.
+		 * If we stay at head there is no need for 2nd pass.
+		 */
+	} while (pass < 2 && p != &svc->destinations);
+
+stop:
+	if (least)
+		svc->sched_data = &least->n_list;
+
+	spin_unlock_bh(&svc->sched_lock);
+
+	if (least) {
+		IP_VS_DBG_BUF(6,
+			      "WLIB: server %s:%u activeconns %d refcnt %d weight %d\n",
+			      IP_VS_DBG_ADDR(least->af, &least->addr),
+			      ntohs(least->port),
+			      atomic_read(&least->activeconns),
+			      atomic_read(&least->refcnt),
+			      atomic_read(&least->weight));
+	} else {
+		ip_vs_scheduler_err(svc, "no destination available");
+	}
+
+	return least;
+}
+
+static struct ip_vs_scheduler ip_vs_wlib_scheduler = {
+	.name =			"wlib",
+	.refcnt =		ATOMIC_INIT(0),
+	.module =		THIS_MODULE,
+	.n_list =		LIST_HEAD_INIT(ip_vs_wlib_scheduler.n_list),
+	.init_service =		ip_vs_wlib_init_svc,
+	.add_dest =		NULL,
+	.del_dest =		ip_vs_wlib_del_dest,
+	.schedule =		ip_vs_wlib_schedule,
+};
+
+static int __init ip_vs_wlib_init(void)
+{
+	return register_ip_vs_scheduler(&ip_vs_wlib_scheduler);
+}
+
+static void __exit ip_vs_wlib_cleanup(void)
+{
+	unregister_ip_vs_scheduler(&ip_vs_wlib_scheduler);
+	synchronize_rcu();
+}
+
+module_init(ip_vs_wlib_init);
+module_exit(ip_vs_wlib_cleanup);
+MODULE_LICENSE("GPL");
diff -uprN linux-3.19-rc5-stock/net/netfilter/ipvs/ip_vs_wlip.c linux-3.19-rc5/net/netfilter/ipvs/ip_vs_wlip.c
--- linux-3.19-rc5-stock/net/netfilter/ipvs/ip_vs_wlip.c	1970-01-01 00:00:00.000000000 +0000
+++ linux-3.19-rc5/net/netfilter/ipvs/ip_vs_wlip.c	2015-01-20 08:09:07.456126624 +0000
@@ -0,0 +1,166 @@
+/* IPVS:        Weighted Least Incoming Packetrate Scheduling module
+ *
+ * Authors:     Chris Caputo <ccaputo@alt.net> based on code by:
+ *
+ *                  Wensong Zhang <wensong@linuxvirtualserver.org>
+ *                  Peter Kese <peter.kese@ijs.si>
+ *                  Julian Anastasov <ja@ssi.bg>
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Changes:
+ *     Chris Caputo: Based code on ip_vs_wlc.c ip_vs_rr.c.
+ *
+ */
+
+/* The WLIP algorithm uses the results of the estimator's inpps
+ * calculations to determine which real server has the lowest incoming
+ * packetrate.
+ *
+ * Real server weight is factored into the calculation.  An example way to
+ * use this is if you have one server that can handle 10 Kpps of input and
+ * another that can handle 100 Kpps you could set the weights to be 10 and 100
+ * respectively.
+ */
+
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+
+#include <net/ip_vs.h>
+
+static int
+ip_vs_wlip_init_svc(struct ip_vs_service *svc)
+{
+	svc->sched_data = &svc->destinations;
+	return 0;
+}
+
+static int
+ip_vs_wlip_del_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest)
+{
+	struct list_head *p;
+
+	spin_lock_bh(&svc->sched_lock);
+	p = (struct list_head *)svc->sched_data;
+	/* dest is already unlinked, so p->prev is not valid but
+	 * p->next is valid, use it to reach previous entry.
+	 */
+	if (p == &dest->n_list)
+		svc->sched_data = p->next->prev;
+	spin_unlock_bh(&svc->sched_lock);
+	return 0;
+}
+
+/* Weighted Least Incoming Packetrate scheduling */
+static struct ip_vs_dest *
+ip_vs_wlip_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
+		    struct ip_vs_iphdr *iph)
+{
+	struct list_head *p;
+	struct ip_vs_dest *dest, *last, *least = NULL;
+	int pass = 0;
+	u32 dr, lr = -1;
+	u32 dwgt, lwgt = 0;
+
+	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
+
+	/* We calculate the load of each dest server as follows:
+	 *        (dest inpps rate) / dest->weight
+	 *
+	 * The comparison of dr*lwght < lr*dwght is equivalent to that of
+	 * dr/dwght < lr/lwght if every weight is larger than zero.
+	 *
+	 * A server with weight=0 is quiesced and will not receive any
+	 * new connections.
+	 *
+	 * In case of inactivity, highest weight is winner.  And if that still makes
+	 * for a tie, round robin is used (which is why we remember our last
+	 * starting location in the linked list).
+	 */
+
+	spin_lock_bh(&svc->sched_lock);
+	p = (struct list_head *)svc->sched_data;
+	last = dest = list_entry(p, struct ip_vs_dest, n_list);
+
+	do {
+		list_for_each_entry_continue_rcu(dest,
+						 &svc->destinations,
+						 n_list) {
+			dwgt = (u32)atomic_read(&dest->weight);
+			if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
+			    dwgt > 0) {
+				spin_lock(&dest->stats.lock);
+				/* estimator's scaling doesn't matter */
+				dr = dest->stats.est.inpps;
+				spin_unlock(&dest->stats.lock);
+
+				if (!least ||
+				    (u64)dr * lwgt < (u64)lr * dwgt ||
+				    (!dr && !lr && dwgt > lwgt)) {
+					least = dest;
+					lr = dr;
+					lwgt = dwgt;
+				}
+			}
+
+			if (dest == last)
+				goto stop;
+		}
+		pass++;
+		/* Previous dest could be unlinked, do not loop forever.
+		 * If we stay at head there is no need for 2nd pass.
+		 */
+	} while (pass < 2 && p != &svc->destinations);
+
+stop:
+	if (least)
+		svc->sched_data = &least->n_list;
+
+	spin_unlock_bh(&svc->sched_lock);
+
+	if (least) {
+		IP_VS_DBG_BUF(6,
+			      "WLIP: server %s:%u activeconns %d refcnt %d weight %d\n",
+			      IP_VS_DBG_ADDR(least->af, &least->addr),
+			      ntohs(least->port),
+			      atomic_read(&least->activeconns),
+			      atomic_read(&least->refcnt),
+			      atomic_read(&least->weight));
+	} else {
+		ip_vs_scheduler_err(svc, "no destination available");
+	}
+
+	return least;
+}
+
+static struct ip_vs_scheduler ip_vs_wlip_scheduler = {
+	.name =			"wlip",
+	.refcnt =		ATOMIC_INIT(0),
+	.module =		THIS_MODULE,
+	.n_list =		LIST_HEAD_INIT(ip_vs_wlip_scheduler.n_list),
+	.init_service =		ip_vs_wlip_init_svc,
+	.add_dest =		NULL,
+	.del_dest =		ip_vs_wlip_del_dest,
+	.schedule =		ip_vs_wlip_schedule,
+};
+
+static int __init ip_vs_wlip_init(void)
+{
+	return register_ip_vs_scheduler(&ip_vs_wlip_scheduler);
+}
+
+static void __exit ip_vs_wlip_cleanup(void)
+{
+	unregister_ip_vs_scheduler(&ip_vs_wlip_scheduler);
+	synchronize_rcu();
+}
+
+module_init(ip_vs_wlip_init);
+module_exit(ip_vs_wlip_cleanup);
+MODULE_LICENSE("GPL");
