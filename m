From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 55/84] ipvs: Pass ipvs not net to register_ip_vs_app and unregister_ip_vs_app
Date: Mon, 21 Sep 2015 13:02:32 -0500
Message-ID: <1442858581-15869-55-git-send-email-ebiederm@xmission.com>
References: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>

Also move the tests for net_ipvs being NULL into __ip_vs_ftp_init
and __ip_vs_ftp_exit.  The only places where they possibly make
sense.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/ip_vs.h            |  4 ++--
 net/netfilter/ipvs/ip_vs_app.c | 17 ++++++-----------
 net/netfilter/ipvs/ip_vs_ftp.c | 11 ++++++++---
 3 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index c06bad39958d..5caafed5af2e 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1341,8 +1341,8 @@ void ip_vs_service_net_cleanup(struct netns_ipvs *ipvs);
  * (from ip_vs_app.c)
  */
 #define IP_VS_APP_MAX_PORTS  8
-struct ip_vs_app *register_ip_vs_app(struct net *net, struct ip_vs_app *app);
-void unregister_ip_vs_app(struct net *net, struct ip_vs_app *app);
+struct ip_vs_app *register_ip_vs_app(struct netns_ipvs *ipvs, struct ip_vs_app *app);
+void unregister_ip_vs_app(struct netns_ipvs *ipvs, struct ip_vs_app *app);
 int ip_vs_bind_app(struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
 void ip_vs_unbind_app(struct ip_vs_conn *cp);
 int register_ip_vs_app_inc(struct netns_ipvs *ipvs, struct ip_vs_app *app, __u16 proto,
diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index 20cb947a3ddd..a0cc08337a2c 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -192,15 +192,11 @@ register_ip_vs_app_inc(struct netns_ipvs *ipvs, struct ip_vs_app *app, __u16 pro
 
 
 /* Register application for netns */
-struct ip_vs_app *register_ip_vs_app(struct net *net, struct ip_vs_app *app)
+struct ip_vs_app *register_ip_vs_app(struct netns_ipvs *ipvs, struct ip_vs_app *app)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_app *a;
 	int err = 0;
 
-	if (!ipvs)
-		return ERR_PTR(-ENOENT);
-
 	mutex_lock(&__ip_vs_app_mutex);
 
 	list_for_each_entry(a, &ipvs->app_list, a_list) {
@@ -231,13 +227,10 @@ out_unlock:
  *	We are sure there are no app incarnations attached to services
  *	Caller should use synchronize_rcu() or rcu_barrier()
  */
-void unregister_ip_vs_app(struct net *net, struct ip_vs_app *app)
+void unregister_ip_vs_app(struct netns_ipvs *ipvs, struct ip_vs_app *app)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_app *a, *anxt, *inc, *nxt;
-
-	if (!ipvs)
-		return;
+	struct net *net = ipvs->net;
 
 	mutex_lock(&__ip_vs_app_mutex);
 
@@ -623,6 +616,8 @@ int __net_init ip_vs_app_net_init(struct net *net)
 
 void __net_exit ip_vs_app_net_cleanup(struct net *net)
 {
-	unregister_ip_vs_app(net, NULL /* all */);
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
+	unregister_ip_vs_app(ipvs, NULL /* all */);
 	remove_proc_entry("ip_vs_app", net->proc_net);
 }
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 24bab8e5a507..508544aff36d 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -447,7 +447,7 @@ static int __net_init __ip_vs_ftp_init(struct net *net)
 	if (!ipvs)
 		return -ENOENT;
 
-	app = register_ip_vs_app(net, &ip_vs_ftp);
+	app = register_ip_vs_app(ipvs, &ip_vs_ftp);
 	if (IS_ERR(app))
 		return PTR_ERR(app);
 
@@ -463,7 +463,7 @@ static int __net_init __ip_vs_ftp_init(struct net *net)
 	return 0;
 
 err_unreg:
-	unregister_ip_vs_app(net, &ip_vs_ftp);
+	unregister_ip_vs_app(ipvs, &ip_vs_ftp);
 	return ret;
 }
 /*
@@ -471,7 +471,12 @@ err_unreg:
  */
 static void __ip_vs_ftp_exit(struct net *net)
 {
-	unregister_ip_vs_app(net, &ip_vs_ftp);
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
+	if (!ipvs)
+		return;
+
+	unregister_ip_vs_app(ipvs, &ip_vs_ftp);
 }
 
 static struct pernet_operations ip_vs_ftp_ops = {
-- 
2.2.1
