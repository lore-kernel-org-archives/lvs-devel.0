From: "Julius R. Volz" <juliusv@google.com>
Subject: [PATCH 12/26] IPVS: Extend proto handler debug functions to handle IPv6.
Date: Wed, 11 Jun 2008 19:11:55 +0200
Message-ID: <1213204329-10973-13-git-send-email-juliusv@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213204337; bh=kaT4Pe+QMQvaanBx46dumcWv3xk=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=XawlF2BV6cI5RQ6H8VrVt4KpkSmOZ20jmjH/jEbv
	7qweyaQ6h9IwD+b6nVSq1JWaAbi5iM6hpc/0dw/w5RUW6A==
In-Reply-To: <1213204329-10973-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com, "Julius R. Volz" <juliusv@google.com>

Extend protocol handler packet debug functions for TCP, UDP, AH and ESP to
handle IPv6. Make the main debug function call either a v4 or v6 version,
depending on the packet protocol version.

Signed-off-by: Julius R. Volz <juliusv@google.com>

 3 files changed, 127 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 4b1c16c..8b82400 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -154,10 +154,10 @@ const char * ip_vs_state_name(__u16 proto, int state)
 
 
 void
-ip_vs_tcpudp_debug_packet(struct ip_vs_protocol *pp,
-			  const struct sk_buff *skb,
-			  int offset,
-			  const char *msg)
+ip_vs_tcpudp_debug_packet_v4(struct ip_vs_protocol *pp,
+			     const struct sk_buff *skb,
+			     int offset,
+			     const char *msg)
 {
 	char buf[128];
 	struct iphdr _iph, *ih;
@@ -170,8 +170,8 @@ ip_vs_tcpudp_debug_packet(struct ip_vs_protocol *pp,
 			pp->name, NIPQUAD(ih->saddr),
 			NIPQUAD(ih->daddr));
 	else {
-		__be16 _ports[2], *pptr
-;
+		__be16 _ports[2], *pptr;
+
 		pptr = skb_header_pointer(skb, offset + ih->ihl*4,
 					  sizeof(_ports), _ports);
 		if (pptr == NULL)
@@ -191,6 +191,60 @@ ip_vs_tcpudp_debug_packet(struct ip_vs_protocol *pp,
 	printk(KERN_DEBUG "IPVS: %s: %s\n", msg, buf);
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+void
+ip_vs_tcpudp_debug_packet_v6(struct ip_vs_protocol *pp,
+			     const struct sk_buff *skb,
+			     int offset,
+			     const char *msg)
+{
+	char buf[192];
+	struct ipv6hdr _iph, *ih;
+
+	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
+	if (ih == NULL)
+		sprintf(buf, "%s TRUNCATED", pp->name);
+	else if (ih->nexthdr == IPPROTO_FRAGMENT)
+		sprintf(buf, "%s " NIP6_FMT "->" NIP6_FMT " frag",
+			pp->name, NIP6(ih->saddr),
+			NIP6(ih->daddr));
+	else {
+		__be16 _ports[2], *pptr;
+
+		pptr = skb_header_pointer(skb, offset + sizeof(struct ipv6hdr),
+					  sizeof(_ports), _ports);
+		if (pptr == NULL)
+			sprintf(buf, "%s TRUNCATED " NIP6_FMT "->" NIP6_FMT,
+				pp->name,
+				NIP6(ih->saddr),
+				NIP6(ih->daddr));
+		else
+			sprintf(buf, "%s " NIP6_FMT ":%u->" NIP6_FMT ":%u",
+				pp->name,
+				NIP6(ih->saddr),
+				ntohs(pptr[0]),
+				NIP6(ih->daddr),
+				ntohs(pptr[1]));
+	}
+
+	printk(KERN_DEBUG "IPVS: %s: %s\n", msg, buf);
+}
+#endif
+
+
+void
+ip_vs_tcpudp_debug_packet(struct ip_vs_protocol *pp,
+			  const struct sk_buff *skb,
+			  int offset,
+			  const char *msg)
+{
+#ifdef CONFIG_IP_VS_IPV6
+	if (skb->protocol == htons(ETH_P_IPV6))
+		ip_vs_tcpudp_debug_packet_v6(pp, skb, offset, msg);
+	else
+#endif
+		ip_vs_tcpudp_debug_packet_v4(pp, skb, offset, msg);
+}
 
 int ip_vs_protocol_init(void)
 {
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah.c b/net/netfilter/ipvs/ip_vs_proto_ah.c
index 674c9d8..7c727d7 100644
--- a/net/netfilter/ipvs/ip_vs_proto_ah.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah.c
@@ -202,8 +202,8 @@ ah_conn_schedule(struct sk_buff *skb,
 
 
 static void
-ah_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
-		int offset, const char *msg)
+ah_debug_packet_v4(struct ip_vs_protocol *pp, const struct sk_buff *skb,
+		   int offset, const char *msg)
 {
 	char buf[256];
 	struct iphdr _iph, *ih;
@@ -219,6 +219,38 @@ ah_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
 	printk(KERN_DEBUG "IPVS: %s: %s\n", msg, buf);
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static void
+ah_debug_packet_v6(struct ip_vs_protocol *pp, const struct sk_buff *skb,
+		   int offset, const char *msg)
+{
+	char buf[256];
+	struct ipv6hdr _iph, *ih;
+
+	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
+	if (ih == NULL)
+		sprintf(buf, "%s TRUNCATED", pp->name);
+	else
+		sprintf(buf, "%s " NIP6_FMT "->" NIP6_FMT,
+			pp->name, NIP6(ih->saddr),
+			NIP6(ih->daddr));
+
+	printk(KERN_DEBUG "IPVS: %s: %s\n", msg, buf);
+}
+#endif
+
+static void
+ah_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
+		int offset, const char *msg)
+{
+#ifdef CONFIG_IP_VS_IPV6
+	if (skb->protocol == htons(ETH_P_IPV6))
+		ah_debug_packet_v6(pp, skb, offset, msg);
+	else
+#endif
+		ah_debug_packet_v4(pp, skb, offset, msg);
+}
+
 
 static void ah_init(struct ip_vs_protocol *pp)
 {
diff --git a/net/netfilter/ipvs/ip_vs_proto_esp.c b/net/netfilter/ipvs/ip_vs_proto_esp.c
index 5113df4..c7606c7 100644
--- a/net/netfilter/ipvs/ip_vs_proto_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_esp.c
@@ -201,8 +201,8 @@ esp_conn_schedule(struct sk_buff *skb, struct ip_vs_protocol *pp,
 
 
 static void
-esp_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
-		 int offset, const char *msg)
+esp_debug_packet_v4(struct ip_vs_protocol *pp, const struct sk_buff *skb,
+		    int offset, const char *msg)
 {
 	char buf[256];
 	struct iphdr _iph, *ih;
@@ -218,6 +218,37 @@ esp_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
 	printk(KERN_DEBUG "IPVS: %s: %s\n", msg, buf);
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static void
+esp_debug_packet_v6(struct ip_vs_protocol *pp, const struct sk_buff *skb,
+		    int offset, const char *msg)
+{
+	char buf[256];
+	struct ipv6hdr _iph, *ih;
+
+	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
+	if (ih == NULL)
+		sprintf(buf, "%s TRUNCATED", pp->name);
+	else
+		sprintf(buf, "%s " NIP6_FMT "->" NIP6_FMT,
+			pp->name, NIP6(ih->saddr),
+			NIP6(ih->daddr));
+
+	printk(KERN_DEBUG "IPVS: %s: %s\n", msg, buf);
+}
+#endif
+
+static void
+esp_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
+		 int offset, const char *msg)
+{
+#ifdef CONFIG_IP_VS_IPV6
+	if (skb->protocol == htons(ETH_P_IPV6))
+		esp_debug_packet_v6(pp, skb, offset, msg);
+	else
+#endif
+		esp_debug_packet_v4(pp, skb, offset, msg);
+}
 
 static void esp_init(struct ip_vs_protocol *pp)
 {
-- 
1.5.3.6

