From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 3/8] IPVS: skb defrag in L7 helpers
Date: Thu, 25 Nov 2010 10:46:53 +0900
Message-ID: <1290649618-18955-4-git-send-email-horms@verge.net.au>
References: <1290649618-18955-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1290649618-18955-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

L7 helpers like sip needs skb defrag
since L7 data can be fragmented.

This patch requires "IPVS Break ports-2 into src_port and dst_port" patch

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_pe_sip.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/ip_vs_pe_sip.c
index b8b4e96..0d83bc0 100644
--- a/net/netfilter/ipvs/ip_vs_pe_sip.c
+++ b/net/netfilter/ipvs/ip_vs_pe_sip.c
@@ -71,6 +71,7 @@ ip_vs_sip_fill_param(struct ip_vs_conn_param *p, struct sk_buff *skb)
 	struct ip_vs_iphdr iph;
 	unsigned int dataoff, datalen, matchoff, matchlen;
 	const char *dptr;
+	int retc;
 
 	ip_vs_fill_iphdr(p->af, skb_network_header(skb), &iph);
 
@@ -83,6 +84,8 @@ ip_vs_sip_fill_param(struct ip_vs_conn_param *p, struct sk_buff *skb)
 	if (dataoff >= skb->len)
 		return -EINVAL;
 
+	if ((retc=skb_linearize(skb)) < 0)
+		return retc;
 	dptr = skb->data + dataoff;
 	datalen = skb->len - dataoff;
 
-- 
1.7.2.3

