From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 12/84] ipvs: Pass ipvs not net to ip_vs_service_find
Date: Thu, 24 Sep 2015 09:51:57 +0900
Message-ID: <1443055989-1306-13-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "Eric W. Biederman" <ebiederm@xmission.com>, Simon Horman <horms@verge.net.au>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h                   | 2 +-
 net/netfilter/ipvs/ip_vs_ctl.c        | 5 ++---
 net/netfilter/ipvs/ip_vs_proto_sctp.c | 4 ++--
 net/netfilter/ipvs/ip_vs_proto_tcp.c  | 4 ++--
 net/netfilter/ipvs/ip_vs_proto_udp.c  | 6 ++++--
 5 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 2c22380b9ad7..828b19b23e02 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1410,7 +1410,7 @@ extern struct ip_vs_stats ip_vs_stats;
 extern int sysctl_ip_vs_sync_ver;
 
 struct ip_vs_service *
-ip_vs_service_find(struct net *net, int af, __u32 fwmark, __u16 protocol,
+ip_vs_service_find(struct netns_ipvs *ipvs, int af, __u32 fwmark, __u16 protocol,
 		  const union nf_inet_addr *vaddr, __be16 vport);
 
 bool ip_vs_has_real_service(struct net *net, int af, __u16 protocol,
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index fd8de5ceffca..67fe0c92e3f7 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -406,11 +406,10 @@ __ip_vs_svc_fwm_find(struct netns_ipvs *ipvs, int af, __u32 fwmark)
 
 /* Find service, called under RCU lock */
 struct ip_vs_service *
-ip_vs_service_find(struct net *net, int af, __u32 fwmark, __u16 protocol,
+ip_vs_service_find(struct netns_ipvs *ipvs, int af, __u32 fwmark, __u16 protocol,
 		   const union nf_inet_addr *vaddr, __be16 vport)
 {
 	struct ip_vs_service *svc;
-	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	/*
 	 *	Check the table hashed by fwmark first
@@ -612,7 +611,7 @@ struct ip_vs_dest *ip_vs_find_dest(struct net  *net, int svc_af, int dest_af,
 	struct ip_vs_service *svc;
 	__be16 port = dport;
 
-	svc = ip_vs_service_find(net, svc_af, fwmark, protocol, vaddr, vport);
+	svc = ip_vs_service_find(net_ipvs(net), svc_af, fwmark, protocol, vaddr, vport);
 	if (!svc)
 		return NULL;
 	if (fwmark && (flags & IP_VS_CONN_F_FWD_MASK) != IP_VS_CONN_F_MASQ)
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index ce615866bd63..373a4751c328 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -45,10 +45,10 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 
 	rcu_read_lock();
 	if (likely(!ip_vs_iph_inverse(iph)))
-		svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
+		svc = ip_vs_service_find(ipvs, af, skb->mark, iph->protocol,
 					 &iph->daddr, ports[1]);
 	else
-		svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
+		svc = ip_vs_service_find(ipvs, af, skb->mark, iph->protocol,
 					 &iph->saddr, ports[0]);
 	if (svc) {
 		int ignored;
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index e00623a88518..48af3ca6be03 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -70,10 +70,10 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	rcu_read_lock();
 
 	if (likely(!ip_vs_iph_inverse(iph)))
-		svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
+		svc = ip_vs_service_find(ipvs, af, skb->mark, iph->protocol,
 					 &iph->daddr, ports[1]);
 	else
-		svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
+		svc = ip_vs_service_find(ipvs, af, skb->mark, iph->protocol,
 					 &iph->saddr, ports[0]);
 
 	if (svc) {
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 3b0a2dc1826b..e9f5f7e30bef 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -34,6 +34,7 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		  struct ip_vs_iphdr *iph)
 {
 	struct net *net;
+	struct netns_ipvs *ipvs;
 	struct ip_vs_service *svc;
 	struct udphdr _udph, *uh;
 	__be16 _ports[2], *ports = NULL;
@@ -54,12 +55,13 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	}
 
 	net = skb_net(skb);
+	ipvs = net_ipvs(net);
 	rcu_read_lock();
 	if (likely(!ip_vs_iph_inverse(iph)))
-		svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
+		svc = ip_vs_service_find(ipvs, af, skb->mark, iph->protocol,
 					 &iph->daddr, ports[1]);
 	else
-		svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
+		svc = ip_vs_service_find(ipvs, af, skb->mark, iph->protocol,
 					 &iph->saddr, ports[0]);
 
 	if (svc) {
-- 
2.1.4

