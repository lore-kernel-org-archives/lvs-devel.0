From: Sven Wegener <sven.wegener@stealer.net>
Subject: [PATCH] ipvs: Return negative error values from
 ip_vs_edit_service()
Date: Fri, 5 Sep 2008 13:47:37 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.0809051346240.18192@titan.stealer.net>
References: <1220363755-9854-1-git-send-email-juliusv@google.com> <1220363755-9854-25-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1220363755-9854-25-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Like the other code in this function does.

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 net/ipv4/ipvs/ip_vs_ctl.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

Simon, please apply onto lvs-next-2.6.

diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index 7f89c58..d2dc05a 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -1284,11 +1284,11 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
 #ifdef CONFIG_IP_VS_IPV6
 	if (u->af == AF_INET6) {
 		if (!sched->supports_ipv6) {
-			ret = EAFNOSUPPORT;
+			ret = -EAFNOSUPPORT;
 			goto out;
 		}
 		if ((u->netmask < 1) || (u->netmask > 128)) {
-			ret = EINVAL;
+			ret = -EINVAL;
 			goto out;
 		}
 	}
