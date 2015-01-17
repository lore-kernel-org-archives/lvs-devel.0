From: Chris Caputo <ccaputo@alt.net>
Subject: [PATCH 1/2] IPVS: add wlib & wlip schedulers
Date: Sat, 17 Jan 2015 23:15:49 +0000 (UTC)
Message-ID: <Pine.LNX.4.64.1501172217420.8217@nacho.alt.net>
References: <Pine.LNX.4.44.0501260832210.17893-100000@nacho.alt.net>
	<Pine.LNX.4.61.0502010007060.1148@penguin.linux-vs.org>
Reply-To: Chris Caputo <ccaputo-dated-1431904550.82858f@alt.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alt.net;
	s=default; x=1422141751; h=Comment:DomainKey-Signature:Received:
	Received:Received:Date:To:cc:Subject:In-Reply-To:Message-ID:
	References:MIME-Version:Content-Type:From:Reply-To; bh=teiRYF1ZF
	78Nvyo+UP5YngWXeDpqj9U/FGYNdIsc63s=; b=J3M1Bu9OHpBIcmyQ+i8S0o1Xq
	iiC9k5y7xSPdq7hbVdf/nTYJ14UXbr6+rPbBpANqFRT67TZb3t1TYjpl5RKBjK+Q
	4c+HnSBNMDIJlgLW6dNuxBD1UerzQONj5/zA1LLix9uqcvj+mHz3ZfJmomP4F9BA
	S2IFKCOGDYUuAzP6SQ=
In-Reply-To: <Pine.LNX.4.61.0502010007060.1148@penguin.linux-vs.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org

Wensong, this is something we discussed 10 years ago and you liked it, but 
it didn't actually get into the kernel.  I've updated it, tested it, and 
would like to work toward inclusion.

Thanks,
Chris

---
From: Chris Caputo <ccaputo@alt.net> 

IPVS wlib (Weighted Least Incoming Byterate) and wlip (Weighted Least Incoming 
Packetrate) schedulers, updated for 3.19-rc4.

Signed-off-by: Chris Caputo <ccaputo@alt.net>
---
diff -uprN linux-3.19-rc4-stock/net/netfilter/ipvs/Kconfig linux-3.19-rc4/net/netfilter/ipvs/Kconfig
--- linux-3.19-rc4-stock/net/netfilter/ipvs/Kconfig	2015-01-11 20:44:53.000000000 +0000
+++ linux-3.19-rc4/net/netfilter/ipvs/Kconfig	2015-01-17 22:47:52.250301042 +0000
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
diff -uprN linux-3.19-rc4-stock/net/netfilter/ipvs/Makefile linux-3.19-rc4/net/netfilter/ipvs/Makefile
--- linux-3.19-rc4-stock/net/netfilter/ipvs/Makefile	2015-01-11 20:44:53.000000000 +0000
+++ linux-3.19-rc4/net/netfilter/ipvs/Makefile	2015-01-17 22:47:35.421861075 +0000
@@ -33,6 +33,8 @@ obj-$(CONFIG_IP_VS_DH) += ip_vs_dh.o
 obj-$(CONFIG_IP_VS_SH) += ip_vs_sh.o
 obj-$(CONFIG_IP_VS_SED) += ip_vs_sed.o
 obj-$(CONFIG_IP_VS_NQ) += ip_vs_nq.o
+obj-$(CONFIG_IP_VS_WLIB) += ip_vs_wlib.o
+obj-$(CONFIG_IP_VS_WLIP) += ip_vs_wlip.o
 
 # IPVS application helpers
 obj-$(CONFIG_IP_VS_FTP) += ip_vs_ftp.o
diff -uprN linux-3.19-rc4-stock/net/netfilter/ipvs/ip_vs_wlib.c linux-3.19-rc4/net/netfilter/ipvs/ip_vs_wlib.c
--- linux-3.19-rc4-stock/net/netfilter/ipvs/ip_vs_wlib.c	1970-01-01 00:00:00.000000000 +0000
+++ linux-3.19-rc4/net/netfilter/ipvs/ip_vs_wlib.c	2015-01-17 22:47:35.421861075 +0000
@@ -0,0 +1,156 @@
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
+	struct list_head *p, *q;
+	struct ip_vs_dest *dest, *least = NULL;
+	u32 dr, lr = -1;
+	int dwgt, lwgt = 0;
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
+	 * In case of ties, highest weight is winner.  And if that still makes
+	 * for a tie, round robin is used (which is why we remember our last
+	 * starting location in the linked list).
+	 */
+
+	spin_lock_bh(&svc->sched_lock);
+	p = (struct list_head *)svc->sched_data;
+	p = list_next_rcu(p);
+	q = p;
+	do {
+		/* skip list head */
+		if (q == &svc->destinations) {
+			q = list_next_rcu(q);
+			continue;
+		}
+
+		dest = list_entry_rcu(q, struct ip_vs_dest, n_list);
+		dwgt = atomic_read(&dest->weight);
+		if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) && dwgt > 0) {
+			spin_lock(&dest->stats.lock);
+			dr = dest->stats.ustats.inbps;
+			spin_unlock(&dest->stats.lock);
+
+			if (!least ||
+			    (u64)dr * (u64)lwgt < (u64)lr * (u64)dwgt ||
+			    (dr == lr && dwgt > lwgt)) {
+				least = dest;
+				lr = dr;
+				lwgt = dwgt;
+				svc->sched_data = q;
+			}
+		}
+		q = list_next_rcu(q);
+	} while (q != p);
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
diff -uprN linux-3.19-rc4-stock/net/netfilter/ipvs/ip_vs_wlip.c linux-3.19-rc4/net/netfilter/ipvs/ip_vs_wlip.c
--- linux-3.19-rc4-stock/net/netfilter/ipvs/ip_vs_wlip.c	1970-01-01 00:00:00.000000000 +0000
+++ linux-3.19-rc4/net/netfilter/ipvs/ip_vs_wlip.c	2015-01-17 22:47:35.421861075 +0000
@@ -0,0 +1,156 @@
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
+	struct list_head *p, *q;
+	struct ip_vs_dest *dest, *least = NULL;
+	u32 dr, lr = -1;
+	int dwgt, lwgt = 0;
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
+	 * In case of ties, highest weight is winner.  And if that still makes
+	 * for a tie, round robin is used (which is why we remember our last
+	 * starting location in the linked list).
+	 */
+
+	spin_lock_bh(&svc->sched_lock);
+	p = (struct list_head *)svc->sched_data;
+	p = list_next_rcu(p);
+	q = p;
+	do {
+		/* skip list head */
+		if (q == &svc->destinations) {
+			q = list_next_rcu(q);
+			continue;
+		}
+
+		dest = list_entry_rcu(q, struct ip_vs_dest, n_list);
+		dwgt = atomic_read(&dest->weight);
+		if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) && dwgt > 0) {
+			spin_lock(&dest->stats.lock);
+			dr = dest->stats.ustats.inpps;
+			spin_unlock(&dest->stats.lock);
+
+			if (!least ||
+			    (u64)dr * (u64)lwgt < (u64)lr * (u64)dwgt ||
+			    (dr == lr && dwgt > lwgt)) {
+				least = dest;
+				lr = dr;
+				lwgt = dwgt;
+				svc->sched_data = q;
+			}
+		}
+		q = list_next_rcu(q);
+	} while (q != p);
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
