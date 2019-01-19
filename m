From: Matteo Croce <mcroce@redhat.com>
Subject: [PATCH ipvs-next] ipvs: use indirect call wrappers
Date: Sat, 19 Jan 2019 15:25:35 +0100
Message-ID: <20190119142535.29572-1-mcroce@redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Paolo Abeni <pabeni@redhat.com>

Use the new indirect call wrappers in IPVS when calling the TCP or UDP
protocol specific functions.
This avoids an indirect calls in IPVS, and reduces the performance
impact of the Spectre mitigation.

Signed-off-by: Matteo Croce <mcroce@redhat.com>
---
 net/netfilter/ipvs/ip_vs_core.c      | 49 +++++++++++++++++++++++-----
 net/netfilter/ipvs/ip_vs_proto_tcp.c |  3 +-
 net/netfilter/ipvs/ip_vs_proto_udp.c |  3 +-
 3 files changed, 45 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index fe9abf3cc10a..e969dad66991 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -53,6 +53,7 @@
 #endif
 
 #include <net/ip_vs.h>
+#include <linux/indirect_call_wrapper.h>
 
 
 EXPORT_SYMBOL(register_ip_vs_scheduler);
@@ -70,6 +71,29 @@ EXPORT_SYMBOL(ip_vs_get_debug_level);
 #endif
 EXPORT_SYMBOL(ip_vs_new_conn_out);
 
+#ifdef CONFIG_IP_VS_PROTO_TCP
+INDIRECT_CALLABLE_DECLARE(int
+	tcp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
+			 struct ip_vs_conn *cp, struct ip_vs_iphdr *iph));
+#endif
+
+#ifdef CONFIG_IP_VS_PROTO_UDP
+INDIRECT_CALLABLE_DECLARE(int
+	udp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
+			 struct ip_vs_conn *cp, struct ip_vs_iphdr *iph));
+#endif
+
+#if defined(CONFIG_IP_VS_PROTO_TCP) && defined(CONFIG_IP_VS_PROTO_UDP)
+#define SNAT_CALL(f, ...) \
+	INDIRECT_CALL_2(f, tcp_snat_handler, udp_snat_handler, __VA_ARGS__)
+#elif defined(CONFIG_IP_VS_PROTO_TCP)
+#define SNAT_CALL(f, ...) INDIRECT_CALL_1(f, tcp_snat_handler, __VA_ARGS__)
+#elif defined(CONFIG_IP_VS_PROTO_UDP)
+#define SNAT_CALL(f, ...) INDIRECT_CALL_1(f, udp_snat_handler, __VA_ARGS__)
+#else
+#define SNAT_CALL(f, ...) f(__VA_ARGS__)
+#endif
+
 static unsigned int ip_vs_net_id __read_mostly;
 /* netns cnt used for uniqueness */
 static atomic_t ipvs_netns_cnt = ATOMIC_INIT(0);
@@ -478,7 +502,9 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	 */
 	if ((!skb->dev || skb->dev->flags & IFF_LOOPBACK)) {
 		iph->hdr_flags ^= IP_VS_HDR_INVERSE;
-		cp = pp->conn_in_get(svc->ipvs, svc->af, skb, iph);
+		cp = INDIRECT_CALL_1(pp->conn_in_get,
+				     ip_vs_conn_in_get_proto, svc->ipvs,
+				     svc->af, skb, iph);
 		iph->hdr_flags ^= IP_VS_HDR_INVERSE;
 
 		if (cp) {
@@ -972,7 +998,8 @@ static int ip_vs_out_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb,
 	ip_vs_fill_iph_skb_icmp(AF_INET, skb, offset, true, &ciph);
 
 	/* The embedded headers contain source and dest in reverse order */
-	cp = pp->conn_out_get(ipvs, AF_INET, skb, &ciph);
+	cp = INDIRECT_CALL_1(pp->conn_out_get, ip_vs_conn_out_get_proto,
+			     ipvs, AF_INET, skb, &ciph);
 	if (!cp)
 		return NF_ACCEPT;
 
@@ -1028,7 +1055,8 @@ static int ip_vs_out_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
 		return NF_ACCEPT;
 
 	/* The embedded headers contain source and dest in reverse order */
-	cp = pp->conn_out_get(ipvs, AF_INET6, skb, &ciph);
+	cp = INDIRECT_CALL_1(pp->conn_out_get, ip_vs_conn_out_get_proto,
+			     ipvs, AF_INET6, skb, &ciph);
 	if (!cp)
 		return NF_ACCEPT;
 
@@ -1263,7 +1291,8 @@ handle_response(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		goto drop;
 
 	/* mangle the packet */
-	if (pp->snat_handler && !pp->snat_handler(skb, pp, cp, iph))
+	if (pp->snat_handler &&
+	    !SNAT_CALL(pp->snat_handler, skb, pp, cp, iph))
 		goto drop;
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -1389,7 +1418,8 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
 	/*
 	 * Check if the packet belongs to an existing entry
 	 */
-	cp = pp->conn_out_get(ipvs, af, skb, &iph);
+	cp = INDIRECT_CALL_1(pp->conn_out_get, ip_vs_conn_out_get_proto,
+			     ipvs, af, skb, &iph);
 
 	if (likely(cp)) {
 		if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
@@ -1644,7 +1674,8 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 	/* The embedded headers contain source and dest in reverse order.
 	 * For IPIP this is error for request, not for reply.
 	 */
-	cp = pp->conn_in_get(ipvs, AF_INET, skb, &ciph);
+	cp = INDIRECT_CALL_1(pp->conn_in_get, ip_vs_conn_in_get_proto,
+			     ipvs, AF_INET, skb, &ciph);
 
 	if (!cp) {
 		int v;
@@ -1796,7 +1827,8 @@ static int ip_vs_in_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
 	/* The embedded headers contain source and dest in reverse order
 	 * if not from localhost
 	 */
-	cp = pp->conn_in_get(ipvs, AF_INET6, skb, &ciph);
+	cp = INDIRECT_CALL_1(pp->conn_in_get, ip_vs_conn_in_get_proto,
+			     ipvs, AF_INET6, skb, &ciph);
 
 	if (!cp) {
 		int v;
@@ -1925,7 +1957,8 @@ ip_vs_in(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int
 	/*
 	 * Check if the packet belongs to an existing connection entry
 	 */
-	cp = pp->conn_in_get(ipvs, af, skb, &iph);
+	cp = INDIRECT_CALL_1(pp->conn_in_get, ip_vs_conn_in_get_proto,
+			     ipvs, af, skb, &iph);
 
 	conn_reuse_mode = sysctl_conn_reuse_mode(ipvs);
 	if (conn_reuse_mode && !iph.fragoffs && is_new_conn(skb, &iph) && cp) {
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 6a275f989085..479419759983 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -28,6 +28,7 @@
 #include <net/ip6_checksum.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
+#include <linux/indirect_call_wrapper.h>
 
 #include <net/ip_vs.h>
 
@@ -146,7 +147,7 @@ tcp_partial_csum_update(int af, struct tcphdr *tcph,
 }
 
 
-static int
+INDIRECT_CALLABLE_SCOPE int
 tcp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		 struct ip_vs_conn *cp, struct ip_vs_iphdr *iph)
 {
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 3285718264d5..646c384910fb 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -23,6 +23,7 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/udp.h>
+#include <linux/indirect_call_wrapper.h>
 
 #include <net/ip_vs.h>
 #include <net/ip.h>
@@ -136,7 +137,7 @@ udp_partial_csum_update(int af, struct udphdr *uhdr,
 }
 
 
-static int
+INDIRECT_CALLABLE_SCOPE int
 udp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		 struct ip_vs_conn *cp, struct ip_vs_iphdr *iph)
 {
-- 
2.20.1

