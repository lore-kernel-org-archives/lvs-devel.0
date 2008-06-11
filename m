From: "Julius R. Volz" <juliusv@google.com>
Subject: [PATCH 06/26] IPVS: Add IPv6-specific function pointers to struct ip_vs_protocol.
Date: Wed, 11 Jun 2008 19:11:49 +0200
Message-ID: <1213204329-10973-7-git-send-email-juliusv@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213204337; bh=dRvhSRAtCELEA92qaiwMnA2jCkQ=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=pze2wwNu+YPdz8iEvuQv0mUm3M1ek9Wrd00cujVu
	RBvm0H8BSHbQLd2iN+pbLT10GQDgEDeXTlFPfwAGfAEXvg==
In-Reply-To: <1213204329-10973-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com, "Julius R. Volz" <juliusv@google.com>

Add some IPv6-specific handler function pointers to struct ip_vs_protocol.
These are needed for handlers that (may) have a different implementation
between protocol versions. Depending on the code path (processing either
v4 or v6 packets), the corresponding version of a handler will be called.

Signed-off-by: Julius R. Volz <juliusv@google.com>

 1 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 5c2d48d..9ae04d0 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -477,6 +477,12 @@ struct ip_vs_protocol {
 			     struct ip_vs_protocol *pp,
 			     int *verdict, struct ip_vs_conn **cpp);
 
+#ifdef CONFIG_IP_VS_IPV6
+	int (*conn_schedule_v6)(struct sk_buff *skb,
+			        struct ip_vs_protocol *pp,
+			        int *verdict, struct ip_vs_conn **cpp);
+#endif
+
 	struct ip_vs_conn *
 	(*conn_in_get)(const struct sk_buff *skb,
 		       struct ip_vs_protocol *pp,
@@ -491,13 +497,40 @@ struct ip_vs_protocol {
 			unsigned int proto_off,
 			int inverse);
 
+#ifdef CONFIG_IP_VS_IPV6
+	struct ip_vs_conn *
+	(*conn_in_get_v6)(const struct sk_buff *skb,
+		       struct ip_vs_protocol *pp,
+		       const struct ipv6hdr *iph,
+		       unsigned int proto_off,
+		       int inverse);
+
+	struct ip_vs_conn *
+	(*conn_out_get_v6)(const struct sk_buff *skb,
+			struct ip_vs_protocol *pp,
+			const struct ipv6hdr *iph,
+			unsigned int proto_off,
+			int inverse);
+#endif
+
 	int (*snat_handler)(struct sk_buff *skb,
 			    struct ip_vs_protocol *pp, struct ip_vs_conn *cp);
 
 	int (*dnat_handler)(struct sk_buff *skb,
 			    struct ip_vs_protocol *pp, struct ip_vs_conn *cp);
 
+#ifdef CONFIG_IP_VS_IPV6
+	int (*snat_handler_v6)(struct sk_buff *skb,
+			       struct ip_vs_protocol *pp, struct ip_vs_conn *cp);
+
+	int (*dnat_handler_v6)(struct sk_buff *skb,
+			       struct ip_vs_protocol *pp, struct ip_vs_conn *cp);
+#endif
+
 	int (*csum_check)(struct sk_buff *skb, struct ip_vs_protocol *pp);
+#ifdef CONFIG_IP_VS_IPV6
+	int (*csum_check_v6)(struct sk_buff *skb, struct ip_vs_protocol *pp);
+#endif
 
 	const char *(*state_name)(int state);
 
-- 
1.5.3.6

