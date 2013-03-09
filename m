From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 4/5] ipvs: fix hashing in ip_vs_svc_hashkey
Date: Sat,  9 Mar 2013 23:25:07 +0200
Message-ID: <1362864308-8259-5-git-send-email-ja@ssi.bg>
References: <1362864308-8259-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1362864308-8259-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

	net is a pointer in host order, mix it properly
with other keys in network order. Fixes sparse warning.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 11326db..2c8db45 100644
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
1.7.3.4

