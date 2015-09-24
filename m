From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 61/84] ipvs: Pass ipvs into .conn_in_get and ip_vs_conn_in_get_proto
Date: Thu, 24 Sep 2015 09:52:46 +0900
Message-ID: <1443055989-1306-62-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "Eric W. Biederman" <ebiederm@xmission.com>, Simon Horman <horms@verge.net.au>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Stop relying on "net_ipvs(skb_net(skb))" to derive the ipvs as
skb_net is a hack.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h                     | 6 ++++--
 net/netfilter/ipvs/ip_vs_conn.c         | 4 ++--
 net/netfilter/ipvs/ip_vs_core.c         | 8 ++++----
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c | 3 +--
 4 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index fe3373c9bb3b..5c26383542e3 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -493,7 +493,8 @@ struct ip_vs_protocol {
 			     struct ip_vs_iphdr *iph);
 
 	struct ip_vs_conn *
-	(*conn_in_get)(int af,
+	(*conn_in_get)(struct netns_ipvs *ipvs,
+		       int af,
 		       const struct sk_buff *skb,
 		       const struct ip_vs_iphdr *iph);
 
@@ -1222,7 +1223,8 @@ static inline void ip_vs_conn_fill_param(struct netns_ipvs *ipvs, int af, int pr
 struct ip_vs_conn *ip_vs_conn_in_get(const struct ip_vs_conn_param *p);
 struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p);
 
-struct ip_vs_conn * ip_vs_conn_in_get_proto(int af, const struct sk_buff *skb,
+struct ip_vs_conn * ip_vs_conn_in_get_proto(struct netns_ipvs *ipvs, int af,
+					    const struct sk_buff *skb,
 					    const struct ip_vs_iphdr *iph);
 
 struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p);
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 6754e3595a72..439d6fb8bc29 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -335,10 +335,10 @@ ip_vs_conn_fill_param_proto(struct netns_ipvs *ipvs,
 }
 
 struct ip_vs_conn *
-ip_vs_conn_in_get_proto(int af, const struct sk_buff *skb,
+ip_vs_conn_in_get_proto(struct netns_ipvs *ipvs, int af,
+			const struct sk_buff *skb,
 			const struct ip_vs_iphdr *iph)
 {
-	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
 	struct ip_vs_conn_param p;
 
 	if (ip_vs_conn_fill_param_proto(ipvs, af, skb, iph, &p))
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 01398eb757fa..9b5c2af7b63a 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -469,7 +469,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	 */
 	if ((!skb->dev || skb->dev->flags & IFF_LOOPBACK)) {
 		iph->hdr_flags ^= IP_VS_HDR_INVERSE;
-		cp = pp->conn_in_get(svc->af, skb, iph);
+		cp = pp->conn_in_get(svc->ipvs, svc->af, skb, iph);
 		iph->hdr_flags ^= IP_VS_HDR_INVERSE;
 
 		if (cp) {
@@ -1490,7 +1490,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	/* The embedded headers contain source and dest in reverse order.
 	 * For IPIP this is error for request, not for reply.
 	 */
-	cp = pp->conn_in_get(AF_INET, skb, &ciph);
+	cp = pp->conn_in_get(ipvs, AF_INET, skb, &ciph);
 
 	if (!cp) {
 		int v;
@@ -1648,7 +1648,7 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 	/* The embedded headers contain source and dest in reverse order
 	 * if not from localhost
 	 */
-	cp = pp->conn_in_get(AF_INET6, skb, &ciph);
+	cp = pp->conn_in_get(ipvs, AF_INET6, skb, &ciph);
 
 	if (!cp) {
 		int v;
@@ -1780,7 +1780,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	/*
 	 * Check if the packet belongs to an existing connection entry
 	 */
-	cp = pp->conn_in_get(af, skb, &iph);
+	cp = pp->conn_in_get(ipvs, af, skb, &iph);
 
 	conn_reuse_mode = sysctl_conn_reuse_mode(ipvs);
 	if (conn_reuse_mode && !iph.fragoffs &&
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
index 406d9a433d92..a96d93d11807 100644
--- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
@@ -56,12 +56,11 @@ ah_esp_conn_fill_param_proto(struct netns_ipvs *ipvs, int af,
 }
 
 static struct ip_vs_conn *
-ah_esp_conn_in_get(int af, const struct sk_buff *skb,
+ah_esp_conn_in_get(struct netns_ipvs *ipvs, int af, const struct sk_buff *skb,
 		   const struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_conn *cp;
 	struct ip_vs_conn_param p;
-	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
 
 	ah_esp_conn_fill_param_proto(ipvs, af, iph, &p);
 	cp = ip_vs_conn_in_get(&p);
-- 
2.1.4
