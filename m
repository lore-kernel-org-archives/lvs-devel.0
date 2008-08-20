From: Julius Volz <juliusv@google.com>
Subject: [PATCH RFC 05/24] IPVS: Add general v4/v6 helper functions / data structures
Date: Wed, 20 Aug 2008 18:15:12 +0200
Message-ID: <1219248931-15064-6-git-send-email-juliusv@google.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219248942; bh=OKr/ElkUaLEOaoUl4XSb3tVW1EU=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=FXOR9nU04Qon55bz6ZIlCYbyUtS5ZMBPoUaV29yk
	anlDOR5msDGeh7cCPz5LWGM6wE9hfgVsqY2G5sUYAqEteA==
In-Reply-To: <1219248931-15064-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Add a struct ip_vs_iphdr for easier handling of common v4 and v6 header
fields in the same code path. ip_vs_fill_iphdr() helps to fill this struct
from an IPv4 or IPv6 header. Add further helper functions for copying and
comparing addresses.

Signed-off-by: Julius Volz <juliusv@google.com>

 1 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index e41a164..016af19 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -25,6 +25,56 @@
 #include <linux/ipv6.h>			/* for struct ipv6hdr */
 #include <net/ipv6.h>			/* for ipv6_addr_copy */
 
+struct ip_vs_iphdr {
+	int len;
+	__u8 protocol;
+	union nf_inet_addr saddr;
+	union nf_inet_addr daddr;
+};
+
+static inline void
+ip_vs_fill_iphdr(int af, const void *nh, struct ip_vs_iphdr *iphdr)
+{
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6) {
+		const struct ipv6hdr *iph = nh;
+		iphdr->len = sizeof(struct ipv6hdr);
+		iphdr->protocol = iph->nexthdr;
+		ipv6_addr_copy(&iphdr->saddr.in6, &iph->saddr);
+		ipv6_addr_copy(&iphdr->daddr.in6, &iph->daddr);
+	} else
+#endif
+	{
+		const struct iphdr *iph = nh;
+		iphdr->len = iph->ihl * 4;
+		iphdr->protocol = iph->protocol;
+		iphdr->saddr.ip = iph->saddr;
+		iphdr->daddr.ip = iph->daddr;
+	}
+}
+
+static inline void ip_vs_addr_copy(int af, union nf_inet_addr *dst,
+				  const union nf_inet_addr *src)
+{
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6)
+		ipv6_addr_copy(&dst->in6, &src->in6);
+	else
+#endif
+	dst->ip = src->ip;
+}
+
+static inline int ip_vs_addr_equal(int af, const union nf_inet_addr *a,
+				   const union nf_inet_addr *b)
+{
+#ifdef CONFIG_IP_VS_IPV6
+	return (af == AF_INET) ? (a->ip == b->ip)
+			       : ipv6_addr_equal(&a->in6, &b->in6);
+#else
+	return a->ip == b->ip;
+#endif
+}
+
 #ifdef CONFIG_IP_VS_DEBUG
 #include <linux/net.h>
 
-- 
1.5.4.5

