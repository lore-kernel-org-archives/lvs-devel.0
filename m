From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 5/5] ipvs: fix multiplicative hashing in sh/dh/lblc/lblcr algorithms
Date: Thu, 19 Apr 2018 10:56:14 +0200
Message-ID: <20180419085614.7437-6-horms@verge.net.au>
References: <20180419085614.7437-1-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1524128188; bh=RjwnAa3ldt96n72m9CGOcLioN7+hGyd0eaxuUI5gc9Q=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=NFDKd0Ty3bOmYqhKDDU4IpLYKGm3bDh6ki1oektylDQgF6zSMbSJVJz2iKQzFpgme
         uhPdb3gbkln+Y1mlcBshH41cFOz8Ti/Vy/uqCMVcUpep/N/NNwwrEBVUZs25TgIAKx
         NmllONtbLlOuHL3RFB/Zyo7h8DqsAsL15ukCQ8ik=
In-Reply-To: <20180419085614.7437-1-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Vincent Bernat <vincent@bernat.im>, Simon Horman <horms@verge.net.au>

From: Vincent Bernat <vincent@bernat.im>

The sh/dh/lblc/lblcr algorithms are using Knuth's multiplicative
hashing incorrectly. Replace its use by the hash_32() macro, which
correctly implements this algorithm. It doesn't use the same constant,
but it shouldn't matter.

Signed-off-by: Vincent Bernat <vincent@bernat.im>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_dh.c    | 3 ++-
 net/netfilter/ipvs/ip_vs_lblc.c  | 3 ++-
 net/netfilter/ipvs/ip_vs_lblcr.c | 3 ++-
 net/netfilter/ipvs/ip_vs_sh.c    | 3 ++-
 4 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index 75f798f8e83b..07459e71d907 100644
--- a/net/netfilter/ipvs/ip_vs_dh.c
+++ b/net/netfilter/ipvs/ip_vs_dh.c
@@ -43,6 +43,7 @@
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/skbuff.h>
+#include <linux/hash.h>
 
 #include <net/ip_vs.h>
 
@@ -81,7 +82,7 @@ static inline unsigned int ip_vs_dh_hashkey(int af, const union nf_inet_addr *ad
 		addr_fold = addr->ip6[0]^addr->ip6[1]^
 			    addr->ip6[2]^addr->ip6[3];
 #endif
-	return (ntohl(addr_fold)*2654435761UL) & IP_VS_DH_TAB_MASK;
+	return hash_32(ntohl(addr_fold), IP_VS_DH_TAB_BITS);
 }
 
 
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 3057e453bf31..08147fc6400c 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -48,6 +48,7 @@
 #include <linux/kernel.h>
 #include <linux/skbuff.h>
 #include <linux/jiffies.h>
+#include <linux/hash.h>
 
 /* for sysctl */
 #include <linux/fs.h>
@@ -160,7 +161,7 @@ ip_vs_lblc_hashkey(int af, const union nf_inet_addr *addr)
 		addr_fold = addr->ip6[0]^addr->ip6[1]^
 			    addr->ip6[2]^addr->ip6[3];
 #endif
-	return (ntohl(addr_fold)*2654435761UL) & IP_VS_LBLC_TAB_MASK;
+	return hash_32(ntohl(addr_fold), IP_VS_LBLC_TAB_BITS);
 }
 
 
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 92adc04557ed..9b6a6c9e9cfa 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -47,6 +47,7 @@
 #include <linux/jiffies.h>
 #include <linux/list.h>
 #include <linux/slab.h>
+#include <linux/hash.h>
 
 /* for sysctl */
 #include <linux/fs.h>
@@ -323,7 +324,7 @@ ip_vs_lblcr_hashkey(int af, const union nf_inet_addr *addr)
 		addr_fold = addr->ip6[0]^addr->ip6[1]^
 			    addr->ip6[2]^addr->ip6[3];
 #endif
-	return (ntohl(addr_fold)*2654435761UL) & IP_VS_LBLCR_TAB_MASK;
+	return hash_32(ntohl(addr_fold), IP_VS_LBLCR_TAB_BITS);
 }
 
 
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index 16aaac6eedc9..1e01c782583a 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -96,7 +96,8 @@ ip_vs_sh_hashkey(int af, const union nf_inet_addr *addr,
 		addr_fold = addr->ip6[0]^addr->ip6[1]^
 			    addr->ip6[2]^addr->ip6[3];
 #endif
-	return (offset + (ntohs(port) + ntohl(addr_fold))*2654435761UL) &
+	return (offset + hash_32(ntohs(port) + ntohl(addr_fold),
+				 IP_VS_SH_TAB_BITS)) &
 		IP_VS_SH_TAB_MASK;
 }
 
-- 
2.11.0

