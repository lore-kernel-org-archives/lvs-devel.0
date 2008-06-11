From: "Julius R. Volz" <juliusv@google.com>
Subject: [PATCH 14/26] IPVS: Extend xmit routing cache to support IPv6.
Date: Wed, 11 Jun 2008 19:11:57 +0200
Message-ID: <1213204329-10973-15-git-send-email-juliusv@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213204343; bh=2igCEcQwV3TMrtvpmZ6Cp2Wg/YQ=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=rH9ZR7JCEp6rfkuQJmUDAC9qHmCUL11Xv+9F4pHe
	O43QNiuPFuq3dOGVBO5bsa2HwH7H8kyeyIdgfzryQ4IN+Q==
In-Reply-To: <1213204329-10973-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com, "Julius R. Volz" <juliusv@google.com>

Extend xmit destination routing cache to support lookup of IPv6
destinations.

Signed-off-by: Julius R. Volz <juliusv@google.com>

 1 files changed, 74 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 6b6ce6b..94b8fcb 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -22,6 +22,9 @@
 #include <net/udp.h>
 #include <net/icmp.h>                   /* for icmp_send */
 #include <net/route.h>                  /* for ip_route_output */
+#include <net/ipv6.h>
+#include <net/ip6_route.h>
+#include <linux/icmpv6.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
 
@@ -59,6 +62,25 @@ __ip_vs_dst_check(struct ip_vs_dest *dest, u32 rtos, u32 cookie)
 	return dst;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static inline struct dst_entry *
+__ip_vs_dst_check_v6(struct ip_vs_dest *dest, u32 cookie)
+{
+	struct dst_entry *dst = dest->dst_cache;
+
+	if (!dst)
+		return NULL;
+	if ((dst->obsolete) &&
+	    dst->ops->check(dst, cookie) == NULL) {
+		dest->dst_cache = NULL;
+		dst_release(dst);
+		return NULL;
+	}
+	dst_hold(dst);
+	return dst;
+}
+#endif
+
 static struct rtable *
 __ip_vs_get_out_rt(struct ip_vs_conn *cp, u32 rtos)
 {
@@ -111,6 +133,58 @@ __ip_vs_get_out_rt(struct ip_vs_conn *cp, u32 rtos)
 	return rt;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static struct rt6_info *
+__ip_vs_get_out_rt_v6(struct ip_vs_conn *cp)
+{
+	struct rt6_info *rt;			/* Route to the other host */
+	struct ip_vs_dest *dest = cp->dest;
+
+	if (dest) {
+		spin_lock(&dest->dst_lock);
+		if (!(rt = (struct rt6_info *)
+		      __ip_vs_dst_check_v6(dest, 0))) {
+			struct flowi fl = {
+				.oif = 0,
+				.nl_u = {
+					.ip6_u = {
+						.daddr = dest->addr.v6,
+						.saddr = { .s6_addr32 = {0, 0, 0, 0} }, } },
+			};
+
+			if (!(rt = (struct rt6_info *)ip6_route_output(&init_net, NULL, &fl))) {
+				spin_unlock(&dest->dst_lock);
+				IP_VS_DBG_RL("ip6_route_output error, "
+					     "dest: " NIP6_FMT "\n",
+					     NIP6(dest->addr.v6));
+				return NULL;
+			}
+			__ip_vs_dst_set(dest, 0, dst_clone(&rt->u.dst));
+			IP_VS_DBG(10, "new dst " NIP6_FMT ", refcnt=%d\n",
+				  NIP6(dest->addr.v6),
+				  atomic_read(&rt->u.dst.__refcnt));
+		}
+		spin_unlock(&dest->dst_lock);
+	} else {
+		struct flowi fl = {
+			.oif = 0,
+			.nl_u = {
+				.ip6_u = {
+					.daddr = cp->daddr.v6,
+					.saddr = { .s6_addr32 = {0, 0, 0, 0}}, } },
+		};
+
+		if (!(rt = (struct rt6_info *)ip6_route_output(&init_net, NULL, &fl))) {
+			IP_VS_DBG_RL("ip6_route_output error, dest: "
+				     NIP6_FMT "\n", NIP6(cp->daddr.v6));
+			return NULL;
+		}
+	}
+
+	return rt;
+}
+#endif
+
 
 /*
  *	Release dest->dst_cache before a dest is removed
-- 
1.5.3.6

