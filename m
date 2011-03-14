From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 22/24] IPVS: Conditionally define and use ip_vs_lblc{r}_table
Date: Mon, 14 Mar 2011 18:06:34 +0900
Message-ID: <1300093596-3824-23-git-send-email-horms@verge.net.au>
References: <1300093596-3824-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <1300093596-3824-1-git-send-email-horms@verge.net.au>
Sender: netfilter-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>, Simon Horman <horms@verge.net.au>

ip_vs_lblc_table and ip_vs_lblcr_table, and code that uses them
are unnecessary when CONFIG_SYSCTL is undefined.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_lblc.c  |   15 ++++++++++-----
 net/netfilter/ipvs/ip_vs_lblcr.c |   14 ++++++++++----
 2 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 51a27f5..f276df9 100644
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
@@ -548,6 +549,7 @@ static struct ip_vs_scheduler ip_vs_lblc_scheduler =
 /*
  *  per netns init.
  */
+#ifdef CONFIG_SYSCTL
 static int __net_init __ip_vs_lblc_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
@@ -563,7 +565,6 @@ static int __net_init __ip_vs_lblc_init(struct net *net)
 	ipvs->sysctl_lblc_expiration = DEFAULT_EXPIRATION;
 	ipvs->lblc_ctl_table[0].data = &ipvs->sysctl_lblc_expiration;
 
-#ifdef CONFIG_SYSCTL
 	ipvs->lblc_ctl_header =
 		register_net_sysctl_table(net, net_vs_ctl_path,
 					  ipvs->lblc_ctl_table);
@@ -572,7 +573,6 @@ static int __net_init __ip_vs_lblc_init(struct net *net)
 			kfree(ipvs->lblc_ctl_table);
 		return -ENOMEM;
 	}
-#endif
 
 	return 0;
 }
@@ -581,14 +581,19 @@ static void __net_exit __ip_vs_lblc_exit(struct net *net)
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
index 7fb9190..cb1c991 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -285,6 +285,7 @@ struct ip_vs_lblcr_table {
 };
 
 
+#ifdef CONFIG_SYSCTL
 /*
  *      IPVS LBLCR sysctl table
  */
@@ -299,6 +300,7 @@ static ctl_table vs_vars_table[] = {
 	},
 	{ }
 };
+#endif
 
 static inline void ip_vs_lblcr_free(struct ip_vs_lblcr_entry *en)
 {
@@ -743,6 +745,7 @@ static struct ip_vs_scheduler ip_vs_lblcr_scheduler =
 /*
  *  per netns init.
  */
+#ifdef CONFIG_SYSCTL
 static int __net_init __ip_vs_lblcr_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
@@ -758,7 +761,6 @@ static int __net_init __ip_vs_lblcr_init(struct net *net)
 	ipvs->sysctl_lblcr_expiration = DEFAULT_EXPIRATION;
 	ipvs->lblcr_ctl_table[0].data = &ipvs->sysctl_lblcr_expiration;
 
-#ifdef CONFIG_SYSCTL
 	ipvs->lblcr_ctl_header =
 		register_net_sysctl_table(net, net_vs_ctl_path,
 					  ipvs->lblcr_ctl_table);
@@ -767,7 +769,6 @@ static int __net_init __ip_vs_lblcr_init(struct net *net)
 			kfree(ipvs->lblcr_ctl_table);
 		return -ENOMEM;
 	}
-#endif
 
 	return 0;
 }
@@ -776,14 +777,19 @@ static void __net_exit __ip_vs_lblcr_exit(struct net *net)
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

