From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 1/8] IPVS: Backup, Prepare for transferring firewall marks (fwmark) to the backup daemon.
Date: Thu, 25 Nov 2010 10:46:51 +0900
Message-ID: <1290649618-18955-2-git-send-email-horms@verge.net.au>
References: <1290649618-18955-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <1290649618-18955-1-git-send-email-horms@verge.net.au>
Sender: netfilter-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

One struct will have fwmark added:
 * ip_vs_conn

ip_vs_conn_new() and ip_vs_find_dest()
will have an extra param - fwmark
The effects of that, is in this patch.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             |    6 ++++--
 net/netfilter/ipvs/ip_vs_conn.c |    5 +++--
 net/netfilter/ipvs/ip_vs_core.c |    8 ++++----
 net/netfilter/ipvs/ip_vs_ctl.c  |    4 ++--
 net/netfilter/ipvs/ip_vs_ftp.c  |    5 +++--
 net/netfilter/ipvs/ip_vs_sync.c |    4 ++--
 6 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index d5a32e4..890f01c 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -382,6 +382,7 @@ struct ip_vs_conn {
 	union nf_inet_addr       vaddr;          /* virtual address */
 	union nf_inet_addr       daddr;          /* destination address */
 	volatile __u32           flags;          /* status flags */
+	__u32                    fwmark;         /* Fire wall mark from skb */
 	__be16                   cport;
 	__be16                   vport;
 	__be16                   dport;
@@ -720,7 +721,7 @@ extern void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport);
 struct ip_vs_conn *ip_vs_conn_new(const struct ip_vs_conn_param *p,
 				  const union nf_inet_addr *daddr,
 				  __be16 dport, unsigned flags,
-				  struct ip_vs_dest *dest);
+				  struct ip_vs_dest *dest, __u32 fwmark);
 extern void ip_vs_conn_expire_now(struct ip_vs_conn *cp);
 
 extern const char * ip_vs_state_name(__u16 proto, int state);
@@ -901,7 +902,8 @@ extern int ip_vs_control_init(void);
 extern void ip_vs_control_cleanup(void);
 extern struct ip_vs_dest *
 ip_vs_find_dest(int af, const union nf_inet_addr *daddr, __be16 dport,
-		const union nf_inet_addr *vaddr, __be16 vport, __u16 protocol);
+		const union nf_inet_addr *vaddr, __be16 vport, __u16 protocol,
+		__u32 fwmark);
 extern struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp);
 
 
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 7615f9e..66e4662 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -613,7 +613,7 @@ struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp)
 	if ((cp) && (!cp->dest)) {
 		dest = ip_vs_find_dest(cp->af, &cp->daddr, cp->dport,
 				       &cp->vaddr, cp->vport,
-				       cp->protocol);
+				       cp->protocol, cp->fwmark);
 		ip_vs_bind_dest(cp, dest);
 		return dest;
 	} else
@@ -803,7 +803,7 @@ void ip_vs_conn_expire_now(struct ip_vs_conn *cp)
 struct ip_vs_conn *
 ip_vs_conn_new(const struct ip_vs_conn_param *p,
 	       const union nf_inet_addr *daddr, __be16 dport, unsigned flags,
-	       struct ip_vs_dest *dest)
+	       struct ip_vs_dest *dest, __u32 fwmark)
 {
 	struct ip_vs_conn *cp;
 	struct ip_vs_protocol *pp = ip_vs_proto_get(p->protocol);
@@ -827,6 +827,7 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
 			&cp->daddr, daddr);
 	cp->dport          = dport;
 	cp->flags	   = flags;
+	cp->fwmark         = fwmark;
 	if (flags & IP_VS_CONN_F_TEMPLATE && p->pe) {
 		ip_vs_pe_get(p->pe);
 		cp->pe = p->pe;
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index b4e51e9..e2bb3cd 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -293,7 +293,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 		 * and thus param.pe_data will be destroyed
 		 * when the template expires */
 		ct = ip_vs_conn_new(&param, &dest->addr, dport,
-				    IP_VS_CONN_F_TEMPLATE, dest);
+				    IP_VS_CONN_F_TEMPLATE, dest, skb->mark);
 		if (ct == NULL) {
 			kfree(param.pe_data);
 			return NULL;
@@ -319,7 +319,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	 */
 	ip_vs_conn_fill_param(svc->af, iph.protocol, &iph.saddr, ports[0],
 			      &iph.daddr, ports[1], &param);
-	cp = ip_vs_conn_new(&param, &dest->addr, dport, flags, dest);
+	cp = ip_vs_conn_new(&param, &dest->addr, dport, flags, dest, skb->mark);
 	if (cp == NULL) {
 		ip_vs_conn_put(ct);
 		return NULL;
@@ -423,7 +423,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 				      pptr[0], &iph.daddr, pptr[1], &p);
 		cp = ip_vs_conn_new(&p, &dest->addr,
 				    dest->port ? dest->port : pptr[1],
-				    flags, dest);
+				    flags, dest, skb->mark);
 		if (!cp)
 			return NULL;
 	}
@@ -489,7 +489,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 					      &iph.daddr, pptr[1], &p);
 			cp = ip_vs_conn_new(&p, &daddr, 0,
 					    IP_VS_CONN_F_BYPASS | flags,
-					    NULL);
+					    NULL, skb->mark);
 			if (!cp)
 				return NF_DROP;
 		}
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 3e92558..a5bd002 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -657,12 +657,12 @@ ip_vs_lookup_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
 struct ip_vs_dest *ip_vs_find_dest(int af, const union nf_inet_addr *daddr,
 				   __be16 dport,
 				   const union nf_inet_addr *vaddr,
-				   __be16 vport, __u16 protocol)
+				   __be16 vport, __u16 protocol, __u32 fwmark)
 {
 	struct ip_vs_dest *dest;
 	struct ip_vs_service *svc;
 
-	svc = ip_vs_service_get(af, 0, protocol, vaddr, vport);
+	svc = ip_vs_service_get(af, fwmark, protocol, vaddr, vport);
 	if (!svc)
 		return NULL;
 	dest = ip_vs_lookup_dest(svc, daddr, dport);
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 7545500..84aef65 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -208,7 +208,7 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 			n_cp = ip_vs_conn_new(&p, &from, port,
 					      IP_VS_CONN_F_NO_CPORT |
 					      IP_VS_CONN_F_NFCT,
-					      cp->dest);
+					      cp->dest, skb->mark);
 			if (!n_cp)
 				return 0;
 
@@ -365,7 +365,8 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		if (!n_cp) {
 			n_cp = ip_vs_conn_new(&p, &cp->daddr,
 					      htons(ntohs(cp->dport)-1),
-					      IP_VS_CONN_F_NFCT, cp->dest);
+					      IP_VS_CONN_F_NFCT, cp->dest,
+					      skb->mark);
 			if (!n_cp)
 				return 0;
 
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 3897d6b..47eed67 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -404,7 +404,7 @@ static void ip_vs_process_message(char *buffer, const size_t buflen)
 					       s->dport,
 					       (union nf_inet_addr *)&s->vaddr,
 					       s->vport,
-					       s->protocol);
+					       s->protocol, 0);
 			/*  Set the approprite ativity flag */
 			if (s->protocol == IPPROTO_TCP) {
 				if (state != IP_VS_TCP_S_ESTABLISHED)
@@ -419,7 +419,7 @@ static void ip_vs_process_message(char *buffer, const size_t buflen)
 			}
 			cp = ip_vs_conn_new(&param,
 					    (union nf_inet_addr *)&s->daddr,
-					    s->dport, flags, dest);
+					    s->dport, flags, dest, 0);
 			if (dest)
 				atomic_dec(&dest->refcnt);
 			if (!cp) {
-- 
1.7.2.3

