From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf 1/6] ipvs: fix ipv6 route unreach panic
Date: Thu, 16 Jul 2015 11:14:08 +0900
Message-ID: <1437012853-7318-2-git-send-email-horms@verge.net.au>
References: <1437012853-7318-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1437012853-7318-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Alex Gartrell <agartrell@fb.com>, Simon Horman <horms@verge.net.au>

From: Alex Gartrell <agartrell@fb.com>

Previously there was a trivial panic

unshare -n /bin/bash <<EOF
ip addr add dev lo face::1/128
ipvsadm -A -t [face::1]:15213
ipvsadm -a -t [face::1]:15213 -r b00c::1
echo boom | nc face::1 15213
EOF

This patch allows us to replicate the net logic above and simply capture
the skb_dst(skb)->dev and use that for the purpose of the invocation.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index bf66a8657a5f..b99d80695b1f 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -505,6 +505,13 @@ err_put:
 	return -1;
 
 err_unreach:
+	/* The ip6_link_failure function requires the dev field to be set
+	 * in order to get the net (further for the sake of fwmark
+	 * reflection).
+	 */
+	if (!skb->dev)
+		skb->dev = skb_dst(skb)->dev;
+
 	dst_link_failure(skb);
 	return -1;
 }
-- 
2.1.4

