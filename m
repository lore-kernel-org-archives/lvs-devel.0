From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 52/84] ipvs: Pass ipvs not net into register_app and unregister_app
Date: Sun, 20 Sep 2015 01:23:08 -0500
Message-ID: <1442730220-32458-52-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/ip_vs.h                   | 4 ++--
 net/netfilter/ipvs/ip_vs_app.c        | 6 ++++--
 net/netfilter/ipvs/ip_vs_proto_sctp.c | 7 +++----
 net/netfilter/ipvs/ip_vs_proto_tcp.c  | 7 +++----
 net/netfilter/ipvs/ip_vs_proto_udp.c  | 7 +++----
 5 files changed, 15 insertions(+), 16 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 02734eaae679..a7275ae18b96 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -517,9 +517,9 @@ struct ip_vs_protocol {
 				 const struct sk_buff *skb,
 				 struct ip_vs_proto_data *pd);
 
-	int (*register_app)(struct net *net, struct ip_vs_app *inc);
+	int (*register_app)(struct netns_ipvs *ipvs, struct ip_vs_app *inc);
 
-	void (*unregister_app)(struct net *net, struct ip_vs_app *inc);
+	void (*unregister_app)(struct netns_ipvs *ipvs, struct ip_vs_app *inc);
 
 	int (*app_conn_bind)(struct ip_vs_conn *cp);
 
diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index dfd7b65b3d2a..f20f72c4ac80 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -78,6 +78,7 @@ static int
 ip_vs_app_inc_new(struct net *net, struct ip_vs_app *app, __u16 proto,
 		  __u16 port)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_protocol *pp;
 	struct ip_vs_app *inc;
 	int ret;
@@ -107,7 +108,7 @@ ip_vs_app_inc_new(struct net *net, struct ip_vs_app *app, __u16 proto,
 		}
 	}
 
-	ret = pp->register_app(net, inc);
+	ret = pp->register_app(ipvs, inc);
 	if (ret)
 		goto out;
 
@@ -129,13 +130,14 @@ ip_vs_app_inc_new(struct net *net, struct ip_vs_app *app, __u16 proto,
 static void
 ip_vs_app_inc_release(struct net *net, struct ip_vs_app *inc)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_protocol *pp;
 
 	if (!(pp = ip_vs_proto_get(inc->protocol)))
 		return;
 
 	if (pp->unregister_app)
-		pp->unregister_app(net, inc);
+		pp->unregister_app(ipvs, inc);
 
 	IP_VS_DBG(9, "%s App %s:%u unregistered\n",
 		  pp->name, inc->name, ntohs(inc->port));
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 8f39e0266ade..345fc7485f2e 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -487,13 +487,12 @@ static inline __u16 sctp_app_hashkey(__be16 port)
 		& SCTP_APP_TAB_MASK;
 }
 
-static int sctp_register_app(struct net *net, struct ip_vs_app *inc)
+static int sctp_register_app(struct netns_ipvs *ipvs, struct ip_vs_app *inc)
 {
 	struct ip_vs_app *i;
 	__u16 hash;
 	__be16 port = inc->port;
 	int ret = 0;
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(ipvs, IPPROTO_SCTP);
 
 	hash = sctp_app_hashkey(port);
@@ -511,9 +510,9 @@ out:
 	return ret;
 }
 
-static void sctp_unregister_app(struct net *net, struct ip_vs_app *inc)
+static void sctp_unregister_app(struct netns_ipvs *ipvs, struct ip_vs_app *inc)
 {
-	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net_ipvs(net), IPPROTO_SCTP);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(ipvs, IPPROTO_SCTP);
 
 	atomic_dec(&pd->appcnt);
 	list_del_rcu(&inc->p_list);
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 975aa69eec9c..94bea31ec388 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -595,13 +595,12 @@ static inline __u16 tcp_app_hashkey(__be16 port)
 }
 
 
-static int tcp_register_app(struct net *net, struct ip_vs_app *inc)
+static int tcp_register_app(struct netns_ipvs *ipvs, struct ip_vs_app *inc)
 {
 	struct ip_vs_app *i;
 	__u16 hash;
 	__be16 port = inc->port;
 	int ret = 0;
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(ipvs, IPPROTO_TCP);
 
 	hash = tcp_app_hashkey(port);
@@ -621,9 +620,9 @@ static int tcp_register_app(struct net *net, struct ip_vs_app *inc)
 
 
 static void
-tcp_unregister_app(struct net *net, struct ip_vs_app *inc)
+tcp_unregister_app(struct netns_ipvs *ipvs, struct ip_vs_app *inc)
 {
-	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net_ipvs(net), IPPROTO_TCP);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(ipvs, IPPROTO_TCP);
 
 	atomic_dec(&pd->appcnt);
 	list_del_rcu(&inc->p_list);
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 1baa7494446a..234521ec9703 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -365,13 +365,12 @@ static inline __u16 udp_app_hashkey(__be16 port)
 }
 
 
-static int udp_register_app(struct net *net, struct ip_vs_app *inc)
+static int udp_register_app(struct netns_ipvs *ipvs, struct ip_vs_app *inc)
 {
 	struct ip_vs_app *i;
 	__u16 hash;
 	__be16 port = inc->port;
 	int ret = 0;
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(ipvs, IPPROTO_UDP);
 
 	hash = udp_app_hashkey(port);
@@ -391,9 +390,9 @@ static int udp_register_app(struct net *net, struct ip_vs_app *inc)
 
 
 static void
-udp_unregister_app(struct net *net, struct ip_vs_app *inc)
+udp_unregister_app(struct netns_ipvs *ipvs, struct ip_vs_app *inc)
 {
-	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net_ipvs(net), IPPROTO_UDP);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(ipvs, IPPROTO_UDP);
 
 	atomic_dec(&pd->appcnt);
 	list_del_rcu(&inc->p_list);
-- 
2.2.1

