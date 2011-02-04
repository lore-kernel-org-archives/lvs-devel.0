From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 12/14] IPVS: Conditionally define and use ip_vs_lblc{r}_table
Date: Fri,  4 Feb 2011 18:46:20 +0900
Message-ID: <1296812782-14953-13-git-send-email-horms@verge.net.au>
References: <1296812782-14953-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1296812782-14953-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>, Simon Horman <horms@verge.net.au>

ip_vs_lblc_table and ip_vs_lblcr_table, and code that uses them
are unnecessary when CONFIG_SYSCTL is undefined.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_lblc.c  |   15 ++++++++++-----
 net/netfilter/ipvs/ip_vs_lblcr.c |   14 ++++++++++----
 2 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 7c5ef3f..8ab0603 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -114,7 +114,7 @@ struct ip_vs_lblc_table {
 /*
  *      IPVS LBLC sysctl table
  */
-
+#ifdef CONFIG_SYSCTL
 static ctl_table vs_vars_table[] = {
 	{
 		.procname	= "lblc_expiration",
@@ -125,6 +125,7 @@ static ctl_table vs_vars_table[] = {
 	},
 	{ }
 };
+#endif
 
 static inline void ip_vs_lblc_free(struct ip_vs_lblc_entry *en)
 {
@@ -555,6 +556,7 @@ static struct ip_vs_scheduler ip_vs_lblc_scheduler =
 /*
  *  per netns init.
  */
+#ifdef CONFIG_SYSCTL
 static int __net_init __ip_vs_lblc_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
@@ -570,7 +572,6 @@ static int __net_init __ip_vs_lblc_init(struct net *net)
 	ipvs->sysctl_lblc_expiration = DEFAULT_EXPIRATION;
 	ipvs->lblc_ctl_table[0].data = &ipvs->sysctl_lblc_expiration;
 
-#ifdef CONFIG_SYSCTL
 	ipvs->lblc_ctl_header =
 		register_net_sysctl_table(net, net_vs_ctl_path,
 					  ipvs->lblc_ctl_table);
@@ -579,7 +580,6 @@ static int __net_init __ip_vs_lblc_init(struct net *net)
 			kfree(ipvs->lblc_ctl_table);
 		return -ENOMEM;
 	}
-#endif
 
 	return 0;
 }
@@ -588,14 +588,19 @@ static void __net_exit __ip_vs_lblc_exit(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-#ifdef CONFIG_SYSCTL
 	unregister_net_sysctl_table(ipvs->lblc_ctl_header);
-#endif
 
 	if (!net_eq(net, &init_net))
 		kfree(ipvs->lblc_ctl_table);
 }
 
+#else
+
+static int __net_init __ip_vs_lblc_init(struct net *net) { return 0; }
+static void __net_exit __ip_vs_lblc_exit(struct net *net) { }
+
+#endif
+
 static struct pernet_operations ip_vs_lblc_ops = {
 	.init = __ip_vs_lblc_init,
 	.exit = __ip_vs_lblc_exit,
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 484a700..241d1ef 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -289,6 +289,7 @@ struct ip_vs_lblcr_table {
 };
 
 
+#ifdef CONFIG_SYSCTL
 /*
  *      IPVS LBLCR sysctl table
  */
@@ -303,6 +304,7 @@ static ctl_table vs_vars_table[] = {
 	},
 	{ }
 };
+#endif
 
 static inline void ip_vs_lblcr_free(struct ip_vs_lblcr_entry *en)
 {
@@ -754,6 +756,7 @@ static struct ip_vs_scheduler ip_vs_lblcr_scheduler =
 /*
  *  per netns init.
  */
+#ifdef CONFIG_SYSCTL
 static int __net_init __ip_vs_lblcr_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
@@ -769,7 +772,6 @@ static int __net_init __ip_vs_lblcr_init(struct net *net)
 	ipvs->sysctl_lblcr_expiration = DEFAULT_EXPIRATION;
 	ipvs->lblcr_ctl_table[0].data = &ipvs->sysctl_lblcr_expiration;
 
-#ifdef CONFIG_SYSCTL
 	ipvs->lblcr_ctl_header =
 		register_net_sysctl_table(net, net_vs_ctl_path,
 					  ipvs->lblcr_ctl_table);
@@ -778,7 +780,6 @@ static int __net_init __ip_vs_lblcr_init(struct net *net)
 			kfree(ipvs->lblcr_ctl_table);
 		return -ENOMEM;
 	}
-#endif
 
 	return 0;
 }
@@ -787,14 +788,19 @@ static void __net_exit __ip_vs_lblcr_exit(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-#ifdef CONFIG_SYSCTL
 	unregister_net_sysctl_table(ipvs->lblcr_ctl_header);
-#endif
 
 	if (!net_eq(net, &init_net))
 		kfree(ipvs->lblcr_ctl_table);
 }
 
+#else
+
+static int __net_init __ip_vs_lblcr_init(struct net *net) { return 0; }
+static void __net_exit __ip_vs_lblcr_exit(struct net *net) { }
+
+#endif
+
 static struct pernet_operations ip_vs_lblcr_ops = {
 	.init = __ip_vs_lblcr_init,
 	.exit = __ip_vs_lblcr_exit,
-- 
1.7.2.3

