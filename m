From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs,v2 06/18] ipvs: Pull out crosses_local_route_boundary logic
Date: Thu, 14 Aug 2014 20:23:29 -0700
Message-ID: <1408073021-24007-7-git-send-email-agartrell@fb.com>
References: <1408073021-24007-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=0XpIpUQIbonpMmVsBjmqru7HnvMO1QOHxw0ApEj9vFI=;
 b=kZnVzH3ykkfAM4lhp/yxe4fOqkZikOsQjyue+Y7X1AIVmkB5JupCjf47TAYRCzuszo8N
 1zeLd210FA2RoRjpt8y77ktK07i8DVRV1yDKB1zTWcLODjD7GOUUVwcbBdIPc7fXP4EX
 B4Utnh2Zf3CTOg/AyJQvzOnNMkW6vjEwu2g= 
In-Reply-To: <1408073021-24007-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

This logic is repeated in both out_rt functions so it was redundant.
Additionally, we'll need to be able to do checks to route v4 to v6 and vice
versa in order to deal with heterogeneous pools.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 105 +++++++++++++++++++++-------------------
 1 file changed, 54 insertions(+), 51 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 94c7466..b348347 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -157,6 +157,49 @@ retry:
 	return rt;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static inline int __ip_vs_is_local_route6(struct rt6_info *rt)
+{
+	return rt->dst.dev && rt->dst.dev->flags & IFF_LOOPBACK;
+}
+#endif
+
+static inline bool crosses_local_route_boundary(int skb_af, struct sk_buff *skb,
+						int rt_mode, bool new_rt_is_local)
+{
+	bool rt_mode_allow_local = !!(rt_mode & IP_VS_RT_MODE_LOCAL);
+	bool rt_mode_allow_non_local = !!(rt_mode & IP_VS_RT_MODE_LOCAL);
+	bool rt_mode_allow_redirect = !!(rt_mode & IP_VS_RT_MODE_RDR);
+	bool source_is_loopback;
+	bool old_rt_is_local;
+
+#ifdef CONFIG_IP_VS_IPV6
+	if (skb_af == AF_INET6) {
+		source_is_loopback = (!skb->dev || skb->dev->flags & IFF_LOOPBACK) &&
+			(ipv6_addr_type(&ipv6_hdr(skb)->saddr) & IPV6_ADDR_LOOPBACK);
+		old_rt_is_local = __ip_vs_is_local_route6(
+			(struct rt6_info *) skb_dst(skb));
+	} else
+#endif
+	{
+		source_is_loopback = ipv4_is_loopback(ip_hdr(skb)->saddr);
+		old_rt_is_local = skb_rtable(skb)->rt_flags & RTCF_LOCAL;
+	}
+
+	if (unlikely(new_rt_is_local)) {
+		if (!rt_mode_allow_local)
+			return true;
+		if (!rt_mode_allow_redirect && old_rt_is_local)
+			return true;
+	} else {
+		if (!rt_mode_allow_non_local)
+			return true;
+		if (source_is_loopback)
+			return true;
+	}
+	return false;
+}
+
 /* Get route to destination or remote server */
 static int
 __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
@@ -218,30 +261,14 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 	}
 
 	local = (rt->rt_flags & RTCF_LOCAL) ? 1 : 0;
-	if (!((local ? IP_VS_RT_MODE_LOCAL : IP_VS_RT_MODE_NON_LOCAL) &
-	      rt_mode)) {
-		IP_VS_DBG_RL("Stopping traffic to %s address, dest: %pI4\n",
-			     (rt->rt_flags & RTCF_LOCAL) ?
-			     "local":"non-local", &daddr);
+	if (unlikely(crosses_local_route_boundary(skb_af, skb, rt_mode,
+						  local))) {
+		IP_VS_DBG_RL("We are crossing local and non-local addresses\n");
 		goto err_put;
 	}
 	iph = ip_hdr(skb);
-	if (likely(!local)) {
-		if (unlikely(ipv4_is_loopback(iph->saddr))) {
-			IP_VS_DBG_RL("Stopping traffic from loopback address "
-				     "%pI4 to non-local address, dest: %pI4\n",
-				     &iph->saddr, &daddr);
-			goto err_put;
-		}
-	} else {
-		ort = skb_rtable(skb);
-		if (!(rt_mode & IP_VS_RT_MODE_RDR) &&
-		    !(ort->rt_flags & RTCF_LOCAL)) {
-			IP_VS_DBG_RL("Redirect from non-local address %pI4 to "
-				     "local requires NAT method, dest: %pI4\n",
-				     &iph->daddr, &daddr);
-			goto err_put;
-		}
+
+	if (unlikely(local)) {
 		/* skb to local stack, preserve old route */
 		if (!noref)
 			ip_rt_put(rt);
@@ -295,12 +322,6 @@ err_unreach:
 }
 
 #ifdef CONFIG_IP_VS_IPV6
-
-static inline int __ip_vs_is_local_route6(struct rt6_info *rt)
-{
-	return rt->dst.dev && rt->dst.dev->flags & IFF_LOOPBACK;
-}
-
 static struct dst_entry *
 __ip_vs_route_output_v6(struct net *net, struct in6_addr *daddr,
 			struct in6_addr *ret_saddr, int do_xfrm)
@@ -393,32 +414,14 @@ __ip_vs_get_out_rt_v6(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 	}
 
 	local = __ip_vs_is_local_route6(rt);
-	if (!((local ? IP_VS_RT_MODE_LOCAL : IP_VS_RT_MODE_NON_LOCAL) &
-	      rt_mode)) {
-		IP_VS_DBG_RL("Stopping traffic to %s address, dest: %pI6c\n",
-			     local ? "local":"non-local", daddr);
+
+	if (unlikely(crosses_local_route_boundary(skb_af, skb, rt_mode,
+						  local))) {
+		IP_VS_DBG_RL("We are crossing local and non-local addresses\n");
 		goto err_put;
 	}
-	if (likely(!local)) {
-		if (unlikely((!skb->dev || skb->dev->flags & IFF_LOOPBACK) &&
-			     ipv6_addr_type(&ipv6_hdr(skb)->saddr) &
-					    IPV6_ADDR_LOOPBACK)) {
-			IP_VS_DBG_RL("Stopping traffic from loopback address "
-				     "%pI6c to non-local address, "
-				     "dest: %pI6c\n",
-				     &ipv6_hdr(skb)->saddr, daddr);
-			goto err_put;
-		}
-	} else {
-		ort = (struct rt6_info *) skb_dst(skb);
-		if (!(rt_mode & IP_VS_RT_MODE_RDR) &&
-		    !__ip_vs_is_local_route6(ort)) {
-			IP_VS_DBG_RL("Redirect from non-local address %pI6c "
-				     "to local requires NAT method, "
-				     "dest: %pI6c\n",
-				     &ipv6_hdr(skb)->daddr, daddr);
-			goto err_put;
-		}
+
+	if (unlikely(local)) {
 		/* skb to local stack, preserve old route */
 		if (!noref)
 			dst_release(&rt->dst);
-- 
1.8.1

