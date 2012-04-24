From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH v4 8/8] ipvs: optimize the use of flags in ip_vs_bind_dest
Date: Tue, 24 Apr 2012 23:46:42 +0300
Message-ID: <1335300402-8076-9-git-send-email-ja@ssi.bg>
References: <1335300402-8076-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1335300402-8076-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

	cp->flags is marked volatile but ip_vs_bind_dest
can safely modify the flags, so save some CPU cycles by
using temp variable.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_conn.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 6a43c93..7f21b91 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -548,6 +548,7 @@ static inline void
 ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 {
 	unsigned int conn_flags;
+	__u32 flags;
 
 	/* if dest is NULL, then return directly */
 	if (!dest)
@@ -559,17 +560,19 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 	conn_flags = atomic_read(&dest->conn_flags);
 	if (cp->protocol != IPPROTO_UDP)
 		conn_flags &= ~IP_VS_CONN_F_ONE_PACKET;
+	flags = cp->flags;
 	/* Bind with the destination and its corresponding transmitter */
-	if (cp->flags & IP_VS_CONN_F_SYNC) {
+	if (flags & IP_VS_CONN_F_SYNC) {
 		/* if the connection is not template and is created
 		 * by sync, preserve the activity flag.
 		 */
-		if (!(cp->flags & IP_VS_CONN_F_TEMPLATE))
+		if (!(flags & IP_VS_CONN_F_TEMPLATE))
 			conn_flags &= ~IP_VS_CONN_F_INACTIVE;
 		/* connections inherit forwarding method from dest */
-		cp->flags &= ~(IP_VS_CONN_F_FWD_MASK | IP_VS_CONN_F_NOOUTPUT);
+		flags &= ~(IP_VS_CONN_F_FWD_MASK | IP_VS_CONN_F_NOOUTPUT);
 	}
-	cp->flags |= conn_flags;
+	flags |= conn_flags;
+	cp->flags = flags;
 	cp->dest = dest;
 
 	IP_VS_DBG_BUF(7, "Bind-dest %s c:%s:%d v:%s:%d "
@@ -584,11 +587,11 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 		      atomic_read(&dest->refcnt));
 
 	/* Update the connection counters */
-	if (!(cp->flags & IP_VS_CONN_F_TEMPLATE)) {
+	if (!(flags & IP_VS_CONN_F_TEMPLATE)) {
 		/* It is a normal connection, so modify the counters
 		 * according to the flags, later the protocol can
 		 * update them on state change */
-		if (!(cp->flags & IP_VS_CONN_F_INACTIVE))
+		if (!(flags & IP_VS_CONN_F_INACTIVE))
 			atomic_inc(&dest->activeconns);
 		else
 			atomic_inc(&dest->inactconns);
-- 
1.7.3.4

