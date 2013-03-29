From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 02/34] ipvs: avoid routing by TOS for real server
Date: Fri, 29 Mar 2013 13:11:19 +0900
Message-ID: <1364530311-11512-3-git-send-email-horms@verge.net.au>
References: <1364530311-11512-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1364530311-11512-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

Avoid replacing the cached route for real server
on every packet with different TOS. I doubt that routing
by TOS for real server is used at all, so we should be
better with such optimization.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             |    1 -
 net/netfilter/ipvs/ip_vs_xmit.c |   58 +++++++++++++++++----------------------
 2 files changed, 25 insertions(+), 34 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index bee87ba..64db117 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -753,7 +753,6 @@ struct ip_vs_dest {
 	/* for destination cache */
 	spinlock_t		dst_lock;	/* lock of dst_cache */
 	struct dst_entry	*dst_cache;	/* destination cache entry */
-	u32			dst_rtos;	/* RT_TOS(tos) for dst */
 	u32			dst_cookie;
 	union nf_inet_addr	dst_saddr;
 
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index ee6b7a9..4b0bd15 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -57,27 +57,24 @@ enum {
  *      Destination cache to speed up outgoing route lookup
  */
 static inline void
-__ip_vs_dst_set(struct ip_vs_dest *dest, u32 rtos, struct dst_entry *dst,
-		u32 dst_cookie)
+__ip_vs_dst_set(struct ip_vs_dest *dest, struct dst_entry *dst, u32 dst_cookie)
 {
 	struct dst_entry *old_dst;
 
 	old_dst = dest->dst_cache;
 	dest->dst_cache = dst;
-	dest->dst_rtos = rtos;
 	dest->dst_cookie = dst_cookie;
 	dst_release(old_dst);
 }
 
 static inline struct dst_entry *
-__ip_vs_dst_check(struct ip_vs_dest *dest, u32 rtos)
+__ip_vs_dst_check(struct ip_vs_dest *dest)
 {
 	struct dst_entry *dst = dest->dst_cache;
 
 	if (!dst)
 		return NULL;
-	if ((dst->obsolete || rtos != dest->dst_rtos) &&
-	    dst->ops->check(dst, dest->dst_cookie) == NULL) {
+	if (dst->obsolete && dst->ops->check(dst, dest->dst_cookie) == NULL) {
 		dest->dst_cache = NULL;
 		dst_release(dst);
 		return NULL;
@@ -104,7 +101,7 @@ __mtu_check_toobig_v6(const struct sk_buff *skb, u32 mtu)
 
 /* Get route to daddr, update *saddr, optionally bind route to saddr */
 static struct rtable *do_output_route4(struct net *net, __be32 daddr,
-				       u32 rtos, int rt_mode, __be32 *saddr)
+				       int rt_mode, __be32 *saddr)
 {
 	struct flowi4 fl4;
 	struct rtable *rt;
@@ -113,7 +110,6 @@ static struct rtable *do_output_route4(struct net *net, __be32 daddr,
 	memset(&fl4, 0, sizeof(fl4));
 	fl4.daddr = daddr;
 	fl4.saddr = (rt_mode & IP_VS_RT_MODE_CONNECT) ? *saddr : 0;
-	fl4.flowi4_tos = rtos;
 	fl4.flowi4_flags = (rt_mode & IP_VS_RT_MODE_KNOWN_NH) ?
 			   FLOWI_FLAG_KNOWN_NH : 0;
 
@@ -124,7 +120,7 @@ retry:
 		if (PTR_ERR(rt) == -EINVAL && *saddr &&
 		    rt_mode & IP_VS_RT_MODE_CONNECT && !loop) {
 			*saddr = 0;
-			flowi4_update_output(&fl4, 0, rtos, daddr, 0);
+			flowi4_update_output(&fl4, 0, 0, daddr, 0);
 			goto retry;
 		}
 		IP_VS_DBG_RL("ip_route_output error, dest: %pI4\n", &daddr);
@@ -132,7 +128,7 @@ retry:
 	} else if (!*saddr && rt_mode & IP_VS_RT_MODE_CONNECT && fl4.saddr) {
 		ip_rt_put(rt);
 		*saddr = fl4.saddr;
-		flowi4_update_output(&fl4, 0, rtos, daddr, fl4.saddr);
+		flowi4_update_output(&fl4, 0, 0, daddr, fl4.saddr);
 		loop++;
 		goto retry;
 	}
@@ -143,7 +139,7 @@ retry:
 /* Get route to destination or remote server */
 static struct rtable *
 __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
-		   __be32 daddr, u32 rtos, int rt_mode, __be32 *ret_saddr)
+		   __be32 daddr, int rt_mode, __be32 *ret_saddr)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	struct rtable *rt;			/* Route to the other host */
@@ -152,19 +148,18 @@ __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 
 	if (dest) {
 		spin_lock(&dest->dst_lock);
-		if (!(rt = (struct rtable *)
-		      __ip_vs_dst_check(dest, rtos))) {
-			rt = do_output_route4(net, dest->addr.ip, rtos,
-					      rt_mode, &dest->dst_saddr.ip);
+		rt = (struct rtable *) __ip_vs_dst_check(dest);
+		if (!rt) {
+			rt = do_output_route4(net, dest->addr.ip, rt_mode,
+					      &dest->dst_saddr.ip);
 			if (!rt) {
 				spin_unlock(&dest->dst_lock);
 				return NULL;
 			}
-			__ip_vs_dst_set(dest, rtos, dst_clone(&rt->dst), 0);
-			IP_VS_DBG(10, "new dst %pI4, src %pI4, refcnt=%d, "
-				  "rtos=%X\n",
+			__ip_vs_dst_set(dest, dst_clone(&rt->dst), 0);
+			IP_VS_DBG(10, "new dst %pI4, src %pI4, refcnt=%d\n",
 				  &dest->addr.ip, &dest->dst_saddr.ip,
-				  atomic_read(&rt->dst.__refcnt), rtos);
+				  atomic_read(&rt->dst.__refcnt));
 		}
 		daddr = dest->addr.ip;
 		if (ret_saddr)
@@ -177,7 +172,7 @@ __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 		 * for performance reasons because we do not remember saddr
 		 */
 		rt_mode &= ~IP_VS_RT_MODE_CONNECT;
-		rt = do_output_route4(net, daddr, rtos, rt_mode, &saddr);
+		rt = do_output_route4(net, daddr, rt_mode, &saddr);
 		if (!rt)
 			return NULL;
 		if (ret_saddr)
@@ -307,7 +302,7 @@ __ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_dest *dest,
 
 	if (dest) {
 		spin_lock(&dest->dst_lock);
-		rt = (struct rt6_info *)__ip_vs_dst_check(dest, 0);
+		rt = (struct rt6_info *)__ip_vs_dst_check(dest);
 		if (!rt) {
 			u32 cookie;
 
@@ -320,7 +315,7 @@ __ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_dest *dest,
 			}
 			rt = (struct rt6_info *) dst;
 			cookie = rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
-			__ip_vs_dst_set(dest, 0, dst_clone(&rt->dst), cookie);
+			__ip_vs_dst_set(dest, dst_clone(&rt->dst), cookie);
 			IP_VS_DBG(10, "new dst %pI6, src %pI6, refcnt=%d\n",
 				  &dest->addr.in6, &dest->dst_saddr.in6,
 				  atomic_read(&rt->dst.__refcnt));
@@ -449,8 +444,9 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	EnterFunction(10);
 
-	if (!(rt = __ip_vs_get_out_rt(skb, NULL, iph->daddr, RT_TOS(iph->tos),
-				      IP_VS_RT_MODE_NON_LOCAL, NULL)))
+	rt = __ip_vs_get_out_rt(skb, NULL, iph->daddr, IP_VS_RT_MODE_NON_LOCAL,
+				NULL);
+	if (!rt)
 		goto tx_error_icmp;
 
 	/* MTU checking */
@@ -581,10 +577,9 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	}
 
 	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
-				      RT_TOS(iph->tos),
 				      IP_VS_RT_MODE_LOCAL |
-					IP_VS_RT_MODE_NON_LOCAL |
-					IP_VS_RT_MODE_RDR, NULL)))
+				      IP_VS_RT_MODE_NON_LOCAL |
+				      IP_VS_RT_MODE_RDR, NULL)))
 		goto tx_error_icmp;
 	local = rt->rt_flags & RTCF_LOCAL;
 	/*
@@ -832,10 +827,9 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
-				      RT_TOS(tos), IP_VS_RT_MODE_LOCAL |
-						   IP_VS_RT_MODE_NON_LOCAL |
-						   IP_VS_RT_MODE_CONNECT,
-						   &saddr)))
+				      IP_VS_RT_MODE_LOCAL |
+				      IP_VS_RT_MODE_NON_LOCAL |
+				      IP_VS_RT_MODE_CONNECT, &saddr)))
 		goto tx_error_icmp;
 	if (rt->rt_flags & RTCF_LOCAL) {
 		ip_rt_put(rt);
@@ -1067,7 +1061,6 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
-				      RT_TOS(iph->tos),
 				      IP_VS_RT_MODE_LOCAL |
 				      IP_VS_RT_MODE_NON_LOCAL |
 				      IP_VS_RT_MODE_KNOWN_NH, NULL)))
@@ -1223,7 +1216,6 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		  IP_VS_RT_MODE_LOCAL | IP_VS_RT_MODE_NON_LOCAL |
 		  IP_VS_RT_MODE_RDR : IP_VS_RT_MODE_NON_LOCAL;
 	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
-				      RT_TOS(ip_hdr(skb)->tos),
 				      rt_mode, NULL)))
 		goto tx_error_icmp;
 	local = rt->rt_flags & RTCF_LOCAL;
-- 
1.7.10.4
