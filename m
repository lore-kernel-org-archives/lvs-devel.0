From: hans@schillstrom.com
Subject: [*v3 PATCH 04/22] IPVS: netns awarness to lblc sheduler
Date: Thu, 30 Dec 2010 11:50:48 +0100
Message-ID: <1293706266-27152-5-git-send-email-hans@schillstrom.com>
References: <1293706266-27152-1-git-send-email-hans@schillstrom.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1293706266-27152-1-git-send-email-hans@schillstrom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, daniel.lezcano@free.fr, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

var sysctl_ip_vs_lblc_expiration moved to ipvs struct as
    sysctl_lblc_expiration

procfs updated to handle this.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/net/netns/ip_vs.h       |    4 +++
 net/netfilter/ipvs/ip_vs_lblc.c |   49 ++++++++++++++++++++++++++------------
 2 files changed, 37 insertions(+), 16 deletions(-)

diff --git a/include/net/netns/ip_vs.h b/include/net/netns/ip_vs.h
index 17e4e3a..4c8d751 100644
--- a/include/net/netns/ip_vs.h
+++ b/include/net/netns/ip_vs.h
@@ -30,6 +30,10 @@ struct netns_ipvs {
 
 	struct list_head 	rs_table[IP_VS_RTAB_SIZE];
 
+	/* ip_vs_lblc */
+	int 			sysctl_lblc_expiration;
+	struct ctl_table_header	*lblc_ctl_header;
+	struct ctl_table	*lblc_ctl_table;
 	/* ip_vs_lblcr */
 	int 			sysctl_lblcr_expiration;
 	struct ctl_table_header	*lblcr_ctl_header;
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 84278fb..b2dbfb5 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -70,7 +70,6 @@
  *    entries that haven't been touched for a day.
  */
 #define COUNT_FOR_FULL_EXPIRATION   30
-static int sysctl_ip_vs_lblc_expiration = 24*60*60*HZ;
 
 
 /*
@@ -117,7 +116,7 @@ struct ip_vs_lblc_table {
 static ctl_table vs_vars_table[] = {
 	{
 		.procname	= "lblc_expiration",
-		.data		= &sysctl_ip_vs_lblc_expiration,
+		.data		= NULL,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -125,8 +124,6 @@ static ctl_table vs_vars_table[] = {
 	{ }
 };
 
-static struct ctl_table_header * sysctl_header;
-
 static inline void ip_vs_lblc_free(struct ip_vs_lblc_entry *en)
 {
 	list_del(&en->list);
@@ -248,6 +245,7 @@ static inline void ip_vs_lblc_full_check(struct ip_vs_service *svc)
 	struct ip_vs_lblc_entry *en, *nxt;
 	unsigned long now = jiffies;
 	int i, j;
+	struct netns_ipvs *ipvs = net_ipvs(svc->net);
 
 	for (i=0, j=tbl->rover; i<IP_VS_LBLC_TAB_SIZE; i++) {
 		j = (j + 1) & IP_VS_LBLC_TAB_MASK;
@@ -255,7 +253,7 @@ static inline void ip_vs_lblc_full_check(struct ip_vs_service *svc)
 		write_lock(&svc->sched_lock);
 		list_for_each_entry_safe(en, nxt, &tbl->bucket[j], list) {
 			if (time_before(now,
-					en->lastuse + sysctl_ip_vs_lblc_expiration))
+					en->lastuse + ipvs->sysctl_lblc_expiration))
 				continue;
 
 			ip_vs_lblc_free(en);
@@ -548,23 +546,43 @@ static struct ip_vs_scheduler ip_vs_lblc_scheduler =
  */
 static int __net_init __ip_vs_lblc_init(struct net *net)
 {
-	if (!net_eq(net, &init_net))	/* netns not enabled yet */
-		return -EPERM;
-
-	sysctl_header = register_net_sysctl_table(net, net_vs_ctl_path,
-						  vs_vars_table);
-	if (!sysctl_header)
-		return -ENOMEM;
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
+	if (!net_eq(net, &init_net)) {
+		ipvs->lblc_ctl_table = kmemdup(vs_vars_table,
+						sizeof(vs_vars_table),
+						GFP_KERNEL);
+		if (ipvs->lblc_ctl_table == NULL)
+			goto err_dup;
+	} else
+		ipvs->lblc_ctl_table = vs_vars_table;
+	ipvs->sysctl_lblc_expiration = 24*60*60*HZ;
+	ipvs->lblc_ctl_table[0].data = &ipvs->sysctl_lblc_expiration;
+
+	ipvs->lblc_ctl_header =
+		register_net_sysctl_table(net, net_vs_ctl_path,
+					  ipvs->lblc_ctl_table);
+	if (!ipvs->lblc_ctl_header)
+		goto err_reg;
 
 	return 0;
+
+err_reg:
+	if (!net_eq(net, &init_net))
+		kfree(ipvs->lblc_ctl_table);
+
+err_dup:
+	return -ENOMEM;
 }
 
 static void __net_exit __ip_vs_lblc_exit(struct net *net)
 {
-	if (!net_eq(net, &init_net))	/* netns not enabled yet */
-		return;
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
+	unregister_net_sysctl_table(ipvs->lblc_ctl_header);
 
-	unregister_net_sysctl_table(sysctl_header);
+	if (!net_eq(net, &init_net))
+		kfree(ipvs->lblc_ctl_table);
 }
 
 static struct pernet_operations ip_vs_lblc_ops = {
@@ -586,7 +604,6 @@ static int __init ip_vs_lblc_init(void)
 	return ret;
 }
 
-
 static void __exit ip_vs_lblc_cleanup(void)
 {
 	unregister_ip_vs_scheduler(&ip_vs_lblc_scheduler);
-- 
1.7.2.3

