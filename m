From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 72/84] ipvs: Wrap sysctl_cache_bypass and remove ifdefs in ip_vs_leave
Date: Sun, 20 Sep 2015 01:23:28 -0500
Message-ID: <1442730220-32458-72-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

With sysctl_cache_bypass now a compile time constant the compiler can
figue out that it can elimiate all of the code that depends on
sysctl_cache_bypass being true.

Also remove the duplicate computation of net previously necessitated
by #ifdef CONFIG_SYSCTL

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/ip_vs.h             | 10 ++++++++++
 net/netfilter/ipvs/ip_vs_core.c | 13 +++----------
 2 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index c68c2c8ae48a..dacd873e8bb9 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1101,6 +1101,11 @@ static inline int sysctl_ignore_tunneled(struct netns_ipvs *ipvs)
 	return ipvs->sysctl_ignore_tunneled;
 }
 
+static inline int sysctl_cache_bypass(struct netns_ipvs *ipvs)
+{
+	return ipvs->sysctl_cache_bypass;
+}
+
 #else
 
 static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
@@ -1183,6 +1188,11 @@ static inline int sysctl_ignore_tunneled(struct netns_ipvs *ipvs)
 	return 0;
 }
 
+static inline int sysctl_cache_bypass(struct netns_ipvs *ipvs)
+{
+	return 0;
+}
+
 #endif
 
 /* IPVS core functions
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 1c9c52349b7c..7e9ee1dece19 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -568,17 +568,14 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		struct ip_vs_proto_data *pd, struct ip_vs_iphdr *iph)
 {
 	__be16 _ports[2], *pptr, dport;
-#ifdef CONFIG_SYSCTL
 	struct net *net;
 	struct netns_ipvs *ipvs;
-#endif
 
 	pptr = frag_safe_skb_hp(skb, iph->len, sizeof(_ports), _ports, iph);
 	if (!pptr)
 		return NF_DROP;
 	dport = likely(!ip_vs_iph_inverse(iph)) ? pptr[1] : pptr[0];
 
-#ifdef CONFIG_SYSCTL
 	net = skb_net(skb);
 
 
@@ -586,7 +583,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 	   and the destination is a non-local unicast, then create
 	   a cache_bypass connection entry */
 	ipvs = net_ipvs(net);
-	if (ipvs->sysctl_cache_bypass && svc->fwmark &&
+	if (sysctl_cache_bypass(ipvs) && svc->fwmark &&
 	    !(iph->hdr_flags & (IP_VS_HDR_INVERSE | IP_VS_HDR_ICMP)) &&
 	    ip_vs_addr_is_unicast(net, svc->af, &iph->daddr)) {
 		int ret;
@@ -624,7 +621,6 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		ip_vs_conn_put(cp);
 		return ret;
 	}
-#endif
 
 	/*
 	 * When the virtual ftp service is presented, packets destined
@@ -647,11 +643,8 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 	 */
 #ifdef CONFIG_IP_VS_IPV6
 	if (svc->af == AF_INET6) {
-		if (!skb->dev) {
-			struct net *net_ = dev_net(skb_dst(skb)->dev);
-
-			skb->dev = net_->loopback_dev;
-		}
+		if (!skb->dev)
+			skb->dev = net->loopback_dev;
 		icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0);
 	} else
 #endif
-- 
2.2.1
