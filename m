From: Julius Volz <juliusv@google.com>
Subject: [PATCHv2 RFC 04/25] IPVS: Add debug macros for v4 and v6 address output
Date: Mon,  1 Sep 2008 14:56:01 +0200
Message-ID: <1220273782-19901-5-git-send-email-juliusv@google.com>
References: <1220273782-19901-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220273820; bh=XXdb0GpoEFbMISHII9nzNpud000=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=vJ4dduQdC9flXwOX5E/Tg8I+ldt7a/MaR3rFRTG3
	vwmlAhYW9uP8HFrnQPWlf9ue46nN1aOKmtHa0s+zFkKjuA==
In-Reply-To: <1220273782-19901-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Add some debugging macros that allow conditional output of either v4 or v6
addresses, depending on an 'af' parameter. This is done by creating a
temporary string buffer in an outer debug macro and writing addresses'
string representations into it from another macro which can only be used
when inside the outer one.

Signed-off-by: Julius Volz <juliusv@google.com>

 1 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 6d9a360..45a7458 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -78,6 +78,46 @@ static inline int ip_vs_addr_equal(int af, const union nf_inet_addr *a,
 #include <linux/net.h>
 
 extern int ip_vs_get_debug_level(void);
+
+static inline const char *ip_vs_dbg_addr(int af, char *buf, size_t buf_len,
+					 const union nf_inet_addr *addr,
+					 int *idx)
+{
+	int len;
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6)
+		len = snprintf(&buf[*idx], buf_len - *idx, "[" NIP6_FMT "]",
+			       NIP6(addr->in6)) + 1;
+	else
+#endif
+		len = snprintf(&buf[*idx], buf_len - *idx, NIPQUAD_FMT,
+			       NIPQUAD(addr->ip)) + 1;
+
+	*idx += len;
+	BUG_ON(*idx > buf_len + 1);
+	return &buf[*idx - len];
+}
+
+#define IP_VS_DBG_BUF(level, msg...)			\
+    do {						\
+	    char ip_vs_dbg_buf[160];			\
+	    int ip_vs_dbg_idx = 0;			\
+	    if (level <= ip_vs_get_debug_level())	\
+		    printk(KERN_DEBUG "IPVS: " msg);	\
+    } while (0)
+#define IP_VS_ERR_BUF(msg...)				\
+    do {						\
+	    char ip_vs_dbg_buf[160];			\
+	    int ip_vs_dbg_idx = 0;			\
+	    printk(KERN_ERR "IPVS: " msg);		\
+    } while (0)
+
+/* Only use from within IP_VS_DBG_BUF() or IP_VS_ERR_BUF macros */
+#define IP_VS_DBG_ADDR(af, addr)			\
+    ip_vs_dbg_addr(af, ip_vs_dbg_buf,			\
+		   sizeof(ip_vs_dbg_buf), addr,		\
+		   &ip_vs_dbg_idx)
+
 #define IP_VS_DBG(level, msg...)			\
     do {						\
 	    if (level <= ip_vs_get_debug_level())	\
@@ -100,6 +140,8 @@ extern int ip_vs_get_debug_level(void);
 		pp->debug_packet(pp, skb, ofs, msg);	\
     } while (0)
 #else	/* NO DEBUGGING at ALL */
+#define IP_VS_DBG_BUF(level, msg...)  do {} while (0)
+#define IP_VS_ERR_BUF(msg...)  do {} while (0)
 #define IP_VS_DBG(level, msg...)  do {} while (0)
 #define IP_VS_DBG_RL(msg...)  do {} while (0)
 #define IP_VS_DBG_PKT(level, pp, skb, ofs, msg)		do {} while (0)
-- 
1.5.4.5

