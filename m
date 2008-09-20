From: Sven Wegener <sven.wegener@stealer.net>
Subject: [PATCH] ipvs: Fix unused label warning
Date: Sat, 20 Sep 2008 11:48:33 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.0809201142570.22510@titan.stealer.net>
References: <20080916071318.939200044@vergenet.net> <20080916071610.390873215@vergenet.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080916071610.390873215@vergenet.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Julius Volz <juliusv@google.com>, Vince Busam <vbusam@google.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 net/ipv4/ipvs/ip_vs_ctl.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

Simon, small fixup patch for your patch. It wasn't obvious from the patch, 
that now only the IPV6 support needs this label.

diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index 771551d..0302cf3 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -1330,7 +1330,9 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
 
   out_unlock:
 	write_unlock_bh(&__ip_vs_svc_lock);
+#ifdef CONFIG_IP_VS_IPV6
   out:
+#endif
 
 	if (old_sched)
 		ip_vs_scheduler_put(old_sched);
