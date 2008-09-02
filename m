From: Julius Volz <juliusv@google.com>
Subject: [PATCHv3 21/24] IPVS: Add function to determine if IPv6 address is local
Date: Tue,  2 Sep 2008 15:55:52 +0200
Message-ID: <1220363755-9854-22-git-send-email-juliusv@google.com>
References: <1220363755-9854-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220363766; bh=9sRaxxLTw3HFPUTXdzOyuGDOrsA=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=syMSwSZ0eKCYZe1YVuE50sZnCnXu1eX9shUUZvug
	peqWMEbIe2e4/BVi/aWx6TtEZY+k/J69oUj8EHLdoxQ+vQ==
In-Reply-To: <1220363755-9854-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com

From: Vince Busam <vbusam@google.com>

Add __ip_vs_addr_is_local_v6() to find out if an IPv6 address belongs to a
local interface. Use this function to decide whether to set the
IP_VS_CONN_F_LOCALNODE flag for IPv6 destinations.

Signed-off-by: Vince Busam <vbusam@google.com>

 1 files changed, 49 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index 25d9e98..640203a 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -35,6 +35,10 @@
 
 #include <net/net_namespace.h>
 #include <net/ip.h>
+#ifdef CONFIG_IP_VS_IPV6
+#include <net/ipv6.h>
+#include <net/ip6_route.h>
+#endif
 #include <net/route.h>
 #include <net/sock.h>
 #include <net/genetlink.h>
@@ -91,6 +95,26 @@ int ip_vs_get_debug_level(void)
 }
 #endif
 
+#ifdef CONFIG_IP_VS_IPV6
+/* Taken from rt6_fill_node() in net/ipv6/route.c, is there a better way? */
+static int __ip_vs_addr_is_local_v6(const struct in6_addr *addr)
+{
+	struct rt6_info *rt;
+	struct flowi fl = {
+		.oif = 0,
+		.nl_u = {
+			.ip6_u = {
+				.daddr = *addr,
+				.saddr = { .s6_addr32 = {0, 0, 0, 0} }, } },
+	};
+
+	rt = (struct rt6_info *)ip6_route_output(&init_net, NULL, &fl);
+	if (rt && rt->rt6i_dev && (rt->rt6i_dev->flags & IFF_LOOPBACK))
+			return 1;
+
+	return 0;
+}
+#endif
 /*
  *	update_defense_level is called from keventd and from sysctl,
  *	so it needs to protect itself from softirqs
@@ -751,10 +775,18 @@ __ip_vs_update_dest(struct ip_vs_service *svc,
 	conn_flags = udest->conn_flags | IP_VS_CONN_F_INACTIVE;
 
 	/* check if local node and update the flags */
-	if (inet_addr_type(&init_net, udest->addr.ip) == RTN_LOCAL) {
-		conn_flags = (conn_flags & ~IP_VS_CONN_F_FWD_MASK)
-			| IP_VS_CONN_F_LOCALNODE;
-	}
+#ifdef CONFIG_IP_VS_IPV6
+	if (svc->af == AF_INET6) {
+		if (__ip_vs_addr_is_local_v6(&udest->addr.in6)) {
+			conn_flags = (conn_flags & ~IP_VS_CONN_F_FWD_MASK)
+				| IP_VS_CONN_F_LOCALNODE;
+		}
+	} else
+#endif
+		if (inet_addr_type(&init_net, udest->addr.ip) == RTN_LOCAL) {
+			conn_flags = (conn_flags & ~IP_VS_CONN_F_FWD_MASK)
+				| IP_VS_CONN_F_LOCALNODE;
+		}
 
 	/* set the IP_VS_CONN_F_NOOUTPUT flag if not masquerading/NAT */
 	if ((conn_flags & IP_VS_CONN_F_FWD_MASK) != 0) {
@@ -803,9 +835,19 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 
 	EnterFunction(2);
 
-	atype = inet_addr_type(&init_net, udest->addr.ip);
-	if (atype != RTN_LOCAL && atype != RTN_UNICAST)
-		return -EINVAL;
+#ifdef CONFIG_IP_VS_IPV6
+	if (svc->af == AF_INET6) {
+		atype = ipv6_addr_type(&udest->addr.in6);
+		if (!(atype & IPV6_ADDR_UNICAST) &&
+			!__ip_vs_addr_is_local_v6(&udest->addr.in6))
+			return -EINVAL;
+	} else
+#endif
+	{
+		atype = inet_addr_type(&init_net, udest->addr.ip);
+		if (atype != RTN_LOCAL && atype != RTN_UNICAST)
+			return -EINVAL;
+	}
 
 	dest = kzalloc(sizeof(struct ip_vs_dest), GFP_ATOMIC);
 	if (dest == NULL) {
-- 
1.5.4.5

