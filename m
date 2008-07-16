From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] IPVS: More reliable subchronization on connection close.
Date: Wed, 16 Jul 2008 16:35:20 +1000
Message-ID: <20080716063519.GA5144@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: LVS Devel <lvs-devel@vger.kernel.org>, Linux Netdev List <netdev@vger.kernel.org>
Cc: David Miller <davem@davemloft.net>, Rumen Bogdanovski <rumen@voicecho.com>, Joseph Mack NA3T <jmack@wm7d.net>

From: Rumen Bogdanovski <rumen@voicecho.com>

This patch enhances the synchronization of the closing connections
between the master and the backup director. It prevents the closed
connections to expire with the 15 min timeout of the ESTABLISHED
state on the backup and makes them expire as they would do on the
master with much shorter timeouts.

Cc: Joseph Mack NA3T <jmack@wm7d.net>
Signed-off-by: Rumen G. Bogdanovski <rumen@voicecho.com>
Acked-by: Simon Horman <horms@verge.net.au>

--- 

Hi Dave,

please consider applying this.

diff -Naur net-2.6_orig/net/ipv4/ipvs/ip_vs_core.c net-2.6/net/ipv4/ipvs/ip_vs_core.c
--- net-2.6_orig/net/ipv4/ipvs/ip_vs_core.c	2008-07-15 11:23:44.000000000 +0300
+++ net-2.6/net/ipv4/ipvs/ip_vs_core.c	2008-07-15 11:27:31.000000000 +0300
@@ -993,7 +993,8 @@
 	       == sysctl_ip_vs_sync_threshold[0])) ||
 	     ((cp->protocol == IPPROTO_TCP) && (cp->old_state != cp->state) &&
 	      ((cp->state == IP_VS_TCP_S_FIN_WAIT) ||
-	       (cp->state == IP_VS_TCP_S_CLOSE)))))
+	       (cp->state == IP_VS_TCP_S_CLOSE_WAIT) ||
+	       (cp->state == IP_VS_TCP_S_TIME_WAIT)))))
 		ip_vs_sync_conn(cp);
 	cp->old_state = cp->state;
 
