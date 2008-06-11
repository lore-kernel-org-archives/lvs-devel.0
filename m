From: "Julius R. Volz" <juliusv@google.com>
Subject: [PATCH 22/26] IPVS: Add function to find out if IPv6 address is local.
Date: Wed, 11 Jun 2008 19:12:05 +0200
Message-ID: <1213204329-10973-23-git-send-email-juliusv@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213204337; bh=wvLkgWdvZsmau8bYYNk6ivVU2RE=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=UhalF5jMXGyPT34d5HRBOPL7dU+0x6BQO/55IziE
	a/GFXLsLqAUOFZdSXco2qmEbtsnbZLzscgRLgbaJXxcWng==
In-Reply-To: <1213204329-10973-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com

From: Vince Busam <vbusam@google.com>

Add __ip_vs_addr_is_local_v6() to find out if an IPv6 address belongs to a
local interface. This function is used to decide whether to set the
IP_VS_CONN_F_LOCALNODE flag for IPv6 destinations.

Signed-off-by: Vince Busam <vbusam@google.com>

 1 files changed, 30 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index da2e431..cf52034 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -92,6 +92,23 @@ int ip_vs_get_debug_level(void)
 }
 #endif
 
+#ifdef CONFIG_IP_VS_IPV6
+/* Taken from rt6_fill_node() in net/ipv6/route.c, is there a better way? */
+static int __ip_vs_addr_is_local_v6(const struct in6_addr *addr) {
+	struct rt6_info *rt;
+	struct flowi fl = {
+		.oif = 0,
+		.nl_u = {
+			.ip6_u = {
+				.daddr = *addr,
+				.saddr = { .s6_addr32 = {0, 0, 0, 0} }, } },
+	};
+	if ((rt = (struct rt6_info *)ip6_route_output(&init_net, NULL, &fl)))
+		if (rt->rt6i_dev && (rt->rt6i_dev->flags&IFF_LOOPBACK))
+			return 1;
+	return 0;
+}
+#endif
 /*
  *	update_defense_level is called from keventd and from sysctl,
  *	so it needs to protect itself from softirqs
@@ -708,9 +725,19 @@ __ip_vs_update_dest(struct ip_vs_service *svc,
 	conn_flags = udest->conn_flags | IP_VS_CONN_F_INACTIVE;
 
 	/* check if local node and update the flags */
-	if (inet_addr_type(&init_net, udest->addr) == RTN_LOCAL) {
-		conn_flags = (conn_flags & ~IP_VS_CONN_F_FWD_MASK)
-			| IP_VS_CONN_F_LOCALNODE;
+#ifdef CONFIG_IP_VS_IPV6
+	if (svc->af == AF_INET6) {
+		if (__ip_vs_addr_is_local_v6(&udest->addr.v6)) {
+			conn_flags = (conn_flags & ~IP_VS_CONN_F_FWD_MASK)
+				| IP_VS_CONN_F_LOCALNODE;
+		}
+	}
+#endif
+	if (svc->af == AF_INET) {
+		if (inet_addr_type(&init_net, udest->addr.v4) == RTN_LOCAL) {
+			conn_flags = (conn_flags & ~IP_VS_CONN_F_FWD_MASK)
+				| IP_VS_CONN_F_LOCALNODE;
+		}
 	}
 
 	/* set the IP_VS_CONN_F_NOOUTPUT flag if not masquerading/NAT */
-- 
1.5.3.6

