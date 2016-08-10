From: "Dwip N. Banerjee" <dwip@linux.vnet.ibm.com>
Subject: [PATCH] ipvs: decrement forwarded packet's IP ttl
Date: Tue, 09 Aug 2016 22:55:58 -0500
Message-ID: <1470801358.31822.4.camel@oc0624138382>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org


We decrement the IP ttl in all the modes in order to prevent infinite
route loops. The changes were done based on Julian Anastasov's
suggestions in a prior thread. 

The (ttl <= 1) check/discard and the actual decrement are done in 
__ip_vs_get_out_rt() and in __ip_vs_get_out_rt_v6(), for the IPv6
case. Because of the ttl change, the skb_make_writable() guard is 
also invoked therein.

The !ip_vs_iph_icmp(ipvsh) checks are removed from
ensure_mtu_is_adequate() as they seem unnecessary (icmp code doesn't
send ICMP error in response to another ICMP error).

Signed-off-by: Dwip Banerjee <dwip@linux.vnet.ibm.com>
---
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c
b/net/netfilter/ipvs/ip_vs_xmit.c
index 01d3d89..e3586bd 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -225,7 +225,7 @@ static inline bool ensure_mtu_is_adequate(struct
netns_ipvs *ipvs, int skb_af,
 			if (!skb->dev)
 				skb->dev = net->loopback_dev;
 			/* only send ICMP too big on first fragment */
-			if (!ipvsh->fragoffs && !ip_vs_iph_icmp(ipvsh))
+			if (!ipvsh->fragoffs)
 				icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 			IP_VS_DBG(1, "frag needed for %pI6c\n",
 				  &ipv6_hdr(skb)->saddr);
@@ -241,8 +241,7 @@ static inline bool ensure_mtu_is_adequate(struct
netns_ipvs *ipvs, int skb_af,
 			return true;
 
 		if (unlikely(ip_hdr(skb)->frag_off & htons(IP_DF) &&
-			     skb->len > mtu && !skb_is_gso(skb) &&
-			     !ip_vs_iph_icmp(ipvsh))) {
+			     skb->len > mtu && !skb_is_gso(skb))) {
 			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 				  htonl(mtu));
 			IP_VS_DBG(1, "frag needed for %pI4\n",
@@ -266,6 +265,7 @@ __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int
skb_af, struct sk_buff *skb,
 	struct rtable *rt;			/* Route to the other host */
 	int mtu;
 	int local, noref = 1;
+	struct iphdr  *iph = ip_hdr(skb);
 
 	if (dest) {
 		dest_dst = __ip_vs_dst_check(dest);
@@ -326,6 +326,14 @@ __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int
skb_af, struct sk_buff *skb,
 		return local;
 	}
 
+	if (iph->ttl <= 1) {
+		/* Tell the sender its packet died... */
+		__IP_INC_STATS(dev_net(skb_dst(skb)->dev),
+			       IPSTATS_MIB_INHDRERRORS);
+		icmp_send(skb, ICMP_TIME_EXCEEDED, ICMP_EXC_TTL, 0);
+		goto err_put;
+	}
+
 	if (likely(!(rt_mode & IP_VS_RT_MODE_TUNNEL))) {
 		mtu = dst_mtu(&rt->dst);
 	} else {
@@ -349,6 +357,13 @@ __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int
skb_af, struct sk_buff *skb,
 	} else
 		skb_dst_set(skb, &rt->dst);
 
+	/* don't propagate ttl change to cloned packets */
+	if (!skb_make_writable(skb, sizeof(struct iphdr)))
+		goto err_put;
+
+	/* Decrease ttl */
+	ip_decrease_ttl(iph);
+
 	return local;
 
 err_put:
@@ -414,6 +429,7 @@ __ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int
skb_af, struct sk_buff *skb,
 	struct dst_entry *dst;
 	int mtu;
 	int local, noref = 1;
+	struct ipv6hdr *hdr = ipv6_hdr(skb);
 
 	if (dest) {
 		dest_dst = __ip_vs_dst_check(dest);
@@ -473,6 +489,19 @@ __ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int
skb_af, struct sk_buff *skb,
 		return local;
 	}
 
+	/* check and decrement ttl */
+	if (hdr->hop_limit <= 1) {
+		/* Force OUTPUT device used as source address */
+		if (!dst)
+			dst = skb_dst(skb);
+		skb->dev = dst->dev;
+		icmpv6_send(skb, ICMPV6_TIME_EXCEED, ICMPV6_EXC_HOPLIMIT, 0);
+		__IP6_INC_STATS(net, ip6_dst_idev(dst),
+				IPSTATS_MIB_INHDRERRORS);
+
+		goto err_put;
+	}
+
 	/* MTU checking */
 	if (likely(!(rt_mode & IP_VS_RT_MODE_TUNNEL)))
 		mtu = dst_mtu(&rt->dst);
@@ -498,6 +527,11 @@ __ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int
skb_af, struct sk_buff *skb,
 	} else
 		skb_dst_set(skb, &rt->dst);
 
+	/* don't propagate ttl change to cloned packets */
+	if (!skb_make_writable(skb, sizeof(struct ipv6hdr)))
+		goto err_put;
+
+	hdr->hop_limit--;
 	return local;
 
 err_put:
@@ -739,9 +773,6 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct
ip_vs_conn *cp,
 	}
 
 	/* copy-on-write the packet before mangling it */
-	if (!skb_make_writable(skb, sizeof(struct iphdr)))
-		goto tx_error;
-
 	if (skb_cow(skb, rt->dst.dev->hard_header_len))
 		goto tx_error;
 
@@ -831,9 +862,6 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct
ip_vs_conn *cp,
 	}
 
 	/* copy-on-write the packet before mangling it */
-	if (!skb_make_writable(skb, sizeof(struct ipv6hdr)))
-		goto tx_error;
-
 	if (skb_cow(skb, rt->dst.dev->hard_header_len))
 		goto tx_error;
 
@@ -1302,9 +1330,6 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct
ip_vs_conn *cp,
 	}
 
 	/* copy-on-write the packet before mangling it */
-	if (!skb_make_writable(skb, offset))
-		goto tx_error;
-
 	if (skb_cow(skb, rt->dst.dev->hard_header_len))
 		goto tx_error;
 
@@ -1394,9 +1419,6 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct
ip_vs_conn *cp,
 	}
 
 	/* copy-on-write the packet before mangling it */
-	if (!skb_make_writable(skb, offset))
-		goto tx_error;
