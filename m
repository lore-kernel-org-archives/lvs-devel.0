From: Simon Horman <horms@verge.net.au>
Subject: [rfc v2 02/10] ipvs network name space aware: app
Date: Fri, 22 Oct 2010 22:09:36 +0200
Message-ID: <20101022202356.621386473@joe.akashicho.tokyo.vergenet.net>
References: <20101022200934.822223308@joe.akashicho.tokyo.vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=ipvs-netns-2.patch
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Daniel Lezcano <daniel.lezcano@free.fr>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, Julian Anastasov <ja@ssi.bg>, Wensong Zhang <wensong@linux-vs.org>

This is patch 2/9  previous was just a copy of patch 1/9 

This patch just contains ip_vs_app.c
There is nothing special whith this file,
just the normal,
 - moving to vars to struct ipvs
 - adding per netns init and exit

Signed-off-by:Hans Schillstrom <hans.schillstrom@ericsson.com>

Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_app.c
===================================================================
--- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_app.c	2010-10-22 21:33:42.000000000 +0200
+++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_app.c	2010-10-22 21:33:52.000000000 +0200
@@ -43,11 +43,6 @@ EXPORT_SYMBOL(register_ip_vs_app);
 EXPORT_SYMBOL(unregister_ip_vs_app);
 EXPORT_SYMBOL(register_ip_vs_app_inc);
 
-/* ipvs application list head */
-static LIST_HEAD(ip_vs_app_list);
-static DEFINE_MUTEX(__ip_vs_app_mutex);
-
-
 /*
  *	Get an ip_vs_app object
  */
@@ -67,7 +62,8 @@ static inline void ip_vs_app_put(struct
  *	Allocate/initialize app incarnation and register it in proto apps.
  */
 static int
-ip_vs_app_inc_new(struct ip_vs_app *app, __u16 proto, __u16 port)
+ip_vs_app_inc_new(struct net *net, struct ip_vs_app *app, __u16 proto,
+		  __u16 port)
 {
 	struct ip_vs_protocol *pp;
 	struct ip_vs_app *inc;
@@ -98,7 +94,7 @@ ip_vs_app_inc_new(struct ip_vs_app *app,
 		}
 	}
 
-	ret = pp->register_app(inc);
+	ret = pp->register_app(net, inc);
 	if (ret)
 		goto out;
 
@@ -119,7 +115,7 @@ ip_vs_app_inc_new(struct ip_vs_app *app,
  *	Release app incarnation
  */
 static void
-ip_vs_app_inc_release(struct ip_vs_app *inc)
+ip_vs_app_inc_release(struct net *net, struct ip_vs_app *inc)
 {
 	struct ip_vs_protocol *pp;
 
@@ -127,7 +123,7 @@ ip_vs_app_inc_release(struct ip_vs_app *
 		return;
 
 	if (pp->unregister_app)
-		pp->unregister_app(inc);
+		pp->unregister_app(net, inc);
 
 	IP_VS_DBG(9, "%s App %s:%u unregistered\n",
 		  pp->name, inc->name, ntohs(inc->port));
@@ -167,16 +163,16 @@ void ip_vs_app_inc_put(struct ip_vs_app
 /*
  *	Register an application incarnation in protocol applications
  */
-int
-register_ip_vs_app_inc(struct ip_vs_app *app, __u16 proto, __u16 port)
+int register_ip_vs_app_inc(struct net *net, struct ip_vs_app *app, __u16 proto,
+		           __u16 port)
 {
 	int result;
 
-	mutex_lock(&__ip_vs_app_mutex);
+	mutex_lock(&net->ipvs->app_mutex);
 
-	result = ip_vs_app_inc_new(app, proto, port);
+	result = ip_vs_app_inc_new(net, app, proto, port);
 
-	mutex_unlock(&__ip_vs_app_mutex);
+	mutex_unlock(&net->ipvs->app_mutex);
 
 	return result;
 }
@@ -185,16 +181,16 @@ register_ip_vs_app_inc(struct ip_vs_app
 /*
  *	ip_vs_app registration routine
  */
-int register_ip_vs_app(struct ip_vs_app *app)
+int register_ip_vs_app(struct net *net, struct ip_vs_app *app)
 {
 	/* increase the module use count */
 	ip_vs_use_count_inc();
 
-	mutex_lock(&__ip_vs_app_mutex);
+	mutex_lock(&net->ipvs->app_mutex);
 
-	list_add(&app->a_list, &ip_vs_app_list);
+	list_add(&app->a_list, &net->ipvs->app_list);
 
-	mutex_unlock(&__ip_vs_app_mutex);
+	mutex_unlock(&net->ipvs->app_mutex);
 
 	return 0;
 }
@@ -204,19 +200,19 @@ int register_ip_vs_app(struct ip_vs_app
  *	ip_vs_app unregistration routine
  *	We are sure there are no app incarnations attached to services
  */
-void unregister_ip_vs_app(struct ip_vs_app *app)
+void unregister_ip_vs_app(struct net *net, struct ip_vs_app *app)
 {
 	struct ip_vs_app *inc, *nxt;
 
-	mutex_lock(&__ip_vs_app_mutex);
+	mutex_lock(&net->ipvs->app_mutex);
 
 	list_for_each_entry_safe(inc, nxt, &app->incs_list, a_list) {
-		ip_vs_app_inc_release(inc);
+		ip_vs_app_inc_release(net, inc);
 	}
 
 	list_del(&app->a_list);
 
-	mutex_unlock(&__ip_vs_app_mutex);
+	mutex_unlock(&net->ipvs->app_mutex);
 
 	/* decrease the module use count */
 	ip_vs_use_count_dec();
@@ -226,9 +222,9 @@ void unregister_ip_vs_app(struct ip_vs_a
 /*
  *	Bind ip_vs_conn to its ip_vs_app (called by cp constructor)
  */
-int ip_vs_bind_app(struct ip_vs_conn *cp, struct ip_vs_protocol *pp)
+int ip_vs_bind_app(struct net *net, struct ip_vs_conn *cp, struct ip_vs_protocol *pp)
 {
-	return pp->app_conn_bind(cp);
+	return pp->app_conn_bind(net, cp);
 }
 
 
@@ -481,11 +477,12 @@ int ip_vs_app_pkt_in(struct ip_vs_conn *
  *	/proc/net/ip_vs_app entry function
  */
 
-static struct ip_vs_app *ip_vs_app_idx(loff_t pos)
+static struct ip_vs_app *ip_vs_app_idx(struct net *net, loff_t pos)
 {
 	struct ip_vs_app *app, *inc;
+	struct netns_ipvs *ipvs = net->ipvs;
 
-	list_for_each_entry(app, &ip_vs_app_list, a_list) {
+	list_for_each_entry(app, &ipvs->app_list, a_list) {
 		list_for_each_entry(inc, &app->incs_list, a_list) {
 			if (pos-- == 0)
 				return inc;
@@ -497,19 +494,22 @@ static struct ip_vs_app *ip_vs_app_idx(l
 
 static void *ip_vs_app_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	mutex_lock(&__ip_vs_app_mutex);
+	struct net *net = seq_file_net(seq);
+	mutex_lock(&net->ipvs->app_mutex);
 
-	return *pos ? ip_vs_app_idx(*pos - 1) : SEQ_START_TOKEN;
+	return *pos ? ip_vs_app_idx(net, *pos - 1) : SEQ_START_TOKEN;
 }
 
 static void *ip_vs_app_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct ip_vs_app *inc, *app;
 	struct list_head *e;
+	struct net *net = seq_file_net(seq);
+	struct netns_ipvs *ipvs = net->ipvs;
 
 	++*pos;
 	if (v == SEQ_START_TOKEN)
-		return ip_vs_app_idx(0);
+		return ip_vs_app_idx(net, 0);
 
 	inc = v;
 	app = inc->app;
@@ -518,7 +518,7 @@ static void *ip_vs_app_seq_next(struct s
 		return list_entry(e, struct ip_vs_app, a_list);
 
 	/* go on to next application */
-	for (e = app->a_list.next; e != &ip_vs_app_list; e = e->next) {
+	for (e = app->a_list.next; e != &ipvs->app_list; e = e->next) {
 		app = list_entry(e, struct ip_vs_app, a_list);
 		list_for_each_entry(inc, &app->incs_list, a_list) {
 			return inc;
@@ -529,7 +529,9 @@ static void *ip_vs_app_seq_next(struct s
 
 static void ip_vs_app_seq_stop(struct seq_file *seq, void *v)
 {
-	mutex_unlock(&__ip_vs_app_mutex);
+	struct net *net = seq_file_net(seq);
+
+	mutex_unlock(&net->ipvs->app_mutex);
 }
 
 static int ip_vs_app_seq_show(struct seq_file *seq, void *v)
@@ -557,7 +559,8 @@ static const struct seq_operations ip_vs
 
 static int ip_vs_app_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &ip_vs_app_seq_ops);
+
+	return seq_open_net(inode,file, &ip_vs_app_seq_ops, sizeof(struct seq_net_private));
 }
 
 static const struct file_operations ip_vs_app_fops = {
@@ -565,19 +568,38 @@ static const struct file_operations ip_v
 	.open	 = ip_vs_app_open,
 	.read	 = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release,
+	.release = seq_release_private,
 };
 #endif
 
-int __init ip_vs_app_init(void)
+static int __net_init __ip_vs_app_init(struct net *net)
 {
-	/* we will replace it with proc_net_ipvs_create() soon */
-	proc_net_fops_create(&init_net, "ip_vs_app", 0, &ip_vs_app_fops);
+	INIT_LIST_HEAD(&net->ipvs->app_list);
+	__mutex_init(&net->ipvs->app_mutex,"ipvs->app_mutex", &net->ipvs->app_key);
+	proc_net_fops_create(net, "ip_vs_app", 0, &ip_vs_app_fops);
 	return 0;
 }
 
+static void __net_exit __ip_vs_app_cleanup(struct net *net)
+{
+	proc_net_remove(net, "ip_vs_app");
+}
+
+static struct pernet_operations ip_vs_app_ops = {
+	.init = __ip_vs_app_init,
+	.exit = __ip_vs_app_cleanup,
+};
+
+int __init ip_vs_app_init(void)
+{
+	int rv;
+
+	rv = register_pernet_subsys(&ip_vs_app_ops);
+	return rv;
+}
+
 
 void ip_vs_app_cleanup(void)
 {
-	proc_net_remove(&init_net, "ip_vs_app");
+	unregister_pernet_subsys(&ip_vs_app_ops);
 }

