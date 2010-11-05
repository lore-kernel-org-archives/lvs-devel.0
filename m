From: Simon Horman <horms@verge.net.au>
Subject: [RFC] ipvs: allow transmit of GRO aggregated skbs
Date: Fri, 5 Nov 2010 22:52:26 +0900
Message-ID: <20101105135222.GA8714@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Julian Anastasov <ja@ssi.bg>

This is a first attempt at allowing LVS to transmit
skbs of greater than MTU length that have been aggregated by GRO.

I have lightly tested the ip_vs_dr_xmit() portion of this patch and
although it seems to work I am unsure that netif_needs_gso() is the correct
test to use.

Signed-off-by: Simon Horman <horms@verge.net.au>

--- 

LRO is still an outstanding issue, but as its deprecated in favour
of GRO perhaps it doesn't need to be solved.

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 93c15a1..93a782e 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -246,7 +246,8 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->u.dst);
-	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF))) {
+	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF)) &&
+	    !netif_needs_gso(rt->u.dst.dev, skb)) {
 		ip_rt_put(rt);
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
@@ -310,7 +311,7 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->u.dst);
-	if (skb->len > mtu) {
+	if (skb->len > mtu && !netif_needs_gso(rt->u.dst.dev, skb)) {
 		dst_release(&rt->u.dst);
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
@@ -377,7 +378,8 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->u.dst);
-	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF))) {
+	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF)) &&
+	    !netif_needs_gso(rt->u.dst.dev, skb)) {
 		ip_rt_put(rt);
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
 		IP_VS_DBG_RL_PKT(0, pp, skb, 0, "ip_vs_nat_xmit(): frag needed for");
@@ -453,7 +455,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->u.dst);
-	if (skb->len > mtu) {
+	if (skb->len > mtu && !netif_needs_gso(rt->u.dst.dev, skb)) {
 		dst_release(&rt->u.dst);
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		IP_VS_DBG_RL_PKT(0, pp, skb, 0,
@@ -562,8 +564,9 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	df |= (old_iph->frag_off & htons(IP_DF));
 
-	if ((old_iph->frag_off & htons(IP_DF))
-	    && mtu < ntohs(old_iph->tot_len)) {
+	if ((old_iph->frag_off & htons(IP_DF) &&
+	    mtu < ntohs(old_iph->tot_len) &&
+	    !netif_needs_gso(rt->u.dst.dev, skb))) {
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
 		ip_rt_put(rt);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
@@ -672,7 +675,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	if (skb_dst(skb))
 		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), mtu);
 
-	if (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr)) {
+	if (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr) &&
+	    !netif_needs_gso(rt->u.dst.dev, skb)) {
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		dst_release(&rt->u.dst);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
@@ -761,7 +765,8 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->u.dst);
-	if ((iph->frag_off & htons(IP_DF)) && skb->len > mtu) {
+	if ((iph->frag_off & htons(IP_DF)) && skb->len > mtu &&
+	    !netif_needs_gso(rt->u.dst.dev, skb)) {
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
 		ip_rt_put(rt);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
@@ -889,7 +894,8 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->u.dst);
-	if ((skb->len > mtu) && (ip_hdr(skb)->frag_off & htons(IP_DF))) {
+	if ((skb->len > mtu) && (ip_hdr(skb)->frag_off & htons(IP_DF)) &&
+	    !netif_needs_gso(rt->u.dst.dev, skb)) {
 		ip_rt_put(rt);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
@@ -964,7 +970,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->u.dst);
-	if (skb->len > mtu) {
+	if (skb->len > mtu && !netif_needs_gso(rt->u.dst.dev, skb)) {
 		dst_release(&rt->u.dst);
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);

