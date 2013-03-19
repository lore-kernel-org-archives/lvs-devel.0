From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 1/2] ipvs: fix hashing in ip_vs_svc_hashkey
Date: Tue, 19 Mar 2013 21:43:47 +0900
Message-ID: <1363697028-15314-2-git-send-email-horms@verge.net.au>
References: <1363697028-15314-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1363697028-15314-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

net is a pointer in host order, mix it properly
with other keys in network order. Fixes sparse warning.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c68198b..a528178 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -271,16 +271,18 @@ ip_vs_svc_hashkey(struct net *net, int af, unsigned int proto,
 {
 	register unsigned int porth = ntohs(port);
 	__be32 addr_fold = addr->ip;
+	__u32 ahash;
 
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6)
 		addr_fold = addr->ip6[0]^addr->ip6[1]^
 			    addr->ip6[2]^addr->ip6[3];
 #endif
-	addr_fold ^= ((size_t)net>>8);
+	ahash = ntohl(addr_fold);
+	ahash ^= ((size_t) net >> 8);
 
-	return (proto^ntohl(addr_fold)^(porth>>IP_VS_SVC_TAB_BITS)^porth)
-		& IP_VS_SVC_TAB_MASK;
+	return (proto ^ ahash ^ (porth >> IP_VS_SVC_TAB_BITS) ^ porth) &
+	       IP_VS_SVC_TAB_MASK;
 }
 
 /*
-- 
1.7.10.4
