From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next,v2] ipvs: orphan skb on LOCAL_IN path
Date: Thu, 29 Jan 2015 13:25:51 -0800
Message-ID: <1422566751-92285-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : mime-version : content-type; s=facebook;
 bh=3qkIwFYrYWO+uVk7nQP/xsISyr/QM+rmPvy97cy6waE=;
 b=Tnjy5RHLbmVa0QOIa6aHGaF2s70qynBFIUhk7TSrroVIPRiE+SI2qFtQ4Rkrq3+CAlz4
 zYxYohIUv0WgewDWLmuewTEKMCjEDv45z0WCDuEM7znFgEhET4ZPtE+pa9WtefywjaGD
 A6igm8E9mGaOExjAEkIFoEaVBpAxm1DTWLA= 
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
Cc: lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

skb->sk can be set in the early_demux path.  This can be problematic, as it
may be a time-wait socket, which will blow up in the ip6_output path when
we try to pull out the non-existant pinet6 pointer (the type-punning causes
that pointer to be garbage).

This patch orphans the skb if it's not a local socket, so we no longer have
to worry about running into the time-wait problem from early demux.  It
does this by checking for dev, which is unset in that path.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 936fd29..9b8c3c4 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -484,6 +484,9 @@ static inline int ip_vs_tunnel_xmit_prepare(struct sk_buff *skb,
 	if (unlikely(cp->flags & IP_VS_CONN_F_NFCT))
 		ret = ip_vs_confirm_conntrack(skb);
 	if (ret == NF_ACCEPT) {
+		/* orphan on LOCAL_IN */
+		if (skb->dev)
+			skb_orphan(skb);
 		nf_reset(skb);
 		skb_forward_csum(skb);
 	}
@@ -502,6 +505,9 @@ static inline int ip_vs_nat_send_or_cont(int pf, struct sk_buff *skb,
 	else
 		ip_vs_update_conntrack(skb, cp, 1);
 	if (!local) {
+		/* orphan on LOCAL_IN */
+		if (skb->dev)
+			skb_orphan(skb);
 		skb_forward_csum(skb);
 		NF_HOOK(pf, NF_INET_LOCAL_OUT, skb, NULL, skb_dst(skb)->dev,
 			dst_output);
@@ -520,6 +526,9 @@ static inline int ip_vs_send_or_cont(int pf, struct sk_buff *skb,
 	if (likely(!(cp->flags & IP_VS_CONN_F_NFCT)))
 		ip_vs_notrack(skb);
 	if (!local) {
+		/* orphan on LOCAL_IN */
+		if (skb->dev)
+			skb_orphan(skb);
 		skb_forward_csum(skb);
 		NF_HOOK(pf, NF_INET_LOCAL_OUT, skb, NULL, skb_dst(skb)->dev,
 			dst_output);
-- 
Alex Gartrell <agartrell@fb.com>

