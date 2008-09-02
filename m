From: Julius Volz <juliusv@google.com>
Subject: [PATCHv3 10/24] IPVS: Add protocol debug functions for IPv6
Date: Tue,  2 Sep 2008 15:55:41 +0200
Message-ID: <1220363755-9854-11-git-send-email-juliusv@google.com>
References: <1220363755-9854-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220363768; bh=TbJ0mUsJWEqhYNLDE0HZ5v8zHas=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=WgSZ0c3wrjwtVL8E7UDDUfoLgVZEMZArej2Hixqs
	6peoYOI0GdPEekRDPcHWTUL391SEMltzSFqDSmgV1QSTgg==
In-Reply-To: <1220363755-9854-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Add protocol (TCP, UDP, AH, ESP) debug functions for IPv6 packet debug
output.

Signed-off-by: Julius Volz <juliusv@google.com>

 2 files changed, 93 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_proto.c b/net/ipv4/ipvs/ip_vs_proto.c
index 6099a88..50f6215 100644
--- a/net/ipv4/ipvs/ip_vs_proto.c
+++ b/net/ipv4/ipvs/ip_vs_proto.c
@@ -152,10 +152,10 @@ const char * ip_vs_state_name(__u16 proto, int state)
 
 
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
@@ -189,6 +189,61 @@ ip_vs_tcpudp_debug_packet(struct ip_vs_protocol *pp,
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
+	if (skb->protocol == __constant_htons(ETH_P_IPV6))
+		ip_vs_tcpudp_debug_packet_v6(pp, skb, offset, msg);
+	else
+#endif
+		ip_vs_tcpudp_debug_packet_v4(pp, skb, offset, msg);
+}
+
 
 int __init ip_vs_protocol_init(void)
 {
diff --git a/net/ipv4/ipvs/ip_vs_proto_ah_esp.c b/net/ipv4/ipvs/ip_vs_proto_ah_esp.c
index 2a361a9..4b0b8f2 100644
--- a/net/ipv4/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_ah_esp.c
@@ -125,8 +125,8 @@ ah_esp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 
 
 static void
-ah_esp_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
-		    int offset, const char *msg)
+ah_esp_debug_packet_v4(struct ip_vs_protocol *pp, const struct sk_buff *skb,
+		       int offset, const char *msg)
 {
 	char buf[256];
 	struct iphdr _iph, *ih;
@@ -142,6 +142,38 @@ ah_esp_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
 	printk(KERN_DEBUG "IPVS: %s: %s\n", msg, buf);
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static void
+ah_esp_debug_packet_v6(struct ip_vs_protocol *pp, const struct sk_buff *skb,
+		       int offset, const char *msg)
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
+ah_esp_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
+		    int offset, const char *msg)
+{
+#ifdef CONFIG_IP_VS_IPV6
+	if (skb->protocol == __constant_htons(ETH_P_IPV6))
+		ah_esp_debug_packet_v6(pp, skb, offset, msg);
+	else
+#endif
+		ah_esp_debug_packet_v4(pp, skb, offset, msg);
+}
+
 
 static void ah_esp_init(struct ip_vs_protocol *pp)
 {
-- 
1.5.4.5

