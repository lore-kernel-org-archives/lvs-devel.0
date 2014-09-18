From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 01/15] ipvs: Add simple weighted failover scheduler
Date: Thu, 18 Sep 2014 09:25:47 +0900
Message-ID: <1410999961-7975-2-git-send-email-horms@verge.net.au>
References: <1410999961-7975-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1410999961-7975-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Kenny Mathis <kmathis@chokepoint.net>, Simon Horman <horms@verge.net.au>

From: Kenny Mathis <kmathis@chokepoint.net>

Add simple weighted IPVS failover support to the Linux kernel. All
other scheduling modules implement some form of load balancing, while
this offers a simple failover solution. Connections are directed to
the appropriate server based solely on highest weight value and server
availability. Tested functionality with keepalived.

Signed-off-by: Kenny Mathis <kmathis@chokepoint.net>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/Kconfig    | 10 ++++++
 net/netfilter/ipvs/Makefile   |  1 +
 net/netfilter/ipvs/ip_vs_fo.c | 79 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 90 insertions(+)
 create mode 100644 net/netfilter/ipvs/ip_vs_fo.c

diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index 0c3b167..3b6929d 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -152,6 +152,16 @@ config	IP_VS_WLC
 	  If you want to compile it in kernel, say Y. To compile it as a
 	  module, choose M here. If unsure, say N.
 
+config  IP_VS_FO
+		tristate "weighted failover scheduling"
+	---help---
+	  The weighted failover scheduling algorithm directs network
+	  connections to the server with the highest weight that is
+	  currently available.
+
+	  If you want to compile it in kernel, say Y. To compile it as a
+	  module, choose M here. If unsure, say N.
+
 config	IP_VS_LBLC
 	tristate "locality-based least-connection scheduling"
 	---help---
diff --git a/net/netfilter/ipvs/Makefile b/net/netfilter/ipvs/Makefile
index 34ee602..38b2723 100644
--- a/net/netfilter/ipvs/Makefile
+++ b/net/netfilter/ipvs/Makefile
@@ -26,6 +26,7 @@ obj-$(CONFIG_IP_VS_RR) += ip_vs_rr.o
 obj-$(CONFIG_IP_VS_WRR) += ip_vs_wrr.o
 obj-$(CONFIG_IP_VS_LC) += ip_vs_lc.o
 obj-$(CONFIG_IP_VS_WLC) += ip_vs_wlc.o
+obj-$(CONFIG_IP_VS_FO) += ip_vs_fo.o
 obj-$(CONFIG_IP_VS_LBLC) += ip_vs_lblc.o
 obj-$(CONFIG_IP_VS_LBLCR) += ip_vs_lblcr.o
 obj-$(CONFIG_IP_VS_DH) += ip_vs_dh.o
diff --git a/net/netfilter/ipvs/ip_vs_fo.c b/net/netfilter/ipvs/ip_vs_fo.c
new file mode 100644
index 0000000..6a2647d
--- /dev/null
+++ b/net/netfilter/ipvs/ip_vs_fo.c
@@ -0,0 +1,79 @@
+/*
+ * IPVS:        Weighted Fail Over module
+ *
+ * Authors:     Kenny Mathis <kmathis@chokepoint.net>
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Changes:
+ *     Kenny Mathis            :     added initial functionality based on weight
+ *
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
+/* Weighted Fail Over Module */
+static struct ip_vs_dest *
+ip_vs_fo_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
+		  struct ip_vs_iphdr *iph)
+{
+	struct ip_vs_dest *dest, *hweight = NULL;
+	int hw = 0; /* Track highest weight */
+
+	IP_VS_DBG(6, "ip_vs_fo_schedule(): Scheduling...\n");
+
+	/* Basic failover functionality
+	 * Find virtual server with highest weight and send it traffic
+	 */
+	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
+		if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
+		    atomic_read(&dest->weight) > hw) {
+			hweight = dest;
+			hw = atomic_read(&dest->weight);
+		}
+	}
+
+	if (hweight) {
+		IP_VS_DBG_BUF(6, "FO: server %s:%u activeconns %d weight %d\n",
+			      IP_VS_DBG_ADDR(svc->af, &hweight->addr),
+			      ntohs(hweight->port),
+			      atomic_read(&hweight->activeconns),
+			      atomic_read(&hweight->weight));
+		return hweight;
+	}
+
+	ip_vs_scheduler_err(svc, "no destination available");
+	return NULL;
+}
+
+static struct ip_vs_scheduler ip_vs_fo_scheduler = {
+	.name =			"fo",
+	.refcnt =		ATOMIC_INIT(0),
+	.module =		THIS_MODULE,
+	.n_list =		LIST_HEAD_INIT(ip_vs_fo_scheduler.n_list),
+	.schedule =		ip_vs_fo_schedule,
+};
+
+static int __init ip_vs_fo_init(void)
+{
+	return register_ip_vs_scheduler(&ip_vs_fo_scheduler);
+}
+
+static void __exit ip_vs_fo_cleanup(void)
+{
+	unregister_ip_vs_scheduler(&ip_vs_fo_scheduler);
+	synchronize_rcu();
+}
+
+module_init(ip_vs_fo_init);
+module_exit(ip_vs_fo_cleanup);
+MODULE_LICENSE("GPL");
-- 
2.0.1
