From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 09/15] ipvs: Add generic ensure_mtu_is_adequate to handle mixed pools
Date: Thu, 18 Sep 2014 09:25:55 +0900
Message-ID: <1410999961-7975-10-git-send-email-horms@verge.net.au>
References: <1410999961-7975-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1410999961-7975-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Alex Gartrell <agartrell@fb.com>, Simon Horman <horms@verge.net.au>

From: Alex Gartrell <agartrell@fb.com>

The out_rt functions check to see if the mtu is large enough for the packet
and, if not, send icmp messages (TOOBIG or DEST_UNREACH) to the source and
bail out.  We needed the ability to send ICMP from the out_rt_v6 function
and DEST_UNREACH from the out_rt function, so we just pulled it out into a
common function.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 77 +++++++++++++++++++++++++++--------------
 1 file changed, 51 insertions(+), 26 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 034a282..fa2fdd7 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -213,17 +213,57 @@ static inline void maybe_update_pmtu(int skb_af, struct sk_buff *skb, int mtu)
 		ort->dst.ops->update_pmtu(&ort->dst, sk, NULL, mtu);
 }
 
+static inline bool ensure_mtu_is_adequate(int skb_af, int rt_mode,
+					  struct ip_vs_iphdr *ipvsh,
+					  struct sk_buff *skb, int mtu)
+{
+#ifdef CONFIG_IP_VS_IPV6
+	if (skb_af == AF_INET6) {
+		struct net *net = dev_net(skb_dst(skb)->dev);
+
+		if (unlikely(__mtu_check_toobig_v6(skb, mtu))) {
+			if (!skb->dev)
+				skb->dev = net->loopback_dev;
+			/* only send ICMP too big on first fragment */
+			if (!ipvsh->fragoffs)
+				icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
+			IP_VS_DBG(1, "frag needed for %pI6c\n",
+				  &ipv6_hdr(skb)->saddr);
+			return false;
+		}
+	} else
+#endif
+	{
+		struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
+
+		/* If we're going to tunnel the packet and pmtu discovery
+		 * is disabled, we'll just fragment it anyway
+		 */
+		if ((rt_mode & IP_VS_RT_MODE_TUNNEL) && !sysctl_pmtu_disc(ipvs))
+			return true;
+
+		if (unlikely(ip_hdr(skb)->frag_off & htons(IP_DF) &&
+			     skb->len > mtu && !skb_is_gso(skb))) {
+			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
+				  htonl(mtu));
+			IP_VS_DBG(1, "frag needed for %pI4\n",
+				  &ip_hdr(skb)->saddr);
+			return false;
+		}
+	}
+
+	return true;
+}
+
 /* Get route to destination or remote server */
 static int
 __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
-		   __be32 daddr, int rt_mode, __be32 *ret_saddr)
+		   __be32 daddr, int rt_mode, __be32 *ret_saddr,
+		   struct ip_vs_iphdr *ipvsh)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_dest_dst *dest_dst;
 	struct rtable *rt;			/* Route to the other host */
-	struct iphdr *iph;
-	__be16 df;
 	int mtu;
 	int local, noref = 1;
 
@@ -279,7 +319,6 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 			     " daddr=%pI4\n", &dest->addr.ip);
 		goto err_put;
 	}
-	iph = ip_hdr(skb);
 
 	if (unlikely(local)) {
 		/* skb to local stack, preserve old route */
@@ -290,7 +329,6 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 
 	if (likely(!(rt_mode & IP_VS_RT_MODE_TUNNEL))) {
 		mtu = dst_mtu(&rt->dst);
-		df = iph->frag_off & htons(IP_DF);
 	} else {
 		mtu = dst_mtu(&rt->dst) - sizeof(struct iphdr);
 		if (mtu < 68) {
@@ -298,16 +336,10 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 			goto err_put;
 		}
 		maybe_update_pmtu(skb_af, skb, mtu);
-		/* MTU check allowed? */
-		df = sysctl_pmtu_disc(ipvs) ? iph->frag_off & htons(IP_DF) : 0;
 	}
 
-	/* MTU checking */
-	if (unlikely(df && skb->len > mtu && !skb_is_gso(skb))) {
-		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
-		IP_VS_DBG(1, "frag needed for %pI4\n", &iph->saddr);
+	if (!ensure_mtu_is_adequate(skb_af, rt_mode, ipvsh, skb, mtu))
 		goto err_put;
-	}
 
 	skb_dst_drop(skb);
 	if (noref) {
@@ -450,15 +482,8 @@ __ip_vs_get_out_rt_v6(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 		maybe_update_pmtu(skb_af, skb, mtu);
 	}
 
-	if (unlikely(__mtu_check_toobig_v6(skb, mtu))) {
-		if (!skb->dev)
-			skb->dev = net->loopback_dev;
-		/* only send ICMP too big on first fragment */
-		if (!ipvsh->fragoffs)
-			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
-		IP_VS_DBG(1, "frag needed for %pI6c\n", &ipv6_hdr(skb)->saddr);
+	if (!ensure_mtu_is_adequate(skb_af, rt_mode, ipvsh, skb, mtu))
 		goto err_put;
-	}
 
 	skb_dst_drop(skb);
 	if (noref) {
@@ -565,7 +590,7 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	rcu_read_lock();
 	if (__ip_vs_get_out_rt(cp->af, skb, NULL, iph->daddr,
-			       IP_VS_RT_MODE_NON_LOCAL, NULL) < 0)
+			       IP_VS_RT_MODE_NON_LOCAL, NULL, ipvsh) < 0)
 		goto tx_error;
 
 	ip_send_check(iph);
@@ -644,7 +669,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	local = __ip_vs_get_out_rt(cp->af, skb, cp->dest, cp->daddr.ip,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
-				   IP_VS_RT_MODE_RDR, NULL);
+				   IP_VS_RT_MODE_RDR, NULL, ipvsh);
 	if (local < 0)
 		goto tx_error;
 	rt = skb_rtable(skb);
@@ -841,7 +866,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
 				   IP_VS_RT_MODE_CONNECT |
-				   IP_VS_RT_MODE_TUNNEL, &saddr);
+				   IP_VS_RT_MODE_TUNNEL, &saddr, ipvsh);
 	if (local < 0)
 		goto tx_error;
 	if (local) {
@@ -1032,7 +1057,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	local = __ip_vs_get_out_rt(cp->af, skb, cp->dest, cp->daddr.ip,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
-				   IP_VS_RT_MODE_KNOWN_NH, NULL);
+				   IP_VS_RT_MODE_KNOWN_NH, NULL, ipvsh);
 	if (local < 0)
 		goto tx_error;
 	if (local) {
@@ -1137,7 +1162,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		  IP_VS_RT_MODE_RDR : IP_VS_RT_MODE_NON_LOCAL;
 	rcu_read_lock();
 	local = __ip_vs_get_out_rt(cp->af, skb, cp->dest, cp->daddr.ip, rt_mode,
-				   NULL);
+				   NULL, iph);
 	if (local < 0)
 		goto tx_error;
 	rt = skb_rtable(skb);
-- 
2.0.1
