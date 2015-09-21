From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 73/84] ipvs: Simplify ipvs and net access in ip_vs_leave
Date: Mon, 21 Sep 2015 13:02:50 -0500
Message-ID: <1442858581-15869-73-git-send-email-ebiederm@xmission.com>
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

Stop using the hack skb_net(skb) to compute the network namespace.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 7e9ee1dece19..15661691bf7d 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -568,21 +568,17 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		struct ip_vs_proto_data *pd, struct ip_vs_iphdr *iph)
 {
 	__be16 _ports[2], *pptr, dport;
-	struct net *net;
-	struct netns_ipvs *ipvs;
+	struct netns_ipvs *ipvs = svc->ipvs;
+	struct net *net = ipvs->net;
 
 	pptr = frag_safe_skb_hp(skb, iph->len, sizeof(_ports), _ports, iph);
 	if (!pptr)
 		return NF_DROP;
 	dport = likely(!ip_vs_iph_inverse(iph)) ? pptr[1] : pptr[0];
 
-	net = skb_net(skb);
-
-
 	/* if it is fwmark-based service, the cache_bypass sysctl is up
 	   and the destination is a non-local unicast, then create
 	   a cache_bypass connection entry */
-	ipvs = net_ipvs(net);
 	if (sysctl_cache_bypass(ipvs) && svc->fwmark &&
 	    !(iph->hdr_flags & (IP_VS_HDR_INVERSE | IP_VS_HDR_ICMP)) &&
 	    ip_vs_addr_is_unicast(net, svc->af, &iph->daddr)) {
-- 
2.2.1
