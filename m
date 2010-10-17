From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 05/12] ipvs: stop ICMP from FORWARD to local
Date: Sun, 17 Oct 2010 16:27:31 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010171624390.20665@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; format="flowed"; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


 	Delivering locally ICMP from FORWARD hook is not supported.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_core.c linux/net/netfilter/ipvs/ip_vs_core.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_core.c	2010-10-16 15:14:05.629354594 +0300
+++ linux/net/netfilter/ipvs/ip_vs_core.c	2010-10-16 16:30:01.832355877 +0300
@@ -48,6 +48,7 @@
  #ifdef CONFIG_IP_VS_IPV6
  #include <net/ipv6.h>
  #include <linux/netfilter_ipv6.h>
+#include <net/ip6_route.h>
  #endif

  #include <net/ip_vs.h>
@@ -1191,7 +1192,14 @@ ip_vs_in_icmp(struct sk_buff *skb, int *
  	if (IPPROTO_TCP == cih->protocol || IPPROTO_UDP == cih->protocol)
  		offset += 2 * sizeof(__u16);
  	verdict = ip_vs_icmp_xmit(skb, cp, pp, offset);
-	/* do not touch skb anymore */
+	/* LOCALNODE from FORWARD hook is not supported */
+	if (verdict == NF_ACCEPT && hooknum == NF_INET_FORWARD &&
+	    skb_rtable(skb)->rt_flags & RTCF_LOCAL) {
+		IP_VS_DBG(1, "%s(): "
+			  "local delivery to %pI4 but in FORWARD\n",
+			  __func__, &skb_rtable(skb)->rt_dst);
+		verdict = NF_DROP;
+	}

    out:
  	__ip_vs_conn_put(cp);
@@ -1212,6 +1220,7 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, in
  	struct ip_vs_protocol *pp;
  	unsigned int offset, verdict;
  	union nf_inet_addr snet;
+	struct rt6_info *rt;

  	*related = 1;

@@ -1290,7 +1299,15 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, in
  	    IPPROTO_SCTP == cih->nexthdr)
  		offset += 2 * sizeof(__u16);
  	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, offset);
-	/* do not touch skb anymore */
+	/* LOCALNODE from FORWARD hook is not supported */
+	if (verdict == NF_ACCEPT && hooknum == NF_INET_FORWARD &&
+	    (rt = (struct rt6_info *) skb_dst(skb)) &&
+	    rt->rt6i_dev && rt->rt6i_dev->flags & IFF_LOOPBACK) {
+		IP_VS_DBG(1, "%s(): "
+			  "local delivery to %pI6 but in FORWARD\n",
+			  __func__, &rt->rt6i_dst);
+		verdict = NF_DROP;
+	}

  	__ip_vs_conn_put(cp);

