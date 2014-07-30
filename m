From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs 4/7] ipvs: Supply destination address family to ip_vs_conn_new
Date: Tue, 29 Jul 2014 21:10:52 -0700
Message-ID: <1406693455-915-5-git-send-email-agartrell@fb.com>
References: <1406693455-915-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=BvZrrWDJEBUlwrXwAIK6JAigg4+Y7uUpWisMbfCLTRc=;
 b=OCBOl21yCcsOGxNabvWlWLf26AR/PSbBnR3GdONINpsOPK1o8J+PzeF8cJu0H2B/rQc+
 srU0P3ZOFiH10ByxwZeendMkZ686la+L5n7IPytnlQ8i/TMDhNgD92SFG3rH2VmcAXO/
 lL8cTd2Sk/pnGY6yUO/R3D2LVzzVAdsECUM= 
In-Reply-To: <1406693455-915-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, agartrell@fb.com, kernel-team@fb.com

The assumption that dest af is equal to service af is now unreliable, so we
must specify it manually so as not to copy just the first 4 bytes of a v6
address or doing an illegal read of 16 butes on a v6 address.

We "lie" in two places: for synchronization (which we will explicitly
disallow from happening when we have heterogeneous pools) and for black
hole addresses where there's no real dest.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 include/net/ip_vs.h             | 2 +-
 net/netfilter/ipvs/ip_vs_conn.c | 4 ++--
 net/netfilter/ipvs/ip_vs_core.c | 9 +++++----
 net/netfilter/ipvs/ip_vs_sync.c | 3 ++-
 4 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 2fa1155..72698b1 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1213,7 +1213,7 @@ static inline void __ip_vs_conn_put(struct ip_vs_conn *cp)
 void ip_vs_conn_put(struct ip_vs_conn *cp);
 void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport);
 
-struct ip_vs_conn *ip_vs_conn_new(const struct ip_vs_conn_param *p,
+struct ip_vs_conn *ip_vs_conn_new(const struct ip_vs_conn_param *p, int dest_af,
 				  const union nf_inet_addr *daddr,
 				  __be16 dport, unsigned int flags,
 				  struct ip_vs_dest *dest, __u32 fwmark);
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 2a59564..22c72da 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -853,7 +853,7 @@ void ip_vs_conn_expire_now(struct ip_vs_conn *cp)
  *	Create a new connection entry and hash it into the ip_vs_conn_tab
  */
 struct ip_vs_conn *
-ip_vs_conn_new(const struct ip_vs_conn_param *p,
+ip_vs_conn_new(const struct ip_vs_conn_param *p, int dest_af,
 	       const union nf_inet_addr *daddr, __be16 dport, unsigned int flags,
 	       struct ip_vs_dest *dest, __u32 fwmark)
 {
@@ -879,7 +879,7 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
 	ip_vs_addr_set(p->protocol == IPPROTO_IP ? AF_UNSPEC : p->af,
 		       &cp->vaddr, p->vaddr);
 	cp->vport	   = p->vport;
-	ip_vs_addr_set(p->af, &cp->daddr, daddr);
+	ip_vs_addr_set(dest_af, &cp->daddr, daddr);
 	cp->dport          = dport;
 	cp->flags	   = flags;
 	cp->fwmark         = fwmark;
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index e683675..0cf952a 100644
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
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 392f687..9b1c936 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -888,7 +888,8 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 				       param->vaddr, param->vport, protocol,
 				       fwmark, flags);
 
-		cp = ip_vs_conn_new(param, daddr, dport, flags, dest, fwmark);
+		cp = ip_vs_conn_new(param, type, daddr, dport, flags, dest,
+				    fwmark);
 		rcu_read_unlock();
 		if (!cp) {
 			if (param->pe_data)
-- 
1.8.1

