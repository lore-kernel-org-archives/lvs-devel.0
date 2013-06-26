From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 6/8] ipvs: add sync_persist_mode flag
Date: Wed, 26 Jun 2013 18:11:28 +0900
Message-ID: <1372237890-28211-7-git-send-email-horms@verge.net.au>
References: <1372237890-28211-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1372237890-28211-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

Add sync_persist_mode flag to reduce sync traffic
by syncing only persistent templates.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Tested-by: Aleksey Chudov <aleksey.chudov@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 Documentation/networking/ipvs-sysctl.txt | 13 +++++++++++++
 include/net/ip_vs.h                      | 11 +++++++++++
 net/netfilter/ipvs/ip_vs_ctl.c           |  7 +++++++
 net/netfilter/ipvs/ip_vs_sync.c          | 12 ++++++++++++
 4 files changed, 43 insertions(+)

diff --git a/Documentation/networking/ipvs-sysctl.txt b/Documentation/networking/ipvs-sysctl.txt
index 9573d0c..7a3c047 100644
--- a/Documentation/networking/ipvs-sysctl.txt
+++ b/Documentation/networking/ipvs-sysctl.txt
@@ -181,6 +181,19 @@ snat_reroute - BOOLEAN
 	always be the same as the original route so it is an optimisation
 	to disable snat_reroute and avoid the recalculation.
 
+sync_persist_mode - INTEGER
+	default 0
+
+	Controls the synchronisation of connections when using persistence
+
+	0: All types of connections are synchronised
+	1: Attempt to reduce the synchronisation traffic depending on
+	the connection type. For persistent services avoid synchronisation
+	for normal connections, do it only for persistence templates.
+	In such case, for TCP and SCTP it may need enabling sloppy_tcp and
+	sloppy_sctp flags on backup servers. For non-persistent services
+	such optimization is not applied, mode 0 is assumed.
+
 sync_version - INTEGER
 	default 1
 
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index e667df1..f0d70f0 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -975,6 +975,7 @@ struct netns_ipvs {
 	int			sysctl_snat_reroute;
 	int			sysctl_sync_ver;
 	int			sysctl_sync_ports;
+	int			sysctl_sync_persist_mode;
 	unsigned long		sysctl_sync_qlen_max;
 	int			sysctl_sync_sock_size;
 	int			sysctl_cache_bypass;
@@ -1076,6 +1077,11 @@ static inline int sysctl_sync_ports(struct netns_ipvs *ipvs)
 	return ACCESS_ONCE(ipvs->sysctl_sync_ports);
 }
 
+static inline int sysctl_sync_persist_mode(struct netns_ipvs *ipvs)
+{
+	return ipvs->sysctl_sync_persist_mode;
+}
+
 static inline unsigned long sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
 {
 	return ipvs->sysctl_sync_qlen_max;
@@ -1139,6 +1145,11 @@ static inline int sysctl_sync_ports(struct netns_ipvs *ipvs)
 	return 1;
 }
 
+static inline int sysctl_sync_persist_mode(struct netns_ipvs *ipvs)
+{
+	return 0;
+}
+
 static inline unsigned long sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
 {
 	return IPVS_SYNC_QLEN_MAX;
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index da035fc..c8148e4 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1715,6 +1715,12 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_do_sync_ports,
 	},
 	{
+		.procname	= "sync_persist_mode",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
 		.procname	= "sync_qlen_max",
 		.maxlen		= sizeof(unsigned long),
 		.mode		= 0644,
@@ -3729,6 +3735,7 @@ static int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 	tbl[idx++].data = &ipvs->sysctl_sync_ver;
 	ipvs->sysctl_sync_ports = 1;
 	tbl[idx++].data = &ipvs->sysctl_sync_ports;
+	tbl[idx++].data = &ipvs->sysctl_sync_persist_mode;
 	ipvs->sysctl_sync_qlen_max = nr_free_buffer_pages() / 32;
 	tbl[idx++].data = &ipvs->sysctl_sync_qlen_max;
 	ipvs->sysctl_sync_sock_size = 0;
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 2fc6639..f448471 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -425,6 +425,16 @@ ip_vs_sync_buff_create_v0(struct netns_ipvs *ipvs)
 	return sb;
 }
 
+/* Check if connection is controlled by persistence */
+static inline bool in_persistence(struct ip_vs_conn *cp)
+{
+	for (cp = cp->control; cp; cp = cp->control) {
+		if (cp->flags & IP_VS_CONN_F_TEMPLATE)
+			return true;
+	}
+	return false;
+}
+
 /* Check if conn should be synced.
  * pkts: conn packets, use sysctl_sync_threshold to avoid packet check
  * - (1) sync_refresh_period: reduce sync rate. Additionally, retry
@@ -447,6 +457,8 @@ static int ip_vs_sync_conn_needed(struct netns_ipvs *ipvs,
 	/* Check if we sync in current state */
 	if (unlikely(cp->flags & IP_VS_CONN_F_TEMPLATE))
 		force = 0;
+	else if (unlikely(sysctl_sync_persist_mode(ipvs) && in_persistence(cp)))
+		return 0;
 	else if (likely(cp->protocol == IPPROTO_TCP)) {
 		if (!((1 << cp->state) &
 		      ((1 << IP_VS_TCP_S_ESTABLISHED) |
-- 
1.8.2.1

