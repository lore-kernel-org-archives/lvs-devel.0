From: "Julius R. Volz" <juliusv@google.com>
Subject: [PATCH 17/26] IPVS: Add connection hashing function for IPv6 entries.
Date: Wed, 11 Jun 2008 19:12:00 +0200
Message-ID: <1213204329-10973-18-git-send-email-juliusv@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213204338; bh=ISYu+biW7ZcCBQICwryLRGwqEkI=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=OaD8qr9ONy1oCre9zFiQ99yJ09400l6hHA9Qc0eJ
	TaG5VPbdriqZm2p8FeD57jiN6ZWnKgsWtlKDPuHoJNRW9w==
In-Reply-To: <1213204329-10973-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com, "Julius R. Volz" <juliusv@google.com>

Add ip_vs_conn_hashkey_v6() and call it instead of ip_vs_conn_hashkey()
when hashing IPv6 connection entries.

Signed-off-by: Julius R. Volz <juliusv@google.com>

 1 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 1a4040d..4ee5dac 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -37,6 +37,9 @@
 
 #include <net/net_namespace.h>
 #include <net/ip_vs.h>
+#ifdef CONFIG_IP_VS_IPV6
+#include <net/ipv6.h>
+#endif
 
 
 /*
@@ -122,6 +125,13 @@ static unsigned int ip_vs_conn_hashkey(unsigned proto, __be32 addr, __be16 port)
 		& IP_VS_CONN_TAB_MASK;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static unsigned int ip_vs_conn_hashkey_v6(unsigned proto, const struct in6_addr *addr, __be16 port)
+{
+	return jhash_3words(jhash(addr, 16, ip_vs_conn_rnd), (__force u32)port, proto, ip_vs_conn_rnd)
+		& IP_VS_CONN_TAB_MASK;
+}
+#endif
 
 /*
  *	Hashes ip_vs_conn in ip_vs_conn_tab by proto,addr,port.
@@ -133,7 +143,12 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
 	int ret;
 
 	/* Hash by protocol, client address and port */
-	hash = ip_vs_conn_hashkey(cp->protocol, cp->caddr, cp->cport);
+#ifdef CONFIG_IP_VS_IPV6
+	if (cp->af == AF_INET6)
+		hash = ip_vs_conn_hashkey_v6(cp->protocol, &cp->caddr.v6, cp->cport);
+	else
+#endif
+		hash = ip_vs_conn_hashkey(cp->protocol, cp->caddr.v4, cp->cport);
 
 	ct_write_lock(hash);
 
@@ -164,7 +179,12 @@ static inline int ip_vs_conn_unhash(struct ip_vs_conn *cp)
 	int ret;
 
 	/* unhash it and decrease its reference counter */
-	hash = ip_vs_conn_hashkey(cp->protocol, cp->caddr, cp->cport);
+#ifdef CONFIG_IP_VS_IPV6
+	if (cp->af == AF_INET6)
+		hash = ip_vs_conn_hashkey_v6(cp->protocol, &cp->caddr.v6, cp->cport);
+	else
+#endif
+		hash = ip_vs_conn_hashkey(cp->protocol, cp->caddr.v4, cp->cport);
 
 	ct_write_lock(hash);
 
-- 
1.5.3.6

