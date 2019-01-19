From: Matteo Croce <mcroce@redhat.com>
Subject: [PATCH ipvs-next] ipvs: avoid indirect calls when calculating checksums
Date: Sat, 19 Jan 2019 15:22:38 +0100
Message-ID: <20190119142238.29319-1-mcroce@redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>
Cc: Wensong Zhang <wensong@linux-vs.org>

The function pointer ip_vs_protocol->csum_check is only used in protocol
specific code, and never in the generic one.
Remove the function pointer from struct ip_vs_protocol and call the
checksum functions directly.
This reduces the performance impact of the Spectre mitigation, and
should give a small improvement even with RETPOLINES disabled.

Signed-off-by: Matteo Croce <mcroce@redhat.com>
---
 include/net/ip_vs.h                     |  3 ---
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |  2 --
 net/netfilter/ipvs/ip_vs_proto_sctp.c   |  8 +++++---
 net/netfilter/ipvs/ip_vs_proto_tcp.c    | 12 +++++++-----
 net/netfilter/ipvs/ip_vs_proto_udp.c    | 12 +++++++-----
 5 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index a0d2e0bb9a94..047f9a5ccaad 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -453,9 +453,6 @@ struct ip_vs_protocol {
 	int (*dnat_handler)(struct sk_buff *skb, struct ip_vs_protocol *pp,
 			    struct ip_vs_conn *cp, struct ip_vs_iphdr *iph);
 
-	int (*csum_check)(int af, struct sk_buff *skb,
-			  struct ip_vs_protocol *pp);
-
 	const char *(*state_name)(int state);
 
 	void (*state_transition)(struct ip_vs_conn *cp, int direction,
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
index 5320d39976e1..480598cb0f05 100644
--- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
@@ -129,7 +129,6 @@ struct ip_vs_protocol ip_vs_protocol_ah = {
 	.conn_out_get =		ah_esp_conn_out_get,
 	.snat_handler =		NULL,
 	.dnat_handler =		NULL,
-	.csum_check =		NULL,
 	.state_transition =	NULL,
 	.register_app =		NULL,
 	.unregister_app =	NULL,
@@ -152,7 +151,6 @@ struct ip_vs_protocol ip_vs_protocol_esp = {
 	.conn_out_get =		ah_esp_conn_out_get,
 	.snat_handler =		NULL,
 	.dnat_handler =		NULL,
-	.csum_check =		NULL,
 	.state_transition =	NULL,
 	.register_app =		NULL,
 	.unregister_app =	NULL,
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index b0cd7d08f2a7..bc3d1625ecc8 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -9,6 +9,9 @@
 #include <net/sctp/checksum.h>
 #include <net/ip_vs.h>
 
+static int
+sctp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp);
+
 static int
 sctp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 		   struct ip_vs_proto_data *pd,
@@ -105,7 +108,7 @@ sctp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		int ret;
 
 		/* Some checks before mangling */
-		if (pp->csum_check && !pp->csum_check(cp->af, skb, pp))
+		if (!sctp_csum_check(cp->af, skb, pp))
 			return 0;
 
 		/* Call application helper if needed */
@@ -152,7 +155,7 @@ sctp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		int ret;
 
 		/* Some checks before mangling */
-		if (pp->csum_check && !pp->csum_check(cp->af, skb, pp))
+		if (!sctp_csum_check(cp->af, skb, pp))
 			return 0;
 
 		/* Call application helper if needed */
@@ -587,7 +590,6 @@ struct ip_vs_protocol ip_vs_protocol_sctp = {
 	.conn_out_get	= ip_vs_conn_out_get_proto,
 	.snat_handler	= sctp_snat_handler,
 	.dnat_handler	= sctp_dnat_handler,
-	.csum_check	= sctp_csum_check,
 	.state_name	= sctp_state_name,
 	.state_transition = sctp_state_transition,
 	.app_conn_bind	= sctp_app_conn_bind,
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 1770fc6ce960..6a275f989085 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -31,6 +31,9 @@
 
 #include <net/ip_vs.h>
 
+static int
+tcp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp);
+
 static int
 tcp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 		  struct ip_vs_proto_data *pd,
@@ -166,7 +169,7 @@ tcp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		int ret;
 
 		/* Some checks before mangling */
-		if (pp->csum_check && !pp->csum_check(cp->af, skb, pp))
+		if (!tcp_csum_check(cp->af, skb, pp))
 			return 0;
 
 		/* Call application helper if needed */
@@ -192,7 +195,7 @@ tcp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		tcp_fast_csum_update(cp->af, tcph, &cp->daddr, &cp->vaddr,
 				     cp->dport, cp->vport);
 		if (skb->ip_summed == CHECKSUM_COMPLETE)
-			skb->ip_summed = (cp->app && pp->csum_check) ?
+			skb->ip_summed = cp->app ?
 					 CHECKSUM_UNNECESSARY : CHECKSUM_NONE;
 	} else {
 		/* full checksum calculation */
@@ -244,7 +247,7 @@ tcp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		int ret;
 
 		/* Some checks before mangling */
-		if (pp->csum_check && !pp->csum_check(cp->af, skb, pp))
+		if (!tcp_csum_check(cp->af, skb, pp))
 			return 0;
 
 		/*
@@ -275,7 +278,7 @@ tcp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		tcp_fast_csum_update(cp->af, tcph, &cp->vaddr, &cp->daddr,
 				     cp->vport, cp->dport);
 		if (skb->ip_summed == CHECKSUM_COMPLETE)
-			skb->ip_summed = (cp->app && pp->csum_check) ?
+			skb->ip_summed = cp->app ?
 					 CHECKSUM_UNNECESSARY : CHECKSUM_NONE;
 	} else {
 		/* full checksum calculation */
@@ -736,7 +739,6 @@ struct ip_vs_protocol ip_vs_protocol_tcp = {
 	.conn_out_get =		ip_vs_conn_out_get_proto,
 	.snat_handler =		tcp_snat_handler,
 	.dnat_handler =		tcp_dnat_handler,
-	.csum_check =		tcp_csum_check,
 	.state_name =		tcp_state_name,
 	.state_transition =	tcp_state_transition,
 	.app_conn_bind =	tcp_app_conn_bind,
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 0f53c49025f8..3285718264d5 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -28,6 +28,9 @@
 #include <net/ip.h>
 #include <net/ip6_checksum.h>
 
+static int
+udp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp);
+
 static int
 udp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 		  struct ip_vs_proto_data *pd,
@@ -156,7 +159,7 @@ udp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		int ret;
 
 		/* Some checks before mangling */
-		if (pp->csum_check && !pp->csum_check(cp->af, skb, pp))
+		if (!udp_csum_check(cp->af, skb, pp))
 			return 0;
 
 		/*
@@ -186,7 +189,7 @@ udp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		udp_fast_csum_update(cp->af, udph, &cp->daddr, &cp->vaddr,
 				     cp->dport, cp->vport);
 		if (skb->ip_summed == CHECKSUM_COMPLETE)
-			skb->ip_summed = (cp->app && pp->csum_check) ?
+			skb->ip_summed = cp->app ?
 					 CHECKSUM_UNNECESSARY : CHECKSUM_NONE;
 	} else {
 		/* full checksum calculation */
@@ -239,7 +242,7 @@ udp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		int ret;
 
 		/* Some checks before mangling */
-		if (pp->csum_check && !pp->csum_check(cp->af, skb, pp))
+		if (!udp_csum_check(cp->af, skb, pp))
 			return 0;
 
 		/*
@@ -270,7 +273,7 @@ udp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		udp_fast_csum_update(cp->af, udph, &cp->vaddr, &cp->daddr,
 				     cp->vport, cp->dport);
 		if (skb->ip_summed == CHECKSUM_COMPLETE)
-			skb->ip_summed = (cp->app && pp->csum_check) ?
+			skb->ip_summed = cp->app ?
 					 CHECKSUM_UNNECESSARY : CHECKSUM_NONE;
 	} else {
 		/* full checksum calculation */
@@ -494,7 +497,6 @@ struct ip_vs_protocol ip_vs_protocol_udp = {
 	.conn_out_get =		ip_vs_conn_out_get_proto,
 	.snat_handler =		udp_snat_handler,
 	.dnat_handler =		udp_dnat_handler,
-	.csum_check =		udp_csum_check,
 	.state_transition =	udp_state_transition,
 	.state_name =		udp_state_name,
 	.register_app =		udp_register_app,
-- 
2.20.1

