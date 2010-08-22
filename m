From: Simon Horman <horms@verge.net.au>
Subject: [patch v1 07/12] IPVS: Add struct ip_vs_pe
Date: Sun, 22 Aug 2010 21:45:04 +0900
Message-ID: <20100822124859.084116079@vergenet.net>
References: <20100822124457.339517323@vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=pe-struct.patch
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

Signed-off-by: Simon Horman <horms@verge.net.au>

--- 

This the first of several patches to add persistence engines.

Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_conn.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_conn.c	2010-07-26 07:31:06.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_conn.c	2010-07-26 16:39:45.000000000 +0900
@@ -148,6 +148,29 @@ static unsigned int ip_vs_conn_hashkey(i
 		& ip_vs_conn_tab_mask;
 }
 
+static unsigned int ip_vs_conn_hashkey_param(const struct ip_vs_conn_param *p)
+{
+	if (p->pe && p->pe->hashkey_raw)
+		return p->pe->hashkey_raw(p, ip_vs_conn_rnd) &
+			ip_vs_conn_tab_mask;
+	return ip_vs_conn_hashkey(p->af, p->protocol, p->caddr, p->cport);
+}
+
+static unsigned int ip_vs_conn_hashkey_conn(const struct ip_vs_conn *cp)
+{
+	struct ip_vs_conn_param p;
+
+	ip_vs_conn_fill_param(cp->af, cp->protocol, &cp->caddr, cp->cport,
+			      NULL, 0, &p);
+
+	if (cp->dest->svc->pe) {
+		p.pe = cp->dest->svc->pe;
+		p.pe_data = cp->pe_data;
+		p.pe_data_len = cp->pe_data_len;
+	}
+
+	return ip_vs_conn_hashkey_param(&p);
+}
 
 /*
  *	Hashes ip_vs_conn in ip_vs_conn_tab by proto,addr,port.
@@ -162,7 +185,7 @@ static inline int ip_vs_conn_hash(struct
 		return 0;
 
 	/* Hash by protocol, client address and port */
-	hash = ip_vs_conn_hashkey(cp->af, cp->protocol, &cp->caddr, cp->cport);
+	hash = ip_vs_conn_hashkey_conn(cp);
 
 	ct_write_lock(hash);
 	spin_lock(&cp->lock);
@@ -195,7 +218,7 @@ static inline int ip_vs_conn_unhash(stru
 	int ret;
 
 	/* unhash it and decrease its reference counter */
-	hash = ip_vs_conn_hashkey(cp->af, cp->protocol, &cp->caddr, cp->cport);
+	hash = ip_vs_conn_hashkey_conn(cp);
 
 	ct_write_lock(hash);
 	spin_lock(&cp->lock);
@@ -227,7 +250,7 @@ __ip_vs_conn_in_get(const struct ip_vs_c
 	unsigned hash;
 	struct ip_vs_conn *cp;
 
-	hash = ip_vs_conn_hashkey(p->af, p->protocol, p->caddr, p->cport);
+	hash = ip_vs_conn_hashkey_param(p);
 
 	ct_read_lock(hash);
 
@@ -312,11 +335,17 @@ struct ip_vs_conn *ip_vs_ct_in_get(const
 	unsigned hash;
 	struct ip_vs_conn *cp;
 
-	hash = ip_vs_conn_hashkey(p->af, p->protocol, p->caddr, p->cport);
+	hash = ip_vs_conn_hashkey_param(p);
 
 	ct_read_lock(hash);
 
 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
+		if (p->pe && p->pe->ct_match) {
+			if (p->pe->ct_match(p, cp))
+				goto out;
+			continue;
+		}
+
 		if (cp->af == p->af &&
 		    ip_vs_addr_equal(p->af, p->caddr, &cp->caddr) &&
 		    /* protocol should only be IPPROTO_IP if
@@ -325,15 +354,14 @@ struct ip_vs_conn *ip_vs_ct_in_get(const
 				     p->af, p->vaddr, &cp->vaddr) &&
 		    p->cport == cp->cport && p->vport == cp->vport &&
 		    cp->flags & IP_VS_CONN_F_TEMPLATE &&
-		    p->protocol == cp->protocol) {
-			/* HIT */
-			atomic_inc(&cp->refcnt);
+		    p->protocol == cp->protocol)
 			goto out;
-		}
 	}
 	cp = NULL;
 
   out:
+	if (cp)
+		atomic_inc(&cp->refcnt);
 	ct_read_unlock(hash);
 
 	IP_VS_DBG_BUF(9, "template lookup/in %s %s:%d->%s:%d %s\n",
@@ -359,7 +387,7 @@ struct ip_vs_conn *ip_vs_conn_out_get(co
 	/*
 	 *	Check for "full" addressed entries
 	 */
-	hash = ip_vs_conn_hashkey(p->af, p->protocol, p->vaddr, p->vport);
+	hash = ip_vs_conn_hashkey_param(p);
 
 	ct_read_lock(hash);
 
@@ -777,6 +805,10 @@ ip_vs_conn_new(const struct ip_vs_conn_p
 			&cp->daddr, daddr);
 	cp->dport          = dport;
 	cp->flags	   = flags;
+	if (p->pe_data) {
+		cp->pe_data = p->pe_data;
+		cp->pe_data_len = p->pe_data_len;
+	}
 	spin_lock_init(&cp->lock);
 
 	/*
@@ -817,7 +849,6 @@ ip_vs_conn_new(const struct ip_vs_conn_p
 	return cp;
 }
 
-
 /*
  *	/proc/net/ip_vs_conn entries
  */
@@ -833,7 +864,7 @@ static void *ip_vs_conn_array(struct seq
 		list_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
 			if (pos-- == 0) {
 				seq->private = &ip_vs_conn_tab[idx];
-				return cp;
+			return cp;
 			}
 		}
 		ct_read_unlock_bh(idx);
Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_core.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_core.c	2010-07-26 07:31:07.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_core.c	2010-07-26 16:39:38.000000000 +0900
@@ -175,6 +175,19 @@ ip_vs_set_state(struct ip_vs_conn *cp, i
 	return pp->state_transition(cp, direction, skb, pp);
 }
 
+static inline int
+ip_vs_conn_fill_param_persist(const struct ip_vs_service *svc,
+			      struct sk_buff *skb, int protocol,
+			      const union nf_inet_addr *caddr, __be16 cport,
+			      const union nf_inet_addr *vaddr, __be16 vport,
+			      struct ip_vs_conn_param *p)
+{
+	ip_vs_conn_fill_param(svc->af, protocol, caddr, cport, vaddr, vport, p);
+	p->pe = svc->pe;
+	if (p->pe && p->pe->fill_param)
+		return p->pe->fill_param(p, skb);
+	return 0;
+}
 
 /*
  *  IPVS persistent scheduling function
@@ -185,7 +198,7 @@ ip_vs_set_state(struct ip_vs_conn *cp, i
  */
 static struct ip_vs_conn *
 ip_vs_sched_persist(struct ip_vs_service *svc,
-		    const struct sk_buff *skb,
+		    struct sk_buff *skb,
 		    __be16 ports[2])
 {
 	struct ip_vs_conn *cp = NULL;
@@ -254,8 +267,9 @@ ip_vs_sched_persist(struct ip_vs_service
 				vaddr = &fwmark;
 			}
 		}
-		ip_vs_conn_fill_param(svc->af, protocol, &snet, 0,
-				      vaddr, vport, &param);
+		if (ip_vs_conn_fill_param_persist(svc, skb, protocol, &snet, 0,
+						  vaddr, vport, &param))
+			return NULL;
 	}
 
 	/* Check if a template already exists */
@@ -316,7 +330,7 @@ ip_vs_sched_persist(struct ip_vs_service
  *  Protocols supported: TCP, UDP
  */
 struct ip_vs_conn *
-ip_vs_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
+ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb)
 {
 	struct ip_vs_conn *cp = NULL;
 	struct ip_vs_iphdr iph;
Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_sync.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_sync.c	2010-07-26 07:31:06.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_sync.c	2010-07-26 07:31:15.000000000 +0900
@@ -288,6 +288,16 @@ void ip_vs_sync_conn(struct ip_vs_conn *
 		ip_vs_sync_conn(cp->control);
 }
 
+static inline int
+ip_vs_conn_fill_param_sync(int af, int protocol,
+			   const union nf_inet_addr *caddr, __be16 cport,
+			   const union nf_inet_addr *vaddr, __be16 vport,
+			   struct ip_vs_conn_param *p)
+{
+	/* XXX: Need to take into account persistence engine */
+	ip_vs_conn_fill_param(af, protocol, caddr, cport, vaddr, vport, p);
+	return 0;
+}
 
 /*
  *      Process received multicast message and create the corresponding
@@ -372,11 +382,14 @@ static void ip_vs_process_message(const
 		}
 
 		{
-			ip_vs_conn_fill_param(AF_INET, s->protocol,
+			if (ip_vs_conn_fill_param_sync(AF_INET, s->protocol,
 					      (union nf_inet_addr *)&s->caddr,
 					      s->cport,
 					      (union nf_inet_addr *)&s->vaddr,
-					      s->vport, &param);
+					      s->vport, &param)) {
+				pr_err("ip_vs_conn_fill_param_sync failed");
+				return;
+			}
 			if (!(flags & IP_VS_CONN_F_TEMPLATE))
 				cp = ip_vs_conn_in_get(&param);
 			else
Index: nf-next-2.6/include/net/ip_vs.h
===================================================================
--- nf-next-2.6.orig/include/net/ip_vs.h	2010-07-26 07:31:07.000000000 +0900
+++ nf-next-2.6/include/net/ip_vs.h	2010-07-26 16:39:45.000000000 +0900
@@ -362,6 +362,10 @@ struct ip_vs_conn_param {
 	__be16				vport;
 	__u16				protocol;
 	u16				af;
+
+	const struct ip_vs_pe		*pe;
+	char				*pe_data;
+	__u8				pe_data_len;
 };
 
 /*
@@ -414,6 +418,9 @@ struct ip_vs_conn {
 	void                    *app_data;      /* Application private data */
 	struct ip_vs_seq        in_seq;         /* incoming seq. struct */
 	struct ip_vs_seq        out_seq;        /* outgoing seq. struct */
+
+	char			*pe_data;
+	__u8			pe_data_len;
 };
 
 
@@ -484,6 +491,9 @@ struct ip_vs_service {
 	struct ip_vs_scheduler	*scheduler;    /* bound scheduler object */
 	rwlock_t		sched_lock;    /* lock sched_data */
 	void			*sched_data;   /* scheduler application data */
+
+	/* alternate persistence engine */
+	struct ip_vs_pe		*pe;
 };
 
 
@@ -547,6 +557,19 @@ struct ip_vs_scheduler {
 				       const struct sk_buff *skb);
 };
 
+/* The persistence engine object */
+struct ip_vs_pe {
+	struct list_head	n_list;		/* d-linked list head */
+	char			*name;		/* scheduler name */
+	atomic_t		refcnt;		/* reference counter */
+	struct module		*module;	/* THIS_MODULE/NULL */
+
+	/* get the connection template, if any */
+	int (*fill_param)(struct ip_vs_conn_param *p, struct sk_buff *skb);
+	bool (*ct_match)(const struct ip_vs_conn_param *p,
+			 struct ip_vs_conn *ct);
+	u32 (*hashkey_raw)(const struct ip_vs_conn_param *p, u32 initval);
+};
 
 /*
  *	The application module object (a.k.a. app incarnation)
@@ -646,6 +669,8 @@ static inline void ip_vs_conn_fill_param
 	p->cport = cport;
 	p->vaddr = vaddr;
 	p->vport = vport;
+	p->pe = NULL;
+	p->pe_data = NULL;
 }
 
 struct ip_vs_conn *ip_vs_conn_in_get(const struct ip_vs_conn_param *p);
@@ -801,7 +826,7 @@ extern int ip_vs_unbind_scheduler(struct
 extern struct ip_vs_scheduler *ip_vs_scheduler_get(const char *sched_name);
 extern void ip_vs_scheduler_put(struct ip_vs_scheduler *scheduler);
 extern struct ip_vs_conn *
-ip_vs_schedule(struct ip_vs_service *svc, const struct sk_buff *skb);
+ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb);
 extern int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 			struct ip_vs_protocol *pp);
 
Index: nf-next-2.6/include/linux/ip_vs.h
===================================================================
--- nf-next-2.6.orig/include/linux/ip_vs.h	2010-07-26 07:32:01.000000000 +0900
+++ nf-next-2.6/include/linux/ip_vs.h	2010-07-26 16:39:38.000000000 +0900
@@ -89,8 +89,10 @@
 #define IP_VS_CONN_F_ONE_PACKET	0x2000		/* forward only one packet */
 
 #define IP_VS_SCHEDNAME_MAXLEN	16
+#define IP_VS_PENAME_MAXLEN	16
 #define IP_VS_IFNAME_MAXLEN	16
 
+#define IP_VS_PEDATA_MAXLEN     255
 
 /*
  *	The struct ip_vs_service_user and struct ip_vs_dest_user are

