From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next,v2 05/13] ipvs: Make ip_vs_schedule aware of inverse iph'es
Date: Mon, 24 Aug 2015 16:44:37 -0700
Message-ID: <1440459885-1103938-5-git-send-email-agartrell@fb.com>
References: <1440459885-1103938-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=bVzVTLxB8IcqN/rTN215BiMkSVBRFgYm6DCZxEu4/Uo=;
 b=mv+OYJaJUYT7OOQvdGHKDHkjH2yOnCeNIZGcNoKQvZMAUky1vBKPAuU6M4eIK0AwIRUK
 4XwZR8v0VaACuizxrMm4TpfYiF6rj8RHsb+WYswzfJxlY5g7q+ciaEZ/E34DT1S7sl2X
 0XEN1ypD+AeQUTi8VLOGncsVXTaZ/k53UzE= 
In-Reply-To: <1440459885-1103938-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org
Cc: alexgartrell@gmail.com, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

This is necessary to schedule icmp later.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 26 +++++++++++++++++++-------
 1 file changed, 19 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 1d9d177..558239a 100644
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
 		IP_VS_DBG_PKT(12, svc->af, pp, skb, iph->off,
 			      "Not scheduling FTPDATA");
 		return NULL;
@@ -462,7 +475,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	 *    Persistent service
 	 */
 	if (svc->flags & IP_VS_SVC_F_PERSISTENT)
-		return ip_vs_sched_persist(svc, skb, pptr[0], pptr[1], ignored,
+		return ip_vs_sched_persist(svc, skb, cport, vport, ignored,
 					   iph);
 
 	*ignored = 0;
@@ -470,7 +483,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	/*
 	 *    Non-persistent service
 	 */
-	if (!svc->fwmark && pptr[1] != svc->port) {
+	if (!svc->fwmark && vport != svc->port) {
 		if (!svc->port)
 			pr_err("Schedule: port zero only supported "
 			       "in persistent services, "
@@ -502,10 +515,9 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
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

