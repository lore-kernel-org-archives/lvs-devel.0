From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 05/84] ipvs: Store ipvs not net in struct ip_vs_conn_param
Date: Thu, 24 Sep 2015 09:51:50 +0900
Message-ID: <1443055989-1306-6-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "Eric W. Biederman" <ebiederm@xmission.com>, Simon Horman <horms@verge.net.au>

From: "Eric W. Biederman" <ebiederm@xmission.com>

In practice struct netns_ipvs is as meaningful as struct net and more
useful as it holds the ipvs specific data.  So store a pointer to
struct netns_ipvs.

Update the accesses of param->net to access param->ipvs->net instead.

When lookup up struct ip_vs_conn in a hash table replace comparisons
of cp->net with comparisons of cp->ipvs which is possible
now that ipvs is present in ip_vs_conn_param.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             |  4 ++--
 net/netfilter/ipvs/ip_vs_conn.c | 14 +++++++-------
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 3bf6da8fdaf1..8cca99bbe15b 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -545,7 +545,7 @@ struct ip_vs_proto_data *ip_vs_proto_data_get(struct net *net,
 					      unsigned short proto);
 
 struct ip_vs_conn_param {
-	struct net			*net;
+	struct netns_ipvs		*ipvs;
 	const union nf_inet_addr	*caddr;
 	const union nf_inet_addr	*vaddr;
 	__be16				cport;
@@ -1208,7 +1208,7 @@ static inline void ip_vs_conn_fill_param(struct net *net, int af, int protocol,
 					 __be16 vport,
 					 struct ip_vs_conn_param *p)
 {
-	p->net = net;
+	p->ipvs = net_ipvs(net);
 	p->af = af;
 	p->protocol = protocol;
 	p->caddr = caddr;
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index dd8e5a12d545..72c47ee2f9f5 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -141,7 +141,7 @@ static unsigned int ip_vs_conn_hashkey_param(const struct ip_vs_conn_param *p,
 		port = p->vport;
 	}
 
-	return ip_vs_conn_hashkey(p->net, p->af, p->protocol, addr, port);
+	return ip_vs_conn_hashkey(p->ipvs->net, p->af, p->protocol, addr, port);
 }
 
 static unsigned int ip_vs_conn_hashkey_conn(const struct ip_vs_conn *cp)
@@ -279,7 +279,7 @@ __ip_vs_conn_in_get(const struct ip_vs_conn_param *p)
 		    ip_vs_addr_equal(p->af, p->vaddr, &cp->vaddr) &&
 		    ((!p->cport) ^ (!(cp->flags & IP_VS_CONN_F_NO_CPORT))) &&
 		    p->protocol == cp->protocol &&
-		    net_eq(cp->ipvs->net, p->net)) {
+		    cp->ipvs == p->ipvs) {
 			if (!__ip_vs_conn_get(cp))
 				continue;
 			/* HIT */
@@ -359,7 +359,7 @@ struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p)
 
 	hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
 		if (unlikely(p->pe_data && p->pe->ct_match)) {
-			if (!net_eq(cp->ipvs->net, p->net))
+			if (cp->ipvs != p->ipvs)
 				continue;
 			if (p->pe == cp->pe && p->pe->ct_match(p, cp)) {
 				if (__ip_vs_conn_get(cp))
@@ -377,7 +377,7 @@ struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p)
 		    p->vport == cp->vport && p->cport == cp->cport &&
 		    cp->flags & IP_VS_CONN_F_TEMPLATE &&
 		    p->protocol == cp->protocol &&
-		    net_eq(cp->ipvs->net, p->net)) {
+		    cp->ipvs == p->ipvs) {
 			if (__ip_vs_conn_get(cp))
 				goto out;
 		}
@@ -418,7 +418,7 @@ struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
 		    ip_vs_addr_equal(p->af, p->vaddr, &cp->caddr) &&
 		    ip_vs_addr_equal(p->af, p->caddr, &cp->daddr) &&
 		    p->protocol == cp->protocol &&
-		    net_eq(cp->ipvs->net, p->net)) {
+		    cp->ipvs == p->ipvs) {
 			if (!__ip_vs_conn_get(cp))
 				continue;
 			/* HIT */
@@ -875,8 +875,8 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p, int dest_af,
 	       struct ip_vs_dest *dest, __u32 fwmark)
 {
 	struct ip_vs_conn *cp;
-	struct netns_ipvs *ipvs = net_ipvs(p->net);
-	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(p->net,
+	struct netns_ipvs *ipvs = p->ipvs;
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(p->ipvs->net,
 							   p->protocol);
 
 	cp = kmem_cache_alloc(ip_vs_conn_cachep, GFP_ATOMIC);
-- 
2.1.4

