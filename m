From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCHv3 net-next 08/15] ipvs: consolidate all dst checks on transmit in one place
Date: Thu, 21 Mar 2013 11:58:05 +0200
Message-ID: <1363859892-9058-9-git-send-email-ja@ssi.bg>
References: <1363859892-9058-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1363859892-9058-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

	Consolidate the PMTU checks, ICMP sending and
skb_dst modification in __ip_vs_get_out_rt and
__ip_vs_get_out_rt_v6. Now skb_dst is changed early
to simplify the transmitters.

	Make sure update_pmtu is called only for
local clients.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_xmit.c |  627 +++++++++++++++------------------------
 1 files changed, 235 insertions(+), 392 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index e6e2d3f..603eb8a 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -51,6 +51,7 @@ enum {
 				      */
 	IP_VS_RT_MODE_CONNECT	= 8, /* Always bind route to saddr */
 	IP_VS_RT_MODE_KNOWN_NH	= 16,/* Route via remote addr */
+	IP_VS_RT_MODE_TUNNEL	= 32,/* Tunnel mode */
 };
 
 /*
@@ -137,13 +138,17 @@ retry:
 }
 
 /* Get route to destination or remote server */
-static struct rtable *
+static int
 __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 		   __be32 daddr, int rt_mode, __be32 *ret_saddr)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct rtable *rt;			/* Route to the other host */
 	struct rtable *ort;			/* Original route */
+	struct iphdr *iph;
+	__be16 df;
+	int mtu;
 	int local;
 
 	if (dest) {
@@ -154,7 +159,7 @@ __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 					      &dest->dst_saddr.ip);
 			if (!rt) {
 				spin_unlock(&dest->dst_lock);
-				return NULL;
+				goto err_unreach;
 			}
 			__ip_vs_dst_set(dest, dst_clone(&rt->dst), 0);
 			IP_VS_DBG(10, "new dst %pI4, src %pI4, refcnt=%d\n",
@@ -174,37 +179,78 @@ __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 		rt_mode &= ~IP_VS_RT_MODE_CONNECT;
 		rt = do_output_route4(net, daddr, rt_mode, &saddr);
 		if (!rt)
-			return NULL;
+			goto err_unreach;
 		if (ret_saddr)
 			*ret_saddr = saddr;
 	}
 
-	local = rt->rt_flags & RTCF_LOCAL;
+	local = (rt->rt_flags & RTCF_LOCAL) ? 1 : 0;
 	if (!((local ? IP_VS_RT_MODE_LOCAL : IP_VS_RT_MODE_NON_LOCAL) &
 	      rt_mode)) {
 		IP_VS_DBG_RL("Stopping traffic to %s address, dest: %pI4\n",
 			     (rt->rt_flags & RTCF_LOCAL) ?
 			     "local":"non-local", &daddr);
-		ip_rt_put(rt);
-		return NULL;
+		goto err_put;
 	}
-	if (local && !(rt_mode & IP_VS_RT_MODE_RDR) &&
-	    !((ort = skb_rtable(skb)) && ort->rt_flags & RTCF_LOCAL)) {
-		IP_VS_DBG_RL("Redirect from non-local address %pI4 to local "
-			     "requires NAT method, dest: %pI4\n",
-			     &ip_hdr(skb)->daddr, &daddr);
+	iph = ip_hdr(skb);
+	if (likely(!local)) {
+		if (unlikely(ipv4_is_loopback(iph->saddr))) {
+			IP_VS_DBG_RL("Stopping traffic from loopback address "
+				     "%pI4 to non-local address, dest: %pI4\n",
+				     &iph->saddr, &daddr);
+			goto err_put;
+		}
+	} else {
+		ort = skb_rtable(skb);
+		if (!(rt_mode & IP_VS_RT_MODE_RDR) &&
+		    !(ort->rt_flags & RTCF_LOCAL)) {
+			IP_VS_DBG_RL("Redirect from non-local address %pI4 to "
+				     "local requires NAT method, dest: %pI4\n",
+				     &iph->daddr, &daddr);
+			goto err_put;
+		}
+		/* skb to local stack, preserve old route */
 		ip_rt_put(rt);
-		return NULL;
+		return local;
 	}
-	if (unlikely(!local && ipv4_is_loopback(ip_hdr(skb)->saddr))) {
-		IP_VS_DBG_RL("Stopping traffic from loopback address %pI4 "
-			     "to non-local address, dest: %pI4\n",
-			     &ip_hdr(skb)->saddr, &daddr);
-		ip_rt_put(rt);
-		return NULL;
+
+	if (likely(!(rt_mode & IP_VS_RT_MODE_TUNNEL))) {
+		mtu = dst_mtu(&rt->dst);
+		df = iph->frag_off & htons(IP_DF);
+	} else {
+		struct sock *sk = skb->sk;
+
+		mtu = dst_mtu(&rt->dst) - sizeof(struct iphdr);
+		if (mtu < 68) {
+			IP_VS_DBG_RL("%s(): mtu less than 68\n", __func__);
+			goto err_put;
+		}
+		ort = skb_rtable(skb);
+		if (!skb->dev && sk && sk->sk_state != TCP_TIME_WAIT)
+			ort->dst.ops->update_pmtu(&ort->dst, sk, NULL, mtu);
+		/* MTU check allowed? */
+		df = sysctl_pmtu_disc(ipvs) ? iph->frag_off & htons(IP_DF) : 0;
 	}
 
-	return rt;
+	/* MTU checking */
+	if (unlikely(df && skb->len > mtu && !skb_is_gso(skb))) {
+		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
+		IP_VS_DBG(1, "frag needed for %pI4\n", &iph->saddr);
+		goto err_put;
+	}
+
+	skb_dst_drop(skb);
+	skb_dst_set(skb, &rt->dst);
+
+	return local;
+
+err_put:
+	ip_rt_put(rt);
+	return -1;
+
+err_unreach:
+	dst_link_failure(skb);
+	return -1;
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -251,15 +297,16 @@ out_err:
 /*
  * Get route to destination or remote server
  */
-static struct rt6_info *
+static int
 __ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_dest *dest,
 		      struct in6_addr *daddr, struct in6_addr *ret_saddr,
-		      int do_xfrm, int rt_mode)
+		      struct ip_vs_iphdr *ipvsh, int do_xfrm, int rt_mode)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	struct rt6_info *rt;			/* Route to the other host */
 	struct rt6_info *ort;			/* Original route */
 	struct dst_entry *dst;
+	int mtu;
 	int local;
 
 	if (dest) {
@@ -273,7 +320,7 @@ __ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_dest *dest,
 						      do_xfrm);
 			if (!dst) {
 				spin_unlock(&dest->dst_lock);
-				return NULL;
+				goto err_unreach;
 			}
 			rt = (struct rt6_info *) dst;
 			cookie = rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
@@ -288,7 +335,7 @@ __ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_dest *dest,
 	} else {
 		dst = __ip_vs_route_output_v6(net, daddr, ret_saddr, do_xfrm);
 		if (!dst)
-			return NULL;
+			goto err_unreach;
 		rt = (struct rt6_info *) dst;
 	}
 
@@ -297,29 +344,72 @@ __ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_dest *dest,
 	      rt_mode)) {
 		IP_VS_DBG_RL("Stopping traffic to %s address, dest: %pI6c\n",
 			     local ? "local":"non-local", daddr);
-		dst_release(&rt->dst);
-		return NULL;
+		goto err_put;
 	}
-	if (local && !(rt_mode & IP_VS_RT_MODE_RDR) &&
-	    !((ort = (struct rt6_info *) skb_dst(skb)) &&
-	      __ip_vs_is_local_route6(ort))) {
-		IP_VS_DBG_RL("Redirect from non-local address %pI6c to local "
-			     "requires NAT method, dest: %pI6c\n",
-			     &ipv6_hdr(skb)->daddr, daddr);
+	if (likely(!local)) {
+		if (unlikely((!skb->dev || skb->dev->flags & IFF_LOOPBACK) &&
+			     ipv6_addr_type(&ipv6_hdr(skb)->saddr) &
+					    IPV6_ADDR_LOOPBACK)) {
+			IP_VS_DBG_RL("Stopping traffic from loopback address "
+				     "%pI6c to non-local address, "
+				     "dest: %pI6c\n",
+				     &ipv6_hdr(skb)->saddr, daddr);
+			goto err_put;
+		}
+	} else {
+		ort = (struct rt6_info *) skb_dst(skb);
+		if (!(rt_mode & IP_VS_RT_MODE_RDR) &&
+		    !__ip_vs_is_local_route6(ort)) {
+			IP_VS_DBG_RL("Redirect from non-local address %pI6c "
+				     "to local requires NAT method, "
+				     "dest: %pI6c\n",
+				     &ipv6_hdr(skb)->daddr, daddr);
+			goto err_put;
+		}
+		/* skb to local stack, preserve old route */
 		dst_release(&rt->dst);
-		return NULL;
+		return local;
 	}
-	if (unlikely(!local && (!skb->dev || skb->dev->flags & IFF_LOOPBACK) &&
-		     ipv6_addr_type(&ipv6_hdr(skb)->saddr) &
-				    IPV6_ADDR_LOOPBACK)) {
-		IP_VS_DBG_RL("Stopping traffic from loopback address %pI6c "
-			     "to non-local address, dest: %pI6c\n",
-			     &ipv6_hdr(skb)->saddr, daddr);
-		dst_release(&rt->dst);
-		return NULL;
+
+	/* MTU checking */
+	if (likely(!(rt_mode & IP_VS_RT_MODE_TUNNEL)))
+		mtu = dst_mtu(&rt->dst);
+	else {
+		struct sock *sk = skb->sk;
+
+		mtu = dst_mtu(&rt->dst) - sizeof(struct ipv6hdr);
+		if (mtu < IPV6_MIN_MTU) {
+			IP_VS_DBG_RL("%s(): mtu less than %d\n", __func__,
+				     IPV6_MIN_MTU);
+			goto err_put;
+		}
+		ort = (struct rt6_info *) skb_dst(skb);
+		if (!skb->dev && sk && sk->sk_state != TCP_TIME_WAIT)
+			ort->dst.ops->update_pmtu(&ort->dst, sk, NULL, mtu);
 	}
 
-	return rt;
+	if (unlikely(__mtu_check_toobig_v6(skb, mtu))) {
+		if (!skb->dev)
+			skb->dev = net->loopback_dev;
+		/* only send ICMP too big on first fragment */
+		if (!ipvsh->fragoffs)
+			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
+		IP_VS_DBG(1, "frag needed for %pI6c\n", &ipv6_hdr(skb)->saddr);
+		goto err_put;
+	}
+
+	skb_dst_drop(skb);
+	skb_dst_set(skb, &rt->dst);
+
+	return local;
+
+err_put:
+	dst_release(&rt->dst);
+	return -1;
+
+err_unreach:
+	dst_link_failure(skb);
+	return -1;
 }
 #endif
 
@@ -400,32 +490,15 @@ int
 ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
-	struct rtable *rt;			/* Route to the other host */
 	struct iphdr  *iph = ip_hdr(skb);
-	int    mtu;
 
 	EnterFunction(10);
 
-	rt = __ip_vs_get_out_rt(skb, NULL, iph->daddr, IP_VS_RT_MODE_NON_LOCAL,
-				NULL);
-	if (!rt)
-		goto tx_error_icmp;
-
-	/* MTU checking */
-	mtu = dst_mtu(&rt->dst);
-	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF)) &&
-	    !skb_is_gso(skb)) {
-		ip_rt_put(rt);
-		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
-		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
+	if (__ip_vs_get_out_rt(skb, NULL, iph->daddr, IP_VS_RT_MODE_NON_LOCAL,
+			       NULL) < 0)
 		goto tx_error;
-	}
 
-	ip_send_check(ip_hdr(skb));
-
-	/* drop old route */
-	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->dst);
+	ip_send_check(iph);
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
@@ -435,8 +508,6 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	LeaveFunction(10);
 	return NF_STOLEN;
 
- tx_error_icmp:
-	dst_link_failure(skb);
  tx_error:
 	kfree_skb(skb);
 	LeaveFunction(10);
@@ -446,37 +517,13 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph)
+		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
-	struct rt6_info *rt;			/* Route to the other host */
-	int    mtu;
-
 	EnterFunction(10);
 
-	rt = __ip_vs_get_out_rt_v6(skb, NULL, &iph->daddr.in6, NULL, 0,
-				   IP_VS_RT_MODE_NON_LOCAL);
-	if (!rt)
-		goto tx_error_icmp;
-
-	/* MTU checking */
-	mtu = dst_mtu(&rt->dst);
-	if (__mtu_check_toobig_v6(skb, mtu)) {
-		if (!skb->dev) {
-			struct net *net = dev_net(skb_dst(skb)->dev);
-
-			skb->dev = net->loopback_dev;
-		}
-		/* only send ICMP too big on first fragment */
-		if (!iph->fragoffs)
-			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
-		dst_release(&rt->dst);
-		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
+	if (__ip_vs_get_out_rt_v6(skb, NULL, &ipvsh->daddr.in6, NULL,
+				  ipvsh, 0, IP_VS_RT_MODE_NON_LOCAL) < 0)
 		goto tx_error;
-	}
-
-	/* drop old route */
-	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->dst);
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
@@ -486,8 +533,6 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	LeaveFunction(10);
 	return NF_STOLEN;
 
- tx_error_icmp:
-	dst_link_failure(skb);
  tx_error:
 	kfree_skb(skb);
 	LeaveFunction(10);
@@ -504,28 +549,29 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	       struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
 	struct rtable *rt;		/* Route to the other host */
-	int mtu;
-	struct iphdr *iph = ip_hdr(skb);
-	int local, rc;
+	int local, rc, was_input;
 
 	EnterFunction(10);
 
 	/* check if it is a connection of no-client-port */
 	if (unlikely(cp->flags & IP_VS_CONN_F_NO_CPORT)) {
 		__be16 _pt, *p;
-		p = skb_header_pointer(skb, iph->ihl*4, sizeof(_pt), &_pt);
+
+		p = skb_header_pointer(skb, ipvsh->len, sizeof(_pt), &_pt);
 		if (p == NULL)
 			goto tx_error;
 		ip_vs_conn_fill_cport(cp, *p);
 		IP_VS_DBG(10, "filled cport=%d\n", ntohs(*p));
 	}
 
-	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
-				      IP_VS_RT_MODE_LOCAL |
-				      IP_VS_RT_MODE_NON_LOCAL |
-				      IP_VS_RT_MODE_RDR, NULL)))
-		goto tx_error_icmp;
-	local = rt->rt_flags & RTCF_LOCAL;
+	was_input = rt_is_input_route(skb_rtable(skb));
+	local = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
+				   IP_VS_RT_MODE_LOCAL |
+				   IP_VS_RT_MODE_NON_LOCAL |
+				   IP_VS_RT_MODE_RDR, NULL);
+	if (local < 0)
+		goto tx_error;
+	rt = skb_rtable(skb);
 	/*
 	 * Avoid duplicate tuple in reply direction for NAT traffic
 	 * to local address when connection is sync-ed
@@ -539,49 +585,31 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 			IP_VS_DBG_RL_PKT(10, AF_INET, pp, skb, 0,
 					 "ip_vs_nat_xmit(): "
 					 "stopping DNAT to local address");
-			goto tx_error_put;
+			goto tx_error;
 		}
 	}
 #endif
 
 	/* From world but DNAT to loopback address? */
-	if (local && ipv4_is_loopback(cp->daddr.ip) &&
-	    rt_is_input_route(skb_rtable(skb))) {
+	if (local && ipv4_is_loopback(cp->daddr.ip) && was_input) {
 		IP_VS_DBG_RL_PKT(1, AF_INET, pp, skb, 0, "ip_vs_nat_xmit(): "
 				 "stopping DNAT to loopback address");
-		goto tx_error_put;
-	}
-
-	/* MTU checking */
-	mtu = dst_mtu(&rt->dst);
-	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF)) &&
-	    !skb_is_gso(skb)) {
-		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
-		IP_VS_DBG_RL_PKT(0, AF_INET, pp, skb, 0,
-				 "ip_vs_nat_xmit(): frag needed for");
-		goto tx_error_put;
+		goto tx_error;
 	}
 
 	/* copy-on-write the packet before mangling it */
 	if (!skb_make_writable(skb, sizeof(struct iphdr)))
-		goto tx_error_put;
+		goto tx_error;
 
 	if (skb_cow(skb, rt->dst.dev->hard_header_len))
-		goto tx_error_put;
+		goto tx_error;
 
 	/* mangle the packet */
 	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp, ipvsh))
-		goto tx_error_put;
+		goto tx_error;
 	ip_hdr(skb)->daddr = cp->daddr.ip;
 	ip_send_check(ip_hdr(skb));
 
-	if (!local) {
-		/* drop old route */
-		skb_dst_drop(skb);
-		skb_dst_set(skb, &rt->dst);
-	} else
-		ip_rt_put(rt);
-
 	IP_VS_DBG_PKT(10, AF_INET, pp, skb, 0, "After DNAT");
 
 	/* FIXME: when application helper enlarges the packet and the length
@@ -596,44 +624,40 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	LeaveFunction(10);
 	return rc;
 
-  tx_error_icmp:
-	dst_link_failure(skb);
   tx_error:
 	kfree_skb(skb);
 	LeaveFunction(10);
 	return NF_STOLEN;
-  tx_error_put:
-	ip_rt_put(rt);
-	goto tx_error;
 }
 
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph)
+		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
 	struct rt6_info *rt;		/* Route to the other host */
-	int mtu;
 	int local, rc;
 
 	EnterFunction(10);
 
 	/* check if it is a connection of no-client-port */
-	if (unlikely(cp->flags & IP_VS_CONN_F_NO_CPORT && !iph->fragoffs)) {
+	if (unlikely(cp->flags & IP_VS_CONN_F_NO_CPORT && !ipvsh->fragoffs)) {
 		__be16 _pt, *p;
-		p = skb_header_pointer(skb, iph->len, sizeof(_pt), &_pt);
+		p = skb_header_pointer(skb, ipvsh->len, sizeof(_pt), &_pt);
 		if (p == NULL)
 			goto tx_error;
 		ip_vs_conn_fill_cport(cp, *p);
 		IP_VS_DBG(10, "filled cport=%d\n", ntohs(*p));
 	}
 
-	if (!(rt = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
-					 0, (IP_VS_RT_MODE_LOCAL |
-					     IP_VS_RT_MODE_NON_LOCAL |
-					     IP_VS_RT_MODE_RDR))))
-		goto tx_error_icmp;
-	local = __ip_vs_is_local_route6(rt);
+	local = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
+				      ipvsh, 0,
+				      IP_VS_RT_MODE_LOCAL |
+				      IP_VS_RT_MODE_NON_LOCAL |
+				      IP_VS_RT_MODE_RDR);
+	if (local < 0)
+		goto tx_error;
+	rt = (struct rt6_info *) skb_dst(skb);
 	/*
 	 * Avoid duplicate tuple in reply direction for NAT traffic
 	 * to local address when connection is sync-ed
@@ -647,7 +671,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 			IP_VS_DBG_RL_PKT(10, AF_INET6, pp, skb, 0,
 					 "ip_vs_nat_xmit_v6(): "
 					 "stopping DNAT to local address");
-			goto tx_error_put;
+			goto tx_error;
 		}
 	}
 #endif
@@ -658,45 +682,21 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		IP_VS_DBG_RL_PKT(1, AF_INET6, pp, skb, 0,
 				 "ip_vs_nat_xmit_v6(): "
 				 "stopping DNAT to loopback address");
-		goto tx_error_put;
-	}
-
-	/* MTU checking */
-	mtu = dst_mtu(&rt->dst);
-	if (__mtu_check_toobig_v6(skb, mtu)) {
-		if (!skb->dev) {
-			struct net *net = dev_net(skb_dst(skb)->dev);
-
-			skb->dev = net->loopback_dev;
-		}
-		/* only send ICMP too big on first fragment */
-		if (!iph->fragoffs)
-			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
-		IP_VS_DBG_RL_PKT(0, AF_INET6, pp, skb, 0,
-				 "ip_vs_nat_xmit_v6(): frag needed for");
-		goto tx_error_put;
+		goto tx_error;
 	}
 
 	/* copy-on-write the packet before mangling it */
 	if (!skb_make_writable(skb, sizeof(struct ipv6hdr)))
-		goto tx_error_put;
+		goto tx_error;
 
 	if (skb_cow(skb, rt->dst.dev->hard_header_len))
-		goto tx_error_put;
+		goto tx_error;
 
 	/* mangle the packet */
-	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp, iph))
+	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp, ipvsh))
 		goto tx_error;
 	ipv6_hdr(skb)->daddr = cp->daddr.in6;
 
-	if (!local || !skb->dev) {
-		skb_dst_drop(skb);
-		skb_dst_set(skb, &rt->dst);
-	} else {
-		/* destined to loopback, do we need to change route? */
-		dst_release(&rt->dst);
-	}
-
 	IP_VS_DBG_PKT(10, AF_INET6, pp, skb, 0, "After DNAT");
 
 	/* FIXME: when application helper enlarges the packet and the length
@@ -711,15 +711,10 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	LeaveFunction(10);
 	return rc;
 
-tx_error_icmp:
-	dst_link_failure(skb);
 tx_error:
 	LeaveFunction(10);
 	kfree_skb(skb);
 	return NF_STOLEN;
-tx_error_put:
-	dst_release(&rt->dst);
-	goto tx_error;
 }
 #endif
 
@@ -756,40 +751,26 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	__be16 df;
 	struct iphdr  *iph;			/* Our new IP header */
 	unsigned int max_headroom;		/* The extra header space needed */
-	int    mtu;
-	int ret;
+	int ret, local;
 
 	EnterFunction(10);
 
-	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
-				      IP_VS_RT_MODE_LOCAL |
-				      IP_VS_RT_MODE_NON_LOCAL |
-				      IP_VS_RT_MODE_CONNECT, &saddr)))
-		goto tx_error_icmp;
-	if (rt->rt_flags & RTCF_LOCAL) {
-		ip_rt_put(rt);
+	local = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
+				   IP_VS_RT_MODE_LOCAL |
+				   IP_VS_RT_MODE_NON_LOCAL |
+				   IP_VS_RT_MODE_CONNECT |
+				   IP_VS_RT_MODE_TUNNEL, &saddr);
+	if (local < 0)
+		goto tx_error;
+	if (local)
 		return ip_vs_send_or_cont(NFPROTO_IPV4, skb, cp, 1);
-	}
 
+	rt = skb_rtable(skb);
 	tdev = rt->dst.dev;
 
-	mtu = dst_mtu(&rt->dst) - sizeof(struct iphdr);
-	if (mtu < 68) {
-		IP_VS_DBG_RL("%s(): mtu less than 68\n", __func__);
-		goto tx_error_put;
-	}
-	if (rt_is_output_route(skb_rtable(skb)))
-		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
-
 	/* Copy DF, reset fragment offset and MF */
 	df = sysctl_pmtu_disc(ipvs) ? old_iph->frag_off & htons(IP_DF) : 0;
 
-	if (df && mtu < ntohs(old_iph->tot_len) && !skb_is_gso(skb)) {
-		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
-		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
-		goto tx_error_put;
-	}
-
 	/*
 	 * Okay, now see if we can stuff it in the buffer as-is.
 	 */
@@ -798,12 +779,9 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	if (skb_headroom(skb) < max_headroom || skb_cloned(skb)) {
 		struct sk_buff *new_skb =
 			skb_realloc_headroom(skb, max_headroom);
-		if (!new_skb) {
-			ip_rt_put(rt);
-			kfree_skb(skb);
-			IP_VS_ERR_RL("%s(): no memory\n", __func__);
-			return NF_STOLEN;
-		}
+
+		if (!new_skb)
+			goto tx_error;
 		consume_skb(skb);
 		skb = new_skb;
 		old_iph = ip_hdr(skb);
@@ -818,10 +796,6 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	skb_reset_network_header(skb);
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 
-	/* drop old route */
-	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->dst);
-
 	/*
 	 *	Push down and install the IPIP header.
 	 */
@@ -849,15 +823,10 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	return NF_STOLEN;
 
-  tx_error_icmp:
-	dst_link_failure(skb);
   tx_error:
 	kfree_skb(skb);
 	LeaveFunction(10);
 	return NF_STOLEN;
-tx_error_put:
-	ip_rt_put(rt);
-	goto tx_error;
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -871,45 +840,23 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	struct ipv6hdr  *old_iph = ipv6_hdr(skb);
 	struct ipv6hdr  *iph;		/* Our new IP header */
 	unsigned int max_headroom;	/* The extra header space needed */
-	int    mtu;
-	int ret;
+	int ret, local;
 
 	EnterFunction(10);
 
-	if (!(rt = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6,
-					 &saddr, 1, (IP_VS_RT_MODE_LOCAL |
-						     IP_VS_RT_MODE_NON_LOCAL))))
-		goto tx_error_icmp;
-	if (__ip_vs_is_local_route6(rt)) {
-		dst_release(&rt->dst);
+	local = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6,
+				      &saddr, ipvsh, 1,
+				      IP_VS_RT_MODE_LOCAL |
+				      IP_VS_RT_MODE_NON_LOCAL |
+				      IP_VS_RT_MODE_TUNNEL);
+	if (local < 0)
+		goto tx_error;
+	if (local)
 		return ip_vs_send_or_cont(NFPROTO_IPV6, skb, cp, 1);
-	}
 
+	rt = (struct rt6_info *) skb_dst(skb);
 	tdev = rt->dst.dev;
 
-	mtu = dst_mtu(&rt->dst) - sizeof(struct ipv6hdr);
-	if (mtu < IPV6_MIN_MTU) {
-		IP_VS_DBG_RL("%s(): mtu less than %d\n", __func__,
-			     IPV6_MIN_MTU);
-		goto tx_error_put;
-	}
-	if (skb_dst(skb))
-		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
-
-	/* MTU checking: Notice that 'mtu' have been adjusted before hand */
-	if (__mtu_check_toobig_v6(skb, mtu)) {
-		if (!skb->dev) {
-			struct net *net = dev_net(skb_dst(skb)->dev);
-
-			skb->dev = net->loopback_dev;
-		}
-		/* only send ICMP too big on first fragment */
-		if (!ipvsh->fragoffs)
-			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
-		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
-		goto tx_error_put;
-	}
-
 	/*
 	 * Okay, now see if we can stuff it in the buffer as-is.
 	 */
@@ -918,12 +865,9 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	if (skb_headroom(skb) < max_headroom || skb_cloned(skb)) {
 		struct sk_buff *new_skb =
 			skb_realloc_headroom(skb, max_headroom);
-		if (!new_skb) {
-			dst_release(&rt->dst);
-			kfree_skb(skb);
-			IP_VS_ERR_RL("%s(): no memory\n", __func__);
-			return NF_STOLEN;
-		}
+
+		if (!new_skb)
+			goto tx_error;
 		consume_skb(skb);
 		skb = new_skb;
 		old_iph = ipv6_hdr(skb);
@@ -935,10 +879,6 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	skb_reset_network_header(skb);
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 
-	/* drop old route */
-	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->dst);
-
 	/*
 	 *	Push down and install the IPIP header.
 	 */
@@ -966,15 +906,10 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	return NF_STOLEN;
 
-tx_error_icmp:
-	dst_link_failure(skb);
 tx_error:
 	kfree_skb(skb);
 	LeaveFunction(10);
 	return NF_STOLEN;
-tx_error_put:
-	dst_release(&rt->dst);
-	goto tx_error;
 }
 #endif
 
@@ -987,38 +922,21 @@ int
 ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	      struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
-	struct rtable *rt;			/* Route to the other host */
-	struct iphdr  *iph = ip_hdr(skb);
-	int    mtu;
+	int local;
 
 	EnterFunction(10);
 
-	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
-				      IP_VS_RT_MODE_LOCAL |
-				      IP_VS_RT_MODE_NON_LOCAL |
-				      IP_VS_RT_MODE_KNOWN_NH, NULL)))
-		goto tx_error_icmp;
-	if (rt->rt_flags & RTCF_LOCAL) {
-		ip_rt_put(rt);
-		return ip_vs_send_or_cont(NFPROTO_IPV4, skb, cp, 1);
-	}
-
-	/* MTU checking */
-	mtu = dst_mtu(&rt->dst);
-	if ((iph->frag_off & htons(IP_DF)) && skb->len > mtu &&
-	    !skb_is_gso(skb)) {
-		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
-		ip_rt_put(rt);
-		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
+	local = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
+				   IP_VS_RT_MODE_LOCAL |
+				   IP_VS_RT_MODE_NON_LOCAL |
+				   IP_VS_RT_MODE_KNOWN_NH, NULL);
+	if (local < 0)
 		goto tx_error;
-	}
+	if (local)
+		return ip_vs_send_or_cont(NFPROTO_IPV4, skb, cp, 1);
 
 	ip_send_check(ip_hdr(skb));
 
-	/* drop old route */
-	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->dst);
-
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
@@ -1027,8 +945,6 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	LeaveFunction(10);
 	return NF_STOLEN;
 
-  tx_error_icmp:
-	dst_link_failure(skb);
   tx_error:
 	kfree_skb(skb);
 	LeaveFunction(10);
@@ -1038,41 +954,20 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		 struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph)
+		 struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
-	struct rt6_info *rt;			/* Route to the other host */
-	int    mtu;
+	int local;
 
 	EnterFunction(10);
 
-	if (!(rt = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
-					 0, (IP_VS_RT_MODE_LOCAL |
-					     IP_VS_RT_MODE_NON_LOCAL))))
-		goto tx_error_icmp;
-	if (__ip_vs_is_local_route6(rt)) {
-		dst_release(&rt->dst);
-		return ip_vs_send_or_cont(NFPROTO_IPV6, skb, cp, 1);
-	}
-
-	/* MTU checking */
-	mtu = dst_mtu(&rt->dst);
-	if (__mtu_check_toobig_v6(skb, mtu)) {
-		if (!skb->dev) {
-			struct net *net = dev_net(skb_dst(skb)->dev);
-
-			skb->dev = net->loopback_dev;
-		}
-		/* only send ICMP too big on first fragment */
-		if (!iph->fragoffs)
-			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
-		dst_release(&rt->dst);
-		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
+	local = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
+				      ipvsh, 0,
+				      IP_VS_RT_MODE_LOCAL |
+				      IP_VS_RT_MODE_NON_LOCAL);
+	if (local < 0)
 		goto tx_error;
-	}
-
-	/* drop old route */
-	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->dst);
+	if (local)
+		return ip_vs_send_or_cont(NFPROTO_IPV6, skb, cp, 1);
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
@@ -1082,8 +977,6 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	LeaveFunction(10);
 	return NF_STOLEN;
 
-tx_error_icmp:
-	dst_link_failure(skb);
 tx_error:
 	kfree_skb(skb);
 	LeaveFunction(10);
@@ -1102,10 +995,9 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		struct ip_vs_iphdr *iph)
 {
 	struct rtable	*rt;	/* Route to the other host */
-	int mtu;
 	int rc;
 	int local;
-	int rt_mode;
+	int rt_mode, was_input;
 
 	EnterFunction(10);
 
@@ -1125,15 +1017,16 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/*
 	 * mangle and send the packet here (only for VS/NAT)
 	 */
+	was_input = rt_is_input_route(skb_rtable(skb));
 
 	/* LOCALNODE from FORWARD hook is not supported */
 	rt_mode = (hooknum != NF_INET_FORWARD) ?
 		  IP_VS_RT_MODE_LOCAL | IP_VS_RT_MODE_NON_LOCAL |
 		  IP_VS_RT_MODE_RDR : IP_VS_RT_MODE_NON_LOCAL;
-	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
-				      rt_mode, NULL)))
-		goto tx_error_icmp;
-	local = rt->rt_flags & RTCF_LOCAL;
+	local = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip, rt_mode, NULL);
+	if (local < 0)
+		goto tx_error;
+	rt = skb_rtable(skb);
 
 	/*
 	 * Avoid duplicate tuple in reply direction for NAT traffic
@@ -1148,71 +1041,49 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 			IP_VS_DBG(10, "%s(): "
 				  "stopping DNAT to local address %pI4\n",
 				  __func__, &cp->daddr.ip);
-			goto tx_error_put;
+			goto tx_error;
 		}
 	}
 #endif
 
 	/* From world but DNAT to loopback address? */
-	if (local && ipv4_is_loopback(cp->daddr.ip) &&
-	    rt_is_input_route(skb_rtable(skb))) {
+	if (local && ipv4_is_loopback(cp->daddr.ip) && was_input) {
 		IP_VS_DBG(1, "%s(): "
 			  "stopping DNAT to loopback %pI4\n",
 			  __func__, &cp->daddr.ip);
-		goto tx_error_put;
-	}
-
-	/* MTU checking */
-	mtu = dst_mtu(&rt->dst);
-	if ((skb->len > mtu) && (ip_hdr(skb)->frag_off & htons(IP_DF)) &&
-	    !skb_is_gso(skb)) {
-		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
-		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
-		goto tx_error_put;
+		goto tx_error;
 	}
 
 	/* copy-on-write the packet before mangling it */
 	if (!skb_make_writable(skb, offset))
-		goto tx_error_put;
+		goto tx_error;
 
 	if (skb_cow(skb, rt->dst.dev->hard_header_len))
-		goto tx_error_put;
+		goto tx_error;
 
 	ip_vs_nat_icmp(skb, pp, cp, 0);
 
-	if (!local) {
-		skb_dst_drop(skb);
-		skb_dst_set(skb, &rt->dst);
-	} else
-		ip_rt_put(rt);
-
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
 	rc = ip_vs_nat_send_or_cont(NFPROTO_IPV4, skb, cp, local);
 	goto out;
 
-  tx_error_icmp:
-	dst_link_failure(skb);
   tx_error:
 	dev_kfree_skb(skb);
 	rc = NF_STOLEN;
   out:
 	LeaveFunction(10);
 	return rc;
-  tx_error_put:
-	ip_rt_put(rt);
-	goto tx_error;
 }
 
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		struct ip_vs_protocol *pp, int offset, unsigned int hooknum,
-		struct ip_vs_iphdr *iph)
+		struct ip_vs_iphdr *ipvsh)
 {
 	struct rt6_info	*rt;	/* Route to the other host */
-	int mtu;
 	int rc;
 	int local;
 	int rt_mode;
@@ -1224,7 +1095,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	   translate address/port back */
 	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ) {
 		if (cp->packet_xmit)
-			rc = cp->packet_xmit(skb, cp, pp, iph);
+			rc = cp->packet_xmit(skb, cp, pp, ipvsh);
 		else
 			rc = NF_ACCEPT;
 		/* do not touch skb anymore */
@@ -1240,11 +1111,11 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	rt_mode = (hooknum != NF_INET_FORWARD) ?
 		  IP_VS_RT_MODE_LOCAL | IP_VS_RT_MODE_NON_LOCAL |
 		  IP_VS_RT_MODE_RDR : IP_VS_RT_MODE_NON_LOCAL;
-	if (!(rt = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
-					 0, rt_mode)))
-		goto tx_error_icmp;
-
-	local = __ip_vs_is_local_route6(rt);
+	local = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
+				      ipvsh, 0, rt_mode);
+	if (local < 0)
+		goto tx_error;
+	rt = (struct rt6_info *) skb_dst(skb);
 	/*
 	 * Avoid duplicate tuple in reply direction for NAT traffic
 	 * to local address when connection is sync-ed
@@ -1258,7 +1129,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 			IP_VS_DBG(10, "%s(): "
 				  "stopping DNAT to local address %pI6\n",
 				  __func__, &cp->daddr.in6);
-			goto tx_error_put;
+			goto tx_error;
 		}
 	}
 #endif
@@ -1269,57 +1140,29 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		IP_VS_DBG(1, "%s(): "
 			  "stopping DNAT to loopback %pI6\n",
 			  __func__, &cp->daddr.in6);
-		goto tx_error_put;
-	}
-
-	/* MTU checking */
-	mtu = dst_mtu(&rt->dst);
-	if (__mtu_check_toobig_v6(skb, mtu)) {
-		if (!skb->dev) {
-			struct net *net = dev_net(skb_dst(skb)->dev);
-
-			skb->dev = net->loopback_dev;
-		}
-		/* only send ICMP too big on first fragment */
-		if (!iph->fragoffs)
-			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
-		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
-		goto tx_error_put;
+		goto tx_error;
 	}
 
 	/* copy-on-write the packet before mangling it */
 	if (!skb_make_writable(skb, offset))
-		goto tx_error_put;
+		goto tx_error;
 
 	if (skb_cow(skb, rt->dst.dev->hard_header_len))
-		goto tx_error_put;
+		goto tx_error;
 
 	ip_vs_nat_icmp_v6(skb, pp, cp, 0);
 
-	if (!local || !skb->dev) {
-		skb_dst_drop(skb);
-		skb_dst_set(skb, &rt->dst);
-	} else {
-		/* destined to loopback, do we need to change route? */
-		dst_release(&rt->dst);
-	}
