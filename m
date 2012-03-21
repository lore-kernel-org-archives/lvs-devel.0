From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 4/9] ipvs: always update some of the flags bits in backup
Date: Wed, 21 Mar 2012 17:56:19 +0900
Message-ID: <1332320185-27157-5-git-send-email-horms@verge.net.au>
References: <1332320185-27157-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1332320185-27157-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

	As the goal is to mirror the inactconns/activeconns
counters in the backup server, make sure the cp->flags are
updated even if cp is still not bound to dest. If cp->flags
are not updated ip_vs_bind_dest will rely only on the initial
flags when updating the counters. To avoid mistakes and
complicated checks for protocol state rely only on the
IP_VS_CONN_F_INACTIVE bit when updating the counters.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Tested-by: Aleksey Chudov <aleksey.chudov@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/linux/ip_vs.h           |    5 +++
 net/netfilter/ipvs/ip_vs_sync.c |   65 ++++++++++++++-------------------------
 2 files changed, 28 insertions(+), 42 deletions(-)

diff --git a/include/linux/ip_vs.h b/include/linux/ip_vs.h
index 4deb383..ac31ef2 100644
--- a/include/linux/ip_vs.h
+++ b/include/linux/ip_vs.h
@@ -89,6 +89,7 @@
 #define IP_VS_CONN_F_TEMPLATE	0x1000		/* template, not connection */
 #define IP_VS_CONN_F_ONE_PACKET	0x2000		/* forward only one packet */
 
+/* Initial bits allowed in backup server */
 #define IP_VS_CONN_F_BACKUP_MASK (IP_VS_CONN_F_FWD_MASK | \
 				  IP_VS_CONN_F_NOOUTPUT | \
 				  IP_VS_CONN_F_INACTIVE | \
@@ -97,6 +98,10 @@
 				  IP_VS_CONN_F_TEMPLATE \
 				 )
 
+/* Bits allowed to update in backup server */
+#define IP_VS_CONN_F_BACKUP_UPD_MASK (IP_VS_CONN_F_INACTIVE | \
+				      IP_VS_CONN_F_SEQ_MASK)
+
 /* Flags that are not sent to backup server start from bit 16 */
 #define IP_VS_CONN_F_NFCT	(1 << 16)	/* use netfilter conntrack */
 
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 8a0d6d6..0e36679 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -731,9 +731,30 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 	else
 		cp = ip_vs_ct_in_get(param);
 
-	if (cp && param->pe_data) 	/* Free pe_data */
+	if (cp) {
+		/* Free pe_data */
 		kfree(param->pe_data);
-	if (!cp) {
+
+		dest = cp->dest;
+		if ((cp->flags ^ flags) & IP_VS_CONN_F_INACTIVE &&
+		    !(flags & IP_VS_CONN_F_TEMPLATE) && dest) {
+			if (flags & IP_VS_CONN_F_INACTIVE) {
+				atomic_dec(&dest->activeconns);
+				atomic_inc(&dest->inactconns);
+			} else {
+				atomic_inc(&dest->activeconns);
+				atomic_dec(&dest->inactconns);
+			}
+		}
+		flags &= IP_VS_CONN_F_BACKUP_UPD_MASK;
+		flags |= cp->flags & ~IP_VS_CONN_F_BACKUP_UPD_MASK;
+		cp->flags = flags;
+		if (!dest) {
+			dest = ip_vs_try_bind_dest(cp);
+			if (dest)
+				atomic_dec(&dest->refcnt);
+		}
+	} else {
 		/*
 		 * Find the appropriate destination for the connection.
 		 * If it is not found the connection will remain unbound
@@ -742,18 +763,6 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 		dest = ip_vs_find_dest(net, type, daddr, dport, param->vaddr,
 				       param->vport, protocol, fwmark, flags);
 
-		/*  Set the approprite ativity flag */
-		if (protocol == IPPROTO_TCP) {
-			if (state != IP_VS_TCP_S_ESTABLISHED)
-				flags |= IP_VS_CONN_F_INACTIVE;
-			else
-				flags &= ~IP_VS_CONN_F_INACTIVE;
-		} else if (protocol == IPPROTO_SCTP) {
-			if (state != IP_VS_SCTP_S_ESTABLISHED)
-				flags |= IP_VS_CONN_F_INACTIVE;
-			else
-				flags &= ~IP_VS_CONN_F_INACTIVE;
-		}
 		cp = ip_vs_conn_new(param, daddr, dport, flags, dest, fwmark);
 		if (dest)
 			atomic_dec(&dest->refcnt);
@@ -763,34 +772,6 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 			IP_VS_DBG(2, "BACKUP, add new conn. failed\n");
 			return;
 		}
-	} else if (!cp->dest) {
-		dest = ip_vs_try_bind_dest(cp);
-		if (dest)
-			atomic_dec(&dest->refcnt);
-	} else if ((cp->dest) && (cp->protocol == IPPROTO_TCP) &&
-		(cp->state != state)) {
-		/* update active/inactive flag for the connection */
-		dest = cp->dest;
-		if (!(cp->flags & IP_VS_CONN_F_INACTIVE) &&
-			(state != IP_VS_TCP_S_ESTABLISHED)) {
-			atomic_dec(&dest->activeconns);
-			atomic_inc(&dest->inactconns);
-			cp->flags |= IP_VS_CONN_F_INACTIVE;
-		} else if ((cp->flags & IP_VS_CONN_F_INACTIVE) &&
-			(state == IP_VS_TCP_S_ESTABLISHED)) {
-			atomic_inc(&dest->activeconns);
-			atomic_dec(&dest->inactconns);
-			cp->flags &= ~IP_VS_CONN_F_INACTIVE;
-		}
-	} else if ((cp->dest) && (cp->protocol == IPPROTO_SCTP) &&
-		(cp->state != state)) {
-		dest = cp->dest;
-		if (!(cp->flags & IP_VS_CONN_F_INACTIVE) &&
-		(state != IP_VS_SCTP_S_ESTABLISHED)) {
-			atomic_dec(&dest->activeconns);
-			atomic_inc(&dest->inactconns);
-			cp->flags &= ~IP_VS_CONN_F_INACTIVE;
-		}
 	}
 
 	if (opt)
-- 
1.7.6.3

