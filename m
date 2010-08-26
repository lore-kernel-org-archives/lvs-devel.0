From: Simon Horman <horms@verge.net.au>
Subject: [patch net-next 1/4] [patch nf-next v2] IPVS: ICMPv6 checksum calculation
Date: Thu, 26 Aug 2010 21:54:28 +0900
Message-ID: <20100826125726.621600393@vergenet.net>
References: <20100826125427.056491061@vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=ipvs-icmpv6-checksum-calulation.patch
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, Xiaoyu Du <tingsrain@gmail.com>

Cc: Xiaoyu Du <tingsrain@gmail.com>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>

Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_core.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_core.c	2010-08-25 16:57:37.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_core.c	2010-08-25 17:02:35.000000000 +0900
@@ -637,9 +637,11 @@ void ip_vs_nat_icmp_v6(struct sk_buff *s
 	}
 
 	/* And finally the ICMP checksum */
-	icmph->icmp6_cksum = 0;
-	/* TODO IPv6: is this correct for ICMPv6? */
-	ip_vs_checksum_complete(skb, icmp_offset);
+	icmph->icmp6_cksum = ~csum_ipv6_magic(&iph->saddr, &iph->daddr,
+					      skb->len - icmp_offset,
+					      IPPROTO_ICMPV6, 0);
+	skb->csum_start = skb_network_header(skb) - skb->head + icmp_offset;
+	skb->csum_offset = offsetof(struct icmp6hdr, icmp6_cksum);
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 	if (inout)

