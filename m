From: Simon Horman <horms@verge.net.au>
Subject: [rfc 04/13] [RFC 04/13] IPVS: compact ip_vs_sched_persist()
Date: Thu, 05 Aug 2010 20:47:59 +0900
Message-ID: <20100805115240.322432872@vergenet.net>
References: <20100805114755.118303531@vergenet.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0004-IPVS-compact-ip_vs_sched_persist.patch
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

Compact ip_vs_sched_persist() by setting up parameters
and calling functions once.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c |  158 +++++++++++++--------------------------
 1 files changed, 51 insertions(+), 107 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 4f8ddba..0fcc6f9 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -192,10 +192,15 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
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
 
@@ -226,120 +231,59 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
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
-			 */
-			if (svc->port)
-				return NULL;
-
-			dest = svc->scheduler->schedule(svc, skb);
-			if (dest == NULL) {
-				IP_VS_DBG(1, "p-schedule: no dest found.\n");
-				return NULL;
-			}
-
-			/*
-			 * Create a template according to the service
+			/* Note: persistent fwmark-based services and
+			 * persistent port zero service are handled here.
+			 * fwmark template:
+			 * <IPPROTO_IP,caddr,0,fwmark,0,daddr,0>
+			 * port zero template:
+			 * <protocol,caddr,0,vaddr,0,daddr,0>
 			 */
 			if (svc->fwmark) {
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
-
-			ct->timeout = svc->timeout;
-		} else {
-			/* set destination with the found template */
-			dest = ct->dest;
+				protocol = IPPROTO_IP;
+				vaddr = &fwmark;
+			}
 		}
-		dport = ports[1];
 	}
 
+	/* Check if a template already exists */
+	ct = ip_vs_ct_in_get(svc->af, protocol, &snet, 0, vaddr, vport);
+
+	if (!ct || !ip_vs_check_template(ct)) {
+		/* No template found or the dest of the connection
+		 * template is not available.
+		 */
+		dest = svc->scheduler->schedule(svc, skb);
+		if (!dest) {
+			IP_VS_DBG(1, "p-schedule: no dest found.\n");
+			return NULL;
+		}
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
+
 	flags = (svc->flags & IP_VS_SVC_F_ONEPACKET
 		 && iph.protocol == IPPROTO_UDP)?
 		IP_VS_CONN_F_ONE_PACKET : 0;
-- 
1.7.1


