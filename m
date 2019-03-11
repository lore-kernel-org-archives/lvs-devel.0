From: Sasha Levin <sashal@kernel.org>
Subject: [PATCH AUTOSEL 4.19 30/44] ipvs: fix dependency on nf_defrag_ipv6
Date: Mon, 11 Mar 2019 15:56:46 -0400
Message-ID: <20190311195700.138462-30-sashal@kernel.org>
References: <20190311195700.138462-1-sashal@kernel.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1552334274;
        bh=nKQ0Wpl3rjO6c9rZDH2Ap7zWn8031qnb0bb6M1iYOlM=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=BwvOp5ZybRp6X7CMERqXqkpJ3TuSy8eiLdw7na4D4DzDPnTwFw0OHIwbuLkLwRgk/
         +7DN3SITIOuzX+799OfVc7MHrcXgXALd/PL1CyMj47EcGPuDJKDovqRmF7YUVhW3hu
         GUf2DnVIB4JVhLBqXCbtS3ZHK9Dc5SFMWpuGg+Yc=
In-Reply-To: <20190311195700.138462-1-sashal@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc: Andrea Claudi <aclaudi@redhat.com>, Pablo Neira Ayuso <pablo@netfilter.org>, Sasha Levin <sashal@kernel.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

From: Andrea Claudi <aclaudi@redhat.com>

[ Upstream commit 098e13f5b21d3398065fce8780f07a3ef62f4812 ]

ipvs relies on nf_defrag_ipv6 module to manage IPv6 fragmentation,
but lacks proper Kconfig dependencies and does not explicitly
request defrag features.

As a result, if netfilter hooks are not loaded, when IPv6 fragmented
packet are handled by ipvs only the first fragment makes through.

Fix it properly declaring the dependency on Kconfig and registering
netfilter hooks on ip_vs_add_service() and ip_vs_new_dest().

Reported-by: Li Shuang <shuali@redhat.com>
Signed-off-by: Andrea Claudi <aclaudi@redhat.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Acked-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 net/netfilter/ipvs/Kconfig      |  1 +
 net/netfilter/ipvs/ip_vs_core.c | 10 ++++------
 net/netfilter/ipvs/ip_vs_ctl.c  | 10 ++++++++++
 3 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index cad48d07c818..8401cefd9f65 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -29,6 +29,7 @@ config	IP_VS_IPV6
 	bool "IPv6 support for IPVS"
 	depends on IPV6 = y || IP_VS = IPV6
 	select IP6_NF_IPTABLES
+	select NF_DEFRAG_IPV6
 	---help---
 	  Add IPv6 support to IPVS.
 
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 7ca926a03b81..3f963ea22277 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1536,14 +1536,12 @@ ip_vs_try_to_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 		/* sorry, all this trouble for a no-hit :) */
 		IP_VS_DBG_PKT(12, af, pp, skb, iph->off,
 			      "ip_vs_in: packet continues traversal as normal");
-		if (iph->fragoffs) {
-			/* Fragment that couldn't be mapped to a conn entry
-			 * is missing module nf_defrag_ipv6
-			 */
-			IP_VS_DBG_RL("Unhandled frag, load nf_defrag_ipv6\n");
+
+		/* Fragment couldn't be mapped to a conn entry */
+		if (iph->fragoffs)
 			IP_VS_DBG_PKT(7, af, pp, skb, iph->off,
 				      "unhandled fragment");
-		}
+
 		*verdict = NF_ACCEPT;
 		return 0;
 	}
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 518364f4abcc..3bcc4b222a82 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -43,6 +43,7 @@
 #ifdef CONFIG_IP_VS_IPV6
 #include <net/ipv6.h>
 #include <net/ip6_route.h>
+#include <net/netfilter/ipv6/nf_defrag_ipv6.h>
 #endif
 #include <net/route.h>
 #include <net/sock.h>
@@ -895,6 +896,7 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 {
 	struct ip_vs_dest *dest;
 	unsigned int atype, i;
+	int ret = 0;
 
 	EnterFunction(2);
 
@@ -905,6 +907,10 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 			atype & IPV6_ADDR_LINKLOCAL) &&
 			!__ip_vs_addr_is_local_v6(svc->ipvs->net, &udest->addr.in6))
 			return -EINVAL;
+
+		ret = nf_defrag_ipv6_enable(svc->ipvs->net);
+		if (ret)
+			return ret;
 	} else
 #endif
 	{
@@ -1228,6 +1234,10 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 			ret = -EINVAL;
 			goto out_err;
 		}
+
+		ret = nf_defrag_ipv6_enable(ipvs->net);
+		if (ret)
+			goto out_err;
 	}
 #endif
 
-- 
2.19.1

