From: "Julius R. Volz" <juliusv@google.com>
Subject: [PATCH 05/26] IPVS: Use new address family specific debugging macros.
Date: Wed, 11 Jun 2008 19:11:48 +0200
Message-ID: <1213204329-10973-6-git-send-email-juliusv@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213204336; bh=seHT8YWHEdCawz+7UgeDjqjDZIg=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=oA4xqZ+2pJJmFS0ukbB4PDpGyMgQNcKYtgjr9Gr1
	/6qjrQ9yi8epWsdeidlMgtQthPE6QT58jYDbI51B4JqicA==
In-Reply-To: <1213204329-10973-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com, "Julius R. Volz" <juliusv@google.com>

Change debug output to use address family specific debugging macros where
appropriate.

Signed-off-by: Julius R. Volz <juliusv@google.com>

 10 files changed, 257 insertions(+), 112 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 349a746..5c2d48d 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -806,24 +806,41 @@ static inline void ip_vs_control_del(struct ip_vs_conn *cp)
 {
 	struct ip_vs_conn *ctl_cp = cp->control;
 	if (!ctl_cp) {
-		IP_VS_ERR("request control DEL for uncontrolled: "
-			  "%d.%d.%d.%d:%d to %d.%d.%d.%d:%d\n",
-			  NIPQUAD(cp->caddr),ntohs(cp->cport),
-			  NIPQUAD(cp->vaddr),ntohs(cp->vport));
+		IP_VS_ERR_V4(cp->af, "request control DEL for uncontrolled: "
+			     "%d.%d.%d.%d:%d to %d.%d.%d.%d:%d\n",
+			     NIPQUAD(cp->caddr.v4),ntohs(cp->cport),
+			     NIPQUAD(cp->vaddr.v4),ntohs(cp->vport));
+
+		IP_VS_ERR_V6(cp->af, "request control DEL for uncontrolled: "
+			     NIP6_FMT ":%d to " NIP6_FMT ":%d\n",
+			     NIP6(cp->caddr.v6),ntohs(cp->cport),
+			     NIP6(cp->vaddr.v6),ntohs(cp->vport));
+
 		return;
 	}
 
-	IP_VS_DBG(7, "DELeting control for: "
-		  "cp.dst=%d.%d.%d.%d:%d ctl_cp.dst=%d.%d.%d.%d:%d\n",
-		  NIPQUAD(cp->caddr),ntohs(cp->cport),
-		  NIPQUAD(ctl_cp->caddr),ntohs(ctl_cp->cport));
+	IP_VS_DBG_V4(cp->af, 7, "DELeting control for: "
+		     "cp.dst=%d.%d.%d.%d:%d ctl_cp.dst=%d.%d.%d.%d:%d\n",
+		     NIPQUAD(cp->caddr.v4),ntohs(cp->cport),
+		     NIPQUAD(ctl_cp->caddr.v4),ntohs(ctl_cp->cport));
+
+	IP_VS_DBG_V6(cp->af, 7, "DELeting control for: "
+		     "cp.dst=" NIP6_FMT ":%d ctl_cp.dst=" NIP6_FMT ":%d\n",
+		     NIP6(cp->caddr.v6),ntohs(cp->cport),
+		     NIP6(ctl_cp->caddr.v6),ntohs(ctl_cp->cport));
 
 	cp->control = NULL;
 	if (atomic_read(&ctl_cp->n_control) == 0) {
-		IP_VS_ERR("BUG control DEL with n=0 : "
-			  "%d.%d.%d.%d:%d to %d.%d.%d.%d:%d\n",
-			  NIPQUAD(cp->caddr),ntohs(cp->cport),
-			  NIPQUAD(cp->vaddr),ntohs(cp->vport));
+		IP_VS_ERR_V4(cp->af, "BUG control DEL with n=0 : "
+			     "%d.%d.%d.%d:%d to %d.%d.%d.%d:%d\n",
+			     NIPQUAD(cp->caddr.v4),ntohs(cp->cport),
+			     NIPQUAD(cp->vaddr.v4),ntohs(cp->vport));
+
+		IP_VS_ERR_V6(cp->af, "BUG control DEL with n=0 : "
+			     NIP6_FMT ":%d to " NIP6_FMT ":%d\n",
+			     NIP6(cp->caddr.v6),ntohs(cp->cport),
+			     NIP6(cp->vaddr.v6),ntohs(cp->vport));
+
 		return;
 	}
 	atomic_dec(&ctl_cp->n_control);
@@ -833,17 +850,28 @@ static inline void
 ip_vs_control_add(struct ip_vs_conn *cp, struct ip_vs_conn *ctl_cp)
 {
 	if (cp->control) {
-		IP_VS_ERR("request control ADD for already controlled: "
-			  "%d.%d.%d.%d:%d to %d.%d.%d.%d:%d\n",
-			  NIPQUAD(cp->caddr),ntohs(cp->cport),
-			  NIPQUAD(cp->vaddr),ntohs(cp->vport));
+		IP_VS_ERR_V4(cp->af, "request control ADD for already controlled: "
+			     "%d.%d.%d.%d:%d to %d.%d.%d.%d:%d\n",
+			     NIPQUAD(cp->caddr.v4),ntohs(cp->cport),
+			     NIPQUAD(cp->vaddr.v4),ntohs(cp->vport));
+
+		IP_VS_ERR_V6(cp->af, "request control ADD for already controlled: "
+			     NIP6_FMT ":%d to " NIP6_FMT ":%d\n",
+			     NIP6(cp->caddr.v6),ntohs(cp->cport),
+			     NIP6(cp->vaddr.v6),ntohs(cp->vport));
+
 		ip_vs_control_del(cp);
 	}
 
-	IP_VS_DBG(7, "ADDing control for: "
-		  "cp.dst=%d.%d.%d.%d:%d ctl_cp.dst=%d.%d.%d.%d:%d\n",
-		  NIPQUAD(cp->caddr),ntohs(cp->cport),
-		  NIPQUAD(ctl_cp->caddr),ntohs(ctl_cp->cport));
+	IP_VS_DBG_V4(cp->af, 7, "ADDing control for: "
+		     "cp.dst=%d.%d.%d.%d:%d ctl_cp.dst=%d.%d.%d.%d:%d\n",
+		     NIPQUAD(cp->caddr.v4),ntohs(cp->cport),
+		     NIPQUAD(ctl_cp->caddr.v4),ntohs(ctl_cp->cport));
+
+	IP_VS_DBG_V6(cp->af, 7, "ADDing control for: "
+		     "cp.dst=" NIP6_FMT ":%d ctl_cp.dst=" NIP6_FMT ":%d\n",
+		     NIP6(cp->caddr.v6),ntohs(cp->cport),
+		     NIP6(ctl_cp->caddr.v6),ntohs(ctl_cp->cport));
 
 	cp->control = ctl_cp;
 	atomic_inc(&ctl_cp->n_control);
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 1d81cbc..b3df938 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -407,16 +407,27 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
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
+	IP_VS_DBG_V4(cp->af, 7, "Bind-dest %s c:%u.%u.%u.%u:%d v:%u.%u.%u.%u:%d "
+		     "d:%u.%u.%u.%u:%d fwd:%c s:%u conn->flags:%X conn->refcnt:%d "
+		     "dest->refcnt:%d\n",
+		     ip_vs_proto_name(cp->protocol),
+		     NIPQUAD(cp->caddr.v4), ntohs(cp->cport),
+		     NIPQUAD(cp->vaddr.v4), ntohs(cp->vport),
+		     NIPQUAD(cp->daddr.v4), ntohs(cp->dport),
+		     ip_vs_fwd_tag(cp), cp->state,
+		     cp->flags, atomic_read(&cp->refcnt),
+		     atomic_read(&dest->refcnt));
+
+	IP_VS_DBG_V6(cp->af, 7, "Bind-dest %s c:" NIP6_FMT ":%d v:" NIP6_FMT ":%d "
+		     "d:" NIP6_FMT ":%d fwd:%c s:%u conn->flags:%X conn->refcnt:%d "
+		     "dest->refcnt:%d\n",
+		     ip_vs_proto_name(cp->protocol),
+		     NIP6(cp->caddr.v6), ntohs(cp->cport),
+		     NIP6(cp->vaddr.v6), ntohs(cp->vport),
+		     NIP6(cp->daddr.v6), ntohs(cp->dport),
+		     ip_vs_fwd_tag(cp), cp->state,
+		     cp->flags, atomic_read(&cp->refcnt),
+		     atomic_read(&dest->refcnt));
 
 	/* Update the connection counters */
 	if (!(cp->flags & IP_VS_CONN_F_TEMPLATE)) {
@@ -469,16 +480,27 @@ static inline void ip_vs_unbind_dest(struct ip_vs_conn *cp)
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
+	IP_VS_DBG_V4(cp->af, 7, "Unbind-dest %s c:%u.%u.%u.%u:%d v:%u.%u.%u.%u:%d "
+		     "d:%u.%u.%u.%u:%d fwd:%c s:%u conn->flags:%X conn->refcnt:%d "
+		     "dest->refcnt:%d\n",
+		     ip_vs_proto_name(cp->protocol),
+		     NIPQUAD(cp->caddr.v4), ntohs(cp->cport),
+		     NIPQUAD(cp->vaddr.v4), ntohs(cp->vport),
+		     NIPQUAD(cp->daddr.v4), ntohs(cp->dport),
+		     ip_vs_fwd_tag(cp), cp->state,
+		     cp->flags, atomic_read(&cp->refcnt),
+		     atomic_read(&dest->refcnt));
+
+	IP_VS_DBG_V6(cp->af, 7, "Unbind-dest %s c:" NIP6_FMT ":%d v:" NIP6_FMT ":%d "
+		     "d:" NIP6_FMT ":%d fwd:%c s:%u conn->flags:%X conn->refcnt:%d "
+		     "dest->refcnt:%d\n",
+		     ip_vs_proto_name(cp->protocol),
+		     NIP6(cp->caddr.v6), ntohs(cp->cport),
+		     NIP6(cp->vaddr.v6), ntohs(cp->vport),
+		     NIP6(cp->daddr.v6), ntohs(cp->dport),
+		     ip_vs_fwd_tag(cp), cp->state,
+		     cp->flags, atomic_read(&cp->refcnt),
+		     atomic_read(&dest->refcnt));
 
 	/* Update the connection counters */
 	if (!(cp->flags & IP_VS_CONN_F_TEMPLATE)) {
@@ -530,14 +552,22 @@ int ip_vs_check_template(struct ip_vs_conn *ct)
 	if ((dest == NULL) ||
 	    !(dest->flags & IP_VS_DEST_F_AVAILABLE) ||
 	    (sysctl_ip_vs_expire_quiescent_template &&
-	     (atomic_read(&dest->weight) == 0))) {
-		IP_VS_DBG(9, "check_template: dest not available for "
-			  "protocol %s s:%u.%u.%u.%u:%d v:%u.%u.%u.%u:%d "
-			  "-> d:%u.%u.%u.%u:%d\n",
-			  ip_vs_proto_name(ct->protocol),
-			  NIPQUAD(ct->caddr), ntohs(ct->cport),
-			  NIPQUAD(ct->vaddr), ntohs(ct->vport),
-			  NIPQUAD(ct->daddr), ntohs(ct->dport));
+	    (atomic_read(&dest->weight) == 0))) {
+		IP_VS_DBG_V4(ct->af, 9, "check_template: dest not available for "
+			     "protocol %s s:%u.%u.%u.%u:%d v:%u.%u.%u.%u:%d "
+			     "-> d:%u.%u.%u.%u:%d\n",
+			     ip_vs_proto_name(ct->protocol),
+			     NIPQUAD(ct->caddr.v4), ntohs(ct->cport),
+			     NIPQUAD(ct->vaddr.v4), ntohs(ct->vport),
+			     NIPQUAD(ct->daddr.v4), ntohs(ct->dport));
+
+		IP_VS_DBG_V6(ct->af, 9, "check_template: dest not available for "
+			     "protocol %s s:" NIP6_FMT ":%d v:" NIP6_FMT ":%d "
+			     "-> d:" NIP6_FMT ":%d\n",
+			     ip_vs_proto_name(ct->protocol),
+			     NIP6(ct->caddr.v6), ntohs(ct->cport),
+			     NIP6(ct->vaddr.v6), ntohs(ct->vport),
+			     NIP6(ct->daddr.v6), ntohs(ct->dport));
 
 		/*
 		 * Invalidate the connection template
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index dd84deb..da2e431 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -835,13 +835,22 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest)
 	 */
 	dest = ip_vs_trash_get_dest(svc, daddr, dport);
 	if (dest != NULL) {
-		IP_VS_DBG(3, "Get destination %u.%u.%u.%u:%u from trash, "
-			  "dest->refcnt=%d, service %u/%u.%u.%u.%u:%u\n",
-			  NIPQUAD(daddr), ntohs(dport),
-			  atomic_read(&dest->refcnt),
-			  dest->vfwmark,
-			  NIPQUAD(dest->vaddr),
-			  ntohs(dest->vport));
+		IP_VS_DBG_V4(svc->af, 3, "Get destination %u.%u.%u.%u:%u from trash, "
+			     "dest->refcnt=%d, service %u/%u.%u.%u.%u:%u\n",
+			     NIPQUAD(daddr.v4), ntohs(dport),
+			     atomic_read(&dest->refcnt),
+			     dest->vfwmark,
+			     NIPQUAD(dest->vaddr.v4),
+			     ntohs(dest->vport));
+
+		IP_VS_DBG_V6(svc->af, 3, "Get destination " NIP6_FMT ":%u from trash, "
+			     "dest->refcnt=%d, service %u/" NIP6_FMT ":%u\n",
+			     NIP6(daddr.v6), ntohs(dport),
+			     atomic_read(&dest->refcnt),
+			     dest->vfwmark,
+			     NIP6(dest->vaddr.v6),
+			     ntohs(dest->vport));
+
 		__ip_vs_update_dest(svc, dest, udest);
 
 		/*
@@ -981,10 +990,16 @@ static void __ip_vs_del_dest(struct ip_vs_dest *dest)
 		atomic_dec(&dest->svc->refcnt);
 		kfree(dest);
 	} else {
-		IP_VS_DBG(3, "Moving dest %u.%u.%u.%u:%u into trash, "
-			  "dest->refcnt=%d\n",
-			  NIPQUAD(dest->addr), ntohs(dest->port),
-			  atomic_read(&dest->refcnt));
+		IP_VS_DBG_V4(dest->af, 3, "Moving dest %u.%u.%u.%u:%u into trash, "
+			     "dest->refcnt=%d\n",
+			     NIPQUAD(dest->addr.v4), ntohs(dest->port),
+			     atomic_read(&dest->refcnt));
+
+		IP_VS_DBG_V6(dest->af, 3, "Moving dest " NIP6_FMT ":%u into trash, "
+			     "dest->refcnt=%d\n",
+			     NIP6(dest->addr.v6), ntohs(dest->port),
+			     atomic_read(&dest->refcnt));
+
 		list_add(&dest->n_list, &ip_vs_dest_trash);
 		atomic_inc(&dest->refcnt);
 	}
@@ -1953,9 +1968,14 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 
 	/* Check for valid protocol: TCP or UDP, even for fwmark!=0 */
 	if (usvc->protocol!=IPPROTO_TCP && usvc->protocol!=IPPROTO_UDP) {
-		IP_VS_ERR("set_ctl: invalid protocol: %d %d.%d.%d.%d:%d %s\n",
-			  usvc->protocol, NIPQUAD(usvc->addr),
-			  ntohs(usvc->port), usvc->sched_name);
+		IP_VS_ERR_V4(usvc->af, "set_ctl: invalid protocol: %d %d.%d.%d.%d:%d %s\n",
+			     usvc->protocol, NIPQUAD(usvc->addr.v4),
+			     ntohs(usvc->port), usvc->sched_name);
+
+		IP_VS_ERR_V6(usvc->af, "set_ctl: invalid protocol: %d " NIP6_FMT ":%d %s\n",
+			     usvc->protocol, NIP6(usvc->addr.v6),
+			     ntohs(usvc->port), usvc->sched_name);
+
 		ret = -EFAULT;
 		goto out_unlock;
 	}
diff --git a/net/netfilter/ipvs/ip_vs_lc.c b/net/netfilter/ipvs/ip_vs_lc.c
index d88fef9..e1214d1 100644
--- a/net/netfilter/ipvs/ip_vs_lc.c
+++ b/net/netfilter/ipvs/ip_vs_lc.c
@@ -86,11 +86,18 @@ ip_vs_lc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
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
+	IP_VS_DBG_V4(svc->af, 6, "LC: server %u.%u.%u.%u:%u activeconns %d inactconns %d\n",
+		     NIPQUAD(least->addr.v4), ntohs(least->port),
+		     atomic_read(&least->activeconns),
+		     atomic_read(&least->inactconns));
+
+	IP_VS_DBG_V6(svc->af, 6, "LC: server " NIP6_FMT ":%u activeconns %d inactconns %d\n",
+		     NIP6(least->addr.v6), ntohs(least->port),
+		     atomic_read(&least->activeconns),
+		     atomic_read(&least->inactconns));
 
 	return least;
 }
diff --git a/net/netfilter/ipvs/ip_vs_nq.c b/net/netfilter/ipvs/ip_vs_nq.c
index bc2a9e5..5de2e34 100644
--- a/net/netfilter/ipvs/ip_vs_nq.c
+++ b/net/netfilter/ipvs/ip_vs_nq.c
@@ -122,9 +122,17 @@ ip_vs_nq_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		return NULL;
 
   out:
-	IP_VS_DBG(6, "NQ: server %u.%u.%u.%u:%u "
+
+	IP_VS_DBG_V4(svc->af, 6, "NQ: server %u.%u.%u.%u:%u "
+		  "activeconns %d refcnt %d weight %d overhead %d\n",
+		  NIPQUAD(least->addr.v4), ntohs(least->port),
+		  atomic_read(&least->activeconns),
+		  atomic_read(&least->refcnt),
+		  atomic_read(&least->weight), loh);
+
+	IP_VS_DBG_V6(svc->af, 6, "NQ: server " NIP6_FMT ":%u "
 		  "activeconns %d refcnt %d weight %d overhead %d\n",
-		  NIPQUAD(least->addr), ntohs(least->port),
+		  NIP6(least->addr.v6), ntohs(least->port),
 		  atomic_read(&least->activeconns),
 		  atomic_read(&least->refcnt),
 		  atomic_read(&least->weight), loh);
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 6068c47..0efb3e4 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -421,19 +421,34 @@ set_tcp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
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
+		IP_VS_DBG_V4(cp->af, 8, "%s %s [%c%c%c%c] %u.%u.%u.%u:%d->"
+			     "%u.%u.%u.%u:%d state: %s->%s conn->refcnt:%d\n",
+			     pp->name,
+			     (state_off==TCP_DIR_OUTPUT)?"output ":"input ",
+			     th->syn? 'S' : '.',
+			     th->fin? 'F' : '.',
+			     th->ack? 'A' : '.',
+			     th->rst? 'R' : '.',
+			     NIPQUAD(cp->daddr.v4), ntohs(cp->dport),
+			     NIPQUAD(cp->caddr.v4), ntohs(cp->cport),
+			     tcp_state_name(cp->state),
+			     tcp_state_name(new_state),
+			     atomic_read(&cp->refcnt));
+
+		IP_VS_DBG_V6(cp->af, 8, "%s %s [%c%c%c%c] " NIP6_FMT ":%d->"
+			     NIP6_FMT ":%d state: %s->%s conn->refcnt:%d\n",
+			     pp->name,
+			     (state_off==TCP_DIR_OUTPUT)?"output ":"input ",
+			     th->syn? 'S' : '.',
+			     th->fin? 'F' : '.',
+			     th->ack? 'A' : '.',
+			     th->rst? 'R' : '.',
+			     NIP6(cp->daddr.v6), ntohs(cp->dport),
+			     NIP6(cp->caddr.v6), ntohs(cp->cport),
+			     tcp_state_name(cp->state),
+			     tcp_state_name(new_state),
+			     atomic_read(&cp->refcnt));
+
 		if (dest) {
 			if (!(cp->flags & IP_VS_CONN_F_INACTIVE) &&
 			    (new_state != IP_VS_TCP_S_ESTABLISHED)) {
@@ -548,12 +563,20 @@ tcp_app_conn_bind(struct ip_vs_conn *cp)
 				break;
 			spin_unlock(&tcp_app_lock);
 
-			IP_VS_DBG(9, "%s: Binding conn %u.%u.%u.%u:%u->"
-				  "%u.%u.%u.%u:%u to app %s on port %u\n",
-				  __func__,
-				  NIPQUAD(cp->caddr), ntohs(cp->cport),
-				  NIPQUAD(cp->vaddr), ntohs(cp->vport),
-				  inc->name, ntohs(inc->port));
+			IP_VS_DBG_V4(cp->af, 9, "%s: Binding conn %u.%u.%u.%u:%u->"
+				     "%u.%u.%u.%u:%u to app %s on port %u\n",
+				     __func__,
+				     NIPQUAD(cp->caddr.v4), ntohs(cp->cport),
+				     NIPQUAD(cp->vaddr.v4), ntohs(cp->vport),
+				     inc->name, ntohs(inc->port));
+
+			IP_VS_DBG_V6(cp->af, 9, "%s: Binding conn " NIP6_FMT ":%u->"
+				     NIP6_FMT ":%u to app %s on port %u\n",
+				     __func__,
+				     NIP6(cp->caddr.v6), ntohs(cp->cport),
+				     NIP6(cp->vaddr.v6), ntohs(cp->vport),
+				     inc->name, ntohs(inc->port));
+
 			cp->app = inc;
 			if (inc->init_conn)
 				result = inc->init_conn(inc, cp);
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 0bcc17a..76e97ef 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -342,12 +342,20 @@ static int udp_app_conn_bind(struct ip_vs_conn *cp)
 				break;
 			spin_unlock(&udp_app_lock);
 
-			IP_VS_DBG(9, "%s: Binding conn %u.%u.%u.%u:%u->"
-				  "%u.%u.%u.%u:%u to app %s on port %u\n",
-				  __func__,
-				  NIPQUAD(cp->caddr), ntohs(cp->cport),
-				  NIPQUAD(cp->vaddr), ntohs(cp->vport),
-				  inc->name, ntohs(inc->port));
+			IP_VS_DBG_V4(cp->af, 9, "%s: Binding conn %u.%u.%u.%u:%u->"
+				     "%u.%u.%u.%u:%u to app %s on port %u\n",
+				     __func__,
+				     NIPQUAD(cp->caddr.v4), ntohs(cp->cport),
+				     NIPQUAD(cp->vaddr.v4), ntohs(cp->vport),
+				     inc->name, ntohs(inc->port));
+
+			IP_VS_DBG_V6(cp->af, 9, "%s: Binding conn " NIP6_FMT ":%u->"
+				     NIP6_FMT ":%u to app %s on port %u\n",
+				     __func__,
+				     NIP6(cp->caddr.v6), ntohs(cp->cport),
+				     NIP6(cp->vaddr.v6), ntohs(cp->vport),
+				     inc->name, ntohs(inc->port));
+
 			cp->app = inc;
 			if (inc->init_conn)
 				result = inc->init_conn(inc, cp);
diff --git a/net/netfilter/ipvs/ip_vs_sed.c b/net/netfilter/ipvs/ip_vs_sed.c
index dd7c128..e7bc810 100644
--- a/net/netfilter/ipvs/ip_vs_sed.c
+++ b/net/netfilter/ipvs/ip_vs_sed.c
@@ -124,12 +124,19 @@ ip_vs_sed_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		}
 	}
 
-	IP_VS_DBG(6, "SED: server %u.%u.%u.%u:%u "
-		  "activeconns %d refcnt %d weight %d overhead %d\n",
-		  NIPQUAD(least->addr), ntohs(least->port),
-		  atomic_read(&least->activeconns),
-		  atomic_read(&least->refcnt),
-		  atomic_read(&least->weight), loh);
+	IP_VS_DBG_V4(svc->af, 6, "SED: server %u.%u.%u.%u:%u "
+		     "activeconns %d refcnt %d weight %d overhead %d\n",
+		     NIPQUAD(least->addr.v4), ntohs(least->port),
+		     atomic_read(&least->activeconns),
+		     atomic_read(&least->refcnt),
+		     atomic_read(&least->weight), loh);
+
+	IP_VS_DBG_V6(svc->af, 6, "SED: server " NIP6_FMT ":%u "
+		     "activeconns %d refcnt %d weight %d overhead %d\n",
+		     NIP6(least->addr.v6), ntohs(least->port),
+		     atomic_read(&least->activeconns),
+		     atomic_read(&least->refcnt),
+		     atomic_read(&least->weight), loh);
 
 	return least;
 }
diff --git a/net/netfilter/ipvs/ip_vs_wlc.c b/net/netfilter/ipvs/ip_vs_wlc.c
index 8a9d913..ff003a7 100644
--- a/net/netfilter/ipvs/ip_vs_wlc.c
+++ b/net/netfilter/ipvs/ip_vs_wlc.c
@@ -112,12 +112,19 @@ ip_vs_wlc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		}
 	}
 
-	IP_VS_DBG(6, "WLC: server %u.%u.%u.%u:%u "
-		  "activeconns %d refcnt %d weight %d overhead %d\n",
-		  NIPQUAD(least->addr), ntohs(least->port),
-		  atomic_read(&least->activeconns),
-		  atomic_read(&least->refcnt),
-		  atomic_read(&least->weight), loh);
+	IP_VS_DBG_V4(svc->af, 6, "WLC: server %u.%u.%u.%u:%u "
+		     "activeconns %d refcnt %d weight %d overhead %d\n",
+		     NIPQUAD(least->addr.v4), ntohs(least->port),
+		     atomic_read(&least->activeconns),
+		     atomic_read(&least->refcnt),
+		     atomic_read(&least->weight), loh);
+
+	IP_VS_DBG_V6(svc->af, 6, "WLC: server " NIP6_FMT ":%u "
+		     "activeconns %d refcnt %d weight %d overhead %d\n",
+		     NIP6(least->addr.v6), ntohs(least->port),
+		     atomic_read(&least->activeconns),
+		     atomic_read(&least->refcnt),
+		     atomic_read(&least->weight), loh);
 
 	return least;
 }
diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wrr.c
index 85c680a..3f61ab2 100644
--- a/net/netfilter/ipvs/ip_vs_wrr.c
+++ b/net/netfilter/ipvs/ip_vs_wrr.c
@@ -197,12 +197,19 @@ ip_vs_wrr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		}
 	}
 
-	IP_VS_DBG(6, "WRR: server %u.%u.%u.%u:%u "
-		  "activeconns %d refcnt %d weight %d\n",
-		  NIPQUAD(dest->addr), ntohs(dest->port),
-		  atomic_read(&dest->activeconns),
-		  atomic_read(&dest->refcnt),
-		  atomic_read(&dest->weight));
+	IP_VS_DBG_V4(svc->af, 6, "WRR: server %u.%u.%u.%u:%u "
+		     "activeconns %d refcnt %d weight %d\n",
+		     NIPQUAD(dest->addr.v4), ntohs(dest->port),
+		     atomic_read(&dest->activeconns),
+		     atomic_read(&dest->refcnt),
+		     atomic_read(&dest->weight));
+
+	IP_VS_DBG_V6(svc->af, 6, "WRR: server " NIP6_FMT ":%u "
+		     "activeconns %d refcnt %d weight %d\n",
+		     NIP6(dest->addr.v6), ntohs(dest->port),
+		     atomic_read(&dest->activeconns),
+		     atomic_read(&dest->refcnt),
+		     atomic_read(&dest->weight));
 
   out:
 	write_unlock(&svc->sched_lock);
-- 
1.5.3.6

