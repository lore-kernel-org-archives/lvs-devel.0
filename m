From: "Julius R. Volz" <juliusv@google.com>
Subject: [PATCH 23/26] IPVS: Add hash functions for IPv6 services and real servers.
Date: Wed, 11 Jun 2008 19:12:06 +0200
Message-ID: <1213204329-10973-24-git-send-email-juliusv@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213204337; bh=Ji/0n1fh9/+tnVXCpVNtMczASiI=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=cVVA6GP9rnCiIkehwktFjO5Sb82BKnF0ysbceWCq
	WPl2KU3/1RNGPHpPv7cdG82MBycpJF2CP6FFEvwg8qY72A==
In-Reply-To: <1213204329-10973-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com, "Julius R. Volz" <juliusv@google.com>

Add hashing functions ip_vs_svc_hashkey_v6() for hashing IPv6 service
entries and ip_vs_rs_hashkey_v6() for hashing real servers.

Signed-off-by: Julius R. Volz <juliusv@google.com>

 1 files changed, 46 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index cf52034..ca198b9 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -37,6 +37,10 @@
 
 #include <net/net_namespace.h>
 #include <net/ip.h>
+#ifdef CONFIG_IP_VS_IPV6
+#include <net/ipv6.h>
+#include <net/ip6_route.h>
+#endif
 #include <net/route.h>
 #include <net/sock.h>
 
@@ -308,6 +312,20 @@ ip_vs_svc_hashkey(unsigned proto, __be32 addr, __be16 port)
 		& IP_VS_SVC_TAB_MASK;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static __inline__ unsigned
+ip_vs_svc_hashkey_v6(unsigned proto, const struct in6_addr *addr, __be16 port)
+{
+	register unsigned porth = ntohs(port);
+
+	/* TODO IPv6: is this a good way to hash IPv6 entries? */
+	int addr_fold = addr->s6_addr32[0]^addr->s6_addr32[1]^
+			addr->s6_addr32[2]^addr->s6_addr32[3];
+	return (proto^ntohl(addr_fold)^(porth>>IP_VS_SVC_TAB_BITS)^porth)
+		& IP_VS_SVC_TAB_MASK;
+}
+#endif
+
 /*
  *	Returns hash value of fwmark for virtual service lookup
  */
@@ -335,7 +353,13 @@ static int ip_vs_svc_hash(struct ip_vs_service *svc)
 		/*
 		 *  Hash it by <protocol,addr,port> in ip_vs_svc_table
 		 */
-		hash = ip_vs_svc_hashkey(svc->protocol, svc->addr, svc->port);
+#ifdef CONFIG_IP_VS_IPV6
+		hash = (svc->af == AF_INET)
+			? ip_vs_svc_hashkey(svc->protocol, svc->addr.v4, svc->port)
+			: ip_vs_svc_hashkey_v6(svc->protocol, &svc->addr.v6, svc->port);
+#else
+		hash = ip_vs_svc_hashkey(svc->protocol, svc->addr.v4, svc->port);
+#endif
 		list_add(&svc->s_list, &ip_vs_svc_table[hash]);
 	} else {
 		/*
@@ -506,6 +530,20 @@ static __inline__ unsigned ip_vs_rs_hashkey(__be32 addr, __be16 port)
 		& IP_VS_RTAB_MASK;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static __inline__ unsigned ip_vs_rs_hashkey_v6(const struct in6_addr *addr,
+					       __be16 port)
+{
+	register unsigned porth = ntohs(port);
+
+	/* TODO IPv6: is this a good way to hash IPv6 entries? */
+	int addr_fold = addr->s6_addr32[0]^addr->s6_addr32[1]^
+			addr->s6_addr32[2]^addr->s6_addr32[3];
+	return (ntohl(addr_fold)^(porth>>IP_VS_RTAB_BITS)^porth)
+		& IP_VS_RTAB_MASK;
+}
+#endif
+
 /*
  *	Hashes ip_vs_dest in ip_vs_rtable by <proto,addr,port>.
  *	should be called with locked tables.
@@ -522,7 +560,13 @@ static int ip_vs_rs_hash(struct ip_vs_dest *dest)
 	 *	Hash by proto,addr,port,
 	 *	which are the parameters of the real service.
 	 */
-	hash = ip_vs_rs_hashkey(dest->addr, dest->port);
+#ifdef CONFIG_IP_VS_IPV6
+	if (dest->af == AF_INET6)
+		hash = ip_vs_rs_hashkey_v6(&dest->addr.v6, dest->port);
+	else
+#endif
+		hash = ip_vs_rs_hashkey(dest->addr.v4, dest->port);
+
 	list_add(&dest->d_list, &ip_vs_rtable[hash]);
 
 	return 1;
-- 
1.5.3.6

