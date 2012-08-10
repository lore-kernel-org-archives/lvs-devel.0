From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 4/5] ipvs: implement passive PMTUD for IPIP packets
Date: Fri, 10 Aug 2012 10:41:33 +0900
Message-ID: <1344562895-22790-5-git-send-email-horms@verge.net.au>
References: <1344562895-22790-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1344562895-22790-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

	IPVS is missing the logic to update PMTU in routing
for its IPIP packets. We monitor the dst_mtu and can return
FRAG_NEEDED messages but if the tunneled packets get ICMP
error we can not rely on other traffic to save the lowest
MTU.

	The following patch adds ICMP handling for IPIP
packets in incoming direction, from some remote host to
our local IP used as saddr in the outer header. By this
way we can forward any related ICMP traffic if it is for IPVS
TUN connection. For the special case of PMTUD we update the
routing and if client requested DF we can forward the
error.

	To properly update the routing we have to bind
the cached route (dest->dst_cache) to the selected saddr
because ipv4_update_pmtu uses saddr for dst lookup.
Add IP_VS_RT_MODE_CONNECT flag to force such binding with
second route.

	Update ip_vs_tunnel_xmit to provide IP_VS_RT_MODE_CONNECT
and change the code to copy DF. For now we prefer not to
force PMTU discovery (outer DF=1) because we don't have
configuration option to enable or disable PMTUD. As we
do not keep any packets to resend, we prefer not to
play games with packets without DF bit because the sender
is not informed when they are rejected.

	Also, change ops->update_pmtu to be called only
for local clients because there is no point to update
MTU for input routes, in our case skb->dst->dev is lo.
It seems the code is copied from ipip.c where the skb
dst points to tunnel device.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c | 76 +++++++++++++++++++++++++++++++++++++--
 net/netfilter/ipvs/ip_vs_xmit.c | 79 ++++++++++++++++++++++++++++-------------
 2 files changed, 128 insertions(+), 27 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index b54ecce..58918e2 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1303,7 +1303,8 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	struct ip_vs_conn *cp;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
-	unsigned int offset, ihl, verdict;
+	unsigned int offset, offset2, ihl, verdict;
+	bool ipip;
 
 	*related = 1;
 
@@ -1345,6 +1346,21 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 
 	net = skb_net(skb);
 
+	/* Special case for errors for IPIP packets */
+	ipip = false;
+	if (cih->protocol == IPPROTO_IPIP) {
+		if (unlikely(cih->frag_off & htons(IP_OFFSET)))
+			return NF_ACCEPT;
+		/* Error for our IPIP must arrive at LOCAL_IN */
+		if (!(skb_rtable(skb)->rt_flags & RTCF_LOCAL))
+			return NF_ACCEPT;
+		offset += cih->ihl * 4;
+		cih = skb_header_pointer(skb, offset, sizeof(_ciph), &_ciph);
+		if (cih == NULL)
+			return NF_ACCEPT; /* The packet looks wrong, ignore */
+		ipip = true;
+	}
+
 	pd = ip_vs_proto_data_get(net, cih->protocol);
 	if (!pd)
 		return NF_ACCEPT;
@@ -1358,11 +1374,14 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	IP_VS_DBG_PKT(11, AF_INET, pp, skb, offset,
 		      "Checking incoming ICMP for");
 
+	offset2 = offset;
 	offset += cih->ihl * 4;
 
 	ip_vs_fill_iphdr(AF_INET, cih, &ciph);
-	/* The embedded headers contain source and dest in reverse order */
-	cp = pp->conn_in_get(AF_INET, skb, &ciph, offset, 1);
+	/* The embedded headers contain source and dest in reverse order.
+	 * For IPIP this is error for request, not for reply.
+	 */
+	cp = pp->conn_in_get(AF_INET, skb, &ciph, offset, ipip ? 0 : 1);
 	if (!cp)
 		return NF_ACCEPT;
 
@@ -1376,6 +1395,57 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 		goto out;
 	}
 
+	if (ipip) {
+		__be32 info = ic->un.gateway;
+
+		/* Update the MTU */
+		if (ic->type == ICMP_DEST_UNREACH &&
+		    ic->code == ICMP_FRAG_NEEDED) {
+			struct ip_vs_dest *dest = cp->dest;
+			u32 mtu = ntohs(ic->un.frag.mtu);
+
+			/* Strip outer IP and ICMP, go to IPIP header */
+			__skb_pull(skb, ihl + sizeof(_icmph));
+			offset2 -= ihl + sizeof(_icmph);
+			skb_reset_network_header(skb);
+			IP_VS_DBG(12, "ICMP for IPIP %pI4->%pI4: mtu=%u\n",
+				&ip_hdr(skb)->saddr, &ip_hdr(skb)->daddr, mtu);
+			rcu_read_lock();
+			ipv4_update_pmtu(skb, dev_net(skb->dev),
+					 mtu, 0, 0, 0, 0);
+			rcu_read_unlock();
+			/* Client uses PMTUD? */
+			if (!(cih->frag_off & htons(IP_DF)))
+				goto ignore_ipip;
+			/* Prefer the resulting PMTU */
+			if (dest) {
+				spin_lock(&dest->dst_lock);
+				if (dest->dst_cache)
+					mtu = dst_mtu(dest->dst_cache);
+				spin_unlock(&dest->dst_lock);
+			}
+			if (mtu > 68 + sizeof(struct iphdr))
+				mtu -= sizeof(struct iphdr);
+			info = htonl(mtu);
+		}
+		/* Strip outer IP, ICMP and IPIP, go to IP header of
+		 * original request.
+		 */
+		__skb_pull(skb, offset2);
+		skb_reset_network_header(skb);
+		IP_VS_DBG(12, "Sending ICMP for %pI4->%pI4: t=%u, c=%u, i=%u\n",
+			&ip_hdr(skb)->saddr, &ip_hdr(skb)->daddr,
+			ic->type, ic->code, ntohl(info));
+		icmp_send(skb, ic->type, ic->code, info);
+		/* ICMP can be shorter but anyways, account it */
+		ip_vs_out_stats(cp, skb);
+
+ignore_ipip:
+		consume_skb(skb);
+		verdict = NF_STOLEN;
+		goto out;
+	}
+
 	/* do the statistics and put it back */
 	ip_vs_in_stats(cp, skb);
 	if (IPPROTO_TCP == cih->protocol || IPPROTO_UDP == cih->protocol)
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 65b616a..c2275ba 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -49,6 +49,7 @@ enum {
 	IP_VS_RT_MODE_RDR	= 4, /* Allow redirect from remote daddr to
 				      * local
 				      */
+	IP_VS_RT_MODE_CONNECT	= 8, /* Always bind route to saddr */
 };
 
 /*
@@ -84,6 +85,42 @@ __ip_vs_dst_check(struct ip_vs_dest *dest, u32 rtos)
 	return dst;
 }
 
+/* Get route to daddr, update *saddr, optionally bind route to saddr */
+static struct rtable *do_output_route4(struct net *net, __be32 daddr,
+				       u32 rtos, int rt_mode, __be32 *saddr)
+{
+	struct flowi4 fl4;
+	struct rtable *rt;
+	int loop = 0;
+
+	memset(&fl4, 0, sizeof(fl4));
+	fl4.daddr = daddr;
+	fl4.saddr = (rt_mode & IP_VS_RT_MODE_CONNECT) ? *saddr : 0;
+	fl4.flowi4_tos = rtos;
+
+retry:
+	rt = ip_route_output_key(net, &fl4);
+	if (IS_ERR(rt)) {
+		/* Invalid saddr ? */
+		if (PTR_ERR(rt) == -EINVAL && *saddr &&
+		    rt_mode & IP_VS_RT_MODE_CONNECT && !loop) {
+			*saddr = 0;
+			flowi4_update_output(&fl4, 0, rtos, daddr, 0);
+			goto retry;
+		}
+		IP_VS_DBG_RL("ip_route_output error, dest: %pI4\n", &daddr);
+		return NULL;
+	} else if (!*saddr && rt_mode & IP_VS_RT_MODE_CONNECT && fl4.saddr) {
+		ip_rt_put(rt);
+		*saddr = fl4.saddr;
+		flowi4_update_output(&fl4, 0, rtos, daddr, fl4.saddr);
+		loop++;
+		goto retry;
+	}
+	*saddr = fl4.saddr;
+	return rt;
+}
+
 /* Get route to destination or remote server */
 static struct rtable *
 __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
@@ -98,20 +135,13 @@ __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 		spin_lock(&dest->dst_lock);
 		if (!(rt = (struct rtable *)
 		      __ip_vs_dst_check(dest, rtos))) {
-			struct flowi4 fl4;
-
-			memset(&fl4, 0, sizeof(fl4));
-			fl4.daddr = dest->addr.ip;
-			fl4.flowi4_tos = rtos;
-			rt = ip_route_output_key(net, &fl4);
-			if (IS_ERR(rt)) {
+			rt = do_output_route4(net, dest->addr.ip, rtos,
+					      rt_mode, &dest->dst_saddr.ip);
+			if (!rt) {
 				spin_unlock(&dest->dst_lock);
-				IP_VS_DBG_RL("ip_route_output error, dest: %pI4\n",
-					     &dest->addr.ip);
 				return NULL;
 			}
 			__ip_vs_dst_set(dest, rtos, dst_clone(&rt->dst), 0);
-			dest->dst_saddr.ip = fl4.saddr;
 			IP_VS_DBG(10, "new dst %pI4, src %pI4, refcnt=%d, "
 				  "rtos=%X\n",
 				  &dest->addr.ip, &dest->dst_saddr.ip,
@@ -122,19 +152,17 @@ __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 			*ret_saddr = dest->dst_saddr.ip;
 		spin_unlock(&dest->dst_lock);
 	} else {
-		struct flowi4 fl4;
+		__be32 saddr = htonl(INADDR_ANY);
 
-		memset(&fl4, 0, sizeof(fl4));
-		fl4.daddr = daddr;
-		fl4.flowi4_tos = rtos;
-		rt = ip_route_output_key(net, &fl4);
-		if (IS_ERR(rt)) {
-			IP_VS_DBG_RL("ip_route_output error, dest: %pI4\n",
-				     &daddr);
+		/* For such unconfigured boxes avoid many route lookups
+		 * for performance reasons because we do not remember saddr
+		 */
+		rt_mode &= ~IP_VS_RT_MODE_CONNECT;
+		rt = do_output_route4(net, daddr, rtos, rt_mode, &saddr);
+		if (!rt)
 			return NULL;
-		}
 		if (ret_saddr)
-			*ret_saddr = fl4.saddr;
+			*ret_saddr = saddr;
 	}
 
 	local = rt->rt_flags & RTCF_LOCAL;
@@ -331,6 +359,7 @@ ip_vs_dst_reset(struct ip_vs_dest *dest)
 	old_dst = dest->dst_cache;
 	dest->dst_cache = NULL;
 	dst_release(old_dst);
+	dest->dst_saddr.ip = 0;
 }
 
 #define IP_VS_XMIT_TUNNEL(skb, cp)				\
@@ -771,7 +800,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	struct net_device *tdev;		/* Device to other host */
 	struct iphdr  *old_iph = ip_hdr(skb);
 	u8     tos = old_iph->tos;
-	__be16 df = old_iph->frag_off;
+	__be16 df;
 	struct iphdr  *iph;			/* Our new IP header */
 	unsigned int max_headroom;		/* The extra header space needed */
 	int    mtu;
@@ -781,7 +810,8 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
 				      RT_TOS(tos), IP_VS_RT_MODE_LOCAL |
-						   IP_VS_RT_MODE_NON_LOCAL,
+						   IP_VS_RT_MODE_NON_LOCAL |
+						   IP_VS_RT_MODE_CONNECT,
 						   &saddr)))
 		goto tx_error_icmp;
 	if (rt->rt_flags & RTCF_LOCAL) {
@@ -796,10 +826,11 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		IP_VS_DBG_RL("%s(): mtu less than 68\n", __func__);
 		goto tx_error_put;
 	}
-	if (skb_dst(skb))
+	if (rt_is_output_route(skb_rtable(skb)))
 		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
 
-	df |= (old_iph->frag_off & htons(IP_DF));
+	/* Copy DF, reset fragment offset and MF */
+	df = old_iph->frag_off & htons(IP_DF);
 
 	if ((old_iph->frag_off & htons(IP_DF) &&
 	    mtu < ntohs(old_iph->tot_len) && !skb_is_gso(skb))) {
-- 
1.7.10.2.484.gcd07cc5

