From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 2/9] ipvs: remove check for IP_VS_CONN_F_SYNC from ip_vs_bind_dest
Date: Wed, 21 Mar 2012 17:56:17 +0900
Message-ID: <1332320185-27157-3-git-send-email-horms@verge.net.au>
References: <1332320185-27157-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1332320185-27157-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

	As the IP_VS_CONN_F_INACTIVE bit is properly set
in cp->flags for all kind of connections we do not need to
add special checks for synced connections when updating
the activeconns/inactconns counters for first time. Now
logic will look just like in ip_vs_unbind_dest.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 6413d58..18f58a08 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -585,11 +585,10 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 
 	/* Update the connection counters */
 	if (!(cp->flags & IP_VS_CONN_F_TEMPLATE)) {
-		/* It is a normal connection, so increase the inactive
-		   connection counter because it is in TCP SYNRECV
-		   state (inactive) or other protocol inacive state */
-		if ((cp->flags & IP_VS_CONN_F_SYNC) &&
-		    (!(cp->flags & IP_VS_CONN_F_INACTIVE)))
+		/* It is a normal connection, so modify the counters
+		 * according to the flags, later the protocol can
+		 * update them on state change */
+		if (!(cp->flags & IP_VS_CONN_F_INACTIVE))
 			atomic_inc(&dest->activeconns);
 		else
 			atomic_inc(&dest->inactconns);
-- 
1.7.6.3
