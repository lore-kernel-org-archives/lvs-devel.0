From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [RFC PATCH 7/9] ipvs network name space aware
Date: Fri, 8 Oct 2010 13:17:08 +0200
Message-ID: <201010081317.09621.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org, daniel.lezcano@free.fr

This patch just contains ip_vs_ftp.c

minor changes.

Signed-off-by:Hans Schillstrom <hans.schillstrom@ericsson.com>

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 7e9af5b..9d54eb0 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -157,7 +157,8 @@ ip_vs_expect_callback(struct nf_conn *ct,
 {
 	struct nf_conntrack_tuple *orig, new_reply;
 	struct ip_vs_conn *cp;
-
+	struct net *net = nf_ct_net(ct);
+
 	if (exp->tuple.src.l3num != PF_INET)
 		return;

@@ -168,10 +169,10 @@ ip_vs_expect_callback(struct nf_conn *ct,
 	 * actual values from the newly created original conntrack direction.
 	 * The conntrack is confirmed when packet reaches IPVS hooks.
 	 */
-
+	BUG_ON(!net);
 	/* RS->CLIENT */
 	orig = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
-	cp = ip_vs_conn_out_get(exp->tuple.src.l3num, orig->dst.protonum,
+	cp = ip_vs_conn_out_get(net, exp->tuple.src.l3num, orig->dst.protonum,
 				&orig->src.u3, orig->src.u.tcp.port,
 				&orig->dst.u3, orig->dst.u.tcp.port);
 	if (cp) {
@@ -193,7 +194,7 @@ ip_vs_expect_callback(struct nf_conn *ct,
 	}

 	/* CLIENT->VS */
-	cp = ip_vs_conn_in_get(exp->tuple.src.l3num, orig->dst.protonum,
+	cp = ip_vs_conn_in_get(net, exp->tuple.src.l3num, orig->dst.protonum,
 			       &orig->src.u3, orig->src.u.tcp.port,
 			       &orig->dst.u3, orig->dst.u.tcp.port);
 	if (cp) {
@@ -290,7 +291,8 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	int ret = 0;
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct;
-
+	struct net *net = dev_net(skb->dev);
+
 #ifdef CONFIG_IP_VS_IPV6
 	/* This application helper doesn't work with IPv6 yet,
 	 * so turn this into a no-op for IPv6 packets
@@ -328,10 +330,10 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		/*
 		 * Now update or create an connection entry for it
 		 */
-		n_cp = ip_vs_conn_out_get(AF_INET, iph->protocol, &from, port,
-					  &cp->caddr, 0);
+		n_cp = ip_vs_conn_out_get(net, AF_INET, iph->protocol,
+				          &from, port, &cp->caddr, 0);
 		if (!n_cp) {
-			n_cp = ip_vs_conn_new(AF_INET, IPPROTO_TCP,
+			n_cp = ip_vs_conn_new(net, AF_INET, IPPROTO_TCP,
 					      &cp->caddr, 0,
 					      &cp->vaddr, port,
 					      &from, port,
@@ -381,7 +383,7 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		 */

 		cp->app_data = NULL;
-		ip_vs_tcp_conn_listen(n_cp);
+		ip_vs_tcp_conn_listen(net, n_cp);
 		ip_vs_conn_put(n_cp);
 		return ret;
 	}
@@ -410,6 +412,8 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	union nf_inet_addr to;
 	__be16 port;
 	struct ip_vs_conn *n_cp;
+	struct nf_conn *ct;
+	struct net *net = dev_net(skb->dev);

 #ifdef CONFIG_IP_VS_IPV6
 	/* This application helper doesn't work with IPv6 yet,
@@ -479,11 +483,11 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		  ip_vs_proto_name(iph->protocol),
 		  &to.ip, ntohs(port), &cp->vaddr.ip, 0);

-	n_cp = ip_vs_conn_in_get(AF_INET, iph->protocol,
+	n_cp = ip_vs_conn_in_get(net, AF_INET, iph->protocol,
 				 &to, port,
 				 &cp->vaddr, htons(ntohs(cp->vport)-1));
 	if (!n_cp) {
-		n_cp = ip_vs_conn_new(AF_INET, IPPROTO_TCP,
+		n_cp = ip_vs_conn_new(net, AF_INET, IPPROTO_TCP,
 				      &to, port,
 				      &cp->vaddr, htons(ntohs(cp->vport)-1),
 				      &cp->daddr, htons(ntohs(cp->dport)-1),
@@ -499,7 +503,7 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	/*
 	 *	Move tunnel to listen state
 	 */
-	ip_vs_tcp_conn_listen(n_cp);
+	ip_vs_tcp_conn_listen(net, n_cp);
 	ip_vs_conn_put(n_cp);

 	return 1;
@@ -520,23 +524,22 @@ static struct ip_vs_app ip_vs_ftp = {
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
-
-	ret = register_ip_vs_app(app);
+
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
@@ -544,18 +547,39 @@ static int __init ip_vs_ftp_init(void)
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
+
+int __init ip_vs_ftp_init(void)
+{
+	int rv;

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



-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
