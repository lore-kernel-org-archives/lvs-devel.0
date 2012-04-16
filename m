From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [PATCH 2/2] IPVS: make failure of netns init more stable
Date: Mon, 16 Apr 2012 13:39:38 +0200
Message-ID: <1334576378-2034-2-git-send-email-hans.schillstrom@ericsson.com>
References: <1334576378-2034-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1334576378-2034-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: hans@schillstrom.com, Hans Schillstrom <hans.schillstrom@ericsson.com>

Add a IP_VS_F_NET_INIT_OK flag
that other modules can use for check of a successful init of ip_vs

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/net/ip_vs.h              |   20 +++++++++++++++++++-
 net/netfilter/ipvs/ip_vs_conn.c  |    2 +-
 net/netfilter/ipvs/ip_vs_core.c  |   15 +++++++++------
 net/netfilter/ipvs/ip_vs_ctl.c   |    2 +-
 net/netfilter/ipvs/ip_vs_ftp.c   |    2 ++
 net/netfilter/ipvs/ip_vs_lblc.c  |    3 +++
 net/netfilter/ipvs/ip_vs_lblcr.c |    3 +++
 7 files changed, 38 insertions(+), 9 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 04e2211..96add20 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -787,7 +787,8 @@ struct ip_vs_app {
 /* IPVS in network namespace */
 struct netns_ipvs {
 	int			gen;		/* Generation */
-	int			enable;		/* enable like nf_hooks do */
+	/* Status flags: enable like nf_hooks, and netns init ok */
+	int			status;
 	/*
 	 *	Hash table: for real service lookups
 	 */
@@ -909,6 +910,23 @@ struct netns_ipvs {
 	struct net		*net;            /* Needed by timer routines */
 };
 
+/*
+ * Status flags for each netns
+ */
+enum {
+	IP_VS_ENABLE,		/* Enabled ipvs i.e. service registered */
+	IP_VS_NET_INIT_OK,	/* Netns init is OK */
+	IP_VS_F_ENABLE      = (1 << IP_VS_ENABLE),
+	IP_VS_F_NET_INIT_OK = (1 << IP_VS_NET_INIT_OK)
+};
+
+#define IS_IPVS_ENABLED(ipvs) (ipvs->status & IP_VS_F_ENABLE)
+#define IPVS_ENABLE(ipvs) (ipvs->status |= IP_VS_F_ENABLE)
+#define IPVS_DISABLE(ipvs) (ipvs->status &= ~IP_VS_F_ENABLE)
+
+#define IS_IPVS_NETNS_OK(ipvs) (ipvs->status & IP_VS_F_NET_INIT_OK)
+#define IPVS_NETNS_OK(ipvs) (ipvs->status |= IP_VS_F_NET_INIT_OK)
+
 #define DEFAULT_SYNC_THRESHOLD	3
 #define DEFAULT_SYNC_PERIOD	50
 #define DEFAULT_SYNC_VER	1
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 4a09b78..4f2a7ec 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -783,7 +783,7 @@ static void ip_vs_conn_expire(unsigned long data)
 			 * conntrack cleanup for the net.
 			 */
 			smp_rmb();
-			if (ipvs->enable)
+			if (IS_IPVS_ENABLED(ipvs))
 				ip_vs_conn_drop_conntrack(cp);
 		}
 
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index b5a5c73..58722a2 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1112,7 +1112,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 		return NF_ACCEPT;
 
 	net = skb_net(skb);
-	if (!net_ipvs(net)->enable)
+	if (!IS_IPVS_ENABLED(net_ipvs(net)))
 		return NF_ACCEPT;
 
 	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
@@ -1513,7 +1513,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	}
 	/* ipvs enabled in this netns ? */
 	net = skb_net(skb);
-	if (!net_ipvs(net)->enable)
+	if (!IS_IPVS_ENABLED(net_ipvs(net)))
 		return NF_ACCEPT;
 
 	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
@@ -1735,7 +1735,7 @@ ip_vs_forward_icmp(unsigned int hooknum, struct sk_buff *skb,
 
 	/* ipvs enabled in this netns ? */
 	net = skb_net(skb);
-	if (!net_ipvs(net)->enable)
+	if (!IS_IPVS_ENABLED(net_ipvs(net)))
 		return NF_ACCEPT;
 
 	return ip_vs_in_icmp(skb, &r, hooknum);
@@ -1755,7 +1755,7 @@ ip_vs_forward_icmp_v6(unsigned int hooknum, struct sk_buff *skb,
 
 	/* ipvs enabled in this netns ? */
 	net = skb_net(skb);
-	if (!net_ipvs(net)->enable)
+	if (!IS_IPVS_ENABLED(net_ipvs(net)))
 		return NF_ACCEPT;
 
 	return ip_vs_in_icmp_v6(skb, &r, hooknum);
@@ -1881,7 +1881,7 @@ static int __net_init __ip_vs_init(struct net *net)
 		return -ENOMEM;
 
 	/* Hold the beast until a service is registerd */
-	ipvs->enable = 0;
+	ipvs->status = 0;
 	ipvs->net = net;
 	/* Counters used for creating unique names */
 	ipvs->gen = atomic_read(&ipvs_netns_cnt);
@@ -1906,6 +1906,7 @@ static int __net_init __ip_vs_init(struct net *net)
 	if (ip_vs_sync_net_init(net) < 0)
 		goto sync_fail;
 
+	IPVS_NETNS_OK(ipvs);
 	printk(KERN_INFO "IPVS: Creating netns size=%zu id=%d\n",
 			 sizeof(struct netns_ipvs), ipvs->gen);
 	return 0;
@@ -1924,6 +1925,7 @@ protocol_fail:
 control_fail:
 	ip_vs_estimator_net_cleanup(net);
 estimator_fail:
+	ipvs->status = 0;	/* Nothing is enabled */
 	return -ENOMEM;
 }
 
@@ -1936,12 +1938,13 @@ static void __net_exit __ip_vs_cleanup(struct net *net)
 	ip_vs_control_net_cleanup(net);
 	ip_vs_estimator_net_cleanup(net);
 	IP_VS_DBG(2, "ipvs netns %d released\n", net_ipvs(net)->gen);
+	net->ipvs = NULL;
 }
 
 static void __net_exit __ip_vs_dev_cleanup(struct net *net)
 {
 	EnterFunction(2);
-	net_ipvs(net)->enable = 0;	/* Disable packet reception */
+	IPVS_DISABLE(net_ipvs(net));	/* Disable packet reception */
 	smp_wmb();
 	ip_vs_sync_net_cleanup(net);
 	LeaveFunction(2);
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index b8d0df7..5392de9 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1221,7 +1221,7 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 
 	*svc_p = svc;
 	/* Now there is a service - full throttle */
-	ipvs->enable = 1;
+	IPVS_ENABLE(ipvs);
 	return 0;
 
 
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index debb8c7..6bc2420 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -439,6 +439,8 @@ static int __net_init __ip_vs_ftp_init(struct net *net)
 	struct ip_vs_app *app;
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
+	if (!IS_IPVS_NETNS_OK(ipvs))
+		return -EUNATCH;
 	app = kmemdup(&ip_vs_ftp, sizeof(struct ip_vs_app), GFP_KERNEL);
 	if (!app)
 		return -ENOMEM;
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 27c24f1..f158f0c 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -551,6 +551,9 @@ static int __net_init __ip_vs_lblc_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
+	if (!IS_IPVS_NETNS_OK(ipvs))
+		return -EUNATCH;
+
 	if (!net_eq(net, &init_net)) {
 		ipvs->lblc_ctl_table = kmemdup(vs_vars_table,
 						sizeof(vs_vars_table),
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 7498756..aeecda4 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -745,6 +745,9 @@ static int __net_init __ip_vs_lblcr_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
+	if (!IS_IPVS_NETNS_OK(ipvs))
+		return -EUNATCH;
+
 	if (!net_eq(net, &init_net)) {
 		ipvs->lblcr_ctl_table = kmemdup(vs_vars_table,
 						sizeof(vs_vars_table),
-- 
1.7.2.3

