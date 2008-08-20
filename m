From: Julius Volz <juliusv@google.com>
Subject: [PATCH RFC 13/24] IPVS: Add IPv6 support to ip_vs_conn_hashkey()
Date: Wed, 20 Aug 2008 18:15:20 +0200
Message-ID: <1219248931-15064-14-git-send-email-juliusv@google.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219248943; bh=AtzxAilRFczfoocDm7Zf73aJe2E=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=YMdcEiIGTtVW7+NZRWdF6K1a0WLTdvDjNKEoPJ8n
	th8jve9+Fx1I5DMU4Lly0LLxj84l3+2pry/mIPc8nBMn3Q==
In-Reply-To: <1219248931-15064-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Add IPv6 support to ip_vs_conn_hashkey() by adding an 'af' argument and
update callers.

Signed-off-by: Julius Volz <juliusv@google.com>

 1 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
index 1a6b9d8..5e013c9 100644
--- a/net/ipv4/ipvs/ip_vs_conn.c
+++ b/net/ipv4/ipvs/ip_vs_conn.c
@@ -114,13 +114,21 @@ static inline void ct_write_unlock_bh(unsigned key)
 /*
  *	Returns hash value for IPVS connection entry
  */
-static unsigned int ip_vs_conn_hashkey(unsigned proto, __be32 addr, __be16 port)
+static unsigned int ip_vs_conn_hashkey(int af, unsigned proto,
+				       const union nf_inet_addr *addr,
+				       __be16 port)
 {
-	return jhash_3words((__force u32)addr, (__force u32)port, proto, ip_vs_conn_rnd)
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6)
+		return jhash_3words(jhash(addr, 16, ip_vs_conn_rnd),
+				    (__force u32)port, proto, ip_vs_conn_rnd)
+			& IP_VS_CONN_TAB_MASK;
+#endif
+	return jhash_3words((__force u32)addr->ip, (__force u32)port, proto,
+			    ip_vs_conn_rnd)
 		& IP_VS_CONN_TAB_MASK;
 }
 
