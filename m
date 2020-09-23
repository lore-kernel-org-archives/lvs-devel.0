From: "longguang.yue" <bigclouds@163.com>
Subject: [PATCH] ipvs: adjust the debug order of src and dst
Date: Wed, 23 Sep 2020 13:49:59 +0800
Message-ID: <20200923055000.82748-1-bigclouds@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=163.com;
        s=s110527; h=From:Subject:Date:Message-Id:MIME-Version; bh=ldeUR
        Yewu2fM70h0EcU97t98Qm0u/6Ht4u3dUu5od6Y=; b=MLF42AACz3rkP1GNgHZK/
        srL2AkQcuHuQxZjKikGuEcoZjhrqQhtHdAxLmncCzw8tMv5QeDLh6njaM67t5S33
        XlAgSIraM/OdUnHgWYWIuXJ8U1bv3Foj6OKs/EvVwHfERJNT08p14bpOZo7xGQ3r
        l0wJ/C1vQtH5wRyDKQpW0I=
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: 
Cc: ylg <bigclouds@163.com>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

From: ylg <bigclouds@163.com>

adjust the debug order of src and dst when tcp state changes

Signed-off-by: ylg <bigclouds@163.com>
---
 net/netfilter/ipvs/ip_vs_proto_tcp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index dc2e7da2742a..6567eb45a234 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -548,10 +548,10 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 			      th->fin ? 'F' : '.',
 			      th->ack ? 'A' : '.',
 			      th->rst ? 'R' : '.',
-			      IP_VS_DBG_ADDR(cp->daf, &cp->daddr),
-			      ntohs(cp->dport),
 			      IP_VS_DBG_ADDR(cp->af, &cp->caddr),
 			      ntohs(cp->cport),
+			      IP_VS_DBG_ADDR(cp->daf, &cp->daddr),
+			      ntohs(cp->dport),
 			      tcp_state_name(cp->state),
 			      tcp_state_name(new_state),
 			      refcount_read(&cp->refcnt));
-- 
2.20.1 (Apple Git-117)

