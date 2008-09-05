From: Sven Wegener <sven.wegener@stealer.net>
Subject: [PATCH] ipvs: Reject ipv6 link-local addresses for destinations
Date: Fri, 5 Sep 2008 16:53:49 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.0809051638480.18192@titan.stealer.net>
References: <1220363755-9854-1-git-send-email-juliusv@google.com> <1220363755-9854-22-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1220363755-9854-22-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

We can't use non-local link-local addresses for destinations, without
knowing the interface on which we can reach the address. Reject them for
now.

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 net/ipv4/ipvs/ip_vs_ctl.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index d2dc05a..e53efe4 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -838,7 +838,8 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 #ifdef CONFIG_IP_VS_IPV6
 	if (svc->af == AF_INET6) {
 		atype = ipv6_addr_type(&udest->addr.in6);
-		if (!(atype & IPV6_ADDR_UNICAST) &&
+		if ((!(atype & IPV6_ADDR_UNICAST) ||
+			atype & IPV6_ADDR_LINKLOCAL) &&
 			!__ip_vs_addr_is_local_v6(&udest->addr.in6))
 			return -EINVAL;
 	} else
