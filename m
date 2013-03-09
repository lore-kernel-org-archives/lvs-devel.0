From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCHv2 net-next 09/15] ipvs: optimize dst usage for real server
Date: Sat,  9 Mar 2013 23:16:49 +0200
Message-ID: <1362863815-5898-10-git-send-email-ja@ssi.bg>
References: <1362863815-5898-1-git-send-email-ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1362863815-5898-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

	Currently when forwarding requests to real servers
we use dst_lock and atomic operations when cloning the
dst_cache value. As the dst_cache value does not change
most of the time it is better to use RCU and to lock
dst_lock only when we need to replace the obsoleted dst.
For this to work we keep dst_cache in new structure protected
by RCU. For packets to remote real servers we will use noref
version of dst_cache, it will be valid while we are in RCU
read-side critical section because now dst_release for replaced
dsts will be invoked after the grace period. Packets to
local real servers that are passed to local stack with
NF_ACCEPT need a dst clone.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h             |   12 ++-
 net/netfilter/ipvs/ip_vs_core.c |   11 ++-
 net/netfilter/ipvs/ip_vs_ctl.c  |   24 ++++--
 net/netfilter/ipvs/ip_vs_xmit.c |  188 +++++++++++++++++++++++++++++---------
 4 files changed, 176 insertions(+), 59 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index c05c59c..f8cc8f4 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -724,6 +724,13 @@ struct ip_vs_service {
 	struct ip_vs_pe		*pe;
 };
 
+/* Information for cached dst */
+struct ip_vs_dest_dst {
+	struct dst_entry	*dst_cache;	/* destination cache entry */
+	u32			dst_cookie;
+	union nf_inet_addr	dst_saddr;
+	struct rcu_head		rcu_head;
+};
 
 /*
  *	The real server destination forwarding entry
@@ -752,9 +759,7 @@ struct ip_vs_dest {
 
 	/* for destination cache */
 	spinlock_t		dst_lock;	/* lock of dst_cache */
-	struct dst_entry	*dst_cache;	/* destination cache entry */
-	u32			dst_cookie;
-	union nf_inet_addr	dst_saddr;
+	struct ip_vs_dest_dst __rcu *dest_dst;	/* cached dst info */
 
 	/* for virtual service */
 	struct ip_vs_service	*svc;		/* service it belongs to */
@@ -1415,6 +1420,7 @@ extern int ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 extern int ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 			   struct ip_vs_protocol *pp, int offset,
 			   unsigned int hooknum, struct ip_vs_iphdr *iph);
+extern void ip_vs_dest_dst_rcu_free(struct rcu_head *head);
 
 #ifdef CONFIG_IP_VS_IPV6
 extern int ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 47edf5a..7e03f42 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1403,10 +1403,13 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 				goto ignore_ipip;
 			/* Prefer the resulting PMTU */
 			if (dest) {
-				spin_lock(&dest->dst_lock);
-				if (dest->dst_cache)
-					mtu = dst_mtu(dest->dst_cache);
-				spin_unlock(&dest->dst_lock);
+				struct ip_vs_dest_dst *dest_dst;
+
+				rcu_read_lock();
+				dest_dst = rcu_dereference(dest->dest_dst);
+				if (dest_dst)
+					mtu = dst_mtu(dest_dst->dst_cache);
+				rcu_read_unlock();
 			}
 			if (mtu > 68 + sizeof(struct iphdr))
 				mtu -= sizeof(struct iphdr);
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 7b774af..844fb9b 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -639,15 +639,25 @@ struct ip_vs_dest *ip_vs_find_dest(struct net  *net, int af,
 	return dest;
 }
 
-/* Release dst_cache for dest in user context */
+void ip_vs_dest_dst_rcu_free(struct rcu_head *head)
+{
+	struct ip_vs_dest_dst *dest_dst = container_of(head,
+						       struct ip_vs_dest_dst,
+						       rcu_head);
+
+	dst_release(dest_dst->dst_cache);
+	kfree(dest_dst);
+}
+
+/* Release dest_dst and dst_cache for dest in user context */
 static void __ip_vs_dst_cache_reset(struct ip_vs_dest *dest)
 {
-	struct dst_entry *old_dst;
+	struct ip_vs_dest_dst *old = rcu_dereference_raw(dest->dest_dst);
 
-	old_dst = dest->dst_cache;
-	dest->dst_cache = NULL;
-	dst_release(old_dst);
-	dest->dst_saddr.ip = 0;
+	if (old) {
+		RCU_INIT_POINTER(dest->dest_dst, NULL);
+		call_rcu(&old->rcu_head, ip_vs_dest_dst_rcu_free);
+	}
 }
 
 /*
@@ -1511,7 +1521,7 @@ static inline void
 ip_vs_forget_dev(struct ip_vs_dest *dest, struct net_device *dev)
 {
 	spin_lock_bh(&dest->dst_lock);
-	if (dest->dst_cache && dest->dst_cache->dev == dev) {
+	if (dest->dest_dst && dest->dest_dst->dst_cache->dev == dev) {
 		IP_VS_DBG_BUF(3, "Reset dev:%s dest %s:%u ,dest->refcnt=%d\n",
 			      dev->name,
 			      IP_VS_DBG_ADDR(dest->af, &dest->addr),
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 307d0f3..693701f 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -17,6 +17,8 @@
  * - not all connections have destination server, for example,
  * connections in backup server when fwmark is used
  * - bypass connections use daddr from packet
+ * - we can use dst without ref while sending in RCU section, we use
+ * ref when returning NF_ACCEPT for NAT-ed packet via loopback
  * LOCAL_OUT rules:
  * - skb->dev is NULL, skb->protocol is not set (both are set in POST_ROUTING)
  * - skb->pkt_type is not set yet
@@ -54,34 +56,51 @@ enum {
 	IP_VS_RT_MODE_TUNNEL	= 32,/* Tunnel mode */
 };
 
+static inline struct ip_vs_dest_dst *ip_vs_dest_dst_alloc(void)
+{
+	return kmalloc(sizeof(struct ip_vs_dest_dst), GFP_ATOMIC);
+}
+
+static inline void ip_vs_dest_dst_free(struct ip_vs_dest_dst *dest_dst)
+{
+	kfree(dest_dst);
+}
+
 /*
  *      Destination cache to speed up outgoing route lookup
  */
 static inline void
-__ip_vs_dst_set(struct ip_vs_dest *dest, struct dst_entry *dst, u32 dst_cookie)
+__ip_vs_dst_set(struct ip_vs_dest *dest, struct ip_vs_dest_dst *dest_dst,
+		struct dst_entry *dst, u32 dst_cookie)
 {
-	struct dst_entry *old_dst;
+	struct ip_vs_dest_dst *old;
+
+	old = rcu_dereference_protected(dest->dest_dst,
+					lockdep_is_held(&dest->dst_lock));
+
+	if (dest_dst) {
+		dest_dst->dst_cache = dst;
+		dest_dst->dst_cookie = dst_cookie;
+	}
+	rcu_assign_pointer(dest->dest_dst, dest_dst);
 
-	old_dst = dest->dst_cache;
-	dest->dst_cache = dst;
-	dest->dst_cookie = dst_cookie;
-	dst_release(old_dst);
+	if (old)
+		call_rcu(&old->rcu_head, ip_vs_dest_dst_rcu_free);
 }
 
-static inline struct dst_entry *
+static inline struct ip_vs_dest_dst *
 __ip_vs_dst_check(struct ip_vs_dest *dest)
 {
-	struct dst_entry *dst = dest->dst_cache;
+	struct ip_vs_dest_dst *dest_dst = rcu_dereference(dest->dest_dst);
+	struct dst_entry *dst;
 
-	if (!dst)
+	if (!dest_dst)
 		return NULL;
-	if (dst->obsolete && dst->ops->check(dst, dest->dst_cookie) == NULL) {
-		dest->dst_cache = NULL;
-		dst_release(dst);
+	dst = dest_dst->dst_cache;
+	if (dst->obsolete &&
+	    dst->ops->check(dst, dest_dst->dst_cookie) == NULL)
 		return NULL;
-	}
-	dst_hold(dst);
-	return dst;
+	return dest_dst;
 }
 
 static inline bool
@@ -144,35 +163,48 @@ __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct ip_vs_dest_dst *dest_dst;
 	struct rtable *rt;			/* Route to the other host */
 	struct rtable *ort;			/* Original route */
 	struct iphdr *iph;
 	__be16 df;
 	int mtu;
-	int local;
+	int local, noref = 1;
 
 	if (dest) {
-		spin_lock(&dest->dst_lock);
-		rt = (struct rtable *) __ip_vs_dst_check(dest);
-		if (!rt) {
+		dest_dst = __ip_vs_dst_check(dest);
+		if (likely(dest_dst))
+			rt = (struct rtable *) dest_dst->dst_cache;
+		else {
+			dest_dst = ip_vs_dest_dst_alloc();
+			spin_lock(&dest->dst_lock);
+			if (!dest_dst) {
+				__ip_vs_dst_set(dest, NULL, NULL, 0);
+				spin_unlock(&dest->dst_lock);
+				goto err_unreach;
+			}
 			rt = do_output_route4(net, dest->addr.ip, rt_mode,
-					      &dest->dst_saddr.ip);
+					      &dest_dst->dst_saddr.ip);
 			if (!rt) {
+				__ip_vs_dst_set(dest, NULL, NULL, 0);
 				spin_unlock(&dest->dst_lock);
+				ip_vs_dest_dst_free(dest_dst);
 				goto err_unreach;
 			}
-			__ip_vs_dst_set(dest, dst_clone(&rt->dst), 0);
+			__ip_vs_dst_set(dest, dest_dst, &rt->dst, 0);
+			spin_unlock(&dest->dst_lock);
 			IP_VS_DBG(10, "new dst %pI4, src %pI4, refcnt=%d\n",
-				  &dest->addr.ip, &dest->dst_saddr.ip,
+				  &dest->addr.ip, &dest_dst->dst_saddr.ip,
 				  atomic_read(&rt->dst.__refcnt));
 		}
 		daddr = dest->addr.ip;
 		if (ret_saddr)
-			*ret_saddr = dest->dst_saddr.ip;
-		spin_unlock(&dest->dst_lock);
+			*ret_saddr = dest_dst->dst_saddr.ip;
 	} else {
 		__be32 saddr = htonl(INADDR_ANY);
 
+		noref = 0;
+
 		/* For such unconfigured boxes avoid many route lookups
 		 * for performance reasons because we do not remember saddr
 		 */
@@ -211,7 +243,8 @@ __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 		}
 		if (rt_is_input_route(ort)) {
 			/* skb to local stack, preserve old route */
-			ip_rt_put(rt);
+			if (!noref)
+				ip_rt_put(rt);
 			return local;
 		}
 	}
@@ -240,12 +273,19 @@ __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 	}
 
 	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->dst);
+	if (noref) {
+		if (!local)
+			skb_dst_set_unref(skb, &rt->dst);
+		else
+			skb_dst_set(skb, dst_clone(&rt->dst));
+	} else
+		skb_dst_set(skb, &rt->dst);
 
 	return local;
 
 err_put:
-	ip_rt_put(rt);
+	if (!noref)
+		ip_rt_put(rt);
 	return -1;
 
 err_unreach:
@@ -303,36 +343,48 @@ __ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_dest *dest,
 		      struct ip_vs_iphdr *ipvsh, int do_xfrm, int rt_mode)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
+	struct ip_vs_dest_dst *dest_dst;
 	struct rt6_info *rt;			/* Route to the other host */
 	struct rt6_info *ort;			/* Original route */
 	struct dst_entry *dst;
 	int mtu;
-	int local;
+	int local, noref = 1;
 
 	if (dest) {
-		spin_lock(&dest->dst_lock);
-		rt = (struct rt6_info *)__ip_vs_dst_check(dest);
-		if (!rt) {
+		dest_dst = __ip_vs_dst_check(dest);
+		if (likely(dest_dst))
+			rt = (struct rt6_info *) dest_dst->dst_cache;
+		else {
 			u32 cookie;
 
+			dest_dst = ip_vs_dest_dst_alloc();
+			spin_lock(&dest->dst_lock);
+			if (!dest_dst) {
+				__ip_vs_dst_set(dest, NULL, NULL, 0);
+				spin_unlock(&dest->dst_lock);
+				goto err_unreach;
+			}
 			dst = __ip_vs_route_output_v6(net, &dest->addr.in6,
-						      &dest->dst_saddr.in6,
+						      &dest_dst->dst_saddr.in6,
 						      do_xfrm);
 			if (!dst) {
+				__ip_vs_dst_set(dest, NULL, NULL, 0);
 				spin_unlock(&dest->dst_lock);
+				ip_vs_dest_dst_free(dest_dst);
 				goto err_unreach;
 			}
 			rt = (struct rt6_info *) dst;
 			cookie = rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
-			__ip_vs_dst_set(dest, dst_clone(&rt->dst), cookie);
+			__ip_vs_dst_set(dest, dest_dst, &rt->dst, cookie);
+			spin_unlock(&dest->dst_lock);
 			IP_VS_DBG(10, "new dst %pI6, src %pI6, refcnt=%d\n",
-				  &dest->addr.in6, &dest->dst_saddr.in6,
+				  &dest->addr.in6, &dest_dst->dst_saddr.in6,
 				  atomic_read(&rt->dst.__refcnt));
 		}
 		if (ret_saddr)
-			*ret_saddr = dest->dst_saddr.in6;
-		spin_unlock(&dest->dst_lock);
+			*ret_saddr = dest_dst->dst_saddr.in6;
 	} else {
+		noref = 0;
 		dst = __ip_vs_route_output_v6(net, daddr, ret_saddr, do_xfrm);
 		if (!dst)
 			goto err_unreach;
@@ -368,7 +420,8 @@ __ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_dest *dest,
 		}
 		if (skb->dev) {
 			/* skb to local stack, preserve old route */
-			dst_release(&rt->dst);
+			if (!noref)
+				dst_release(&rt->dst);
 			return local;
 		}
 	}
@@ -399,12 +452,19 @@ __ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_dest *dest,
 	}
 
 	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->dst);
+	if (noref) {
+		if (!local)
+			skb_dst_set_unref(skb, &rt->dst);
+		else
+			skb_dst_set(skb, dst_clone(&rt->dst));
+	} else
+		skb_dst_set(skb, &rt->dst);
 
 	return local;
 
 err_put:
-	dst_release(&rt->dst);
+	if (!noref)
+		dst_release(&rt->dst);
 	return -1;
 
 err_unreach:
@@ -494,6 +554,7 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	EnterFunction(10);
 
+	rcu_read_lock();
 	if (__ip_vs_get_out_rt(skb, NULL, iph->daddr, IP_VS_RT_MODE_NON_LOCAL,
 			       NULL) < 0)
 		goto tx_error;
@@ -504,12 +565,14 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	skb->local_df = 1;
 
 	ip_vs_send_or_cont(NFPROTO_IPV4, skb, cp, 0);
+	rcu_read_unlock();
 
 	LeaveFunction(10);
 	return NF_STOLEN;
 
  tx_error:
 	kfree_skb(skb);
+	rcu_read_unlock();
 	LeaveFunction(10);
 	return NF_STOLEN;
 }
@@ -521,6 +584,7 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 {
 	EnterFunction(10);
 
+	rcu_read_lock();
 	if (__ip_vs_get_out_rt_v6(skb, NULL, &ipvsh->daddr.in6, NULL,
 				  ipvsh, 0, IP_VS_RT_MODE_NON_LOCAL) < 0)
 		goto tx_error;
@@ -529,12 +593,14 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	skb->local_df = 1;
 
 	ip_vs_send_or_cont(NFPROTO_IPV6, skb, cp, 0);
+	rcu_read_unlock();
 
 	LeaveFunction(10);
 	return NF_STOLEN;
 
  tx_error:
 	kfree_skb(skb);
+	rcu_read_unlock();
 	LeaveFunction(10);
 	return NF_STOLEN;
 }
@@ -553,6 +619,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	EnterFunction(10);
 
+	rcu_read_lock();
 	/* check if it is a connection of no-client-port */
 	if (unlikely(cp->flags & IP_VS_CONN_F_NO_CPORT)) {
 		__be16 _pt, *p;
@@ -620,12 +687,14 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	skb->local_df = 1;
 
 	rc = ip_vs_nat_send_or_cont(NFPROTO_IPV4, skb, cp, local);
+	rcu_read_unlock();
 
 	LeaveFunction(10);
 	return rc;
 
   tx_error:
 	kfree_skb(skb);
+	rcu_read_unlock();
 	LeaveFunction(10);
 	return NF_STOLEN;
 }
@@ -640,6 +709,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	EnterFunction(10);
 
+	rcu_read_lock();
 	/* check if it is a connection of no-client-port */
 	if (unlikely(cp->flags & IP_VS_CONN_F_NO_CPORT && !ipvsh->fragoffs)) {
 		__be16 _pt, *p;
@@ -707,6 +777,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	skb->local_df = 1;
 
 	rc = ip_vs_nat_send_or_cont(NFPROTO_IPV6, skb, cp, local);
+	rcu_read_unlock();
 
 	LeaveFunction(10);
 	return rc;
@@ -714,6 +785,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 tx_error:
 	LeaveFunction(10);
 	kfree_skb(skb);
+	rcu_read_unlock();
 	return NF_STOLEN;
 }
 #endif
@@ -755,6 +827,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	EnterFunction(10);
 
+	rcu_read_lock();
 	local = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
@@ -762,8 +835,10 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 				   IP_VS_RT_MODE_TUNNEL, &saddr);
 	if (local < 0)
 		goto tx_error;
-	if (local)
+	if (local) {
+		rcu_read_unlock();
 		return ip_vs_send_or_cont(NFPROTO_IPV4, skb, cp, 1);
+	}
 
 	rt = skb_rtable(skb);
 	tdev = rt->dst.dev;
@@ -818,6 +893,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		ip_local_out(skb);
 	else if (ret == NF_DROP)
 		kfree_skb(skb);
+	rcu_read_unlock();
 
 	LeaveFunction(10);
 
@@ -825,6 +901,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
   tx_error:
 	kfree_skb(skb);
+	rcu_read_unlock();
 	LeaveFunction(10);
 	return NF_STOLEN;
 }
@@ -844,6 +921,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	EnterFunction(10);
 
+	rcu_read_lock();
 	local = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6,
 				      &saddr, ipvsh, 1,
 				      IP_VS_RT_MODE_LOCAL |
@@ -851,8 +929,10 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 				      IP_VS_RT_MODE_TUNNEL);
 	if (local < 0)
 		goto tx_error;
-	if (local)
+	if (local) {
+		rcu_read_unlock();
 		return ip_vs_send_or_cont(NFPROTO_IPV6, skb, cp, 1);
+	}
 
 	rt = (struct rt6_info *) skb_dst(skb);
 	tdev = rt->dst.dev;
@@ -901,6 +981,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		ip6_local_out(skb);
 	else if (ret == NF_DROP)
 		kfree_skb(skb);
+	rcu_read_unlock();
 
 	LeaveFunction(10);
 
@@ -908,6 +989,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 tx_error:
 	kfree_skb(skb);
+	rcu_read_unlock();
 	LeaveFunction(10);
 	return NF_STOLEN;
 }
@@ -926,14 +1008,17 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	EnterFunction(10);
 
+	rcu_read_lock();
 	local = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
 				   IP_VS_RT_MODE_KNOWN_NH, NULL);
 	if (local < 0)
 		goto tx_error;
-	if (local)
+	if (local) {
+		rcu_read_unlock();
 		return ip_vs_send_or_cont(NFPROTO_IPV4, skb, cp, 1);
+	}
 
 	ip_send_check(ip_hdr(skb));
 
@@ -941,12 +1026,14 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	skb->local_df = 1;
 
 	ip_vs_send_or_cont(NFPROTO_IPV4, skb, cp, 0);
+	rcu_read_unlock();
 
 	LeaveFunction(10);
 	return NF_STOLEN;
 
   tx_error:
 	kfree_skb(skb);
+	rcu_read_unlock();
 	LeaveFunction(10);
 	return NF_STOLEN;
 }
@@ -960,25 +1047,30 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	EnterFunction(10);
 
+	rcu_read_lock();
 	local = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
 				      ipvsh, 0,
 				      IP_VS_RT_MODE_LOCAL |
 				      IP_VS_RT_MODE_NON_LOCAL);
 	if (local < 0)
 		goto tx_error;
-	if (local)
+	if (local) {
+		rcu_read_unlock();
 		return ip_vs_send_or_cont(NFPROTO_IPV6, skb, cp, 1);
+	}
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
 	ip_vs_send_or_cont(NFPROTO_IPV6, skb, cp, 0);
+	rcu_read_unlock();
 
 	LeaveFunction(10);
 	return NF_STOLEN;
 
 tx_error:
 	kfree_skb(skb);
+	rcu_read_unlock();
 	LeaveFunction(10);
 	return NF_STOLEN;
 }
@@ -1023,6 +1115,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	rt_mode = (hooknum != NF_INET_FORWARD) ?
 		  IP_VS_RT_MODE_LOCAL | IP_VS_RT_MODE_NON_LOCAL |
 		  IP_VS_RT_MODE_RDR : IP_VS_RT_MODE_NON_LOCAL;
+	rcu_read_lock();
 	local = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip, rt_mode, NULL);
 	if (local < 0)
 		goto tx_error;
@@ -1067,10 +1160,12 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	skb->local_df = 1;
 
 	rc = ip_vs_nat_send_or_cont(NFPROTO_IPV4, skb, cp, local);
+	rcu_read_unlock();
 	goto out;
 
   tx_error:
-	dev_kfree_skb(skb);
+	kfree_skb(skb);
+	rcu_read_unlock();
 	rc = NF_STOLEN;
   out:
 	LeaveFunction(10);
@@ -1111,6 +1206,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	rt_mode = (hooknum != NF_INET_FORWARD) ?
 		  IP_VS_RT_MODE_LOCAL | IP_VS_RT_MODE_NON_LOCAL |
 		  IP_VS_RT_MODE_RDR : IP_VS_RT_MODE_NON_LOCAL;
+	rcu_read_lock();
 	local = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
 				      ipvsh, 0, rt_mode);
 	if (local < 0)
@@ -1156,10 +1252,12 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	skb->local_df = 1;
 
 	rc = ip_vs_nat_send_or_cont(NFPROTO_IPV6, skb, cp, local);
+	rcu_read_unlock();
 	goto out;
 
 tx_error:
-	dev_kfree_skb(skb);
+	kfree_skb(skb);
+	rcu_read_unlock();
 	rc = NF_STOLEN;
 out:
 	LeaveFunction(10);
-- 
1.7.3.4
