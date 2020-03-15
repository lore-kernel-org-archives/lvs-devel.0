From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH] ipvs: optimize tunnel dumps for icmp errors
Date: Sun, 15 Mar 2020 14:18:07 +0800
Message-ID: <1584253087-8316-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

After strip GRE/UDP tunnel header for icmp errors, it's better to show
"ICMP for GRE/UDP" instead of "ICMP for IPIP" in debug message.

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 41 +++++++++++++++++++++++------------------
 1 file changed, 23 insertions(+), 18 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 512259f..f39ae6b 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -114,6 +114,10 @@ const char *ip_vs_proto_name(unsigned int proto)
 		return "SCTP";
 	case IPPROTO_ICMP:
 		return "ICMP";
+	case IPPROTO_IPIP:
+		return "IPIP";
+	case IPPROTO_GRE:
+		return "GRE";
 #ifdef CONFIG_IP_VS_IPV6
 	case IPPROTO_ICMPV6:
 		return "ICMPv6";
@@ -1661,7 +1665,7 @@ static int ipvs_gre_decap(struct netns_ipvs *ipvs, struct sk_buff *skb,
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
 	unsigned int offset, offset2, ihl, verdict;
-	bool ipip, new_cp = false;
+	bool tunnel, new_cp = false;
 	union nf_inet_addr *raddr;
 
 	*related = 1;
@@ -1703,8 +1707,8 @@ static int ipvs_gre_decap(struct netns_ipvs *ipvs, struct sk_buff *skb,
 		return NF_ACCEPT; /* The packet looks wrong, ignore */
 	raddr = (union nf_inet_addr *)&cih->daddr;
 
-	/* Special case for errors for IPIP packets */
-	ipip = false;
+	/* Special case for errors for IPIP/UDP/GRE tunnel packets */
+	tunnel = false;
 	if (cih->protocol == IPPROTO_IPIP) {
 		struct ip_vs_dest *dest;
 
@@ -1721,7 +1725,7 @@ static int ipvs_gre_decap(struct netns_ipvs *ipvs, struct sk_buff *skb,
 		cih = skb_header_pointer(skb, offset, sizeof(_ciph), &_ciph);
 		if (cih == NULL)
 			return NF_ACCEPT; /* The packet looks wrong, ignore */
-		ipip = true;
+		tunnel = true;
 	} else if ((cih->protocol == IPPROTO_UDP ||	/* Can be UDP encap */
 		    cih->protocol == IPPROTO_GRE) &&	/* Can be GRE encap */
 		   /* Error for our tunnel must arrive at LOCAL_IN */
@@ -1729,7 +1733,7 @@ static int ipvs_gre_decap(struct netns_ipvs *ipvs, struct sk_buff *skb,
 		__u8 iproto;
 		int ulen;
 
-		/* Non-first fragment has no UDP header */
+		/* Non-first fragment has no UDP/GRE header */
 		if (unlikely(cih->frag_off & htons(IP_OFFSET)))
 			return NF_ACCEPT;
 		offset2 = offset + cih->ihl * 4;
@@ -1747,7 +1751,7 @@ static int ipvs_gre_decap(struct netns_ipvs *ipvs, struct sk_buff *skb,
 						 &_ciph);
 			if (cih && cih->version == 4 && cih->ihl >= 5 &&
 			    iproto == IPPROTO_IPIP)
-				ipip = true;
+				tunnel = true;
 			else
 				return NF_ACCEPT;
 		}
@@ -1767,11 +1771,11 @@ static int ipvs_gre_decap(struct netns_ipvs *ipvs, struct sk_buff *skb,
 		      "Checking incoming ICMP for");
 
 	offset2 = offset;
-	ip_vs_fill_iph_skb_icmp(AF_INET, skb, offset, !ipip, &ciph);
+	ip_vs_fill_iph_skb_icmp(AF_INET, skb, offset, !tunnel, &ciph);
 	offset = ciph.len;
 
 	/* The embedded headers contain source and dest in reverse order.
-	 * For IPIP this is error for request, not for reply.
+	 * For IPIP/UDP/GRE tunnel this is error for request, not for reply.
 	 */
 	cp = INDIRECT_CALL_1(pp->conn_in_get, ip_vs_conn_in_get_proto,
 			     ipvs, AF_INET, skb, &ciph);
@@ -1779,7 +1783,7 @@ static int ipvs_gre_decap(struct netns_ipvs *ipvs, struct sk_buff *skb,
 	if (!cp) {
 		int v;
 
-		if (ipip || !sysctl_schedule_icmp(ipvs))
+		if (tunnel || !sysctl_schedule_icmp(ipvs))
 			return NF_ACCEPT;
 
 		if (!ip_vs_try_to_schedule(ipvs, AF_INET, skb, pd, &v, &cp, &ciph))
@@ -1797,7 +1801,7 @@ static int ipvs_gre_decap(struct netns_ipvs *ipvs, struct sk_buff *skb,
 		goto out;
 	}
 
-	if (ipip) {
+	if (tunnel) {
 		__be32 info = ic->un.gateway;
 		__u8 type = ic->type;
 		__u8 code = ic->code;
@@ -1809,17 +1813,18 @@ static int ipvs_gre_decap(struct netns_ipvs *ipvs, struct sk_buff *skb,
 			u32 mtu = ntohs(ic->un.frag.mtu);
 			__be16 frag_off = cih->frag_off;
 
-			/* Strip outer IP and ICMP, go to IPIP header */
+			/* Strip outer IP and ICMP, go to IPIP/UDP/GRE header */
 			if (pskb_pull(skb, ihl + sizeof(_icmph)) == NULL)
-				goto ignore_ipip;
+				goto ignore_tunnel;
 			offset2 -= ihl + sizeof(_icmph);
 			skb_reset_network_header(skb);
-			IP_VS_DBG(12, "ICMP for IPIP %pI4->%pI4: mtu=%u\n",
-				&ip_hdr(skb)->saddr, &ip_hdr(skb)->daddr, mtu);
+			IP_VS_DBG(12, "ICMP for %s %pI4->%pI4: mtu=%u\n",
+				  ip_vs_proto_name(cih->protocol),
+				  &ip_hdr(skb)->saddr, &ip_hdr(skb)->daddr, mtu);
 			ipv4_update_pmtu(skb, ipvs->net, mtu, 0, 0);
 			/* Client uses PMTUD? */
 			if (!(frag_off & htons(IP_DF)))
-				goto ignore_ipip;
+				goto ignore_tunnel;
 			/* Prefer the resulting PMTU */
 			if (dest) {
 				struct ip_vs_dest_dst *dest_dst;
@@ -1832,11 +1837,11 @@ static int ipvs_gre_decap(struct netns_ipvs *ipvs, struct sk_buff *skb,
 				mtu -= sizeof(struct iphdr);
 			info = htonl(mtu);
 		}
-		/* Strip outer IP, ICMP and IPIP, go to IP header of
+		/* Strip outer IP, ICMP and IPIP/UDP/GRE, go to IP header of
 		 * original request.
 		 */
 		if (pskb_pull(skb, offset2) == NULL)
-			goto ignore_ipip;
+			goto ignore_tunnel;
 		skb_reset_network_header(skb);
 		IP_VS_DBG(12, "Sending ICMP for %pI4->%pI4: t=%u, c=%u, i=%u\n",
 			&ip_hdr(skb)->saddr, &ip_hdr(skb)->daddr,
@@ -1845,7 +1850,7 @@ static int ipvs_gre_decap(struct netns_ipvs *ipvs, struct sk_buff *skb,
 		/* ICMP can be shorter but anyways, account it */
 		ip_vs_out_stats(cp, skb);
 
-ignore_ipip:
+ignore_tunnel:
 		consume_skb(skb);
 		verdict = NF_STOLEN;
 		goto out;
-- 
1.8.3.1



