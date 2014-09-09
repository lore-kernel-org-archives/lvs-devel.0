From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next 04/20] ipvs: Supply destination address family to ip_vs_conn_new
Date: Tue, 9 Sep 2014 16:40:23 -0700
Message-ID: <1410306039-2977-5-git-send-email-agartrell@fb.com>
References: <1410306039-2977-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=4c9/kjQrCve2NzcRDM1YWdsdoasEpDGkA+K2hvd3xKQ=;
 b=D7nZG4RRxLVODhBs7VxQoyREdwFhxJZzbXUY7iGLLz1tf19mu9GyIxLxbDZvy2ZKHoLN
 +6nTHgo9f6aUNWS8eDEwZtAKnsSJAR8otjOSRlkWW8iX65riFptdThiP5rS2OV22IkXN
 fs8oQsm08+Cw5NBxJMfe1qXtjT8V5NRalqs= 
In-Reply-To: <1410306039-2977-1-git-send-email-agartrell@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Cc: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com, ps@fb.com, Alex Gartrell <agartrell@fb.com>

The assumption that dest af is equal to service af is now unreliable, so we
must specify it manually so as not to copy just the first 4 bytes of a v6
address or doing an illegal read of 16 butes on a v6 address.

We "lie" in two places: for synchronization (which we will explicitly
disallow from happening when we have heterogeneous pools) and for black
hole addresses where there's no real dest.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 include/net/ip_vs.h             | 3 ++-
 net/netfilter/ipvs/ip_vs_conn.c | 5 +++--
 net/netfilter/ipvs/ip_vs_core.c | 9 +++++----
 net/netfilter/ipvs/ip_vs_ftp.c  | 6 ++++--
 net/netfilter/ipvs/ip_vs_sync.c | 3 ++-
 5 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 2fa1155..7600dbe 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -535,6 +535,7 @@ struct ip_vs_conn {
 	union nf_inet_addr      daddr;          /* destination address */
 	volatile __u32          flags;          /* status flags */
 	__u16                   protocol;       /* Which protocol (TCP/UDP) */
+	__u16			daf;		/* Address family of the dest */
 #ifdef CONFIG_NET_NS
 	struct net              *net;           /* Name space */
 #endif
@@ -1213,7 +1214,7 @@ static inline void __ip_vs_conn_put(struct ip_vs_conn *cp)
 void ip_vs_conn_put(struct ip_vs_conn *cp);
 void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport);
 
-struct ip_vs_conn *ip_vs_conn_new(const struct ip_vs_conn_param *p,
+struct ip_vs_conn *ip_vs_conn_new(const struct ip_vs_conn_param *p, int dest_af,
 				  const union nf_inet_addr *daddr,
 				  __be16 dport, unsigned int flags,
 				  struct ip_vs_dest *dest, __u32 fwmark);
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 8f4c602..fdb4880 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -854,7 +854,7 @@ void ip_vs_conn_expire_now(struct ip_vs_conn *cp)
  *	Create a new connection entry and hash it into the ip_vs_conn_tab
  */
 struct ip_vs_conn *
-ip_vs_conn_new(const struct ip_vs_conn_param *p,
+ip_vs_conn_new(const struct ip_vs_conn_param *p, int dest_af,
 	       const union nf_inet_addr *daddr, __be16 dport, unsigned int flags,
 	       struct ip_vs_dest *dest, __u32 fwmark)
 {
@@ -873,6 +873,7 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
 	setup_timer(&cp->timer, ip_vs_conn_expire, (unsigned long)cp);
 	ip_vs_conn_net_set(cp, p->net);
 	cp->af		   = p->af;
+	cp->daf		   = dest_af;
 	cp->protocol	   = p->protocol;
 	ip_vs_addr_set(p->af, &cp->caddr, p->caddr);
 	cp->cport	   = p->cport;
@@ -880,7 +881,7 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
 	ip_vs_addr_set(p->protocol == IPPROTO_IP ? AF_UNSPEC : p->af,
 		       &cp->vaddr, p->vaddr);
 	cp->vport	   = p->vport;
-	ip_vs_addr_set(p->af, &cp->daddr, daddr);
+	ip_vs_addr_set(cp->daf, &cp->daddr, daddr);
 	cp->dport          = dport;
 	cp->flags	   = flags;
 	cp->fwmark         = fwmark;
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 5c34e8d..1f6ecb7 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -328,7 +328,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 		 * This adds param.pe_data to the template,
 		 * and thus param.pe_data will be destroyed
 		 * when the template expires */
-		ct = ip_vs_conn_new(&param, &dest->addr, dport,
+		ct = ip_vs_conn_new(&param, dest->af, &dest->addr, dport,
 				    IP_VS_CONN_F_TEMPLATE, dest, skb->mark);
 		if (ct == NULL) {
 			kfree(param.pe_data);
@@ -357,7 +357,8 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	ip_vs_conn_fill_param(svc->net, svc->af, iph->protocol, &iph->saddr,
 			      src_port, &iph->daddr, dst_port, &param);
 
-	cp = ip_vs_conn_new(&param, &dest->addr, dport, flags, dest, skb->mark);
+	cp = ip_vs_conn_new(&param, dest->af, &dest->addr, dport, flags, dest,
+			    skb->mark);
 	if (cp == NULL) {
 		ip_vs_conn_put(ct);
 		*ignored = -1;
@@ -479,7 +480,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 		ip_vs_conn_fill_param(svc->net, svc->af, iph->protocol,
 				      &iph->saddr, pptr[0], &iph->daddr,
 				      pptr[1], &p);
-		cp = ip_vs_conn_new(&p, &dest->addr,
+		cp = ip_vs_conn_new(&p, dest->af, &dest->addr,
 				    dest->port ? dest->port : pptr[1],
 				    flags, dest, skb->mark);
 		if (!cp) {
@@ -550,7 +551,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 			ip_vs_conn_fill_param(svc->net, svc->af, iph->protocol,
 					      &iph->saddr, pptr[0],
 					      &iph->daddr, pptr[1], &p);
-			cp = ip_vs_conn_new(&p, &daddr, 0,
+			cp = ip_vs_conn_new(&p, svc->af, &daddr, 0,
 					    IP_VS_CONN_F_BYPASS | flags,
 					    NULL, skb->mark);
 			if (!cp)
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 77c1732..a64fa15 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -233,7 +233,8 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 			ip_vs_conn_fill_param(ip_vs_conn_net(cp),
 					      AF_INET, IPPROTO_TCP, &cp->caddr,
 					      0, &cp->vaddr, port, &p);
-			n_cp = ip_vs_conn_new(&p, &from, port,
+			/* As above, this is ipv4 only */
+			n_cp = ip_vs_conn_new(&p, AF_INET, &from, port,
 					      IP_VS_CONN_F_NO_CPORT |
 					      IP_VS_CONN_F_NFCT,
 					      cp->dest, skb->mark);
@@ -396,7 +397,8 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 				      htons(ntohs(cp->vport)-1), &p);
 		n_cp = ip_vs_conn_in_get(&p);
 		if (!n_cp) {
-			n_cp = ip_vs_conn_new(&p, &cp->daddr,
+			/* This is ipv4 only */
+			n_cp = ip_vs_conn_new(&p, AF_INET, &cp->daddr,
 					      htons(ntohs(cp->dport)-1),
 					      IP_VS_CONN_F_NFCT, cp->dest,
 					      skb->mark);
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index edd2664..7162c86 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -889,7 +889,8 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 				       param->vaddr, param->vport, protocol,
 				       fwmark, flags);
 
-		cp = ip_vs_conn_new(param, daddr, dport, flags, dest, fwmark);
+		cp = ip_vs_conn_new(param, type, daddr, dport, flags, dest,
+				    fwmark);
 		rcu_read_unlock();
 		if (!cp) {
 			kfree(param->pe_data);
-- 
1.8.1
