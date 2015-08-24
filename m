From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next,v2 02/13] ipvs: Add hdr_flags to iphdr
Date: Mon, 24 Aug 2015 16:44:34 -0700
Message-ID: <1440459885-1103938-2-git-send-email-agartrell@fb.com>
References: <1440459885-1103938-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=c2Qj57AIAzJwJ+VGbo+jqON45fCjJathih5SB9pFW+Y=;
 b=lYjEAaTUnzCXVoXpJ0ixZdQy7cGJ6tIi/saNeyHZrDE2X9detGQanzaYUohsD/QtoO5J
 PUkg1JRusAfQEVglOg8cukQ3N7xUk+B3CIgn2DWzjJ21RurZCRrQ6cBkqXlkszzSF+mm
 806vnjc10whPcbzfVlU3NWQ3MeTW5XCTHr8= 
In-Reply-To: <1440459885-1103938-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org
Cc: alexgartrell@gmail.com, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

These flags contain information like whether or not the addresses are
inverted or from icmp.  The first will allow us to drop an inverse param
all over the place, and the second will later be useful in scheduling icmp.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 include/net/ip_vs.h               | 43 ++++++++++++++++++++++++++++++++++++---
 net/netfilter/ipvs/ip_vs_core.c   | 20 +++++++++---------
 net/netfilter/ipvs/ip_vs_pe_sip.c |  2 +-
 net/netfilter/xt_ipvs.c           |  2 +-
 4 files changed, 52 insertions(+), 15 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 781068c..62d9c61 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -29,6 +29,9 @@
 #endif
 #include <net/net_namespace.h>		/* Netw namespace */
 
+#define IP_VS_HDR_INVERSE	1
+#define IP_VS_HDR_ICMP		2
+
 /* Generic access of ipvs struct */
 static inline struct netns_ipvs *net_ipvs(struct net* net)
 {
@@ -104,6 +107,7 @@ static inline struct net *seq_file_single_net(struct seq_file *seq)
 extern int ip_vs_conn_tab_size;
 
 struct ip_vs_iphdr {
+	int hdr_flags;	/* ipvs flags */
 	__u32 off;	/* Where IP or IPv4 header starts */
 	__u32 len;	/* IPv4 simply where L4 starts
 			 * IPv6 where L4 Transport Header starts */
@@ -127,9 +131,11 @@ static inline void *frag_safe_skb_hp(const struct sk_buff *skb, int offset,
  */
 static inline int
 ip_vs_fill_iph_skb_off(int af, const struct sk_buff *skb, int offset,
-		       struct ip_vs_iphdr *iphdr)
+		       int hdr_flags, struct ip_vs_iphdr *iphdr)
 {
+	iphdr->hdr_flags = hdr_flags;
 	iphdr->off = offset;
+
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
 		struct ipv6hdr _iph;
@@ -168,9 +174,40 @@ ip_vs_fill_iph_skb_off(int af, const struct sk_buff *skb, int offset,
 }
 
 static inline int
-ip_vs_fill_iph_skb(int af, const struct sk_buff *skb, struct ip_vs_iphdr *iphdr)
+ip_vs_fill_iph_skb_icmp(int af, const struct sk_buff *skb, int offset,
+			bool inverse, struct ip_vs_iphdr *iphdr)
+{
+	int hdr_flags = IP_VS_HDR_ICMP;
+
+	if (inverse)
+		hdr_flags |= IP_VS_HDR_INVERSE;
+
+	return ip_vs_fill_iph_skb_off(af, skb, offset, hdr_flags, iphdr);
+}
+
+static inline int
+ip_vs_fill_iph_skb(int af, const struct sk_buff *skb, bool inverse,
+		   struct ip_vs_iphdr *iphdr)
+{
+	int hdr_flags = 0;
+
+	if (inverse)
+		hdr_flags |= IP_VS_HDR_INVERSE;
+
+	return ip_vs_fill_iph_skb_off(af, skb, skb_network_offset(skb),
+				      hdr_flags, iphdr);
+}
+
+static inline bool
+ip_vs_iph_inverse(const struct ip_vs_iphdr *iph)
+{
+	return !!(iph->hdr_flags & IP_VS_HDR_INVERSE);
+}
+
+static inline bool
+ip_vs_iph_icmp(const struct ip_vs_iphdr *iph)
 {
-	return ip_vs_fill_iph_skb_off(af, skb, skb_network_offset(skb), iphdr);
+	return !!(iph->hdr_flags & IP_VS_HDR_ICMP);
 }
 
 static inline void ip_vs_addr_copy(int af, union nf_inet_addr *dst,
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index a08a81e..f36b81c 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -934,7 +934,7 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related,
 	IP_VS_DBG_PKT(11, AF_INET, pp, skb, offset,
 		      "Checking outgoing ICMP for");
 
-	ip_vs_fill_iph_skb_off(AF_INET, skb, offset, &ciph);
+	ip_vs_fill_iph_skb_icmp(AF_INET, skb, offset, true, &ciph);
 
 	/* The embedded headers contain source and dest in reverse order */
 	cp = pp->conn_out_get(AF_INET, skb, &ciph, 1);
@@ -983,8 +983,8 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
 		  ic->icmp6_type, ntohs(icmpv6_id(ic)),
 		  &ipvsh->saddr, &ipvsh->daddr);
 
-	if (!ip_vs_fill_iph_skb_off(AF_INET6, skb, ipvsh->len + sizeof(_icmph),
-				    &ciph))
+	if (!ip_vs_fill_iph_skb_icmp(AF_INET6, skb, ipvsh->len + sizeof(_icmph),
+				     true, &ciph))
 		return NF_ACCEPT; /* The packet looks wrong, ignore */
 
 	pp = ip_vs_proto_get(ciph.protocol);
@@ -1177,7 +1177,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (!net_ipvs(net)->enable)
 		return NF_ACCEPT;
 
-	ip_vs_fill_iph_skb(af, skb, &iph);
+	ip_vs_fill_iph_skb(af, skb, false, &iph);
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
 		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
@@ -1212,7 +1212,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 					       ip_vs_defrag_user(hooknum)))
 				return NF_STOLEN;
 
-			ip_vs_fill_iph_skb(AF_INET, skb, &iph);
+			ip_vs_fill_iph_skb(AF_INET, skb, false, &iph);
 		}
 
 	/*
@@ -1407,7 +1407,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 		      "Checking incoming ICMP for");
 
 	offset2 = offset;
-	ip_vs_fill_iph_skb_off(AF_INET, skb, offset, &ciph);
+	ip_vs_fill_iph_skb_icmp(AF_INET, skb, offset, !ipip, &ciph);
 	offset = ciph.len;
 
 	/* The embedded headers contain source and dest in reverse order.
@@ -1537,7 +1537,7 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 		  &iph->saddr, &iph->daddr);
 
 	offset = iph->len + sizeof(_icmph);
-	if (!ip_vs_fill_iph_skb_off(AF_INET6, skb, offset, &ciph))
+	if (!ip_vs_fill_iph_skb_icmp(AF_INET6, skb, offset, true, &ciph))
 		return NF_ACCEPT;
 
 	net = skb_net(skb);
@@ -1613,7 +1613,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (unlikely((skb->pkt_type != PACKET_HOST &&
 		      hooknum != NF_INET_LOCAL_OUT) ||
 		     !skb_dst(skb))) {
-		ip_vs_fill_iph_skb(af, skb, &iph);
+		ip_vs_fill_iph_skb(af, skb, false, &iph);
 		IP_VS_DBG_BUF(12, "packet type=%d proto=%d daddr=%s"
 			      " ignored in hook %u\n",
 			      skb->pkt_type, iph.protocol,
@@ -1626,7 +1626,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (unlikely(sysctl_backup_only(ipvs) || !ipvs->enable))
 		return NF_ACCEPT;
 
-	ip_vs_fill_iph_skb(af, skb, &iph);
+	ip_vs_fill_iph_skb(af, skb, false, &iph);
 
 	/* Bad... Do not break raw sockets */
 	if (unlikely(skb->sk != NULL && hooknum == NF_INET_LOCAL_OUT &&
@@ -1840,7 +1840,7 @@ ip_vs_forward_icmp_v6(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	struct netns_ipvs *ipvs;
 	struct ip_vs_iphdr iphdr;
 
-	ip_vs_fill_iph_skb(AF_INET6, skb, &iphdr);
+	ip_vs_fill_iph_skb(AF_INET6, skb, false, &iphdr);
 	if (iphdr.protocol != IPPROTO_ICMPV6)
 		return NF_ACCEPT;
 
diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/ip_vs_pe_sip.c
index bed5f70..1b8d594 100644
--- a/net/netfilter/ipvs/ip_vs_pe_sip.c
+++ b/net/netfilter/ipvs/ip_vs_pe_sip.c
@@ -70,7 +70,7 @@ ip_vs_sip_fill_param(struct ip_vs_conn_param *p, struct sk_buff *skb)
 	const char *dptr;
 	int retc;
 
-	ip_vs_fill_iph_skb(p->af, skb, &iph);
+	ip_vs_fill_iph_skb(p->af, skb, false, &iph);
 
 	/* Only useful with UDP */
 	if (iph.protocol != IPPROTO_UDP)
diff --git a/net/netfilter/xt_ipvs.c b/net/netfilter/xt_ipvs.c
index 8d47c37..3704625 100644
--- a/net/netfilter/xt_ipvs.c
+++ b/net/netfilter/xt_ipvs.c
@@ -67,7 +67,7 @@ ipvs_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		goto out;
 	}
 
-	ip_vs_fill_iph_skb(family, skb, &iph);
+	ip_vs_fill_iph_skb(family, skb, true, &iph);
 
 	if (data->bitmask & XT_IPVS_PROTO)
 		if ((iph.protocol == data->l4proto) ^
-- 
Alex Gartrell <agartrell@fb.com>

