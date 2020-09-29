From: "longguang.yue" <bigclouds@163.com>
Subject: [PATCH] ipvs: Add traffic statistic up even it is VS/DR or VS/TUN mode
Date: Tue, 29 Sep 2020 13:03:02 +0800
Message-ID: <20200929050302.28105-1-bigclouds@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=163.com;
        s=s110527; h=From:Subject:Date:Message-Id:MIME-Version; bh=6uKgF
        uXFSap/EdUsAgj497IozAnPWYkZEiXqqo30dV4=; b=TDuUmUecsCWlsrrmVse8P
        PNPgB0PgbMi63CXLyukIN/JcSXL02GseHhw0sIeKlqkeIX4yVgAd8jEl1cyXglHu
        7IFpeIkM0iUMOUqoSg08Oq52phT47DWZ7avEKsqV/VMH0pCjt2MZFQ57u2bqvkT4
        v2nGnMN7Sl8e1kHqAFs5KA=
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: 
Cc: yuelongguang@gmail.com, "longguang.yue" <bigclouds@163.com>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, "open list:IPVS" <netdev@vger.kernel.org>, "open list:IPVS" <lvs-devel@vger.kernel.org>, "open list:NETFILTER" <netfilter-devel@vger.kernel.org>, "open list:NETFILTER" <coreteam@netfilter.org>, open list <linux-kernel@vger.kernel.org>

It's ipvs's duty to do traffic statistic if packets get hit,
no matter what mode it is.

Signed-off-by: longguang.yue <bigclouds@163.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index e3668a6e54e4..ed523057f07f 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1413,8 +1413,11 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
 			     ipvs, af, skb, &iph);
 
 	if (likely(cp)) {
-		if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
+		if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ){
+			ip_vs_out_stats(cp, skb);
+			skb->ipvs_property = 1;
 			goto ignore_cp;
+		}
 		return handle_response(af, skb, pd, cp, &iph, hooknum);
 	}
 
-- 
2.20.1 (Apple Git-117)

