From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 04/84] ipvs: Store ipvs not net in struct ip_vs_conn
Date: Sun, 20 Sep 2015 01:22:20 -0500
Message-ID: <1442730220-32458-4-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

In practice struct netns_ipvs is as meaningful as struct net and more
useful as it holds the ipvs specific data.  So store a pointer to
struct netns_ipvs.

Update the accesses of conn->net to access conn->ipvs->net instead.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/ip_vs.h                   | 31 +------------------------------
 net/netfilter/ipvs/ip_vs_conn.c       | 30 +++++++++++++++---------------
 net/netfilter/ipvs/ip_vs_ftp.c        |  6 +++---
 net/netfilter/ipvs/ip_vs_nfct.c       |  3 +--
 net/netfilter/ipvs/ip_vs_proto_sctp.c |  2 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |  2 +-
 net/netfilter/ipvs/ip_vs_proto_udp.c  |  2 +-
 net/netfilter/ipvs/ip_vs_xmit.c       |  4 ++--
 8 files changed, 25 insertions(+), 55 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 1096a71ab6ed..3bf6da8fdaf1 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -572,9 +572,7 @@ struct ip_vs_conn {
 	volatile __u32          flags;          /* status flags */
 	__u16                   protocol;       /* Which protocol (TCP/UDP) */
 	__u16			daf;		/* Address family of the dest */
-#ifdef CONFIG_NET_NS
-	struct net              *net;           /* Name space */
-#endif
+	struct netns_ipvs	*ipvs;
 
 	/* counter and timer */
 	atomic_t		refcnt;		/* reference count */
@@ -621,33 +619,6 @@ struct ip_vs_conn {
 	struct rcu_head		rcu_head;
 };
 
-/* To save some memory in conn table when name space is disabled. */
-static inline struct net *ip_vs_conn_net(const struct ip_vs_conn *cp)
-{
-#ifdef CONFIG_NET_NS
-	return cp->net;
-#else
-	return &init_net;
-#endif
-}
-
-static inline void ip_vs_conn_net_set(struct ip_vs_conn *cp, struct net *net)
-{
-#ifdef CONFIG_NET_NS
-	cp->net = net;
-#endif
-}
-
-static inline int ip_vs_conn_net_eq(const struct ip_vs_conn *cp,
-				    struct net *net)
-{
-#ifdef CONFIG_NET_NS
-	return cp->net == net;
-#else
-	return 1;
-#endif
-}
-
 /* Extended internal versions of struct ip_vs_service_user and ip_vs_dest_user
  * for IPv6 support.
  *
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index f71b3146a5a1..899f5d3e46ed 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -148,7 +148,7 @@ static unsigned int ip_vs_conn_hashkey_conn(const struct ip_vs_conn *cp)
 {
 	struct ip_vs_conn_param p;
 
-	ip_vs_conn_fill_param(ip_vs_conn_net(cp), cp->af, cp->protocol,
+	ip_vs_conn_fill_param(cp->ipvs->net, cp->af, cp->protocol,
 			      &cp->caddr, cp->cport, NULL, 0, &p);
 
 	if (cp->pe) {
@@ -279,7 +279,7 @@ __ip_vs_conn_in_get(const struct ip_vs_conn_param *p)
 		    ip_vs_addr_equal(p->af, p->vaddr, &cp->vaddr) &&
 		    ((!p->cport) ^ (!(cp->flags & IP_VS_CONN_F_NO_CPORT))) &&
 		    p->protocol == cp->protocol &&
-		    ip_vs_conn_net_eq(cp, p->net)) {
+		    net_eq(cp->ipvs->net, p->net)) {
 			if (!__ip_vs_conn_get(cp))
 				continue;
 			/* HIT */
@@ -359,7 +359,7 @@ struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p)
 
 	hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
 		if (unlikely(p->pe_data && p->pe->ct_match)) {
-			if (!ip_vs_conn_net_eq(cp, p->net))
+			if (net_eq(cp->ipvs->net, p->net))
 				continue;
 			if (p->pe == cp->pe && p->pe->ct_match(p, cp)) {
 				if (__ip_vs_conn_get(cp))
@@ -377,7 +377,7 @@ struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p)
 		    p->vport == cp->vport && p->cport == cp->cport &&
 		    cp->flags & IP_VS_CONN_F_TEMPLATE &&
 		    p->protocol == cp->protocol &&
-		    ip_vs_conn_net_eq(cp, p->net)) {
+		    net_eq(cp->ipvs->net, p->net)) {
 			if (__ip_vs_conn_get(cp))
 				goto out;
 		}
@@ -418,7 +418,7 @@ struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
 		    ip_vs_addr_equal(p->af, p->vaddr, &cp->caddr) &&
 		    ip_vs_addr_equal(p->af, p->caddr, &cp->daddr) &&
 		    p->protocol == cp->protocol &&
-		    ip_vs_conn_net_eq(cp, p->net)) {
+		    net_eq(cp->ipvs->net, p->net)) {
 			if (!__ip_vs_conn_get(cp))
 				continue;
 			/* HIT */
@@ -638,7 +638,7 @@ void ip_vs_try_bind_dest(struct ip_vs_conn *cp)
 	 * so we can make the assumption that the svc_af is the same as the
 	 * dest_af
 	 */
-	dest = ip_vs_find_dest(ip_vs_conn_net(cp), cp->af, cp->af, &cp->daddr,
+	dest = ip_vs_find_dest(cp->ipvs->net, cp->af, cp->af, &cp->daddr,
 			       cp->dport, &cp->vaddr, cp->vport,
 			       cp->protocol, cp->fwmark, cp->flags);
 	if (dest) {
@@ -668,7 +668,7 @@ void ip_vs_try_bind_dest(struct ip_vs_conn *cp)
 #endif
 			ip_vs_bind_xmit(cp);
 
-		pd = ip_vs_proto_data_get(ip_vs_conn_net(cp), cp->protocol);
+		pd = ip_vs_proto_data_get(cp->ipvs->net, cp->protocol);
 		if (pd && atomic_read(&pd->appcnt))
 			ip_vs_bind_app(cp, pd->pp);
 	}
@@ -746,7 +746,7 @@ static int expire_quiescent_template(struct netns_ipvs *ipvs,
 int ip_vs_check_template(struct ip_vs_conn *ct)
 {
 	struct ip_vs_dest *dest = ct->dest;
-	struct netns_ipvs *ipvs = net_ipvs(ip_vs_conn_net(ct));
+	struct netns_ipvs *ipvs = ct->ipvs;
 
 	/*
 	 * Checking the dest server status.
@@ -800,8 +800,8 @@ static void ip_vs_conn_rcu_free(struct rcu_head *head)
 static void ip_vs_conn_expire(unsigned long data)
 {
 	struct ip_vs_conn *cp = (struct ip_vs_conn *)data;
-	struct net *net = ip_vs_conn_net(cp);
-	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct netns_ipvs *ipvs = cp->ipvs;
+	struct net *net = ipvs->net;
 
 	/*
 	 *	do I control anybody?
@@ -887,7 +887,7 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p, int dest_af,
 
 	INIT_HLIST_NODE(&cp->c_list);
 	setup_timer(&cp->timer, ip_vs_conn_expire, (unsigned long)cp);
-	ip_vs_conn_net_set(cp, p->net);
+	cp->ipvs	   = ipvs;
 	cp->af		   = p->af;
 	cp->daf		   = dest_af;
 	cp->protocol	   = p->protocol;
@@ -1061,7 +1061,7 @@ static int ip_vs_conn_seq_show(struct seq_file *seq, void *v)
 		size_t len = 0;
 		char dbuf[IP_VS_ADDRSTRLEN];
 
-		if (!ip_vs_conn_net_eq(cp, net))
+		if (!net_eq(cp->ipvs->net, net))
 			return 0;
 		if (cp->pe_data) {
 			pe_data[0] = ' ';
@@ -1146,7 +1146,7 @@ static int ip_vs_conn_sync_seq_show(struct seq_file *seq, void *v)
 		const struct ip_vs_conn *cp = v;
 		struct net *net = seq_file_net(seq);
 
-		if (!ip_vs_conn_net_eq(cp, net))
+		if (!net_eq(cp->ipvs->net, net))
 			return 0;
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -1256,7 +1256,7 @@ void ip_vs_random_dropentry(struct net *net)
 			if (cp->flags & IP_VS_CONN_F_TEMPLATE)
 				/* connection template */
 				continue;
-			if (!ip_vs_conn_net_eq(cp, net))
+			if (!net_eq(cp->ipvs->net, net))
 				continue;
 			if (cp->protocol == IPPROTO_TCP) {
 				switch(cp->state) {
@@ -1319,7 +1319,7 @@ flush_again:
 	for (idx = 0; idx < ip_vs_conn_tab_size; idx++) {
 
 		hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[idx], c_list) {
-			if (!ip_vs_conn_net_eq(cp, net))
+			if (cp->ipvs != ipvs)
 				continue;
 			IP_VS_DBG(4, "del connection\n");
 			ip_vs_conn_expire_now(cp);
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 5d3daae98bf0..5ccbf3c16dd4 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -223,14 +223,14 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		 */
 		{
 			struct ip_vs_conn_param p;
-			ip_vs_conn_fill_param(ip_vs_conn_net(cp), AF_INET,
+			ip_vs_conn_fill_param(cp->ipvs->net, AF_INET,
 					      iph->protocol, &from, port,
 					      &cp->caddr, 0, &p);
 			n_cp = ip_vs_conn_out_get(&p);
 		}
 		if (!n_cp) {
 			struct ip_vs_conn_param p;
-			ip_vs_conn_fill_param(ip_vs_conn_net(cp),
+			ip_vs_conn_fill_param(cp->ipvs->net,
 					      AF_INET, IPPROTO_TCP, &cp->caddr,
 					      0, &cp->vaddr, port, &p);
 			/* As above, this is ipv4 only */
@@ -392,7 +392,7 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 
 	{
 		struct ip_vs_conn_param p;
-		ip_vs_conn_fill_param(ip_vs_conn_net(cp), AF_INET,
+		ip_vs_conn_fill_param(cp->ipvs->net, AF_INET,
 				      iph->protocol, &to, port, &cp->vaddr,
 				      htons(ntohs(cp->vport)-1), &p);
 		n_cp = ip_vs_conn_in_get(&p);
diff --git a/net/netfilter/ipvs/ip_vs_nfct.c b/net/netfilter/ipvs/ip_vs_nfct.c
index 136184572fc9..dae3c069966f 100644
--- a/net/netfilter/ipvs/ip_vs_nfct.c
+++ b/net/netfilter/ipvs/ip_vs_nfct.c
@@ -274,8 +274,7 @@ void ip_vs_conn_drop_conntrack(struct ip_vs_conn *cp)
 		" for conn " FMT_CONN "\n",
 		__func__, ARG_TUPLE(&tuple), ARG_CONN(cp));
 
-	h = nf_conntrack_find_get(ip_vs_conn_net(cp), &nf_ct_zone_dflt,
-				  &tuple);
+	h = nf_conntrack_find_get(cp->ipvs->net, &nf_ct_zone_dflt, &tuple);
 	if (h) {
 		ct = nf_ct_tuplehash_to_ctrack(h);
 		/* Show what happens instead of calling nf_ct_kill() */
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index ac628a9afdb5..ce615866bd63 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -521,7 +521,7 @@ static void sctp_unregister_app(struct net *net, struct ip_vs_app *inc)
 
 static int sctp_app_conn_bind(struct ip_vs_conn *cp)
 {
-	struct netns_ipvs *ipvs = net_ipvs(ip_vs_conn_net(cp));
+	struct netns_ipvs *ipvs = cp->ipvs;
 	int hash;
 	struct ip_vs_app *inc;
 	int result = 0;
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 8f43cf6044e9..e00623a88518 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -633,7 +633,7 @@ tcp_unregister_app(struct net *net, struct ip_vs_app *inc)
 static int
 tcp_app_conn_bind(struct ip_vs_conn *cp)
 {
-	struct netns_ipvs *ipvs = net_ipvs(ip_vs_conn_net(cp));
+	struct netns_ipvs *ipvs = cp->ipvs;
 	int hash;
 	struct ip_vs_app *inc;
 	int result = 0;
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index f3aa821efb89..3b0a2dc1826b 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -400,7 +400,7 @@ udp_unregister_app(struct net *net, struct ip_vs_app *inc)
 
 static int udp_app_conn_bind(struct ip_vs_conn *cp)
 {
-	struct netns_ipvs *ipvs = net_ipvs(ip_vs_conn_net(cp));
+	struct netns_ipvs *ipvs = cp->ipvs;
 	int hash;
 	struct ip_vs_app *inc;
 	int result = 0;
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 9dbb7ccadecb..5b5ec0b688de 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -574,7 +574,7 @@ static inline int ip_vs_nat_send_or_cont(int pf, struct sk_buff *skb,
 		skb_forward_csum(skb);
 		if (!skb->sk)
 			skb_sender_cpu_clear(skb);
-		NF_HOOK(pf, NF_INET_LOCAL_OUT, ip_vs_conn_net(cp), NULL, skb,
+		NF_HOOK(pf, NF_INET_LOCAL_OUT, cp->ipvs->net, NULL, skb,
 			NULL, skb_dst(skb)->dev, dst_output_okfn);
 	} else
 		ret = NF_ACCEPT;
@@ -596,7 +596,7 @@ static inline int ip_vs_send_or_cont(int pf, struct sk_buff *skb,
 		skb_forward_csum(skb);
 		if (!skb->sk)
 			skb_sender_cpu_clear(skb);
-		NF_HOOK(pf, NF_INET_LOCAL_OUT, ip_vs_conn_net(cp), NULL, skb,
+		NF_HOOK(pf, NF_INET_LOCAL_OUT, cp->ipvs->net, NULL, skb,
 			NULL, skb_dst(skb)->dev, dst_output_okfn);
 	} else
 		ret = NF_ACCEPT;
-- 
2.2.1
