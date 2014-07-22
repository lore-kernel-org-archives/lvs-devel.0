From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] ipvs: Maintain all DSCP and ECN bits for ipv6 tun forwarding
Date: Tue, 22 Jul 2014 16:25:52 +0900
Message-ID: <1406013952-18522-2-git-send-email-horms@verge.net.au>
References: <1406013952-18522-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1406013952-18522-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Alex Gartrell <agartrell@fb.com>, Simon Horman <horms@verge.net.au>

From: Alex Gartrell <agartrell@fb.com>

Previously, only the four high bits of the tclass were maintained in the
ipv6 case.  This matches the behavior of ipv4, though whether or not we
should reflect ECN bits may be up for debate.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 73ba1cc..6f70bdd 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -967,8 +967,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	iph->nexthdr		=	IPPROTO_IPV6;
 	iph->payload_len	=	old_iph->payload_len;
 	be16_add_cpu(&iph->payload_len, sizeof(*old_iph));
-	iph->priority		=	old_iph->priority;
 	memset(&iph->flow_lbl, 0, sizeof(iph->flow_lbl));
+	ipv6_change_dsfield(iph, 0, ipv6_get_dsfield(old_iph));
 	iph->daddr = cp->daddr.in6;
 	iph->saddr = saddr;
 	iph->hop_limit		=	old_iph->hop_limit;
-- 
2.0.1
