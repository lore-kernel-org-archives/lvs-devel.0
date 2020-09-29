From: "longguang.yue" <bigclouds@163.com>
Subject: [PATCH v2] ipvs: Add traffic statistic up even it is VS/DR or VS/TUN mode
Date: Tue, 29 Sep 2020 16:18:11 +0800
Message-ID: <20200929081811.32302-1-bigclouds@163.com>
References: <20200929050302.28105-1-bigclouds@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=163.com;
        s=s110527; h=From:Subject:Date:Message-Id:MIME-Version; bh=uJw7P
        bcKiwi2XDoJgHU84ZZoA4o7HeGvmqfG+5az7NQ=; b=Rch5DBd1wq3OPbV+pGi1J
        sTNEnhW6f4f3z88dTUN4HcS+OjL71Ve71ISYm5tp52UHtD9jJtnCGO+SJuwrbx56
        WnvMT6MVq22LY35zeR9xoTuf40qN3efev4SbKNilGO99Ydd8LQ/HMXpzBYq3DPC0
        4dOCS6Cd1tYcEilUgDDfEw=
In-Reply-To: <20200929050302.28105-1-bigclouds@163.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: 
Cc: yuelongguang@gmail.com, "longguang.yue" <bigclouds@163.com>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, "open list:IPVS" <netdev@vger.kernel.org>, "open list:IPVS" <lvs-devel@vger.kernel.org>, "open list:NETFILTER" <netfilter-devel@vger.kernel.org>, "open list:NETFILTER" <coreteam@netfilter.org>, open list <linux-kernel@vger.kernel.org>

It's ipvs's duty to do traffic statistic if packets get hit,
no matter what mode it is.

Signed-off-by: longguang.yue <bigclouds@163.com>
---
 net/netfilter/ipvs/ip_vs_conn.c | 13 +++++++++++--
 net/netfilter/ipvs/ip_vs_core.c |  5 ++++-
 2 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index a90b8eac16ac..2620c585d0c0 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -401,6 +401,8 @@ struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p)
 struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
 {
 	unsigned int hash;
+	__be16 cport;
+	const union nf_inet_addr *caddr;
 	struct ip_vs_conn *cp, *ret=NULL;
 
 	/*
@@ -411,10 +413,17 @@ struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
 	rcu_read_lock();
 
 	hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
-		if (p->vport == cp->cport && p->cport == cp->dport &&
+		if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ){
+			cport = cp->vport;
+			caddr = &cp->vaddr;
+		} else {
+			cport = cp->dport;
+			caddr = &cp->daddr;
+		}
+		if (p->vport == cp->cport && p->cport == cport &&
 		    cp->af == p->af &&
 		    ip_vs_addr_equal(p->af, p->vaddr, &cp->caddr) &&
-		    ip_vs_addr_equal(p->af, p->caddr, &cp->daddr) &&
+		    ip_vs_addr_equal(p->af, p->caddr, caddr) &&
 		    p->protocol == cp->protocol &&
 		    cp->ipvs == p->ipvs) {
 			if (!__ip_vs_conn_get(cp))
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

