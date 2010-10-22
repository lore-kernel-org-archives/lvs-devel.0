From: Simon Horman <horms@verge.net.au>
Subject: [rfc v2 04/10] ipvs network name space aware: core
Date: Fri, 22 Oct 2010 22:09:38 +0200
Message-ID: <20101022202358.079947890@joe.akashicho.tokyo.vergenet.net>
References: <20101022200934.822223308@joe.akashicho.tokyo.vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=ipvs-netns-4.patch
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, Julian Anastasov <ja@ssi.bg>, Daniel Lezcano <daniel.lezcano@free.fr>, Wensong Zhang <wensong@linux-vs.org>

This patch just contains ip_vs_core.c

Signed-off-by:Hans Schillstrom <hans.schillstrom@ericsson.com>

Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_core.c
===================================================================
--- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_core.c	2010-10-22 21:38:58.000000000 +0200
+++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_core.c	2010-10-22 21:42:03.000000000 +0200
@@ -68,6 +68,8 @@ EXPORT_SYMBOL(ip_vs_conn_put);
 EXPORT_SYMBOL(ip_vs_get_debug_level);
 #endif
 
+/* netns cnt used for uniqueness */
+static atomic_t ipvs_netns_cnt = ATOMIC_INIT(0);
 
 /* ID used in ICMP lookups */
 #define icmp_id(icmph)          (((icmph)->un).echo.id)
@@ -108,6 +110,8 @@ static inline void
 ip_vs_in_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 {
 	struct ip_vs_dest *dest = cp->dest;
+	struct net *net = dev_net(skb->dev);
+
 	if (dest && (dest->flags & IP_VS_DEST_F_AVAILABLE)) {
 		spin_lock(&dest->stats.lock);
 		dest->stats.ustats.inpkts++;
@@ -119,10 +123,10 @@ ip_vs_in_stats(struct ip_vs_conn *cp, st
 		dest->svc->stats.ustats.inbytes += skb->len;
 		spin_unlock(&dest->svc->stats.lock);
 
-		spin_lock(&ip_vs_stats.lock);
-		ip_vs_stats.ustats.inpkts++;
-		ip_vs_stats.ustats.inbytes += skb->len;
-		spin_unlock(&ip_vs_stats.lock);
+		spin_lock(&net->ipvs->ctl_stats->lock);
+		net->ipvs->ctl_stats->ustats.inpkts++;
+		net->ipvs->ctl_stats->ustats.inbytes += skb->len;
+		spin_unlock(&net->ipvs->ctl_stats->lock);
 	}
 }
 
@@ -131,7 +135,10 @@ static inline void
 ip_vs_out_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 {
 	struct ip_vs_dest *dest = cp->dest;
+	struct net *net = dev_net(skb->dev);
+
 	if (dest && (dest->flags & IP_VS_DEST_F_AVAILABLE)) {
+		struct ip_vs_stats *ctl_stats = net->ipvs->ctl_stats;
 		spin_lock(&dest->stats.lock);
 		dest->stats.ustats.outpkts++;
 		dest->stats.ustats.outbytes += skb->len;
@@ -142,16 +149,16 @@ ip_vs_out_stats(struct ip_vs_conn *cp, s
 		dest->svc->stats.ustats.outbytes += skb->len;
 		spin_unlock(&dest->svc->stats.lock);
 
-		spin_lock(&ip_vs_stats.lock);
-		ip_vs_stats.ustats.outpkts++;
-		ip_vs_stats.ustats.outbytes += skb->len;
-		spin_unlock(&ip_vs_stats.lock);
+		spin_lock(&ctl_stats->lock);
+		net->ipvs->ctl_stats->ustats.outpkts++;
+		net->ipvs->ctl_stats->ustats.outbytes += skb->len;
+		spin_unlock(&ctl_stats->lock);
 	}
 }
 
 
 static inline void
-ip_vs_conn_stats(struct ip_vs_conn *cp, struct ip_vs_service *svc)
+ip_vs_conn_stats(struct net *net, struct ip_vs_conn *cp, struct ip_vs_service *svc)
 {
 	spin_lock(&cp->dest->stats.lock);
 	cp->dest->stats.ustats.conns++;
@@ -161,9 +168,9 @@ ip_vs_conn_stats(struct ip_vs_conn *cp,
 	svc->stats.ustats.conns++;
 	spin_unlock(&svc->stats.lock);
 
-	spin_lock(&ip_vs_stats.lock);
-	ip_vs_stats.ustats.conns++;
-	spin_unlock(&ip_vs_stats.lock);
+	spin_lock(&net->ipvs->ctl_stats->lock);
+	net->ipvs->ctl_stats->ustats.conns++;
+	spin_unlock(&net->ipvs->ctl_stats->lock);
 }
 
 
@@ -178,13 +185,15 @@ ip_vs_set_state(struct ip_vs_conn *cp, i
 }
 
 static inline void
-ip_vs_conn_fill_param_persist(const struct ip_vs_service *svc,
+ip_vs_conn_fill_param_persist(struct net *net,
+			      const struct ip_vs_service *svc,
 			      struct sk_buff *skb, int protocol,
 			      const union nf_inet_addr *caddr, __be16 cport,
 			      const union nf_inet_addr *vaddr, __be16 vport,
 			      struct ip_vs_conn_param *p)
 {
-	ip_vs_conn_fill_param(svc->af, protocol, caddr, cport, vaddr, vport, p);
+	ip_vs_conn_fill_param(net, svc->af, protocol, caddr, cport,
+			      vaddr, vport, p);
 	p->pe = svc->pe;
 	if (p->pe && p->pe->fill_param)
 		p->pe->fill_param(p, skb);
@@ -211,6 +220,7 @@ ip_vs_sched_persist(struct ip_vs_service
 	struct ip_vs_conn_param param;
 	union nf_inet_addr snet;	/* source network of the client,
 					   after masking */
+	struct net *net = dev_net(skb->dev);
 
 	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
 
@@ -268,13 +278,13 @@ ip_vs_sched_persist(struct ip_vs_service
 				vaddr = &fwmark;
 			}
 		}
-		ip_vs_conn_fill_param_persist(svc, skb, protocol, &snet, 0,
+		ip_vs_conn_fill_param_persist(net, svc, skb, protocol, &snet, 0,
 					      vaddr, vport, &param);
 	}
 
 	/* Check if a template already exists */
 	ct = ip_vs_ct_in_get(&param);
-	if (!ct || !ip_vs_check_template(ct)) {
+	if (!ct || !ip_vs_check_template(net, ct)) {
 		/* No template found or the dest of the connection
 		 * template is not available.
 		 */
@@ -317,7 +327,7 @@ ip_vs_sched_persist(struct ip_vs_service
 	/*
 	 *    Create a new connection according to the template
 	 */
-	ip_vs_conn_fill_param(svc->af, iph.protocol, &iph.saddr, ports[0],
+	ip_vs_conn_fill_param(net, svc->af, iph.protocol, &iph.saddr, ports[0],
 			      &iph.daddr, ports[1], &param);
 	cp = ip_vs_conn_new(&param, &dest->addr, dport, flags, dest);
 	if (cp == NULL) {
@@ -331,7 +341,7 @@ ip_vs_sched_persist(struct ip_vs_service
 	ip_vs_control_add(cp, ct);
 	ip_vs_conn_put(ct);
 
-	ip_vs_conn_stats(cp, svc);
+	ip_vs_conn_stats(net, cp, svc);
 	return cp;
 }
 
@@ -351,6 +361,7 @@ ip_vs_schedule(struct ip_vs_service *svc
 	struct ip_vs_dest *dest;
 	__be16 _ports[2], *pptr;
 	unsigned int flags;
+	struct net *net = dev_net(skb->dev);
 
 	*ignored = 1;
 	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
@@ -419,7 +430,7 @@ ip_vs_schedule(struct ip_vs_service *svc
 	 */
 	{
 		struct ip_vs_conn_param p;
-		ip_vs_conn_fill_param(svc->af, iph.protocol, &iph.saddr,
+		ip_vs_conn_fill_param(net, svc->af, iph.protocol, &iph.saddr,
 				      pptr[0], &iph.daddr, pptr[1], &p);
 		cp = ip_vs_conn_new(&p, &dest->addr,
 				    dest->port ? dest->port : pptr[1],
@@ -436,7 +447,7 @@ ip_vs_schedule(struct ip_vs_service *svc
 		      IP_VS_DBG_ADDR(svc->af, &cp->daddr), ntohs(cp->dport),
 		      cp->flags, atomic_read(&cp->refcnt));
 
-	ip_vs_conn_stats(cp, svc);
+	ip_vs_conn_stats(net, cp, svc);
 	return cp;
 }
 
@@ -452,6 +463,8 @@ int ip_vs_leave(struct ip_vs_service *sv
 	__be16 _ports[2], *pptr;
 	struct ip_vs_iphdr iph;
 	int unicast;
+	struct net *net = dev_net(skb->dev);
+
 	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
 
 	pptr = skb_header_pointer(skb, iph.len, sizeof(_ports), _ports);
@@ -465,12 +478,12 @@ int ip_vs_leave(struct ip_vs_service *sv
 		unicast = ipv6_addr_type(&iph.daddr.in6) & IPV6_ADDR_UNICAST;
 	else
 #endif
-		unicast = (inet_addr_type(&init_net, iph.daddr.ip) == RTN_UNICAST);
+		unicast = (inet_addr_type(net, iph.daddr.ip) == RTN_UNICAST);
 
 	/* if it is fwmark-based service, the cache_bypass sysctl is up
 	   and the destination is a non-local unicast, then create
 	   a cache_bypass connection entry */
-	if (sysctl_ip_vs_cache_bypass && svc->fwmark && unicast) {
+	if (net->ipvs->sysctl_cache_bypass && svc->fwmark && unicast) {
 		int ret, cs;
 		struct ip_vs_conn *cp;
 		unsigned int flags = (svc->flags & IP_VS_SVC_F_ONEPACKET &&
@@ -484,7 +497,7 @@ int ip_vs_leave(struct ip_vs_service *sv
 		IP_VS_DBG(6, "%s(): create a cache_bypass entry\n", __func__);
 		{
 			struct ip_vs_conn_param p;
-			ip_vs_conn_fill_param(svc->af, iph.protocol,
+			ip_vs_conn_fill_param(net, svc->af, iph.protocol,
 					      &iph.saddr, pptr[0],
 					      &iph.daddr, pptr[1], &p);
 			cp = ip_vs_conn_new(&p, &daddr, 0,
@@ -683,6 +696,7 @@ static int handle_response_icmp(int af,
 				unsigned int offset, unsigned int ihl)
 {
 	unsigned int verdict = NF_DROP;
+	struct net *net = dev_net(skb->dev);
 
 	if (IP_VS_FWD_METHOD(cp) != 0) {
 		pr_err("shouldn't reach here, because the box is on the "
@@ -712,11 +726,12 @@ static int handle_response_icmp(int af,
 
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
-		if (sysctl_ip_vs_snat_reroute && ip6_route_me_harder(skb) != 0)
+		if (net->ipvs->sysctl_snat_reroute &&
+		    ip6_route_me_harder(skb) != 0)
 			goto out;
 	} else
 #endif
-		if ((sysctl_ip_vs_snat_reroute ||
+		if ((net->ipvs->sysctl_snat_reroute ||
 		     skb_rtable(skb)->rt_flags & RTCF_LOCAL) &&
 		    ip_route_me_harder(skb, RTN_LOCAL) != 0)
 			goto out;
@@ -927,6 +942,8 @@ static unsigned int
 handle_response(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		struct ip_vs_conn *cp, int ihl)
 {
+	struct net *net = dev_net(skb->dev);
+
 	IP_VS_DBG_PKT(11, af, pp, skb, 0, "Outgoing packet");
 
 	if (!skb_make_writable(skb, ihl))
@@ -963,11 +980,12 @@ handle_response(int af, struct sk_buff *
 	 */
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
-		if (sysctl_ip_vs_snat_reroute && ip6_route_me_harder(skb) != 0)
+		if (net->ipvs->sysctl_snat_reroute &&
+		    ip6_route_me_harder(skb) != 0)
 			goto drop;
 	} else
 #endif
-		if ((sysctl_ip_vs_snat_reroute ||
+		if ((net->ipvs->sysctl_snat_reroute ||
 		     skb_rtable(skb)->rt_flags & RTCF_LOCAL) &&
 		    ip_route_me_harder(skb, RTN_LOCAL) != 0)
 			goto drop;
@@ -1002,6 +1020,7 @@ ip_vs_out(unsigned int hooknum, struct s
 	struct ip_vs_iphdr iph;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_conn *cp;
+	struct net *net = dev_net(skb->dev);
 
 	EnterFunction(11);
 
@@ -1077,7 +1096,7 @@ ip_vs_out(unsigned int hooknum, struct s
 
 	if (likely(cp))
 		return handle_response(af, skb, pp, cp, iph.len);
-	if (sysctl_ip_vs_nat_icmp_send &&
+	if (net->ipvs->sysctl_nat_icmp_send &&
 	    (pp->protocol == IPPROTO_TCP ||
 	     pp->protocol == IPPROTO_UDP ||
 	     pp->protocol == IPPROTO_SCTP)) {
@@ -1087,7 +1106,7 @@ ip_vs_out(unsigned int hooknum, struct s
 					  sizeof(_ports), _ports);
 		if (pptr == NULL)
 			return NF_ACCEPT;	/* Not for me */
-		if (ip_vs_lookup_real_service(af, iph.protocol,
+		if (ip_vs_lookup_real_service(net, af, iph.protocol,
 					      &iph.saddr,
 					      pptr[0])) {
 			/*
@@ -1427,6 +1446,7 @@ ip_vs_in(unsigned int hooknum, struct sk
 	struct ip_vs_protocol *pp;
 	struct ip_vs_conn *cp;
 	int ret, restart, pkts;
+	struct net *net = dev_net(skb->dev);
 
 	/* Already marked as IPVS request or reply? */
 	if (skb->ipvs_property)
@@ -1510,7 +1530,7 @@ ip_vs_in(unsigned int hooknum, struct sk
 	if (cp->dest && !(cp->dest->flags & IP_VS_DEST_F_AVAILABLE)) {
 		/* the destination server is not available */
 
-		if (sysctl_ip_vs_expire_nodest_conn) {
+		if (net->ipvs->sysctl_expire_nodest_conn) {
 			/* try to expire the connection immediately */
 			ip_vs_conn_expire_now(cp);
 		}
@@ -1537,33 +1557,33 @@ ip_vs_in(unsigned int hooknum, struct sk
 	 * encorage the standby servers to update the connections timeout
 	 */
 	pkts = atomic_add_return(1, &cp->in_pkts);
-	if (af == AF_INET && (ip_vs_sync_state & IP_VS_STATE_MASTER) &&
+	if (af == AF_INET && (net->ipvs->sync_state & IP_VS_STATE_MASTER) &&
 	    cp->protocol == IPPROTO_SCTP) {
 		if ((cp->state == IP_VS_SCTP_S_ESTABLISHED &&
-			(pkts % sysctl_ip_vs_sync_threshold[1]
-			 == sysctl_ip_vs_sync_threshold[0])) ||
+			(pkts % net->ipvs->sysctl_sync_threshold[1]
+			 == net->ipvs->sysctl_sync_threshold[0])) ||
 				(cp->old_state != cp->state &&
 				 ((cp->state == IP_VS_SCTP_S_CLOSED) ||
 				  (cp->state == IP_VS_SCTP_S_SHUT_ACK_CLI) ||
 				  (cp->state == IP_VS_SCTP_S_SHUT_ACK_SER)))) {
-			ip_vs_sync_conn(cp);
+			ip_vs_sync_conn(net, cp);
 			goto out;
 		}
 	}
 
 	/* Keep this block last: TCP and others with pp->num_states <= 1 */
 	else if (af == AF_INET &&
-	    (ip_vs_sync_state & IP_VS_STATE_MASTER) &&
+	    (net->ipvs->sync_state & IP_VS_STATE_MASTER) &&
 	    (((cp->protocol != IPPROTO_TCP ||
 	       cp->state == IP_VS_TCP_S_ESTABLISHED) &&
-	      (pkts % sysctl_ip_vs_sync_threshold[1]
-	       == sysctl_ip_vs_sync_threshold[0])) ||
+	      (pkts % net->ipvs->sysctl_sync_threshold[1]
+	       == net->ipvs->sysctl_sync_threshold[0])) ||
 	     ((cp->protocol == IPPROTO_TCP) && (cp->old_state != cp->state) &&
 	      ((cp->state == IP_VS_TCP_S_FIN_WAIT) ||
 	       (cp->state == IP_VS_TCP_S_CLOSE) ||
 	       (cp->state == IP_VS_TCP_S_CLOSE_WAIT) ||
 	       (cp->state == IP_VS_TCP_S_TIME_WAIT)))))
-		ip_vs_sync_conn(cp);
+		ip_vs_sync_conn(net,cp);
 out:
 	cp->old_state = cp->state;
 
@@ -1782,7 +1802,37 @@ static struct nf_hook_ops ip_vs_ops[] __
 	},
 #endif
 };
+/*
+ *	Initialize IP Virtual Server netns mem.
+ */
+static int __net_init __ip_vs_init(struct net *net)
+{
+	struct netns_ipvs *ipvs = 0;
 
+	ipvs = kzalloc(sizeof(struct netns_ipvs), GFP_ATOMIC);
+	if( ipvs == NULL ) {
+		pr_err("%s(): no memory.\n", __func__);
+		return -ENOMEM;
+	}
+	ipvs->inc = atomic_read(&ipvs_netns_cnt);
+	atomic_inc(&ipvs_netns_cnt);
+	IP_VS_DBG(10, "Creating new netns *net=%p *ipvs=%p size=%lu\n",
+		     net, ipvs, sizeof(struct netns_ipvs));
+	net->ipvs = ipvs;
+
+	return 0;
+}
+
+static void __net_exit __ip_vs_cleanup(struct net *net)
+{
+	IP_VS_DBG(10, "ipvs netns %p released\n", net);
+	kfree(net->ipvs);
+}
+
+static struct pernet_operations ipvs_core_ops = {
+	.init = __ip_vs_init,
+	.exit = __ip_vs_cleanup,
+};
 
 /*
  *	Initialize IP Virtual Server
@@ -1791,6 +1841,10 @@ static int __init ip_vs_init(void)
 {
 	int ret;
 
+	ret = register_pernet_subsys(&ipvs_core_ops);	/* Alloc ip_vs struct */
+	if( ret < 0 )
+		return ret;
+
 	ip_vs_estimator_init();
 
 	ret = ip_vs_control_init();
@@ -1813,15 +1867,22 @@ static int __init ip_vs_init(void)
 		goto cleanup_app;
 	}
 
+	ret = ip_vs_sync_init();
+	if (ret < 0) {
+		pr_err("can't setup sync data.\n");
+		goto cleanup_conn;
+	}
 	ret = nf_register_hooks(ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
 	if (ret < 0) {
 		pr_err("can't register hooks.\n");
-		goto cleanup_conn;
+		goto cleanup_sync;
 	}
 
 	pr_info("ipvs loaded.\n");
 	return ret;
 
+  cleanup_sync:
+  	ip_vs_sync_cleanup();
   cleanup_conn:
 	ip_vs_conn_cleanup();
   cleanup_app:
@@ -1831,17 +1892,20 @@ static int __init ip_vs_init(void)
 	ip_vs_control_cleanup();
   cleanup_estimator:
 	ip_vs_estimator_cleanup();
+	unregister_pernet_subsys(&ipvs_core_ops);	/* free ip_vs struct */
 	return ret;
 }
 
 static void __exit ip_vs_cleanup(void)
 {
 	nf_unregister_hooks(ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
+	ip_vs_sync_cleanup();
 	ip_vs_conn_cleanup();
 	ip_vs_app_cleanup();
 	ip_vs_protocol_cleanup();
 	ip_vs_control_cleanup();
 	ip_vs_estimator_cleanup();
+	unregister_pernet_subsys(&ipvs_core_ops);	/* free ip_vs struct */
 	pr_info("ipvs unloaded.\n");
 }
 

