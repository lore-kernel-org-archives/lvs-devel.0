From: Hannes Eder <heder@google.com>
Subject: [PATCH v2 1/2] IPVS: use pr_fmt
Date: Tue, 28 Jul 2009 22:35:49 +0200
Message-ID: <20090728203539.7654.85832.stgit@jazzy.zrh.corp.google.com>
References: <20090728203414.7654.73236.stgit@jazzy.zrh.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1248813482; bh=6ZKt/sMFWyaBAdn3iFXC6MQEtTQ=;
	h=DomainKey-Signature:Subject:To:From:Cc:Date:Message-ID:
	 In-Reply-To:References:User-Agent:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:X-System-Of-Record; b=A/hDzVy/QxPMicHO6P
	+EvTC2ABJxH6Wb4yTAxZF3YWXPQQxi4INGIk//knxl/AwJRXXmLYRp9Wt/IhK+HyzY3
	g==
In-Reply-To: <20090728203414.7654.73236.stgit@jazzy.zrh.corp.google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org, Jan Engelhardt <jengelh@medozas.de>

While being at it cleanup whitespace.

Signed-off-by: Hannes Eder <heder@google.com>

 include/net/ip_vs.h                     |  119 ++++++++++++++++---------------
 net/netfilter/ipvs/ip_vs_app.c          |    3 +
 net/netfilter/ipvs/ip_vs_conn.c         |    3 +
 net/netfilter/ipvs/ip_vs_core.c         |    3 +
 net/netfilter/ipvs/ip_vs_ctl.c          |    3 +
 net/netfilter/ipvs/ip_vs_dh.c           |    3 +
 net/netfilter/ipvs/ip_vs_est.c          |    4 +
 net/netfilter/ipvs/ip_vs_ftp.c          |    3 +
 net/netfilter/ipvs/ip_vs_lblc.c         |    3 +
 net/netfilter/ipvs/ip_vs_lblcr.c        |    3 +
 net/netfilter/ipvs/ip_vs_lc.c           |    3 +
 net/netfilter/ipvs/ip_vs_nq.c           |    3 +
 net/netfilter/ipvs/ip_vs_proto.c        |    7 +-
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |    7 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |    3 +
 net/netfilter/ipvs/ip_vs_proto_udp.c    |    3 +
 net/netfilter/ipvs/ip_vs_rr.c           |    3 +
 net/netfilter/ipvs/ip_vs_sched.c        |    3 +
 net/netfilter/ipvs/ip_vs_sed.c          |    3 +
 net/netfilter/ipvs/ip_vs_sh.c           |    3 +
 net/netfilter/ipvs/ip_vs_sync.c         |    3 +
 net/netfilter/ipvs/ip_vs_wlc.c          |    3 +
 net/netfilter/ipvs/ip_vs_wrr.c          |    3 +
 net/netfilter/ipvs/ip_vs_xmit.c         |    3 +
 24 files changed, 134 insertions(+), 63 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index e01cc2d..b0bd782 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -99,47 +99,47 @@ static inline const char *ip_vs_dbg_addr(int af, char *buf, size_t buf_len,
 	return &buf[*idx - len];
 }
 
-#define IP_VS_DBG_BUF(level, msg...)			\
-    do {						\
-	    char ip_vs_dbg_buf[160];			\
-	    int ip_vs_dbg_idx = 0;			\
-	    if (level <= ip_vs_get_debug_level())	\
-		    printk(KERN_DEBUG "IPVS: " msg);	\
-    } while (0)
-#define IP_VS_ERR_BUF(msg...)				\
-    do {						\
-	    char ip_vs_dbg_buf[160];			\
-	    int ip_vs_dbg_idx = 0;			\
-	    printk(KERN_ERR "IPVS: " msg);		\
-    } while (0)
+#define IP_VS_DBG_BUF(level, msg, ...)					\
+	do {								\
+		char ip_vs_dbg_buf[160];				\
+		int ip_vs_dbg_idx = 0;					\
+		if (level <= ip_vs_get_debug_level())			\
+			printk(KERN_DEBUG pr_fmt(msg), ##__VA_ARGS__);	\
+	} while (0)
+#define IP_VS_ERR_BUF(msg...)						\
+	do {								\
+		char ip_vs_dbg_buf[160];				\
+		int ip_vs_dbg_idx = 0;					\
+		pr_err(msg);						\
+	} while (0)
 
 /* Only use from within IP_VS_DBG_BUF() or IP_VS_ERR_BUF macros */
-#define IP_VS_DBG_ADDR(af, addr)			\
-    ip_vs_dbg_addr(af, ip_vs_dbg_buf,			\
-		   sizeof(ip_vs_dbg_buf), addr,		\
-		   &ip_vs_dbg_idx)
-
-#define IP_VS_DBG(level, msg...)			\
-    do {						\
-	    if (level <= ip_vs_get_debug_level())	\
-		    printk(KERN_DEBUG "IPVS: " msg);	\
-    } while (0)
-#define IP_VS_DBG_RL(msg...)				\
-    do {						\
-	    if (net_ratelimit())			\
-		    printk(KERN_DEBUG "IPVS: " msg);	\
-    } while (0)
-#define IP_VS_DBG_PKT(level, pp, skb, ofs, msg)		\
-    do {						\
-	    if (level <= ip_vs_get_debug_level())	\
-		pp->debug_packet(pp, skb, ofs, msg);	\
-    } while (0)
-#define IP_VS_DBG_RL_PKT(level, pp, skb, ofs, msg)	\
-    do {						\
-	    if (level <= ip_vs_get_debug_level() &&	\
-		net_ratelimit())			\
-		pp->debug_packet(pp, skb, ofs, msg);	\
-    } while (0)
+#define IP_VS_DBG_ADDR(af, addr)					\
+	ip_vs_dbg_addr(af, ip_vs_dbg_buf,				\
+		       sizeof(ip_vs_dbg_buf), addr,			\
+		       &ip_vs_dbg_idx)
+
+#define IP_VS_DBG(level, msg, ...)					\
+	do {								\
+		if (level <= ip_vs_get_debug_level())			\
+			printk(KERN_DEBUG pr_fmt(msg), ##__VA_ARGS__);	\
+	} while (0)
+#define IP_VS_DBG_RL(msg, ...)						\
+	do {								\
+		if (net_ratelimit())					\
+			printk(KERN_DEBUG pr_fmt(msg), ##__VA_ARGS__);	\
+	} while (0)
+#define IP_VS_DBG_PKT(level, pp, skb, ofs, msg)				\
+	do {								\
+		if (level <= ip_vs_get_debug_level())			\
+			pp->debug_packet(pp, skb, ofs, msg);		\
+	} while (0)
+#define IP_VS_DBG_RL_PKT(level, pp, skb, ofs, msg)			\
+	do {								\
+		if (level <= ip_vs_get_debug_level() &&			\
+		    net_ratelimit())					\
+			pp->debug_packet(pp, skb, ofs, msg);		\
+	} while (0)
 #else	/* NO DEBUGGING at ALL */
 #define IP_VS_DBG_BUF(level, msg...)  do {} while (0)
 #define IP_VS_ERR_BUF(msg...)  do {} while (0)
@@ -150,29 +150,30 @@ static inline const char *ip_vs_dbg_addr(int af, char *buf, size_t buf_len,
 #endif
 
 #define IP_VS_BUG() BUG()
-#define IP_VS_ERR(msg...) printk(KERN_ERR "IPVS: " msg)
-#define IP_VS_INFO(msg...) printk(KERN_INFO "IPVS: " msg)
-#define IP_VS_WARNING(msg...) \
-	printk(KERN_WARNING "IPVS: " msg)
-#define IP_VS_ERR_RL(msg...)				\
-    do {						\
-	    if (net_ratelimit())			\
-		    printk(KERN_ERR "IPVS: " msg);	\
-    } while (0)
+#define IP_VS_ERR(msg...) pr_err(msg)
+#define IP_VS_INFO(msg...) pr_info(msg)
+#define IP_VS_WARNING(msg...) pr_warning(msg)
+#define IP_VS_ERR_RL(msg...)						\
+	do {								\
+		if (net_ratelimit())					\
+			pr_err(msg);					\
+	} while (0)
 
 #ifdef CONFIG_IP_VS_DEBUG
 #define EnterFunction(level)						\
-    do {								\
-	    if (level <= ip_vs_get_debug_level())			\
-		    printk(KERN_DEBUG "Enter: %s, %s line %i\n",	\
-			   __func__, __FILE__, __LINE__);		\
-    } while (0)
-#define LeaveFunction(level)                                            \
-    do {                                                                \
-	    if (level <= ip_vs_get_debug_level())                       \
-			printk(KERN_DEBUG "Leave: %s, %s line %i\n",    \
-			       __func__, __FILE__, __LINE__);       \
-    } while (0)
+	do {								\
+		if (level <= ip_vs_get_debug_level())			\
+			printk(KERN_DEBUG				\
+			       pr_fmt("Enter: %s, %s line %i\n"),	\
+			       __func__, __FILE__, __LINE__);		\
+	} while (0)
+#define LeaveFunction(level)						\
+	do {								\
+		if (level <= ip_vs_get_debug_level())			\
+			printk(KERN_DEBUG				\
+			       pr_fmt("Leave: %s, %s line %i\n"),	\
+			       __func__, __FILE__, __LINE__);		\
+	} while (0)
 #else
 #define EnterFunction(level)   do {} while (0)
 #define LeaveFunction(level)   do {} while (0)
diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index 201b8ea..c1781f8 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -18,6 +18,9 @@
  *
  */
 
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/skbuff.h>
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 928af1c..e613745 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -22,6 +22,9 @@
  *
  */
 
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
 #include <linux/interrupt.h>
 #include <linux/in.h>
 #include <linux/net.h>
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 8dddb17..6811dca 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -24,6 +24,9 @@
  *
  */
 
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/ip.h>
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index beaf129..83a7ab6 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -18,6 +18,9 @@
  *
  */
 
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/types.h>
diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index a9dac74..d0c0594 100644
--- a/net/netfilter/ipvs/ip_vs_dh.c
+++ b/net/netfilter/ipvs/ip_vs_dh.c
@@ -35,6 +35,9 @@
  *
  */
 
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
 #include <linux/ip.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 2eb2860..702b53c 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -11,6 +11,10 @@
  * Changes:
  *
  */
+
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/jiffies.h>
 #include <linux/slab.h>
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 428edbf..9c16a3f 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -22,6 +22,9 @@
  *
  */
 
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/kernel.h>
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 537a7a1..66f625b 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -39,6 +39,9 @@
  * me to write this module.
  */
 
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
 #include <linux/ip.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index c8f8687..63cca2b 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -37,6 +37,9 @@
  *
  */
 
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
 #include <linux/ip.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
diff --git a/net/netfilter/ipvs/ip_vs_lc.c b/net/netfilter/ipvs/ip_vs_lc.c
index d0dadc8..4ecd5e1 100644
--- a/net/netfilter/ipvs/ip_vs_lc.c
+++ b/net/netfilter/ipvs/ip_vs_lc.c
@@ -14,6 +14,9 @@
  *
  */
 
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 
diff --git a/net/netfilter/ipvs/ip_vs_nq.c b/net/netfilter/ipvs/ip_vs_nq.c
index 694952d..2224478 100644
--- a/net/netfilter/ipvs/ip_vs_nq.c
+++ b/net/netfilter/ipvs/ip_vs_nq.c
@@ -31,6 +31,9 @@
  *
  */
 
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index a01520e..a95bc40 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -13,6 +13,9 @@
  *
  */
 
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/skbuff.h>
@@ -181,7 +184,7 @@ ip_vs_tcpudp_debug_packet_v4(struct ip_vs_protocol *pp,
 				&ih->daddr, ntohs(pptr[1]));
 	}
 
-	printk(KERN_DEBUG "IPVS: %s: %s\n", msg, buf);
+	pr_debug("%s: %s\n", msg, buf);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -215,7 +218,7 @@ ip_vs_tcpudp_debug_packet_v6(struct ip_vs_protocol *pp,
 				&ih->daddr, ntohs(pptr[1]));
 	}
 
-	printk(KERN_DEBUG "IPVS: %s: %s\n", msg, buf);
+	pr_debug("%s: %s\n", msg, buf);
 }
 #endif
 
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
index 79f56c1..c30b43c 100644
--- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
@@ -10,6 +10,9 @@
  *
  */
 
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/module.h>
@@ -138,7 +141,7 @@ ah_esp_debug_packet_v4(struct ip_vs_protocol *pp, const struct sk_buff *skb,
 		sprintf(buf, "%s %pI4->%pI4",
 			pp->name, &ih->saddr, &ih->daddr);
 
-	printk(KERN_DEBUG "IPVS: %s: %s\n", msg, buf);
+	pr_debug("%s: %s\n", msg, buf);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -156,7 +159,7 @@ ah_esp_debug_packet_v6(struct ip_vs_protocol *pp, const struct sk_buff *skb,
 		sprintf(buf, "%s %pI6->%pI6",
 			pp->name, &ih->saddr, &ih->daddr);
 
-	printk(KERN_DEBUG "IPVS: %s: %s\n", msg, buf);
+	pr_debug("%s: %s\n", msg, buf);
 }
 #endif
 
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 8cba418..c36c80d 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -13,6 +13,9 @@
  *
  */
 
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/ip.h>
 #include <linux/tcp.h>                  /* for tcphdr */
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index d2930a7..96ebe40 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -13,6 +13,9 @@
  *
  */
 
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/kernel.h>
diff --git a/net/netfilter/ipvs/ip_vs_rr.c b/net/netfilter/ipvs/ip_vs_rr.c
index 2d16ab7..b01007e 100644
--- a/net/netfilter/ipvs/ip_vs_rr.c
+++ b/net/netfilter/ipvs/ip_vs_rr.c
@@ -19,6 +19,9 @@
  *
  */
 
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 
diff --git a/net/netfilter/ipvs/ip_vs_sched.c b/net/netfilter/ipvs/ip_vs_sched.c
index a46ad9e..87bc5ea 100644
--- a/net/netfilter/ipvs/ip_vs_sched.c
+++ b/net/netfilter/ipvs/ip_vs_sched.c
@@ -17,6 +17,9 @@
  *
  */
 
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
 #include <linux/module.h>
 #include <linux/spinlock.h>
 #include <linux/interrupt.h>
diff --git a/net/netfilter/ipvs/ip_vs_sed.c b/net/netfilter/ipvs/ip_vs_sed.c
index 20e4657..4f745dd 100644
--- a/net/netfilter/ipvs/ip_vs_sed.c
+++ b/net/netfilter/ipvs/ip_vs_sed.c
@@ -35,6 +35,9 @@
  *
  */
 
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index 75709eb..fb4d2d2 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -32,6 +32,9 @@
  *
  */
 
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
 #include <linux/ip.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 5c48378..cc04c99 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -17,6 +17,9 @@
  *	Justin Ossevoort	:	Fix endian problem on sync message size.
  */
 
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
 #include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/inetdevice.h>
diff --git a/net/netfilter/ipvs/ip_vs_wlc.c b/net/netfilter/ipvs/ip_vs_wlc.c
index 8e94256..bbddfdb 100644
--- a/net/netfilter/ipvs/ip_vs_wlc.c
+++ b/net/netfilter/ipvs/ip_vs_wlc.c
@@ -19,6 +19,9 @@
  *
  */
 
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 
diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wrr.c
index f7d74ef..c39ebb6 100644
--- a/net/netfilter/ipvs/ip_vs_wrr.c
+++ b/net/netfilter/ipvs/ip_vs_wrr.c
@@ -18,6 +18,9 @@
  *
  */
 
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/net.h>
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 425ab14..e5e0025 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -13,6 +13,9 @@
  *
  */
 
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/tcp.h>                  /* for tcphdr */
 #include <net/ip.h>

