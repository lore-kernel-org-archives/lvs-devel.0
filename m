From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next 03/12] ipvs: Add hdr_flags to iphdr
Date: Wed, 12 Aug 2015 13:47:01 -0700
Message-ID: <1439412430-1702375-4-git-send-email-agartrell@fb.com>
References: <1439412430-1702375-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=Y0eAbiPF5KXaWUJnkJTU0XthM4m3X3OrgQfrt32zYQM=;
 b=CuIt5OMZC7des7kFHcjhJ+fyoug3fSlVFRZbR6kY7DkuLryQ8pKm6dwZRtx3bFQco4hw
 N9tMdcCVTMHxmULUa9ofqxIQCDmgVGvVYCv3NLJ1/d/C9oafYC+7Lo/ov5KrxRFJyUYz
 1WEWeC/CXDBbFvOYxXHrucSK0LCQ15lozzo= 
In-Reply-To: <1439412430-1702375-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ja@ssi.bg, horms@verge.net.au, lvs-devel@vger.kernel.org
Cc: kernel-team@fb.com, alexgartrell@gmail.com, Alex Gartrell <agartrell@fb.com>

These flags contain information like whether or not the addresses are
inverted or from icmp.  The first will allow us to drop an inverse param
all over the place, and the second will later be useful in scheduling icmp.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 include/net/ip_vs.h             | 37 ++++++++++++++++++++++++++++++++++---
 net/netfilter/ipvs/ip_vs_core.c | 22 ++++++++++++----------
 2 files changed, 46 insertions(+), 13 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 3e09725..9333a0a 100644
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
 	__u32 len;	/* IPv4 simply where L4 starts
 			 * IPv6 where L4 Transport Header starts */
 	__u16 fragoffs; /* IPv6 fragment offset, 0 if first frag (or not frag)*/
@@ -126,8 +130,14 @@ static inline void *frag_safe_skb_hp(const struct sk_buff *skb, int offset,
  */
 static inline int
 ip_vs_fill_iph_skb_off(int af, const struct sk_buff *skb, int offset,
-		       struct ip_vs_iphdr *iphdr)
+		       bool inverse, bool icmp, struct ip_vs_iphdr *iphdr)
 {
+	iphdr->hdr_flags = 0;
+	if (inverse)
+		iphdr->hdr_flags |= IP_VS_HDR_INVERSE;
+	if (icmp)
+		iphdr->hdr_flags |= IP_VS_HDR_ICMP;
+
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
 		struct ipv6hdr _iph;
@@ -166,9 +176,30 @@ ip_vs_fill_iph_skb_off(int af, const struct sk_buff *skb, int offset,
 }
 
 static inline int
-ip_vs_fill_iph_skb(int af, const struct sk_buff *skb, struct ip_vs_iphdr *iphdr)
+ip_vs_fill_iph_skb_icmp(int af, const struct sk_buff *skb, int offset,
+			bool inverse, struct ip_vs_iphdr *iphdr)
+{
+	return ip_vs_fill_iph_skb_off(af, skb, offset, inverse, true, iphdr);
+}
+
+static inline int
+ip_vs_fill_iph_skb(int af, const struct sk_buff *skb, bool inverse,
+		   struct ip_vs_iphdr *iphdr)
+{
+	return ip_vs_fill_iph_skb_off(
+		af, skb, skb_network_offset(skb), inverse, false, iphdr);
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
index f8725d5..2ff3eb4 100644
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
 
-	if (!ip_vs_fill_iph_skb_off(
-		    AF_INET6, skb, ipvsh->len + sizeof(_icmph), &ciph))
+	if (!ip_vs_fill_iph_skb_icmp(
+		    AF_INET6, skb, ipvsh->len + sizeof(_icmph), true, &ciph))
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
@@ -1433,7 +1433,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 		return NF_ACCEPT;
 	pp = pd->pp;
 
-	ip_vs_fill_iph_skb_off(AF_INET, skb, offset, &ciph);
+	ip_vs_fill_iph_skb_icmp(AF_INET, skb, offset, !ipip, &ciph);
 
 	/* Is the embedded protocol header present? */
 	if (unlikely(cih->frag_off & htons(IP_OFFSET) &&
@@ -1572,7 +1572,9 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 		  &iph->saddr, &iph->daddr);
 
 	offs_ciph = iph->len + sizeof(_icmph);
-	if (!ip_vs_fill_iph_skb_off(AF_INET6, skb, offs_ciph, &ciph))
+	if (!ip_vs_fill_iph_skb_icmp(
+		    AF_INET6, skb, offs_ciph, (hooknum != NF_INET_LOCAL_OUT),
+		    &ciph))
 		return NF_ACCEPT;
 
 	net = skb_net(skb);
@@ -1649,7 +1651,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (unlikely((skb->pkt_type != PACKET_HOST &&
 		      hooknum != NF_INET_LOCAL_OUT) ||
 		     !skb_dst(skb))) {
-		ip_vs_fill_iph_skb(af, skb, &iph);
+		ip_vs_fill_iph_skb(af, skb, false, &iph);
 		IP_VS_DBG_BUF(12, "packet type=%d proto=%d daddr=%s"
 			      " ignored in hook %u\n",
 			      skb->pkt_type, iph.protocol,
@@ -1662,7 +1664,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (unlikely(sysctl_backup_only(ipvs) || !ipvs->enable))
 		return NF_ACCEPT;
 
-	ip_vs_fill_iph_skb(af, skb, &iph);
+	ip_vs_fill_iph_skb(af, skb, false, &iph);
 
 	/* Bad... Do not break raw sockets */
 	if (unlikely(skb->sk != NULL && hooknum == NF_INET_LOCAL_OUT &&
@@ -1857,7 +1859,7 @@ ip_vs_forward_icmp_v6(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	struct netns_ipvs *ipvs;
 	struct ip_vs_iphdr iphdr;
 
-	ip_vs_fill_iph_skb(AF_INET6, skb, &iphdr);
+	ip_vs_fill_iph_skb(AF_INET6, skb, false, &iphdr);
 	if (iphdr.protocol != IPPROTO_ICMPV6)
 		return NF_ACCEPT;
 
-- 
Alex Gartrell <agartrell@fb.com>

