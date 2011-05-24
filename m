From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [PATCH 1/1] IPVS : bug in ip_vs_ftp, same list heaad used in all netns.
Date: Tue, 24 May 2011 14:11:05 +0200
Message-ID: <1306239065-17271-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: hans@schillstrom.com, Hans Schillstrom <hans.schillstrom@ericsson.com>

When ip_vs was adapted to netns the ftp application was not adapted
in a correct way.
However this is a fix to avoid kernel errors. In the long term another solution
might be chosen.  I.e the ports that the ftp appl, uses should be per netns.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/net/ip_vs.h            |    3 ++-
 net/netfilter/ipvs/ip_vs_ftp.c |   27 +++++++++++++++++++--------
 2 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 4fff432..481f856 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -797,7 +797,8 @@ struct netns_ipvs {
 	struct list_head	rs_table[IP_VS_RTAB_SIZE];
 	/* ip_vs_app */
 	struct list_head	app_list;
-
+	/* ip_vs_ftp */
+	struct ip_vs_app	*ftp_app;
 	/* ip_vs_proto */
 	#define IP_VS_PROTO_TAB_SIZE	32	/* must be power of 2 */
 	struct ip_vs_proto_data *proto_data_table[IP_VS_PROTO_TAB_SIZE];
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 6b5dd6d..af63553 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -411,25 +411,35 @@ static struct ip_vs_app ip_vs_ftp = {
 static int __net_init __ip_vs_ftp_init(struct net *net)
 {
 	int i, ret;
-	struct ip_vs_app *app = &ip_vs_ftp;
+	struct ip_vs_app *app;
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
+	app = kmemdup(&ip_vs_ftp, sizeof(struct ip_vs_app), GFP_KERNEL);
+	if (!app)
+		return -ENOMEM;
+	INIT_LIST_HEAD(&app->a_list);
+	INIT_LIST_HEAD(&app->incs_list);
+	ipvs->ftp_app = app;
 
 	ret = register_ip_vs_app(net, app);
 	if (ret)
-		return ret;
+		goto err_exit;
 
 	for (i=0; i<IP_VS_APP_MAX_PORTS; i++) {
 		if (!ports[i])
 			continue;
 		ret = register_ip_vs_app_inc(net, app, app->protocol, ports[i]);
 		if (ret)
-			break;
+			goto err_unreg;
 		pr_info("%s: loaded support on port[%d] = %d\n",
 			app->name, i, ports[i]);
 	}
+	return 0;
 
-	if (ret)
-		unregister_ip_vs_app(net, app);
