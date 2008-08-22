From: Julius Volz <juliusv@google.com>
Subject: [PATCH 1/2] IPVS: Integrate ESP protocol into ip_vs_proto_ah.c
Date: Fri, 22 Aug 2008 14:06:12 +0200
Message-ID: <1219406773-19357-2-git-send-email-juliusv@google.com>
References: <1219406773-19357-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219406780; bh=gLNXC0avtCno6Eq6BahQnPlLH20=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=x06oEbzJlGhx2Yksd1NU6+9MRgcwfmyFCxdAqS9m
	DBsk/nFc0VRzSDsdtvvdj2owB+m/KwdV8KkxNJjtT+FORA==
In-Reply-To: <1219406773-19357-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, vbusam@google.com, sven.wegener@stealer.net, brian.haley@hp.com, Julius Volz <juliusv@google.com>

Rename all ah_* functions to ah_esp_* (and adjust comments). Move ESP
protocol definition into ip_vs_proto_ah.c and remove all usage of
ip_vs_proto_esp.c.

Make the compilation of ip_vs_proto_ah.c dependent on a new config
variable, IP_VS_PROTO_AH_ESP, which is selected either by
IP_VS_PROTO_ESP or IP_VS_PROTO_AH. Only compile the selected protocols'
structures within this file.

Signed-off-by: Julius Volz <juliusv@google.com>

 3 files changed, 54 insertions(+), 24 deletions(-)

diff --git a/net/ipv4/ipvs/Kconfig b/net/ipv4/ipvs/Kconfig
index 09d0c3f..2e48a7e 100644
--- a/net/ipv4/ipvs/Kconfig
+++ b/net/ipv4/ipvs/Kconfig
@@ -71,14 +71,20 @@ config	IP_VS_PROTO_UDP
 	  This option enables support for load balancing UDP transport
 	  protocol. Say Y if unsure.
 
+config	IP_VS_PROTO_AH_ESP
+	bool
+	depends on UNDEFINED
+
 config	IP_VS_PROTO_ESP
 	bool "ESP load balancing support"
+	select IP_VS_PROTO_AH_ESP
 	---help---
 	  This option enables support for load balancing ESP (Encapsulation
 	  Security Payload) transport protocol. Say Y if unsure.
 
 config	IP_VS_PROTO_AH
 	bool "AH load balancing support"
+	select IP_VS_PROTO_AH_ESP
 	---help---
 	  This option enables support for load balancing AH (Authentication
 	  Header) transport protocol. Say Y if unsure.
diff --git a/net/ipv4/ipvs/Makefile b/net/ipv4/ipvs/Makefile
index 30e85de..cda3e08 100644
--- a/net/ipv4/ipvs/Makefile
+++ b/net/ipv4/ipvs/Makefile
@@ -6,8 +6,7 @@
 ip_vs_proto-objs-y :=
 ip_vs_proto-objs-$(CONFIG_IP_VS_PROTO_TCP) += ip_vs_proto_tcp.o
 ip_vs_proto-objs-$(CONFIG_IP_VS_PROTO_UDP) += ip_vs_proto_udp.o
-ip_vs_proto-objs-$(CONFIG_IP_VS_PROTO_ESP) += ip_vs_proto_esp.o
-ip_vs_proto-objs-$(CONFIG_IP_VS_PROTO_AH) += ip_vs_proto_ah.o
+ip_vs_proto-objs-$(CONFIG_IP_VS_PROTO_AH_ESP) += ip_vs_proto_ah.o
 
 ip_vs-objs :=	ip_vs_conn.o ip_vs_core.o ip_vs_ctl.o ip_vs_sched.o	   \
 		ip_vs_xmit.o ip_vs_app.o ip_vs_sync.o	   		   \
diff --git a/net/ipv4/ipvs/ip_vs_proto_ah.c b/net/ipv4/ipvs/ip_vs_proto_ah.c
index 73e0ea8..3f9ebd7 100644
--- a/net/ipv4/ipvs/ip_vs_proto_ah.c
+++ b/net/ipv4/ipvs/ip_vs_proto_ah.c
@@ -1,5 +1,5 @@
 /*
- * ip_vs_proto_ah.c:	AH IPSec load balancing support for IPVS
+ * ip_vs_proto_ah_esp.c:	AH/ESP IPSec load balancing support for IPVS
  *
  * Authors:	Julian Anastasov <ja@ssi.bg>, February 2002
  *		Wensong Zhang <wensong@linuxvirtualserver.org>
@@ -39,11 +39,11 @@ struct isakmp_hdr {
 
 
 static struct ip_vs_conn *
-ah_conn_in_get(const struct sk_buff *skb,
-	       struct ip_vs_protocol *pp,
-	       const struct iphdr *iph,
-	       unsigned int proto_off,
-	       int inverse)
+ah_esp_conn_in_get(const struct sk_buff *skb,
+		   struct ip_vs_protocol *pp,
+		   const struct iphdr *iph,
+		   unsigned int proto_off,
+		   int inverse)
 {
 	struct ip_vs_conn *cp;
 
@@ -79,8 +79,8 @@ ah_conn_in_get(const struct sk_buff *skb,
 
 
 static struct ip_vs_conn *
-ah_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
-		const struct iphdr *iph, unsigned int proto_off, int inverse)
+ah_esp_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
+		    const struct iphdr *iph, unsigned int proto_off, int inverse)
 {
 	struct ip_vs_conn *cp;
 
@@ -112,12 +112,12 @@ ah_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
 
 
 static int
-ah_conn_schedule(struct sk_buff *skb,
-		 struct ip_vs_protocol *pp,
-		 int *verdict, struct ip_vs_conn **cpp)
+ah_esp_conn_schedule(struct sk_buff *skb,
+		     struct ip_vs_protocol *pp,
+		     int *verdict, struct ip_vs_conn **cpp)
 {
 	/*
-	 * AH is only related traffic. Pass the packet to IP stack.
+	 * AH/ESP is only related traffic. Pass the packet to IP stack.
 	 */
 	*verdict = NF_ACCEPT;
 	return 0;
@@ -125,8 +125,8 @@ ah_conn_schedule(struct sk_buff *skb,
 
 
 static void
-ah_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
-		int offset, const char *msg)
+ah_esp_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
+		    int offset, const char *msg)
 {
 	char buf[256];
 	struct iphdr _iph, *ih;
@@ -143,28 +143,29 @@ ah_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
 }
 
 
-static void ah_init(struct ip_vs_protocol *pp)
+static void ah_esp_init(struct ip_vs_protocol *pp)
 {
 	/* nothing to do now */
 }
 
 
-static void ah_exit(struct ip_vs_protocol *pp)
+static void ah_esp_exit(struct ip_vs_protocol *pp)
 {
 	/* nothing to do now */
 }
 
 
+#ifdef CONFIG_IP_VS_PROTO_AH
 struct ip_vs_protocol ip_vs_protocol_ah = {
 	.name =			"AH",
 	.protocol =		IPPROTO_AH,
 	.num_states =		1,
 	.dont_defrag =		1,
-	.init =			ah_init,
-	.exit =			ah_exit,
-	.conn_schedule =	ah_conn_schedule,
-	.conn_in_get =		ah_conn_in_get,
-	.conn_out_get =		ah_conn_out_get,
+	.init =			ah_esp_init,
+	.exit =			ah_esp_exit,
+	.conn_schedule =	ah_esp_conn_schedule,
+	.conn_in_get =		ah_esp_conn_in_get,
+	.conn_out_get =		ah_esp_conn_out_get,
 	.snat_handler =		NULL,
 	.dnat_handler =		NULL,
 	.csum_check =		NULL,
@@ -172,7 +173,31 @@ struct ip_vs_protocol ip_vs_protocol_ah = {
 	.register_app =		NULL,
 	.unregister_app =	NULL,
 	.app_conn_bind =	NULL,
-	.debug_packet =		ah_debug_packet,
+	.debug_packet =		ah_esp_debug_packet,
 	.timeout_change =	NULL,		/* ISAKMP */
 	.set_state_timeout =	NULL,
 };
+#endif
+
+#ifdef CONFIG_IP_VS_PROTO_ESP
+struct ip_vs_protocol ip_vs_protocol_esp = {
+	.name =			"ESP",
+	.protocol =		IPPROTO_ESP,
+	.num_states =		1,
+	.dont_defrag =		1,
+	.init =			ah_esp_init,
+	.exit =			ah_esp_exit,
+	.conn_schedule =	ah_esp_conn_schedule,
+	.conn_in_get =		ah_esp_conn_in_get,
+	.conn_out_get =		ah_esp_conn_out_get,
+	.snat_handler =		NULL,
+	.dnat_handler =		NULL,
+	.csum_check =		NULL,
+	.state_transition =	NULL,
+	.register_app =		NULL,
+	.unregister_app =	NULL,
+	.app_conn_bind =	NULL,
+	.debug_packet =		ah_esp_debug_packet,
+	.timeout_change =	NULL,		/* ISAKMP */
+};
+#endif
-- 
1.5.4.5

