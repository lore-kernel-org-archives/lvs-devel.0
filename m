From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH ipvs] ipvs: call skb_sender_cpu_clear
Date: Thu,  9 Jul 2015 11:15:27 +0300
Message-ID: <1436429727-6527-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

Reset XPS's sender_cpu on forwarding.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 6 ++++++
 1 file changed, 6 insertions(+)

 I see similar patches for other forwarding places...
that is the reason for this patch.

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 34dc142..258a0b0 100644
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
1.9.3

