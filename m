From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf 4/6] ipvs: skb_orphan in case of forwarding
Date: Thu, 16 Jul 2015 11:14:11 +0900
Message-ID: <1437012853-7318-5-git-send-email-horms@verge.net.au>
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

It is possible that we bind against a local socket in early_demux when we
are actually going to want to forward it.  In this case, the socket serves
no purpose and only serves to confuse things (particularly functions which
implicitly expect sk_fullsock to be true, like ip_local_out).
Additionally, skb_set_owner_w is totally broken for non full-socks.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
Fixes: 41063e9dd119 ("ipv4: Early TCP socket demux.")
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index ec30d68ccc0b..34dc1429ebdb 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -533,6 +533,21 @@ static inline int ip_vs_tunnel_xmit_prepare(struct sk_buff *skb,
 	return ret;
 }
 
+/* In the event of a remote destination, it's possible that we would have
+ * matches against an old socket (particularly a TIME-WAIT socket). This
+ * causes havoc down the line (ip_local_out et. al. expect regular sockets
+ * and invalid memory accesses will happen) so simply drop the association
+ * in this case.
+*/
+static inline void ip_vs_drop_early_demux_sk(struct sk_buff *skb)
+{
+	/* If dev is set, the packet came from the LOCAL_IN callback and
+	 * not from a local TCP socket.
+	 */
+	if (skb->dev)
+		skb_orphan(skb);
+}
+
 /* return NF_STOLEN (sent) or NF_ACCEPT if local=1 (not sent) */
 static inline int ip_vs_nat_send_or_cont(int pf, struct sk_buff *skb,
 					 struct ip_vs_conn *cp, int local)
@@ -544,12 +559,21 @@ static inline int ip_vs_nat_send_or_cont(int pf, struct sk_buff *skb,
 		ip_vs_notrack(skb);
 	else
 		ip_vs_update_conntrack(skb, cp, 1);
+
+	/* Remove the early_demux association unless it's bound for the
+	 * exact same port and address on this host after translation.
+	 */
+	if (!local || cp->vport != cp->dport ||
+	    !ip_vs_addr_equal(cp->af, &cp->vaddr, &cp->daddr))
+		ip_vs_drop_early_demux_sk(skb);
+
 	if (!local) {
 		skb_forward_csum(skb);
 		NF_HOOK(pf, NF_INET_LOCAL_OUT, NULL, skb,
 			NULL, skb_dst(skb)->dev, dst_output_sk);
 	} else
 		ret = NF_ACCEPT;
+
 	return ret;
 }
 
@@ -563,6 +587,7 @@ static inline int ip_vs_send_or_cont(int pf, struct sk_buff *skb,
 	if (likely(!(cp->flags & IP_VS_CONN_F_NFCT)))
 		ip_vs_notrack(skb);
 	if (!local) {
+		ip_vs_drop_early_demux_sk(skb);
 		skb_forward_csum(skb);
 		NF_HOOK(pf, NF_INET_LOCAL_OUT, NULL, skb,
 			NULL, skb_dst(skb)->dev, dst_output_sk);
@@ -851,6 +876,8 @@ ip_vs_prepare_tunneled_skb(struct sk_buff *skb, int skb_af,
 	struct ipv6hdr *old_ipv6h = NULL;
 #endif
 
+	ip_vs_drop_early_demux_sk(skb);
+
 	if (skb_headroom(skb) < max_headroom || skb_cloned(skb)) {
 		new_skb = skb_realloc_headroom(skb, max_headroom);
 		if (!new_skb)
-- 
2.1.4

