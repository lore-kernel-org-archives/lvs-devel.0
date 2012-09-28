From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 7/7] ipvs: SIP fragment handling
Date: Fri, 28 Sep 2012 11:55:04 +0900
Message-ID: <1348800904-23902-8-git-send-email-horms@verge.net.au>
References: <1348800904-23902-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1348800904-23902-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Hans Schillstrom <hans@schillstrom.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Simon Horman <horms@verge.net.au>

From: Jesper Dangaard Brouer <brouer@redhat.com>

Use the nfct_reasm SKB if available.

Based on part of a patch from: Hans Schillstrom
I have left Hans'es comment in the patch (marked /HS)

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
[ horms@verge.net.au: Fix comment style ]
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_pe_sip.c |   16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/ip_vs_pe_sip.c
index ee4e2e3..12475ef 100644
--- a/net/netfilter/ipvs/ip_vs_pe_sip.c
+++ b/net/netfilter/ipvs/ip_vs_pe_sip.c
@@ -68,6 +68,7 @@ static int get_callid(const char *dptr, unsigned int dataoff,
 static int
 ip_vs_sip_fill_param(struct ip_vs_conn_param *p, struct sk_buff *skb)
 {
+	struct sk_buff *reasm = skb_nfct_reasm(skb);
 	struct ip_vs_iphdr iph;
 	unsigned int dataoff, datalen, matchoff, matchlen;
 	const char *dptr;
@@ -78,13 +79,20 @@ ip_vs_sip_fill_param(struct ip_vs_conn_param *p, struct sk_buff *skb)
 	/* Only useful with UDP */
 	if (iph.protocol != IPPROTO_UDP)
 		return -EINVAL;
+	/* todo: IPv6 fragments:
+	 *       I think this only should be done for the first fragment. /HS
+	 */
+	if (reasm) {
+		skb = reasm;
+		dataoff = iph.thoff_reasm + sizeof(struct udphdr);
+	} else
+		dataoff = iph.len + sizeof(struct udphdr);
 
-	/* No Data ? */
-	dataoff = iph.len + sizeof(struct udphdr);
 	if (dataoff >= skb->len)
 		return -EINVAL;
-
-	if ((retc=skb_linearize(skb)) < 0)
+	/* todo: Check if this will mess-up the reasm skb !!! /HS */
+	retc = skb_linearize(skb);
+	if (retc < 0)
 		return retc;
 	dptr = skb->data + dataoff;
 	datalen = skb->len - dataoff;
-- 
1.7.10.4

