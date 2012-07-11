From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 2/2] ipvs: generalize app registration in netns
Date: Wed, 11 Jul 2012 09:25:27 +0900
Message-ID: <1341966327-16606-3-git-send-email-horms@verge.net.au>
References: <1341966327-16606-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1341966327-16606-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

	Get rid of the ftp_app pointer and allow applications
to be registered without adding fields in the netns_ipvs structure.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h            |  5 ++--
 net/netfilter/ipvs/ip_vs_app.c | 61 +++++++++++++++++++++++++++++++-----------
 net/netfilter/ipvs/ip_vs_ftp.c | 21 ++++-----------
 3 files changed, 52 insertions(+), 35 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index d6146b4..6cb4699 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -808,8 +808,6 @@ struct netns_ipvs {
 	struct list_head	rs_table[IP_VS_RTAB_SIZE];
 	/* ip_vs_app */
 	struct list_head	app_list;
-	/* ip_vs_ftp */
-	struct ip_vs_app	*ftp_app;
 	/* ip_vs_proto */
 	#define IP_VS_PROTO_TAB_SIZE	32	/* must be power of 2 */
 	struct ip_vs_proto_data *proto_data_table[IP_VS_PROTO_TAB_SIZE];
@@ -1179,7 +1177,8 @@ extern void ip_vs_service_net_cleanup(struct net *net);
  *      (from ip_vs_app.c)
  */
 #define IP_VS_APP_MAX_PORTS  8
-extern int register_ip_vs_app(struct net *net, struct ip_vs_app *app);
+extern struct ip_vs_app *register_ip_vs_app(struct net *net,
+					    struct ip_vs_app *app);
 extern void unregister_ip_vs_app(struct net *net, struct ip_vs_app *app);
 extern int ip_vs_bind_app(struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
 extern void ip_vs_unbind_app(struct ip_vs_conn *cp);
diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index 64f9e8f..11caaea 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -180,22 +180,41 @@ register_ip_vs_app_inc(struct net *net, struct ip_vs_app *app, __u16 proto,
 }
 
 
-/*
- *	ip_vs_app registration routine
- */
-int register_ip_vs_app(struct net *net, struct ip_vs_app *app)
+/* Register application for netns */
+struct ip_vs_app *register_ip_vs_app(struct net *net, struct ip_vs_app *app)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
-	/* increase the module use count */
-	ip_vs_use_count_inc();
+	struct ip_vs_app *a;
+	int err = 0;
+
+	if (!ipvs)
+		return ERR_PTR(-ENOENT);
 
 	mutex_lock(&__ip_vs_app_mutex);
 
-	list_add(&app->a_list, &ipvs->app_list);
+	list_for_each_entry(a, &ipvs->app_list, a_list) {
+		if (!strcmp(app->name, a->name)) {
+			err = -EEXIST;
+			break;
+		}
+	}
+	if (!err) {
+		a = kmemdup(app, sizeof(*app), GFP_KERNEL);
+		if (!a)
+			err = -ENOMEM;
+	}
+	if (!err) {
+		INIT_LIST_HEAD(&a->incs_list);
+		list_add(&a->a_list, &ipvs->app_list);
+		/* increase the module use count */
+		ip_vs_use_count_inc();
+	}
 
 	mutex_unlock(&__ip_vs_app_mutex);
 
-	return 0;
+	if (err)
+		return ERR_PTR(err);
+	return a;
 }
 
 
@@ -205,20 +224,29 @@ int register_ip_vs_app(struct net *net, struct ip_vs_app *app)
  */
 void unregister_ip_vs_app(struct net *net, struct ip_vs_app *app)
 {
-	struct ip_vs_app *inc, *nxt;
+	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct ip_vs_app *a, *anxt, *inc, *nxt;
+
+	if (!ipvs)
+		return;
 
 	mutex_lock(&__ip_vs_app_mutex);
 
-	list_for_each_entry_safe(inc, nxt, &app->incs_list, a_list) {
-		ip_vs_app_inc_release(net, inc);
-	}
+	list_for_each_entry_safe(a, anxt, &ipvs->app_list, a_list) {
+		if (app && strcmp(app->name, a->name))
+			continue;
+		list_for_each_entry_safe(inc, nxt, &a->incs_list, a_list) {
+			ip_vs_app_inc_release(net, inc);
+		}
 
-	list_del(&app->a_list);
+		list_del(&a->a_list);
+		kfree(a);
 
-	mutex_unlock(&__ip_vs_app_mutex);
+		/* decrease the module use count */
+		ip_vs_use_count_dec();
+	}
 
-	/* decrease the module use count */
-	ip_vs_use_count_dec();
+	mutex_unlock(&__ip_vs_app_mutex);
 }
 
 
@@ -586,5 +614,6 @@ int __net_init ip_vs_app_net_init(struct net *net)
 
 void __net_exit ip_vs_app_net_cleanup(struct net *net)
 {
+	unregister_ip_vs_app(net, NULL /* all */);
 	proc_net_remove(net, "ip_vs_app");
 }
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index b20b29c..ad70b7e 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -441,16 +441,10 @@ static int __net_init __ip_vs_ftp_init(struct net *net)
 
 	if (!ipvs)
 		return -ENOENT;
-	app = kmemdup(&ip_vs_ftp, sizeof(struct ip_vs_app), GFP_KERNEL);
-	if (!app)
-		return -ENOMEM;
-	INIT_LIST_HEAD(&app->a_list);
-	INIT_LIST_HEAD(&app->incs_list);
-	ipvs->ftp_app = app;
 
-	ret = register_ip_vs_app(net, app);
-	if (ret)
-		goto err_exit;
+	app = register_ip_vs_app(net, &ip_vs_ftp);
+	if (IS_ERR(app))
+		return PTR_ERR(app);
 
 	for (i = 0; i < ports_count; i++) {
 		if (!ports[i])
@@ -464,9 +458,7 @@ static int __net_init __ip_vs_ftp_init(struct net *net)
 	return 0;
 
 err_unreg:
-	unregister_ip_vs_app(net, app);
-err_exit:
-	kfree(ipvs->ftp_app);
+	unregister_ip_vs_app(net, &ip_vs_ftp);
 	return ret;
 }
 /*
@@ -474,10 +466,7 @@ err_exit:
  */
 static void __ip_vs_ftp_exit(struct net *net)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
