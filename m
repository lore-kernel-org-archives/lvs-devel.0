From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [*v2 PATCH 16/22] IPVS: netns, connection hash got net as param.
Date: Mon, 13 Dec 2010 14:38:24 +0100
Message-ID: <1292247510-753-17-git-send-email-hans.schillstrom@ericsson.com>
References: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, daniel.lezcano@free.fr, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: hans@schillstrom.com, Hans Schillstrom <hans.schillstrom@ericsson.com>

Connection hash table is now name space aware.
i.e. net ptr >> 8 is xor:ed to the hash,
and this is the first param to be compared.
The net struct is 0xa40 in size ( a little bit smaller for 32 bit arch:s)
and cache-line aligned, so a ptr >> 5 might be a more clever solution ?

All lookups where net is compared uses net_eq() which returns 1 when netns
is disabled, and the compiler seems to do something clever in that case.

ip_vs_conn_fill_param() have *net as first param now.

Three new inlines added to keep conn struct smaller
when names space is disabled.
- ip_vs_conn_net()
- ip_vs_conn_net_set()
- ip_vs_conn_net_eq()

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/net/ip_vs.h                     |   54 ++++++++---
 include/net/netns/ip_vs.h               |    2 +
 net/netfilter/ipvs/ip_vs_conn.c         |  165 ++++++++++++++++++-------------
 net/netfilter/ipvs/ip_vs_core.c         |   15 ++-
 net/netfilter/ipvs/ip_vs_ftp.c          |   14 ++-
 net/netfilter/ipvs/ip_vs_nfct.c         |    6 +-
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |   15 ++-
 net/netfilter/ipvs/ip_vs_proto_sctp.c   |    2 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |    2 +-
 net/netfilter/ipvs/ip_vs_proto_udp.c    |    2 +-
 net/netfilter/ipvs/ip_vs_sync.c         |   13 +--
 11 files changed, 177 insertions(+), 113 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 848fcda..446e417 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -105,7 +105,6 @@ static inline struct net *seq_file_single_net(struct seq_file *seq)
 #endif
 }
 
-
 /* Connections' size value needed by ip_vs_ctl.c */
 extern int ip_vs_conn_tab_size;
 
@@ -460,6 +459,7 @@ extern struct ip_vs_proto_data * ip_vs_proto_data_get(struct net *net,
 						      unsigned short proto);
 
 struct ip_vs_conn_param {
+	struct net *			net;
 	const union nf_inet_addr	*caddr;
 	const union nf_inet_addr	*vaddr;
 	__be16				cport;
@@ -477,17 +477,19 @@ struct ip_vs_conn_param {
  */
 struct ip_vs_conn {
 	struct list_head        c_list;         /* hashed list heads */
-
+#ifdef CONFIG_NET_NS
+	struct net              *net;           /* Name space */
+#endif
 	/* Protocol, addresses and port numbers */
-	u16                      af;		/* address family */
-	union nf_inet_addr       caddr;          /* client address */
-	union nf_inet_addr       vaddr;          /* virtual address */
-	union nf_inet_addr       daddr;          /* destination address */
-	volatile __u32           flags;          /* status flags */
-	__u32                    fwmark;         /* Fire wall mark from skb */
-	__be16                   cport;
-	__be16                   vport;
-	__be16                   dport;
+	u16                     af;             /* address family */
+	__be16                  cport;
+	__be16                  vport;
+	__be16                  dport;
+	__u32                   fwmark;         /* Fire wall mark from skb */
+	union nf_inet_addr      caddr;          /* client address */
+	union nf_inet_addr      vaddr;          /* virtual address */
+	union nf_inet_addr      daddr;          /* destination address */
+	volatile __u32          flags;          /* status flags */
 	__u16                   protocol;       /* Which protocol (TCP/UDP) */
 
 	/* counter and timer */
@@ -530,6 +532,33 @@ struct ip_vs_conn {
 	__u8			pe_data_len;
 };
 
+/*
+ *  To save some memory in conn table when name space is disabled.
+ */
+static inline struct net *ip_vs_conn_net(const struct ip_vs_conn *cp)
+{
+#ifdef CONFIG_NET_NS
+	return cp->net;
+#else
+	return &init_net;
+#endif
+}
+static inline void ip_vs_conn_net_set(struct ip_vs_conn *cp, struct net *net)
+{
+#ifdef CONFIG_NET_NS
+	cp->net = net;
+#endif
+}
+
+static inline int ip_vs_conn_net_eq(const struct ip_vs_conn *cp,
+				    struct net *net)
+{
+#ifdef CONFIG_NET_NS
+	return cp->net == net;
+#else
+	return 1;
+#endif
+}
 
 /*
  *	Extended internal versions of struct ip_vs_service_user and
@@ -779,13 +808,14 @@ enum {
 	IP_VS_DIR_LAST,
 };
 
-static inline void ip_vs_conn_fill_param(int af, int protocol,
+static inline void ip_vs_conn_fill_param(struct net *net, int af, int protocol,
 					 const union nf_inet_addr *caddr,
 					 __be16 cport,
 					 const union nf_inet_addr *vaddr,
 					 __be16 vport,
 					 struct ip_vs_conn_param *p)
 {
+	p->net = net;
 	p->af = af;
 	p->protocol = protocol;
 	p->caddr = caddr;
diff --git a/include/net/netns/ip_vs.h b/include/net/netns/ip_vs.h
index b6642f0..f2d5bcd 100644
--- a/include/net/netns/ip_vs.h
+++ b/include/net/netns/ip_vs.h
@@ -66,6 +66,8 @@ struct netns_ipvs {
 	struct ip_vs_stats 		*ctl_stats; /* Statistics & estimator */
 	struct ip_vs_stats_user __percpu *ustats;   /* Statistics */
 
+	/* ip_vs_conn */
+	atomic_t 		conn_count;         /*  connection counter */
 	/* ip_vs_lblc */
 	int 			sysctl_lblc_expiration;
 	struct ctl_table_header	*lblc_ctl_header;
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index ef35e5d..41f93cc 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -64,9 +64,6 @@ static struct list_head *ip_vs_conn_tab __read_mostly;
 /*  SLAB cache for IPVS connections */
 static struct kmem_cache *ip_vs_conn_cachep __read_mostly;
 
-/*  counter for current IPVS connections */
-static atomic_t ip_vs_conn_count = ATOMIC_INIT(0);
-
 /*  counter for no client port connections */
 static atomic_t ip_vs_conn_no_cport_cnt = ATOMIC_INIT(0);
 
@@ -76,7 +73,7 @@ static unsigned int ip_vs_conn_rnd __read_mostly;
 /*
  *  Fine locking granularity for big connection hash table
  */
-#define CT_LOCKARRAY_BITS  4
+#define CT_LOCKARRAY_BITS  5
 #define CT_LOCKARRAY_SIZE  (1<<CT_LOCKARRAY_BITS)
 #define CT_LOCKARRAY_MASK  (CT_LOCKARRAY_SIZE-1)
 
@@ -133,19 +130,19 @@ static inline void ct_write_unlock_bh(unsigned key)
 /*
  *	Returns hash value for IPVS connection entry
  */
-static unsigned int ip_vs_conn_hashkey(int af, unsigned proto,
+static unsigned int ip_vs_conn_hashkey(struct net *net, int af, unsigned proto,
 				       const union nf_inet_addr *addr,
 				       __be16 port)
 {
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6)
-		return jhash_3words(jhash(addr, 16, ip_vs_conn_rnd),
-				    (__force u32)port, proto, ip_vs_conn_rnd)
-			& ip_vs_conn_tab_mask;
+		return (jhash_3words(jhash(addr, 16, ip_vs_conn_rnd),
+				    (__force u32)port, proto, ip_vs_conn_rnd) ^
+			((size_t)net>>8)) & ip_vs_conn_tab_mask;
 #endif
-	return jhash_3words((__force u32)addr->ip, (__force u32)port, proto,
-			    ip_vs_conn_rnd)
-		& ip_vs_conn_tab_mask;
+	return (jhash_3words((__force u32)addr->ip, (__force u32)port, proto,
+			    ip_vs_conn_rnd) ^
+		((size_t)net>>8)) & ip_vs_conn_tab_mask;
 }
 
 static unsigned int ip_vs_conn_hashkey_param(const struct ip_vs_conn_param *p,
@@ -166,15 +163,15 @@ static unsigned int ip_vs_conn_hashkey_param(const struct ip_vs_conn_param *p,
 		port = p->vport;
 	}
 
-	return ip_vs_conn_hashkey(p->af, p->protocol, addr, port);
+	return ip_vs_conn_hashkey(p->net, p->af, p->protocol, addr, port);
 }
 
 static unsigned int ip_vs_conn_hashkey_conn(const struct ip_vs_conn *cp)
 {
 	struct ip_vs_conn_param p;
 
-	ip_vs_conn_fill_param(cp->af, cp->protocol, &cp->caddr, cp->cport,
-			      NULL, 0, &p);
+	ip_vs_conn_fill_param(ip_vs_conn_net(cp), cp->af, cp->protocol,
+			      &cp->caddr, cp->cport, NULL, 0, &p);
 
 	if (cp->pe) {
 		p.pe = cp->pe;
@@ -186,7 +183,7 @@ static unsigned int ip_vs_conn_hashkey_conn(const struct ip_vs_conn *cp)
 }
 
 /*
- *	Hashes ip_vs_conn in ip_vs_conn_tab by proto,addr,port.
+ *	Hashes ip_vs_conn in ip_vs_conn_tab by netns,proto,addr,port.
  *	returns bool success.
  */
 static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
@@ -268,10 +265,10 @@ __ip_vs_conn_in_get(const struct ip_vs_conn_param *p)
 	ct_read_lock(hash);
 
 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
-		if (cp->af == p->af &&
+		if (ip_vs_conn_net_eq(cp, p->net) && cp->af == p->af &&
+		    p->cport == cp->cport && p->vport == cp->vport &&
 		    ip_vs_addr_equal(p->af, p->caddr, &cp->caddr) &&
 		    ip_vs_addr_equal(p->af, p->vaddr, &cp->vaddr) &&
-		    p->cport == cp->cport && p->vport == cp->vport &&
 		    ((!p->cport) ^ (!(cp->flags & IP_VS_CONN_F_NO_CPORT))) &&
 		    p->protocol == cp->protocol) {
 			/* HIT */
@@ -313,17 +310,18 @@ ip_vs_conn_fill_param_proto(int af, const struct sk_buff *skb,
 			    struct ip_vs_conn_param *p)
 {
 	__be16 _ports[2], *pptr;
+	struct net *net = skb_net(skb);
 
 	pptr = skb_header_pointer(skb, proto_off, sizeof(_ports), _ports);
 	if (pptr == NULL)
 		return 1;
 
 	if (likely(!inverse))
-		ip_vs_conn_fill_param(af, iph->protocol, &iph->saddr, pptr[0],
-				      &iph->daddr, pptr[1], p);
+		ip_vs_conn_fill_param(net, af, iph->protocol, &iph->saddr,
+				      pptr[0], &iph->daddr, pptr[1], p);
 	else
-		ip_vs_conn_fill_param(af, iph->protocol, &iph->daddr, pptr[1],
-				      &iph->saddr, pptr[0], p);
+		ip_vs_conn_fill_param(net, af, iph->protocol, &iph->daddr,
+				      pptr[1], &iph->saddr, pptr[0], p);
 	return 0;
 }
 
@@ -353,6 +351,8 @@ struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p)
 	ct_read_lock(hash);
 
 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
+		if (!ip_vs_conn_net_eq(cp, p->net))
+			continue;
 		if (p->pe_data && p->pe->ct_match) {
 			if (p->pe == cp->pe && p->pe->ct_match(p, cp))
 				goto out;
@@ -403,10 +403,10 @@ struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
 	ct_read_lock(hash);
 
 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
-		if (cp->af == p->af &&
+		if (ip_vs_conn_net_eq(cp, p->net) && cp->af == p->af &&
+		    p->vport == cp->cport && p->cport == cp->dport &&
 		    ip_vs_addr_equal(p->af, p->vaddr, &cp->caddr) &&
 		    ip_vs_addr_equal(p->af, p->caddr, &cp->daddr) &&
-		    p->vport == cp->cport && p->cport == cp->dport &&
 		    p->protocol == cp->protocol) {
 			/* HIT */
 			atomic_inc(&cp->refcnt);
@@ -611,8 +611,8 @@ struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp)
 	struct ip_vs_dest *dest;
 
 	if ((cp) && (!cp->dest)) {
-		dest = ip_vs_find_dest(&init_net, cp->af, &cp->daddr, cp->dport,
-				       &cp->vaddr, cp->vport,
+		dest = ip_vs_find_dest(ip_vs_conn_net(cp), cp->af, &cp->daddr,
+				       cp->dport, &cp->vaddr, cp->vport,
 				       cp->protocol, cp->fwmark);
 		ip_vs_bind_dest(cp, dest);
 		return dest;
@@ -730,6 +730,7 @@ int ip_vs_check_template(struct ip_vs_conn *ct)
 static void ip_vs_conn_expire(unsigned long data)
 {
 	struct ip_vs_conn *cp = (struct ip_vs_conn *)data;
+	struct netns_ipvs *ipvs = net_ipvs(ip_vs_conn_net(cp));
 
 	cp->timeout = 60*HZ;
 
@@ -772,7 +773,7 @@ static void ip_vs_conn_expire(unsigned long data)
 		ip_vs_unbind_dest(cp);
 		if (cp->flags & IP_VS_CONN_F_NO_CPORT)
 			atomic_dec(&ip_vs_conn_no_cport_cnt);
-		atomic_dec(&ip_vs_conn_count);
+		atomic_dec(&ipvs->conn_count);
 
 		kmem_cache_free(ip_vs_conn_cachep, cp);
 		return;
@@ -806,7 +807,9 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
 	       struct ip_vs_dest *dest, __u32 fwmark)
 {
 	struct ip_vs_conn *cp;
-	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(&init_net, p->protocol);
+	struct netns_ipvs *ipvs = net_ipvs(p->net);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(p->net,
+							   p->protocol);
 
 	cp = kmem_cache_zalloc(ip_vs_conn_cachep, GFP_ATOMIC);
 	if (cp == NULL) {
@@ -816,6 +819,7 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
 
 	INIT_LIST_HEAD(&cp->c_list);
 	setup_timer(&cp->timer, ip_vs_conn_expire, (unsigned long)cp);
+	ip_vs_conn_net_set(cp, p->net);
 	cp->af		   = p->af;
 	cp->protocol	   = p->protocol;
 	ip_vs_addr_copy(p->af, &cp->caddr, p->caddr);
@@ -846,7 +850,7 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
 	atomic_set(&cp->n_control, 0);
 	atomic_set(&cp->in_pkts, 0);
 
-	atomic_inc(&ip_vs_conn_count);
+	atomic_inc(&ipvs->conn_count);
 	if (flags & IP_VS_CONN_F_NO_CPORT)
 		atomic_inc(&ip_vs_conn_no_cport_cnt);
 
@@ -888,17 +892,22 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
  *	/proc/net/ip_vs_conn entries
  */
 #ifdef CONFIG_PROC_FS
+struct ip_vs_iter_state {
+	struct seq_net_private p;
+	struct list_head *l;
+};
 
 static void *ip_vs_conn_array(struct seq_file *seq, loff_t pos)
 {
 	int idx;
 	struct ip_vs_conn *cp;
+	struct ip_vs_iter_state *iter = seq->private;
 
 	for (idx = 0; idx < ip_vs_conn_tab_size; idx++) {
 		ct_read_lock_bh(idx);
 		list_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
 			if (pos-- == 0) {
-				seq->private = &ip_vs_conn_tab[idx];
+				iter->l = &ip_vs_conn_tab[idx];
 			return cp;
 			}
 		}
@@ -910,14 +919,17 @@ static void *ip_vs_conn_array(struct seq_file *seq, loff_t pos)
 
 static void *ip_vs_conn_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	seq->private = NULL;
+	struct ip_vs_iter_state *iter = seq->private;
+
+	iter->l = NULL;
 	return *pos ? ip_vs_conn_array(seq, *pos - 1) :SEQ_START_TOKEN;
 }
 
 static void *ip_vs_conn_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct ip_vs_conn *cp = v;
-	struct list_head *e, *l = seq->private;
+	struct ip_vs_iter_state *iter = seq->private;
+	struct list_head *e, *l = iter->l;
 	int idx;
 
 	++*pos;
@@ -934,18 +946,19 @@ static void *ip_vs_conn_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	while (++idx < ip_vs_conn_tab_size) {
 		ct_read_lock_bh(idx);
 		list_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
-			seq->private = &ip_vs_conn_tab[idx];
+			iter->l = &ip_vs_conn_tab[idx];
 			return cp;
 		}
 		ct_read_unlock_bh(idx);
 	}
-	seq->private = NULL;
+	iter->l = NULL;
 	return NULL;
 }
 
 static void ip_vs_conn_seq_stop(struct seq_file *seq, void *v)
 {
-	struct list_head *l = seq->private;
+	struct ip_vs_iter_state *iter = seq->private;
+	struct list_head *l = iter->l;
 
 	if (l)
 		ct_read_unlock_bh(l - ip_vs_conn_tab);
@@ -959,9 +972,12 @@ static int ip_vs_conn_seq_show(struct seq_file *seq, void *v)
    "Pro FromIP   FPrt ToIP     TPrt DestIP   DPrt State       Expires PEName PEData\n");
 	else {
 		const struct ip_vs_conn *cp = v;
+		struct net *net = seq_file_net(seq);
 		char pe_data[IP_VS_PENAME_MAXLEN + IP_VS_PEDATA_MAXLEN + 3];
 		size_t len = 0;
 
+		if (!ip_vs_conn_net_eq(cp, net))
+			return 0;
 		if (cp->pe_data) {
 			pe_data[0] = ' ';
 			len = strlen(cp->pe->name);
@@ -1006,7 +1022,8 @@ static const struct seq_operations ip_vs_conn_seq_ops = {
 
 static int ip_vs_conn_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &ip_vs_conn_seq_ops);
+	return seq_open_net(inode, file, &ip_vs_conn_seq_ops,
+			    sizeof(struct ip_vs_iter_state));
 }
 
 static const struct file_operations ip_vs_conn_fops = {
@@ -1033,6 +1050,10 @@ static int ip_vs_conn_sync_seq_show(struct seq_file *seq, void *v)
    "Pro FromIP   FPrt ToIP     TPrt DestIP   DPrt State       Origin Expires\n");
 	else {
 		const struct ip_vs_conn *cp = v;
+		struct net *net = seq_file_net(seq);
+
+		if (!ip_vs_conn_net_eq(cp, net))
+			return 0;
 
 #ifdef CONFIG_IP_VS_IPV6
 		if (cp->af == AF_INET6)
@@ -1069,7 +1090,8 @@ static const struct seq_operations ip_vs_conn_sync_seq_ops = {
 
 static int ip_vs_conn_sync_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &ip_vs_conn_sync_seq_ops);
+	return seq_open_net(inode, file, &ip_vs_conn_sync_seq_ops,
+			    sizeof(struct ip_vs_iter_state));
 }
 
 static const struct file_operations ip_vs_conn_sync_fops = {
@@ -1170,10 +1192,11 @@ void ip_vs_random_dropentry(void)
 /*
  *      Flush all the connection entries in the ip_vs_conn_tab
  */
-static void ip_vs_conn_flush(void)
+static void ip_vs_conn_flush(struct net *net)
 {
 	int idx;
 	struct ip_vs_conn *cp;
+	struct netns_ipvs *ipvs = net_ipvs(net);
 
   flush_again:
 	for (idx = 0; idx < ip_vs_conn_tab_size; idx++) {
@@ -1183,7 +1206,8 @@ static void ip_vs_conn_flush(void)
 		ct_write_lock_bh(idx);
 
 		list_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
-
+			if (!ip_vs_conn_net_eq(cp, net))
+				continue;
 			IP_VS_DBG(4, "del connection\n");
 			ip_vs_conn_expire_now(cp);
 			if (cp->control) {
@@ -1196,7 +1220,7 @@ static void ip_vs_conn_flush(void)
 
 	/* the counter may be not NULL, because maybe some conn entries
 	   are run by slow timer handler or unhashed but still referred */
-	if (atomic_read(&ip_vs_conn_count) != 0) {
+	if (atomic_read(&ipvs->conn_count) != 0) {
 		schedule();
 		goto flush_again;
 	}
@@ -1204,14 +1228,37 @@ static void ip_vs_conn_flush(void)
 
 int __net_init __ip_vs_conn_init(struct net *net)
 {
-	int idx;
+	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	if (!net_eq(net, &init_net))	/* netns not enabled yet */
 		return -EPERM;
+	atomic_set(&ipvs->conn_count, 0);
 
-	/* Compute size and mask */
-	ip_vs_conn_tab_size = 1 << ip_vs_conn_tab_bits;
-	ip_vs_conn_tab_mask = ip_vs_conn_tab_size - 1;
+	proc_net_fops_create(net, "ip_vs_conn", 0, &ip_vs_conn_fops);
+	proc_net_fops_create(net, "ip_vs_conn_sync", 0, &ip_vs_conn_sync_fops);
+
+	return 0;
+}
+/* Cleanup and release all netns related ... */
+static void __net_exit __ip_vs_conn_cleanup(struct net *net)
+{
+	if (!net_eq(net, &init_net))	/* netns not enabled yet */
+		return;
+
+	/* flush all the connection entries first */
+	ip_vs_conn_flush(net);
+	proc_net_remove(net, "ip_vs_conn");
+	proc_net_remove(net, "ip_vs_conn_sync");
+}
+static struct pernet_operations ipvs_conn_ops = {
+	.init = __ip_vs_conn_init,
+	.exit = __ip_vs_conn_cleanup,
+};
+
+int __init ip_vs_conn_init(void)
+{
+	int rv;
+	int idx;
 
 	/* Compute size and mask */
 	ip_vs_conn_tab_size = 1 << ip_vs_conn_tab_bits;
@@ -1249,34 +1296,6 @@ int __net_init __ip_vs_conn_init(struct net *net)
 		rwlock_init(&__ip_vs_conntbl_lock_array[idx].l);
 	}
 
-	proc_net_fops_create(net, "ip_vs_conn", 0, &ip_vs_conn_fops);
-	proc_net_fops_create(net, "ip_vs_conn_sync", 0, &ip_vs_conn_sync_fops);
-
-	return 0;
-}
-/* Cleanup and release all netns related ... */
-static void __net_exit __ip_vs_conn_cleanup(struct net *net)
-{
-	if (!net_eq(net, &init_net))	/* netns not enabled yet */
-		return;
-
-	/* flush all the connection entries first */
-	ip_vs_conn_flush();
-	/* Release the empty cache */
-	kmem_cache_destroy(ip_vs_conn_cachep);
-	proc_net_remove(net, "ip_vs_conn");
-	proc_net_remove(net, "ip_vs_conn_sync");
-	vfree(ip_vs_conn_tab);
-}
-static struct pernet_operations ipvs_conn_ops = {
-	.init = __ip_vs_conn_init,
-	.exit = __ip_vs_conn_cleanup,
-};
-
-int __init ip_vs_conn_init(void)
-{
-	int rv;
-
 	rv = register_pernet_subsys(&ipvs_conn_ops);
 
 	/* calculate the random value for connection hash */
@@ -1287,4 +1306,8 @@ int __init ip_vs_conn_init(void)
 void ip_vs_conn_cleanup(void)
 {
 	unregister_pernet_subsys(&ipvs_conn_ops);
+	/* Release the empty cache */
+	kmem_cache_destroy(ip_vs_conn_cachep);
+	vfree(ip_vs_conn_tab);
+
 }
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 679eb16..69ba8cc 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -193,7 +193,8 @@ ip_vs_conn_fill_param_persist(const struct ip_vs_service *svc,
 			      const union nf_inet_addr *vaddr, __be16 vport,
 			      struct ip_vs_conn_param *p)
 {
-	ip_vs_conn_fill_param(svc->af, protocol, caddr, cport, vaddr, vport, p);
+	ip_vs_conn_fill_param(svc->net, svc->af, protocol, caddr, cport, vaddr,
+			      vport, p);
 	p->pe = svc->pe;
 	if (p->pe && p->pe->fill_param)
 		return p->pe->fill_param(p, skb);
@@ -336,8 +337,8 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	/*
 	 *    Create a new connection according to the template
 	 */
-	ip_vs_conn_fill_param(svc->af, iph.protocol, &iph.saddr, src_port,
-			      &iph.daddr, dst_port, &param);
+	ip_vs_conn_fill_param(svc->net, svc->af, iph.protocol, &iph.saddr,
+			      src_port, &iph.daddr, dst_port, &param);
 
 	cp = ip_vs_conn_new(&param, &dest->addr, dport, flags, dest, skb->mark);
 	if (cp == NULL) {
@@ -451,8 +452,10 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	 */
 	{
 		struct ip_vs_conn_param p;
-		ip_vs_conn_fill_param(svc->af, iph.protocol, &iph.saddr,
-				      pptr[0], &iph.daddr, pptr[1], &p);
+
+		ip_vs_conn_fill_param(svc->net, svc->af, iph.protocol,
+				      &iph.saddr, pptr[0], &iph.daddr, pptr[1],
+				      &p);
 		cp = ip_vs_conn_new(&p, &dest->addr,
 				    dest->port ? dest->port : pptr[1],
 				    flags, dest, skb->mark);
@@ -518,7 +521,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		IP_VS_DBG(6, "%s(): create a cache_bypass entry\n", __func__);
 		{
 			struct ip_vs_conn_param p;
-			ip_vs_conn_fill_param(svc->af, iph.protocol,
+			ip_vs_conn_fill_param(svc->net, svc->af, iph.protocol,
 					      &iph.saddr, pptr[0],
 					      &iph.daddr, pptr[1], &p);
 			cp = ip_vs_conn_new(&p, &daddr, 0,
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index b39befd..78d5980 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -198,13 +198,15 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		 */
 		{
 			struct ip_vs_conn_param p;
-			ip_vs_conn_fill_param(AF_INET, iph->protocol,
-					      &from, port, &cp->caddr, 0, &p);
+			ip_vs_conn_fill_param(ip_vs_conn_net(cp), AF_INET,
+					      iph->protocol, &from, port,
+					      &cp->caddr, 0, &p);
 			n_cp = ip_vs_conn_out_get(&p);
 		}
 		if (!n_cp) {
 			struct ip_vs_conn_param p;
-			ip_vs_conn_fill_param(AF_INET, IPPROTO_TCP, &cp->caddr,
+			ip_vs_conn_fill_param(ip_vs_conn_net(cp),
+					      AF_INET, IPPROTO_TCP, &cp->caddr,
 					      0, &cp->vaddr, port, &p);
 			n_cp = ip_vs_conn_new(&p, &from, port,
 					      IP_VS_CONN_F_NO_CPORT |
@@ -360,9 +362,9 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 
 	{
 		struct ip_vs_conn_param p;
-		ip_vs_conn_fill_param(AF_INET, iph->protocol, &to, port,
-				      &cp->vaddr, htons(ntohs(cp->vport)-1),
-				      &p);
+		ip_vs_conn_fill_param(ip_vs_conn_net(cp), AF_INET,
+				      iph->protocol, &to, port, &cp->vaddr,
+				      htons(ntohs(cp->vport)-1), &p);
 		n_cp = ip_vs_conn_in_get(&p);
 		if (!n_cp) {
 			n_cp = ip_vs_conn_new(&p, &cp->daddr,
diff --git a/net/netfilter/ipvs/ip_vs_nfct.c b/net/netfilter/ipvs/ip_vs_nfct.c
index 4680647..f454c80 100644
--- a/net/netfilter/ipvs/ip_vs_nfct.c
+++ b/net/netfilter/ipvs/ip_vs_nfct.c
@@ -141,6 +141,7 @@ static void ip_vs_nfct_expect_callback(struct nf_conn *ct,
 	struct nf_conntrack_tuple *orig, new_reply;
 	struct ip_vs_conn *cp;
 	struct ip_vs_conn_param p;
+	struct net *net = nf_ct_net(ct);
 
 	if (exp->tuple.src.l3num != PF_INET)
 		return;
@@ -155,7 +156,7 @@ static void ip_vs_nfct_expect_callback(struct nf_conn *ct,
 
 	/* RS->CLIENT */
 	orig = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
-	ip_vs_conn_fill_param(exp->tuple.src.l3num, orig->dst.protonum,
+	ip_vs_conn_fill_param(net, exp->tuple.src.l3num, orig->dst.protonum,
 			      &orig->src.u3, orig->src.u.tcp.port,
 			      &orig->dst.u3, orig->dst.u.tcp.port, &p);
 	cp = ip_vs_conn_out_get(&p);
@@ -268,7 +269,8 @@ void ip_vs_conn_drop_conntrack(struct ip_vs_conn *cp)
 		" for conn " FMT_CONN "\n",
 		__func__, ARG_TUPLE(&tuple), ARG_CONN(cp));
 
-	h = nf_conntrack_find_get(&init_net, NF_CT_DEFAULT_ZONE, &tuple);
+	h = nf_conntrack_find_get(ip_vs_conn_net(cp), NF_CT_DEFAULT_ZONE,
+				  &tuple);
 	if (h) {
 		ct = nf_ct_tuplehash_to_ctrack(h);
 		/* Show what happens instead of calling nf_ct_kill() */
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
index b8b37fa..ded1adb 100644
--- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
@@ -41,15 +41,16 @@ struct isakmp_hdr {
 #define PORT_ISAKMP	500
 
 static void
-ah_esp_conn_fill_param_proto(int af, const struct ip_vs_iphdr *iph,
-			     int inverse, struct ip_vs_conn_param *p)
+ah_esp_conn_fill_param_proto(struct net *net, int af,
+			     const struct ip_vs_iphdr *iph, int inverse,
+			     struct ip_vs_conn_param *p)
 {
 	if (likely(!inverse))
-		ip_vs_conn_fill_param(af, IPPROTO_UDP,
+		ip_vs_conn_fill_param(net, af, IPPROTO_UDP,
 				      &iph->saddr, htons(PORT_ISAKMP),
 				      &iph->daddr, htons(PORT_ISAKMP), p);
 	else
-		ip_vs_conn_fill_param(af, IPPROTO_UDP,
+		ip_vs_conn_fill_param(net, af, IPPROTO_UDP,
 				      &iph->daddr, htons(PORT_ISAKMP),
 				      &iph->saddr, htons(PORT_ISAKMP), p);
 }
@@ -61,8 +62,9 @@ ah_esp_conn_in_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
 {
 	struct ip_vs_conn *cp;
 	struct ip_vs_conn_param p;
+	struct net *net = skb_net(skb);
 
-	ah_esp_conn_fill_param_proto(af, iph, inverse, &p);
+	ah_esp_conn_fill_param_proto(net, af, iph, inverse, &p);
 	cp = ip_vs_conn_in_get(&p);
 	if (!cp) {
 		/*
@@ -90,8 +92,9 @@ ah_esp_conn_out_get(int af, const struct sk_buff *skb,
 {
 	struct ip_vs_conn *cp;
 	struct ip_vs_conn_param p;
+	struct net *net = skb_net(skb);
 
-	ah_esp_conn_fill_param_proto(af, iph, inverse, &p);
+	ah_esp_conn_fill_param_proto(net, af, iph, inverse, &p);
 	cp = ip_vs_conn_out_get(&p);
 	if (!cp) {
 		IP_VS_DBG_BUF(12, "Unknown ISAKMP entry for inout packet "
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 3c6d06d..c011830 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -1064,7 +1064,7 @@ static void sctp_unregister_app(struct net *net, struct ip_vs_app *inc)
 
 static int sctp_app_conn_bind(struct ip_vs_conn *cp)
 {
-	struct netns_ipvs *ipvs = net_ipvs(&init_net);
+	struct netns_ipvs *ipvs = net_ipvs(ip_vs_conn_net(cp));
 	int hash;
 	struct ip_vs_app *inc;
 	int result = 0;
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 326768d..2e270b6 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -626,7 +626,7 @@ tcp_unregister_app(struct net *net, struct ip_vs_app *inc)
 static int
 tcp_app_conn_bind(struct ip_vs_conn *cp)
 {
-	struct netns_ipvs *ipvs = net_ipvs(&init_net);
+	struct netns_ipvs *ipvs = net_ipvs(ip_vs_conn_net(cp));
 	int hash;
 	struct ip_vs_app *inc;
 	int result = 0;
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 7e894d5..882a547 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -396,7 +396,7 @@ udp_unregister_app(struct net *net, struct ip_vs_app *inc)
 
 static int udp_app_conn_bind(struct ip_vs_conn *cp)
 {
-	struct netns_ipvs *ipvs = net_ipvs(&init_net);
+	struct netns_ipvs *ipvs = net_ipvs(ip_vs_conn_net(cp));
 	int hash;
 	struct ip_vs_app *inc;
 	int result = 0;
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 29c6bbb..2887c34 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -657,21 +657,21 @@ control:
  *  fill_param used by version 1
  */
 static inline int
-ip_vs_conn_fill_param_sync(int af, union ip_vs_sync_conn *sc,
+ip_vs_conn_fill_param_sync(struct net *net, int af, union ip_vs_sync_conn *sc,
 			   struct ip_vs_conn_param *p,
 			   __u8 *pe_data, unsigned int pe_data_len,
 			   __u8 *pe_name, unsigned int pe_name_len)
 {
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6)
-		ip_vs_conn_fill_param(af, sc->v6.protocol,
+		ip_vs_conn_fill_param(net, af, sc->v6.protocol,
 				      (const union nf_inet_addr *)&sc->v6.caddr,
 				      sc->v6.cport,
 				      (const union nf_inet_addr *)&sc->v6.vaddr,
 				      sc->v6.vport, p);
 	else
 #endif
-		ip_vs_conn_fill_param(af, sc->v4.protocol,
+		ip_vs_conn_fill_param(net, af, sc->v4.protocol,
 				      (const union nf_inet_addr *)&sc->v4.caddr,
 				      sc->v4.cport,
 				      (const union nf_inet_addr *)&sc->v4.vaddr,
@@ -878,7 +878,7 @@ static void ip_vs_process_message_v0(struct net *net, const char *buffer,
 			}
 		}
 
-		ip_vs_conn_fill_param(AF_INET, s->protocol,
+		ip_vs_conn_fill_param(net, AF_INET, s->protocol,
 				      (const union nf_inet_addr *)&s->caddr,
 				      s->cport,
 				      (const union nf_inet_addr *)&s->vaddr,
@@ -1040,9 +1040,8 @@ static inline int ip_vs_proc_sync_conn(struct net *net, __u8 *p, __u8 *msg_end)
 			state = 0;
 		}
 	}
-	if (ip_vs_conn_fill_param_sync(af, s, &param,
-					pe_data, pe_data_len,
-					pe_name, pe_name_len)) {
+	if (ip_vs_conn_fill_param_sync(net, af, s, &param, pe_data,
+				       pe_data_len, pe_name, pe_name_len)) {
 		retc = 50;
 		goto out;
 	}
-- 
1.7.2.3

