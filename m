From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipvs: use pkts for SCTP too
Date: Thu, 2 Sep 2010 02:47:26 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.1009020242060.14271@u.domain.uli>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org


	Use correctly the in_pkts packet counter also for SCTP

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

	This patch is for net-next

--- v2.6.36-rc2/linux/net/netfilter/ipvs/ip_vs_core.c	2010-09-01 23:47:47.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_core.c	2010-09-01 23:55:30.000000000 +0300
@@ -1380,8 +1380,7 @@ ip_vs_in(unsigned int hooknum, struct sk
 	if (af == AF_INET && (ip_vs_sync_state & IP_VS_STATE_MASTER) &&
 	    cp->protocol == IPPROTO_SCTP) {
 		if ((cp->state == IP_VS_SCTP_S_ESTABLISHED &&
-			(atomic_read(&cp->in_pkts) %
-			 sysctl_ip_vs_sync_threshold[1]
+			(pkts % sysctl_ip_vs_sync_threshold[1]
 			 == sysctl_ip_vs_sync_threshold[0])) ||
 				(cp->old_state != cp->state &&
 				 ((cp->state == IP_VS_SCTP_S_CLOSED) ||
@@ -1391,7 +1390,8 @@ ip_vs_in(unsigned int hooknum, struct sk
 			goto out;
 		}
 	}
