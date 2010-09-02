From: Simon Horman <horms@verge.net.au>
Subject: [patch net-next] ipvs: use pkts for SCTP too
Date: Thu, 2 Sep 2010 17:19:14 +0900
Message-ID: <20100902081913.GC28727@verge.net.au>
References: <Pine.LNX.4.58.1009020242060.14271@u.domain.uli>
 <20100902020331.GS8174@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100902020331.GS8174@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

From: Julian Anastasov <ja@ssi.bg>

Use correctly the in_pkts packet counter also for SCTP

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>

--- 

Dave, can you take this into net-next?

Index: net-next-2.6/net/netfilter/ipvs/ip_vs_core.c
===================================================================
--- net-next-2.6.orig/net/netfilter/ipvs/ip_vs_core.c	2010-09-02 10:59:53.000000000 +0900
+++ net-next-2.6/net/netfilter/ipvs/ip_vs_core.c	2010-09-02 11:02:11.000000000 +0900
@@ -1383,8 +1383,7 @@ ip_vs_in(unsigned int hooknum, struct sk
 	if (af == AF_INET && (ip_vs_sync_state & IP_VS_STATE_MASTER) &&
 	    cp->protocol == IPPROTO_SCTP) {
 		if ((cp->state == IP_VS_SCTP_S_ESTABLISHED &&
-			(atomic_read(&cp->in_pkts) %
-			 sysctl_ip_vs_sync_threshold[1]
+			(pkts % sysctl_ip_vs_sync_threshold[1]
 			 == sysctl_ip_vs_sync_threshold[0])) ||
 				(cp->old_state != cp->state &&
 				 ((cp->state == IP_VS_SCTP_S_CLOSED) ||
@@ -1395,7 +1394,8 @@ ip_vs_in(unsigned int hooknum, struct sk
 		}
 	}
 
-	if (af == AF_INET &&
+	/* Keep this block last: TCP and others with pp->num_states <= 1 */
+	else if (af == AF_INET &&
 	    (ip_vs_sync_state & IP_VS_STATE_MASTER) &&
 	    (((cp->protocol != IPPROTO_TCP ||
 	       cp->state == IP_VS_TCP_S_ESTABLISHED) &&
