From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 2/2] ipvs: add pmtu_disc option to disable IP DF for TUN packets
Date: Fri, 20 Jul 2012 11:59:53 +0300
Message-ID: <1342774793-29234-3-git-send-email-ja@ssi.bg>
References: <1342774793-29234-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1342774793-29234-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

	Disabling PMTU discovery can increase the output packet
rate but some users have enough resources and prefer to fragment
than to drop traffic. By default, we copy the DF bit but if
pmtu_disc is disabled we do not send FRAG_NEEDED messages anymore.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h             |   11 +++++++++++
 net/netfilter/ipvs/ip_vs_ctl.c  |    8 ++++++++
 net/netfilter/ipvs/ip_vs_xmit.c |    6 +++---
 3 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 95374d1..f6741ed 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -890,6 +890,7 @@ struct netns_ipvs {
 	unsigned int		sysctl_sync_refresh_period;
 	int			sysctl_sync_retries;
 	int			sysctl_nat_icmp_send;
+	int			sysctl_pmtu_disc;
 
 	/* ip_vs_lblc */
 	int			sysctl_lblc_expiration;
@@ -976,6 +977,11 @@ static inline int sysctl_sync_sock_size(struct netns_ipvs *ipvs)
 	return ipvs->sysctl_sync_sock_size;
 }
 
+static inline int sysctl_pmtu_disc(struct netns_ipvs *ipvs)
+{
+	return ipvs->sysctl_pmtu_disc;
+}
+
 #else
 
 static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
@@ -1018,6 +1024,11 @@ static inline int sysctl_sync_sock_size(struct netns_ipvs *ipvs)
 	return 0;
 }
 
+static inline int sysctl_pmtu_disc(struct netns_ipvs *ipvs)
+{
+	return 1;
+}
+
 #endif
 
 /*
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 84444dd..df7432c 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1801,6 +1801,12 @@ static struct ctl_table vs_vars[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "pmtu_disc",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 #ifdef CONFIG_IP_VS_DEBUG
 	{
 		.procname	= "debug_level",
@@ -3726,6 +3732,8 @@ int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 	ipvs->sysctl_sync_retries = clamp_t(int, DEFAULT_SYNC_RETRIES, 0, 3);
 	tbl[idx++].data = &ipvs->sysctl_sync_retries;
 	tbl[idx++].data = &ipvs->sysctl_nat_icmp_send;
+	ipvs->sysctl_pmtu_disc = 1;
+	tbl[idx++].data = &ipvs->sysctl_pmtu_disc;
 
 
 	ipvs->sysctl_hdr = register_net_sysctl(net, "net/ipv4/vs", tbl);
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index c2275ba..543a554 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -795,6 +795,7 @@ int
 ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		  struct ip_vs_protocol *pp)
 {
+	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
 	struct rtable *rt;			/* Route to the other host */
 	__be32 saddr;				/* Source for tunnel */
 	struct net_device *tdev;		/* Device to other host */
@@ -830,10 +831,9 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
 
 	/* Copy DF, reset fragment offset and MF */
-	df = old_iph->frag_off & htons(IP_DF);
+	df = sysctl_pmtu_disc(ipvs) ? old_iph->frag_off & htons(IP_DF) : 0;
 
-	if ((old_iph->frag_off & htons(IP_DF) &&
-	    mtu < ntohs(old_iph->tot_len) && !skb_is_gso(skb))) {
+	if (df && mtu < ntohs(old_iph->tot_len) && !skb_is_gso(skb)) {
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
 		goto tx_error_put;
-- 
1.7.3.4

