From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [*v6 PATCH 3/8] IPVS: skb defrag in L7 helpers
Date: Fri, 19 Nov 2010 14:25:09 +0100
Message-ID: <1290173114-732-3-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org, daniel.lezcano@free.fr
Cc: hans@schillstrom.com, Hans Schillstrom <hans.schillstrom@ericsson.com>

L7 helpers like sip needs skb defrag
since L7 data can be fragmented.

This patch requires "IPVS Break ports-2 into src_port and dst_port" patch

*v3
  Removed unneeded if (skb_shinfo(skb)->nr_frags)
  from Julian.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
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

