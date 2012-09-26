From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH V4 7/7] ipvs: SIP fragment handling
Date: Wed, 26 Sep 2012 14:07:33 +0200
Message-ID: <20120926120722.24804.28000.stgit@dragon>
References: <20120926120534.24804.78415.stgit@dragon>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20120926120534.24804.78415.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Hans Schillstrom <hans@schillstrom.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>, netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Patrick McHardy <kaber@trash.net>, Thomas Graf <tgraf@suug.ch>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>

Use the nfct_reasm SKB if available.

Based on part of a patch from: Hans Schillstrom
I have left Hans'es comment in the patch (marked /HS)

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
V3:
 - I have split out the SIP fragment handling into a seperate patch.
   As I have not been able to test this part.
 - Change the strange SKB swapping reasm = skb, reverse logic to minimize patch


 net/netfilter/ipvs/ip_vs_pe_sip.c |   19 +++++++++++++++----
 1 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/ip_vs_pe_sip.c
index ee4e2e3..43acba6 100644
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
@@ -78,13 +79,23 @@ ip_vs_sip_fill_param(struct ip_vs_conn_param *p, struct sk_buff *skb)
 	/* Only useful with UDP */
 	if (iph.protocol != IPPROTO_UDP)
 		return -EINVAL;
+	/*
+	 * todo: IPv6 fragments:
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
+	/*
+	 * todo: Check if this will mess-up the reasm skb !!! /HS
+	 */
+	retc = skb_linearize(skb);
+	if (retc < 0)
 		return retc;
 	dptr = skb->data + dataoff;
 	datalen = skb->len - dataoff;
