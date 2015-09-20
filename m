From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 66/84] ipvs: Pass ipvs into .conn_schedule and ip_vs_try_to_schedule
Date: Sun, 20 Sep 2015 01:23:22 -0500
Message-ID: <1442730220-32458-66-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

This moves the hack "net_ipvs(skb_net(skb))" up one level where it
will be easier to remove.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/ip_vs.h                     |  3 ++-
 net/netfilter/ipvs/ip_vs_core.c         | 11 ++++++-----
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |  3 ++-
 net/netfilter/ipvs/ip_vs_proto_sctp.c   |  8 ++------
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |  8 ++------
 net/netfilter/ipvs/ip_vs_proto_udp.c    |  9 +++------
 6 files changed, 17 insertions(+), 25 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 5ad04be64895..c68c2c8ae48a 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -487,7 +487,8 @@ struct ip_vs_protocol {
 
 	void (*exit_netns)(struct netns_ipvs *ipvs, struct ip_vs_proto_data *pd);
 
-	int (*conn_schedule)(int af, struct sk_buff *skb,
+	int (*conn_schedule)(struct netns_ipvs *ipvs,
+			     int af, struct sk_buff *skb,
 			     struct ip_vs_proto_data *pd,
 			     int *verdict, struct ip_vs_conn **cpp,
 			     struct ip_vs_iphdr *iph);
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 9b37fe30dcac..514596b7a324 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1360,7 +1360,8 @@ ip_vs_local_reply6(void *priv, struct sk_buff *skb,
 #endif
 
 static unsigned int
-ip_vs_try_to_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
+ip_vs_try_to_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
+		      struct ip_vs_proto_data *pd,
 		      int *verdict, struct ip_vs_conn **cpp,
 		      struct ip_vs_iphdr *iph)
 {
@@ -1372,7 +1373,7 @@ ip_vs_try_to_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		 */
 
 		/* Schedule and create new connection entry into cpp */
-		if (!pp->conn_schedule(af, skb, pd, verdict, cpp, iph))
+		if (!pp->conn_schedule(ipvs, af, skb, pd, verdict, cpp, iph))
 			return 0;
 	}
 
@@ -1500,7 +1501,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 		if (!sysctl_schedule_icmp(ipvs))
 			return NF_ACCEPT;
 
-		if (!ip_vs_try_to_schedule(AF_INET, skb, pd, &v, &cp, &ciph))
+		if (!ip_vs_try_to_schedule(ipvs, AF_INET, skb, pd, &v, &cp, &ciph))
 			return v;
 		new_cp = true;
 	}
@@ -1658,7 +1659,7 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 		if (!sysctl_schedule_icmp(ipvs))
 			return NF_ACCEPT;
 
-		if (!ip_vs_try_to_schedule(AF_INET6, skb, pd, &v, &cp, &ciph))
+		if (!ip_vs_try_to_schedule(ipvs, AF_INET6, skb, pd, &v, &cp, &ciph))
 			return v;
 
 		new_cp = true;
@@ -1799,7 +1800,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (unlikely(!cp)) {
 		int v;
 
-		if (!ip_vs_try_to_schedule(af, skb, pd, &v, &cp, &iph))
+		if (!ip_vs_try_to_schedule(ipvs, af, skb, pd, &v, &cp, &iph))
 			return v;
 	}
 
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
index e924455de5c0..5320d39976e1 100644
--- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
@@ -104,7 +104,8 @@ ah_esp_conn_out_get(struct netns_ipvs *ipvs, int af, const struct sk_buff *skb,
 
 
 static int
-ah_esp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
+ah_esp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
+		     struct ip_vs_proto_data *pd,
 		     int *verdict, struct ip_vs_conn **cpp,
 		     struct ip_vs_iphdr *iph)
 {
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 3e9418ab276a..010ddeec135f 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -9,20 +9,16 @@
 #include <net/ip_vs.h>
 
 static int
-sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
+sctp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
+		   struct ip_vs_proto_data *pd,
 		   int *verdict, struct ip_vs_conn **cpp,
 		   struct ip_vs_iphdr *iph)
 {
-	struct net *net;
 	struct ip_vs_service *svc;
-	struct netns_ipvs *ipvs;
 	sctp_chunkhdr_t _schunkh, *sch;
 	sctp_sctphdr_t *sh, _sctph;
 	__be16 _ports[2], *ports = NULL;
 
-	net = skb_net(skb);
-	ipvs = net_ipvs(net);
-
 	if (likely(!ip_vs_iph_icmp(iph))) {
 		sh = skb_header_pointer(skb, iph->len, sizeof(_sctph), &_sctph);
 		if (sh) {
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 93ba6b1fe9d1..c913c2d00caf 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -32,19 +32,15 @@
 #include <net/ip_vs.h>
 
 static int
-tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
+tcp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
+		  struct ip_vs_proto_data *pd,
 		  int *verdict, struct ip_vs_conn **cpp,
 		  struct ip_vs_iphdr *iph)
 {
-	struct net *net;
 	struct ip_vs_service *svc;
 	struct tcphdr _tcph, *th;
-	struct netns_ipvs *ipvs;
 	__be16 _ports[2], *ports = NULL;
 
-	net = skb_net(skb);
-	ipvs = net_ipvs(net);
-
 	/* In the event of icmp, we're only guaranteed to have the first 8
 	 * bytes of the transport header, so we only check the rest of the
 	 * TCP packet for non-ICMP packets
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 382dcc9cfe11..e494e9a88c7f 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -29,12 +29,11 @@
 #include <net/ip6_checksum.h>
 
 static int
-udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
+udp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
+		  struct ip_vs_proto_data *pd,
 		  int *verdict, struct ip_vs_conn **cpp,
 		  struct ip_vs_iphdr *iph)
 {
-	struct net *net;
-	struct netns_ipvs *ipvs;
 	struct ip_vs_service *svc;
 	struct udphdr _udph, *uh;
 	__be16 _ports[2], *ports = NULL;
@@ -54,8 +53,6 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		return 0;
 	}
 
-	net = skb_net(skb);
-	ipvs = net_ipvs(net);
 	rcu_read_lock();
 	if (likely(!ip_vs_iph_inverse(iph)))
 		svc = ip_vs_service_find(ipvs, af, skb->mark, iph->protocol,
@@ -67,7 +64,7 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	if (svc) {
 		int ignored;
 
-		if (ip_vs_todrop(net_ipvs(net))) {
+		if (ip_vs_todrop(ipvs)) {
 			/*
 			 * It seems that we are very loaded.
 			 * We have to drop this packet :(
-- 
2.2.1

