From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 5/5] ipvs: add pmtu_disc option to disable IP DF for TUN packets
Date: Fri, 10 Aug 2012 10:41:34 +0900
Message-ID: <1344562895-22790-6-git-send-email-horms@verge.net.au>
References: <1344562895-22790-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1344562895-22790-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

	Disabling PMTU discovery can increase the output packet
rate but some users have enough resources and prefer to fragment
than to drop traffic. By default, we copy the DF bit but if
pmtu_disc is disabled we do not send FRAG_NEEDED messages anymore.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             | 11 +++++++++++
 net/netfilter/ipvs/ip_vs_ctl.c  |  8 ++++++++
 net/netfilter/ipvs/ip_vs_xmit.c |  6 +++---
 3 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 4b8f18f..ee75ccd 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -888,6 +888,7 @@ struct netns_ipvs {
 	unsigned int		sysctl_sync_refresh_period;
 	int			sysctl_sync_retries;
 	int			sysctl_nat_icmp_send;
+	int			sysctl_pmtu_disc;
 
 	/* ip_vs_lblc */
 	int			sysctl_lblc_expiration;
@@ -974,6 +975,11 @@ static inline int sysctl_sync_sock_size(struct netns_ipvs *ipvs)
 	return ipvs->sysctl_sync_sock_size;
 }
 
+static inline int sysctl_pmtu_disc(struct netns_ipvs *ipvs)
+{
+	return ipvs->sysctl_pmtu_disc;
+}
+
 #else
 
 static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
@@ -1016,6 +1022,11 @@ static inline int sysctl_sync_sock_size(struct netns_ipvs *ipvs)
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
index d6d5cca..03d3fc6 100644
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
@@ -3726,6 +3732,8 @@ static int __net_init ip_vs_control_net_init_sysctl(struct net *net)
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
1.7.10.2.484.gcd07cc5

