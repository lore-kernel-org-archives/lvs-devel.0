From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next 05/12] ipvs: Make ip_vs_schedule aware of inverse iph'es
Date: Wed, 12 Aug 2015 13:47:03 -0700
Message-ID: <1439412430-1702375-6-git-send-email-agartrell@fb.com>
References: <1439412430-1702375-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=Q19YBEayVQxmWWRjlvDOo/SuTOQFXVXRKqR5rcuhpXM=;
 b=WQ2PIGcFxIFPq9fMNkyz2P0F/R2YNCc5mU2v0onr1RKV0vITRVbP65nWqBNwqvGVgXpX
 ANdF1fx/lE5UXkXRVyzpF9bge+DMk8YMdrBDu6K0sIIM3Ww6C2C10Eusrdk1AcTAxj4i
 ZrGmU979+92xdblH4MtQinWsWKRd9zFwlSM= 
In-Reply-To: <1439412430-1702375-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ja@ssi.bg, horms@verge.net.au, lvs-devel@vger.kernel.org
Cc: kernel-team@fb.com, alexgartrell@gmail.com, Alex Gartrell <agartrell@fb.com>

This is necessary to schedule icmp later.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 26 +++++++++++++++++++-------
 1 file changed, 19 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 0603522..574a289 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -418,7 +418,8 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	struct ip_vs_conn *cp = NULL;
 	struct ip_vs_scheduler *sched;
 	struct ip_vs_dest *dest;
-	__be16 _ports[2], *pptr;
+	__be16 _ports[2], *pptr, cport, vport;
+	const void *caddr, *vaddr;
 	unsigned int flags;
 
 	*ignored = 1;
@@ -429,13 +430,25 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	if (pptr == NULL)
 		return NULL;
 
+	if (likely(!ip_vs_iph_inverse(iph))) {
+		cport = pptr[0];
+		caddr = &iph->saddr;
+		vport = pptr[1];
+		vaddr = &iph->daddr;
+	} else {
+		cport = pptr[1];
+		caddr = &iph->daddr;
+		vport = pptr[0];
+		vaddr = &iph->saddr;
+	}
+
 	/*
 	 * FTPDATA needs this check when using local real server.
 	 * Never schedule Active FTPDATA connections from real server.
 	 * For LVS-NAT they must be already created. For other methods
 	 * with persistence the connection is created on SYN+ACK.
 	 */
-	if (pptr[0] == FTPDATA) {
+	if (cport == FTPDATA) {
 		IP_VS_DBG_PKT(12, svc->af, pp, skb, 0,
 			      "Not scheduling FTPDATA");
 		return NULL;
@@ -456,7 +469,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	 *    Persistent service
 	 */
 	if (svc->flags & IP_VS_SVC_F_PERSISTENT)
-		return ip_vs_sched_persist(svc, skb, pptr[0], pptr[1], ignored,
+		return ip_vs_sched_persist(svc, skb, cport, vport, ignored,
 					   iph);
 
 	*ignored = 0;
@@ -464,7 +477,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	/*
 	 *    Non-persistent service
 	 */
-	if (!svc->fwmark && pptr[1] != svc->port) {
+	if (!svc->fwmark && vport != svc->port) {
 		if (!svc->port)
 			pr_err("Schedule: port zero only supported "
 			       "in persistent services, "
@@ -496,10 +509,9 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 		struct ip_vs_conn_param p;
 
 		ip_vs_conn_fill_param(svc->net, svc->af, iph->protocol,
-				      &iph->saddr, pptr[0], &iph->daddr,
-				      pptr[1], &p);
+				      caddr, cport, vaddr, vport, &p);
 		cp = ip_vs_conn_new(&p, dest->af, &dest->addr,
-				    dest->port ? dest->port : pptr[1],
+				    dest->port ? dest->port : vport,
 				    flags, dest, skb->mark);
 		if (!cp) {
 			*ignored = -1;
-- 
Alex Gartrell <agartrell@fb.com>

