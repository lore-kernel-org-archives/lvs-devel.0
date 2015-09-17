From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 07/15] ipvs: add schedule_icmp sysctl
Date: Thu, 17 Sep 2015 14:40:43 +0900
Message-ID: <1442468451-24012-8-git-send-email-horms@verge.net.au>
References: <1442468451-24012-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1442468451-24012-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Alex Gartrell <agartrell@fb.com>, Simon Horman <horms@verge.net.au>

From: Alex Gartrell <agartrell@fb.com>

This sysctl will be used to enable the scheduling of icmp packets.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h            | 11 +++++++++++
 net/netfilter/ipvs/ip_vs_ctl.c |  8 +++++++-
 2 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index ba90729d1111..47677f0493c7 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -997,6 +997,7 @@ struct netns_ipvs {
 	int			sysctl_pmtu_disc;
 	int			sysctl_backup_only;
 	int			sysctl_conn_reuse_mode;
+	int			sysctl_schedule_icmp;
 
 	/* ip_vs_lblc */
 	int			sysctl_lblc_expiration;
@@ -1115,6 +1116,11 @@ static inline int sysctl_conn_reuse_mode(struct netns_ipvs *ipvs)
 	return ipvs->sysctl_conn_reuse_mode;
 }
 
+static inline int sysctl_schedule_icmp(struct netns_ipvs *ipvs)
+{
+	return ipvs->sysctl_schedule_icmp;
+}
+
 #else
 
 static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
@@ -1187,6 +1193,11 @@ static inline int sysctl_conn_reuse_mode(struct netns_ipvs *ipvs)
 	return 1;
 }
 
+static inline int sysctl_schedule_icmp(struct netns_ipvs *ipvs)
+{
+	return 0;
+}
+
 #endif
 
 /* IPVS core functions
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 1a23e91d50d8..31d80e203863 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1844,6 +1844,12 @@ static struct ctl_table vs_vars[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "schedule_icmp",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 #ifdef CONFIG_IP_VS_DEBUG
 	{
 		.procname	= "debug_level",
@@ -3895,7 +3901,7 @@ static int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 	tbl[idx++].data = &ipvs->sysctl_backup_only;
 	ipvs->sysctl_conn_reuse_mode = 1;
 	tbl[idx++].data = &ipvs->sysctl_conn_reuse_mode;
-
+	tbl[idx++].data = &ipvs->sysctl_schedule_icmp;
 
 	ipvs->sysctl_hdr = register_net_sysctl(net, "net/ipv4/vs", tbl);
 	if (ipvs->sysctl_hdr == NULL) {
-- 
2.1.4

