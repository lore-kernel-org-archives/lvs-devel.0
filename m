From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net] ipvs: clear skb->tstamp in forwarding path
Date: Fri,  9 Oct 2020 21:24:25 +0300
Message-ID: <20201009182425.9050-1-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, netfilter-devel@vger.kernel.org, Evgeny B <abt-admin@mail.ru>, Eric Dumazet <eric.dumazet@gmail.com>

fq qdisc requires tstamp to be cleared in forwarding path

Reported-by: Evgeny B <abt-admin@mail.ru>
Link: https://bugzilla.kernel.org/show_bug.cgi?id=209427
Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Fixes: 8203e2d844d3 ("net: clear skb->tstamp in forwarding paths")
Fixes: fb420d5d91c1 ("tcp/fq: move back to CLOCK_MONOTONIC")
Fixes: 80b14dee2bea ("net: Add a new socket option for a future transmit time.")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index b00866d777fe..d2e5a8f644b8 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -609,6 +609,8 @@ static inline int ip_vs_tunnel_xmit_prepare(struct sk_buff *skb,
 	if (ret == NF_ACCEPT) {
 		nf_reset_ct(skb);
 		skb_forward_csum(skb);
+		if (skb->dev)
+			skb->tstamp = 0;
 	}
 	return ret;
 }
@@ -649,6 +651,8 @@ static inline int ip_vs_nat_send_or_cont(int pf, struct sk_buff *skb,
 
 	if (!local) {
 		skb_forward_csum(skb);
+		if (skb->dev)
+			skb->tstamp = 0;
 		NF_HOOK(pf, NF_INET_LOCAL_OUT, cp->ipvs->net, NULL, skb,
 			NULL, skb_dst(skb)->dev, dst_output);
 	} else
@@ -669,6 +673,8 @@ static inline int ip_vs_send_or_cont(int pf, struct sk_buff *skb,
 	if (!local) {
 		ip_vs_drop_early_demux_sk(skb);
 		skb_forward_csum(skb);
+		if (skb->dev)
+			skb->tstamp = 0;
 		NF_HOOK(pf, NF_INET_LOCAL_OUT, cp->ipvs->net, NULL, skb,
 			NULL, skb_dst(skb)->dev, dst_output);
 	} else
-- 
2.26.2


