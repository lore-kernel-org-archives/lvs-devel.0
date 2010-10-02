From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch v2 03/12] [PATCH 03/12] IPVS: compact
 ip_vs_sched_persist()
Date: Sat, 2 Oct 2010 11:20:50 +0900
Message-ID: <20101002022050.GA16593@verge.net.au>
References: <20101001143517.645421976@akiko.akashicho.tokyo.vergenet.net>
 <20101001143941.949669349@akiko.akashicho.tokyo.vergenet.net>
 <alpine.LFD.2.00.1010020129400.2462@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1010020129400.2462@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org, Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Patrick McHardy <kaber@trash.net>

On Sat, Oct 02, 2010 at 01:35:28AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Fri, 1 Oct 2010, Simon Horman wrote:
> 
> >Compact ip_vs_sched_persist() by setting up parameters
> >and calling functions once.
> >
> >Signed-off-by: Simon Horman <horms@verge.net.au>
> >---
> >
> >v2
> >* Make "union nf_inet_addr fwmark" const
> >* Don't remove the comment next to the declaration of dport
> >* Add a comment to the declaration of vport
> >
> >Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_core.c
> >===================================================================
> >--- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_core.c	2010-10-01 21:56:39.000000000 +0900
> >+++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_core.c	2010-10-01 22:02:41.000000000 +0900
> >@@ -193,10 +193,14 @@ ip_vs_sched_persist(struct ip_vs_service
> >	struct ip_vs_iphdr iph;
> >	struct ip_vs_dest *dest;
> >	struct ip_vs_conn *ct;
> >-	__be16  dport;			/* destination port to forward */
> >+	int protocol = iph.protocol;
> >+	__be16 dport = 0;		/* destination port to forward */
> >+	__be16 vport = 0;		/* virtual service port */
> >	unsigned int flags;
> >	union nf_inet_addr snet;	/* source network of the client,
> >					   after masking */
> >+	const union nf_inet_addr fwmark = { .ip = htonl(svc->fwmark) };
> >+	const union nf_inet_addr *vaddr = &iph.daddr;
> >
> >	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
> >
> >@@ -227,119 +231,58 @@ ip_vs_sched_persist(struct ip_vs_service
> >	 * service, and a template like <caddr, 0, vaddr, vport, daddr, dport>
> >	 * is created for other persistent services.
> >	 */
> >-	if (ports[1] == svc->port) {
> >-		/* Check if a template already exists */
> >-		if (svc->port != FTPPORT)
> >-			ct = ip_vs_ct_in_get(svc->af, iph.protocol, &snet, 0,
> >-					     &iph.daddr, ports[1]);
> >-		else
> >-			ct = ip_vs_ct_in_get(svc->af, iph.protocol, &snet, 0,
> >-					     &iph.daddr, 0);
> >-
> >-		if (!ct || !ip_vs_check_template(ct)) {
> >-			/*
> >-			 * No template found or the dest of the connection
> >-			 * template is not available.
> >-			 */
> >-			dest = svc->scheduler->schedule(svc, skb);
> >-			if (dest == NULL) {
> >-				IP_VS_DBG(1, "p-schedule: no dest found.\n");
> >-				return NULL;
> >-			}
> >-
> >-			/*
> >-			 * Create a template like <protocol,caddr,0,
> >-			 * vaddr,vport,daddr,dport> for non-ftp service,
> >-			 * and <protocol,caddr,0,vaddr,0,daddr,0>
> >-			 * for ftp service.
> >+	{
> >+		if (ports[1] == svc->port) {
> >+			/* non-FTP template:
> >+			 * <protocol, caddr, 0, vaddr, vport, daddr, dport>
> >+			 * FTP template:
> >+			 * <protocol, caddr, 0, vaddr, 0, daddr, 0>
> >			 */
> >			if (svc->port != FTPPORT)
> >-				ct = ip_vs_conn_new(svc->af, iph.protocol,
> >-						    &snet, 0,
> >-						    &iph.daddr,
> >-						    ports[1],
> >-						    &dest->addr, dest->port,
> >-						    IP_VS_CONN_F_TEMPLATE,
> >-						    dest);
> >-			else
> >-				ct = ip_vs_conn_new(svc->af, iph.protocol,
> >-						    &snet, 0,
> >-						    &iph.daddr, 0,
> >-						    &dest->addr, 0,
> >-						    IP_VS_CONN_F_TEMPLATE,
> >-						    dest);
> >-			if (ct == NULL)
> >-				return NULL;
> >-
> >-			ct->timeout = svc->timeout;
> >+				vport = ports[1];
> >		} else {
> >-			/* set destination with the found template */
> >-			dest = ct->dest;
> >-		}
> >-		dport = dest->port;
> >-	} else {
> >-		/*
> >-		 * Note: persistent fwmark-based services and persistent
> >-		 * port zero service are handled here.
> >-		 * fwmark template: <IPPROTO_IP,caddr,0,fwmark,0,daddr,0>
> >-		 * port zero template: <protocol,caddr,0,vaddr,0,daddr,0>
> >-		 */
> >-		if (svc->fwmark) {
> >-			union nf_inet_addr fwmark = {
> >-				.ip = htonl(svc->fwmark)
> >-			};
> >-
> >-			ct = ip_vs_ct_in_get(svc->af, IPPROTO_IP, &snet, 0,
> >-					     &fwmark, 0);
> >-		} else
> >-			ct = ip_vs_ct_in_get(svc->af, iph.protocol, &snet, 0,
> >-					     &iph.daddr, 0);
> >-
> >-		if (!ct || !ip_vs_check_template(ct)) {
> >-			/*
> >-			 * If it is not persistent port zero, return NULL,
> >-			 * otherwise create a connection template.
> >+			/* Note: persistent fwmark-based services and
> >+			 * persistent port zero service are handled here.
> >+			 * fwmark template:
> >+			 * <IPPROTO_IP,caddr,0,fwmark,0,daddr,0>
> >+			 * port zero template:
> >+			 * <protocol,caddr,0,vaddr,0,daddr,0>
> >			 */
> >-			if (svc->port)
> >-				return NULL;
> >-
> >-			dest = svc->scheduler->schedule(svc, skb);
> >-			if (dest == NULL) {
> >-				IP_VS_DBG(1, "p-schedule: no dest found.\n");
> >-				return NULL;
> >+			if (svc->fwmark) {
> >+				protocol = IPPROTO_IP;
> >+				vaddr = &fwmark;
> >			}
> >+		}
> >+	}
> >
> >-			/*
> >-			 * Create a template according to the service
> >-			 */
> >-			if (svc->fwmark) {
> >-				union nf_inet_addr fwmark = {
> >-					.ip = htonl(svc->fwmark)
> >-				};
> >-
> >-				ct = ip_vs_conn_new(svc->af, IPPROTO_IP,
> >-						    &snet, 0,
> >-						    &fwmark, 0,
> >-						    &dest->addr, 0,
> >-						    IP_VS_CONN_F_TEMPLATE,
> >-						    dest);
> >-			} else
> >-				ct = ip_vs_conn_new(svc->af, iph.protocol,
> >-						    &snet, 0,
> >-						    &iph.daddr, 0,
> >-						    &dest->addr, 0,
> >-						    IP_VS_CONN_F_TEMPLATE,
> >-						    dest);
> >-			if (ct == NULL)
> >-				return NULL;
> >+	/* Check if a template already exists */
> >+	ct = ip_vs_ct_in_get(svc->af, protocol, &snet, 0, vaddr, vport);
> >
> >-			ct->timeout = svc->timeout;
> >-		} else {
> >-			/* set destination with the found template */
> >-			dest = ct->dest;
> >+	if (!ct || !ip_vs_check_template(ct)) {
> >+		/* No template found or the dest of the connection
> >+		 * template is not available.
> >+		 */
> >+		dest = svc->scheduler->schedule(svc, skb);
> >+		if (!dest) {
> >+			IP_VS_DBG(1, "p-schedule: no dest found.\n");
> >+			return NULL;
> >		}
> >-		dport = ports[1];
> >-	}
> >+
> >+		if (ports[1] == svc->port && svc->port != FTPPORT)
> >+			dport = dest->port;
> >+
> >+		/* Create a template */
> >+		ct = ip_vs_conn_new(svc->af, protocol, &snet, 0,vaddr, vport,
> >+				    &dest->addr, dport,
> >+				    IP_VS_CONN_F_TEMPLATE, dest);
> >+		if (ct == NULL)
> >+			return NULL;
> >+
> >+		ct->timeout = svc->timeout;
> >+	} else
> >+		/* set destination with the found template */
> >+		dest = ct->dest;
> 
> 	Here dport:
> 
> >+	dport = dest->port;
> 
> 	should be:
> 
> 	dport = ports[1];
> 	if (dport == svc->port && dest->port)
> 		dport = dest->port;

Thanks, fixed.

> >	flags = (svc->flags & IP_VS_SVC_F_ONEPACKET
> >		 && iph.protocol == IPPROTO_UDP)?

I will repost the entire series a little later.
For reference, here is the updated version of this patch.


From a6310d1a8f21bdf15fa797ed748651679c0197e2 Mon Sep 17 00:00:00 2001
From: Simon Horman <horms@verge.net.au>
Date: Sun, 22 Aug 2010 21:37:51 +0900
Subject: [PATCH 03/12] IPVS: compact ip_vs_sched_persist()

Compact ip_vs_sched_persist() by setting up parameters
and calling functions once.

Signed-off-by: Simon Horman <horms@verge.net.au>
---

v2
* Make "union nf_inet_addr fwmark" const
* Don't remove the comment next to the declaration of dport
* Add a comment to the declaration of vport

v3
* As suggested by Julian Anastasov
  - Correct dport logic

Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_core.c
===================================================================
--- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_core.c	2010-10-02 10:54:57.000000000 +0900
+++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_core.c	2010-10-02 11:04:04.000000000 +0900
@@ -193,10 +193,14 @@ ip_vs_sched_persist(struct ip_vs_service
 	struct ip_vs_iphdr iph;
 	struct ip_vs_dest *dest;
 	struct ip_vs_conn *ct;
-	__be16  dport;			/* destination port to forward */
+	int protocol = iph.protocol;
+	__be16 dport = 0;		/* destination port to forward */
+	__be16 vport = 0;		/* virtual service port */
 	unsigned int flags;
 	union nf_inet_addr snet;	/* source network of the client,
 					   after masking */
+	const union nf_inet_addr fwmark = { .ip = htonl(svc->fwmark) };
+	const union nf_inet_addr *vaddr = &iph.daddr;
 
 	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
 
@@ -227,119 +231,61 @@ ip_vs_sched_persist(struct ip_vs_service
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
+
+	dport = ports[1];
+	if (dport == svc->port && dest->port)
+		dport = dest->port;
 
 	flags = (svc->flags & IP_VS_SVC_F_ONEPACKET
 		 && iph.protocol == IPPROTO_UDP)?
