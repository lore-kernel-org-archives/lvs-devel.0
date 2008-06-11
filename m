From: "Julius R. Volz" <juliusv@google.com>
Subject: [PATCH 04/26] IPVS: Add address family specific debugging macros.
Date: Wed, 11 Jun 2008 19:11:47 +0200
Message-ID: <1213204329-10973-5-git-send-email-juliusv@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213204335; bh=g/fUFHXgw2bkkazTIb/yYyiHclQ=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=xnkeXeVOEmISvww1qZn2FfefZtku4r1k5pv9wro5
	8opQOuIIosrOrkNkQyGWqTRUY8S0Touhozlyw+5RyF9wlg==
In-Reply-To: <1213204329-10973-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com, "Julius R. Volz" <juliusv@google.com>

Define debugging/error logging macros that only do something for a
specific address family. Avoids ugly conditionals in code using these
debugging macros.

Signed-off-by: Julius R. Volz <juliusv@google.com>

 1 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index b7b181e..349a746 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -287,6 +287,24 @@ struct ip_vs_daemon_user {
 #include <linux/net.h>
 
 extern int ip_vs_get_debug_level(void);
+#define IP_VS_DBG_V4(af, level, msg...)			\
+    do {						\
+	    if (af == AF_INET				\
+		&& level <= ip_vs_get_debug_level())	\
+		    printk(KERN_DEBUG "IPVS: " msg);	\
+    } while (0)
+
+#ifdef CONFIG_IP_VS_IPV6
+#define IP_VS_DBG_V6(af, level, msg...)			\
+    do {						\
+	    if (af == AF_INET6				\
+		&& level <= ip_vs_get_debug_level())	\
+		    printk(KERN_DEBUG "IPVS: " msg);	\
+    } while (0)
+#else
+#define IP_VS_DBG_V6(af, level, msg...)	do {} while (0)
+#endif
+
 #define IP_VS_DBG(level, msg...)			\
     do {						\
 	    if (level <= ip_vs_get_debug_level())	\
@@ -309,6 +327,8 @@ extern int ip_vs_get_debug_level(void);
 		pp->debug_packet(pp, skb, ofs, msg);	\
     } while (0)
 #else	/* NO DEBUGGING at ALL */
+#define IP_VS_DBG_V4(af, level, msg...)  do {} while (0)
+#define IP_VS_DBG_V6(af, level, msg...)  do {} while (0)
 #define IP_VS_DBG(level, msg...)  do {} while (0)
 #define IP_VS_DBG_RL(msg...)  do {} while (0)
 #define IP_VS_DBG_PKT(level, pp, skb, ofs, msg)		do {} while (0)
@@ -316,6 +336,20 @@ extern int ip_vs_get_debug_level(void);
 #endif
 
 #define IP_VS_BUG() BUG()
+#define IP_VS_ERR_V4(af, msg...)			\
+    do {						\
+	    if (af == AF_INET)				\
+	        printk(KERN_ERR "IPVS: " msg);		\
+    } while (0)
+#ifdef CONFIG_IP_VS_IPV6
+#define IP_VS_ERR_V6(af, msg...)			\
+do {							\
+	    if (af == AF_INET6)				\
+	        printk(KERN_ERR "IPVS: " msg);		\
+    } while (0)
+#else
+#define IP_VS_ERR_V6(af, msg...) do {} while (0)
+#endif
 #define IP_VS_ERR(msg...) printk(KERN_ERR "IPVS: " msg)
 #define IP_VS_INFO(msg...) printk(KERN_INFO "IPVS: " msg)
 #define IP_VS_WARNING(msg...) \
-- 
1.5.3.6

