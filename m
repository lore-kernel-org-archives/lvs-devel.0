From: Simon Horman <horms@verge.net.au>
Subject: [rfc v2 08/10] ipvs network name space aware: ftp
Date: Fri, 22 Oct 2010 22:09:42 +0200
Message-ID: <20101022202400.938869895@joe.akashicho.tokyo.vergenet.net>
References: <20101022200934.822223308@joe.akashicho.tokyo.vergenet.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=ipvs-netns-7.patch
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, Julian Anastasov <ja@ssi.bg>, Daniel Lezcano <daniel.lezcano@free.fr>, Wensong Zhang <wensong@linux-vs.org>

This patch just contains ip_vs_ftp.c

minor changes.

Signed-off-by:Hans Schillstrom <hans.schillstrom@ericsson.com>

Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_ftp.c
===================================================================
--- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_ftp.c	2010-10-22 20:28:10.000000000 +0200
+++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_ftp.c	2010-10-22 20:30:58.000000000 +0200
@@ -157,6 +157,7 @@ static int ip_vs_ftp_out(struct ip_vs_ap
 	int ret = 0;
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct;
+	struct net *net = dev_net(skb->dev);
 
 #ifdef CONFIG_IP_VS_IPV6
 	/* This application helper doesn't work with IPv6 yet,
@@ -197,13 +198,14 @@ static int ip_vs_ftp_out(struct ip_vs_ap
 		 */
 		{
 			struct ip_vs_conn_param p;
-			ip_vs_conn_fill_param(AF_INET, iph->protocol,
+			ip_vs_conn_fill_param(net, AF_INET, iph->protocol,
 					      &from, port, &cp->caddr, 0, &p);
 			n_cp = ip_vs_conn_out_get(&p);
 		}
 		if (!n_cp) {
 			struct ip_vs_conn_param p;
-			ip_vs_conn_fill_param(AF_INET, IPPROTO_TCP, &cp->caddr,
+			ip_vs_conn_fill_param(net, AF_INET, IPPROTO_TCP,
+					      &cp->caddr,
 					      0, &cp->vaddr, port, &p);
 			n_cp = ip_vs_conn_new(&p, &from, port,
 					      IP_VS_CONN_F_NO_CPORT |
@@ -258,7 +260,7 @@ static int ip_vs_ftp_out(struct ip_vs_ap
 		 */
 
 		cp->app_data = NULL;
-		ip_vs_tcp_conn_listen(n_cp);
+		ip_vs_tcp_conn_listen(net, n_cp);
 		ip_vs_conn_put(n_cp);
 		return ret;
 	}
@@ -287,6 +289,7 @@ static int ip_vs_ftp_in(struct ip_vs_app
 	union nf_inet_addr to;
 	__be16 port;
 	struct ip_vs_conn *n_cp;
+	struct net *net = dev_net(skb->dev);
 
 #ifdef CONFIG_IP_VS_IPV6
 	/* This application helper doesn't work with IPv6 yet,
@@ -358,7 +361,7 @@ static int ip_vs_ftp_in(struct ip_vs_app
 
 	{
 		struct ip_vs_conn_param p;
-		ip_vs_conn_fill_param(AF_INET, iph->protocol, &to, port,
+		ip_vs_conn_fill_param(net, AF_INET, iph->protocol, &to, port,
 				      &cp->vaddr, htons(ntohs(cp->vport)-1),
 				      &p);
 		n_cp = ip_vs_conn_in_get(&p);
@@ -377,7 +380,7 @@ static int ip_vs_ftp_in(struct ip_vs_app
 	/*
 	 *	Move tunnel to listen state
 	 */
-	ip_vs_tcp_conn_listen(n_cp);
+	ip_vs_tcp_conn_listen(net, n_cp);
 	ip_vs_conn_put(n_cp);
 
 	return 1;
@@ -398,23 +401,22 @@ static struct ip_vs_app ip_vs_ftp = {
 	.pkt_in =	ip_vs_ftp_in,
 };
 
-
 /*
- *	ip_vs_ftp initialization
+ *	per netns ip_vs_ftp initialization
  */
-static int __init ip_vs_ftp_init(void)
+static int __net_init __ip_vs_ftp_init(struct net *net)
 {
 	int i, ret;
 	struct ip_vs_app *app = &ip_vs_ftp;
 
-	ret = register_ip_vs_app(app);
+	ret = register_ip_vs_app(net, app);
 	if (ret)
 		return ret;
 
 	for (i=0; i<IP_VS_APP_MAX_PORTS; i++) {
 		if (!ports[i])
 			continue;
-		ret = register_ip_vs_app_inc(app, app->protocol, ports[i]);
+		ret = register_ip_vs_app_inc(net, app, app->protocol, ports[i]);
 		if (ret)
 			break;
 		pr_info("%s: loaded support on port[%d] = %d\n",
@@ -422,18 +424,39 @@ static int __init ip_vs_ftp_init(void)
 	}
 
 	if (ret)
-		unregister_ip_vs_app(app);
+		unregister_ip_vs_app(net, app);
 
 	return ret;
 }
+/*
+ * 	netns exit
+ */
+static void __ip_vs_ftp_exit(struct net *net)
+{
+	struct ip_vs_app *app = &ip_vs_ftp;
+
+	unregister_ip_vs_app(net, app);
+}
+
+static struct pernet_operations ip_vs_ftp_ops = {
+	.init = __ip_vs_ftp_init,
+	.exit = __ip_vs_ftp_exit,
+};
 
+int __init ip_vs_ftp_init(void)
+{
+	int rv;
+
+	rv = register_pernet_subsys(&ip_vs_ftp_ops);
+	return rv;
+}
 
 /*
  *	ip_vs_ftp finish.
  */
 static void __exit ip_vs_ftp_exit(void)
 {
-	unregister_ip_vs_app(&ip_vs_ftp);
+	unregister_pernet_subsys(&ip_vs_ftp_ops);
 }
 
 
Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_nfct.c
===================================================================
--- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_nfct.c	2010-10-22 20:28:10.000000000 +0200
+++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_nfct.c	2010-10-22 20:29:28.000000000 +0200
@@ -141,6 +141,7 @@ static void ip_vs_nfct_expect_callback(s
 	struct nf_conntrack_tuple *orig, new_reply;
 	struct ip_vs_conn *cp;
 	struct ip_vs_conn_param p;
+	struct net *net = nf_ct_net(ct);
 
 	if (exp->tuple.src.l3num != PF_INET)
 		return;
@@ -155,7 +156,7 @@ static void ip_vs_nfct_expect_callback(s
 
 	/* RS->CLIENT */
 	orig = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
-	ip_vs_conn_fill_param(exp->tuple.src.l3num, orig->dst.protonum,
+	ip_vs_conn_fill_param(net, exp->tuple.src.l3num, orig->dst.protonum,
 			      &orig->src.u3, orig->src.u.tcp.port,
 			      &orig->dst.u3, orig->dst.u.tcp.port, &p);
 	cp = ip_vs_conn_out_get(&p);

