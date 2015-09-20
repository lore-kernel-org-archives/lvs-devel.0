From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 13/84] ipvs: Pass ipvs not net to ip_vs_has_real_service
Date: Sun, 20 Sep 2015 01:22:29 -0500
Message-ID: <1442730220-32458-13-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/ip_vs.h             | 2 +-
 net/netfilter/ipvs/ip_vs_core.c | 6 ++++--
 net/netfilter/ipvs/ip_vs_ctl.c  | 3 +--
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 828b19b23e02..b93ee28fb011 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1413,7 +1413,7 @@ struct ip_vs_service *
 ip_vs_service_find(struct netns_ipvs *ipvs, int af, __u32 fwmark, __u16 protocol,
 		  const union nf_inet_addr *vaddr, __be16 vport);
 
-bool ip_vs_has_real_service(struct net *net, int af, __u16 protocol,
+bool ip_vs_has_real_service(struct netns_ipvs *ipvs, int af, __u16 protocol,
 			    const union nf_inet_addr *daddr, __be16 dport);
 
 int ip_vs_use_count_inc(void);
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 583199c2bcdc..c22e0692e22d 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1186,6 +1186,7 @@ static unsigned int
 ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 {
 	struct net *net = NULL;
+	struct netns_ipvs *ipvs;
 	struct ip_vs_iphdr iph;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
@@ -1211,7 +1212,8 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 		return NF_ACCEPT;
 
 	net = skb_net(skb);
-	if (!net_ipvs(net)->enable)
+	ipvs = net_ipvs(net);
+	if (!ipvs->enable)
 		return NF_ACCEPT;
 
 	ip_vs_fill_iph_skb(af, skb, false, &iph);
@@ -1269,7 +1271,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 					 sizeof(_ports), _ports, &iph);
 		if (pptr == NULL)
 			return NF_ACCEPT;	/* Not for me */
-		if (ip_vs_has_real_service(net, af, iph.protocol, &iph.saddr,
+		if (ip_vs_has_real_service(ipvs, af, iph.protocol, &iph.saddr,
 					   pptr[0])) {
 			/*
 			 * Notify the real server: there is no
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index f9151d8ee1ac..c2f4694f626f 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -542,10 +542,9 @@ static void ip_vs_rs_unhash(struct ip_vs_dest *dest)
 }
 
 /* Check if real service by <proto,addr,port> is present */
-bool ip_vs_has_real_service(struct net *net, int af, __u16 protocol,
+bool ip_vs_has_real_service(struct netns_ipvs *ipvs, int af, __u16 protocol,
 			    const union nf_inet_addr *daddr, __be16 dport)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	unsigned int hash;
 	struct ip_vs_dest *dest;
 
-- 
2.2.1

