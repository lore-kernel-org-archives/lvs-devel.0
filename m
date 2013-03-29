From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 15/34] ipvs: avoid kmem_cache_zalloc in ip_vs_conn_new
Date: Fri, 29 Mar 2013 13:11:32 +0900
Message-ID: <1364530311-11512-16-git-send-email-horms@verge.net.au>
References: <1364530311-11512-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1364530311-11512-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

We have many fields to set and few to reset,
use kmem_cache_alloc instead to save some cycles.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             |   15 +++++++++++++++
 net/netfilter/ipvs/ip_vs_conn.c |   24 +++++++++++++++++++-----
 2 files changed, 34 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 929e04c..43886bb 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -233,6 +233,21 @@ static inline void ip_vs_addr_copy(int af, union nf_inet_addr *dst,
 	dst->ip = src->ip;
 }
 
+static inline void ip_vs_addr_set(int af, union nf_inet_addr *dst,
+				  const union nf_inet_addr *src)
+{
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6) {
+		dst->in6 = src->in6;
+		return;
+	}
+#endif
+	dst->ip = src->ip;
+	dst->all[1] = 0;
+	dst->all[2] = 0;
+	dst->all[3] = 0;
+}
+
 static inline int ip_vs_addr_equal(int af, const union nf_inet_addr *a,
 				   const union nf_inet_addr *b)
 {
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 416015b..e3e2b4d 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -861,7 +861,7 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
 	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(p->net,
 							   p->protocol);
 
-	cp = kmem_cache_zalloc(ip_vs_conn_cachep, GFP_ATOMIC);
+	cp = kmem_cache_alloc(ip_vs_conn_cachep, GFP_ATOMIC);
 	if (cp == NULL) {
 		IP_VS_ERR_RL("%s(): no memory\n", __func__);
 		return NULL;
@@ -872,13 +872,13 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
 	ip_vs_conn_net_set(cp, p->net);
 	cp->af		   = p->af;
 	cp->protocol	   = p->protocol;
-	ip_vs_addr_copy(p->af, &cp->caddr, p->caddr);
+	ip_vs_addr_set(p->af, &cp->caddr, p->caddr);
 	cp->cport	   = p->cport;
-	ip_vs_addr_copy(p->af, &cp->vaddr, p->vaddr);
+	ip_vs_addr_set(p->af, &cp->vaddr, p->vaddr);
 	cp->vport	   = p->vport;
 	/* proto should only be IPPROTO_IP if d_addr is a fwmark */
-	ip_vs_addr_copy(p->protocol == IPPROTO_IP ? AF_UNSPEC : p->af,
-			&cp->daddr, daddr);
+	ip_vs_addr_set(p->protocol == IPPROTO_IP ? AF_UNSPEC : p->af,
+		       &cp->daddr, daddr);
 	cp->dport          = dport;
 	cp->flags	   = flags;
 	cp->fwmark         = fwmark;
@@ -887,6 +887,10 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
 		cp->pe = p->pe;
 		cp->pe_data = p->pe_data;
 		cp->pe_data_len = p->pe_data_len;
+	} else {
+		cp->pe = NULL;
+		cp->pe_data = NULL;
+		cp->pe_data_len = 0;
 	}
 	spin_lock_init(&cp->lock);
 
@@ -897,18 +901,28 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
 	 */
 	atomic_set(&cp->refcnt, 1);
 
+	cp->control = NULL;
 	atomic_set(&cp->n_control, 0);
 	atomic_set(&cp->in_pkts, 0);
 
+	cp->packet_xmit = NULL;
+	cp->app = NULL;
+	cp->app_data = NULL;
+	/* reset struct ip_vs_seq */
+	cp->in_seq.delta = 0;
+	cp->out_seq.delta = 0;
+
 	atomic_inc(&ipvs->conn_count);
 	if (flags & IP_VS_CONN_F_NO_CPORT)
 		atomic_inc(&ip_vs_conn_no_cport_cnt);
 
 	/* Bind the connection with a destination server */
+	cp->dest = NULL;
 	ip_vs_bind_dest(cp, dest);
 
 	/* Set its state and timeout */
 	cp->state = 0;
+	cp->old_state = 0;
 	cp->timeout = 3*HZ;
 	cp->sync_endtime = jiffies & ~3UL;
 
-- 
1.7.10.4

