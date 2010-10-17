From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 09/12] ipvs: changes for local real server
Date: Sun, 17 Oct 2010 16:38:15 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010171635470.20665@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; format="flowed"; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


 	This patch deals with local real servers:

- Add support for DNAT to local address (different real server port).
It needs ip_vs_out hook in LOCAL_OUT for both families because
skb->protocol is not set for locally generated packets and can not
be used to set 'af'.

- Skip packets in ip_vs_in marked with skb->ipvs_property because
ip_vs_out processing can be executed in LOCAL_OUT but we still
have the conn_out_get check in ip_vs_in.

- Ignore packets with inet->nodefrag from local stack

- Require skb_dst(skb) != NULL because we use it to get struct net

- Add support for changing the route to local IPv4 stack after DNAT
depending on the source address type. Local client sets output
route and the remote client sets input route. It looks like
IPv6 does not need such rerouting because the replies use
addresses from initial incoming header, not from skb route.

- All transmitters now have strict checks for the destination
address type: redirect from non-local address to local real
server requires NAT method, local address can not be used as
source address when talking to remote real server.

- Now LOCALNODE is not set explicitly as forwarding
method in real server to allow the connections to provide
correct forwarding method to the backup server. Not sure if
this breaks tools that expect to see 'Local' real server type.
If needed, this can be supported with new flag IP_VS_DEST_F_LOCAL.
Now it should be possible connections in backup that lost
their fwmark information during sync to be forwarded properly
to their daddr, even if it is local address in the backup server.
By this way backup could be used as real server for DR or TUN,
for NAT there are some restrictions because tuple collisions
in conntracks can create problems for the traffic.

- Call ip_vs_dst_reset when destination is updated in case
some real server IP type is changed between local and remote.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp nf-next-2.6-a91fd26/linux/include/net/ip_vs.h linux/include/net/ip_vs.h
--- nf-next-2.6-a91fd26/linux/include/net/ip_vs.h	2010-10-16 19:34:46.428355263 +0300
+++ linux/include/net/ip_vs.h	2010-10-16 19:35:04.718355828 +0300
@@ -409,6 +409,7 @@ struct ip_vs_conn {
  	/* packet transmitter for different forwarding methods.  If it
  	   mangles the packet, it must return NF_DROP or better NF_STOLEN,
  	   otherwise this must be changed to a sk_buff **.
+	   NF_ACCEPT can be returned when destination is local.
  	 */
  	int (*packet_xmit)(struct sk_buff *skb, struct ip_vs_conn *cp,
  			   struct ip_vs_protocol *pp);
diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_core.c linux/net/netfilter/ipvs/ip_vs_core.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_core.c	2010-10-16 17:51:57.252355662 +0300
+++ linux/net/netfilter/ipvs/ip_vs_core.c	2010-10-17 00:56:09.784869091 +0300
@@ -984,26 +984,34 @@ drop:
  }

  /*
- *	It is hooked at the NF_INET_FORWARD chain, used only for VS/NAT.
   *	Check if outgoing packet belongs to the established ip_vs_conn.
   */
  static unsigned int
-ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
-	  const struct net_device *in, const struct net_device *out,
-	  int (*okfn)(struct sk_buff *))
+ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
  {
  	struct ip_vs_iphdr iph;
  	struct ip_vs_protocol *pp;
  	struct ip_vs_conn *cp;
-	int af;

  	EnterFunction(11);

-	af = (skb->protocol == htons(ETH_P_IP)) ? AF_INET : AF_INET6;
-
+	/* Already marked as IPVS request or reply? */
  	if (skb->ipvs_property)
  		return NF_ACCEPT;

+	/* Bad... Do not break raw sockets */
+	if (unlikely(skb->sk != NULL && hooknum == NF_INET_LOCAL_OUT &&
+		     af == AF_INET)) {
+		struct sock *sk = skb->sk;
+		struct inet_sock *inet = inet_sk(skb->sk);
+ 
+		if (inet && sk->sk_family == PF_INET && inet->nodefrag)
+			return NF_ACCEPT;
+	}
+
+	if (unlikely(!skb_dst(skb)))
+		return NF_ACCEPT;
+
  	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
  #ifdef CONFIG_IP_VS_IPV6
  	if (af == AF_INET6) {
@@ -1106,6 +1114,69 @@ ip_vs_out(unsigned int hooknum, struct s
  	return handle_response(af, skb, pp, cp, iph.len);
  }

+/*
+ *	It is hooked at the NF_INET_FORWARD chain, used only for VS/NAT.
+ *	Check if packet is reply for established ip_vs_conn.
+ */
+static unsigned int
+ip_vs_reply4(unsigned int hooknum, struct sk_buff *skb,
+	     const struct net_device *in, const struct net_device *out,
+	     int (*okfn)(struct sk_buff *))
+{
+	return ip_vs_out(hooknum, skb, AF_INET);
+}
+
+/*
+ *	It is hooked at the NF_INET_LOCAL_OUT chain, used only for VS/NAT.
+ *	Check if packet is reply for established ip_vs_conn.
+ */
+static unsigned int
+ip_vs_local_reply4(unsigned int hooknum, struct sk_buff *skb,
+		   const struct net_device *in, const struct net_device *out,
+		   int (*okfn)(struct sk_buff *))
+{
+	unsigned int verdict;
+
+	/* Disable BH in LOCAL_OUT until all places are fixed */
+	local_bh_disable();
+	verdict = ip_vs_out(hooknum, skb, AF_INET);
+	local_bh_enable();
+	return verdict;
+}
+
+#ifdef CONFIG_IP_VS_IPV6
+
+/*
+ *	It is hooked at the NF_INET_FORWARD chain, used only for VS/NAT.
+ *	Check if packet is reply for established ip_vs_conn.
+ */
+static unsigned int
+ip_vs_reply6(unsigned int hooknum, struct sk_buff *skb,
+	     const struct net_device *in, const struct net_device *out,
+	     int (*okfn)(struct sk_buff *))
+{
+	return ip_vs_out(hooknum, skb, AF_INET6);
+}
+
+/*
+ *	It is hooked at the NF_INET_LOCAL_OUT chain, used only for VS/NAT.
+ *	Check if packet is reply for established ip_vs_conn.
+ */
+static unsigned int
+ip_vs_local_reply6(unsigned int hooknum, struct sk_buff *skb,
+		   const struct net_device *in, const struct net_device *out,
+		   int (*okfn)(struct sk_buff *))
+{
+	unsigned int verdict;
+
+	/* Disable BH in LOCAL_OUT until all places are fixed */
+	local_bh_disable();
+	verdict = ip_vs_out(hooknum, skb, AF_INET6);
+	local_bh_enable();
+	return verdict;
+}
+
+#endif

  /*
   *	Handle ICMP messages in the outside-to-inside direction (incoming).
@@ -1342,6 +1413,10 @@ ip_vs_in(unsigned int hooknum, struct sk
  	struct ip_vs_conn *cp;
  	int ret, restart, af, pkts;

+	/* Already marked as IPVS request or reply? */
+	if (skb->ipvs_property)
+		return NF_ACCEPT;
+
  	af = (skb->protocol == htons(ETH_P_IP)) ? AF_INET : AF_INET6;

  	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
@@ -1525,13 +1600,13 @@ static struct nf_hook_ops ip_vs_ops[] __
  		.hooknum        = NF_INET_LOCAL_IN,
  		.priority       = 100,
  	},
-	/* After packet filtering, change source only for VS/NAT */
+	/* Before ip_vs_in, change source only for VS/NAT */
  	{
-		.hook		= ip_vs_out,
+		.hook		= ip_vs_local_reply4,
  		.owner		= THIS_MODULE,
  		.pf		= PF_INET,
-		.hooknum        = NF_INET_FORWARD,
-		.priority       = 100,
+		.hooknum	= NF_INET_LOCAL_OUT,
+		.priority	= -99,
  	},
  	/* After packet filtering (but before ip_vs_out_icmp), catch icmp
  	 * destined for 0.0.0.0/0, which is for incoming IPVS connections */
@@ -1542,6 +1617,14 @@ static struct nf_hook_ops ip_vs_ops[] __
  		.hooknum        = NF_INET_FORWARD,
  		.priority       = 99,
  	},
+	/* After packet filtering, change source only for VS/NAT */
+	{
+		.hook		= ip_vs_reply4,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET,
+		.hooknum	= NF_INET_FORWARD,
+		.priority	= 100,
+	},
  #ifdef CONFIG_IP_VS_IPV6
  	/* After packet filtering, forward packet through VS/DR, VS/TUN,
  	 * or VS/NAT(change destination), so that filtering rules can be
@@ -1553,13 +1636,13 @@ static struct nf_hook_ops ip_vs_ops[] __
  		.hooknum        = NF_INET_LOCAL_IN,
  		.priority       = 100,
  	},
-	/* After packet filtering, change source only for VS/NAT */
+	/* Before ip_vs_in, change source only for VS/NAT */
  	{
-		.hook		= ip_vs_out,
+		.hook		= ip_vs_local_reply6,
  		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
-		.hooknum        = NF_INET_FORWARD,
-		.priority       = 100,
+		.pf		= PF_INET,
+		.hooknum	= NF_INET_LOCAL_OUT,
+		.priority	= -99,
  	},
  	/* After packet filtering (but before ip_vs_out_icmp), catch icmp
  	 * destined for 0.0.0.0/0, which is for incoming IPVS connections */
@@ -1570,6 +1653,14 @@ static struct nf_hook_ops ip_vs_ops[] __
  		.hooknum        = NF_INET_FORWARD,
  		.priority       = 99,
  	},
+	/* After packet filtering, change source only for VS/NAT */
+	{
+		.hook		= ip_vs_reply6,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET6,
+		.hooknum	= NF_INET_FORWARD,
+		.priority	= 100,
+	},
  #endif
  };

diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_ctl.c linux/net/netfilter/ipvs/ip_vs_ctl.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_ctl.c	2010-10-13 22:22:35.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_ctl.c	2010-10-16 19:15:33.372354738 +0300
@@ -777,20 +777,6 @@ __ip_vs_update_dest(struct ip_vs_service
  	conn_flags = udest->conn_flags & IP_VS_CONN_F_DEST_MASK;
  	conn_flags |= IP_VS_CONN_F_INACTIVE;

-	/* check if local node and update the flags */
-#ifdef CONFIG_IP_VS_IPV6
-	if (svc->af == AF_INET6) {
-		if (__ip_vs_addr_is_local_v6(&udest->addr.in6)) {
-			conn_flags = (conn_flags & ~IP_VS_CONN_F_FWD_MASK)
-				| IP_VS_CONN_F_LOCALNODE;
-		}
-	} else
-#endif
-		if (inet_addr_type(&init_net, udest->addr.ip) == RTN_LOCAL) {
-			conn_flags = (conn_flags & ~IP_VS_CONN_F_FWD_MASK)
-				| IP_VS_CONN_F_LOCALNODE;
-		}
-
  	/* set the IP_VS_CONN_F_NOOUTPUT flag if not masquerading/NAT */
  	if ((conn_flags & IP_VS_CONN_F_FWD_MASK) != IP_VS_CONN_F_MASQ) {
  		conn_flags |= IP_VS_CONN_F_NOOUTPUT;
@@ -824,6 +810,10 @@ __ip_vs_update_dest(struct ip_vs_service
  	dest->u_threshold = udest->u_threshold;
  	dest->l_threshold = udest->l_threshold;

+	spin_lock(&dest->dst_lock);
+	ip_vs_dst_reset(dest);
+	spin_unlock(&dest->dst_lock);
+
  	if (add)
  		ip_vs_new_estimator(&dest->stats);

diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_xmit.c linux/net/netfilter/ipvs/ip_vs_xmit.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_xmit.c	2010-10-16 19:34:46.430353974 +0300
+++ linux/net/netfilter/ipvs/ip_vs_xmit.c	2010-10-16 19:55:45.862354986 +0300
@@ -67,12 +67,19 @@ __ip_vs_dst_check(struct ip_vs_dest *des
  	return dst;
  }

+/*
+ * Get route to destination or remote server
+ * rt_mode: flags, &1=Allow local dest, &2=Allow non-local dest,
+ *	    &4=Allow redirect from remote daddr to local
+ */
  static struct rtable *
-__ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_conn *cp, u32 rtos)
+__ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
+		   __be32 daddr, u32 rtos, int rt_mode)
  {
-	struct net *net = dev_net(skb->dev);
+	struct net *net = dev_net(skb_dst(skb)->dev);
  	struct rtable *rt;			/* Route to the other host */
-	struct ip_vs_dest *dest = cp->dest;
+	struct rtable *ort;			/* Original route */
+	int local;

  	if (dest) {
  		spin_lock(&dest->dst_lock);
@@ -104,23 +111,95 @@ __ip_vs_get_out_rt(struct sk_buff *skb,
  			.oif = 0,
  			.nl_u = {
  				.ip4_u = {
-					.daddr = cp->daddr.ip,
+					.daddr = daddr,
  					.saddr = 0,
  					.tos = rtos, } },
  		};

  		if (ip_route_output_key(net, &rt, &fl)) {
  			IP_VS_DBG_RL("ip_route_output error, dest: %pI4\n",
-				     &cp->daddr.ip);
+				     &daddr);
  			return NULL;
  		}
  	}

+	local = rt->rt_flags & RTCF_LOCAL;
+	if (!((local ? 1 : 2) & rt_mode)) {
+		IP_VS_DBG_RL("Stopping traffic to %s address, dest: %pI4\n",
+			     (rt->rt_flags & RTCF_LOCAL) ?
+			     "local":"non-local", &rt->rt_dst);
+		ip_rt_put(rt);
+		return NULL;
+	}
+	if (local && !(rt_mode & 4) && !((ort = skb_rtable(skb)) &&
+					 ort->rt_flags & RTCF_LOCAL)) {
+		IP_VS_DBG_RL("Redirect from non-local address %pI4 to local "
+			     "requires NAT method, dest: %pI4\n",
+			     &ip_hdr(skb)->daddr, &rt->rt_dst);
+		ip_rt_put(rt);
+		return NULL;
+	}
+	if (unlikely(!local && ipv4_is_loopback(ip_hdr(skb)->saddr))) {
+		IP_VS_DBG_RL("Stopping traffic from loopback address %pI4 "
+			     "to non-local address, dest: %pI4\n",
+			     &ip_hdr(skb)->saddr, &rt->rt_dst);
+		ip_rt_put(rt);
+		return NULL;
+	}
+
  	return rt;
  }

+/* Reroute packet to local IPv4 stack after DNAT */
+static int
+__ip_vs_reroute_locally(struct sk_buff *skb)
+{
+	struct rtable *rt = skb_rtable(skb);
+	struct net_device *dev = rt->dst.dev;
+	struct net *net = dev_net(dev);
+	struct iphdr *iph = ip_hdr(skb);
+
+	if (rt->fl.iif) {
+		unsigned long orefdst = skb->_skb_refdst;
+
+		if (ip_route_input(skb, iph->daddr, iph->saddr,
+				   iph->tos, skb->dev))
+			return 0;
+		refdst_drop(orefdst);
+	} else {
+		struct flowi fl = {
+			.oif = 0,
+			.nl_u = {
+				.ip4_u = {
+					.daddr = iph->daddr,
+					.saddr = iph->saddr,
+					.tos = RT_TOS(iph->tos),
+				}
+			},
+			.mark = skb->mark,
+		};
+		struct rtable *rt;
+
+		if (ip_route_output_key(net, &rt, &fl))
+			return 0;
+		if (!(rt->rt_flags & RTCF_LOCAL)) {
+			ip_rt_put(rt);
+			return 0;
+		}
+		/* Drop old route. */
+		skb_dst_drop(skb);
+		skb_dst_set(skb, &rt->dst);
+	}
+	return 1;
+}
+
  #ifdef CONFIG_IP_VS_IPV6

+static inline int __ip_vs_is_local_route6(struct rt6_info *rt)
+{
+	return rt->rt6i_dev && rt->rt6i_dev->flags & IFF_LOOPBACK;
+}
+
  static struct dst_entry *
  __ip_vs_route_output_v6(struct net *net, struct in6_addr *daddr,
  			struct in6_addr *ret_saddr, int do_xfrm)
@@ -155,14 +234,21 @@ out_err:
  	return NULL;
  }

+/*
+ * Get route to destination or remote server
+ * rt_mode: flags, &1=Allow local dest, &2=Allow non-local dest,
+ *	    &4=Allow redirect from remote daddr to local
+ */
  static struct rt6_info *
-__ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		      struct in6_addr *ret_saddr, int do_xfrm)
+__ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_dest *dest,
+		      struct in6_addr *daddr, struct in6_addr *ret_saddr,
+		      int do_xfrm, int rt_mode)
  {
-	struct net *net = dev_net(skb->dev);
+	struct net *net = dev_net(skb_dst(skb)->dev);
  	struct rt6_info *rt;			/* Route to the other host */
-	struct ip_vs_dest *dest = cp->dest;
+	struct rt6_info *ort;			/* Original route */
  	struct dst_entry *dst;
+	int local;

  	if (dest) {
  		spin_lock(&dest->dst_lock);
@@ -188,13 +274,38 @@ __ip_vs_get_out_rt_v6(struct sk_buff *sk
  			ipv6_addr_copy(ret_saddr, &dest->dst_saddr);
  		spin_unlock(&dest->dst_lock);
  	} else {
-		dst = __ip_vs_route_output_v6(net, &cp->daddr.in6, ret_saddr,
-					      do_xfrm);
+		dst = __ip_vs_route_output_v6(net, daddr, ret_saddr, do_xfrm);
  		if (!dst)
  			return NULL;
  		rt = (struct rt6_info *) dst;
  	}

+	local = __ip_vs_is_local_route6(rt);
+	if (!((local ? 1 : 2) & rt_mode)) {
+		IP_VS_DBG_RL("Stopping traffic to %s address, dest: %pI6\n",
+			     local ? "local":"non-local", daddr);
+		dst_release(&rt->dst);
+		return NULL;
+	}
+	if (local && !(rt_mode & 4) &&
+	    !((ort = (struct rt6_info *) skb_dst(skb)) &&
+	      __ip_vs_is_local_route6(ort))) {
+		IP_VS_DBG_RL("Redirect from non-local address %pI6 to local "
+			     "requires NAT method, dest: %pI6\n",
+			     &ipv6_hdr(skb)->daddr, daddr);
+		dst_release(&rt->dst);
+		return NULL;
+	}
+	if (unlikely(!local && (!skb->dev || skb->dev->flags & IFF_LOOPBACK) &&
+		     ipv6_addr_type(&ipv6_hdr(skb)->saddr) &
+				    IPV6_ADDR_LOOPBACK)) {
+		IP_VS_DBG_RL("Stopping traffic from loopback address %pI6 "
+			     "to non-local address, dest: %pI6\n",
+			     &ipv6_hdr(skb)->saddr, daddr);
+		dst_release(&rt->dst);
+		return NULL;
+	}
+
  	return rt;
  }
  #endif
@@ -227,29 +338,32 @@ ip_vs_dst_reset(struct ip_vs_dest *dest)
  	__ret;							\
  })

-#define IP_VS_XMIT_NAT(pf, skb, cp)				\
+#define IP_VS_XMIT_NAT(pf, skb, cp, local)		\
  do {							\
  	(skb)->ipvs_property = 1;			\
  	if (likely(!((cp)->flags & IP_VS_CONN_F_NFCT)))	\
  		ip_vs_notrack(skb);			\
  	else						\
  		ip_vs_update_conntrack(skb, cp, 1);	\
+	if (local)					\
+		return NF_ACCEPT;			\
  	skb_forward_csum(skb);				\
  	NF_HOOK(pf, NF_INET_LOCAL_OUT, (skb), NULL,	\
  		skb_dst(skb)->dev, dst_output);		\
  } while (0)

-#define IP_VS_XMIT(pf, skb, cp)				\
+#define IP_VS_XMIT(pf, skb, cp, local)			\
  do {							\
  	(skb)->ipvs_property = 1;			\
  	if (likely(!((cp)->flags & IP_VS_CONN_F_NFCT)))	\
  		ip_vs_notrack(skb);			\
+	if (local)					\
+		return NF_ACCEPT;			\
  	skb_forward_csum(skb);				\
  	NF_HOOK(pf, NF_INET_LOCAL_OUT, (skb), NULL,	\
  		skb_dst(skb)->dev, dst_output);		\
  } while (0)

-
  /*
   *      NULL transmitter (do nothing except return NF_ACCEPT)
   */
@@ -258,7 +372,7 @@ ip_vs_null_xmit(struct sk_buff *skb, str
  		struct ip_vs_protocol *pp)
  {
  	/* we do not touch skb and do not need pskb ptr */
-	return NF_ACCEPT;
+	IP_VS_XMIT(NFPROTO_IPV4, skb, cp, 1);
  }


@@ -271,27 +385,15 @@ int
  ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
  		  struct ip_vs_protocol *pp)
  {
-	struct net *net = dev_net(skb->dev);
  	struct rtable *rt;			/* Route to the other host */
  	struct iphdr  *iph = ip_hdr(skb);
-	u8     tos = iph->tos;
  	int    mtu;
-	struct flowi fl = {
-		.oif = 0,
-		.nl_u = {
-			.ip4_u = {
-				.daddr = iph->daddr,
-				.saddr = 0,
-				.tos = RT_TOS(tos), } },
-	};

  	EnterFunction(10);

-	if (ip_route_output_key(net, &rt, &fl)) {
-		IP_VS_DBG_RL("%s(): ip_route_output error, dest: %pI4\n",
-			     __func__, &iph->daddr);
+	if (!(rt = __ip_vs_get_out_rt(skb, NULL, iph->daddr,
+				      RT_TOS(iph->tos), 2)))
  		goto tx_error_icmp;
-	}

  	/* MTU checking */
  	mtu = dst_mtu(&rt->dst);
@@ -319,7 +421,7 @@ ip_vs_bypass_xmit(struct sk_buff *skb, s
  	/* Another hack: avoid icmp_send in ip_fragment */
  	skb->local_df = 1;

-	IP_VS_XMIT(NFPROTO_IPV4, skb, cp);
+	IP_VS_XMIT(NFPROTO_IPV4, skb, cp, 0);

  	LeaveFunction(10);
  	return NF_STOLEN;
@@ -337,18 +439,14 @@ int
  ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
  		     struct ip_vs_protocol *pp)
  {
-	struct net *net = dev_net(skb->dev);
-	struct dst_entry *dst;
  	struct rt6_info *rt;			/* Route to the other host */
  	struct ipv6hdr  *iph = ipv6_hdr(skb);
  	int    mtu;

  	EnterFunction(10);

-	dst = __ip_vs_route_output_v6(net, &iph->daddr, NULL, 0);
-	if (!dst)
+	if (!(rt = __ip_vs_get_out_rt_v6(skb, NULL, &iph->daddr, NULL, 0, 2)))
  		goto tx_error_icmp;
-	rt = (struct rt6_info *) dst;

  	/* MTU checking */
  	mtu = dst_mtu(&rt->dst);
@@ -376,7 +474,7 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb
  	/* Another hack: avoid icmp_send in ip_fragment */
  	skb->local_df = 1;

-	IP_VS_XMIT(NFPROTO_IPV6, skb, cp);
+	IP_VS_XMIT(NFPROTO_IPV6, skb, cp, 0);

  	LeaveFunction(10);
  	return NF_STOLEN;
@@ -401,6 +499,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, stru
  	struct rtable *rt;		/* Route to the other host */
  	int mtu;
  	struct iphdr *iph = ip_hdr(skb);
+	int local;

  	EnterFunction(10);

@@ -414,16 +513,40 @@ ip_vs_nat_xmit(struct sk_buff *skb, stru
  		IP_VS_DBG(10, "filled cport=%d\n", ntohs(*p));
  	}

-	if (!(rt = __ip_vs_get_out_rt(skb, cp, RT_TOS(iph->tos))))
+	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
+				      RT_TOS(iph->tos), 1|2|4)))
  		goto tx_error_icmp;
+	local = rt->rt_flags & RTCF_LOCAL;
+	/* 
+	 * Avoid duplicate tuple in reply direction for NAT traffic
+	 * to local address when connection is sync-ed
+	 */
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+	if (cp->flags & IP_VS_CONN_F_SYNC && local) {
+		enum ip_conntrack_info ctinfo;
+		struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
+
+		if (ct && !nf_ct_is_untracked(ct)) {
+			IP_VS_DBG_RL_PKT(10, pp, skb, 0, "ip_vs_nat_xmit(): "
+					 "stopping DNAT to local address");
+			goto tx_error_put;
+		}
+	}
+#endif
+
+	/* From world but DNAT to loopback address? */
+	if (local && ipv4_is_loopback(rt->rt_dst) && skb_rtable(skb)->fl.iif) {
+		IP_VS_DBG_RL_PKT(1, pp, skb, 0, "ip_vs_nat_xmit(): "
+				 "stopping DNAT to loopback address");
+		goto tx_error_put;
+	}

  	/* MTU checking */
  	mtu = dst_mtu(&rt->dst);
  	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF))) {
-		ip_rt_put(rt);
  		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
  		IP_VS_DBG_RL_PKT(0, pp, skb, 0, "ip_vs_nat_xmit(): frag needed for");
-		goto tx_error;
+		goto tx_error_put;
  	}

  	/* copy-on-write the packet before mangling it */
@@ -433,16 +556,27 @@ ip_vs_nat_xmit(struct sk_buff *skb, stru
  	if (skb_cow(skb, rt->dst.dev->hard_header_len))
  		goto tx_error_put;

-	/* drop old route */
-	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->dst);
-
  	/* mangle the packet */
  	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp))
-		goto tx_error;
+		goto tx_error_put;
  	ip_hdr(skb)->daddr = cp->daddr.ip;
  	ip_send_check(ip_hdr(skb));

+	if (!local) {
+		/* drop old route */
+		skb_dst_drop(skb);
+		skb_dst_set(skb, &rt->dst);
+	} else {
+		ip_rt_put(rt);
+		/*
+		 * Some IPv4 replies get local address from routes,
+		 * not from iph, so while we DNAT after routing
+		 * we need this second input/output route.
+		 */
+		if (!__ip_vs_reroute_locally(skb))
+			goto tx_error;
+	}
+
  	IP_VS_DBG_PKT(10, pp, skb, 0, "After DNAT");

  	/* FIXME: when application helper enlarges the packet and the length
@@ -452,7 +586,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, stru
  	/* Another hack: avoid icmp_send in ip_fragment */
  	skb->local_df = 1;

-	IP_VS_XMIT_NAT(NFPROTO_IPV4, skb, cp);
+	IP_VS_XMIT_NAT(NFPROTO_IPV4, skb, cp, local);

  	LeaveFunction(10);
  	return NF_STOLEN;
@@ -475,6 +609,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, s
  {
  	struct rt6_info *rt;		/* Route to the other host */
  	int mtu;
+	int local;

  	EnterFunction(10);

@@ -489,18 +624,44 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, s
  		IP_VS_DBG(10, "filled cport=%d\n", ntohs(*p));
  	}

-	rt = __ip_vs_get_out_rt_v6(skb, cp, NULL, 0);
-	if (!rt)
+	if (!(rt = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
+					 0, 1|2|4)))
  		goto tx_error_icmp;
+	local = __ip_vs_is_local_route6(rt);
+	/* 
+	 * Avoid duplicate tuple in reply direction for NAT traffic
+	 * to local address when connection is sync-ed
+	 */
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+	if (cp->flags & IP_VS_CONN_F_SYNC && local) {
+		enum ip_conntrack_info ctinfo;
+		struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
+
+		if (ct && !nf_ct_is_untracked(ct)) {
+			IP_VS_DBG_RL_PKT(10, pp, skb, 0,
+					 "ip_vs_nat_xmit_v6(): "
+					 "stopping DNAT to local address");
+			goto tx_error_put;
+		}
+	}
+#endif
+
+	/* From world but DNAT to loopback address? */
+	if (local && skb->dev && !(skb->dev->flags & IFF_LOOPBACK) &&
+	    ipv6_addr_type(&rt->rt6i_dst.addr) & IPV6_ADDR_LOOPBACK) {
+		IP_VS_DBG_RL_PKT(1, pp, skb, 0,
+				 "ip_vs_nat_xmit_v6(): "
+				 "stopping DNAT to loopback address");
+		goto tx_error_put;
+	}

  	/* MTU checking */
  	mtu = dst_mtu(&rt->dst);
  	if (skb->len > mtu) {
-		dst_release(&rt->dst);
  		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
  		IP_VS_DBG_RL_PKT(0, pp, skb, 0,
  				 "ip_vs_nat_xmit_v6(): frag needed for");
-		goto tx_error;
+		goto tx_error_put;
  	}

  	/* copy-on-write the packet before mangling it */
@@ -510,14 +671,19 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, s
  	if (skb_cow(skb, rt->dst.dev->hard_header_len))
  		goto tx_error_put;

-	/* drop old route */
-	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->dst);
-
  	/* mangle the packet */
  	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp))
  		goto tx_error;
-	ipv6_hdr(skb)->daddr = cp->daddr.in6;
+	ipv6_addr_copy(&ipv6_hdr(skb)->daddr, &cp->daddr.in6);
+
+	if (!local || !skb->dev) {
+		/* drop the old route when skb is not shared */
+		skb_dst_drop(skb);
+		skb_dst_set(skb, &rt->dst);
+	} else {
+		/* destined to loopback, do we need to change route? */
+		dst_release(&rt->dst);
+	}

  	IP_VS_DBG_PKT(10, pp, skb, 0, "After DNAT");

@@ -528,7 +694,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, s
  	/* Another hack: avoid icmp_send in ip_fragment */
  	skb->local_df = 1;

-	IP_VS_XMIT_NAT(NFPROTO_IPV6, skb, cp);
+	IP_VS_XMIT_NAT(NFPROTO_IPV6, skb, cp, local);

  	LeaveFunction(10);
  	return NF_STOLEN;
@@ -588,16 +754,20 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, s
  		goto tx_error;
  	}

-	if (!(rt = __ip_vs_get_out_rt(skb, cp, RT_TOS(tos))))
+	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
+				      RT_TOS(tos), 1|2)))
  		goto tx_error_icmp;
+	if (rt->rt_flags & RTCF_LOCAL) {
+		ip_rt_put(rt);
+		IP_VS_XMIT(NFPROTO_IPV4, skb, cp, 1);
+	}

  	tdev = rt->dst.dev;

  	mtu = dst_mtu(&rt->dst) - sizeof(struct iphdr);
  	if (mtu < 68) {
-		ip_rt_put(rt);
  		IP_VS_DBG_RL("%s(): mtu less than 68\n", __func__);
-		goto tx_error;
+		goto tx_error_put;
  	}
  	if (skb_dst(skb))
  		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), mtu);
@@ -607,9 +777,8 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, s
  	if ((old_iph->frag_off & htons(IP_DF))
  	    && mtu < ntohs(old_iph->tot_len)) {
  		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
-		ip_rt_put(rt);
  		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
-		goto tx_error;
+		goto tx_error_put;
  	}

  	/*
@@ -678,6 +847,9 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, s
  	kfree_skb(skb);
  	LeaveFunction(10);
  	return NF_STOLEN;
+tx_error_put:
+	ip_rt_put(rt);
+	goto tx_error;
  }

  #ifdef CONFIG_IP_VS_IPV6
@@ -703,27 +875,29 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb
  		goto tx_error;
  	}

-	rt = __ip_vs_get_out_rt_v6(skb, cp, &saddr, 1);
-	if (!rt)
+	if (!(rt = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6,
+					 &saddr, 1, 1|2)))
  		goto tx_error_icmp;
+	if (__ip_vs_is_local_route6(rt)) {
+		dst_release(&rt->dst);
+		IP_VS_XMIT(NFPROTO_IPV6, skb, cp, 1);
+	}

  	tdev = rt->dst.dev;

  	mtu = dst_mtu(&rt->dst) - sizeof(struct ipv6hdr);
  	if (mtu < IPV6_MIN_MTU) {
-		dst_release(&rt->dst);
  		IP_VS_DBG_RL("%s(): mtu less than %d\n", __func__,
  			     IPV6_MIN_MTU);
-		goto tx_error;
+		goto tx_error_put;
  	}
  	if (skb_dst(skb))
  		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), mtu);

  	if (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr)) {
  		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
-		dst_release(&rt->dst);
  		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
-		goto tx_error;
+		goto tx_error_put;
  	}

  	/*
@@ -789,6 +963,9 @@ tx_error:
  	kfree_skb(skb);
  	LeaveFunction(10);
  	return NF_STOLEN;
+tx_error_put:
+	dst_release(&rt->dst);
+	goto tx_error;
  }
  #endif

@@ -807,8 +984,13 @@ ip_vs_dr_xmit(struct sk_buff *skb, struc

  	EnterFunction(10);

-	if (!(rt = __ip_vs_get_out_rt(skb, cp, RT_TOS(iph->tos))))
+	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
+				      RT_TOS(iph->tos), 1|2)))
  		goto tx_error_icmp;
+	if (rt->rt_flags & RTCF_LOCAL) {
+		ip_rt_put(rt);
+		IP_VS_XMIT(NFPROTO_IPV4, skb, cp, 1);
+	}

  	/* MTU checking */
  	mtu = dst_mtu(&rt->dst);
@@ -836,7 +1018,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struc
  	/* Another hack: avoid icmp_send in ip_fragment */
  	skb->local_df = 1;

-	IP_VS_XMIT(NFPROTO_IPV4, skb, cp);
+	IP_VS_XMIT(NFPROTO_IPV4, skb, cp, 0);

  	LeaveFunction(10);
  	return NF_STOLEN;
@@ -859,9 +1041,13 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, st

  	EnterFunction(10);

-	rt = __ip_vs_get_out_rt_v6(skb, cp, NULL, 0);
-	if (!rt)
+	if (!(rt = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
+					 0, 1|2)))
  		goto tx_error_icmp;
+	if (__ip_vs_is_local_route6(rt)) {
+		dst_release(&rt->dst);
+		IP_VS_XMIT(NFPROTO_IPV6, skb, cp, 1);
+	}

  	/* MTU checking */
  	mtu = dst_mtu(&rt->dst);
@@ -889,7 +1075,7 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, st
  	/* Another hack: avoid icmp_send in ip_fragment */
  	skb->local_df = 1;

-	IP_VS_XMIT(NFPROTO_IPV6, skb, cp);
+	IP_VS_XMIT(NFPROTO_IPV6, skb, cp, 0);

  	LeaveFunction(10);
  	return NF_STOLEN;
@@ -915,6 +1101,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, str
  	struct rtable	*rt;	/* Route to the other host */
  	int mtu;
  	int rc;
+	int local;

  	EnterFunction(10);

@@ -935,16 +1122,43 @@ ip_vs_icmp_xmit(struct sk_buff *skb, str
  	 * mangle and send the packet here (only for VS/NAT)
  	 */

-	if (!(rt = __ip_vs_get_out_rt(skb, cp, RT_TOS(ip_hdr(skb)->tos))))
+	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
+				      RT_TOS(ip_hdr(skb)->tos), 1|2|4)))
  		goto tx_error_icmp;
+	local = rt->rt_flags & RTCF_LOCAL;
+
+	/* 
+	 * Avoid duplicate tuple in reply direction for NAT traffic
+	 * to local address when connection is sync-ed
+	 */
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+	if (cp->flags & IP_VS_CONN_F_SYNC && local) {
+		enum ip_conntrack_info ctinfo;
+		struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
+
+		if (ct && !nf_ct_is_untracked(ct)) {
+			IP_VS_DBG(10, "%s(): "
+				  "stopping DNAT to local address %pI4\n",
+				  __func__, &cp->daddr.ip);
+			goto tx_error_put;
+		}
+	}
+#endif
+
+	/* From world but DNAT to loopback address? */
+	if (local && ipv4_is_loopback(rt->rt_dst) && skb_rtable(skb)->fl.iif) {
+		IP_VS_DBG(1, "%s(): "
+			  "stopping DNAT to loopback %pI4\n",
+			  __func__, &cp->daddr.ip);
+		goto tx_error_put;
+	}

  	/* MTU checking */
  	mtu = dst_mtu(&rt->dst);
  	if ((skb->len > mtu) && (ip_hdr(skb)->frag_off & htons(IP_DF))) {
-		ip_rt_put(rt);
  		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
  		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
-		goto tx_error;
+		goto tx_error_put;
  	}

  	/* copy-on-write the packet before mangling it */
@@ -954,16 +1168,27 @@ ip_vs_icmp_xmit(struct sk_buff *skb, str
  	if (skb_cow(skb, rt->dst.dev->hard_header_len))
  		goto tx_error_put;

-	/* drop the old route when skb is not shared */
-	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->dst);
-
  	ip_vs_nat_icmp(skb, pp, cp, 0);

+	if (!local) {
+		/* drop the old route when skb is not shared */
+		skb_dst_drop(skb);
+		skb_dst_set(skb, &rt->dst);
+	} else {
+		ip_rt_put(rt);
+		/*
+		 * Some IPv4 replies get local address from routes,
+		 * not from iph, so while we DNAT after routing
+		 * we need this second input/output route.
+		 */
+		if (!__ip_vs_reroute_locally(skb))
+			goto tx_error;
+	}
+
  	/* Another hack: avoid icmp_send in ip_fragment */
  	skb->local_df = 1;

-	IP_VS_XMIT(NFPROTO_IPV4, skb, cp);
+	IP_VS_XMIT_NAT(NFPROTO_IPV4, skb, cp, local);

  	rc = NF_STOLEN;
  	goto out;
@@ -989,6 +1214,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb,
  	struct rt6_info	*rt;	/* Route to the other host */
  	int mtu;
  	int rc;
+	int local;

  	EnterFunction(10);

@@ -1009,17 +1235,44 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb,
  	 * mangle and send the packet here (only for VS/NAT)
  	 */

-	rt = __ip_vs_get_out_rt_v6(skb, cp, NULL, 0);
-	if (!rt)
+	if (!(rt = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
+					 0, 1|2|4)))
  		goto tx_error_icmp;

+	local = __ip_vs_is_local_route6(rt);
+	/* 
+	 * Avoid duplicate tuple in reply direction for NAT traffic
+	 * to local address when connection is sync-ed
+	 */
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+	if (cp->flags & IP_VS_CONN_F_SYNC && local) {
+		enum ip_conntrack_info ctinfo;
+		struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
+
+		if (ct && !nf_ct_is_untracked(ct)) {
+			IP_VS_DBG(10, "%s(): "
+				  "stopping DNAT to local address %pI6\n",
+				  __func__, &cp->daddr.in6);
+			goto tx_error_put;
+		}
+	}
+#endif
+
+	/* From world but DNAT to loopback address? */
+	if (local && skb->dev && !(skb->dev->flags & IFF_LOOPBACK) &&
+	    ipv6_addr_type(&rt->rt6i_dst.addr) & IPV6_ADDR_LOOPBACK) {
+		IP_VS_DBG(1, "%s(): "
+			  "stopping DNAT to loopback %pI6\n",
+			  __func__, &cp->daddr.in6);
+		goto tx_error_put;
+	}
+
  	/* MTU checking */
  	mtu = dst_mtu(&rt->dst);
  	if (skb->len > mtu) {
-		dst_release(&rt->dst);
  		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
  		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
-		goto tx_error;
+		goto tx_error_put;
  	}

  	/* copy-on-write the packet before mangling it */
@@ -1029,16 +1282,21 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb,
  	if (skb_cow(skb, rt->dst.dev->hard_header_len))
  		goto tx_error_put;

-	/* drop the old route when skb is not shared */
-	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->dst);
-
  	ip_vs_nat_icmp_v6(skb, pp, cp, 0);

+	if (!local || !skb->dev) {
+		/* drop the old route when skb is not shared */
+		skb_dst_drop(skb);
+		skb_dst_set(skb, &rt->dst);
+	} else {
+		/* destined to loopback, do we need to change route? */
+		dst_release(&rt->dst);
+	}
+
  	/* Another hack: avoid icmp_send in ip_fragment */
  	skb->local_df = 1;

-	IP_VS_XMIT(NFPROTO_IPV6, skb, cp);
+	IP_VS_XMIT_NAT(NFPROTO_IPV6, skb, cp, local);

  	rc = NF_STOLEN;
  	goto out;
