From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] ipvs: change some __constant_htons() to htons()
Date: Tue, 16 Sep 2008 11:11:11 -0400
Message-ID: <48CFCC8F.1040702@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000809030502090009010403"
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org

This is a multi-part message in MIME format.
--------------000809030502090009010403
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Change __contant_htons() to htons() in the IPVS code when not in an 
initializer.

-Brian

Signed-off-by: Brian Haley <brian.haley@hp.com>
---

--------------000809030502090009010403
Content-Type: text/x-patch;
 name="ipvs.htons.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ipvs.htons.patch"

diff --git a/net/ipv4/ipvs/ip_vs_proto.c b/net/ipv4/ipvs/ip_vs_proto.c
index b06da1c..0791f9e 100644
--- a/net/ipv4/ipvs/ip_vs_proto.c
+++ b/net/ipv4/ipvs/ip_vs_proto.c
@@ -237,7 +237,7 @@ ip_vs_tcpudp_debug_packet(struct ip_vs_protocol *pp,
 			  const char *msg)
 {
 #ifdef CONFIG_IP_VS_IPV6
-	if (skb->protocol == __constant_htons(ETH_P_IPV6))
+	if (skb->protocol == htons(ETH_P_IPV6))
 		ip_vs_tcpudp_debug_packet_v6(pp, skb, offset, msg);
 	else
 #endif
diff --git a/net/ipv4/ipvs/ip_vs_proto_ah_esp.c b/net/ipv4/ipvs/ip_vs_proto_ah_esp.c
index 2b18a78..80ab0c8 100644
--- a/net/ipv4/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_ah_esp.c
@@ -167,7 +167,7 @@ ah_esp_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
 		    int offset, const char *msg)
 {
 #ifdef CONFIG_IP_VS_IPV6
-	if (skb->protocol == __constant_htons(ETH_P_IPV6))
+	if (skb->protocol == htons(ETH_P_IPV6))
 		ah_esp_debug_packet_v6(pp, skb, offset, msg);
 	else
 #endif

--------------000809030502090009010403--
