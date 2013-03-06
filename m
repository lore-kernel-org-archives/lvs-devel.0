From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 06/12] ipvs: optimize dst usage for real server
Date: Wed,  6 Mar 2013 10:42:16 +0200
Message-ID: <1362559342-18784-7-git-send-email-ja@ssi.bg>
References: <1362559342-18784-1-git-send-email-ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1362559342-18784-1-git-send-email-ja@ssi.bg>
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
dsts will be invoked after the grace period. NAT-ed packets
via loopback that are not sent but are passed to local stack
with NF_ACCEPT need a dst clone (skb_dst_force).

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h             |   12 +-
 net/netfilter/ipvs/ip_vs_core.c |   11 +-
 net/netfilter/ipvs/ip_vs_ctl.c  |   24 ++-
 net/netfilter/ipvs/ip_vs_xmit.c |  366 ++++++++++++++++++++++++++-------------
 4 files changed, 275 insertions(+), 138 deletions(-)

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
index 6448a2e..439a67f 100644
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
@@ -53,34 +55,51 @@ enum {
 	IP_VS_RT_MODE_KNOWN_NH	= 16,/* Route via remote addr */
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
 
-	old_dst = dest->dst_cache;
-	dest->dst_cache = dst;
-	dest->dst_cookie = dst_cookie;
-	dst_release(old_dst);
+	if (dest_dst) {
+		dest_dst->dst_cache = dst;
+		dest_dst->dst_cookie = dst_cookie;
+	}
+	rcu_assign_pointer(dest->dest_dst, dest_dst);
+
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
@@ -136,35 +155,48 @@ retry:
 	return rt;
 }
 
-/* Get route to destination or remote server */
-static struct rtable *
+/* Get route (refdst) to destination or remote server */
+static unsigned long
 __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 		   __be32 daddr, int rt_mode, __be32 *ret_saddr)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
+	struct ip_vs_dest_dst *dest_dst;
 	struct rtable *rt;			/* Route to the other host */
 	struct rtable *ort;			/* Original route */
+	unsigned long refdst;
 	int local;
 
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
+				return 0;
+			}
 			rt = do_output_route4(net, dest->addr.ip, rt_mode,
-					      &dest->dst_saddr.ip);
+					      &dest_dst->dst_saddr.ip);
 			if (!rt) {
+				__ip_vs_dst_set(dest, NULL, NULL, 0);
 				spin_unlock(&dest->dst_lock);
-				return NULL;
+				ip_vs_dest_dst_free(dest_dst);
+				return 0;
 			}
-			__ip_vs_dst_set(dest, dst_clone(&rt->dst), 0);
+			__ip_vs_dst_set(dest, dest_dst, &rt->dst, 0);
+			spin_unlock(&dest->dst_lock);
 			IP_VS_DBG(10, "new dst %pI4, src %pI4, refcnt=%d\n",
-				  &dest->addr.ip, &dest->dst_saddr.ip,
+				  &dest->addr.ip, &dest_dst->dst_saddr.ip,
 				  atomic_read(&rt->dst.__refcnt));
 		}
+		refdst = (unsigned long) dst_get_noref(&rt->dst);
 		daddr = dest->addr.ip;
 		if (ret_saddr)
-			*ret_saddr = dest->dst_saddr.ip;
-		spin_unlock(&dest->dst_lock);
+			*ret_saddr = dest_dst->dst_saddr.ip;
 	} else {
 		__be32 saddr = htonl(INADDR_ANY);
 
@@ -174,7 +206,8 @@ __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 		rt_mode &= ~IP_VS_RT_MODE_CONNECT;
 		rt = do_output_route4(net, daddr, rt_mode, &saddr);
 		if (!rt)
-			return NULL;
+			return 0;
+		refdst = (unsigned long) &rt->dst;
 		if (ret_saddr)
 			*ret_saddr = saddr;
 	}
@@ -185,26 +218,26 @@ __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 		IP_VS_DBG_RL("Stopping traffic to %s address, dest: %pI4\n",
 			     (rt->rt_flags & RTCF_LOCAL) ?
 			     "local":"non-local", &daddr);
-		ip_rt_put(rt);
-		return NULL;
+		refdst_drop(refdst);
+		return 0;
 	}
 	if (local && !(rt_mode & IP_VS_RT_MODE_RDR) &&
 	    !((ort = skb_rtable(skb)) && ort->rt_flags & RTCF_LOCAL)) {
 		IP_VS_DBG_RL("Redirect from non-local address %pI4 to local "
 			     "requires NAT method, dest: %pI4\n",
 			     &ip_hdr(skb)->daddr, &daddr);
-		ip_rt_put(rt);
-		return NULL;
+		refdst_drop(refdst);
+		return 0;
 	}
 	if (unlikely(!local && ipv4_is_loopback(ip_hdr(skb)->saddr))) {
 		IP_VS_DBG_RL("Stopping traffic from loopback address %pI4 "
 			     "to non-local address, dest: %pI4\n",
 			     &ip_hdr(skb)->saddr, &daddr);
-		ip_rt_put(rt);
-		return NULL;
+		refdst_drop(refdst);
+		return 0;
 	}
 
-	return rt;
+	return refdst;
 }
 
 /* Reroute packet to local IPv4 stack after DNAT */
@@ -287,47 +320,61 @@ out_err:
 }
 
 /*
- * Get route to destination or remote server
+ * Get route (refdst) to destination or remote server
  */
-static struct rt6_info *
+static unsigned long
 __ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_dest *dest,
 		      struct in6_addr *daddr, struct in6_addr *ret_saddr,
 		      int do_xfrm, int rt_mode)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
+	struct ip_vs_dest_dst *dest_dst;
 	struct rt6_info *rt;			/* Route to the other host */
 	struct rt6_info *ort;			/* Original route */
+	unsigned long refdst;
 	struct dst_entry *dst;
 	int local;
 
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
+				return 0;
+			}
 			dst = __ip_vs_route_output_v6(net, &dest->addr.in6,
-						      &dest->dst_saddr.in6,
+						      &dest_dst->dst_saddr.in6,
 						      do_xfrm);
 			if (!dst) {
+				__ip_vs_dst_set(dest, NULL, NULL, 0);
 				spin_unlock(&dest->dst_lock);
-				return NULL;
+				ip_vs_dest_dst_free(dest_dst);
+				return 0;
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
+		refdst = (unsigned long) dst_get_noref(&rt->dst);
 		if (ret_saddr)
-			*ret_saddr = dest->dst_saddr.in6;
-		spin_unlock(&dest->dst_lock);
+			*ret_saddr = dest_dst->dst_saddr.in6;
 	} else {
 		dst = __ip_vs_route_output_v6(net, daddr, ret_saddr, do_xfrm);
 		if (!dst)
-			return NULL;
+			return 0;
 		rt = (struct rt6_info *) dst;
+		refdst = (unsigned long) dst;
 	}
 
 	local = __ip_vs_is_local_route6(rt);
@@ -335,8 +382,8 @@ __ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_dest *dest,
 	      rt_mode)) {
 		IP_VS_DBG_RL("Stopping traffic to %s address, dest: %pI6c\n",
 			     local ? "local":"non-local", daddr);
-		dst_release(&rt->dst);
-		return NULL;
+		refdst_drop(refdst);
+		return 0;
 	}
 	if (local && !(rt_mode & IP_VS_RT_MODE_RDR) &&
 	    !((ort = (struct rt6_info *) skb_dst(skb)) &&
@@ -344,8 +391,8 @@ __ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_dest *dest,
 		IP_VS_DBG_RL("Redirect from non-local address %pI6c to local "
 			     "requires NAT method, dest: %pI6c\n",
 			     &ipv6_hdr(skb)->daddr, daddr);
-		dst_release(&rt->dst);
-		return NULL;
+		refdst_drop(refdst);
+		return 0;
 	}
 	if (unlikely(!local && (!skb->dev || skb->dev->flags & IFF_LOOPBACK) &&
 		     ipv6_addr_type(&ipv6_hdr(skb)->saddr) &
@@ -353,11 +400,11 @@ __ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_dest *dest,
 		IP_VS_DBG_RL("Stopping traffic from loopback address %pI6c "
 			     "to non-local address, dest: %pI6c\n",
 			     &ipv6_hdr(skb)->saddr, daddr);
-		dst_release(&rt->dst);
-		return NULL;
+		refdst_drop(refdst);
+		return 0;
 	}
 
-	return rt;
+	return refdst;
 }
 #endif
 
@@ -438,22 +485,25 @@ int
 ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
-	struct rtable *rt;			/* Route to the other host */
+	struct dst_entry *dst;
+	unsigned long refdst;
 	struct iphdr  *iph = ip_hdr(skb);
 	int    mtu;
 
 	EnterFunction(10);
 
-	rt = __ip_vs_get_out_rt(skb, NULL, iph->daddr, IP_VS_RT_MODE_NON_LOCAL,
-				NULL);
-	if (!rt)
+	rcu_read_lock();
+	refdst = __ip_vs_get_out_rt(skb, NULL, iph->daddr,
+				    IP_VS_RT_MODE_NON_LOCAL, NULL);
+	if (!refdst)
 		goto tx_error_icmp;
+	dst = refdst_ptr(refdst);
 
 	/* MTU checking */
-	mtu = dst_mtu(&rt->dst);
+	mtu = dst_mtu(dst);
 	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF)) &&
 	    !skb_is_gso(skb)) {
-		ip_rt_put(rt);
+		refdst_drop(refdst);
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
 		goto tx_error;
@@ -464,19 +514,21 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	 * after ip_defrag. Is copy-on-write needed?
 	 */
 	if (unlikely((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)) {
-		ip_rt_put(rt);
+		refdst_drop(refdst);
+		rcu_read_unlock();
 		return NF_STOLEN;
 	}
 	ip_send_check(ip_hdr(skb));
 
 	/* drop old route */
 	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->dst);
+	skb_dst_set(skb, (struct dst_entry *) refdst);
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
 	ip_vs_send_or_cont(NFPROTO_IPV4, skb, cp, 0);
+	rcu_read_unlock();
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -484,6 +536,7 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
  tx_error_icmp:
 	dst_link_failure(skb);
  tx_error:
+	rcu_read_unlock();
 	kfree_skb(skb);
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -494,18 +547,21 @@ int
 ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph)
 {
-	struct rt6_info *rt;			/* Route to the other host */
+	struct dst_entry *dst;
+	unsigned long refdst;
 	int    mtu;
 
 	EnterFunction(10);
 
-	rt = __ip_vs_get_out_rt_v6(skb, NULL, &iph->daddr.in6, NULL, 0,
-				   IP_VS_RT_MODE_NON_LOCAL);
-	if (!rt)
+	rcu_read_lock();
+	refdst = __ip_vs_get_out_rt_v6(skb, NULL, &iph->daddr.in6, NULL, 0,
+				       IP_VS_RT_MODE_NON_LOCAL);
+	if (!refdst)
 		goto tx_error_icmp;
+	dst = refdst_ptr(refdst);
 
 	/* MTU checking */
-	mtu = dst_mtu(&rt->dst);
+	mtu = dst_mtu(dst);
 	if (__mtu_check_toobig_v6(skb, mtu)) {
 		if (!skb->dev) {
 			struct net *net = dev_net(skb_dst(skb)->dev);
@@ -515,7 +571,7 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		/* only send ICMP too big on first fragment */
 		if (!iph->fragoffs)
 			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
-		dst_release(&rt->dst);
+		refdst_drop(refdst);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
 		goto tx_error;
 	}
@@ -526,18 +582,20 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	 */
 	skb = skb_share_check(skb, GFP_ATOMIC);
 	if (unlikely(skb == NULL)) {
-		dst_release(&rt->dst);
+		refdst_drop(refdst);
+		rcu_read_unlock();
 		return NF_STOLEN;
 	}
 
 	/* drop old route */
 	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->dst);
+	skb_dst_set(skb, (struct dst_entry *) refdst);
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
 	ip_vs_send_or_cont(NFPROTO_IPV6, skb, cp, 0);
+	rcu_read_unlock();
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -545,6 +603,7 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
  tx_error_icmp:
 	dst_link_failure(skb);
  tx_error:
+	rcu_read_unlock();
 	kfree_skb(skb);
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -560,12 +619,14 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	       struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
 	struct rtable *rt;		/* Route to the other host */
+	unsigned long refdst;
 	int mtu;
 	struct iphdr *iph = ip_hdr(skb);
 	int local, rc;
 
 	EnterFunction(10);
 
+	rcu_read_lock();
 	/* check if it is a connection of no-client-port */
 	if (unlikely(cp->flags & IP_VS_CONN_F_NO_CPORT)) {
 		__be16 _pt, *p;
@@ -576,11 +637,13 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		IP_VS_DBG(10, "filled cport=%d\n", ntohs(*p));
 	}
 
-	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
-				      IP_VS_RT_MODE_LOCAL |
-				      IP_VS_RT_MODE_NON_LOCAL |
-				      IP_VS_RT_MODE_RDR, NULL)))
+	refdst = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
+				    IP_VS_RT_MODE_LOCAL |
+				    IP_VS_RT_MODE_NON_LOCAL |
+				    IP_VS_RT_MODE_RDR, NULL);
+	if (!refdst)
 		goto tx_error_icmp;
+	rt = (struct rtable *) refdst_ptr(refdst);
 	local = rt->rt_flags & RTCF_LOCAL;
 	/*
 	 * Avoid duplicate tuple in reply direction for NAT traffic
@@ -634,9 +697,9 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	if (!local) {
 		/* drop old route */
 		skb_dst_drop(skb);
-		skb_dst_set(skb, &rt->dst);
+		skb_dst_set(skb, (struct dst_entry *) refdst);
 	} else {
-		ip_rt_put(rt);
+		refdst_drop(refdst);
 		/*
 		 * Some IPv4 replies get local address from routes,
 		 * not from iph, so while we DNAT after routing
@@ -656,6 +719,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	skb->local_df = 1;
 
 	rc = ip_vs_nat_send_or_cont(NFPROTO_IPV4, skb, cp, local);
+	rcu_read_unlock();
 
 	LeaveFunction(10);
 	return rc;
@@ -663,11 +727,12 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
   tx_error_icmp:
 	dst_link_failure(skb);
   tx_error:
+	rcu_read_unlock();
 	kfree_skb(skb);
 	LeaveFunction(10);
 	return NF_STOLEN;
   tx_error_put:
-	ip_rt_put(rt);
+	refdst_drop(refdst);
 	goto tx_error;
 }
 
@@ -677,11 +742,13 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph)
 {
 	struct rt6_info *rt;		/* Route to the other host */
+	unsigned long refdst;
 	int mtu;
 	int local, rc;
 
 	EnterFunction(10);
 
+	rcu_read_lock();
 	/* check if it is a connection of no-client-port */
 	if (unlikely(cp->flags & IP_VS_CONN_F_NO_CPORT && !iph->fragoffs)) {
 		__be16 _pt, *p;
@@ -692,11 +759,13 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		IP_VS_DBG(10, "filled cport=%d\n", ntohs(*p));
 	}
 
-	if (!(rt = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
-					 0, (IP_VS_RT_MODE_LOCAL |
-					     IP_VS_RT_MODE_NON_LOCAL |
-					     IP_VS_RT_MODE_RDR))))
+	refdst = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
+				       0, (IP_VS_RT_MODE_LOCAL |
+				       IP_VS_RT_MODE_NON_LOCAL |
+				       IP_VS_RT_MODE_RDR));
+	if (!refdst)
 		goto tx_error_icmp;
+	rt = (struct rt6_info *) refdst_ptr(refdst);
 	local = __ip_vs_is_local_route6(rt);
 	/*
 	 * Avoid duplicate tuple in reply direction for NAT traffic
@@ -756,10 +825,12 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	if (!local || !skb->dev) {
 		/* drop the old route when skb is not shared */
 		skb_dst_drop(skb);
-		skb_dst_set(skb, &rt->dst);
+		skb_dst_set(skb, (struct dst_entry *) refdst);
+		if (local)
+			skb_dst_force(skb);
 	} else {
 		/* destined to loopback, do we need to change route? */
-		dst_release(&rt->dst);
+		refdst_drop(refdst);
 	}
 
 	IP_VS_DBG_PKT(10, AF_INET6, pp, skb, 0, "After DNAT");
@@ -772,6 +843,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	skb->local_df = 1;
 
 	rc = ip_vs_nat_send_or_cont(NFPROTO_IPV6, skb, cp, local);
+	rcu_read_unlock();
 
 	LeaveFunction(10);
 	return rc;
@@ -779,11 +851,12 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 tx_error_icmp:
 	dst_link_failure(skb);
 tx_error:
+	rcu_read_unlock();
 	LeaveFunction(10);
 	kfree_skb(skb);
 	return NF_STOLEN;
 tx_error_put:
-	dst_release(&rt->dst);
+	refdst_drop(refdst);
 	goto tx_error;
 }
 #endif
@@ -814,6 +887,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 {
 	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
 	struct rtable *rt;			/* Route to the other host */
+	unsigned long refdst;
 	__be32 saddr;				/* Source for tunnel */
 	struct net_device *tdev;		/* Device to other host */
 	struct iphdr  *old_iph = ip_hdr(skb);
@@ -826,13 +900,17 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	EnterFunction(10);
 
-	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
-				      IP_VS_RT_MODE_LOCAL |
-				      IP_VS_RT_MODE_NON_LOCAL |
-				      IP_VS_RT_MODE_CONNECT, &saddr)))
+	rcu_read_lock();
+	refdst = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
+				    IP_VS_RT_MODE_LOCAL |
+				    IP_VS_RT_MODE_NON_LOCAL |
+				    IP_VS_RT_MODE_CONNECT, &saddr);
+	if (!refdst)
 		goto tx_error_icmp;
+	rt = (struct rtable *) refdst_ptr(refdst);
 	if (rt->rt_flags & RTCF_LOCAL) {
-		ip_rt_put(rt);
+		refdst_drop(refdst);
+		rcu_read_unlock();
 		return ip_vs_send_or_cont(NFPROTO_IPV4, skb, cp, 1);
 	}
 
@@ -865,7 +943,8 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		struct sk_buff *new_skb =
 			skb_realloc_headroom(skb, max_headroom);
 		if (!new_skb) {
-			ip_rt_put(rt);
+			refdst_drop(refdst);
+			rcu_read_unlock();
 			kfree_skb(skb);
 			IP_VS_ERR_RL("%s(): no memory\n", __func__);
 			return NF_STOLEN;
@@ -886,7 +965,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* drop old route */
 	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->dst);
+	skb_dst_set(skb, (struct dst_entry *) refdst);
 
 	/*
 	 *	Push down and install the IPIP header.
@@ -910,6 +989,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		ip_local_out(skb);
 	else if (ret == NF_DROP)
 		kfree_skb(skb);
+	rcu_read_unlock();
 
 	LeaveFunction(10);
 
@@ -918,11 +998,12 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
   tx_error_icmp:
 	dst_link_failure(skb);
   tx_error:
+	rcu_read_unlock();
 	kfree_skb(skb);
 	LeaveFunction(10);
 	return NF_STOLEN;
 tx_error_put:
-	ip_rt_put(rt);
+	refdst_drop(refdst);
 	goto tx_error;
 }
 
@@ -932,6 +1013,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
 	struct rt6_info *rt;		/* Route to the other host */
+	unsigned long refdst;
 	struct in6_addr saddr;		/* Source for tunnel */
 	struct net_device *tdev;	/* Device to other host */
 	struct ipv6hdr  *old_iph = ipv6_hdr(skb);
@@ -942,12 +1024,16 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	EnterFunction(10);
 
-	if (!(rt = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6,
-					 &saddr, 1, (IP_VS_RT_MODE_LOCAL |
-						     IP_VS_RT_MODE_NON_LOCAL))))
+	rcu_read_lock();
+	refdst = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6,
+				       &saddr, 1, (IP_VS_RT_MODE_LOCAL |
+				       IP_VS_RT_MODE_NON_LOCAL));
+	if (!refdst)
 		goto tx_error_icmp;
+	rt = (struct rt6_info *) refdst_ptr(refdst);
 	if (__ip_vs_is_local_route6(rt)) {
-		dst_release(&rt->dst);
+		refdst_drop(refdst);
+		rcu_read_unlock();
 		return ip_vs_send_or_cont(NFPROTO_IPV6, skb, cp, 1);
 	}
 
@@ -986,7 +1072,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		struct sk_buff *new_skb =
 			skb_realloc_headroom(skb, max_headroom);
 		if (!new_skb) {
-			dst_release(&rt->dst);
+			refdst_drop(refdst);
+			rcu_read_unlock();
 			kfree_skb(skb);
 			IP_VS_ERR_RL("%s(): no memory\n", __func__);
 			return NF_STOLEN;
@@ -1004,7 +1091,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* drop old route */
 	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->dst);
+	skb_dst_set(skb, (struct dst_entry *) refdst);
 
 	/*
 	 *	Push down and install the IPIP header.
@@ -1028,6 +1115,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		ip6_local_out(skb);
 	else if (ret == NF_DROP)
 		kfree_skb(skb);
+	rcu_read_unlock();
 
 	LeaveFunction(10);
 
@@ -1036,11 +1124,12 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 tx_error_icmp:
 	dst_link_failure(skb);
 tx_error:
+	rcu_read_unlock();
 	kfree_skb(skb);
 	LeaveFunction(10);
 	return NF_STOLEN;
 tx_error_put:
-	dst_release(&rt->dst);
+	refdst_drop(refdst);
 	goto tx_error;
 }
 #endif
@@ -1055,18 +1144,23 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	      struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
 	struct rtable *rt;			/* Route to the other host */
+	unsigned long refdst;
 	struct iphdr  *iph = ip_hdr(skb);
 	int    mtu;
 
 	EnterFunction(10);
 
-	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
-				      IP_VS_RT_MODE_LOCAL |
-				      IP_VS_RT_MODE_NON_LOCAL |
-				      IP_VS_RT_MODE_KNOWN_NH, NULL)))
+	rcu_read_lock();
+	refdst = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
+				    IP_VS_RT_MODE_LOCAL |
+				    IP_VS_RT_MODE_NON_LOCAL |
+				    IP_VS_RT_MODE_KNOWN_NH, NULL);
+	if (!refdst)
 		goto tx_error_icmp;
+	rt = (struct rtable *) refdst_ptr(refdst);
 	if (rt->rt_flags & RTCF_LOCAL) {
-		ip_rt_put(rt);
+		refdst_drop(refdst);
+		rcu_read_unlock();
 		return ip_vs_send_or_cont(NFPROTO_IPV4, skb, cp, 1);
 	}
 
@@ -1075,7 +1169,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	if ((iph->frag_off & htons(IP_DF)) && skb->len > mtu &&
 	    !skb_is_gso(skb)) {
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
-		ip_rt_put(rt);
+		refdst_drop(refdst);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
 		goto tx_error;
 	}
@@ -1085,19 +1179,21 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	 * after ip_defrag. Is copy-on-write needed?
 	 */
 	if (unlikely((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)) {
-		ip_rt_put(rt);
+		refdst_drop(refdst);
+		rcu_read_unlock();
 		return NF_STOLEN;
 	}
 	ip_send_check(ip_hdr(skb));
 
 	/* drop old route */
 	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->dst);
+	skb_dst_set(skb, (struct dst_entry *) refdst);
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
 	ip_vs_send_or_cont(NFPROTO_IPV4, skb, cp, 0);
+	rcu_read_unlock();
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -1105,6 +1201,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
   tx_error_icmp:
 	dst_link_failure(skb);
   tx_error:
+	rcu_read_unlock();
 	kfree_skb(skb);
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -1116,16 +1213,21 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		 struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph)
 {
 	struct rt6_info *rt;			/* Route to the other host */
+	unsigned long refdst;
 	int    mtu;
 
 	EnterFunction(10);
 
-	if (!(rt = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
-					 0, (IP_VS_RT_MODE_LOCAL |
-					     IP_VS_RT_MODE_NON_LOCAL))))
+	rcu_read_lock();
+	refdst = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
+				       0, (IP_VS_RT_MODE_LOCAL |
+				       IP_VS_RT_MODE_NON_LOCAL));
+	if (!refdst)
 		goto tx_error_icmp;
+	rt = (struct rt6_info *) refdst_ptr(refdst);
 	if (__ip_vs_is_local_route6(rt)) {
-		dst_release(&rt->dst);
+		refdst_drop(refdst);
+		rcu_read_unlock();
 		return ip_vs_send_or_cont(NFPROTO_IPV6, skb, cp, 1);
 	}
 
@@ -1140,7 +1242,7 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		/* only send ICMP too big on first fragment */
 		if (!iph->fragoffs)
 			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
-		dst_release(&rt->dst);
+		refdst_drop(refdst);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
 		goto tx_error;
 	}
@@ -1151,18 +1253,20 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	 */
 	skb = skb_share_check(skb, GFP_ATOMIC);
 	if (unlikely(skb == NULL)) {
-		dst_release(&rt->dst);
+		refdst_drop(refdst);
+		rcu_read_unlock();
 		return NF_STOLEN;
 	}
 
 	/* drop old route */
 	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->dst);
+	skb_dst_set(skb, (struct dst_entry *) refdst);
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
 	ip_vs_send_or_cont(NFPROTO_IPV6, skb, cp, 0);
+	rcu_read_unlock();
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -1170,6 +1274,7 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 tx_error_icmp:
 	dst_link_failure(skb);
 tx_error:
+	rcu_read_unlock();
 	kfree_skb(skb);
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -1187,6 +1292,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		struct ip_vs_iphdr *iph)
 {
 	struct rtable	*rt;	/* Route to the other host */
+	unsigned long refdst;
 	int mtu;
 	int rc;
 	int local;
@@ -1215,9 +1321,12 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	rt_mode = (hooknum != NF_INET_FORWARD) ?
 		  IP_VS_RT_MODE_LOCAL | IP_VS_RT_MODE_NON_LOCAL |
 		  IP_VS_RT_MODE_RDR : IP_VS_RT_MODE_NON_LOCAL;
-	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
-				      rt_mode, NULL)))
+	rcu_read_lock();
+	refdst = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip, rt_mode,
+				    NULL);
+	if (!refdst)
 		goto tx_error_icmp;
+	rt = (struct rtable *) refdst_ptr(refdst);
 	local = rt->rt_flags & RTCF_LOCAL;
 
 	/*
@@ -1268,9 +1377,9 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	if (!local) {
 		/* drop the old route when skb is not shared */
 		skb_dst_drop(skb);
-		skb_dst_set(skb, &rt->dst);
+		skb_dst_set(skb, (struct dst_entry *) refdst);
 	} else {
-		ip_rt_put(rt);
+		refdst_drop(refdst);
 		/*
 		 * Some IPv4 replies get local address from routes,
 		 * not from iph, so while we DNAT after routing
@@ -1284,18 +1393,20 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	skb->local_df = 1;
 
 	rc = ip_vs_nat_send_or_cont(NFPROTO_IPV4, skb, cp, local);
+	rcu_read_unlock();
 	goto out;
 
   tx_error_icmp:
 	dst_link_failure(skb);
   tx_error:
+	rcu_read_unlock();
 	dev_kfree_skb(skb);
 	rc = NF_STOLEN;
   out:
 	LeaveFunction(10);
 	return rc;
   tx_error_put:
-	ip_rt_put(rt);
+	refdst_drop(refdst);
 	goto tx_error;
 }
 
@@ -1306,6 +1417,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		struct ip_vs_iphdr *iph)
 {
 	struct rt6_info	*rt;	/* Route to the other host */
+	unsigned long refdst;
 	int mtu;
 	int rc;
 	int local;
@@ -1334,10 +1446,12 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	rt_mode = (hooknum != NF_INET_FORWARD) ?
 		  IP_VS_RT_MODE_LOCAL | IP_VS_RT_MODE_NON_LOCAL |
 		  IP_VS_RT_MODE_RDR : IP_VS_RT_MODE_NON_LOCAL;
-	if (!(rt = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
-					 0, rt_mode)))
+	rcu_read_lock();
+	refdst = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
+				       0, rt_mode);
+	if (!refdst)
 		goto tx_error_icmp;
-
+	rt = (struct rt6_info *) refdst_ptr(refdst);
 	local = __ip_vs_is_local_route6(rt);
 	/*
 	 * Avoid duplicate tuple in reply direction for NAT traffic
@@ -1393,28 +1507,32 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	if (!local || !skb->dev) {
 		/* drop the old route when skb is not shared */
 		skb_dst_drop(skb);
-		skb_dst_set(skb, &rt->dst);
+		skb_dst_set(skb, (struct dst_entry *) refdst);
+		if (local)
+			skb_dst_force(skb);
 	} else {
 		/* destined to loopback, do we need to change route? */
-		dst_release(&rt->dst);
+		refdst_drop(refdst);
 	}
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
 	rc = ip_vs_nat_send_or_cont(NFPROTO_IPV6, skb, cp, local);
+	rcu_read_unlock();
 	goto out;
 
 tx_error_icmp:
 	dst_link_failure(skb);
 tx_error:
+	rcu_read_unlock();
 	dev_kfree_skb(skb);
 	rc = NF_STOLEN;
 out:
 	LeaveFunction(10);
 	return rc;
 tx_error_put:
-	dst_release(&rt->dst);
+	refdst_drop(refdst);
 	goto tx_error;
 }
 #endif
-- 
1.7.3.4
