From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH v8 net-next] ipvs: inspect reply packets from DR/TUN real servers
Date: Mon,  5 Oct 2020 23:13:47 +0300
Message-ID: <20201005201347.13644-1-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, netfilter-devel@vger.kernel.org, "longguang.yue" <bigclouds@163.com>, yuelongguang@gmail.com

From: longguang.yue <bigclouds@163.com>

Just like for MASQ, inspect the reply packets coming from DR/TUN
real servers and alter the connection's state and timeout
according to the protocol.

It's ipvs's duty to do traffic statistic if packets get hit,
no matter what mode it is.

Signed-off-by: longguang.yue <bigclouds@163.com>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

Simon, Pablo, please review and apply!

Before v6 this patch was named
"ipvs: Add traffic statistic up even it is VS/DR or VS/TUN mode"

Changes:
v1: support DR/TUN mode statistic
v2: ip_vs_conn_out_get handles DR/TUN mode's conn
v3: fix checkpatch
v4, v5: restructure and optimise this feature
v6: rewrite subject and patch description
v7: adjust changelogs and order of some local vars
v8: fix patch format

 net/netfilter/ipvs/ip_vs_conn.c | 18 +++++++++++++++---
 net/netfilter/ipvs/ip_vs_core.c | 19 +++++++------------
 2 files changed, 22 insertions(+), 15 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index a90b8eac16ac..c100c6b112c8 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -402,6 +402,8 @@ struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
 {
 	unsigned int hash;
 	struct ip_vs_conn *cp, *ret=NULL;
+	const union nf_inet_addr *saddr;
+	__be16 sport;
 
 	/*
 	 *	Check for "full" addressed entries
@@ -411,10 +413,20 @@ struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
 	rcu_read_lock();
 
 	hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
-		if (p->vport == cp->cport && p->cport == cp->dport &&
-		    cp->af == p->af &&
+		if (p->vport != cp->cport)
+			continue;
+
+		if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ) {
+			sport = cp->vport;
+			saddr = &cp->vaddr;
+		} else {
+			sport = cp->dport;
+			saddr = &cp->daddr;
+		}
+
+		if (p->cport == sport && cp->af == p->af &&
 		    ip_vs_addr_equal(p->af, p->vaddr, &cp->caddr) &&
-		    ip_vs_addr_equal(p->af, p->caddr, &cp->daddr) &&
+		    ip_vs_addr_equal(p->af, p->caddr, saddr) &&
 		    p->protocol == cp->protocol &&
 		    cp->ipvs == p->ipvs) {
 			if (!__ip_vs_conn_get(cp))
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index e3668a6e54e4..cc3c275934f4 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -875,7 +875,7 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
 	unsigned int verdict = NF_DROP;
 
 	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
-		goto ignore_cp;
+		goto after_nat;
 
 	/* Ensure the checksum is correct */
 	if (!skb_csum_unnecessary(skb) && ip_vs_checksum_complete(skb, ihl)) {
@@ -901,6 +901,7 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
 	if (ip_vs_route_me_harder(cp->ipvs, af, skb, hooknum))
 		goto out;
 
+after_nat:
 	/* do the statistics and put it back */
 	ip_vs_out_stats(cp, skb);
 
@@ -909,8 +910,6 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
 		ip_vs_notrack(skb);
 	else
 		ip_vs_update_conntrack(skb, cp, 0);
-
-ignore_cp:
 	verdict = NF_ACCEPT;
 
 out:
@@ -1276,6 +1275,9 @@ handle_response(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 {
 	struct ip_vs_protocol *pp = pd->pp;
 
+	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
+		goto after_nat;
+
 	IP_VS_DBG_PKT(11, af, pp, skb, iph->off, "Outgoing packet");
 
 	if (skb_ensure_writable(skb, iph->len))
@@ -1316,6 +1318,7 @@ handle_response(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 
 	IP_VS_DBG_PKT(10, af, pp, skb, iph->off, "After SNAT");
 
+after_nat:
 	ip_vs_out_stats(cp, skb);
 	ip_vs_set_state(cp, IP_VS_DIR_OUTPUT, skb, pd);
 	skb->ipvs_property = 1;
@@ -1412,11 +1415,8 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
 	cp = INDIRECT_CALL_1(pp->conn_out_get, ip_vs_conn_out_get_proto,
 			     ipvs, af, skb, &iph);
 
-	if (likely(cp)) {
-		if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
-			goto ignore_cp;
+	if (likely(cp))
 		return handle_response(af, skb, pd, cp, &iph, hooknum);
-	}
 
 	/* Check for real-server-started requests */
 	if (atomic_read(&ipvs->conn_out_counter)) {
@@ -1475,14 +1475,9 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
 		}
 	}
 
-out:
 	IP_VS_DBG_PKT(12, af, pp, skb, iph.off,
 		      "ip_vs_out: packet continues traversal as normal");
 	return NF_ACCEPT;
-
-ignore_cp:
-	__ip_vs_conn_put(cp);
-	goto out;
 }
 
 /*
-- 
2.26.2


