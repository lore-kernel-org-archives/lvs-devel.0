From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 10/12] ipvs: changes for local client
Date: Sun, 17 Oct 2010 16:40:51 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010171638160.20665@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; format="flowed"; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


 	This patch deals with local client processing.

 	Prefer LOCAL_OUT hook for scheduling connections from
local clients. LOCAL_IN is still supported if the packets are
not marked as processed in LOCAL_OUT. The idea to process
requests in LOCAL_OUT is to alter conntrack reply before
it is confirmed at POST_ROUTING. If the local requests are
processed in LOCAL_IN the conntrack can not be updated
and matching by state is impossible.

 	Add the following handlers:

- ip_vs_reply[46] at LOCAL_IN:99 to process replies from
remote real servers to local clients. Now when both
replies from remote real servers (ip_vs_reply*) and
local real servers (ip_vs_local_reply*) are handled
it is safe to remove the conn_out_get call from ip_vs_in
because it does not support related ICMP packets.

- ip_vs_local_request[46] at LOCAL_OUT:-98 to process
requests from local client

 	Handling in LOCAL_OUT causes some changes:

- as skb->dev, skb->protocol and skb->pkt_type are not defined
in LOCAL_OUT make sure we set skb->dev before calling icmpv6_send,
prefer skb_dst(skb) for struct net and remove the skb->protocol
checks from TUN transmitters.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_core.c linux/net/netfilter/ipvs/ip_vs_core.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_core.c	2010-10-17 00:56:04.161356066 +0300
+++ linux/net/netfilter/ipvs/ip_vs_core.c	2010-10-16 20:12:43.442356233 +0300
@@ -529,9 +529,14 @@ int ip_vs_leave(struct ip_vs_service *sv
  	 * ICMP_PORT_UNREACH is sent here no matter it is TCP/UDP. --WZ
  	 */
  #ifdef CONFIG_IP_VS_IPV6
-	if (svc->af == AF_INET6)
+	if (svc->af == AF_INET6) {
+		if (!skb->dev) {
+			struct net *net = dev_net(skb_dst(skb)->dev);
+
+			skb->dev = net->loopback_dev;
+		}
  		icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0);
-	else
+	} else
  #endif
  		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);

@@ -1065,57 +1070,61 @@ ip_vs_out(unsigned int hooknum, struct s
  	 */
  	cp = pp->conn_out_get(af, skb, pp, &iph, iph.len, 0);

-	if (unlikely(!cp)) {
-		if (sysctl_ip_vs_nat_icmp_send &&
-		    (pp->protocol == IPPROTO_TCP ||
-		     pp->protocol == IPPROTO_UDP ||
-		     pp->protocol == IPPROTO_SCTP)) {
-			__be16 _ports[2], *pptr;
-
-			pptr = skb_header_pointer(skb, iph.len,
-						  sizeof(_ports), _ports);
-			if (pptr == NULL)
-				return NF_ACCEPT;	/* Not for me */
-			if (ip_vs_lookup_real_service(af, iph.protocol,
-						      &iph.saddr,
-						      pptr[0])) {
-				/*
-				 * Notify the real server: there is no
-				 * existing entry if it is not RST
-				 * packet or not TCP packet.
-				 */
-				if ((iph.protocol != IPPROTO_TCP &&
-				     iph.protocol != IPPROTO_SCTP)
-				     || ((iph.protocol == IPPROTO_TCP
-					  && !is_tcp_reset(skb, iph.len))
-					 || (iph.protocol == IPPROTO_SCTP
-						&& !is_sctp_abort(skb,
-							iph.len)))) {
+	if (likely(cp))
+		return handle_response(af, skb, pp, cp, iph.len);
+	if (sysctl_ip_vs_nat_icmp_send &&
+	    (pp->protocol == IPPROTO_TCP ||
+	     pp->protocol == IPPROTO_UDP ||
+	     pp->protocol == IPPROTO_SCTP)) {
+		__be16 _ports[2], *pptr;
+
+		pptr = skb_header_pointer(skb, iph.len,
+					  sizeof(_ports), _ports);
+		if (pptr == NULL)
+			return NF_ACCEPT;	/* Not for me */
+		if (ip_vs_lookup_real_service(af, iph.protocol,
+					      &iph.saddr,
+					      pptr[0])) {
+			/*
+			 * Notify the real server: there is no
+			 * existing entry if it is not RST
+			 * packet or not TCP packet.
+			 */
+			if ((iph.protocol != IPPROTO_TCP &&
+			     iph.protocol != IPPROTO_SCTP)
+			     || ((iph.protocol == IPPROTO_TCP
+				  && !is_tcp_reset(skb, iph.len))
+				 || (iph.protocol == IPPROTO_SCTP
+					&& !is_sctp_abort(skb,
+						iph.len)))) {
  #ifdef CONFIG_IP_VS_IPV6
-					if (af == AF_INET6)
-						icmpv6_send(skb,
-							    ICMPV6_DEST_UNREACH,
-							    ICMPV6_PORT_UNREACH,
-							    0);
-					else
+				if (af == AF_INET6) {
+					struct net *net =
+						dev_net(skb_dst(skb)->dev);
+
+					if (!skb->dev)
+						skb->dev = net->loopback_dev;
+					icmpv6_send(skb,
+						    ICMPV6_DEST_UNREACH,
+						    ICMPV6_PORT_UNREACH,
+						    0);
+				} else
  #endif
-						icmp_send(skb,
-							  ICMP_DEST_UNREACH,
-							  ICMP_PORT_UNREACH, 0);
-					return NF_DROP;
-				}
+					icmp_send(skb,
+						  ICMP_DEST_UNREACH,
+						  ICMP_PORT_UNREACH, 0);
+				return NF_DROP;
  			}
  		}
-		IP_VS_DBG_PKT(12, pp, skb, 0,
-			      "packet continues traversal as normal");
-		return NF_ACCEPT;
  	}
-
-	return handle_response(af, skb, pp, cp, iph.len);
+	IP_VS_DBG_PKT(12, pp, skb, 0,
+		      "ip_vs_out: packet continues traversal as normal");
+	return NF_ACCEPT;
  }

  /*
- *	It is hooked at the NF_INET_FORWARD chain, used only for VS/NAT.
+ *	It is hooked at the NF_INET_FORWARD and NF_INET_LOCAL_IN chain,
+ *	used only for VS/NAT.
   *	Check if packet is reply for established ip_vs_conn.
   */
  static unsigned int
@@ -1147,7 +1156,8 @@ ip_vs_local_reply4(unsigned int hooknum,
  #ifdef CONFIG_IP_VS_IPV6

  /*
- *	It is hooked at the NF_INET_FORWARD chain, used only for VS/NAT.
+ *	It is hooked at the NF_INET_FORWARD and NF_INET_LOCAL_IN chain,
+ *	used only for VS/NAT.
   *	Check if packet is reply for established ip_vs_conn.
   */
  static unsigned int
@@ -1404,34 +1414,43 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, in
   *	and send it on its way...
   */
  static unsigned int
-ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
-	 const struct net_device *in, const struct net_device *out,
-	 int (*okfn)(struct sk_buff *))
+ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
  {
  	struct ip_vs_iphdr iph;
  	struct ip_vs_protocol *pp;
  	struct ip_vs_conn *cp;
-	int ret, restart, af, pkts;
+	int ret, restart, pkts;

  	/* Already marked as IPVS request or reply? */
  	if (skb->ipvs_property)
  		return NF_ACCEPT;

-	af = (skb->protocol == htons(ETH_P_IP)) ? AF_INET : AF_INET6;
-
-	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
-
  	/*
-	 *	Big tappo: only PACKET_HOST, including loopback for local client
-	 *	Don't handle local packets on IPv6 for now
+	 *	Big tappo:
+	 *	- remote client: only PACKET_HOST
+	 *	- route: used for struct net when skb->dev is unset
  	 */
-	if (unlikely(skb->pkt_type != PACKET_HOST)) {
-		IP_VS_DBG_BUF(12, "packet type=%d proto=%d daddr=%s ignored\n",
-			      skb->pkt_type,
-			      iph.protocol,
-			      IP_VS_DBG_ADDR(af, &iph.daddr));
+	if (unlikely((skb->pkt_type != PACKET_HOST &&
+		      hooknum != NF_INET_LOCAL_OUT) ||
+		     !skb_dst(skb))) {
+		ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+		IP_VS_DBG_BUF(12, "packet type=%d proto=%d daddr=%s"
+			      " ignored in hook %u\n",
+			      skb->pkt_type, iph.protocol,
+			      IP_VS_DBG_ADDR(af, &iph.daddr), hooknum);
  		return NF_ACCEPT;
  	}
+	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+
+	/* Bad... Do not break raw sockets */
+	if (unlikely(skb->sk != NULL && hooknum == NF_INET_LOCAL_OUT &&
+		     af == AF_INET)) {
+		struct sock *sk = skb->sk;
+		struct inet_sock *inet = inet_sk(skb->sk);
+ 
+		if (inet && sk->sk_family == PF_INET && inet->nodefrag)
+			return NF_ACCEPT;
+	}

  #ifdef CONFIG_IP_VS_IPV6
  	if (af == AF_INET6) {
@@ -1467,11 +1486,6 @@ ip_vs_in(unsigned int hooknum, struct sk
  	if (unlikely(!cp)) {
  		int v;

-		/* For local client packets, it could be a response */
-		cp = pp->conn_out_get(af, skb, pp, &iph, iph.len, 0);
-		if (cp)
-			return handle_response(af, skb, pp, cp, iph.len);
-
  		if (!pp->conn_schedule(af, skb, pp, &v, &cp))
  			return v;
  	}
@@ -1479,7 +1493,7 @@ ip_vs_in(unsigned int hooknum, struct sk
  	if (unlikely(!cp)) {
  		/* sorry, all this trouble for a no-hit :) */
  		IP_VS_DBG_PKT(12, pp, skb, 0,
-			      "packet continues traversal as normal");
+			      "ip_vs_in: packet continues traversal as normal");
  		return NF_ACCEPT;
  	}

@@ -1550,6 +1564,72 @@ out:
  	return ret;
  }

+/*
+ *	AF_INET handler in NF_INET_LOCAL_IN chain
+ *	Schedule and forward packets from remote clients
+ */
+static unsigned int
+ip_vs_remote_request4(unsigned int hooknum, struct sk_buff *skb,
+		      const struct net_device *in,
+		      const struct net_device *out,
+		      int (*okfn)(struct sk_buff *))
+{
+	return ip_vs_in(hooknum, skb, AF_INET);
+}
+
+/*
+ *	AF_INET handler in NF_INET_LOCAL_OUT chain
+ *	Schedule and forward packets from local clients
+ */
+static unsigned int
+ip_vs_local_request4(unsigned int hooknum, struct sk_buff *skb,
+		     const struct net_device *in, const struct net_device *out,
+		     int (*okfn)(struct sk_buff *))
+{
+	unsigned int verdict;
+
+	/* Disable BH in LOCAL_OUT until all places are fixed */
+	local_bh_disable();
+	verdict = ip_vs_in(hooknum, skb, AF_INET);
+	local_bh_enable();
+	return verdict;
+}
+
+#ifdef CONFIG_IP_VS_IPV6
+
+/*
+ *	AF_INET6 handler in NF_INET_LOCAL_IN chain
+ *	Schedule and forward packets from remote clients
+ */
+static unsigned int
+ip_vs_remote_request6(unsigned int hooknum, struct sk_buff *skb,
+		      const struct net_device *in,
+		      const struct net_device *out,
+		      int (*okfn)(struct sk_buff *))
+{
+	return ip_vs_in(hooknum, skb, AF_INET6);
+}
+
+/*
+ *	AF_INET6 handler in NF_INET_LOCAL_OUT chain
+ *	Schedule and forward packets from local clients
+ */
+static unsigned int
+ip_vs_local_request6(unsigned int hooknum, struct sk_buff *skb,
+		     const struct net_device *in, const struct net_device *out,
+		     int (*okfn)(struct sk_buff *))
+{
+	unsigned int verdict;
+
+	/* Disable BH in LOCAL_OUT until all places are fixed */
+	local_bh_disable();
+	verdict = ip_vs_in(hooknum, skb, AF_INET6);
+	local_bh_enable();
+	return verdict;
+}
+
+#endif
+

  /*
   *	It is hooked at the NF_INET_FORWARD chain, in order to catch ICMP
@@ -1590,15 +1670,23 @@ ip_vs_forward_icmp_v6(unsigned int hookn


  static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
+	/* After packet filtering, change source only for VS/NAT */
+	{
+		.hook		= ip_vs_reply4,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET,
+		.hooknum	= NF_INET_LOCAL_IN,
+		.priority	= 99,
+	},
  	/* After packet filtering, forward packet through VS/DR, VS/TUN,
  	 * or VS/NAT(change destination), so that filtering rules can be
  	 * applied to IPVS. */
  	{
-		.hook		= ip_vs_in,
+		.hook		= ip_vs_remote_request4,
  		.owner		= THIS_MODULE,
  		.pf		= PF_INET,
-		.hooknum        = NF_INET_LOCAL_IN,
-		.priority       = 100,
+		.hooknum	= NF_INET_LOCAL_IN,
+		.priority	= 101,
  	},
  	/* Before ip_vs_in, change source only for VS/NAT */
  	{
@@ -1608,14 +1696,22 @@ static struct nf_hook_ops ip_vs_ops[] __
  		.hooknum	= NF_INET_LOCAL_OUT,
  		.priority	= -99,
  	},
+	/* After mangle, schedule and forward local requests */
+	{
+		.hook		= ip_vs_local_request4,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET,
+		.hooknum	= NF_INET_LOCAL_OUT,
+		.priority	= -98,
+	},
  	/* After packet filtering (but before ip_vs_out_icmp), catch icmp
  	 * destined for 0.0.0.0/0, which is for incoming IPVS connections */
  	{
  		.hook		= ip_vs_forward_icmp,
  		.owner		= THIS_MODULE,
  		.pf		= PF_INET,
-		.hooknum        = NF_INET_FORWARD,
-		.priority       = 99,
+		.hooknum	= NF_INET_FORWARD,
+		.priority	= 99,
  	},
  	/* After packet filtering, change source only for VS/NAT */
  	{
@@ -1626,15 +1722,23 @@ static struct nf_hook_ops ip_vs_ops[] __
  		.priority	= 100,
  	},
  #ifdef CONFIG_IP_VS_IPV6
+	/* After packet filtering, change source only for VS/NAT */
+	{
+		.hook		= ip_vs_reply6,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET6,
+		.hooknum	= NF_INET_LOCAL_IN,
+		.priority	= 99,
+	},
  	/* After packet filtering, forward packet through VS/DR, VS/TUN,
  	 * or VS/NAT(change destination), so that filtering rules can be
  	 * applied to IPVS. */
  	{
-		.hook		= ip_vs_in,
+		.hook		= ip_vs_remote_request6,
  		.owner		= THIS_MODULE,
  		.pf		= PF_INET6,
-		.hooknum        = NF_INET_LOCAL_IN,
-		.priority       = 100,
+		.hooknum	= NF_INET_LOCAL_IN,
+		.priority	= 101,
  	},
  	/* Before ip_vs_in, change source only for VS/NAT */
  	{
@@ -1644,14 +1748,22 @@ static struct nf_hook_ops ip_vs_ops[] __
  		.hooknum	= NF_INET_LOCAL_OUT,
  		.priority	= -99,
  	},
+	/* After mangle, schedule and forward local requests */
+	{
+		.hook		= ip_vs_local_request6,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET6,
+		.hooknum	= NF_INET_LOCAL_OUT,
+		.priority	= -98,
+	},
  	/* After packet filtering (but before ip_vs_out_icmp), catch icmp
  	 * destined for 0.0.0.0/0, which is for incoming IPVS connections */
  	{
  		.hook		= ip_vs_forward_icmp_v6,
  		.owner		= THIS_MODULE,
  		.pf		= PF_INET6,
-		.hooknum        = NF_INET_FORWARD,
-		.priority       = 99,
+		.hooknum	= NF_INET_FORWARD,
+		.priority	= 99,
  	},
  	/* After packet filtering, change source only for VS/NAT */
  	{
diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_xmit.c linux/net/netfilter/ipvs/ip_vs_xmit.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_xmit.c	2010-10-16 19:55:45.862354986 +0300
+++ linux/net/netfilter/ipvs/ip_vs_xmit.c	2010-10-16 20:14:22.341354963 +0300
@@ -11,6 +11,16 @@
   *
   * Changes:
   *
+ * Description of forwarding methods:
+ * - all transmitters are called from LOCAL_IN (remote clients) and
+ * LOCAL_OUT (local clients) but for ICMP can be called from FORWARD
+ * - not all connections have destination server, for example,
+ * connections in backup server when fwmark is used
+ * - bypass connections use daddr from packet
+ * LOCAL_OUT rules:
+ * - skb->dev is NULL, skb->protocol is not set (both are set in POST_ROUTING)
+ * - skb->pkt_type is not set yet
+ * - the only place where we can see skb->sk != NULL
   */

  #define KMSG_COMPONENT "IPVS"
@@ -451,8 +461,13 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb
  	/* MTU checking */
  	mtu = dst_mtu(&rt->dst);
  	if (skb->len > mtu) {
-		dst_release(&rt->dst);
+		if (!skb->dev) {
+			struct net *net = dev_net(skb_dst(skb)->dev);
+
+			skb->dev = net->loopback_dev;
+		}
  		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
+		dst_release(&rt->dst);
  		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
  		goto tx_error;
  	}
@@ -658,6 +673,11 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, s
  	/* MTU checking */
  	mtu = dst_mtu(&rt->dst);
  	if (skb->len > mtu) {
+		if (!skb->dev) {
+			struct net *net = dev_net(skb_dst(skb)->dev);
+
+			skb->dev = net->loopback_dev;
+		}
  		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
  		IP_VS_DBG_RL_PKT(0, pp, skb, 0,
  				 "ip_vs_nat_xmit_v6(): frag needed for");
@@ -747,13 +767,6 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, s

  	EnterFunction(10);

-	if (skb->protocol != htons(ETH_P_IP)) {
-		IP_VS_DBG_RL("%s(): protocol error, "
-			     "ETH_P_IP: %d, skb protocol: %d\n",
-			     __func__, htons(ETH_P_IP), skb->protocol);
-		goto tx_error;
-	}
-
  	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
  				      RT_TOS(tos), 1|2)))
  		goto tx_error_icmp;
@@ -868,13 +881,6 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb

  	EnterFunction(10);

-	if (skb->protocol != htons(ETH_P_IPV6)) {
-		IP_VS_DBG_RL("%s(): protocol error, "
-			     "ETH_P_IPV6: %d, skb protocol: %d\n",
-			     __func__, htons(ETH_P_IPV6), skb->protocol);
-		goto tx_error;
-	}
-
  	if (!(rt = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6,
  					 &saddr, 1, 1|2)))
  		goto tx_error_icmp;
@@ -895,6 +901,11 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb
  		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), mtu);

  	if (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr)) {
+		if (!skb->dev) {
+			struct net *net = dev_net(skb_dst(skb)->dev);
+
+			skb->dev = net->loopback_dev;
+		}
  		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
  		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
  		goto tx_error_put;
@@ -1052,6 +1063,11 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, st
  	/* MTU checking */
  	mtu = dst_mtu(&rt->dst);
  	if (skb->len > mtu) {
+		if (!skb->dev) {
+			struct net *net = dev_net(skb_dst(skb)->dev);
+
+			skb->dev = net->loopback_dev;
+		}
  		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
  		dst_release(&rt->dst);
  		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
@@ -1270,6 +1286,11 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb,
  	/* MTU checking */
  	mtu = dst_mtu(&rt->dst);
  	if (skb->len > mtu) {
+		if (!skb->dev) {
+			struct net *net = dev_net(skb_dst(skb)->dev);
+
+			skb->dev = net->loopback_dev;
+		}
  		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
  		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
  		goto tx_error_put;
