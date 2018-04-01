From: Vincent Bernat <vincent@bernat.im>
Subject: [PATCH net-next v2] ipvs: fix multiplicative hashing in sh/dh/lblc/lblcr algorithms
Date: Sun,  1 Apr 2018 12:27:11 +0200
Message-ID: <20180401102711.20862-1-vincent@bernat.im>
References: <alpine.LFD.2.20.1804011037200.1933@ja.home.ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed; d=bernat.im; h=from:to:cc
        :subject:date:message-id:in-reply-to:references; s=postfix; bh=C
        8VuxpnvNll7avPIpPt2zoLvEa4=; b=Dgld+jv6WaBRFY6m32zU2vLf0Z0c8pMe0
        SC87GZB3rLgO4t2j+TRgW/K9YYHJX6fUhJew10CZ+hV5H7n7LeF0SA6eoUF4THJn
        p1aW083+pD8zQawZfRt+DVUtkSRY6ZcNcbTLeo6SNKtxC+523KuX9RDM9G3gRaII
        0h+8XI0UkU=
In-Reply-To: <alpine.LFD.2.20.1804011037200.1933@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Vincent Bernat <vincent@bernat.im>

The sh/dh/lblc/lblcr algorithms are using Knuth's multiplicative
hashing incorrectly. Replace its use by the hash_32() macro, which
correctly implements this algorithm. It doesn't use the same constant,
but it shouldn't matter.

Signed-off-by: Vincent Bernat <vincent@bernat.im>
---
 net/netfilter/ipvs/ip_vs_dh.c    | 3 ++-
 net/netfilter/ipvs/ip_vs_lblc.c  | 3 ++-
 net/netfilter/ipvs/ip_vs_lblcr.c | 3 ++-
 net/netfilter/ipvs/ip_vs_sh.c    | 3 ++-
 4 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index 75f798f8e83b..dfea31fb10c5 100644
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
+	return hash_32(ntohl(addr_fold),  IP_VS_DH_TAB_BITS);
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
2.16.3

