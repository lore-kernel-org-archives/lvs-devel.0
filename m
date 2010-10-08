From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [RFC PATCH 4/9] ipvs network name space aware
Date: Fri, 8 Oct 2010 13:16:59 +0200
Message-ID: <201010081317.01120.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org, daniel.lezcano@free.fr

This patch just contains ip_vs_core.c

Signed-off-by:Hans Schillstrom <hans.schillstrom@ericsson.com>

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 0c043b6..4fdc5cb 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -52,7 +52,6 @@

 #include <net/ip_vs.h>

-
 EXPORT_SYMBOL(register_ip_vs_scheduler);
 EXPORT_SYMBOL(unregister_ip_vs_scheduler);
 EXPORT_SYMBOL(ip_vs_proto_name);
@@ -67,6 +66,8 @@ EXPORT_SYMBOL(ip_vs_conn_put);
 EXPORT_SYMBOL(ip_vs_get_debug_level);
 #endif

+/* netns cnt used for uniqueness */
+static atomic_t ipvs_netns_cnt = ATOMIC_INIT(0);

 /* ID used in ICMP lookups */
 #define icmp_id(icmph)          (((icmph)->un).echo.id)
@@ -107,6 +108,8 @@ static inline void
 ip_vs_in_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 {
 	struct ip_vs_dest *dest = cp->dest;
+	struct net *net = dev_net(skb->dev);
+
 	if (dest && (dest->flags & IP_VS_DEST_F_AVAILABLE)) {
 		spin_lock(&dest->stats.lock);
 		dest->stats.ustats.inpkts++;
@@ -118,10 +121,10 @@ ip_vs_in_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
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

@@ -130,7 +133,10 @@ static inline void
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
@@ -141,16 +147,16 @@ ip_vs_out_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
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
@@ -160,9 +166,9 @@ ip_vs_conn_stats(struct ip_vs_conn *cp, struct ip_vs_service *svc)
 	svc->stats.ustats.conns++;
 	spin_unlock(&svc->stats.lock);

-	spin_lock(&ip_vs_stats.lock);
-	ip_vs_stats.ustats.conns++;
-	spin_unlock(&ip_vs_stats.lock);
+	spin_lock(&net->ipvs->ctl_stats->lock);
+	net->ipvs->ctl_stats->ustats.conns++;
+	spin_unlock(&net->ipvs->ctl_stats->lock);
 }


@@ -197,6 +203,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	__be16  flags;
 	union nf_inet_addr snet;	/* source network of the client,
 					   after masking */
+	struct net *net = dev_net(skb->dev);

 	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);

@@ -230,13 +237,13 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	if (ports[1] == svc->port) {
 		/* Check if a template already exists */
 		if (svc->port != FTPPORT)
-			ct = ip_vs_ct_in_get(svc->af, iph.protocol, &snet, 0,
-					     &iph.daddr, ports[1]);
+			ct = ip_vs_ct_in_get(net, svc->af, iph.protocol, &snet,
+					     0, &iph.daddr, ports[1]);
 		else
-			ct = ip_vs_ct_in_get(svc->af, iph.protocol, &snet, 0,
-					     &iph.daddr, 0);
+			ct = ip_vs_ct_in_get(net, svc->af, iph.protocol, &snet,
+					     0, &iph.daddr, 0);

-		if (!ct || !ip_vs_check_template(ct)) {
+		if (!ct || !ip_vs_check_template(net, ct)) {
 			/*
 			 * No template found or the dest of the connection
 			 * template is not available.
@@ -254,7 +261,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 			 * for ftp service.
 			 */
 			if (svc->port != FTPPORT)
-				ct = ip_vs_conn_new(svc->af, iph.protocol,
+				ct = ip_vs_conn_new(net, svc->af, iph.protocol,
 						    &snet, 0,
 						    &iph.daddr,
 						    ports[1],
@@ -262,7 +269,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 						    IP_VS_CONN_F_TEMPLATE,
 						    dest);
 			else
-				ct = ip_vs_conn_new(svc->af, iph.protocol,
+				ct = ip_vs_conn_new(net, svc->af, iph.protocol,
 						    &snet, 0,
 						    &iph.daddr, 0,
 						    &dest->addr, 0,
@@ -289,13 +296,13 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 				.ip = htonl(svc->fwmark)
 			};

-			ct = ip_vs_ct_in_get(svc->af, IPPROTO_IP, &snet, 0,
-					     &fwmark, 0);
+			ct = ip_vs_ct_in_get(net, svc->af, IPPROTO_IP, &snet,
+					     0, &fwmark, 0);
 		} else
-			ct = ip_vs_ct_in_get(svc->af, iph.protocol, &snet, 0,
-					     &iph.daddr, 0);
+			ct = ip_vs_ct_in_get(net, svc->af, iph.protocol, &snet,
+					     0, &iph.daddr, 0);

-		if (!ct || !ip_vs_check_template(ct)) {
+		if (!ct || !ip_vs_check_template(net, ct)) {
 			/*
 			 * If it is not persistent port zero, return NULL,
 			 * otherwise create a connection template.
@@ -317,14 +324,14 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 					.ip = htonl(svc->fwmark)
 				};

-				ct = ip_vs_conn_new(svc->af, IPPROTO_IP,
+				ct = ip_vs_conn_new(net, svc->af, IPPROTO_IP,
 						    &snet, 0,
 						    &fwmark, 0,
 						    &dest->addr, 0,
 						    IP_VS_CONN_F_TEMPLATE,
 						    dest);
 			} else
-				ct = ip_vs_conn_new(svc->af, iph.protocol,
+				ct = ip_vs_conn_new(net, svc->af, iph.protocol,
 						    &snet, 0,
 						    &iph.daddr, 0,
 						    &dest->addr, 0,
@@ -348,7 +355,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	/*
 	 *    Create a new connection according to the template
 	 */
-	cp = ip_vs_conn_new(svc->af, iph.protocol,
+	cp = ip_vs_conn_new(net, svc->af, iph.protocol,
 			    &iph.saddr, ports[0],
 			    &iph.daddr, ports[1],
 			    &dest->addr, dport,
@@ -365,7 +372,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	ip_vs_control_add(cp, ct);
 	ip_vs_conn_put(ct);

-	ip_vs_conn_stats(cp, svc);
+	ip_vs_conn_stats(net, cp, svc);
 	return cp;
 }

@@ -383,6 +390,7 @@ ip_vs_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	struct ip_vs_iphdr iph;
 	struct ip_vs_dest *dest;
 	__be16 _ports[2], *pptr, flags;
+	struct net *net = dev_net(skb->dev);

 	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
 	pptr = skb_header_pointer(skb, iph.len, sizeof(_ports), _ports);
@@ -415,11 +423,10 @@ ip_vs_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	flags = (svc->flags & IP_VS_SVC_F_ONEPACKET
 		 && iph.protocol == IPPROTO_UDP)?
 		IP_VS_CONN_F_ONE_PACKET : 0;
-
 	/*
 	 *    Create a connection entry.
 	 */
-	cp = ip_vs_conn_new(svc->af, iph.protocol,
+	cp = ip_vs_conn_new(net, svc->af, iph.protocol,
 			    &iph.saddr, pptr[0],
 			    &iph.daddr, pptr[1],
 			    &dest->addr, dest->port ? dest->port : pptr[1],
@@ -436,7 +443,7 @@ ip_vs_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		      IP_VS_DBG_ADDR(svc->af, &cp->daddr), ntohs(cp->dport),
 		      cp->flags, atomic_read(&cp->refcnt));

-	ip_vs_conn_stats(cp, svc);
+	ip_vs_conn_stats(net, cp, svc);
 	return cp;
 }

@@ -452,6 +459,8 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 	__be16 _ports[2], *pptr;
 	struct ip_vs_iphdr iph;
 	int unicast;
+	struct net *net = dev_net(skb->dev);
+
 	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);

 	pptr = skb_header_pointer(skb, iph.len, sizeof(_ports), _ports);
@@ -465,12 +474,12 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
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
 		__u16 flags = (svc->flags & IP_VS_SVC_F_ONEPACKET &&
@@ -482,7 +491,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,

 		/* create a new connection entry */
 		IP_VS_DBG(6, "%s(): create a cache_bypass entry\n", __func__);
-		cp = ip_vs_conn_new(svc->af, iph.protocol,
+		cp = ip_vs_conn_new(net, svc->af, iph.protocol,
 				    &iph.saddr, pptr[0],
 				    &iph.daddr, pptr[1],
 				    &daddr, 0,
@@ -954,6 +963,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
 	struct ip_vs_protocol *pp;
 	struct ip_vs_conn *cp;
 	int af;
+	struct net *net = dev_net(skb->dev);

 	EnterFunction(11);

@@ -1013,7 +1023,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
 	cp = pp->conn_out_get(af, skb, pp, &iph, iph.len, 0);

 	if (unlikely(!cp)) {
-		if (sysctl_ip_vs_nat_icmp_send &&
+		if (net->ipvs->sysctl_nat_icmp_send &&
 		    (pp->protocol == IPPROTO_TCP ||
 		     pp->protocol == IPPROTO_UDP ||
 		     pp->protocol == IPPROTO_SCTP)) {
@@ -1023,7 +1033,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
 						  sizeof(_ports), _ports);
 			if (pptr == NULL)
 				return NF_ACCEPT;	/* Not for me */
-			if (ip_vs_lookup_real_service(af, iph.protocol,
+			if (ip_vs_lookup_real_service(net, af, iph.protocol,
 						      &iph.saddr,
 						      pptr[0])) {
 				/*
@@ -1283,6 +1293,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
 	struct ip_vs_protocol *pp;
 	struct ip_vs_conn *cp;
 	int ret, restart, af, pkts;
+	struct net *net = dev_net(skb->dev);

 	af = (skb->protocol == htons(ETH_P_IP)) ? AF_INET : AF_INET6;

@@ -1354,7 +1365,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
 	if (cp->dest && !(cp->dest->flags & IP_VS_DEST_F_AVAILABLE)) {
 		/* the destination server is not available */

-		if (sysctl_ip_vs_expire_nodest_conn) {
+		if (net->ipvs->sysctl_expire_nodest_conn) {
 			/* try to expire the connection immediately */
 			ip_vs_conn_expire_now(cp);
 		}
@@ -1381,33 +1392,33 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
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

@@ -1512,7 +1523,37 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
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
@@ -1521,8 +1562,11 @@ static int __init ip_vs_init(void)
 {
 	int ret;

-	ip_vs_estimator_init();
+	ret = register_pernet_subsys(&ipvs_core_ops);	/* Alloc ip_vs struct */
+	if( ret < 0 )
+		return ret;

+	ip_vs_estimator_init();
 	ret = ip_vs_control_init();
 	if (ret < 0) {
 		pr_err("can't setup control.\n");
@@ -1530,28 +1574,30 @@ static int __init ip_vs_init(void)
 	}

 	ip_vs_protocol_init();
-
 	ret = ip_vs_app_init();
 	if (ret < 0) {
 		pr_err("can't setup application helper.\n");
 		goto cleanup_protocol;
 	}
-
 	ret = ip_vs_conn_init();
 	if (ret < 0) {
 		pr_err("can't setup connection table.\n");
 		goto cleanup_app;
 	}
-
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
-
 	pr_info("ipvs loaded.\n");
 	return ret;
-
+  cleanup_sync:
+  	ip_vs_sync_cleanup();
   cleanup_conn:
 	ip_vs_conn_cleanup();
   cleanup_app:
@@ -1561,17 +1607,20 @@ static int __init ip_vs_init(void)
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


-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
