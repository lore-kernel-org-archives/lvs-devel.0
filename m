From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [*v2 PATCH 12/22] IPVS: netns awareness to ip_vs_app
Date: Mon, 13 Dec 2010 14:38:20 +0100
Message-ID: <1292247510-753-13-git-send-email-hans.schillstrom@ericsson.com>
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

All variables moved to struct ipvs,
most external changes fixed (i.e. init_net removed)

in ip_vs_protocol param struct net *net added to:
 - register_app()
 - unregister_app()
This affected almost all proto_xxx.c files

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/net/ip_vs.h                   |   12 +++---
 include/net/netns/ip_vs.h             |    5 ++
 net/netfilter/ipvs/ip_vs_app.c        |   72 +++++++++++++++++++--------------
 net/netfilter/ipvs/ip_vs_ftp.c        |    8 ++--
 net/netfilter/ipvs/ip_vs_proto_sctp.c |   12 +++---
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |   12 +++---
 net/netfilter/ipvs/ip_vs_proto_udp.c  |   12 +++---
 7 files changed, 75 insertions(+), 58 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index acd795c..5988c5d 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -406,9 +406,9 @@ struct ip_vs_protocol {
 				const struct sk_buff *skb,
 				struct ip_vs_proto_data *pd);
 
-	int (*register_app)(struct ip_vs_app *inc);
+	int (*register_app)(struct net *net, struct ip_vs_app *inc);
 
-	void (*unregister_app)(struct ip_vs_app *inc);
+	void (*unregister_app)(struct net *net, struct ip_vs_app *inc);
 
 	int (*app_conn_bind)(struct ip_vs_conn *cp);
 
@@ -879,12 +879,12 @@ ip_vs_control_add(struct ip_vs_conn *cp, struct ip_vs_conn *ctl_cp)
  *      (from ip_vs_app.c)
  */
 #define IP_VS_APP_MAX_PORTS  8
-extern int register_ip_vs_app(struct ip_vs_app *app);
-extern void unregister_ip_vs_app(struct ip_vs_app *app);
+extern int register_ip_vs_app(struct net *net, struct ip_vs_app *app);
+extern void unregister_ip_vs_app(struct net *net, struct ip_vs_app *app);
 extern int ip_vs_bind_app(struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
 extern void ip_vs_unbind_app(struct ip_vs_conn *cp);
-extern int
-register_ip_vs_app_inc(struct ip_vs_app *app, __u16 proto, __u16 port);
+extern int register_ip_vs_app_inc(struct net *net, struct ip_vs_app *app,
+				  __u16 proto, __u16 port);
 extern int ip_vs_app_inc_get(struct ip_vs_app *inc);
 extern void ip_vs_app_inc_put(struct ip_vs_app *inc);
 
diff --git a/include/net/netns/ip_vs.h b/include/net/netns/ip_vs.h
index fcb3c7c..f077bd3 100644
--- a/include/net/netns/ip_vs.h
+++ b/include/net/netns/ip_vs.h
@@ -29,6 +29,11 @@ struct netns_ipvs {
 	#define IP_VS_RTAB_MASK (IP_VS_RTAB_SIZE - 1)
 
 	struct list_head 	rs_table[IP_VS_RTAB_SIZE];
+	/* ip_vs_app */
+	struct list_head 	app_list;
+	struct mutex		app_mutex;
+	struct lock_class_key 	app_key;	/* mutex debuging */
+
 	/* ip_vs_proto */
 	#define IP_VS_PROTO_TAB_SIZE	32	/* must be power of 2 */
 	struct ip_vs_proto_data *proto_data_table[IP_VS_PROTO_TAB_SIZE];
diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index 6d10352..af2cd83 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
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
@@ -67,7 +62,8 @@ static inline void ip_vs_app_put(struct ip_vs_app *app)
  *	Allocate/initialize app incarnation and register it in proto apps.
  */
 static int
-ip_vs_app_inc_new(struct ip_vs_app *app, __u16 proto, __u16 port)
+ip_vs_app_inc_new(struct net *net, struct ip_vs_app *app, __u16 proto,
+		  __u16 port)
 {
 	struct ip_vs_protocol *pp;
 	struct ip_vs_app *inc;
@@ -98,7 +94,7 @@ ip_vs_app_inc_new(struct ip_vs_app *app, __u16 proto, __u16 port)
 		}
 	}
 
-	ret = pp->register_app(inc);
+	ret = pp->register_app(net, inc);
 	if (ret)
 		goto out;
 
@@ -119,7 +115,7 @@ ip_vs_app_inc_new(struct ip_vs_app *app, __u16 proto, __u16 port)
  *	Release app incarnation
  */
 static void
-ip_vs_app_inc_release(struct ip_vs_app *inc)
+ip_vs_app_inc_release(struct net *net, struct ip_vs_app *inc)
 {
 	struct ip_vs_protocol *pp;
 
@@ -127,7 +123,7 @@ ip_vs_app_inc_release(struct ip_vs_app *inc)
 		return;
 
 	if (pp->unregister_app)
-		pp->unregister_app(inc);
+		pp->unregister_app(net, inc);
 
 	IP_VS_DBG(9, "%s App %s:%u unregistered\n",
 		  pp->name, inc->name, ntohs(inc->port));
@@ -168,15 +164,16 @@ void ip_vs_app_inc_put(struct ip_vs_app *inc)
  *	Register an application incarnation in protocol applications
  */
 int
-register_ip_vs_app_inc(struct ip_vs_app *app, __u16 proto, __u16 port)
+register_ip_vs_app_inc(struct net *net, struct ip_vs_app *app, __u16 proto, __u16 port)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	int result;
 
-	mutex_lock(&__ip_vs_app_mutex);
+	mutex_lock(&ipvs->app_mutex);
 
-	result = ip_vs_app_inc_new(app, proto, port);
+	result = ip_vs_app_inc_new(net, app, proto, port);
 
-	mutex_unlock(&__ip_vs_app_mutex);
+	mutex_unlock(&ipvs->app_mutex);
 
 	return result;
 }
@@ -185,16 +182,17 @@ register_ip_vs_app_inc(struct ip_vs_app *app, __u16 proto, __u16 port)
 /*
  *	ip_vs_app registration routine
  */
-int register_ip_vs_app(struct ip_vs_app *app)
+int register_ip_vs_app(struct net *net, struct ip_vs_app *app)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	/* increase the module use count */
 	ip_vs_use_count_inc();
 
-	mutex_lock(&__ip_vs_app_mutex);
+	mutex_lock(&ipvs->app_mutex);
 
-	list_add(&app->a_list, &ip_vs_app_list);
+	list_add(&app->a_list, &ipvs->app_list);
 
-	mutex_unlock(&__ip_vs_app_mutex);
+	mutex_unlock(&ipvs->app_mutex);
 
 	return 0;
 }
@@ -204,19 +202,20 @@ int register_ip_vs_app(struct ip_vs_app *app)
  *	ip_vs_app unregistration routine
  *	We are sure there are no app incarnations attached to services
  */
-void unregister_ip_vs_app(struct ip_vs_app *app)
+void unregister_ip_vs_app(struct net *net, struct ip_vs_app *app)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_app *inc, *nxt;
 
-	mutex_lock(&__ip_vs_app_mutex);
+	mutex_lock(&ipvs->app_mutex);
 
 	list_for_each_entry_safe(inc, nxt, &app->incs_list, a_list) {
-		ip_vs_app_inc_release(inc);
+		ip_vs_app_inc_release(net, inc);
 	}
 
 	list_del(&app->a_list);
 
-	mutex_unlock(&__ip_vs_app_mutex);
+	mutex_unlock(&ipvs->app_mutex);
 
 	/* decrease the module use count */
 	ip_vs_use_count_dec();
@@ -226,7 +225,8 @@ void unregister_ip_vs_app(struct ip_vs_app *app)
 /*
  *	Bind ip_vs_conn to its ip_vs_app (called by cp constructor)
  */
-int ip_vs_bind_app(struct ip_vs_conn *cp, struct ip_vs_protocol *pp)
+int ip_vs_bind_app(struct ip_vs_conn *cp,
+		   struct ip_vs_protocol *pp)
 {
 	return pp->app_conn_bind(cp);
 }
@@ -481,11 +481,11 @@ int ip_vs_app_pkt_in(struct ip_vs_conn *cp, struct sk_buff *skb)
  *	/proc/net/ip_vs_app entry function
  */
 
-static struct ip_vs_app *ip_vs_app_idx(loff_t pos)
+static struct ip_vs_app *ip_vs_app_idx(struct netns_ipvs *ipvs, loff_t pos)
 {
 	struct ip_vs_app *app, *inc;
 
-	list_for_each_entry(app, &ip_vs_app_list, a_list) {
+	list_for_each_entry(app, &ipvs->app_list, a_list) {
 		list_for_each_entry(inc, &app->incs_list, a_list) {
 			if (pos-- == 0)
 				return inc;
@@ -497,19 +497,24 @@ static struct ip_vs_app *ip_vs_app_idx(loff_t pos)
 
 static void *ip_vs_app_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	mutex_lock(&__ip_vs_app_mutex);
+	struct net *net = seq_file_net(seq);
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
+	mutex_lock(&ipvs->app_mutex);
 
-	return *pos ? ip_vs_app_idx(*pos - 1) : SEQ_START_TOKEN;
+	return *pos ? ip_vs_app_idx(ipvs, *pos - 1) : SEQ_START_TOKEN;
 }
 
 static void *ip_vs_app_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct ip_vs_app *inc, *app;
 	struct list_head *e;
+	struct net *net = seq_file_net(seq);
+	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	++*pos;
 	if (v == SEQ_START_TOKEN)
-		return ip_vs_app_idx(0);
+		return ip_vs_app_idx(ipvs, 0);
 
 	inc = v;
 	app = inc->app;
@@ -518,7 +523,7 @@ static void *ip_vs_app_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 		return list_entry(e, struct ip_vs_app, a_list);
 
 	/* go on to next application */
-	for (e = app->a_list.next; e != &ip_vs_app_list; e = e->next) {
+	for (e = app->a_list.next; e != &ipvs->app_list; e = e->next) {
 		app = list_entry(e, struct ip_vs_app, a_list);
 		list_for_each_entry(inc, &app->incs_list, a_list) {
 			return inc;
@@ -529,7 +534,9 @@ static void *ip_vs_app_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 
 static void ip_vs_app_seq_stop(struct seq_file *seq, void *v)
 {
-	mutex_unlock(&__ip_vs_app_mutex);
+	struct netns_ipvs *ipvs = net_ipvs(seq_file_net(seq));
+
+	mutex_unlock(&ipvs->app_mutex);
 }
 
 static int ip_vs_app_seq_show(struct seq_file *seq, void *v)
@@ -557,7 +564,8 @@ static const struct seq_operations ip_vs_app_seq_ops = {
 
 static int ip_vs_app_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &ip_vs_app_seq_ops);
+	return seq_open_net(inode, file, &ip_vs_app_seq_ops,
+			    sizeof(struct seq_net_private));
 }
 
 static const struct file_operations ip_vs_app_fops = {
@@ -571,9 +579,13 @@ static const struct file_operations ip_vs_app_fops = {
 
 static int __net_init __ip_vs_app_init(struct net *net)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
 	if (!net_eq(net, &init_net))	/* netns not enabled yet */
 		return -EPERM;
 
+	INIT_LIST_HEAD(&ipvs->app_list);
+	__mutex_init(&ipvs->app_mutex,"ipvs->app_mutex", &ipvs->app_key);
 	proc_net_fops_create(net, "ip_vs_app", 0, &ip_vs_app_fops);
 	return 0;
 }
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index fdcb74b..b39befd 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -413,14 +413,14 @@ static int __net_init __ip_vs_ftp_init(struct net *net)
 	if (!net_eq(net, &init_net))	/* netns not enabled yet */
 		return -EPERM;
 
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
@@ -428,7 +428,7 @@ static int __net_init __ip_vs_ftp_init(struct net *net)
 	}
 
 	if (ret)
-		unregister_ip_vs_app(app);
+		unregister_ip_vs_app(net, app);
 
 	return ret;
 }
@@ -442,7 +442,7 @@ static void __ip_vs_ftp_exit(struct net *net)
 	if (!net_eq(net, &init_net))	/* netns not enabled yet */
 		return;
 
-	unregister_ip_vs_app(app);
+	unregister_ip_vs_app(net, app);
 }
 
 static struct pernet_operations ip_vs_ftp_ops = {
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 2460fc7..3c6d06d 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -1025,14 +1025,14 @@ static inline __u16 sctp_app_hashkey(__be16 port)
 		& SCTP_APP_TAB_MASK;
 }
 
-static int sctp_register_app(struct ip_vs_app *inc)
+static int sctp_register_app(struct net *net, struct ip_vs_app *inc)
 {
 	struct ip_vs_app *i;
 	__u16 hash;
 	__be16 port = inc->port;
 	int ret = 0;
-	struct netns_ipvs *ipvs = net_ipvs(&init_net);
-	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(&init_net, IPPROTO_SCTP);
+	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net, IPPROTO_SCTP);
 
 	hash = sctp_app_hashkey(port);
 
@@ -1051,10 +1051,10 @@ out:
 	return ret;
 }
 
-static void sctp_unregister_app(struct ip_vs_app *inc)
+static void sctp_unregister_app(struct net *net, struct ip_vs_app *inc)
 {
-	struct netns_ipvs *ipvs = net_ipvs(&init_net);
-	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(&init_net, IPPROTO_SCTP);
+	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net, IPPROTO_SCTP);
 
 	spin_lock_bh(&ipvs->sctp_app_lock);
 	atomic_dec(&pd->appcnt);
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 98cfec0..326768d 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -583,14 +583,14 @@ static inline __u16 tcp_app_hashkey(__be16 port)
 }
 
 
-static int tcp_register_app(struct ip_vs_app *inc)
+static int tcp_register_app(struct net *net, struct ip_vs_app *inc)
 {
 	struct ip_vs_app *i;
 	__u16 hash;
 	__be16 port = inc->port;
 	int ret = 0;
-	struct netns_ipvs *ipvs = net_ipvs(&init_net);
-	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(&init_net, IPPROTO_TCP);
+	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net, IPPROTO_TCP);
 
 	hash = tcp_app_hashkey(port);
 
@@ -611,10 +611,10 @@ static int tcp_register_app(struct ip_vs_app *inc)
 
 
 static void
-tcp_unregister_app(struct ip_vs_app *inc)
+tcp_unregister_app(struct net *net, struct ip_vs_app *inc)
 {
-	struct netns_ipvs *ipvs = net_ipvs(&init_net);
-	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(&init_net, IPPROTO_TCP);
+	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net, IPPROTO_TCP);
 
 	spin_lock_bh(&ipvs->tcp_app_lock);
 	atomic_dec(&pd->appcnt);
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index da4add0..7e894d5 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -353,14 +353,14 @@ static inline __u16 udp_app_hashkey(__be16 port)
 }
 
 
-static int udp_register_app(struct ip_vs_app *inc)
+static int udp_register_app(struct net *net, struct ip_vs_app *inc)
 {
 	struct ip_vs_app *i;
 	__u16 hash;
 	__be16 port = inc->port;
 	int ret = 0;
-	struct netns_ipvs *ipvs = net_ipvs(&init_net);
-	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(&init_net, IPPROTO_UDP);
+	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net, IPPROTO_UDP);
 
 	hash = udp_app_hashkey(port);
 
@@ -382,10 +382,10 @@ static int udp_register_app(struct ip_vs_app *inc)
 
 
 static void
-udp_unregister_app(struct ip_vs_app *inc)
+udp_unregister_app(struct net *net, struct ip_vs_app *inc)
 {
-	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(&init_net, IPPROTO_UDP);
-	struct netns_ipvs *ipvs = net_ipvs(&init_net);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net, IPPROTO_UDP);
+	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	spin_lock_bh(&ipvs->udp_app_lock);
 	atomic_dec(&pd->appcnt);
-- 
1.7.2.3

