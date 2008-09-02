From: Julius Volz <juliusv@google.com>
Subject: [PATCHv3 13/24] IPVS: Add IPv6 support to xmit() support functions
Date: Tue,  2 Sep 2008 15:55:44 +0200
Message-ID: <1220363755-9854-14-git-send-email-juliusv@google.com>
References: <1220363755-9854-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220363766; bh=6qvFNC8JcHtdlLTVRwOuVnZKxho=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=EaTdiepskxfonjbn+oManoi0vWoMmkBARNEeFlR7
	Y7/jp5b9j95vLiUsg0nOVFQgnL4Tll5py456owrhiEnL0w==
In-Reply-To: <1220363755-9854-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Add IPv6 support to IP_VS_XMIT() and to the xmit routing cache, introducing
a new function __ip_vs_get_out_rt_v6().

Signed-off-by: Julius Volz <juliusv@google.com>

 1 files changed, 75 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_xmit.c b/net/ipv4/ipvs/ip_vs_xmit.c
index 88199c9..fd8342e 100644
--- a/net/ipv4/ipvs/ip_vs_xmit.c
+++ b/net/ipv4/ipvs/ip_vs_xmit.c
@@ -20,6 +20,9 @@
 #include <net/udp.h>
 #include <net/icmp.h>                   /* for icmp_send */
 #include <net/route.h>                  /* for ip_route_output */
+#include <net/ipv6.h>
+#include <net/ip6_route.h>
+#include <linux/icmpv6.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
 
@@ -47,7 +50,8 @@ __ip_vs_dst_check(struct ip_vs_dest *dest, u32 rtos, u32 cookie)
 
 	if (!dst)
 		return NULL;
-	if ((dst->obsolete || rtos != dest->dst_rtos) &&
+	if ((dst->obsolete
+	     || (dest->af == AF_INET && rtos != dest->dst_rtos)) &&
 	    dst->ops->check(dst, cookie) == NULL) {
 		dest->dst_cache = NULL;
 		dst_release(dst);
@@ -109,6 +113,70 @@ __ip_vs_get_out_rt(struct ip_vs_conn *cp, u32 rtos)
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
+		rt = (struct rt6_info *)__ip_vs_dst_check(dest, 0, 0);
+		if (!rt) {
+			struct flowi fl = {
+				.oif = 0,
+				.nl_u = {
+					.ip6_u = {
+						.daddr = dest->addr.in6,
+						.saddr = {
+							.s6_addr32 =
+								{ 0, 0, 0, 0 },
+						},
+					},
+				},
+			};
+
+			rt = (struct rt6_info *)ip6_route_output(&init_net,
+								 NULL, &fl);
+			if (!rt) {
+				spin_unlock(&dest->dst_lock);
+				IP_VS_DBG_RL("ip6_route_output error, "
+					     "dest: " NIP6_FMT "\n",
+					     NIP6(dest->addr.in6));
+				return NULL;
+			}
+			__ip_vs_dst_set(dest, 0, dst_clone(&rt->u.dst));
+			IP_VS_DBG(10, "new dst " NIP6_FMT ", refcnt=%d\n",
+				  NIP6(dest->addr.in6),
+				  atomic_read(&rt->u.dst.__refcnt));
+		}
+		spin_unlock(&dest->dst_lock);
+	} else {
+		struct flowi fl = {
+			.oif = 0,
+			.nl_u = {
+				.ip6_u = {
+					.daddr = cp->daddr.in6,
+					.saddr = {
+						.s6_addr32 = { 0, 0, 0, 0 },
+					},
+				},
+			},
+		};
+
+		rt = (struct rt6_info *)ip6_route_output(&init_net, NULL, &fl);
+		if (!rt) {
+			IP_VS_DBG_RL("ip6_route_output error, dest: "
+				     NIP6_FMT "\n", NIP6(cp->daddr.in6));
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
@@ -123,11 +191,11 @@ ip_vs_dst_reset(struct ip_vs_dest *dest)
 	dst_release(old_dst);
 }
 
-#define IP_VS_XMIT(skb, rt)				\
+#define IP_VS_XMIT(pf, skb, rt)				\
 do {							\
 	(skb)->ipvs_property = 1;			\
 	skb_forward_csum(skb);				\
-	NF_HOOK(PF_INET, NF_INET_LOCAL_OUT, (skb), NULL,	\
+	NF_HOOK(pf, NF_INET_LOCAL_OUT, (skb), NULL,	\
 		(rt)->u.dst.dev, dst_output);		\
 } while (0)
 
@@ -200,7 +268,7 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(skb, rt);
+	IP_VS_XMIT(PF_INET, skb, rt);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -276,7 +344,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(skb, rt);
+	IP_VS_XMIT(PF_INET, skb, rt);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -467,7 +535,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(skb, rt);
+	IP_VS_XMIT(PF_INET, skb, rt);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -540,7 +608,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(skb, rt);
+	IP_VS_XMIT(PF_INET, skb, rt);
 
 	rc = NF_STOLEN;
 	goto out;
-- 
1.5.4.5

