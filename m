From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs,v3 09/20] ipvs: Add generic ensure_mtu_is_adequate to handle mixed pools
Date: Wed, 27 Aug 2014 22:43:43 -0700
Message-ID: <1409204634-1123-10-git-send-email-agartrell@fb.com>
References: <1409204634-1123-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=trykdRxQFbVJFiKiEqvzZIyKiLWGSv8OLUVlGVFUDTM=;
 b=NFOPR5mLi8yrOqG2Z1NTV9JO2onqSgsIQTG5Mm/AwYjVYbtn6woLcLgzKYuCH2BkqzM6
 sKfeTLAKTiZVB80LXNjXMNef2/V3OdDuKvneDHIi8KwF0ObfORR+muNkMYoNu6iS44wn
 cl1VocxxtNPr+wAFItPz1ux266AFmmc9UU4= 
In-Reply-To: <1409204634-1123-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

The out_rt functions check to see if the mtu is large enough for the packet
and, if not, send icmp messages (TOOBIG or DEST_UNREACH) to the source and
bail out.  We needed the ability to send ICMP from the out_rt_v6 function
and DEST_UNREACH from the out_rt function, so we just pulled it out into a
common function.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 79 +++++++++++++++++++++++++++--------------
 1 file changed, 53 insertions(+), 26 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index caab1ad..ffe777b 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -213,17 +213,58 @@ static inline void maybe_update_pmtu(int skb_af, struct sk_buff *skb, int mtu)
 		ort->dst.ops->update_pmtu(&ort->dst, sk, NULL, mtu);
 }
 
+static inline bool ensure_mtu_is_adequate(int skb_af, int rt_mode,
+					  struct ip_vs_iphdr *ipvsh,
+					  struct sk_buff *skb, int mtu)
+{
+	struct netns_ipvs *ipvs = NULL;
+	struct net *net = NULL;
+#ifdef CONFIG_IP_VS_IPV6
+	if (skb_af == AF_INET6) {
+		net = dev_net(skb_dst(skb)->dev);
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
+		ipvs = net_ipvs(skb_net(skb));
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
 
@@ -279,7 +320,6 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 			     " daddr=%pI4\n", &dest->addr.ip);
 		goto err_put;
 	}
-	iph = ip_hdr(skb);
 
 	if (unlikely(local)) {
 		/* skb to local stack, preserve old route */
@@ -290,7 +330,6 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 
 	if (likely(!(rt_mode & IP_VS_RT_MODE_TUNNEL))) {
 		mtu = dst_mtu(&rt->dst);
-		df = iph->frag_off & htons(IP_DF);
 	} else {
 		mtu = dst_mtu(&rt->dst) - sizeof(struct iphdr);
 		if (mtu < 68) {
@@ -298,16 +337,10 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
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
@@ -450,15 +483,9 @@ __ip_vs_get_out_rt_v6(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 		maybe_update_pmtu(skb_af, skb, mtu);
 	}
 
-	if (unlikely(__mtu_check_toobig_v6(skb, mtu))) {
-		if (!skb->dev)
-			skb->dev = net->loopback_dev;
-		/* only send ICMP too big on first fragment */
-		if (!ipvsh->fragoffs)
-			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
-		IP_VS_DBG(1, "frag needed for %pI6c\n", &ipv6_hdr(skb)->saddr);
+
+	if (!ensure_mtu_is_adequate(skb_af, rt_mode, ipvsh, skb, mtu))
 		goto err_put;
-	}
 
 	skb_dst_drop(skb);
 	if (noref) {
@@ -565,7 +592,7 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	rcu_read_lock();
 	if (__ip_vs_get_out_rt(cp->af, skb, NULL, iph->daddr,
-			       IP_VS_RT_MODE_NON_LOCAL, NULL) < 0)
+			       IP_VS_RT_MODE_NON_LOCAL, NULL, ipvsh) < 0)
 		goto tx_error;
 
 	ip_send_check(iph);
@@ -644,7 +671,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	local = __ip_vs_get_out_rt(cp->af, skb, cp->dest, cp->daddr.ip,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
-				   IP_VS_RT_MODE_RDR, NULL);
+				   IP_VS_RT_MODE_RDR, NULL, ipvsh);
 	if (local < 0)
 		goto tx_error;
 	rt = skb_rtable(skb);
@@ -841,7 +868,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
 				   IP_VS_RT_MODE_CONNECT |
-				   IP_VS_RT_MODE_TUNNEL, &saddr);
+				   IP_VS_RT_MODE_TUNNEL, &saddr, ipvsh);
 	if (local < 0)
 		goto tx_error;
 	if (local) {
@@ -1032,7 +1059,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	local = __ip_vs_get_out_rt(cp->af, skb, cp->dest, cp->daddr.ip,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
-				   IP_VS_RT_MODE_KNOWN_NH, NULL);
+				   IP_VS_RT_MODE_KNOWN_NH, NULL, ipvsh);
 	if (local < 0)
 		goto tx_error;
 	if (local) {
@@ -1137,7 +1164,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		  IP_VS_RT_MODE_RDR : IP_VS_RT_MODE_NON_LOCAL;
 	rcu_read_lock();
 	local = __ip_vs_get_out_rt(cp->af, skb, cp->dest, cp->daddr.ip, rt_mode,
-				   NULL);
+				   NULL, iph);
 	if (local < 0)
 		goto tx_error;
 	rt = skb_rtable(skb);
-- 
1.8.1

