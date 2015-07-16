From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf 6/6] ipvs: call skb_sender_cpu_clear
Date: Thu, 16 Jul 2015 11:14:13 +0900
Message-ID: <1437012853-7318-7-git-send-email-horms@verge.net.au>
References: <1437012853-7318-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1437012853-7318-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

Reset XPS's sender_cpu on forwarding.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Fixes: 2bd82484bb4c ("xps: fix xps for stacked devices")
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 34dc1429ebdb..258a0b0e82a2 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -529,6 +529,8 @@ static inline int ip_vs_tunnel_xmit_prepare(struct sk_buff *skb,
 	if (ret == NF_ACCEPT) {
 		nf_reset(skb);
 		skb_forward_csum(skb);
+		if (!skb->sk)
+			skb_sender_cpu_clear(skb);
 	}
 	return ret;
 }
@@ -569,6 +571,8 @@ static inline int ip_vs_nat_send_or_cont(int pf, struct sk_buff *skb,
 
 	if (!local) {
 		skb_forward_csum(skb);
+		if (!skb->sk)
+			skb_sender_cpu_clear(skb);
 		NF_HOOK(pf, NF_INET_LOCAL_OUT, NULL, skb,
 			NULL, skb_dst(skb)->dev, dst_output_sk);
 	} else
@@ -589,6 +593,8 @@ static inline int ip_vs_send_or_cont(int pf, struct sk_buff *skb,
 	if (!local) {
 		ip_vs_drop_early_demux_sk(skb);
 		skb_forward_csum(skb);
+		if (!skb->sk)
+			skb_sender_cpu_clear(skb);
 		NF_HOOK(pf, NF_INET_LOCAL_OUT, NULL, skb,
 			NULL, skb_dst(skb)->dev, dst_output_sk);
 	} else
-- 
2.1.4

