From: Julius Volz <juliusv@google.com>
Subject: [PATCHv2 RFC 22/25] IPVS: Adjust various debug outputs to use new macros
Date: Mon,  1 Sep 2008 14:56:19 +0200
Message-ID: <1220273782-19901-23-git-send-email-juliusv@google.com>
References: <1220273782-19901-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220273825; bh=bOcRyQ/3ZKCkyHRZZGNv+u0x0hg=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=ZqUeCTT7rUE4CkVHKdggBDuZcbKB3/dJw+/Q0t5f
	uhStpbUCzcHGgLufL8PcD8urGq6YZL+Ww2F5OG/Cje4emg==
In-Reply-To: <1220273782-19901-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Adjust various debug outputs to use the new *_BUF macro variants for
correct output of v4/v6 addresses.

Signed-off-by: Julius Volz <juliusv@google.com>

 5 files changed, 110 insertions(+), 83 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index c163c18..fbead05 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -680,24 +680,32 @@ static inline void ip_vs_control_del(struct ip_vs_conn *cp)
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
@@ -707,17 +715,22 @@ static inline void
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
diff --git a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
index 7f33171..ffd2fd5 100644
--- a/net/ipv4/ipvs/ip_vs_conn.c
+++ b/net/ipv4/ipvs/ip_vs_conn.c
@@ -448,16 +448,16 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 		cp->flags |= atomic_read(&dest->conn_flags);
 	cp->dest = dest;
 
-	IP_VS_DBG(7, "Bind-dest %s c:%u.%u.%u.%u:%d v:%u.%u.%u.%u:%d "
-		  "d:%u.%u.%u.%u:%d fwd:%c s:%u conn->flags:%X conn->refcnt:%d "
-		  "dest->refcnt:%d\n",
-		  ip_vs_proto_name(cp->protocol),
-		  NIPQUAD(cp->caddr.ip), ntohs(cp->cport),
-		  NIPQUAD(cp->vaddr.ip), ntohs(cp->vport),
-		  NIPQUAD(cp->daddr.ip), ntohs(cp->dport),
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
@@ -511,16 +511,16 @@ static inline void ip_vs_unbind_dest(struct ip_vs_conn *cp)
 	if (!dest)
 		return;
 
-	IP_VS_DBG(7, "Unbind-dest %s c:%u.%u.%u.%u:%d v:%u.%u.%u.%u:%d "
-		  "d:%u.%u.%u.%u:%d fwd:%c s:%u conn->flags:%X conn->refcnt:%d "
-		  "dest->refcnt:%d\n",
-		  ip_vs_proto_name(cp->protocol),
-		  NIPQUAD(cp->caddr.ip), ntohs(cp->cport),
-		  NIPQUAD(cp->vaddr.ip), ntohs(cp->vport),
-		  NIPQUAD(cp->daddr.ip), ntohs(cp->dport),
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
@@ -573,13 +573,16 @@ int ip_vs_check_template(struct ip_vs_conn *ct)
 	    !(dest->flags & IP_VS_DEST_F_AVAILABLE) ||
 	    (sysctl_ip_vs_expire_quiescent_template &&
 	     (atomic_read(&dest->weight) == 0))) {
-		IP_VS_DBG(9, "check_template: dest not available for "
-			  "protocol %s s:%u.%u.%u.%u:%d v:%u.%u.%u.%u:%d "
-			  "-> d:%u.%u.%u.%u:%d\n",
-			  ip_vs_proto_name(ct->protocol),
-			  NIPQUAD(ct->caddr.ip), ntohs(ct->cport),
-			  NIPQUAD(ct->vaddr.ip), ntohs(ct->vport),
-			  NIPQUAD(ct->daddr.ip), ntohs(ct->dport));
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
diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index 3ce2873..e5873c6 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -920,13 +920,14 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	dest = ip_vs_trash_get_dest(svc, &daddr, dport);
 
 	if (dest != NULL) {
-		IP_VS_DBG(3, "Get destination %u.%u.%u.%u:%u from trash, "
-			  "dest->refcnt=%d, service %u/%u.%u.%u.%u:%u\n",
-			  NIPQUAD(daddr), ntohs(dport),
-			  atomic_read(&dest->refcnt),
-			  dest->vfwmark,
-			  NIPQUAD(dest->vaddr.ip),
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
@@ -1072,10 +1073,11 @@ static void __ip_vs_del_dest(struct ip_vs_dest *dest)
 		atomic_dec(&dest->svc->refcnt);
 		kfree(dest);
 	} else {
-		IP_VS_DBG(3, "Moving dest %u.%u.%u.%u:%u into trash, "
-			  "dest->refcnt=%d\n",
-			  NIPQUAD(dest->addr.ip), ntohs(dest->port),
-			  atomic_read(&dest->refcnt));
+		IP_VS_DBG_BUF(3, "Moving dest %s:%u into trash, "
+			      "dest->refcnt=%d\n",
+			      IP_VS_DBG_ADDR(dest->af, &dest->addr),
+			      ntohs(dest->port),
+			      atomic_read(&dest->refcnt));
 		list_add(&dest->n_list, &ip_vs_dest_trash);
 		atomic_inc(&dest->refcnt);
 	}
diff --git a/net/ipv4/ipvs/ip_vs_proto_tcp.c b/net/ipv4/ipvs/ip_vs_proto_tcp.c
index 3da2bb0..32c0706 100644
--- a/net/ipv4/ipvs/ip_vs_proto_tcp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_tcp.c
@@ -490,19 +490,22 @@ set_tcp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
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
-			  NIPQUAD(cp->daddr.ip), ntohs(cp->dport),
-			  NIPQUAD(cp->caddr.ip), ntohs(cp->cport),
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
@@ -623,12 +626,15 @@ tcp_app_conn_bind(struct ip_vs_conn *cp)
 				break;
 			spin_unlock(&tcp_app_lock);
 
-			IP_VS_DBG(9, "%s: Binding conn %u.%u.%u.%u:%u->"
-				  "%u.%u.%u.%u:%u to app %s on port %u\n",
-				  __func__,
-				  NIPQUAD(cp->caddr.ip), ntohs(cp->cport),
-				  NIPQUAD(cp->vaddr.ip), ntohs(cp->vport),
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
index 0b0b625..9b9f3b3 100644
--- a/net/ipv4/ipvs/ip_vs_proto_udp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_udp.c
@@ -407,12 +407,15 @@ static int udp_app_conn_bind(struct ip_vs_conn *cp)
 				break;
 			spin_unlock(&udp_app_lock);
 
-			IP_VS_DBG(9, "%s: Binding conn %u.%u.%u.%u:%u->"
-				  "%u.%u.%u.%u:%u to app %s on port %u\n",
-				  __func__,
-				  NIPQUAD(cp->caddr.ip), ntohs(cp->cport),
-				  NIPQUAD(cp->vaddr.ip), ntohs(cp->vport),
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
-- 
1.5.4.5

