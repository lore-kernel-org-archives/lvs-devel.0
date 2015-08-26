From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next,v3 06/14] ipvs: Make ip_vs_schedule aware of inverse iph'es
Date: Tue, 25 Aug 2015 20:49:21 -0700
Message-ID: <1440560969-3511889-6-git-send-email-agartrell@fb.com>
References: <1440560969-3511889-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=fh82A9ZthFOLsgpn3RBDlWJphC4No6VZo3mI3m2CrbM=;
 b=RzUWBPEG4/60QzJ/0I4zkgPbZK8MC4iIKKrh5EQNzz1YsFnThKekVMYBCb9z5i8HG6sI
 7Vjb27QB/SdNUiEfROUGyulE9rCJXXfzKuTWjnxqhOTPy1gH6kf+u22XqZlZCbcgl6y/
 gfRzCd4Fsu3FEOE/H4TIX4Iy8ROByLuYKb8= 
In-Reply-To: <1440560969-3511889-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org
Cc: alexgartrell@gmail.com, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

This is necessary to schedule icmp later.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 50 +++++++++++++++++++++++++++++------------
 1 file changed, 36 insertions(+), 14 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 905fc16..efff6cf 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -245,20 +245,30 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	const union nf_inet_addr fwmark = { .ip = htonl(svc->fwmark) };
 	union nf_inet_addr snet;	/* source network of the client,
 					   after masking */
+	const union nf_inet_addr *src_addr, *dst_addr;
+
+	if (likely(!ip_vs_iph_inverse(iph))) {
+		src_addr = &iph->saddr;
+		dst_addr = &iph->daddr;
+	} else {
+		src_addr = &iph->daddr;
+		dst_addr = &iph->saddr;
+	}
+
 
 	/* Mask saddr with the netmask to adjust template granularity */
 #ifdef CONFIG_IP_VS_IPV6
 	if (svc->af == AF_INET6)
-		ipv6_addr_prefix(&snet.in6, &iph->saddr.in6,
+		ipv6_addr_prefix(&snet.in6, &src_addr->in6,
 				 (__force __u32) svc->netmask);
 	else
 #endif
-		snet.ip = iph->saddr.ip & svc->netmask;
+		snet.ip = src_addr->ip & svc->netmask;
 
 	IP_VS_DBG_BUF(6, "p-schedule: src %s:%u dest %s:%u "
 		      "mnet %s\n",
-		      IP_VS_DBG_ADDR(svc->af, &iph->saddr), ntohs(src_port),
-		      IP_VS_DBG_ADDR(svc->af, &iph->daddr), ntohs(dst_port),
+		      IP_VS_DBG_ADDR(svc->af, src_addr), ntohs(src_port),
+		      IP_VS_DBG_ADDR(svc->af, dst_addr), ntohs(dst_port),
 		      IP_VS_DBG_ADDR(svc->af, &snet));
 
 	/*
@@ -276,7 +286,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	 */
 	{
 		int protocol = iph->protocol;
-		const union nf_inet_addr *vaddr = &iph->daddr;
+		const union nf_inet_addr *vaddr = dst_addr;
 		__be16 vport = 0;
 
 		if (dst_port == svc->port) {
@@ -366,8 +376,8 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	/*
 	 *    Create a new connection according to the template
 	 */
-	ip_vs_conn_fill_param(svc->net, svc->af, iph->protocol, &iph->saddr,
-			      src_port, &iph->daddr, dst_port, &param);
+	ip_vs_conn_fill_param(svc->net, svc->af, iph->protocol, src_addr,
+			      src_port, dst_addr, dst_port, &param);
 
 	cp = ip_vs_conn_new(&param, dest->af, &dest->addr, dport, flags, dest,
 			    skb->mark);
@@ -418,7 +428,8 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	struct ip_vs_conn *cp = NULL;
 	struct ip_vs_scheduler *sched;
 	struct ip_vs_dest *dest;
-	__be16 _ports[2], *pptr;
+	__be16 _ports[2], *pptr, cport, vport;
+	const void *caddr, *vaddr;
 	unsigned int flags;
 
 	*ignored = 1;
@@ -429,13 +440,25 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
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
@@ -462,7 +485,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	 *    Persistent service
 	 */
 	if (svc->flags & IP_VS_SVC_F_PERSISTENT)
-		return ip_vs_sched_persist(svc, skb, pptr[0], pptr[1], ignored,
+		return ip_vs_sched_persist(svc, skb, cport, vport, ignored,
 					   iph);
 
 	*ignored = 0;
@@ -470,7 +493,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	/*
 	 *    Non-persistent service
 	 */
-	if (!svc->fwmark && pptr[1] != svc->port) {
+	if (!svc->fwmark && vport != svc->port) {
 		if (!svc->port)
 			pr_err("Schedule: port zero only supported "
 			       "in persistent services, "
@@ -502,10 +525,9 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
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

