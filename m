From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next] ipvs: allow rescheduling of new connections when port reuse is detected
Date: Mon,  2 Mar 2015 11:39:23 +0900
Message-ID: <1425263963-6660-2-git-send-email-horms@verge.net.au>
References: <1425263963-6660-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1425263963-6660-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Marcelo Ricardo Leitner <mleitner@redhat.com>, Simon Horman <horms@verge.net.au>

From: Marcelo Ricardo Leitner <mleitner@redhat.com>

Currently, when TCP/SCTP port reusing happens, IPVS will find the old
entry and use it for the new one, behaving like a forced persistence.
But if you consider a cluster with a heavy load of small connections,
such reuse will happen often and may lead to a not optimal load
balancing and might prevent a new node from getting a fair load.

This patch introduces a new sysctl, conn_reuse_mode, that allows
controlling how to proceed when port reuse is detected. The default
value will allow rescheduling of new connections only if the old entry
was in TIME_WAIT state for TCP or CLOSED for SCTP.

Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 Documentation/networking/ipvs-sysctl.txt | 21 ++++++++++++++++++++
 include/net/ip_vs.h                      | 11 +++++++++++
 net/netfilter/ipvs/ip_vs_core.c          | 33 ++++++++++++++++++++++++++++----
 net/netfilter/ipvs/ip_vs_ctl.c           |  8 ++++++++
 net/netfilter/ipvs/ip_vs_sync.c          | 21 ++++++++++++++++++--
 5 files changed, 88 insertions(+), 6 deletions(-)

diff --git a/Documentation/networking/ipvs-sysctl.txt b/Documentation/networking/ipvs-sysctl.txt
index 7a3c047..3ba7095 100644
--- a/Documentation/networking/ipvs-sysctl.txt
+++ b/Documentation/networking/ipvs-sysctl.txt
@@ -22,6 +22,27 @@ backup_only - BOOLEAN
 	If set, disable the director function while the server is
 	in backup mode to avoid packet loops for DR/TUN methods.
 
+conn_reuse_mode - INTEGER
+	1 - default
+
+	Controls how ipvs will deal with connections that are detected
+	port reuse. It is a bitmap, with the values being:
+
+	0: disable any special handling on port reuse. The new
+	connection will be delivered to the same real server that was
+	servicing the previous connection. This will effectively
+	disable expire_nodest_conn.
+
+	bit 1: enable rescheduling of new connections when it is safe.
+	That is, whenever expire_nodest_conn and for TCP sockets, when
+	the connection is in TIME_WAIT state (which is only possible if
+	you use NAT mode).
+
+	bit 2: it is bit 1 plus, for TCP connections, when connections
+	are in FIN_WAIT state, as this is the last state seen by load
+	balancer in Direct Routing mode. This bit helps on adding new
+	real servers to a very busy cluster.
+
 conntrack - BOOLEAN
 	0 - disabled (default)
 	not 0 - enabled
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index a627fe6..20fd233 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -941,6 +941,7 @@ struct netns_ipvs {
 	int			sysctl_nat_icmp_send;
 	int			sysctl_pmtu_disc;
 	int			sysctl_backup_only;
+	int			sysctl_conn_reuse_mode;
 
 	/* ip_vs_lblc */
 	int			sysctl_lblc_expiration;
@@ -1059,6 +1060,11 @@ static inline int sysctl_backup_only(struct netns_ipvs *ipvs)
 	       ipvs->sysctl_backup_only;
 }
 
+static inline int sysctl_conn_reuse_mode(struct netns_ipvs *ipvs)
+{
+	return ipvs->sysctl_conn_reuse_mode;
+}
+
 #else
 
 static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
@@ -1126,6 +1132,11 @@ static inline int sysctl_backup_only(struct netns_ipvs *ipvs)
 	return 0;
 }
 
+static inline int sysctl_conn_reuse_mode(struct netns_ipvs *ipvs)
+{
+	return 1;
+}
+
 #endif
 
 /* IPVS core functions
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index c9470c8..6103ab93 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1042,6 +1042,26 @@ static inline bool is_new_conn(const struct sk_buff *skb,
 	}
 }
 
+static inline bool is_new_conn_expected(const struct ip_vs_conn *cp,
+					int conn_reuse_mode)
+{
+	/* Controlled (FTP DATA or persistence)? */
+	if (cp->control)
+		return false;
+
+	switch (cp->protocol) {
+	case IPPROTO_TCP:
+		return (cp->state == IP_VS_TCP_S_TIME_WAIT) ||
+			((conn_reuse_mode & 2) &&
+			 (cp->state == IP_VS_TCP_S_FIN_WAIT) &&
+			 (cp->flags & IP_VS_CONN_F_NOOUTPUT));
+	case IPPROTO_SCTP:
+		return cp->state == IP_VS_SCTP_S_CLOSED;
+	default:
+		return false;
+	}
+}
+
 /* Handle response packets: rewrite addresses and send away...
  */
 static unsigned int
@@ -1580,6 +1600,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	struct ip_vs_conn *cp;
 	int ret, pkts;
 	struct netns_ipvs *ipvs;
+	int conn_reuse_mode;
 
 	/* Already marked as IPVS request or reply? */
 	if (skb->ipvs_property)
@@ -1648,10 +1669,14 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	 */
 	cp = pp->conn_in_get(af, skb, &iph, 0);
 
-	if (unlikely(sysctl_expire_nodest_conn(ipvs)) && cp && cp->dest &&
-	    unlikely(!atomic_read(&cp->dest->weight)) && !iph.fragoffs &&
-	    is_new_conn(skb, &iph)) {
-		ip_vs_conn_expire_now(cp);
+	conn_reuse_mode = sysctl_conn_reuse_mode(ipvs);
+	if (conn_reuse_mode && !iph.fragoffs &&
+	    is_new_conn(skb, &iph) && cp &&
+	    ((unlikely(sysctl_expire_nodest_conn(ipvs)) && cp->dest &&
+	      unlikely(!atomic_read(&cp->dest->weight))) ||
+	     unlikely(is_new_conn_expected(cp, conn_reuse_mode)))) {
+		if (!atomic_read(&cp->n_control))
+			ip_vs_conn_expire_now(cp);
 		__ip_vs_conn_put(cp);
 		cp = NULL;
 	}
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 6fd6005..76cc9ff 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1823,6 +1823,12 @@ static struct ctl_table vs_vars[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "conn_reuse_mode",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 #ifdef CONFIG_IP_VS_DEBUG
 	{
 		.procname	= "debug_level",
@@ -3790,6 +3796,8 @@ static int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 	ipvs->sysctl_pmtu_disc = 1;
 	tbl[idx++].data = &ipvs->sysctl_pmtu_disc;
 	tbl[idx++].data = &ipvs->sysctl_backup_only;
+	ipvs->sysctl_conn_reuse_mode = 1;
+	tbl[idx++].data = &ipvs->sysctl_conn_reuse_mode;
 
 
 	ipvs->sysctl_hdr = register_net_sysctl(net, "net/ipv4/vs", tbl);
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index c47ffd7..f96229c 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -845,10 +845,27 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 	struct ip_vs_conn *cp;
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	if (!(flags & IP_VS_CONN_F_TEMPLATE))
+	if (!(flags & IP_VS_CONN_F_TEMPLATE)) {
 		cp = ip_vs_conn_in_get(param);
-	else
+		if (cp && ((cp->dport != dport) ||
+			   !ip_vs_addr_equal(cp->daf, &cp->daddr, daddr))) {
+			if (!(flags & IP_VS_CONN_F_INACTIVE)) {
+				ip_vs_conn_expire_now(cp);
+				__ip_vs_conn_put(cp);
+				cp = NULL;
+			} else {
+				/* This is the expiration message for the
+				 * connection that was already replaced, so we
+				 * just ignore it.
+				 */
+				__ip_vs_conn_put(cp);
+				kfree(param->pe_data);
+				return;
+			}
+		}
+	} else {
 		cp = ip_vs_ct_in_get(param);
+	}
 
 	if (cp) {
 		/* Free pe_data */
-- 
2.1.4

