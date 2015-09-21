From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 54/84] ipvs: Pass ipvs not net to register_ip_vs_app_inc
Date: Mon, 21 Sep 2015 13:02:31 -0500
Message-ID: <1442858581-15869-54-git-send-email-ebiederm@xmission.com>
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

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/ip_vs.h            | 2 +-
 net/netfilter/ipvs/ip_vs_app.c | 3 +--
 net/netfilter/ipvs/ip_vs_ftp.c | 2 +-
 3 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index a7275ae18b96..c06bad39958d 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1345,7 +1345,7 @@ struct ip_vs_app *register_ip_vs_app(struct net *net, struct ip_vs_app *app);
 void unregister_ip_vs_app(struct net *net, struct ip_vs_app *app);
 int ip_vs_bind_app(struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
 void ip_vs_unbind_app(struct ip_vs_conn *cp);
-int register_ip_vs_app_inc(struct net *net, struct ip_vs_app *app, __u16 proto,
+int register_ip_vs_app_inc(struct netns_ipvs *ipvs, struct ip_vs_app *app, __u16 proto,
 			   __u16 port);
 int ip_vs_app_inc_get(struct ip_vs_app *inc);
 void ip_vs_app_inc_put(struct ip_vs_app *inc);
diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index 951516b7783b..20cb947a3ddd 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -176,10 +176,9 @@ void ip_vs_app_inc_put(struct ip_vs_app *inc)
  *	Register an application incarnation in protocol applications
  */
 int
-register_ip_vs_app_inc(struct net *net, struct ip_vs_app *app, __u16 proto,
+register_ip_vs_app_inc(struct netns_ipvs *ipvs, struct ip_vs_app *app, __u16 proto,
 		       __u16 port)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	int result;
 
 	mutex_lock(&__ip_vs_app_mutex);
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index cf0cba956a21..24bab8e5a507 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -454,7 +454,7 @@ static int __net_init __ip_vs_ftp_init(struct net *net)
 	for (i = 0; i < ports_count; i++) {
 		if (!ports[i])
 			continue;
-		ret = register_ip_vs_app_inc(net, app, app->protocol, ports[i]);
+		ret = register_ip_vs_app_inc(ipvs, app, app->protocol, ports[i]);
 		if (ret)
 			goto err_unreg;
 		pr_info("%s: loaded support on port[%d] = %d\n",
-- 
2.2.1
