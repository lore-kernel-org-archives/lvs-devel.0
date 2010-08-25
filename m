From: Simon Horman <horms@verge.net.au>
Subject: [patch nf-next v2] IPVS: ICMPv6 checksum calculation
Date: Wed, 25 Aug 2010 17:08:33 +0900
Message-ID: <20100825080832.GA24863@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Patrick McHardy <kaber@trash.net>, David Miller <davem@davemloft.net>, Xiaoyu Du <tingsrain@gmail.com>, Julian Anastasov <ja@ssi.bg>

Cc: Xiaoyu Du <tingsrain@gmail.com>
Cc: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>

--

Xiaoyu, is this the change that you tested?
If so could you give me a Tested-by line?

Julian, could I get an ack from you?
Alternatively, if you want to take ownership of the patch,
can I get a signed-off-by from you? In that case I'll change
the From accordingly.

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
