From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next 06/20] ipvs: Pull out crosses_local_route_boundary logic
Date: Tue, 9 Sep 2014 16:40:25 -0700
Message-ID: <1410306039-2977-7-git-send-email-agartrell@fb.com>
References: <1410306039-2977-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=603kdeF8RIvgIgcppQ1a6g4sUkuYFqBu5QhR6MXqtj0=;
 b=Bd1j6OMuNdV3SMVtdMoZjrjbjgf8a84pbxvi6IDEcf0gt7Ldss6zAev03A2mV5iHF6IE
 tKdkUXv6/MuC3avVhvegbMvFyAATHfehy/4Smqs9unwkafI0nDNO0lr6SpYEJD12tEka
 SKgBjWvCwwdLttvro0D1qSc9N25fQQNmsbo= 
In-Reply-To: <1410306039-2977-1-git-send-email-agartrell@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Cc: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com, ps@fb.com, Alex Gartrell <agartrell@fb.com>

This logic is repeated in both out_rt functions so it was redundant.
Additionally, we'll need to be able to do checks to route v4 to v6 and vice
versa in order to deal with heterogeneous pools.

This patch also updates the callsites to add an additional parameter to the
out route functions.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 144 +++++++++++++++++++++-------------------
 1 file changed, 77 insertions(+), 67 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 56896a4..b3b54d7 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -157,9 +157,56 @@ retry:
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
+						int rt_mode,
+						bool new_rt_is_local)
+{
+	bool rt_mode_allow_local = !!(rt_mode & IP_VS_RT_MODE_LOCAL);
+	bool rt_mode_allow_non_local = !!(rt_mode & IP_VS_RT_MODE_LOCAL);
+	bool rt_mode_allow_redirect = !!(rt_mode & IP_VS_RT_MODE_RDR);
+	bool source_is_loopback;
+	bool old_rt_is_local;
+
+#ifdef CONFIG_IP_VS_IPV6
+	if (skb_af == AF_INET6) {
+		int addr_type = ipv6_addr_type(&ipv6_hdr(skb)->saddr);
+
+		source_is_loopback =
+			(!skb->dev || skb->dev->flags & IFF_LOOPBACK) &&
+			(addr_type & IPV6_ADDR_LOOPBACK);
+		old_rt_is_local = __ip_vs_is_local_route6(
+			(struct rt6_info *)skb_dst(skb));
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
+		if (!rt_mode_allow_redirect && !old_rt_is_local)
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
-__ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
+__ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 		   __be32 daddr, int rt_mode, __be32 *ret_saddr)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
@@ -218,30 +265,15 @@ __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 	}
 
 	local = (rt->rt_flags & RTCF_LOCAL) ? 1 : 0;
-	if (!((local ? IP_VS_RT_MODE_LOCAL : IP_VS_RT_MODE_NON_LOCAL) &
-	      rt_mode)) {
-		IP_VS_DBG_RL("Stopping traffic to %s address, dest: %pI4\n",
-			     (rt->rt_flags & RTCF_LOCAL) ?
-			     "local":"non-local", &daddr);
+	if (unlikely(crosses_local_route_boundary(skb_af, skb, rt_mode,
+						  local))) {
+		IP_VS_DBG_RL("We are crossing local and non-local addresses"
+			     " daddr=%pI4\n", &dest->addr.ip);
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
@@ -295,12 +327,6 @@ err_unreach:
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
@@ -339,7 +365,7 @@ out_err:
  * Get route to destination or remote server
  */
 static int
-__ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_dest *dest,
+__ip_vs_get_out_rt_v6(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 		      struct in6_addr *daddr, struct in6_addr *ret_saddr,
 		      struct ip_vs_iphdr *ipvsh, int do_xfrm, int rt_mode)
 {
@@ -393,32 +419,15 @@ __ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_dest *dest,
 	}
 
 	local = __ip_vs_is_local_route6(rt);
-	if (!((local ? IP_VS_RT_MODE_LOCAL : IP_VS_RT_MODE_NON_LOCAL) &
-	      rt_mode)) {
-		IP_VS_DBG_RL("Stopping traffic to %s address, dest: %pI6c\n",
-			     local ? "local":"non-local", daddr);
+
+	if (unlikely(crosses_local_route_boundary(skb_af, skb, rt_mode,
+						  local))) {
+		IP_VS_DBG_RL("We are crossing local and non-local addresses"
+			     " daddr=%pI6\n", &dest->addr.in6);
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
@@ -556,8 +565,8 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	rcu_read_lock();
-	if (__ip_vs_get_out_rt(skb, NULL, iph->daddr, IP_VS_RT_MODE_NON_LOCAL,
-			       NULL) < 0)
+	if (__ip_vs_get_out_rt(cp->af, skb, NULL, iph->daddr,
+			       IP_VS_RT_MODE_NON_LOCAL, NULL) < 0)
 		goto tx_error;
 
 	ip_send_check(iph);
@@ -586,7 +595,7 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	rcu_read_lock();
-	if (__ip_vs_get_out_rt_v6(skb, NULL, &ipvsh->daddr.in6, NULL,
+	if (__ip_vs_get_out_rt_v6(cp->af, skb, NULL, &ipvsh->daddr.in6, NULL,
 				  ipvsh, 0, IP_VS_RT_MODE_NON_LOCAL) < 0)
 		goto tx_error;
 
@@ -633,7 +642,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	}
 
 	was_input = rt_is_input_route(skb_rtable(skb));
-	local = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
+	local = __ip_vs_get_out_rt(cp->af, skb, cp->dest, cp->daddr.ip,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
 				   IP_VS_RT_MODE_RDR, NULL);
@@ -721,8 +730,8 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		IP_VS_DBG(10, "filled cport=%d\n", ntohs(*p));
 	}
 
-	local = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
-				      ipvsh, 0,
+	local = __ip_vs_get_out_rt_v6(cp->af, skb, cp->dest, &cp->daddr.in6,
+				      NULL, ipvsh, 0,
 				      IP_VS_RT_MODE_LOCAL |
 				      IP_VS_RT_MODE_NON_LOCAL |
 				      IP_VS_RT_MODE_RDR);
@@ -829,7 +838,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	rcu_read_lock();
-	local = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
+	local = __ip_vs_get_out_rt(cp->af, skb, cp->dest, cp->daddr.ip,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
 				   IP_VS_RT_MODE_CONNECT |
@@ -928,7 +937,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	rcu_read_lock();
-	local = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6,
+	local = __ip_vs_get_out_rt_v6(cp->af, skb, cp->dest, &cp->daddr.in6,
 				      &saddr, ipvsh, 1,
 				      IP_VS_RT_MODE_LOCAL |
 				      IP_VS_RT_MODE_NON_LOCAL |
@@ -1021,7 +1030,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	rcu_read_lock();
-	local = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
+	local = __ip_vs_get_out_rt(cp->af, skb, cp->dest, cp->daddr.ip,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
 				   IP_VS_RT_MODE_KNOWN_NH, NULL);
@@ -1060,8 +1069,8 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	rcu_read_lock();
-	local = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
-				      ipvsh, 0,
+	local = __ip_vs_get_out_rt_v6(cp->af, skb, cp->dest, &cp->daddr.in6,
+				      NULL, ipvsh, 0,
 				      IP_VS_RT_MODE_LOCAL |
 				      IP_VS_RT_MODE_NON_LOCAL);
 	if (local < 0)
@@ -1128,7 +1137,8 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		  IP_VS_RT_MODE_LOCAL | IP_VS_RT_MODE_NON_LOCAL |
 		  IP_VS_RT_MODE_RDR : IP_VS_RT_MODE_NON_LOCAL;
 	rcu_read_lock();
-	local = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip, rt_mode, NULL);
+	local = __ip_vs_get_out_rt(cp->af, skb, cp->dest, cp->daddr.ip, rt_mode,
+				   NULL);
 	if (local < 0)
 		goto tx_error;
 	rt = skb_rtable(skb);
@@ -1219,8 +1229,8 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		  IP_VS_RT_MODE_LOCAL | IP_VS_RT_MODE_NON_LOCAL |
 		  IP_VS_RT_MODE_RDR : IP_VS_RT_MODE_NON_LOCAL;
 	rcu_read_lock();
-	local = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
-				      ipvsh, 0, rt_mode);
+	local = __ip_vs_get_out_rt_v6(cp->af, skb, cp->dest, &cp->daddr.in6,
+				      NULL, ipvsh, 0, rt_mode);
 	if (local < 0)
 		goto tx_error;
 	rt = (struct rt6_info *) skb_dst(skb);
-- 
1.8.1
