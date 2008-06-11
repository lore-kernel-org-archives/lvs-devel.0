From: "Julius R. Volz" <juliusv@google.com>
Subject: [PATCH 19/26] IPVS: Add scheduling functions for IPv6 connections.
Date: Wed, 11 Jun 2008 19:12:02 +0200
Message-ID: <1213204329-10973-20-git-send-email-juliusv@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213204337; bh=cHl8pqmRhzA18sWVz28nM+55up8=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=dqt2vzq3AJBkYsAJ+r4cW3tZE1jbjjX8GtWab3Od
	n1kIKNtU0uz41RU8kJD3YGceGtJaHRmtHrbU4wsiSDuFyg==
In-Reply-To: <1213204329-10973-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com, "Julius R. Volz" <juliusv@google.com>

Add ip_vs_schedule_v6() and ip_vs_sched_persist_v6() functions for
scheduling IPv6 connections.

Signed-off-by: Julius R. Volz <juliusv@google.com>

 2 files changed, 241 insertions(+), 0 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 6a58dff..8d28d98 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -991,6 +991,11 @@ extern struct ip_vs_scheduler *ip_vs_scheduler_get(const char *sched_name);
 extern void ip_vs_scheduler_put(struct ip_vs_scheduler *scheduler);
 extern struct ip_vs_conn *
 ip_vs_schedule(struct ip_vs_service *svc, const struct sk_buff *skb);
+#ifdef CONFIG_IP_VS_IPV6
+extern struct ip_vs_conn *
+ip_vs_schedule_v6(struct ip_vs_service *svc, const struct sk_buff *skb);
+#endif
+
 extern int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 			struct ip_vs_protocol *pp);
 
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 9a3d0df..ccd95ff 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -333,6 +333,180 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	return cp;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static struct ip_vs_conn *
+ip_vs_sched_persist_v6(struct ip_vs_service *svc,
+		       const struct sk_buff *skb,
+		       __be16 ports[2])
+{
+	struct ip_vs_conn *cp = NULL;
+	struct ipv6hdr *iph = ipv6_hdr(skb);
+	struct ip_vs_dest *dest;
+	struct ip_vs_conn *ct;
+	__be16  dport;	 	/* destination port to forward */
+	struct in6_addr snet;	/* source network of the client, after masking */
+
+	/* Mask saddr with the netmask to adjust template granularity */
+	ipv6_addr_prefix(&snet, &iph->saddr, svc->netmask);
+
+	IP_VS_DBG(6, "p-schedule: src " NIP6_FMT ":%u dest " NIP6_FMT ":%u "
+		  "mnet " NIP6_FMT "\n",
+		  NIP6(iph->saddr), ntohs(ports[0]),
+		  NIP6(iph->daddr), ntohs(ports[1]),
+		  NIP6(snet));
+
+	/*
+	 * As far as we know, FTP is a very complicated network protocol, and
+	 * it uses control connection and data connections. For active FTP,
+	 * FTP server initialize data connection to the client, its source port
+	 * is often 20. For passive FTP, FTP server tells the clients the port
+	 * that it passively listens to,  and the client issues the data
+	 * connection. In the tunneling or direct routing mode, the load
+	 * balancer is on the client-to-server half of connection, the port
+	 * number is unknown to the load balancer. So, a conn template like
+	 * <caddr, 0, vaddr, 0, daddr, 0> is created for persistent FTP
+	 * service, and a template like <caddr, 0, vaddr, vport, daddr, dport>
+	 * is created for other persistent services.
+	 */
+	if (ports[1] == svc->port) {
+		/* Check if a template already exists */
+		if (svc->port != FTPPORT)
+			ct = ip_vs_ct_in_get_v6(iph->nexthdr, &snet, 0,
+					        &iph->daddr, ports[1]);
+		else
+			ct = ip_vs_ct_in_get_v6(iph->nexthdr, &snet, 0,
+					        &iph->daddr, 0);
+
+		if (!ct || !ip_vs_check_template(ct)) {
+			/*
+			 * No template found or the dest of the connection
+			 * template is not available.
+			 */
+			dest = svc->scheduler->schedule(svc, skb);
+			if (dest == NULL) {
+				IP_VS_DBG(1, "p-schedule: no dest found.\n");
+				return NULL;
+			}
+
+			/*
+			 * Create a template like <protocol,caddr,0,
+			 * vaddr,vport,daddr,dport> for non-ftp service,
+			 * and <protocol,caddr,0,vaddr,0,daddr,0>
+			 * for ftp service.
+			 */
+			if (svc->port != FTPPORT)
+				ct = ip_vs_conn_new_v6(iph->nexthdr,
+						       &snet, 0,
+						       &iph->daddr,
+						       ports[1],
+						       &dest->addr.v6, dest->port,
+						       IP_VS_CONN_F_TEMPLATE,
+						       dest);
+			else
+				ct = ip_vs_conn_new_v6(iph->nexthdr,
+						       &snet, 0,
+						       &iph->daddr, 0,
+						       &dest->addr.v6, 0,
+						       IP_VS_CONN_F_TEMPLATE,
+						       dest);
+			if (ct == NULL)
+				return NULL;
+
+			ct->timeout = svc->timeout;
+		} else {
+			/* set destination with the found template */
+			dest = ct->dest;
+		}
+		dport = dest->port;
+	} else {
+		/*
+		 * Note: persistent fwmark-based services and persistent
+		 * port zero service are handled here.
+		 * fwmark template: <IPPROTO_IP,caddr,0,fwmark,0,daddr,0>
+		 * port zero template: <protocol,caddr,0,vaddr,0,daddr,0>
+		 */
+		if (svc->fwmark) {
+			struct in6_addr fwmark = {
+				.s6_addr32 = {0, 0, 0, htonl(svc->fwmark)}
+			};
+
+			ct = ip_vs_ct_in_get_v6(IPPROTO_IP, &snet, 0,
+					        &fwmark, 0);
+		} else
+			ct = ip_vs_ct_in_get_v6(iph->nexthdr, &snet, 0,
+					        &iph->daddr, 0);
+
+		if (!ct || !ip_vs_check_template(ct)) {
+			/*
+			 * If it is not persistent port zero, return NULL,
+			 * otherwise create a connection template.
+			 */
+			if (svc->port)
+				return NULL;
+
+			dest = svc->scheduler->schedule(svc, skb);
+			if (dest == NULL) {
+				IP_VS_DBG(1, "p-schedule: no dest found.\n");
+				return NULL;
+			}
+
+			/*
+			 * Create a template according to the service
+			 */
+			if (svc->fwmark) {
+				struct in6_addr fwmark = {
+					.s6_addr32 = {0, 0, 0, htonl(svc->fwmark)}
+				};
+
+				ct = ip_vs_conn_new_v6(IPPROTO_IP,
+						       &snet, 0,
+						       &fwmark, 0,
+						       &dest->addr.v6, 0,
+						       IP_VS_CONN_F_TEMPLATE,
+						       dest);
+			}
+			else
+				ct = ip_vs_conn_new_v6(iph->nexthdr,
+						       &snet, 0,
+						       &iph->daddr, 0,
+						       &dest->addr.v6, 0,
+						       IP_VS_CONN_F_TEMPLATE,
+						       dest);
+			if (ct == NULL)
+				return NULL;
+
+			ct->timeout = svc->timeout;
+		} else {
+			/* set destination with the found template */
+			dest = ct->dest;
+		}
+		dport = ports[1];
+	}
+
+	/*
+	 *    Create a new connection according to the template
+	 */
+	cp = ip_vs_conn_new_v6(iph->nexthdr,
+			       &iph->saddr, ports[0],
+			       &iph->daddr, ports[1],
+			       &dest->addr.v6, dport,
+			       0,
+			       dest);
+	if (cp == NULL) {
+		ip_vs_conn_put(ct);
+		return NULL;
+	}
+
+	/*
+	 *    Add its control
+	 */
+	ip_vs_control_add(cp, ct);
+	ip_vs_conn_put(ct);
+
+	ip_vs_conn_stats(cp, svc);
+	return cp;
+}
+#endif
 
 /*
  *  IPVS main scheduling function
@@ -400,6 +574,68 @@ ip_vs_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	return cp;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+struct ip_vs_conn *
+ip_vs_schedule_v6(struct ip_vs_service *svc, const struct sk_buff *skb)
+{
+	struct ip_vs_conn *cp = NULL;
+	struct ipv6hdr *iph = ipv6_hdr(skb);
+	struct ip_vs_dest *dest;
+	__be16 _ports[2], *pptr;
+
+	pptr = skb_header_pointer(skb, sizeof(struct ipv6hdr),
+				  sizeof(_ports), _ports);
+	if (pptr == NULL)
+		return NULL;
+
+	/*
+	 *    Persistent service
+	 */
+	if (svc->flags & IP_VS_SVC_F_PERSISTENT)
+		return ip_vs_sched_persist_v6(svc, skb, pptr);
+
+	/*
+	 *    Non-persistent service
+	 */
+	if (!svc->fwmark && pptr[1] != svc->port) {
+		if (!svc->port)
+			IP_VS_ERR("Schedule: port zero only supported "
+				  "in persistent services, "
+				  "check your ipvs configuration\n");
+		return NULL;
+	}
+
+	dest = svc->scheduler->schedule(svc, skb);
+	if (dest == NULL) {
+		IP_VS_DBG(1, "Schedule: no dest found.\n");
+		return NULL;
+	}
+
+	/*
+	 *    Create a connection entry.
+	 */
+	cp = ip_vs_conn_new_v6(iph->nexthdr,
+			       &iph->saddr, pptr[0],
+			       &iph->daddr, pptr[1],
+			       &dest->addr.v6, dest->port?dest->port:pptr[1],
+			       0,
+			       dest);
+	if (cp == NULL)
+		return NULL;
+
+	IP_VS_DBG(6, "Schedule fwd:%c c:" NIP6_FMT ":%u v:" NIP6_FMT ":%u "
+		  "d:" NIP6_FMT ":%u conn->flags:%X conn->refcnt:%d\n",
+		  ip_vs_fwd_tag(cp),
+		  NIP6(cp->caddr.v6), ntohs(cp->cport),
+		  NIP6(cp->vaddr.v6), ntohs(cp->vport),
+		  NIP6(cp->daddr.v6), ntohs(cp->dport),
+		  cp->flags, atomic_read(&cp->refcnt));
+
+	ip_vs_conn_stats(cp, svc);
+	return cp;
+}
+#endif
+
 
 /*
  *  Pass or drop the packet.
-- 
1.5.3.6

