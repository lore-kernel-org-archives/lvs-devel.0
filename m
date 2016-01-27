From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 1/2] netfilter: ipvs: avoid unused variable warnings
Date: Wed, 27 Jan 2016 14:52:01 +0100
Message-ID: <1453902749-3422685-1-git-send-email-arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>
Cc: linux-arm-kernel@lists.infradead.org, Arnd Bergmann <arnd@arndb.de>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

The proc_create() and remove_proc_entry() functions do not reference
their arguments when CONFIG_PROC_FS is disabled, so we get a couple
of warnings about unused variables in IPVS:

ipvs/ip_vs_app.c:608:14: warning: unused variable 'net' [-Wunused-variable]
ipvs/ip_vs_ctl.c:3950:14: warning: unused variable 'net' [-Wunused-variable]
ipvs/ip_vs_ctl.c:3994:14: warning: unused variable 'net' [-Wunused-variable]

This removes the local variables and instead looks them up separately
for each use, which obviously avoids the warning.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 4c50a8ce2b63 ("netfilter: ipvs: avoid unused variable warning")
---
 net/netfilter/ipvs/ip_vs_app.c |  8 ++------
 net/netfilter/ipvs/ip_vs_ctl.c | 15 ++++++---------
 2 files changed, 8 insertions(+), 15 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index 0328f7250693..299edc6add5a 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -605,17 +605,13 @@ static const struct file_operations ip_vs_app_fops = {
 
 int __net_init ip_vs_app_net_init(struct netns_ipvs *ipvs)
 {
-	struct net *net = ipvs->net;
-
 	INIT_LIST_HEAD(&ipvs->app_list);
-	proc_create("ip_vs_app", 0, net->proc_net, &ip_vs_app_fops);
+	proc_create("ip_vs_app", 0, ipvs->net->proc_net, &ip_vs_app_fops);
 	return 0;
 }
 
 void __net_exit ip_vs_app_net_cleanup(struct netns_ipvs *ipvs)
 {
-	struct net *net = ipvs->net;
-
 	unregister_ip_vs_app(ipvs, NULL /* all */);
-	remove_proc_entry("ip_vs_app", net->proc_net);
+	remove_proc_entry("ip_vs_app", ipvs->net->proc_net);
 }
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index e7c1b052c2a3..bfb4f8372b83 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3947,7 +3947,6 @@ static struct notifier_block ip_vs_dst_notifier = {
 
 int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
 {
-	struct net *net = ipvs->net;
 	int i, idx;
 
 	/* Initialize rs_table */
@@ -3974,9 +3973,9 @@ int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
 
 	spin_lock_init(&ipvs->tot_stats.lock);
 
-	proc_create("ip_vs", 0, net->proc_net, &ip_vs_info_fops);
-	proc_create("ip_vs_stats", 0, net->proc_net, &ip_vs_stats_fops);
-	proc_create("ip_vs_stats_percpu", 0, net->proc_net,
+	proc_create("ip_vs", 0, ipvs->net->proc_net, &ip_vs_info_fops);
+	proc_create("ip_vs_stats", 0, ipvs->net->proc_net, &ip_vs_stats_fops);
+	proc_create("ip_vs_stats_percpu", 0, ipvs->net->proc_net,
 		    &ip_vs_stats_percpu_fops);
 
 	if (ip_vs_control_net_init_sysctl(ipvs))
@@ -3991,13 +3990,11 @@ err:
 
 void __net_exit ip_vs_control_net_cleanup(struct netns_ipvs *ipvs)
 {
-	struct net *net = ipvs->net;
-
 	ip_vs_trash_cleanup(ipvs);
 	ip_vs_control_net_cleanup_sysctl(ipvs);
-	remove_proc_entry("ip_vs_stats_percpu", net->proc_net);
-	remove_proc_entry("ip_vs_stats", net->proc_net);
-	remove_proc_entry("ip_vs", net->proc_net);
+	remove_proc_entry("ip_vs_stats_percpu", ipvs->net->proc_net);
+	remove_proc_entry("ip_vs_stats", ipvs->net->proc_net);
+	remove_proc_entry("ip_vs", ipvs->net->proc_net);
 	free_percpu(ipvs->tot_stats.cpustats);
 }
 
-- 
2.7.0

