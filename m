From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 60/84] ipvs: Pass ipvs into ip_vs_conn_fill_param_proto
Date: Mon, 21 Sep 2015 13:02:37 -0500
Message-ID: <1442858581-15869-60-git-send-email-ebiederm@xmission.com>
References: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>

Move the ugly hack net_ipvs(skb_net(skb)) up a layer in the call stack
so it is easier to remove.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_conn.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index bbe9e69e3eeb..6754e3595a72 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -314,12 +314,12 @@ struct ip_vs_conn *ip_vs_conn_in_get(const struct ip_vs_conn_param *p)
 }
 
 static int
-ip_vs_conn_fill_param_proto(int af, const struct sk_buff *skb,
+ip_vs_conn_fill_param_proto(struct netns_ipvs *ipvs,
+			    int af, const struct sk_buff *skb,
 			    const struct ip_vs_iphdr *iph,
 			    struct ip_vs_conn_param *p)
 {
 	__be16 _ports[2], *pptr;
-	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
 
 	pptr = frag_safe_skb_hp(skb, iph->len, sizeof(_ports), _ports, iph);
 	if (pptr == NULL)
@@ -338,9 +338,10 @@ struct ip_vs_conn *
 ip_vs_conn_in_get_proto(int af, const struct sk_buff *skb,
 			const struct ip_vs_iphdr *iph)
 {
+	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
 	struct ip_vs_conn_param p;
 
-	if (ip_vs_conn_fill_param_proto(af, skb, iph, &p))
+	if (ip_vs_conn_fill_param_proto(ipvs, af, skb, iph, &p))
 		return NULL;
 
 	return ip_vs_conn_in_get(&p);
@@ -442,9 +443,10 @@ struct ip_vs_conn *
 ip_vs_conn_out_get_proto(int af, const struct sk_buff *skb,
 			 const struct ip_vs_iphdr *iph)
 {
+	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
 	struct ip_vs_conn_param p;
 
-	if (ip_vs_conn_fill_param_proto(af, skb, iph, &p))
+	if (ip_vs_conn_fill_param_proto(ipvs, af, skb, iph, &p))
 		return NULL;
 
 	return ip_vs_conn_out_get(&p);
-- 
2.2.1

