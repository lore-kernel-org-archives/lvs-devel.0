From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH RFC] ipvs: local routes, DNAT and other fixes
Date: Mon, 4 Oct 2010 01:57:50 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010040142580.2597@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; format="flowed"; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org


 	This is a test patch with many changes that should be
separated later.

 	New features:

- DNAT to local address (different real server port), even for
local client. It needs ip_vs_out hook in LOCAL_OUT for both
families because skb->protocol is not set for locally
generated packets and can not be used to set 'af'. Add support
for changing the route to local IPv4 stack after DNAT
depending on the source address type. Local client sets output
route and the remote client sets input route. It looks like
IPv6 does not need such rerouting because the replies use
addresses from initial incoming header, not from skb route.

- Change skb->ipvs_property semantic. ip_vs_out is now
used in LOCAL_OUT, so use ipvs_property to avoid expensive
loops for traffic sent by transmitters. Now when conntrack
support is not needed we use ip_vs_notrack method to avoid
problems in all hooks instead of exiting POST_ROUTING.

- All transmitters now have strict checks for the destination
address type. LOCALNODE is not set explicitly as forwarding
method in real server to allow the connections to provide
correct forwarding method to the backup server. Not sure if
this breaks tools that expect to see 'Local' real server type.
If needed, this can be supported with new flag IP_VS_DEST_F_LOCAL.
Now it should be possible connections in backup that lost
their fwmark information during sync to be forwarded properly
to their daddr, even if it is local address in the backup server.
By this way backup could be used as real server for DR or TUN,
for NAT there are some restrictions because some collisions
in conntracks can create problems for the traffic.

 	Optmizations:

- avoid full checksum calculation for apps that can provide info
whether csum was broken after payload mangling. For now only
ip_vs_ftp mangles payload and it updates the csum, so the full
recalculation is avoided for all packets.

 	Fixes:

- CHECKSUM_PARTIAL handling was broken, may be nobody tested it.
Works for IPv4 TCP, UDP not tested because it needs network card
with HW CSUM support. May be fixes problem where IPVS can not be
used in virtual boxes. Problem appears with DNAT to local address
when the local stack sends reply in CHECKSUM_PARTIAL mode.

- ICMP in FORWARD hook should not try local delivery

- Call ip_vs_dst_reset when destination is updated in case
some real server IP type is changed between local and remote.

- Connections in backup should inherit the forwarding method
from real server

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

 	This applies with SIP PE changes and without them,
it seems there are no collisions. Needs IPv6 testing,
eg. DNAT to local real server IP.

diff -urp net-next-2.6-e548833-nfct_snat_reroute-ipv6dst/linux/include/net/ip_vs.h linux/include/net/ip_vs.h
--- net-next-2.6-e548833-nfct_snat_reroute-ipv6dst/linux/include/net/ip_vs.h	2010-09-22 10:50:18.548963467 +0300
+++ linux/include/net/ip_vs.h	2010-10-03 08:43:33.190352624 +0300
@@ -25,7 +25,7 @@
  #include <linux/ip.h>
  #include <linux/ipv6.h>			/* for struct ipv6hdr */
  #include <net/ipv6.h>			/* for ipv6_addr_copy */
-#ifdef CONFIG_IP_VS_NFCT
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
  #include <net/netfilter/nf_conntrack.h>
  #endif

@@ -562,11 +562,19 @@ struct ip_vs_app {
  	__be16			port;		/* port number in net order */
  	atomic_t		usecnt;		/* usage counter */

-	/* output hook: return false if can't linearize. diff set for TCP.  */
+	/*
+	 * output hook: Process packet in inout direction, diff set for TCP.
+	 * Return: 0=Error, 1=Payload Not Mangled/Mangled but checksum is ok,
+	 *	   2=Mangled but checksum was not updated
+	 */
  	int (*pkt_out)(struct ip_vs_app *, struct ip_vs_conn *,
  		       struct sk_buff *, int *diff);

-	/* input hook: return false if can't linearize. diff set for TCP. */
+	/*
+	 * input hook: Process packet in outin direction, diff set for TCP.
+	 * Return: 0=Error, 1=Payload Not Mangled/Mangled but checksum is ok,
+	 *	   2=Mangled but checksum was not updated
+	 */
  	int (*pkt_in)(struct ip_vs_app *, struct ip_vs_conn *,
  		      struct sk_buff *, int *diff);

@@ -963,6 +971,19 @@ static inline __wsum ip_vs_check_diff2(_
  	return csum_partial(diff, sizeof(diff), oldsum);
  }

+/*
+ * Forget current conntrack (unconfirmed) and attach notrack entry
+ */
+static inline void ip_vs_notrack(struct sk_buff *skb)
+{
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+	nf_reset(skb);
+	skb->nfct = &nf_ct_untracked_get()->ct_general;
+	skb->nfctinfo = IP_CT_NEW;
+	nf_conntrack_get(skb->nfct);
+#endif
+}
+
  #ifdef CONFIG_IP_VS_NFCT
  /*
   *      Netfilter connection tracking
diff -urp net-next-2.6-e548833-nfct_snat_reroute-ipv6dst/linux/net/netfilter/ipvs/ip_vs_conn.c linux/net/netfilter/ipvs/ip_vs_conn.c
--- net-next-2.6-e548833-nfct_snat_reroute-ipv6dst/linux/net/netfilter/ipvs/ip_vs_conn.c	2010-09-16 09:02:25.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_conn.c	2010-09-30 02:22:06.136378465 +0300
@@ -524,6 +524,8 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, s
  		 */
  		if (!(cp->flags & IP_VS_CONN_F_TEMPLATE))
  			conn_flags &= ~IP_VS_CONN_F_INACTIVE;
+		/* connections inherit forwarding method from dest */
+		cp->flags &= ~IP_VS_CONN_F_FWD_MASK;
  	}
  	cp->flags |= conn_flags;
  	cp->dest = dest;
diff -urp net-next-2.6-e548833-nfct_snat_reroute-ipv6dst/linux/net/netfilter/ipvs/ip_vs_core.c linux/net/netfilter/ipvs/ip_vs_core.c
--- net-next-2.6-e548833-nfct_snat_reroute-ipv6dst/linux/net/netfilter/ipvs/ip_vs_core.c	2010-09-16 09:07:13.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_core.c	2010-10-04 01:51:48.154354539 +0300
@@ -48,6 +48,7 @@
  #ifdef CONFIG_IP_VS_IPV6
  #include <net/ipv6.h>
  #include <linux/netfilter_ipv6.h>
+#include <net/ip6_route.h>
  #endif

  #include <net/ip_vs.h>
@@ -537,23 +538,6 @@ int ip_vs_leave(struct ip_vs_service *sv
  	return NF_DROP;
  }

-/*
- * It is hooked before NF_IP_PRI_NAT_SRC at the NF_INET_POST_ROUTING
- * chain and is used to avoid double NAT and confirmation when we do
- * not want to keep the conntrack structure
- */
-static unsigned int ip_vs_post_routing(unsigned int hooknum,
-				       struct sk_buff *skb,
-				       const struct net_device *in,
-				       const struct net_device *out,
-				       int (*okfn)(struct sk_buff *))
-{
-	if (!skb->ipvs_property)
-		return NF_ACCEPT;
-	/* The packet was sent from IPVS, exit this chain */
-	return NF_STOP;
-}
-
  __sum16 ip_vs_checksum_complete(struct sk_buff *skb, int offset)
  {
  	return csum_fold(skb_checksum(skb, offset, skb->len - offset, 0));
@@ -712,8 +696,9 @@ static int handle_response_icmp(int af,
  	/* do the statistics and put it back */
  	ip_vs_out_stats(cp, skb);

+	skb->ipvs_property = 1;
  	if (!(cp->flags & IP_VS_CONN_F_NFCT))
-		skb->ipvs_property = 1;
+		ip_vs_notrack(skb);
  	else
  		ip_vs_update_conntrack(skb, cp, 0);
  	verdict = NF_ACCEPT;
@@ -959,8 +944,9 @@ handle_response(int af, struct sk_buff *

  	ip_vs_out_stats(cp, skb);
  	ip_vs_set_state(cp, IP_VS_DIR_OUTPUT, skb, pp);
+	skb->ipvs_property = 1;
  	if (!(cp->flags & IP_VS_CONN_F_NFCT))
-		skb->ipvs_property = 1;
+		ip_vs_notrack(skb);
  	else
  		ip_vs_update_conntrack(skb, cp, 0);
  	ip_vs_conn_put(cp);
@@ -976,23 +962,18 @@ drop:
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
+	/* Already inspected by IPVS? */
  	if (skb->ipvs_property)
  		return NF_ACCEPT;

@@ -1098,13 +1079,42 @@ ip_vs_out(unsigned int hooknum, struct s
  			}
  		}
  		IP_VS_DBG_PKT(12, pp, skb, 0,
-			      "packet continues traversal as normal");
+			      "ip_vs_out: packet continues traversal as normal");
  		return NF_ACCEPT;
  	}

  	return handle_response(af, skb, pp, cp, iph.len);
  }

+/*
+ *	It is hooked at the NF_INET_FORWARD and NF_INET_LOCAL_OUT chain,
+ *	used only for VS/NAT.
+ *	Check if outgoing packet belongs to the established ip_vs_conn.
+ */
+static unsigned int
+ip_vs_out4(unsigned int hooknum, struct sk_buff *skb,
+	  const struct net_device *in, const struct net_device *out,
+	  int (*okfn)(struct sk_buff *))
+{
+	return ip_vs_out(hooknum, skb, AF_INET);
+}
+
+#ifdef CONFIG_IP_VS_IPV6
+
+/*
+ *	It is hooked at the NF_INET_FORWARD and NF_INET_LOCAL_OUT chain,
+ *	used only for VS/NAT.
+ *	Check if outgoing packet belongs to the established ip_vs_conn.
+ */
+static unsigned int
+ip_vs_out6(unsigned int hooknum, struct sk_buff *skb,
+	  const struct net_device *in, const struct net_device *out,
+	  int (*okfn)(struct sk_buff *))
+{
+	return ip_vs_out(hooknum, skb, AF_INET6);
+}
+
+#endif

  /*
   *	Handle ICMP messages in the outside-to-inside direction (incoming).
@@ -1206,7 +1216,14 @@ ip_vs_in_icmp(struct sk_buff *skb, int *
  	if (IPPROTO_TCP == cih->protocol || IPPROTO_UDP == cih->protocol)
  		offset += 2 * sizeof(__u16);
  	verdict = ip_vs_icmp_xmit(skb, cp, pp, offset);
-	/* do not touch skb anymore */
+	/* LOCALNODE from FORWARD hook is not supported */
+	if (verdict == NF_ACCEPT && hooknum != NF_INET_LOCAL_IN &&
+	    skb_rtable(skb)->rt_flags & RTCF_LOCAL) {
+		IP_VS_DBG(1, "%s(): "
+			  "local delivery to %pI4 but not in LOCAL_IN\n",
+			  __func__, &skb_rtable(skb)->rt_dst);
+		verdict = NF_DROP;
+	}

    out:
  	__ip_vs_conn_put(cp);
@@ -1227,6 +1244,7 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, in
  	struct ip_vs_protocol *pp;
  	unsigned int offset, verdict;
  	union nf_inet_addr snet;
+	struct rt6_info *rt;

  	*related = 1;

@@ -1305,7 +1323,15 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, in
  	    IPPROTO_SCTP == cih->nexthdr)
  		offset += 2 * sizeof(__u16);
  	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, offset);
-	/* do not touch skb anymore */
+	/* LOCALNODE from FORWARD hook is not supported */
+	if (verdict == NF_ACCEPT && hooknum != NF_INET_LOCAL_IN &&
+	    (rt = (struct rt6_info *) skb_dst(skb)) &&
+	    rt->rt6i_dev && rt->rt6i_dev->flags & IFF_LOOPBACK) {
+		IP_VS_DBG(1, "%s(): "
+			  "local delivery to %pI6 but not in LOCAL_IN\n",
+			  __func__, &rt->rt6i_dst);
+		verdict = NF_DROP;
+	}

  	__ip_vs_conn_put(cp);

@@ -1388,7 +1414,7 @@ ip_vs_in(unsigned int hooknum, struct sk
  	if (unlikely(!cp)) {
  		/* sorry, all this trouble for a no-hit :) */
  		IP_VS_DBG_PKT(12, pp, skb, 0,
-			      "packet continues traversal as normal");
+			      "ip_vs_in: packet continues traversal as normal");
  		return NF_ACCEPT;
  	}

@@ -1511,12 +1537,20 @@ static struct nf_hook_ops ip_vs_ops[] __
  	},
  	/* After packet filtering, change source only for VS/NAT */
  	{
-		.hook		= ip_vs_out,
+		.hook		= ip_vs_out4,
  		.owner		= THIS_MODULE,
  		.pf		= PF_INET,
  		.hooknum        = NF_INET_FORWARD,
  		.priority       = 100,
  	},
+	/* Before confirm, change source only for VS/NAT */
+	{
+		.hook		= ip_vs_out4,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET,
+		.hooknum        = NF_INET_LOCAL_OUT,
+		.priority       = NF_IP_PRI_CONNTRACK_CONFIRM - 1,
+	},
  	/* After packet filtering (but before ip_vs_out_icmp), catch icmp
  	 * destined for 0.0.0.0/0, which is for incoming IPVS connections */
  	{
@@ -1526,14 +1560,6 @@ static struct nf_hook_ops ip_vs_ops[] __
  		.hooknum        = NF_INET_FORWARD,
  		.priority       = 99,
  	},
-	/* Before the netfilter connection tracking, exit from POST_ROUTING */
-	{
-		.hook		= ip_vs_post_routing,
-		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
-		.hooknum        = NF_INET_POST_ROUTING,
-		.priority       = NF_IP_PRI_NAT_SRC-1,
-	},
  #ifdef CONFIG_IP_VS_IPV6
  	/* After packet filtering, forward packet through VS/DR, VS/TUN,
  	 * or VS/NAT(change destination), so that filtering rules can be
@@ -1547,12 +1573,20 @@ static struct nf_hook_ops ip_vs_ops[] __
  	},
  	/* After packet filtering, change source only for VS/NAT */
  	{
-		.hook		= ip_vs_out,
+		.hook		= ip_vs_out6,
  		.owner		= THIS_MODULE,
  		.pf		= PF_INET6,
  		.hooknum        = NF_INET_FORWARD,
  		.priority       = 100,
  	},
+	/* Before confirm, change source only for VS/NAT */
+	{
+		.hook		= ip_vs_out6,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET6,
+		.hooknum        = NF_INET_LOCAL_OUT,
+		.priority       = NF_IP6_PRI_LAST - 2,
+	},
  	/* After packet filtering (but before ip_vs_out_icmp), catch icmp
  	 * destined for 0.0.0.0/0, which is for incoming IPVS connections */
  	{
@@ -1562,14 +1596,6 @@ static struct nf_hook_ops ip_vs_ops[] __
  		.hooknum        = NF_INET_FORWARD,
  		.priority       = 99,
  	},
-	/* Before the netfilter connection tracking, exit from POST_ROUTING */
-	{
-		.hook		= ip_vs_post_routing,
-		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
-		.hooknum        = NF_INET_POST_ROUTING,
-		.priority       = NF_IP6_PRI_NAT_SRC-1,
-	},
  #endif
  };

diff -urp net-next-2.6-e548833-nfct_snat_reroute-ipv6dst/linux/net/netfilter/ipvs/ip_vs_ctl.c linux/net/netfilter/ipvs/ip_vs_ctl.c
--- net-next-2.6-e548833-nfct_snat_reroute-ipv6dst/linux/net/netfilter/ipvs/ip_vs_ctl.c	2010-10-03 06:27:49.122352626 +0300
+++ linux/net/netfilter/ipvs/ip_vs_ctl.c	2010-10-03 09:03:03.196356022 +0300
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

diff -urp net-next-2.6-e548833-nfct_snat_reroute-ipv6dst/linux/net/netfilter/ipvs/ip_vs_ftp.c linux/net/netfilter/ipvs/ip_vs_ftp.c
--- net-next-2.6-e548833-nfct_snat_reroute-ipv6dst/linux/net/netfilter/ipvs/ip_vs_ftp.c	2010-09-16 09:02:25.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_ftp.c	2010-09-30 01:53:02.341378005 +0300
@@ -238,9 +238,14 @@ static int ip_vs_ftp_out(struct ip_vs_ap
  			ret = nf_nat_mangle_tcp_packet(skb, ct, ctinfo,
  						       start-data, end-start,
  						       buf, buf_len);
-			if (ret)
+			if (ret) {
  				ip_vs_nfct_expect_related(skb, ct, n_cp,
  							  IPPROTO_TCP, 0, 0);
+				if (skb->ip_summed == CHECKSUM_COMPLETE)
+					skb->ip_summed = CHECKSUM_UNNECESSARY;
+				/* csum is updated */
+				ret = 1;
+			}
  		}

  		/*
diff -urp net-next-2.6-e548833-nfct_snat_reroute-ipv6dst/linux/net/netfilter/ipvs/ip_vs_proto_tcp.c linux/net/netfilter/ipvs/ip_vs_proto_tcp.c
--- net-next-2.6-e548833-nfct_snat_reroute-ipv6dst/linux/net/netfilter/ipvs/ip_vs_proto_tcp.c	2010-09-10 08:27:33.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_proto_tcp.c	2010-10-03 19:19:43.388547265 +0300
@@ -101,15 +101,15 @@ tcp_partial_csum_update(int af, struct t
  #ifdef CONFIG_IP_VS_IPV6
  	if (af == AF_INET6)
  		tcph->check =
-			csum_fold(ip_vs_check_diff16(oldip->ip6, newip->ip6,
+			~csum_fold(ip_vs_check_diff16(oldip->ip6, newip->ip6,
  					 ip_vs_check_diff2(oldlen, newlen,
-						~csum_unfold(tcph->check))));
+						csum_unfold(tcph->check))));
  	else
  #endif
  	tcph->check =
-		csum_fold(ip_vs_check_diff4(oldip->ip, newip->ip,
+		~csum_fold(ip_vs_check_diff4(oldip->ip, newip->ip,
  				ip_vs_check_diff2(oldlen, newlen,
-						~csum_unfold(tcph->check))));
+						csum_unfold(tcph->check))));
  }


@@ -120,6 +120,7 @@ tcp_snat_handler(struct sk_buff *skb,
  	struct tcphdr *tcph;
  	unsigned int tcphoff;
  	int oldlen;
+	int payload_csum = 0;

  #ifdef CONFIG_IP_VS_IPV6
  	if (cp->af == AF_INET6)
@@ -134,13 +135,20 @@ tcp_snat_handler(struct sk_buff *skb,
  		return 0;

  	if (unlikely(cp->app != NULL)) {
+		int ret;
+
  		/* Some checks before mangling */
  		if (pp->csum_check && !pp->csum_check(cp->af, skb, pp))
  			return 0;

  		/* Call application helper if needed */
-		if (!ip_vs_app_pkt_out(cp, skb))
+		if (!(ret = ip_vs_app_pkt_out(cp, skb)))
  			return 0;
+		/* ret=2: csum update is needed after payload mangling */
+		if (ret == 1)
+			oldlen = skb->len - tcphoff;
+		else
+			payload_csum = 1;
  	}

  	tcph = (void *)skb_network_header(skb) + tcphoff;
@@ -151,12 +159,13 @@ tcp_snat_handler(struct sk_buff *skb,
  		tcp_partial_csum_update(cp->af, tcph, &cp->daddr, &cp->vaddr,
  					htons(oldlen),
  					htons(skb->len - tcphoff));
-	} else if (!cp->app) {
+	} else if (!payload_csum) {
  		/* Only port and addr are changed, do fast csum update */
  		tcp_fast_csum_update(cp->af, tcph, &cp->daddr, &cp->vaddr,
  				     cp->dport, cp->vport);
  		if (skb->ip_summed == CHECKSUM_COMPLETE)
-			skb->ip_summed = CHECKSUM_NONE;
+			skb->ip_summed = (cp->app && pp->csum_check) ?
+					 CHECKSUM_UNNECESSARY : CHECKSUM_NONE;
  	} else {
  		/* full checksum calculation */
  		tcph->check = 0;
@@ -174,6 +183,7 @@ tcp_snat_handler(struct sk_buff *skb,
  							skb->len - tcphoff,
  							cp->protocol,
  							skb->csum);
+		skb->ip_summed = CHECKSUM_UNNECESSARY;

  		IP_VS_DBG(11, "O-pkt: %s O-csum=%d (+%zd)\n",
  			  pp->name, tcph->check,
@@ -190,6 +200,7 @@ tcp_dnat_handler(struct sk_buff *skb,
  	struct tcphdr *tcph;
  	unsigned int tcphoff;
  	int oldlen;
+	int payload_csum = 0;

  #ifdef CONFIG_IP_VS_IPV6
  	if (cp->af == AF_INET6)
@@ -204,6 +215,8 @@ tcp_dnat_handler(struct sk_buff *skb,
  		return 0;

  	if (unlikely(cp->app != NULL)) {
+		int ret;
+
  		/* Some checks before mangling */
  		if (pp->csum_check && !pp->csum_check(cp->af, skb, pp))
  			return 0;
@@ -212,8 +225,13 @@ tcp_dnat_handler(struct sk_buff *skb,
  		 *	Attempt ip_vs_app call.
  		 *	It will fix ip_vs_conn and iph ack_seq stuff
  		 */
-		if (!ip_vs_app_pkt_in(cp, skb))
+		if (!(ret = ip_vs_app_pkt_in(cp, skb)))
  			return 0;
+		/* ret=2: csum update is needed after payload mangling */
+		if (ret == 1)
+			oldlen = skb->len - tcphoff;
+		else
+			payload_csum = 1;
  	}

  	tcph = (void *)skb_network_header(skb) + tcphoff;
@@ -226,12 +244,13 @@ tcp_dnat_handler(struct sk_buff *skb,
  		tcp_partial_csum_update(cp->af, tcph, &cp->daddr, &cp->vaddr,
  					htons(oldlen),
  					htons(skb->len - tcphoff));
-	} else if (!cp->app) {
+	} else if (!payload_csum) {
  		/* Only port and addr are changed, do fast csum update */
  		tcp_fast_csum_update(cp->af, tcph, &cp->vaddr, &cp->daddr,
  				     cp->vport, cp->dport);
  		if (skb->ip_summed == CHECKSUM_COMPLETE)
-			skb->ip_summed = CHECKSUM_NONE;
+			skb->ip_summed = (cp->app && pp->csum_check) ?
+					 CHECKSUM_UNNECESSARY : CHECKSUM_NONE;
  	} else {
  		/* full checksum calculation */
  		tcph->check = 0;
diff -urp net-next-2.6-e548833-nfct_snat_reroute-ipv6dst/linux/net/netfilter/ipvs/ip_vs_proto_udp.c linux/net/netfilter/ipvs/ip_vs_proto_udp.c
--- net-next-2.6-e548833-nfct_snat_reroute-ipv6dst/linux/net/netfilter/ipvs/ip_vs_proto_udp.c	2010-09-10 08:27:33.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_proto_udp.c	2010-10-03 19:43:50.519354075 +0300
@@ -102,15 +102,15 @@ udp_partial_csum_update(int af, struct u
  #ifdef CONFIG_IP_VS_IPV6
  	if (af == AF_INET6)
  		uhdr->check =
-			csum_fold(ip_vs_check_diff16(oldip->ip6, newip->ip6,
+			~csum_fold(ip_vs_check_diff16(oldip->ip6, newip->ip6,
  					 ip_vs_check_diff2(oldlen, newlen,
-						~csum_unfold(uhdr->check))));
+						csum_unfold(uhdr->check))));
  	else
  #endif
  	uhdr->check =
-		csum_fold(ip_vs_check_diff4(oldip->ip, newip->ip,
+		~csum_fold(ip_vs_check_diff4(oldip->ip, newip->ip,
  				ip_vs_check_diff2(oldlen, newlen,
-						~csum_unfold(uhdr->check))));
+						csum_unfold(uhdr->check))));
  }


@@ -121,6 +121,7 @@ udp_snat_handler(struct sk_buff *skb,
  	struct udphdr *udph;
  	unsigned int udphoff;
  	int oldlen;
+	int payload_csum = 0;

  #ifdef CONFIG_IP_VS_IPV6
  	if (cp->af == AF_INET6)
@@ -135,6 +136,8 @@ udp_snat_handler(struct sk_buff *skb,
  		return 0;

  	if (unlikely(cp->app != NULL)) {
+		int ret;
+
  		/* Some checks before mangling */
  		if (pp->csum_check && !pp->csum_check(cp->af, skb, pp))
  			return 0;
@@ -142,8 +145,13 @@ udp_snat_handler(struct sk_buff *skb,
  		/*
  		 *	Call application helper if needed
  		 */
-		if (!ip_vs_app_pkt_out(cp, skb))
+		if (!(ret = ip_vs_app_pkt_out(cp, skb)))
  			return 0;
+		/* ret=2: csum update is needed after payload mangling */
+		if (ret == 1)
+			oldlen = skb->len - udphoff;
+		else
+			payload_csum = 1;
  	}

  	udph = (void *)skb_network_header(skb) + udphoff;
@@ -156,12 +164,13 @@ udp_snat_handler(struct sk_buff *skb,
  		udp_partial_csum_update(cp->af, udph, &cp->daddr, &cp->vaddr,
  					htons(oldlen),
  					htons(skb->len - udphoff));
-	} else if (!cp->app && (udph->check != 0)) {
+	} else if (!payload_csum && (udph->check != 0)) {
  		/* Only port and addr are changed, do fast csum update */
  		udp_fast_csum_update(cp->af, udph, &cp->daddr, &cp->vaddr,
  				     cp->dport, cp->vport);
  		if (skb->ip_summed == CHECKSUM_COMPLETE)
-			skb->ip_summed = CHECKSUM_NONE;
+			skb->ip_summed = (cp->app && pp->csum_check) ?
+					 CHECKSUM_UNNECESSARY : CHECKSUM_NONE;
  	} else {
  		/* full checksum calculation */
  		udph->check = 0;
@@ -181,6 +190,7 @@ udp_snat_handler(struct sk_buff *skb,
  							skb->csum);
  		if (udph->check == 0)
  			udph->check = CSUM_MANGLED_0;
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
  		IP_VS_DBG(11, "O-pkt: %s O-csum=%d (+%zd)\n",
  			  pp->name, udph->check,
  			  (char*)&(udph->check) - (char*)udph);
@@ -196,6 +206,7 @@ udp_dnat_handler(struct sk_buff *skb,
  	struct udphdr *udph;
  	unsigned int udphoff;
  	int oldlen;
+	int payload_csum = 0;

  #ifdef CONFIG_IP_VS_IPV6
  	if (cp->af == AF_INET6)
@@ -210,6 +221,8 @@ udp_dnat_handler(struct sk_buff *skb,
  		return 0;

  	if (unlikely(cp->app != NULL)) {
+		int ret;
+
  		/* Some checks before mangling */
  		if (pp->csum_check && !pp->csum_check(cp->af, skb, pp))
  			return 0;
@@ -218,8 +231,13 @@ udp_dnat_handler(struct sk_buff *skb,
  		 *	Attempt ip_vs_app call.
  		 *	It will fix ip_vs_conn
  		 */
-		if (!ip_vs_app_pkt_in(cp, skb))
+		if (!(ret = ip_vs_app_pkt_in(cp, skb)))
  			return 0;
+		/* ret=2: csum update is needed after payload mangling */
+		if (ret == 1)
+			oldlen = skb->len - udphoff;
+		else
+			payload_csum = 1;
  	}

  	udph = (void *)skb_network_header(skb) + udphoff;
@@ -232,12 +250,13 @@ udp_dnat_handler(struct sk_buff *skb,
  		udp_partial_csum_update(cp->af, udph, &cp->daddr, &cp->vaddr,
  					htons(oldlen),
  					htons(skb->len - udphoff));
-	} else if (!cp->app && (udph->check != 0)) {
+	} else if (!payload_csum && (udph->check != 0)) {
  		/* Only port and addr are changed, do fast csum update */
  		udp_fast_csum_update(cp->af, udph, &cp->vaddr, &cp->daddr,
  				     cp->vport, cp->dport);
  		if (skb->ip_summed == CHECKSUM_COMPLETE)
-			skb->ip_summed = CHECKSUM_NONE;
+			skb->ip_summed = (cp->app && pp->csum_check) ?
+					 CHECKSUM_UNNECESSARY : CHECKSUM_NONE;
  	} else {
  		/* full checksum calculation */
  		udph->check = 0;
diff -urp net-next-2.6-e548833-nfct_snat_reroute-ipv6dst/linux/net/netfilter/ipvs/ip_vs_xmit.c linux/net/netfilter/ipvs/ip_vs_xmit.c
--- net-next-2.6-e548833-nfct_snat_reroute-ipv6dst/linux/net/netfilter/ipvs/ip_vs_xmit.c	2010-09-22 16:29:43.271964521 +0300
+++ linux/net/netfilter/ipvs/ip_vs_xmit.c	2010-10-03 22:14:05.735352693 +0300
@@ -11,6 +11,12 @@
   *
   * Changes:
   *
+ * Description of forwarding methods:
+ * - all transmitters are called from LOCAL_IN but for ICMP can be called
+ * from FORWARD
+ * - not all connections have destination server, for example,
+ * connections in backup server when fwmark is used
+ * - bypass connections use daddr from packet
   */

  #define KMSG_COMPONENT "IPVS"
@@ -67,12 +73,16 @@ __ip_vs_dst_check(struct ip_vs_dest *des
  	return dst;
  }

+/*
+ * Get route to destination or remote server
+ * rt_mode: flags, bit 0=Allow local dest, bit 1=Allow non-local dest
+ */
  static struct rtable *
-__ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_conn *cp, u32 rtos)
+__ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
+		   __be32 daddr, u32 rtos, int rt_mode)
  {
  	struct net *net = dev_net(skb->dev);
  	struct rtable *rt;			/* Route to the other host */
-	struct ip_vs_dest *dest = cp->dest;

  	if (dest) {
  		spin_lock(&dest->dst_lock);
@@ -104,23 +114,77 @@ __ip_vs_get_out_rt(struct sk_buff *skb,
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

+	if (!((1 + !(rt->rt_flags & RTCF_LOCAL)) & rt_mode)) {
+		IP_VS_DBG_RL("Stopping traffic to %s address, dest: %pI4\n",
+			     (rt->rt_flags & RTCF_LOCAL) ?
+			     "local":"non-local", &rt->rt_dst);
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
+	struct net *net = dev_net(skb->dev);
+	struct iphdr *iph = ip_hdr(skb);
+
+	if (!(skb->dev->flags & IFF_LOOPBACK)) {
+		unsigned long orefdst = skb->_skb_refdst;
+
+		if (ip_route_input(skb, iph->daddr, iph->saddr,
+				   iph->tos, skb->dev))
+			return 0;
+		refdst_drop(orefdst);
+	} else {
+		struct flowi fl = {
+			.oif = skb->dev->ifindex,
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
+		if (!(rt->rt_flags & RTCF_LOCAL) || skb->dev != rt->dst.dev) {
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
@@ -155,14 +219,19 @@ out_err:
  	return NULL;
  }

+/*
+ * Get route to destination or remote server
+ * rt_mode: flags, bit 0=Allow local dest, bit 1=Allow non-local dest
+ */
  static struct rt6_info *
-__ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		      struct in6_addr *ret_saddr, int do_xfrm)
+__ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_dest *dest,
+		      struct in6_addr *daddr, struct in6_addr *ret_saddr,
+		      int do_xfrm, int rt_mode)
  {
  	struct net *net = dev_net(skb->dev);
  	struct rt6_info *rt;			/* Route to the other host */
-	struct ip_vs_dest *dest = cp->dest;
  	struct dst_entry *dst;
+	int local;

  	if (dest) {
  		spin_lock(&dest->dst_lock);
@@ -188,13 +257,19 @@ __ip_vs_get_out_rt_v6(struct sk_buff *sk
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
+	if (!((1 + !local) & rt_mode)) {
+		IP_VS_DBG_RL("Stopping traffic to %s address, dest: %pI6\n",
+			     local ? "local":"non-local", daddr);
+		dst_release(&rt->dst);
+		return NULL;
+	}
  	return rt;
  }
  #endif
@@ -228,8 +303,9 @@ ip_vs_dst_reset(struct ip_vs_dest *dest)

  #define IP_VS_XMIT_NAT(pf, skb, cp)				\
  do {							\
+	(skb)->ipvs_property = 1;			\
  	if (likely(!((cp)->flags & IP_VS_CONN_F_NFCT)))	\
-		(skb)->ipvs_property = 1;		\
+		ip_vs_notrack(skb);			\
  	else						\
  		ip_vs_update_conntrack(skb, cp, 1);	\
  	skb_forward_csum(skb);				\
@@ -239,8 +315,9 @@ do {							\

  #define IP_VS_XMIT(pf, skb, cp)				\
  do {							\
+	(skb)->ipvs_property = 1;			\
  	if (likely(!((cp)->flags & IP_VS_CONN_F_NFCT)))	\
-		(skb)->ipvs_property = 1;		\
+		ip_vs_notrack(skb);			\
  	skb_forward_csum(skb);				\
  	NF_HOOK(pf, NF_INET_LOCAL_OUT, (skb), NULL,	\
  		skb_dst(skb)->dev, dst_output);		\
@@ -268,27 +345,15 @@ int
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
@@ -334,18 +399,14 @@ int
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
@@ -411,8 +472,59 @@ ip_vs_nat_xmit(struct sk_buff *skb, stru
  		IP_VS_DBG(10, "filled cport=%d\n", ntohs(*p));
  	}

-	if (!(rt = __ip_vs_get_out_rt(skb, cp, RT_TOS(iph->tos))))
+	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
+				      RT_TOS(iph->tos), 3)))
  		goto tx_error_icmp;
+	/* 
+	 * Avoid duplicate tuple in reply direction for NAT traffic
+	 * to local address when connection is sync-ed
+	 */
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+	if (cp->flags & IP_VS_CONN_F_SYNC && rt->rt_flags & RTCF_LOCAL) {
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
+	if (rt->rt_flags & RTCF_LOCAL) {
+		if (ipv4_is_loopback(rt->rt_dst) &&
+		    !(skb->dev->flags & IFF_LOOPBACK)) {
+			IP_VS_DBG_RL_PKT(1, pp, skb, 0, "ip_vs_nat_xmit(): "
+					 "stopping DNAT to loopback address");
+			goto tx_error_put;
+		}
+		/* copy-on-write the packet before mangling it */
+		if (!skb_make_writable(skb, sizeof(struct iphdr)))
+			goto tx_error_put;
+		/* mangle the packet */
+		if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp))
+			goto tx_error_put;
+		ip_rt_put(rt);
+		iph = ip_hdr(skb);
+		iph->daddr = cp->daddr.ip;
+		ip_send_check(iph);
+
+		IP_VS_DBG_PKT(10, pp, skb, 0, "After DNAT to local");
+
+		/*
+		 * Some IPv4 replies get local address from routes,
+		 * not from iph, so while we DNAT after routing
+		 * we need this second input/output route.
+		 */
+		if (!__ip_vs_reroute_locally(skb))
+			goto tx_error;
+
+		if (cp->flags & IP_VS_CONN_F_NFCT)
+			ip_vs_update_conntrack(skb, cp, 1);
+		LeaveFunction(10);
+		return NF_ACCEPT;
+	}

  	/* MTU checking */
  	mtu = dst_mtu(&rt->dst);
@@ -472,6 +584,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, s
  {
  	struct rt6_info *rt;		/* Route to the other host */
  	int mtu;
+	int local;

  	EnterFunction(10);

@@ -486,9 +599,52 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, s
  		IP_VS_DBG(10, "filled cport=%d\n", ntohs(*p));
  	}

-	rt = __ip_vs_get_out_rt_v6(skb, cp, NULL, 0);
-	if (!rt)
+	if (!(rt = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
+					 0, 3)))
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
+	if (local) {
+		if (ipv6_addr_type(&rt->rt6i_dst.addr) & IPV6_ADDR_LOOPBACK &&
+		    !(skb->dev->flags & IFF_LOOPBACK)) {
+			IP_VS_DBG_RL_PKT(1, pp, skb, 0,
+					 "ip_vs_nat_xmit_v6(): "
+					 "stopping DNAT to loopback address");
+			goto tx_error_put;
+		}
+		/* copy-on-write the packet before mangling it */
+		if (!skb_make_writable(skb, sizeof(struct ipv6hdr)))
+			goto tx_error_put;
+		/* mangle the packet */
+		if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp))
+			goto tx_error_put;
+		dst_release(&rt->dst);
+		ipv6_addr_copy(&ipv6_hdr(skb)->daddr, &cp->daddr.in6);
+
+		IP_VS_DBG_PKT(10, pp, skb, 0, "After DNAT to local");
+
+		if (cp->flags & IP_VS_CONN_F_NFCT)
+			ip_vs_update_conntrack(skb, cp, 1);
+		LeaveFunction(10);
+		return NF_ACCEPT;
+	}

  	/* MTU checking */
  	mtu = dst_mtu(&rt->dst);
@@ -514,7 +670,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, s
  	/* mangle the packet */
  	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp))
  		goto tx_error;
-	ipv6_hdr(skb)->daddr = cp->daddr.in6;
+	ipv6_addr_copy(&ipv6_hdr(skb)->daddr, &cp->daddr.in6);

  	IP_VS_DBG_PKT(10, pp, skb, 0, "After DNAT");

@@ -585,8 +741,13 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, s
  		goto tx_error;
  	}

-	if (!(rt = __ip_vs_get_out_rt(skb, cp, RT_TOS(tos))))
+	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
+				      RT_TOS(tos), 3)))
  		goto tx_error_icmp;
+	if (rt->rt_flags & RTCF_LOCAL) {
+		ip_rt_put(rt);
+		return NF_ACCEPT;
+	}

  	tdev = rt->dst.dev;

@@ -700,9 +861,13 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb
  		goto tx_error;
  	}

-	rt = __ip_vs_get_out_rt_v6(skb, cp, &saddr, 1);
-	if (!rt)
+	if (!(rt = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6,
+					 &saddr, 1, 3)))
  		goto tx_error_icmp;
+	if (__ip_vs_is_local_route6(rt)) {
+		dst_release(&rt->dst);
+		return NF_ACCEPT;
+	}

  	tdev = rt->dst.dev;

@@ -804,8 +969,13 @@ ip_vs_dr_xmit(struct sk_buff *skb, struc

  	EnterFunction(10);

-	if (!(rt = __ip_vs_get_out_rt(skb, cp, RT_TOS(iph->tos))))
+	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
+				      RT_TOS(iph->tos), 3)))
  		goto tx_error_icmp;
+	if (rt->rt_flags & RTCF_LOCAL) {
+		ip_rt_put(rt);
+		return NF_ACCEPT;
+	}

  	/* MTU checking */
  	mtu = dst_mtu(&rt->dst);
@@ -856,9 +1026,13 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, st

  	EnterFunction(10);

-	rt = __ip_vs_get_out_rt_v6(skb, cp, NULL, 0);
-	if (!rt)
+	if (!(rt = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
+					 0, 3)))
  		goto tx_error_icmp;
+	if (__ip_vs_is_local_route6(rt)) {
+		dst_release(&rt->dst);
+		return NF_ACCEPT;
+	}

  	/* MTU checking */
  	mtu = dst_mtu(&rt->dst);
@@ -932,9 +1106,55 @@ ip_vs_icmp_xmit(struct sk_buff *skb, str
  	 * mangle and send the packet here (only for VS/NAT)
  	 */

-	if (!(rt = __ip_vs_get_out_rt(skb, cp, RT_TOS(ip_hdr(skb)->tos))))
+	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
+				      RT_TOS(ip_hdr(skb)->tos), 3)))
  		goto tx_error_icmp;

+	/* 
+	 * Avoid duplicate tuple in reply direction for NAT traffic
+	 * to local address when connection is sync-ed
+	 */
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+	if (cp->flags & IP_VS_CONN_F_SYNC && rt->rt_flags & RTCF_LOCAL) {
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
+	if (rt->rt_flags & RTCF_LOCAL) {
+		if (ipv4_is_loopback(rt->rt_dst) &&
+		    !(skb->dev->flags & IFF_LOOPBACK)) {
+			IP_VS_DBG(1, "%s(): "
+				  "stopping DNAT to loopback %pI4\n",
+				  __func__, &cp->daddr.ip);
+			goto tx_error_put;
+		}
+		/* copy-on-write the packet before mangling it */
+		if (!skb_make_writable(skb, offset))
+			goto tx_error_put;
+		/* mangle the packet */
+		ip_vs_nat_icmp(skb, pp, cp, 0);
+		ip_rt_put(rt);
+
+		/*
+		 * Some IPv4 replies get local address from routes,
+		 * not from iph, so while we DNAT after routing
+		 * we need this second input/output route.
+		 */
+		if (!__ip_vs_reroute_locally(skb))
+			goto tx_error;
+
+		LeaveFunction(10);
+		return NF_ACCEPT;
+	}
+
  	/* MTU checking */
  	mtu = dst_mtu(&rt->dst);
  	if ((skb->len > mtu) && (ip_hdr(skb)->frag_off & htons(IP_DF))) {
@@ -986,6 +1206,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb,
  	struct rt6_info	*rt;	/* Route to the other host */
  	int mtu;
  	int rc;
+	int local;

  	EnterFunction(10);

@@ -1006,10 +1227,46 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb,
  	 * mangle and send the packet here (only for VS/NAT)
  	 */

-	rt = __ip_vs_get_out_rt_v6(skb, cp, NULL, 0);
-	if (!rt)
+	if (!(rt = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
+					 0, 3)))
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
+	if (local) {
+		if (ipv6_addr_type(&rt->rt6i_dst.addr) & IPV6_ADDR_LOOPBACK &&
+		    !(skb->dev->flags & IFF_LOOPBACK)) {
+			IP_VS_DBG(1, "%s(): "
+				  "stopping DNAT to loopback %pI6\n",
+				  __func__, &cp->daddr.in6);
+			goto tx_error_put;
+		}
+		/* copy-on-write the packet before mangling it */
+		if (!skb_make_writable(skb, offset))
+			goto tx_error_put;
+		ip_vs_nat_icmp_v6(skb, pp, cp, 0);
+		dst_release(&rt->dst);
+		LeaveFunction(10);
+		return NF_ACCEPT;
+	}
+
  	/* MTU checking */
  	mtu = dst_mtu(&rt->dst);
  	if (skb->len > mtu) {
