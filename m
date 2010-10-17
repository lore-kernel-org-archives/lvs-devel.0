From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 06/12] ipvs: fix CHECKSUM_PARTIAL for TUN method
Date: Sun, 17 Oct 2010 16:29:40 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010171627320.20665@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; format="flowed"; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


 	The recent change in IP_VS_XMIT_TUNNEL to set
CHECKSUM_NONE is not correct. After adding IPIP header
skb->csum becomes invalid but the CHECKSUM_PARTIAL
case must be supported. So, use skb_forward_csum() which is
most suitable for us to allow local clients to send IPIP
to remote real server.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_xmit.c linux/net/netfilter/ipvs/ip_vs_xmit.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_xmit.c	2010-10-16 15:13:35.797354211 +0300
+++ linux/net/netfilter/ipvs/ip_vs_xmit.c	2010-10-16 16:32:34.292355032 +0300
@@ -202,7 +202,7 @@ ip_vs_dst_reset(struct ip_vs_dest *dest)
  		__ret = ip_vs_confirm_conntrack(skb, cp);	\
  	if (__ret == NF_ACCEPT) {				\
  		nf_reset(skb);					\
-		(skb)->ip_summed = CHECKSUM_NONE;		\
+		skb_forward_csum(skb);				\
  	}							\
  	__ret;							\
  })
