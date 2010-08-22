From: Simon Horman <horms@verge.net.au>
Subject: [patch v1 03/12] IPVS: compact ip_vs_sched_persist()
Date: Sun, 22 Aug 2010 21:45:00 +0900
Message-ID: <20100822124857.698805871@vergenet.net>
References: <20100822124457.339517323@vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=ip_vs_sched_persist-compact.patch
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

Compact ip_vs_sched_persist() by setting up parameters
and calling functions once.

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_core.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_core.c	2010-07-25 20:17:58.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_core.c	2010-07-25 20:18:21.000000000 +0900
@@ -192,10 +192,15 @@ ip_vs_sched_persist(struct ip_vs_service
 	struct ip_vs_iphdr iph;
 	struct ip_vs_dest *dest;
 	struct ip_vs_conn *ct;
-	__be16  dport;			/* destination port to forward */
+	__be16  dport = 0;
 	__be16  flags;
 	union nf_inet_addr snet;	/* source network of the client,
 					   after masking */
+	int protocol = iph.protocol;
+	const union nf_inet_addr *vaddr = &iph.daddr;
+	union nf_inet_addr fwmark = { .ip = htonl(svc->fwmark) };
+	__be16 vport = 0;
+
 
 	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
 
@@ -226,119 +231,58 @@ ip_vs_sched_persist(struct ip_vs_service
 	 * service, and a template like <caddr, 0, vaddr, vport, daddr, dport>
 	 * is created for other persistent services.
 	 */
-	if (ports[1] == svc->port) {
-		/* Check if a template already exists */
-		if (svc->port != FTPPORT)
-			ct = ip_vs_ct_in_get(svc->af, iph.protocol, &snet, 0,
-					     &iph.daddr, ports[1]);
-		else
-			ct = ip_vs_ct_in_get(svc->af, iph.protocol, &snet, 0,
-					     &iph.daddr, 0);
-
-		if (!ct || !ip_vs_check_template(ct)) {
-			/*
-			 * No template found or the dest of the connection
-			 * template is not available.
-			 */
-			dest = svc->scheduler->schedule(svc, skb);
-			if (dest == NULL) {
-				IP_VS_DBG(1, "p-schedule: no dest found.\n");
-				return NULL;
-			}
-
-			/*
-			 * Create a template like <protocol,caddr,0,
-			 * vaddr,vport,daddr,dport> for non-ftp service,
-			 * and <protocol,caddr,0,vaddr,0,daddr,0>
-			 * for ftp service.
+	{
+		if (ports[1] == svc->port) {
+			/* non-FTP template:
+			 * <protocol, caddr, 0, vaddr, vport, daddr, dport>
+			 * FTP template:
+			 * <protocol, caddr, 0, vaddr, 0, daddr, 0>
 			 */
 			if (svc->port != FTPPORT)
-				ct = ip_vs_conn_new(svc->af, iph.protocol,
-						    &snet, 0,
-						    &iph.daddr,
-						    ports[1],
-						    &dest->addr, dest->port,
-						    IP_VS_CONN_F_TEMPLATE,
-						    dest);
-			else
-				ct = ip_vs_conn_new(svc->af, iph.protocol,
-						    &snet, 0,
-						    &iph.daddr, 0,
-						    &dest->addr, 0,
-						    IP_VS_CONN_F_TEMPLATE,
-						    dest);
-			if (ct == NULL)
-				return NULL;
-
-			ct->timeout = svc->timeout;
+				vport = ports[1];
 		} else {
-			/* set destination with the found template */
-			dest = ct->dest;
-		}
-		dport = dest->port;
-	} else {
-		/*
-		 * Note: persistent fwmark-based services and persistent
-		 * port zero service are handled here.
-		 * fwmark template: <IPPROTO_IP,caddr,0,fwmark,0,daddr,0>
-		 * port zero template: <protocol,caddr,0,vaddr,0,daddr,0>
-		 */
-		if (svc->fwmark) {
-			union nf_inet_addr fwmark = {
-				.ip = htonl(svc->fwmark)
-			};
-
-			ct = ip_vs_ct_in_get(svc->af, IPPROTO_IP, &snet, 0,
-					     &fwmark, 0);
-		} else
-			ct = ip_vs_ct_in_get(svc->af, iph.protocol, &snet, 0,
-					     &iph.daddr, 0);
-
-		if (!ct || !ip_vs_check_template(ct)) {
-			/*
-			 * If it is not persistent port zero, return NULL,
-			 * otherwise create a connection template.
+			/* Note: persistent fwmark-based services and
+			 * persistent port zero service are handled here.
+			 * fwmark template:
+			 * <IPPROTO_IP,caddr,0,fwmark,0,daddr,0>
+			 * port zero template:
+			 * <protocol,caddr,0,vaddr,0,daddr,0>
 			 */
-			if (svc->port)
-				return NULL;
-
-			dest = svc->scheduler->schedule(svc, skb);
-			if (dest == NULL) {
-				IP_VS_DBG(1, "p-schedule: no dest found.\n");
-				return NULL;
+			if (svc->fwmark) {
+				protocol = IPPROTO_IP;
+				vaddr = &fwmark;
 			}
+		}
+	}
 
-			/*
-			 * Create a template according to the service
-			 */
-			if (svc->fwmark) {
-				union nf_inet_addr fwmark = {
-					.ip = htonl(svc->fwmark)
-				};
-
-				ct = ip_vs_conn_new(svc->af, IPPROTO_IP,
-						    &snet, 0,
-						    &fwmark, 0,
-						    &dest->addr, 0,
-						    IP_VS_CONN_F_TEMPLATE,
-						    dest);
-			} else
-				ct = ip_vs_conn_new(svc->af, iph.protocol,
-						    &snet, 0,
-						    &iph.daddr, 0,
-						    &dest->addr, 0,
-						    IP_VS_CONN_F_TEMPLATE,
-						    dest);
-			if (ct == NULL)
-				return NULL;
+	/* Check if a template already exists */
+	ct = ip_vs_ct_in_get(svc->af, protocol, &snet, 0, vaddr, vport);
 
-			ct->timeout = svc->timeout;
-		} else {
-			/* set destination with the found template */
-			dest = ct->dest;
+	if (!ct || !ip_vs_check_template(ct)) {
+		/* No template found or the dest of the connection
+		 * template is not available.
+		 */
+		dest = svc->scheduler->schedule(svc, skb);
+		if (!dest) {
+			IP_VS_DBG(1, "p-schedule: no dest found.\n");
+			return NULL;
 		}
-		dport = ports[1];
-	}
+
+		if (ports[1] == svc->port && svc->port != FTPPORT)
+			dport = dest->port;
+
+		/* Create a template */
+		ct = ip_vs_conn_new(svc->af, protocol, &snet, 0,vaddr, vport,
+				    &dest->addr, dport,
+				    IP_VS_CONN_F_TEMPLATE, dest);
+		if (ct == NULL)
+			return NULL;
+
+		ct->timeout = svc->timeout;
+	} else
+		/* set destination with the found template */
+		dest = ct->dest;
+	dport = dest->port;
 
 	flags = (svc->flags & IP_VS_SVC_F_ONEPACKET
 		 && iph.protocol == IPPROTO_UDP)?

