From: "longguang.yue" <bigclouds@163.com>
Subject: [PATCH v4] ipvs: adjust the debug info in function set_tcp_state
Date: Sun, 27 Sep 2020 20:07:56 +0800
Message-ID: <20200927120756.75676-1-bigclouds@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=163.com;
        s=s110527; h=From:Subject:Date:Message-Id:MIME-Version; bh=v9Duc
        /2Q8SO2UadA0hRP5VIDU0Yovle4kISsZXu8EyM=; b=Vo09yjMlYeJZZLdpiTBNH
        vSFSlFaSF4eCzBL/o1dj+Ry0agVzvnHG3h4O/zkp3xg9308KsbXnmVqu9VhU6/yd
        mG8Ub/WEAYTOFH/HmCEmo8ETZsO0hS1Kgaihs7vG1QfJfpA5+KpwskzGUv175qAa
        bSWXjTFLQ8gfrq0c4inrrI=
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: 
Cc: yuelongguang@gmail.com, "longguang.yue" <bigclouds@163.com>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, "open list:IPVS" <netdev@vger.kernel.org>, "open list:IPVS" <lvs-devel@vger.kernel.org>, "open list:NETFILTER" <netfilter-devel@vger.kernel.org>, "open list:NETFILTER" <coreteam@netfilter.org>, open list <linux-kernel@vger.kernel.org>

        outputting client,virtual,dst addresses info when tcp state changes,
        which makes the connection debug more clear

Signed-off-by: longguang.yue <bigclouds@163.com>
---
 net/netfilter/ipvs/ip_vs_proto_tcp.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index dc2e7da2742a..7da51390cea6 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -539,8 +539,8 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 	if (new_state != cp->state) {
 		struct ip_vs_dest *dest = cp->dest;
 
-		IP_VS_DBG_BUF(8, "%s %s [%c%c%c%c] %s:%d->"
-			      "%s:%d state: %s->%s conn->refcnt:%d\n",
+		IP_VS_DBG_BUF(8, "%s %s [%c%c%c%c] c:%s:%d v:%s:%d "
+			      "d:%s:%d state: %s->%s conn->refcnt:%d\n",
 			      pd->pp->name,
 			      ((state_off == TCP_DIR_OUTPUT) ?
 			       "output " : "input "),
@@ -548,10 +548,12 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 			      th->fin ? 'F' : '.',
 			      th->ack ? 'A' : '.',
 			      th->rst ? 'R' : '.',
-			      IP_VS_DBG_ADDR(cp->daf, &cp->daddr),
-			      ntohs(cp->dport),
 			      IP_VS_DBG_ADDR(cp->af, &cp->caddr),
 			      ntohs(cp->cport),
+			      IP_VS_DBG_ADDR(cp->af, &cp->vaddr),
+			      ntohs(cp->vport),
+			      IP_VS_DBG_ADDR(cp->daf, &cp->daddr),
+			      ntohs(cp->dport),
 			      tcp_state_name(cp->state),
 			      tcp_state_name(new_state),
 			      refcount_read(&cp->refcnt));
-- 
2.20.1 (Apple Git-117)

