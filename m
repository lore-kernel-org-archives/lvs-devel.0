From: Julius Volz <juliusv@google.com>
Subject: [PATCH 2/2] IPVS: Rename ip_vs_proto_ah.c to ip_vs_proto_ah_esp.c
Date: Fri, 22 Aug 2008 14:06:13 +0200
Message-ID: <1219406773-19357-3-git-send-email-juliusv@google.com>
References: <1219406773-19357-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219406782; bh=fJJLWFvB5LaJaqwYJ/8QKq5ztyM=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=kuFw4qrONmn71mCd/dYT54hJeNQOebexZfUcd5+b
	HKyUNN/z8pdDEAWJE+cyAlI1FrRXHX1NacT7T+PaR4Qqow==
In-Reply-To: <1219406773-19357-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, vbusam@google.com, sven.wegener@stealer.net, brian.haley@hp.com, Julius Volz <juliusv@google.com>

After integrating ESP into ip_vs_proto_ah, rename it (and the references to
it) to ip_vs_proto_ah_esp.c and delete the old ip_vs_proto_esp.c.

Signed-off-by: Julius Volz <juliusv@google.com>

 4 files changed, 204 insertions(+), 380 deletions(-)

diff --git a/net/ipv4/ipvs/Makefile b/net/ipv4/ipvs/Makefile
index cda3e08..73a46fe 100644
--- a/net/ipv4/ipvs/Makefile
+++ b/net/ipv4/ipvs/Makefile
@@ -6,7 +6,7 @@
 ip_vs_proto-objs-y :=
 ip_vs_proto-objs-$(CONFIG_IP_VS_PROTO_TCP) += ip_vs_proto_tcp.o
 ip_vs_proto-objs-$(CONFIG_IP_VS_PROTO_UDP) += ip_vs_proto_udp.o
-ip_vs_proto-objs-$(CONFIG_IP_VS_PROTO_AH_ESP) += ip_vs_proto_ah.o
+ip_vs_proto-objs-$(CONFIG_IP_VS_PROTO_AH_ESP) += ip_vs_proto_ah_esp.o
 
 ip_vs-objs :=	ip_vs_conn.o ip_vs_core.o ip_vs_ctl.o ip_vs_sched.o	   \
 		ip_vs_xmit.o ip_vs_app.o ip_vs_sync.o	   		   \
diff --git a/net/ipv4/ipvs/ip_vs_proto_ah.c b/net/ipv4/ipvs/ip_vs_proto_ah.c
deleted file mode 100644
index 3f9ebd7..0000000
--- a/net/ipv4/ipvs/ip_vs_proto_ah.c
+++ /dev/null
@@ -1,203 +0,0 @@
-/*
- * ip_vs_proto_ah_esp.c:	AH/ESP IPSec load balancing support for IPVS
- *
- * Authors:	Julian Anastasov <ja@ssi.bg>, February 2002
- *		Wensong Zhang <wensong@linuxvirtualserver.org>
- *
- *		This program is free software; you can redistribute it and/or
- *		modify it under the terms of the GNU General Public License
- *		version 2 as published by the Free Software Foundation;
- *
- */
-
-#include <linux/in.h>
-#include <linux/ip.h>
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/netfilter.h>
-#include <linux/netfilter_ipv4.h>
-
-#include <net/ip_vs.h>
-
-
-/* TODO:
-
-struct isakmp_hdr {
-	__u8		icookie[8];
-	__u8		rcookie[8];
-	__u8		np;
-	__u8		version;
-	__u8		xchgtype;
-	__u8		flags;
-	__u32		msgid;
-	__u32		length;
-};
-
-*/
-
-#define PORT_ISAKMP	500
-
-
-static struct ip_vs_conn *
-ah_esp_conn_in_get(const struct sk_buff *skb,
-		   struct ip_vs_protocol *pp,
-		   const struct iphdr *iph,
-		   unsigned int proto_off,
-		   int inverse)
-{
-	struct ip_vs_conn *cp;
-
-	if (likely(!inverse)) {
-		cp = ip_vs_conn_in_get(IPPROTO_UDP,
-				       iph->saddr,
-				       htons(PORT_ISAKMP),
-				       iph->daddr,
-				       htons(PORT_ISAKMP));
-	} else {
-		cp = ip_vs_conn_in_get(IPPROTO_UDP,
-				       iph->daddr,
-				       htons(PORT_ISAKMP),
-				       iph->saddr,
-				       htons(PORT_ISAKMP));
-	}
-
-	if (!cp) {
-		/*
-		 * We are not sure if the packet is from our
-		 * service, so our conn_schedule hook should return NF_ACCEPT
-		 */
-		IP_VS_DBG(12, "Unknown ISAKMP entry for outin packet "
-			  "%s%s %u.%u.%u.%u->%u.%u.%u.%u\n",
-			  inverse ? "ICMP+" : "",
-			  pp->name,
-			  NIPQUAD(iph->saddr),
-			  NIPQUAD(iph->daddr));
-	}
-
-	return cp;
-}
-
-
-static struct ip_vs_conn *
-ah_esp_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
-		    const struct iphdr *iph, unsigned int proto_off, int inverse)
-{
-	struct ip_vs_conn *cp;
-
-	if (likely(!inverse)) {
-		cp = ip_vs_conn_out_get(IPPROTO_UDP,
-					iph->saddr,
-					htons(PORT_ISAKMP),
-					iph->daddr,
-					htons(PORT_ISAKMP));
-	} else {
-		cp = ip_vs_conn_out_get(IPPROTO_UDP,
-					iph->daddr,
-					htons(PORT_ISAKMP),
-					iph->saddr,
-					htons(PORT_ISAKMP));
-	}
-
-	if (!cp) {
-		IP_VS_DBG(12, "Unknown ISAKMP entry for inout packet "
-			  "%s%s %u.%u.%u.%u->%u.%u.%u.%u\n",
-			  inverse ? "ICMP+" : "",
-			  pp->name,
-			  NIPQUAD(iph->saddr),
-			  NIPQUAD(iph->daddr));
-	}
-
-	return cp;
-}
-
-
-static int
-ah_esp_conn_schedule(struct sk_buff *skb,
-		     struct ip_vs_protocol *pp,
-		     int *verdict, struct ip_vs_conn **cpp)
-{
-	/*
-	 * AH/ESP is only related traffic. Pass the packet to IP stack.
-	 */
-	*verdict = NF_ACCEPT;
-	return 0;
-}
-
-
-static void
-ah_esp_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
-		    int offset, const char *msg)
-{
-	char buf[256];
-	struct iphdr _iph, *ih;
-
-	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
-	if (ih == NULL)
-		sprintf(buf, "%s TRUNCATED", pp->name);
-	else
-		sprintf(buf, "%s %u.%u.%u.%u->%u.%u.%u.%u",
-			pp->name, NIPQUAD(ih->saddr),
-			NIPQUAD(ih->daddr));
-
-	printk(KERN_DEBUG "IPVS: %s: %s\n", msg, buf);
-}
-
-
-static void ah_esp_init(struct ip_vs_protocol *pp)
-{
-	/* nothing to do now */
-}
-
-
-static void ah_esp_exit(struct ip_vs_protocol *pp)
-{
-	/* nothing to do now */
-}
-
-
-#ifdef CONFIG_IP_VS_PROTO_AH
-struct ip_vs_protocol ip_vs_protocol_ah = {
-	.name =			"AH",
-	.protocol =		IPPROTO_AH,
-	.num_states =		1,
-	.dont_defrag =		1,
-	.init =			ah_esp_init,
-	.exit =			ah_esp_exit,
-	.conn_schedule =	ah_esp_conn_schedule,
-	.conn_in_get =		ah_esp_conn_in_get,
-	.conn_out_get =		ah_esp_conn_out_get,
-	.snat_handler =		NULL,
-	.dnat_handler =		NULL,
-	.csum_check =		NULL,
-	.state_transition =	NULL,
-	.register_app =		NULL,
-	.unregister_app =	NULL,
-	.app_conn_bind =	NULL,
-	.debug_packet =		ah_esp_debug_packet,
-	.timeout_change =	NULL,		/* ISAKMP */
-	.set_state_timeout =	NULL,
-};
-#endif
-
-#ifdef CONFIG_IP_VS_PROTO_ESP
-struct ip_vs_protocol ip_vs_protocol_esp = {
-	.name =			"ESP",
-	.protocol =		IPPROTO_ESP,
-	.num_states =		1,
-	.dont_defrag =		1,
-	.init =			ah_esp_init,
-	.exit =			ah_esp_exit,
-	.conn_schedule =	ah_esp_conn_schedule,
-	.conn_in_get =		ah_esp_conn_in_get,
-	.conn_out_get =		ah_esp_conn_out_get,
-	.snat_handler =		NULL,
-	.dnat_handler =		NULL,
-	.csum_check =		NULL,
-	.state_transition =	NULL,
-	.register_app =		NULL,
-	.unregister_app =	NULL,
-	.app_conn_bind =	NULL,
-	.debug_packet =		ah_esp_debug_packet,
-	.timeout_change =	NULL,		/* ISAKMP */
-};
-#endif
diff --git a/net/ipv4/ipvs/ip_vs_proto_ah_esp.c b/net/ipv4/ipvs/ip_vs_proto_ah_esp.c
new file mode 100644
index 0000000..3f9ebd7
--- /dev/null
+++ b/net/ipv4/ipvs/ip_vs_proto_ah_esp.c
@@ -0,0 +1,203 @@
+/*
+ * ip_vs_proto_ah_esp.c:	AH/ESP IPSec load balancing support for IPVS
+ *
+ * Authors:	Julian Anastasov <ja@ssi.bg>, February 2002
+ *		Wensong Zhang <wensong@linuxvirtualserver.org>
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		version 2 as published by the Free Software Foundation;
+ *
+ */
+
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv4.h>
+
+#include <net/ip_vs.h>
+
+
+/* TODO:
+
+struct isakmp_hdr {
+	__u8		icookie[8];
+	__u8		rcookie[8];
+	__u8		np;
+	__u8		version;
+	__u8		xchgtype;
+	__u8		flags;
+	__u32		msgid;
+	__u32		length;
+};
+
+*/
+
+#define PORT_ISAKMP	500
+
+
+static struct ip_vs_conn *
+ah_esp_conn_in_get(const struct sk_buff *skb,
+		   struct ip_vs_protocol *pp,
+		   const struct iphdr *iph,
+		   unsigned int proto_off,
+		   int inverse)
+{
+	struct ip_vs_conn *cp;
+
+	if (likely(!inverse)) {
+		cp = ip_vs_conn_in_get(IPPROTO_UDP,
+				       iph->saddr,
+				       htons(PORT_ISAKMP),
+				       iph->daddr,
+				       htons(PORT_ISAKMP));
+	} else {
+		cp = ip_vs_conn_in_get(IPPROTO_UDP,
+				       iph->daddr,
+				       htons(PORT_ISAKMP),
+				       iph->saddr,
+				       htons(PORT_ISAKMP));
+	}
+
+	if (!cp) {
+		/*
+		 * We are not sure if the packet is from our
+		 * service, so our conn_schedule hook should return NF_ACCEPT
+		 */
+		IP_VS_DBG(12, "Unknown ISAKMP entry for outin packet "
+			  "%s%s %u.%u.%u.%u->%u.%u.%u.%u\n",
+			  inverse ? "ICMP+" : "",
+			  pp->name,
+			  NIPQUAD(iph->saddr),
+			  NIPQUAD(iph->daddr));
+	}
+
+	return cp;
+}
+
+
+static struct ip_vs_conn *
+ah_esp_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
+		    const struct iphdr *iph, unsigned int proto_off, int inverse)
+{
+	struct ip_vs_conn *cp;
+
+	if (likely(!inverse)) {
+		cp = ip_vs_conn_out_get(IPPROTO_UDP,
+					iph->saddr,
+					htons(PORT_ISAKMP),
+					iph->daddr,
+					htons(PORT_ISAKMP));
+	} else {
+		cp = ip_vs_conn_out_get(IPPROTO_UDP,
+					iph->daddr,
+					htons(PORT_ISAKMP),
+					iph->saddr,
+					htons(PORT_ISAKMP));
+	}
+
+	if (!cp) {
+		IP_VS_DBG(12, "Unknown ISAKMP entry for inout packet "
+			  "%s%s %u.%u.%u.%u->%u.%u.%u.%u\n",
+			  inverse ? "ICMP+" : "",
+			  pp->name,
+			  NIPQUAD(iph->saddr),
+			  NIPQUAD(iph->daddr));
+	}
+
+	return cp;
+}
+
+
+static int
+ah_esp_conn_schedule(struct sk_buff *skb,
+		     struct ip_vs_protocol *pp,
+		     int *verdict, struct ip_vs_conn **cpp)
+{
+	/*
+	 * AH/ESP is only related traffic. Pass the packet to IP stack.
+	 */
+	*verdict = NF_ACCEPT;
+	return 0;
+}
+
+
+static void
+ah_esp_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
+		    int offset, const char *msg)
+{
+	char buf[256];
+	struct iphdr _iph, *ih;
+
+	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
+	if (ih == NULL)
+		sprintf(buf, "%s TRUNCATED", pp->name);
+	else
+		sprintf(buf, "%s %u.%u.%u.%u->%u.%u.%u.%u",
+			pp->name, NIPQUAD(ih->saddr),
+			NIPQUAD(ih->daddr));
+
+	printk(KERN_DEBUG "IPVS: %s: %s\n", msg, buf);
+}
+
+
+static void ah_esp_init(struct ip_vs_protocol *pp)
+{
+	/* nothing to do now */
+}
+
+
+static void ah_esp_exit(struct ip_vs_protocol *pp)
+{
+	/* nothing to do now */
+}
+
+
+#ifdef CONFIG_IP_VS_PROTO_AH
+struct ip_vs_protocol ip_vs_protocol_ah = {
+	.name =			"AH",
+	.protocol =		IPPROTO_AH,
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
+	.set_state_timeout =	NULL,
+};
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
diff --git a/net/ipv4/ipvs/ip_vs_proto_esp.c b/net/ipv4/ipvs/ip_vs_proto_esp.c
deleted file mode 100644
index 21d70c8..0000000
--- a/net/ipv4/ipvs/ip_vs_proto_esp.c
+++ /dev/null
@@ -1,176 +0,0 @@
-/*
- * ip_vs_proto_esp.c:	ESP IPSec load balancing support for IPVS
- *
- * Authors:	Julian Anastasov <ja@ssi.bg>, February 2002
- *		Wensong Zhang <wensong@linuxvirtualserver.org>
- *
- *		This program is free software; you can redistribute it and/or
- *		modify it under the terms of the GNU General Public License
- *		version 2 as published by the Free Software Foundation;
- *
- */
-
-#include <linux/in.h>
-#include <linux/ip.h>
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/netfilter.h>
-#include <linux/netfilter_ipv4.h>
-
-#include <net/ip_vs.h>
-
-
-/* TODO:
-
-struct isakmp_hdr {
-	__u8		icookie[8];
-	__u8		rcookie[8];
-	__u8		np;
-	__u8		version;
-	__u8		xchgtype;
-	__u8		flags;
-	__u32		msgid;
-	__u32		length;
-};
-
-*/
-
-#define PORT_ISAKMP	500
-
-
-static struct ip_vs_conn *
-esp_conn_in_get(const struct sk_buff *skb,
-		struct ip_vs_protocol *pp,
-		const struct iphdr *iph,
-		unsigned int proto_off,
-		int inverse)
-{
-	struct ip_vs_conn *cp;
-
-	if (likely(!inverse)) {
-		cp = ip_vs_conn_in_get(IPPROTO_UDP,
-				       iph->saddr,
-				       htons(PORT_ISAKMP),
-				       iph->daddr,
-				       htons(PORT_ISAKMP));
-	} else {
-		cp = ip_vs_conn_in_get(IPPROTO_UDP,
-				       iph->daddr,
-				       htons(PORT_ISAKMP),
-				       iph->saddr,
-				       htons(PORT_ISAKMP));
-	}
-
-	if (!cp) {
-		/*
-		 * We are not sure if the packet is from our
-		 * service, so our conn_schedule hook should return NF_ACCEPT
-		 */
-		IP_VS_DBG(12, "Unknown ISAKMP entry for outin packet "
-			  "%s%s %u.%u.%u.%u->%u.%u.%u.%u\n",
-			  inverse ? "ICMP+" : "",
-			  pp->name,
-			  NIPQUAD(iph->saddr),
-			  NIPQUAD(iph->daddr));
-	}
-
-	return cp;
-}
-
-
-static struct ip_vs_conn *
-esp_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
-		 const struct iphdr *iph, unsigned int proto_off, int inverse)
-{
-	struct ip_vs_conn *cp;
-
-	if (likely(!inverse)) {
-		cp = ip_vs_conn_out_get(IPPROTO_UDP,
-					iph->saddr,
-					htons(PORT_ISAKMP),
-					iph->daddr,
-					htons(PORT_ISAKMP));
-	} else {
-		cp = ip_vs_conn_out_get(IPPROTO_UDP,
-					iph->daddr,
-					htons(PORT_ISAKMP),
-					iph->saddr,
-					htons(PORT_ISAKMP));
-	}
-
-	if (!cp) {
-		IP_VS_DBG(12, "Unknown ISAKMP entry for inout packet "
-			  "%s%s %u.%u.%u.%u->%u.%u.%u.%u\n",
-			  inverse ? "ICMP+" : "",
-			  pp->name,
-			  NIPQUAD(iph->saddr),
-			  NIPQUAD(iph->daddr));
-	}
-
-	return cp;
-}
-
-
-static int
-esp_conn_schedule(struct sk_buff *skb, struct ip_vs_protocol *pp,
-		  int *verdict, struct ip_vs_conn **cpp)
-{
-	/*
-	 * ESP is only related traffic. Pass the packet to IP stack.
-	 */
-	*verdict = NF_ACCEPT;
-	return 0;
-}
-
-
-static void
-esp_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
-		 int offset, const char *msg)
-{
-	char buf[256];
-	struct iphdr _iph, *ih;
-
-	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
-	if (ih == NULL)
-		sprintf(buf, "%s TRUNCATED", pp->name);
-	else
-		sprintf(buf, "%s %u.%u.%u.%u->%u.%u.%u.%u",
-			pp->name, NIPQUAD(ih->saddr),
-			NIPQUAD(ih->daddr));
-
-	printk(KERN_DEBUG "IPVS: %s: %s\n", msg, buf);
-}
-
-
-static void esp_init(struct ip_vs_protocol *pp)
-{
-	/* nothing to do now */
-}
-
-
-static void esp_exit(struct ip_vs_protocol *pp)
-{
-	/* nothing to do now */
-}
-
-
-struct ip_vs_protocol ip_vs_protocol_esp = {
-	.name =			"ESP",
-	.protocol =		IPPROTO_ESP,
-	.num_states =		1,
-	.dont_defrag =		1,
-	.init =			esp_init,
-	.exit =			esp_exit,
-	.conn_schedule =	esp_conn_schedule,
-	.conn_in_get =		esp_conn_in_get,
-	.conn_out_get =		esp_conn_out_get,
-	.snat_handler =		NULL,
-	.dnat_handler =		NULL,
-	.csum_check =		NULL,
-	.state_transition =	NULL,
-	.register_app =		NULL,
-	.unregister_app =	NULL,
-	.app_conn_bind =	NULL,
-	.debug_packet =		esp_debug_packet,
-	.timeout_change =	NULL,		/* ISAKMP */
-};
-- 
1.5.4.5

