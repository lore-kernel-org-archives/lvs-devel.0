From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 62/84] ipvs: Pass ipvs into conn_out_get
Date: Mon, 21 Sep 2015 13:02:39 -0500
Message-ID: <1442858581-15869-62-git-send-email-ebiederm@xmission.com>
References: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>

Move the hack of relying on "net_ipvs(skb_net(skb))" to derive the
ipvs up a layer.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/ip_vs.h                     | 6 ++++--
 net/netfilter/ipvs/ip_vs_conn.c         | 4 ++--
 net/netfilter/ipvs/ip_vs_core.c         | 8 +++++---
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c | 3 +--
 net/netfilter/xt_ipvs.c                 | 3 ++-
 5 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 5c26383542e3..0ca436ef7dad 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -499,7 +499,8 @@ struct ip_vs_protocol {
 		       const struct ip_vs_iphdr *iph);
 
 	struct ip_vs_conn *
-	(*conn_out_get)(int af,
+	(*conn_out_get)(struct netns_ipvs *ipvs,
+			int af,
 			const struct sk_buff *skb,
 			const struct ip_vs_iphdr *iph);
 
@@ -1229,7 +1230,8 @@ struct ip_vs_conn * ip_vs_conn_in_get_proto(struct netns_ipvs *ipvs, int af,
 
 struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p);
 
-struct ip_vs_conn * ip_vs_conn_out_get_proto(int af, const struct sk_buff *skb,
+struct ip_vs_conn * ip_vs_conn_out_get_proto(struct netns_ipvs *ipvs, int af,
+					     const struct sk_buff *skb,
 					     const struct ip_vs_iphdr *iph);
 
 /* Get reference to gain full access to conn.
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 439d6fb8bc29..7a4d1d8e8f0c 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -440,10 +440,10 @@ struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
 }
 
 struct ip_vs_conn *
-ip_vs_conn_out_get_proto(int af, const struct sk_buff *skb,
+ip_vs_conn_out_get_proto(struct netns_ipvs *ipvs, int af,
+			 const struct sk_buff *skb,
 			 const struct ip_vs_iphdr *iph)
 {
-	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
 	struct ip_vs_conn_param p;
 
 	if (ip_vs_conn_fill_param_proto(ipvs, af, skb, iph, &p))
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 9b5c2af7b63a..f0369e7602a0 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -912,6 +912,7 @@ out:
 static int ip_vs_out_icmp(struct sk_buff *skb, int *related,
 			  unsigned int hooknum)
 {
+	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
 	struct iphdr *iph;
 	struct icmphdr	_icmph, *ic;
 	struct iphdr	_ciph, *cih;	/* The ip header contained within the ICMP */
@@ -974,7 +975,7 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related,
 	ip_vs_fill_iph_skb_icmp(AF_INET, skb, offset, true, &ciph);
 
 	/* The embedded headers contain source and dest in reverse order */
-	cp = pp->conn_out_get(AF_INET, skb, &ciph);
+	cp = pp->conn_out_get(ipvs, AF_INET, skb, &ciph);
 	if (!cp)
 		return NF_ACCEPT;
 
@@ -987,6 +988,7 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related,
 static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
 			     unsigned int hooknum, struct ip_vs_iphdr *ipvsh)
 {
+	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
 	struct icmp6hdr	_icmph, *ic;
 	struct ip_vs_iphdr ciph = {.flags = 0, .fragoffs = 0};/*Contained IP */
 	struct ip_vs_conn *cp;
@@ -1029,7 +1031,7 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
 		return NF_ACCEPT;
 
 	/* The embedded headers contain source and dest in reverse order */
-	cp = pp->conn_out_get(AF_INET6, skb, &ciph);
+	cp = pp->conn_out_get(ipvs, AF_INET6, skb, &ciph);
 	if (!cp)
 		return NF_ACCEPT;
 
@@ -1257,7 +1259,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 	/*
 	 * Check if the packet belongs to an existing entry
 	 */
-	cp = pp->conn_out_get(af, skb, &iph);
+	cp = pp->conn_out_get(ipvs, af, skb, &iph);
 
 	if (likely(cp))
 		return handle_response(af, skb, pd, cp, &iph, hooknum);
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
index a96d93d11807..e924455de5c0 100644
--- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
@@ -82,12 +82,11 @@ ah_esp_conn_in_get(struct netns_ipvs *ipvs, int af, const struct sk_buff *skb,
 
 
 static struct ip_vs_conn *
-ah_esp_conn_out_get(int af, const struct sk_buff *skb,
+ah_esp_conn_out_get(struct netns_ipvs *ipvs, int af, const struct sk_buff *skb,
 		    const struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_conn *cp;
 	struct ip_vs_conn_param p;
-	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
 
 	ah_esp_conn_fill_param_proto(ipvs, af, iph, &p);
 	cp = ip_vs_conn_out_get(&p);
diff --git a/net/netfilter/xt_ipvs.c b/net/netfilter/xt_ipvs.c
index 452ba2a3e7ae..71a9d95e0a81 100644
--- a/net/netfilter/xt_ipvs.c
+++ b/net/netfilter/xt_ipvs.c
@@ -48,6 +48,7 @@ static bool
 ipvs_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_ipvs_mtinfo *data = par->matchinfo;
+	struct netns_ipvs *ipvs = net_ipvs(par->net);
 	/* ipvs_mt_check ensures that family is only NFPROTO_IPV[46]. */
 	const u_int8_t family = par->family;
 	struct ip_vs_iphdr iph;
@@ -85,7 +86,7 @@ ipvs_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	/*
 	 * Check if the packet belongs to an existing entry
 	 */
-	cp = pp->conn_out_get(family, skb, &iph);
+	cp = pp->conn_out_get(ipvs, family, skb, &iph);
 	if (unlikely(cp == NULL)) {
 		match = false;
 		goto out;
-- 
2.2.1
