From: Julius Volz <juliusv@google.com>
Subject: [PATCHv2 RFC 15/25] IPVS: Extend scheduling functions for IPv6 support
Date: Mon,  1 Sep 2008 14:56:12 +0200
Message-ID: <1220273782-19901-16-git-send-email-juliusv@google.com>
References: <1220273782-19901-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220273824; bh=wHd8fChJ894Rb5ywTXO5xqL5BgU=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=qO6TXMqnxqweME0EQDE/8CJlFcnZgFNo8/lBkja5
	P+0J0I+spli9R/S2rDjP72Pxwk0Aw6ocLh7sBh5VuZQpyQ==
In-Reply-To: <1220273782-19901-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Convert ip_vs_schedule() and ip_vs_sched_persist() to support scheduling of
IPv6 connections.

Signed-off-by: Julius Volz <juliusv@google.com>

 1 files changed, 31 insertions(+), 25 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index d6f5bf9..8bfd7c2 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -176,19 +176,25 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	struct ip_vs_iphdr iph;
 	struct ip_vs_dest *dest;
 	struct ip_vs_conn *ct;
-	__be16  dport;	 /* destination port to forward */
+	__be16  dport;			/* destination port to forward */
 	union nf_inet_addr snet;	/* source network of the client,
 					   after masking */
-	ip_vs_fill_iphdr(AF_INET, skb_network_header(skb), &iph);
+
+	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
 
 	/* Mask saddr with the netmask to adjust template granularity */
-	snet.ip = iph.saddr.ip & svc->netmask;
+#ifdef CONFIG_IP_VS_IPV6
+	if (svc->af == AF_INET6)
+		ipv6_addr_prefix(&snet.in6, &iph.saddr.in6, svc->netmask);
+	else
+#endif
+		snet.ip = iph.saddr.ip & svc->netmask;
 
-	IP_VS_DBG(6, "p-schedule: src %u.%u.%u.%u:%u dest %u.%u.%u.%u:%u "
-		  "mnet %u.%u.%u.%u\n",
-		  NIPQUAD(iph.saddr.ip), ntohs(ports[0]),
-		  NIPQUAD(iph.daddr.ip), ntohs(ports[1]),
-		  NIPQUAD(snet));
+	IP_VS_DBG_BUF(6, "p-schedule: src %s:%u dest %s:%u "
+		      "mnet %s\n",
+		      IP_VS_DBG_ADDR(svc->af, &iph.saddr), ntohs(ports[0]),
+		      IP_VS_DBG_ADDR(svc->af, &iph.daddr), ntohs(ports[1]),
+		      IP_VS_DBG_ADDR(svc->af, &snet));
 
 	/*
 	 * As far as we know, FTP is a very complicated network protocol, and
@@ -206,10 +212,10 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	if (ports[1] == svc->port) {
 		/* Check if a template already exists */
 		if (svc->port != FTPPORT)
-			ct = ip_vs_ct_in_get(AF_INET, iph.protocol, &snet, 0,
+			ct = ip_vs_ct_in_get(svc->af, iph.protocol, &snet, 0,
 					     &iph.daddr, ports[1]);
 		else
-			ct = ip_vs_ct_in_get(AF_INET, iph.protocol, &snet, 0,
+			ct = ip_vs_ct_in_get(svc->af, iph.protocol, &snet, 0,
 					     &iph.daddr, 0);
 
 		if (!ct || !ip_vs_check_template(ct)) {
@@ -230,7 +236,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 			 * for ftp service.
 			 */
 			if (svc->port != FTPPORT)
-				ct = ip_vs_conn_new(AF_INET, iph.protocol,
+				ct = ip_vs_conn_new(svc->af, iph.protocol,
 						    &snet, 0,
 						    &iph.daddr,
 						    ports[1],
@@ -238,7 +244,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 						    IP_VS_CONN_F_TEMPLATE,
 						    dest);
 			else
-				ct = ip_vs_conn_new(AF_INET, iph.protocol,
+				ct = ip_vs_conn_new(svc->af, iph.protocol,
 						    &snet, 0,
 						    &iph.daddr, 0,
 						    &dest->addr, 0,
@@ -265,10 +271,10 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 				.all = { 0, 0, 0, htonl(svc->fwmark) }
 			};
 
-			ct = ip_vs_ct_in_get(AF_INET, IPPROTO_IP, &snet, 0,
+			ct = ip_vs_ct_in_get(svc->af, IPPROTO_IP, &snet, 0,
 					     &fwmark, 0);
 		} else
-			ct = ip_vs_ct_in_get(AF_INET, iph.protocol, &snet, 0,
+			ct = ip_vs_ct_in_get(svc->af, iph.protocol, &snet, 0,
 					     &iph.daddr, 0);
 
 		if (!ct || !ip_vs_check_template(ct)) {
@@ -293,14 +299,14 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 					.all = { 0, 0, 0, htonl(svc->fwmark) }
 				};
 
-				ct = ip_vs_conn_new(AF_INET, IPPROTO_IP,
+				ct = ip_vs_conn_new(svc->af, IPPROTO_IP,
 						    &snet, 0,
 						    &fwmark, 0,
 						    &dest->addr, 0,
 						    IP_VS_CONN_F_TEMPLATE,
 						    dest);
 			} else
-				ct = ip_vs_conn_new(AF_INET, iph.protocol,
+				ct = ip_vs_conn_new(svc->af, iph.protocol,
 						    &snet, 0,
 						    &iph.daddr, 0,
 						    &dest->addr, 0,
@@ -320,7 +326,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	/*
 	 *    Create a new connection according to the template
 	 */
-	cp = ip_vs_conn_new(AF_INET, iph.protocol,
+	cp = ip_vs_conn_new(svc->af, iph.protocol,
 			    &iph.saddr, ports[0],
 			    &iph.daddr, ports[1],
 			    &dest->addr, dport,
@@ -387,7 +393,7 @@ ip_vs_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	/*
 	 *    Create a connection entry.
 	 */
-	cp = ip_vs_conn_new(AF_INET, iph.protocol,
+	cp = ip_vs_conn_new(svc->af, iph.protocol,
 			    &iph.saddr, pptr[0],
 			    &iph.daddr, pptr[1],
 			    &dest->addr, dest->port ? dest->port : pptr[1],
@@ -396,13 +402,13 @@ ip_vs_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	if (cp == NULL)
 		return NULL;
 
-	IP_VS_DBG(6, "Schedule fwd:%c c:%u.%u.%u.%u:%u v:%u.%u.%u.%u:%u "
-		  "d:%u.%u.%u.%u:%u conn->flags:%X conn->refcnt:%d\n",
-		  ip_vs_fwd_tag(cp),
-		  NIPQUAD(cp->caddr.ip), ntohs(cp->cport),
-		  NIPQUAD(cp->vaddr.ip), ntohs(cp->vport),
-		  NIPQUAD(cp->daddr.ip), ntohs(cp->dport),
-		  cp->flags, atomic_read(&cp->refcnt));
+	IP_VS_DBG_BUF(6, "Schedule fwd:%c c:%s:%u v:%s:%u "
+		      "d:%s:%u conn->flags:%X conn->refcnt:%d\n",
+		      ip_vs_fwd_tag(cp),
+		      IP_VS_DBG_ADDR(svc->af, &cp->caddr), ntohs(cp->cport),
+		      IP_VS_DBG_ADDR(svc->af, &cp->vaddr), ntohs(cp->vport),
+		      IP_VS_DBG_ADDR(svc->af, &cp->daddr), ntohs(cp->dport),
+		      cp->flags, atomic_read(&cp->refcnt));
 
 	ip_vs_conn_stats(cp, svc);
 	return cp;
-- 
1.5.4.5

