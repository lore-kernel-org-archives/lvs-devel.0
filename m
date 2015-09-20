From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 80/84] ipvs: Remove net argument from ip_vs_tcp_conn_listen
Date: Sun, 20 Sep 2015 01:23:36 -0500
Message-ID: <1442730220-32458-80-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

The argument is unnecessary and in practice confusing,
and has caused the callers to do all manner of silly things.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/ip_vs.h                  | 2 +-
 net/netfilter/ipvs/ip_vs_ftp.c       | 8 ++------
 net/netfilter/ipvs/ip_vs_proto_tcp.c | 4 ++--
 3 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index dacd873e8bb9..f0a39ce3bf0e 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1271,7 +1271,7 @@ void ip_vs_conn_expire_now(struct ip_vs_conn *cp);
 
 const char *ip_vs_state_name(__u16 proto, int state);
 
-void ip_vs_tcp_conn_listen(struct net *net, struct ip_vs_conn *cp);
+void ip_vs_tcp_conn_listen(struct ip_vs_conn *cp);
 int ip_vs_check_template(struct ip_vs_conn *ct);
 void ip_vs_random_dropentry(struct netns_ipvs *ipvs);
 int ip_vs_conn_init(void);
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index dd94525eb9e6..0733f36732b4 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -181,7 +181,6 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	int ret = 0;
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct;
-	struct net *net;
 
 	*diff = 0;
 
@@ -289,9 +288,8 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		 * would be adjusted twice.
 		 */
 
-		net = skb_net(skb);
 		cp->app_data = NULL;
-		ip_vs_tcp_conn_listen(net, n_cp);
+		ip_vs_tcp_conn_listen(n_cp);
 		ip_vs_conn_put(n_cp);
 		return ret;
 	}
@@ -320,7 +318,6 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	union nf_inet_addr to;
 	__be16 port;
 	struct ip_vs_conn *n_cp;
-	struct net *net;
 
 	/* no diff required for incoming packets */
 	*diff = 0;
@@ -413,8 +410,7 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	/*
 	 *	Move tunnel to listen state
 	 */
-	net = skb_net(skb);
-	ip_vs_tcp_conn_listen(net, n_cp);
+	ip_vs_tcp_conn_listen(n_cp);
 	ip_vs_conn_put(n_cp);
 
 	return 1;
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index c913c2d00caf..d7024b2ed769 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -672,9 +672,9 @@ tcp_app_conn_bind(struct ip_vs_conn *cp)
 /*
  *	Set LISTEN timeout. (ip_vs_conn_put will setup timer)
  */
-void ip_vs_tcp_conn_listen(struct net *net, struct ip_vs_conn *cp)
+void ip_vs_tcp_conn_listen(struct ip_vs_conn *cp)
 {
-	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net_ipvs(net), IPPROTO_TCP);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(cp->ipvs, IPPROTO_TCP);
 
 	spin_lock_bh(&cp->lock);
 	cp->state = IP_VS_TCP_S_LISTEN;
-- 
2.2.1
