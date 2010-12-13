From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [*v2 PATCH 03/22] IPVS: netns awarness to lblcr sheduler
Date: Mon, 13 Dec 2010 14:38:11 +0100
Message-ID: <1292247510-753-4-git-send-email-hans.schillstrom@ericsson.com>
References: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, daniel.lezcano@free.fr, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: hans@schillstrom.com, Hans Schillstrom <hans.schillstrom@ericsson.com>

var sysctl_ip_vs_lblcr_expiration moved to ipvs struct as
    sysctl_lblcr_expiration

procfs updated to handle this.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/net/netns/ip_vs.h        |    4 +++
 net/netfilter/ipvs/ip_vs_lblcr.c |   52 +++++++++++++++++++++++++------------
 2 files changed, 39 insertions(+), 17 deletions(-)

diff --git a/include/net/netns/ip_vs.h b/include/net/netns/ip_vs.h
index c22fec2..17e4e3a 100644
--- a/include/net/netns/ip_vs.h
+++ b/include/net/netns/ip_vs.h
@@ -30,6 +30,10 @@ struct netns_ipvs {
 
 	struct list_head 	rs_table[IP_VS_RTAB_SIZE];
 
+	/* ip_vs_lblcr */
+	int 			sysctl_lblcr_expiration;
+	struct ctl_table_header	*lblcr_ctl_header;
+	struct ctl_table	*lblcr_ctl_table;
 };
 
 #endif /* IP_VS_H_ */
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 7c7396a..91568c3 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -70,8 +70,6 @@
  *    entries that haven't been touched for a day.
  */
 #define COUNT_FOR_FULL_EXPIRATION   30
-static int sysctl_ip_vs_lblcr_expiration = 24*60*60*HZ;
-
 
 /*
  *     for IPVS lblcr entry hash table
@@ -296,7 +294,7 @@ struct ip_vs_lblcr_table {
 static ctl_table vs_vars_table[] = {
 	{
 		.procname	= "lblcr_expiration",
-		.data		= &sysctl_ip_vs_lblcr_expiration,
+		.data		= NULL,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -304,8 +302,6 @@ static ctl_table vs_vars_table[] = {
 	{ }
 };
 
-static struct ctl_table_header * sysctl_header;
-
 static inline void ip_vs_lblcr_free(struct ip_vs_lblcr_entry *en)
 {
 	list_del(&en->list);
@@ -425,13 +421,14 @@ static inline void ip_vs_lblcr_full_check(struct ip_vs_service *svc)
 	unsigned long now = jiffies;
 	int i, j;
 	struct ip_vs_lblcr_entry *en, *nxt;
+	struct netns_ipvs *ipvs = net_ipvs(svc->net);
 
 	for (i=0, j=tbl->rover; i<IP_VS_LBLCR_TAB_SIZE; i++) {
 		j = (j + 1) & IP_VS_LBLCR_TAB_MASK;
 
 		write_lock(&svc->sched_lock);
 		list_for_each_entry_safe(en, nxt, &tbl->bucket[j], list) {
-			if (time_after(en->lastuse+sysctl_ip_vs_lblcr_expiration,
+			if (time_after(en->lastuse+ipvs->sysctl_lblcr_expiration,
 				       now))
 				continue;
 
@@ -664,6 +661,7 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	read_lock(&svc->sched_lock);
 	en = ip_vs_lblcr_get(svc->af, tbl, &iph.daddr);
 	if (en) {
+		struct netns_ipvs *ipvs = net_ipvs(svc->net);
 		/* We only hold a read lock, but this is atomic */
 		en->lastuse = jiffies;
 
@@ -675,7 +673,7 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		/* More than one destination + enough time passed by, cleanup */
 		if (atomic_read(&en->set.size) > 1 &&
 				time_after(jiffies, en->set.lastmod +
-				sysctl_ip_vs_lblcr_expiration)) {
+				ipvs->sysctl_lblcr_expiration)) {
 			struct ip_vs_dest *m;
 
 			write_lock(&en->set.lock);
@@ -749,23 +747,43 @@ static struct ip_vs_scheduler ip_vs_lblcr_scheduler =
  */
 static int __net_init __ip_vs_lblcr_init(struct net *net)
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
+		ipvs->lblcr_ctl_table = kmemdup(vs_vars_table,
+						sizeof(vs_vars_table),
+						GFP_KERNEL);
+		if (ipvs->lblcr_ctl_table == NULL)
+			goto err_dup;
+	} else
+		ipvs->lblcr_ctl_table = vs_vars_table;
+	ipvs->sysctl_lblcr_expiration = 24*60*60*HZ;
+	ipvs->lblcr_ctl_table[0].data = &ipvs->sysctl_lblcr_expiration;
+
+	ipvs->lblcr_ctl_header =
+		register_net_sysctl_table(net, net_vs_ctl_path,
+					  ipvs->lblcr_ctl_table);
+	if (!ipvs->lblcr_ctl_header)
+		goto err_reg;
 
 	return 0;
+
+err_reg:
+	if (!net_eq(net, &init_net))
+		kfree(ipvs->lblcr_ctl_table);
+
+err_dup:
+	return -ENOMEM;
 }
 
 static void __net_exit __ip_vs_lblcr_exit(struct net *net)
 {
-	if (!net_eq(net, &init_net))	/* netns not enabled yet */
-		return;
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
+	unregister_net_sysctl_table(ipvs->lblcr_ctl_header);
 
-	unregister_net_sysctl_table(sysctl_header);
+	if (!net_eq(net, &init_net))
+		kfree(ipvs->lblcr_ctl_table);
 }
 
 static struct pernet_operations ip_vs_lblcr_ops = {
-- 
1.7.2.3

