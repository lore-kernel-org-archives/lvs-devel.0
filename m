From: Julius Volz <juliusv@google.com>
Subject: [PATCH RFC 07/24] IPVS: Convert existing debug uses to use new macros
Date: Wed, 20 Aug 2008 18:15:14 +0200
Message-ID: <1219248931-15064-8-git-send-email-juliusv@google.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219248943; bh=42SyVnw/sp9cgPcIz4QCL6RdrTI=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=ZiH5zbXP6OMCy/j2ty+MFubP34Hsn63UZu6B5B/n
	KIV2rPU66HKHt/+D5eQ7sBIIu1ivCOjTgTXUTq8tBHYLrg==
In-Reply-To: <1219248931-15064-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Convert existing debugging outputs to use the newly introduced debugging
macros where appropriate.

Signed-off-by: Julius Volz <juliusv@google.com>

 13 files changed, 213 insertions(+), 180 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 82037b7..fbf57c2 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -670,24 +670,32 @@ static inline void ip_vs_control_del(struct ip_vs_conn *cp)
 {
 	struct ip_vs_conn *ctl_cp = cp->control;
 	if (!ctl_cp) {
-		IP_VS_ERR("request control DEL for uncontrolled: "
-			  "%d.%d.%d.%d:%d to %d.%d.%d.%d:%d\n",
-			  NIPQUAD(cp->caddr),ntohs(cp->cport),
-			  NIPQUAD(cp->vaddr),ntohs(cp->vport));
+		IP_VS_ERR_BUF("request control DEL for uncontrolled: "
+			      "%s:%d to %s:%d\n",
+			      IP_VS_DBG_ADDR(cp->af, &cp->caddr),
+			      ntohs(cp->cport),
+			      IP_VS_DBG_ADDR(cp->af, &cp->vaddr),
+			      ntohs(cp->vport));
+
 		return;
 	}
 
-	IP_VS_DBG(7, "DELeting control for: "
-		  "cp.dst=%d.%d.%d.%d:%d ctl_cp.dst=%d.%d.%d.%d:%d\n",
-		  NIPQUAD(cp->caddr),ntohs(cp->cport),
-		  NIPQUAD(ctl_cp->caddr),ntohs(ctl_cp->cport));
+	IP_VS_DBG_BUF(7, "DELeting control for: "
+		      "cp.dst=%s:%d ctl_cp.dst=%s:%d\n",
+		      IP_VS_DBG_ADDR(cp->af, &cp->caddr),
+		      ntohs(cp->cport),
+		      IP_VS_DBG_ADDR(cp->af, &ctl_cp->caddr),
+		      ntohs(ctl_cp->cport));
 
 	cp->control = NULL;
 	if (atomic_read(&ctl_cp->n_control) == 0) {
-		IP_VS_ERR("BUG control DEL with n=0 : "
-			  "%d.%d.%d.%d:%d to %d.%d.%d.%d:%d\n",
-			  NIPQUAD(cp->caddr),ntohs(cp->cport),
-			  NIPQUAD(cp->vaddr),ntohs(cp->vport));
+		IP_VS_ERR_BUF("BUG control DEL with n=0 : "
+			      "%s:%d to %s:%d\n",
+			      IP_VS_DBG_ADDR(cp->af, &cp->caddr),
+			      ntohs(cp->cport),
+			      IP_VS_DBG_ADDR(cp->af, &cp->vaddr),
+			      ntohs(cp->vport));
+
 		return;
 	}
 	atomic_dec(&ctl_cp->n_control);
@@ -697,23 +705,27 @@ static inline void
 ip_vs_control_add(struct ip_vs_conn *cp, struct ip_vs_conn *ctl_cp)
 {
 	if (cp->control) {
-		IP_VS_ERR("request control ADD for already controlled: "
-			  "%d.%d.%d.%d:%d to %d.%d.%d.%d:%d\n",
-			  NIPQUAD(cp->caddr),ntohs(cp->cport),
-			  NIPQUAD(cp->vaddr),ntohs(cp->vport));
+		IP_VS_ERR_BUF("request control ADD for already controlled: "
+			      "%s:%d to %s:%d\n",
+			      IP_VS_DBG_ADDR(cp->af, &cp->caddr),
+			      ntohs(cp->cport),
+			      IP_VS_DBG_ADDR(cp->af, &cp->vaddr),
+			      ntohs(cp->vport));
+
 		ip_vs_control_del(cp);
 	}
 
-	IP_VS_DBG(7, "ADDing control for: "
-		  "cp.dst=%d.%d.%d.%d:%d ctl_cp.dst=%d.%d.%d.%d:%d\n",
-		  NIPQUAD(cp->caddr),ntohs(cp->cport),
-		  NIPQUAD(ctl_cp->caddr),ntohs(ctl_cp->cport));
+	IP_VS_DBG_BUF(7, "ADDing control for: "
+		      "cp.dst=%s:%d ctl_cp.dst=%s:%d\n",
+		      IP_VS_DBG_ADDR(cp->af, &cp->caddr),
+		      ntohs(cp->cport),
+		      IP_VS_DBG_ADDR(cp->af, &ctl_cp->caddr),
+		      ntohs(ctl_cp->cport));
 
 	cp->control = ctl_cp;
 	atomic_inc(&ctl_cp->n_control);
 }
 
-
 /*
  *      IPVS application functions
  *      (from ip_vs_app.c)
diff --git a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
index 44a6872..ea921dc 100644
--- a/net/ipv4/ipvs/ip_vs_conn.c
+++ b/net/ipv4/ipvs/ip_vs_conn.c
@@ -222,11 +222,11 @@ struct ip_vs_conn *ip_vs_conn_in_get
 	if (!cp && atomic_read(&ip_vs_conn_no_cport_cnt))
 		cp = __ip_vs_conn_in_get(protocol, s_addr, 0, d_addr, d_port);
 
-	IP_VS_DBG(9, "lookup/in %s %u.%u.%u.%u:%d->%u.%u.%u.%u:%d %s\n",
-		  ip_vs_proto_name(protocol),
-		  NIPQUAD(s_addr), ntohs(s_port),
-		  NIPQUAD(d_addr), ntohs(d_port),
-		  cp?"hit":"not hit");
+	IP_VS_DBG_BUF(9, "lookup/in %s %s:%d->%s:%d %s\n",
+		      ip_vs_proto_name(protocol),
+		      IP_VS_DBG_ADDR(af, s_addr), ntohs(s_port),
+		      IP_VS_DBG_ADDR(af, d_addr), ntohs(d_port),
+		      cp ? "hit" : "not hit");
 
 	return cp;
 }
@@ -257,11 +257,11 @@ struct ip_vs_conn *ip_vs_ct_in_get
   out:
 	ct_read_unlock(hash);
 
-	IP_VS_DBG(9, "template lookup/in %s %u.%u.%u.%u:%d->%u.%u.%u.%u:%d %s\n",
-		  ip_vs_proto_name(protocol),
-		  NIPQUAD(s_addr), ntohs(s_port),
-		  NIPQUAD(d_addr), ntohs(d_port),
-		  cp?"hit":"not hit");
+	IP_VS_DBG_BUF(9, "template lookup/in %s %s:%d->%s:%d %s\n",
+		      ip_vs_proto_name(protocol),
+		      IP_VS_DBG_ADDR(af, s_addr), ntohs(s_port),
+		      IP_VS_DBG_ADDR(af, d_addr), ntohs(d_port),
+		      cp ? "hit" : "not hit");
 
 	return cp;
 }
@@ -298,11 +298,11 @@ struct ip_vs_conn *ip_vs_conn_out_get
 
 	ct_read_unlock(hash);
 
-	IP_VS_DBG(9, "lookup/out %s %u.%u.%u.%u:%d->%u.%u.%u.%u:%d %s\n",
-		  ip_vs_proto_name(protocol),
-		  NIPQUAD(s_addr), ntohs(s_port),
-		  NIPQUAD(d_addr), ntohs(d_port),
-		  ret?"hit":"not hit");
+	IP_VS_DBG_BUF(9, "lookup/out %s %s:%d->%s:%d %s\n",
+		      ip_vs_proto_name(protocol),
+		      IP_VS_DBG_ADDR(af, s_addr), ntohs(s_port),
+		      IP_VS_DBG_ADDR(af, d_addr), ntohs(d_port),
+		      ret ? "hit" : "not hit");
 
 	return ret;
 }
@@ -402,16 +402,16 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 		cp->flags |= atomic_read(&dest->conn_flags);
 	cp->dest = dest;
 
-	IP_VS_DBG(7, "Bind-dest %s c:%u.%u.%u.%u:%d v:%u.%u.%u.%u:%d "
-		  "d:%u.%u.%u.%u:%d fwd:%c s:%u conn->flags:%X conn->refcnt:%d "
-		  "dest->refcnt:%d\n",
-		  ip_vs_proto_name(cp->protocol),
-		  NIPQUAD(cp->caddr), ntohs(cp->cport),
-		  NIPQUAD(cp->vaddr), ntohs(cp->vport),
-		  NIPQUAD(cp->daddr), ntohs(cp->dport),
-		  ip_vs_fwd_tag(cp), cp->state,
-		  cp->flags, atomic_read(&cp->refcnt),
-		  atomic_read(&dest->refcnt));
+	IP_VS_DBG_BUF(7, "Bind-dest %s c:%s:%d v:%s:%d "
+		      "d:%s:%d fwd:%c s:%u conn->flags:%X conn->refcnt:%d "
+		      "dest->refcnt:%d\n",
+		      ip_vs_proto_name(cp->protocol),
+		      IP_VS_DBG_ADDR(cp->af, &cp->caddr), ntohs(cp->cport),
+		      IP_VS_DBG_ADDR(cp->af, &cp->vaddr), ntohs(cp->vport),
+		      IP_VS_DBG_ADDR(cp->af, &cp->daddr), ntohs(cp->dport),
+		      ip_vs_fwd_tag(cp), cp->state,
+		      cp->flags, atomic_read(&cp->refcnt),
+		      atomic_read(&dest->refcnt));
 
 	/* Update the connection counters */
 	if (!(cp->flags & IP_VS_CONN_F_TEMPLATE)) {
@@ -464,16 +464,16 @@ static inline void ip_vs_unbind_dest(struct ip_vs_conn *cp)
 	if (!dest)
 		return;
 
-	IP_VS_DBG(7, "Unbind-dest %s c:%u.%u.%u.%u:%d v:%u.%u.%u.%u:%d "
-		  "d:%u.%u.%u.%u:%d fwd:%c s:%u conn->flags:%X conn->refcnt:%d "
-		  "dest->refcnt:%d\n",
-		  ip_vs_proto_name(cp->protocol),
-		  NIPQUAD(cp->caddr), ntohs(cp->cport),
-		  NIPQUAD(cp->vaddr), ntohs(cp->vport),
-		  NIPQUAD(cp->daddr), ntohs(cp->dport),
-		  ip_vs_fwd_tag(cp), cp->state,
-		  cp->flags, atomic_read(&cp->refcnt),
-		  atomic_read(&dest->refcnt));
+	IP_VS_DBG_BUF(7, "Unbind-dest %s c:%s:%d v:%s:%d "
+		      "d:%s:%d fwd:%c s:%u conn->flags:%X conn->refcnt:%d "
+		      "dest->refcnt:%d\n",
+		      ip_vs_proto_name(cp->protocol),
+		      IP_VS_DBG_ADDR(cp->af, &cp->caddr), ntohs(cp->cport),
+		      IP_VS_DBG_ADDR(cp->af, &cp->vaddr), ntohs(cp->vport),
+		      IP_VS_DBG_ADDR(cp->af, &cp->daddr), ntohs(cp->dport),
+		      ip_vs_fwd_tag(cp), cp->state,
+		      cp->flags, atomic_read(&cp->refcnt),
+		      atomic_read(&dest->refcnt));
 
 	/* Update the connection counters */
 	if (!(cp->flags & IP_VS_CONN_F_TEMPLATE)) {
@@ -526,13 +526,16 @@ int ip_vs_check_template(struct ip_vs_conn *ct)
 	    !(dest->flags & IP_VS_DEST_F_AVAILABLE) ||
 	    (sysctl_ip_vs_expire_quiescent_template &&
 	     (atomic_read(&dest->weight) == 0))) {
-		IP_VS_DBG(9, "check_template: dest not available for "
-			  "protocol %s s:%u.%u.%u.%u:%d v:%u.%u.%u.%u:%d "
-			  "-> d:%u.%u.%u.%u:%d\n",
-			  ip_vs_proto_name(ct->protocol),
-			  NIPQUAD(ct->caddr), ntohs(ct->cport),
-			  NIPQUAD(ct->vaddr), ntohs(ct->vport),
-			  NIPQUAD(ct->daddr), ntohs(ct->dport));
+		IP_VS_DBG_BUF(9, "check_template: dest not available for "
+			      "protocol %s s:%s:%d v:%s:%d "
+			      "-> d:%s:%d\n",
+			      ip_vs_proto_name(ct->protocol),
+			      IP_VS_DBG_ADDR(ct->af, &ct->caddr),
+			      ntohs(ct->cport),
+			      IP_VS_DBG_ADDR(ct->af, &ct->vaddr),
+			      ntohs(ct->vport),
+			      IP_VS_DBG_ADDR(ct->af, &ct->daddr),
+			      ntohs(ct->dport));
 
 		/*
 		 * Invalidate the connection template
diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index a7879ea..63c08c4 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -182,11 +182,11 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	/* Mask saddr with the netmask to adjust template granularity */
 	snet = iph->saddr & svc->netmask;
 
-	IP_VS_DBG(6, "p-schedule: src %u.%u.%u.%u:%u dest %u.%u.%u.%u:%u "
-		  "mnet %u.%u.%u.%u\n",
-		  NIPQUAD(iph->saddr), ntohs(ports[0]),
-		  NIPQUAD(iph->daddr), ntohs(ports[1]),
-		  NIPQUAD(snet));
+	IP_VS_DBG_BUF(6, "p-schedule: src %s:%u dest %s:%u "
+		      "mnet %s\n",
+		      IP_VS_DBG_ADDR(svc->af, &iph.saddr), ntohs(ports[0]),
+		      IP_VS_DBG_ADDR(svc->af, &iph.daddr), ntohs(ports[1]),
+		      IP_VS_DBG_ADDR(svc->af, &snet));
 
 	/*
 	 * As far as we know, FTP is a very complicated network protocol, and
@@ -386,13 +386,13 @@ ip_vs_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	if (cp == NULL)
 		return NULL;
 
-	IP_VS_DBG(6, "Schedule fwd:%c c:%u.%u.%u.%u:%u v:%u.%u.%u.%u:%u "
-		  "d:%u.%u.%u.%u:%u conn->flags:%X conn->refcnt:%d\n",
-		  ip_vs_fwd_tag(cp),
-		  NIPQUAD(cp->caddr), ntohs(cp->cport),
-		  NIPQUAD(cp->vaddr), ntohs(cp->vport),
-		  NIPQUAD(cp->daddr), ntohs(cp->dport),
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
@@ -909,10 +909,10 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
 	 */
 	if (unlikely(skb->pkt_type != PACKET_HOST
 		     || skb->dev->flags & IFF_LOOPBACK || skb->sk)) {
-		IP_VS_DBG(12, "packet type=%d proto=%d daddr=%d.%d.%d.%d ignored\n",
+		IP_VS_DBG_BUF(12, "packet type=%d proto=%d daddr=%s ignored\n",
 			  skb->pkt_type,
-			  ip_hdr(skb)->protocol,
-			  NIPQUAD(ip_hdr(skb)->daddr));
+			  iph.protocol,
+			  IP_VS_DBG_ADDR(af, &iph.daddr));
 		return NF_ACCEPT;
 	}
 
diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index d1dbd8b..efa34fb 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -449,10 +449,10 @@ ip_vs_service_get(__u32 fwmark, __u16 protocol, __be32 vaddr, __be16 vport)
   out:
 	read_unlock(&__ip_vs_svc_lock);
 
-	IP_VS_DBG(9, "lookup service: fwm %u %s %u.%u.%u.%u:%u %s\n",
-		  fwmark, ip_vs_proto_name(protocol),
-		  NIPQUAD(vaddr), ntohs(vport),
-		  svc?"hit":"not hit");
+	IP_VS_DBG_BUF(9, "lookup service: fwm %u %s %s:%u %s\n",
+		      fwmark, ip_vs_proto_name(protocol),
+		      IP_VS_DBG_ADDR(af, vaddr), ntohs(vport),
+		      svc ? "hit" : "not hit");
 
 	return svc;
 }
@@ -623,11 +623,12 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, __be32 daddr, __be16 dport)
 	 * Find the destination in trash
 	 */
 	list_for_each_entry_safe(dest, nxt, &ip_vs_dest_trash, n_list) {
-		IP_VS_DBG(3, "Destination %u/%u.%u.%u.%u:%u still in trash, "
-			  "dest->refcnt=%d\n",
-			  dest->vfwmark,
-			  NIPQUAD(dest->addr), ntohs(dest->port),
-			  atomic_read(&dest->refcnt));
+		IP_VS_DBG_BUF(3, "Destination %u/%s:%u still in trash, "
+			      "dest->refcnt=%d\n",
+			      dest->vfwmark,
+			      IP_VS_DBG_ADDR(svc->af, &dest->addr),
+			      ntohs(dest->port),
+			      atomic_read(&dest->refcnt));
 		if (dest->addr == daddr &&
 		    dest->port == dport &&
 		    dest->vfwmark == svc->fwmark &&
@@ -643,10 +644,11 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, __be32 daddr, __be16 dport)
 		 * Try to purge the destination from trash if not referenced
 		 */
 		if (atomic_read(&dest->refcnt) == 1) {
-			IP_VS_DBG(3, "Removing destination %u/%u.%u.%u.%u:%u "
-				  "from trash\n",
-				  dest->vfwmark,
-				  NIPQUAD(dest->addr), ntohs(dest->port));
+			IP_VS_DBG_BUF(3, "Removing destination %u/%s:%u "
+				      "from trash\n",
+				      dest->vfwmark,
+				      IP_VS_DBG_ADDR(svc->af, &dest->addr),
+				      ntohs(dest->port));
 			list_del(&dest->n_list);
 			ip_vs_dst_reset(dest);
 			__ip_vs_unbind_svc(dest);
@@ -841,14 +843,16 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest)
 	 * is from the same service
 	 */
 	dest = ip_vs_trash_get_dest(svc, daddr, dport);
+
 	if (dest != NULL) {
-		IP_VS_DBG(3, "Get destination %u.%u.%u.%u:%u from trash, "
-			  "dest->refcnt=%d, service %u/%u.%u.%u.%u:%u\n",
-			  NIPQUAD(daddr), ntohs(dport),
-			  atomic_read(&dest->refcnt),
-			  dest->vfwmark,
-			  NIPQUAD(dest->vaddr),
-			  ntohs(dest->vport));
+		IP_VS_DBG_BUF(3, "Get destination %s:%u from trash, "
+			      "dest->refcnt=%d, service %u/%s:%u\n",
+			      IP_VS_DBG_ADDR(svc->af, &daddr), ntohs(dport),
+			      atomic_read(&dest->refcnt),
+			      dest->vfwmark,
+			      IP_VS_DBG_ADDR(svc->af, &dest->vaddr),
+			      ntohs(dest->vport));
+
 		__ip_vs_update_dest(svc, dest, udest);
 
 		/*
@@ -988,10 +992,12 @@ static void __ip_vs_del_dest(struct ip_vs_dest *dest)
 		atomic_dec(&dest->svc->refcnt);
 		kfree(dest);
 	} else {
-		IP_VS_DBG(3, "Moving dest %u.%u.%u.%u:%u into trash, "
-			  "dest->refcnt=%d\n",
-			  NIPQUAD(dest->addr), ntohs(dest->port),
-			  atomic_read(&dest->refcnt));
+		IP_VS_DBG_BUF(3, "Moving dest %s:%u into trash, "
+			      "dest->refcnt=%d\n",
+			      IP_VS_DBG_ADDR(dest->af, &dest->addr),
+			      ntohs(dest->port),
+			      atomic_read(&dest->refcnt));
+
 		list_add(&dest->n_list, &ip_vs_dest_trash);
 		atomic_inc(&dest->refcnt);
 	}
diff --git a/net/ipv4/ipvs/ip_vs_lc.c b/net/ipv4/ipvs/ip_vs_lc.c
index ebcdbf7..b8670ec 100644
--- a/net/ipv4/ipvs/ip_vs_lc.c
+++ b/net/ipv4/ipvs/ip_vs_lc.c
@@ -84,11 +84,13 @@ ip_vs_lc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		}
 	}
 
-	if (least)
-	IP_VS_DBG(6, "LC: server %u.%u.%u.%u:%u activeconns %d inactconns %d\n",
-		  NIPQUAD(least->addr), ntohs(least->port),
-		  atomic_read(&least->activeconns),
-		  atomic_read(&least->inactconns));
+	if (!least)
+		return NULL;
+
+	IP_VS_DBG_BUF(6, "LC: server %s:%u activeconns %d inactconns %d\n",
+		      IP_VS_DBG_ADDR(svc->af, &least->addr), ntohs(least->port),
+		      atomic_read(&least->activeconns),
+		      atomic_read(&least->inactconns));
 
 	return least;
 }
diff --git a/net/ipv4/ipvs/ip_vs_nq.c b/net/ipv4/ipvs/ip_vs_nq.c
index 92f3a67..af277bc 100644
--- a/net/ipv4/ipvs/ip_vs_nq.c
+++ b/net/ipv4/ipvs/ip_vs_nq.c
@@ -120,12 +120,13 @@ ip_vs_nq_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		return NULL;
 
   out:
-	IP_VS_DBG(6, "NQ: server %u.%u.%u.%u:%u "
-		  "activeconns %d refcnt %d weight %d overhead %d\n",
-		  NIPQUAD(least->addr), ntohs(least->port),
-		  atomic_read(&least->activeconns),
-		  atomic_read(&least->refcnt),
-		  atomic_read(&least->weight), loh);
+
+	IP_VS_DBG_BUF(6, "NQ: server %s:%u "
+		      "activeconns %d refcnt %d weight %d overhead %d\n",
+		      IP_VS_DBG_ADDR(svc->af, &least->addr), ntohs(least->port),
+		      atomic_read(&least->activeconns),
+		      atomic_read(&least->refcnt),
+		      atomic_read(&least->weight), loh);
 
 	return least;
 }
diff --git a/net/ipv4/ipvs/ip_vs_proto_ah.c b/net/ipv4/ipvs/ip_vs_proto_ah.c
index 73e0ea8..ee40aef 100644
--- a/net/ipv4/ipvs/ip_vs_proto_ah.c
+++ b/net/ipv4/ipvs/ip_vs_proto_ah.c
@@ -66,12 +66,12 @@ ah_conn_in_get(const struct sk_buff *skb,
 		 * We are not sure if the packet is from our
 		 * service, so our conn_schedule hook should return NF_ACCEPT
 		 */
-		IP_VS_DBG(12, "Unknown ISAKMP entry for outin packet "
-			  "%s%s %u.%u.%u.%u->%u.%u.%u.%u\n",
-			  inverse ? "ICMP+" : "",
-			  pp->name,
-			  NIPQUAD(iph->saddr),
-			  NIPQUAD(iph->daddr));
+		IP_VS_DBG_BUF(12, "Unknown ISAKMP entry for outin packet "
+			      "%s%s %s->%s\n",
+			      inverse ? "ICMP+" : "",
+			      pp->name,
+			      IP_VS_DBG_ADDR(af, &iph->saddr),
+			      IP_VS_DBG_ADDR(af, &iph->daddr));
 	}
 
 	return cp;
@@ -99,12 +99,12 @@ ah_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
 	}
 
 	if (!cp) {
-		IP_VS_DBG(12, "Unknown ISAKMP entry for inout packet "
-			  "%s%s %u.%u.%u.%u->%u.%u.%u.%u\n",
-			  inverse ? "ICMP+" : "",
-			  pp->name,
-			  NIPQUAD(iph->saddr),
-			  NIPQUAD(iph->daddr));
+		IP_VS_DBG_BUF(12, "Unknown ISAKMP entry for inout packet "
+			      "%s%s %s->%s\n",
+			      inverse ? "ICMP+" : "",
+			      pp->name,
+			      IP_VS_DBG_ADDR(af, &iph->saddr),
+			      IP_VS_DBG_ADDR(af, &iph->daddr));
 	}
 
 	return cp;
diff --git a/net/ipv4/ipvs/ip_vs_proto_esp.c b/net/ipv4/ipvs/ip_vs_proto_esp.c
index 21d70c8..51950e3 100644
--- a/net/ipv4/ipvs/ip_vs_proto_esp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_esp.c
@@ -66,12 +66,12 @@ esp_conn_in_get(const struct sk_buff *skb,
 		 * We are not sure if the packet is from our
 		 * service, so our conn_schedule hook should return NF_ACCEPT
 		 */
-		IP_VS_DBG(12, "Unknown ISAKMP entry for outin packet "
-			  "%s%s %u.%u.%u.%u->%u.%u.%u.%u\n",
-			  inverse ? "ICMP+" : "",
-			  pp->name,
-			  NIPQUAD(iph->saddr),
-			  NIPQUAD(iph->daddr));
+		IP_VS_DBG_BUF(12, "Unknown ISAKMP entry for outin packet "
+			      "%s%s %s->%s\n",
+			      inverse ? "ICMP+" : "",
+			      pp->name,
+			      IP_VS_DBG_ADDR(af, &iph->saddr),
+			      IP_VS_DBG_ADDR(af, &iph->daddr));
 	}
 
 	return cp;
@@ -99,12 +99,12 @@ esp_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
 	}
 
 	if (!cp) {
-		IP_VS_DBG(12, "Unknown ISAKMP entry for inout packet "
-			  "%s%s %u.%u.%u.%u->%u.%u.%u.%u\n",
-			  inverse ? "ICMP+" : "",
-			  pp->name,
-			  NIPQUAD(iph->saddr),
-			  NIPQUAD(iph->daddr));
+		IP_VS_DBG_BUF(12, "Unknown ISAKMP entry for inout packet "
+			      "%s%s %s->%s\n",
+			      inverse ? "ICMP+" : "",
+			      pp->name,
+			      IP_VS_DBG_ADDR(af, &iph->saddr),
+			      IP_VS_DBG_ADDR(af, &iph->daddr));
 	}
 
 	return cp;
diff --git a/net/ipv4/ipvs/ip_vs_proto_tcp.c b/net/ipv4/ipvs/ip_vs_proto_tcp.c
index d0ea467..4689d94 100644
--- a/net/ipv4/ipvs/ip_vs_proto_tcp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_tcp.c
@@ -419,19 +419,22 @@ set_tcp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
 	if (new_state != cp->state) {
 		struct ip_vs_dest *dest = cp->dest;
 
-		IP_VS_DBG(8, "%s %s [%c%c%c%c] %u.%u.%u.%u:%d->"
-			  "%u.%u.%u.%u:%d state: %s->%s conn->refcnt:%d\n",
-			  pp->name,
-			  (state_off==TCP_DIR_OUTPUT)?"output ":"input ",
-			  th->syn? 'S' : '.',
-			  th->fin? 'F' : '.',
-			  th->ack? 'A' : '.',
-			  th->rst? 'R' : '.',
-			  NIPQUAD(cp->daddr), ntohs(cp->dport),
-			  NIPQUAD(cp->caddr), ntohs(cp->cport),
-			  tcp_state_name(cp->state),
-			  tcp_state_name(new_state),
-			  atomic_read(&cp->refcnt));
+		IP_VS_DBG_BUF(8, "%s %s [%c%c%c%c] %s:%d->"
+			      "%s:%d state: %s->%s conn->refcnt:%d\n",
+			      pp->name,
+			      (state_off==TCP_DIR_OUTPUT)?"output ":"input ",
+			      th->syn? 'S' : '.',
+			      th->fin? 'F' : '.',
+			      th->ack? 'A' : '.',
+			      th->rst? 'R' : '.',
+			      IP_VS_DBG_ADDR(cp->af, &cp->daddr),
+			      ntohs(cp->dport),
+			      IP_VS_DBG_ADDR(cp->af, &cp->caddr),
+			      ntohs(cp->cport),
+			      tcp_state_name(cp->state),
+			      tcp_state_name(new_state),
+			      atomic_read(&cp->refcnt));
+
 		if (dest) {
 			if (!(cp->flags & IP_VS_CONN_F_INACTIVE) &&
 			    (new_state != IP_VS_TCP_S_ESTABLISHED)) {
@@ -546,12 +549,15 @@ tcp_app_conn_bind(struct ip_vs_conn *cp)
 				break;
 			spin_unlock(&tcp_app_lock);
 
-			IP_VS_DBG(9, "%s: Binding conn %u.%u.%u.%u:%u->"
-				  "%u.%u.%u.%u:%u to app %s on port %u\n",
-				  __func__,
-				  NIPQUAD(cp->caddr), ntohs(cp->cport),
-				  NIPQUAD(cp->vaddr), ntohs(cp->vport),
-				  inc->name, ntohs(inc->port));
+			IP_VS_DBG_BUF(9, "%s: Binding conn %s:%u->"
+				      "%s:%u to app %s on port %u\n",
+				      __func__,
+				      IP_VS_DBG_ADDR(cp->af, &cp->caddr),
+				      ntohs(cp->cport),
+				      IP_VS_DBG_ADDR(cp->af, &cp->vaddr),
+				      ntohs(cp->vport),
+				      inc->name, ntohs(inc->port));
+
 			cp->app = inc;
 			if (inc->init_conn)
 				result = inc->init_conn(inc, cp);
diff --git a/net/ipv4/ipvs/ip_vs_proto_udp.c b/net/ipv4/ipvs/ip_vs_proto_udp.c
index c6be5d5..e06020b 100644
--- a/net/ipv4/ipvs/ip_vs_proto_udp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_udp.c
@@ -340,12 +340,15 @@ static int udp_app_conn_bind(struct ip_vs_conn *cp)
 				break;
 			spin_unlock(&udp_app_lock);
 
-			IP_VS_DBG(9, "%s: Binding conn %u.%u.%u.%u:%u->"
-				  "%u.%u.%u.%u:%u to app %s on port %u\n",
-				  __func__,
-				  NIPQUAD(cp->caddr), ntohs(cp->cport),
-				  NIPQUAD(cp->vaddr), ntohs(cp->vport),
-				  inc->name, ntohs(inc->port));
+			IP_VS_DBG_BUF(9, "%s: Binding conn %s:%u->"
+				      "%s:%u to app %s on port %u\n",
+				      __func__,
+				      IP_VS_DBG_ADDR(cp->af, &cp->caddr),
+				      ntohs(cp->cport),
+				      IP_VS_DBG_ADDR(cp->af, &cp->vaddr),
+				      ntohs(cp->vport),
+				      inc->name, ntohs(inc->port));
+
 			cp->app = inc;
 			if (inc->init_conn)
 				result = inc->init_conn(inc, cp);
diff --git a/net/ipv4/ipvs/ip_vs_sed.c b/net/ipv4/ipvs/ip_vs_sed.c
index 77663d8..33d93b0 100644
--- a/net/ipv4/ipvs/ip_vs_sed.c
+++ b/net/ipv4/ipvs/ip_vs_sed.c
@@ -122,12 +122,12 @@ ip_vs_sed_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		}
 	}
 
-	IP_VS_DBG(6, "SED: server %u.%u.%u.%u:%u "
-		  "activeconns %d refcnt %d weight %d overhead %d\n",
-		  NIPQUAD(least->addr), ntohs(least->port),
-		  atomic_read(&least->activeconns),
-		  atomic_read(&least->refcnt),
-		  atomic_read(&least->weight), loh);
+	IP_VS_DBG_BUF(6, "SED: server %s:%u "
+		      "activeconns %d refcnt %d weight %d overhead %d\n",
+		      IP_VS_DBG_ADDR(svc->af, &least->addr), ntohs(least->port),
+		      atomic_read(&least->activeconns),
+		      atomic_read(&least->refcnt),
+		      atomic_read(&least->weight), loh);
 
 	return least;
 }
diff --git a/net/ipv4/ipvs/ip_vs_wlc.c b/net/ipv4/ipvs/ip_vs_wlc.c
index 9b0ef86..76e3339 100644
--- a/net/ipv4/ipvs/ip_vs_wlc.c
+++ b/net/ipv4/ipvs/ip_vs_wlc.c
@@ -110,12 +110,12 @@ ip_vs_wlc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		}
 	}
 
-	IP_VS_DBG(6, "WLC: server %u.%u.%u.%u:%u "
-		  "activeconns %d refcnt %d weight %d overhead %d\n",
-		  NIPQUAD(least->addr), ntohs(least->port),
-		  atomic_read(&least->activeconns),
-		  atomic_read(&least->refcnt),
-		  atomic_read(&least->weight), loh);
+	IP_VS_DBG_BUF(6, "WLC: server %s:%u "
+		      "activeconns %d refcnt %d weight %d overhead %d\n",
+		      IP_VS_DBG_ADDR(svc->af, &least->addr), ntohs(least->port),
+		      atomic_read(&least->activeconns),
+		      atomic_read(&least->refcnt),
+		      atomic_read(&least->weight), loh);
 
 	return least;
 }
diff --git a/net/ipv4/ipvs/ip_vs_wrr.c b/net/ipv4/ipvs/ip_vs_wrr.c
index 0d86a79..2f618dc 100644
--- a/net/ipv4/ipvs/ip_vs_wrr.c
+++ b/net/ipv4/ipvs/ip_vs_wrr.c
@@ -195,12 +195,12 @@ ip_vs_wrr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		}
 	}
 
-	IP_VS_DBG(6, "WRR: server %u.%u.%u.%u:%u "
-		  "activeconns %d refcnt %d weight %d\n",
-		  NIPQUAD(dest->addr), ntohs(dest->port),
-		  atomic_read(&dest->activeconns),
-		  atomic_read(&dest->refcnt),
-		  atomic_read(&dest->weight));
+	IP_VS_DBG_BUF(6, "WRR: server %s:%u "
+		      "activeconns %d refcnt %d weight %d\n",
+		      IP_VS_DBG_ADDR(svc->af, &dest->addr), ntohs(dest->port),
+		      atomic_read(&dest->activeconns),
+		      atomic_read(&dest->refcnt),
+		      atomic_read(&dest->weight));
 
   out:
 	write_unlock(&svc->sched_lock);
-- 
1.5.4.5

