From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 37/84] ipvs: Store ipvs not net in struct ip_vs_sync_thread_data
Date: Mon, 21 Sep 2015 13:02:14 -0500
Message-ID: <1442858581-15869-37-git-send-email-ebiederm@xmission.com>
References: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>

In practice struct netns_ipvs is as meaningful as struct net and more
useful as it holds the ipvs specific data.  So store a pointer to
struct netns_ipvs.

Update the accesses of tinfo->net to access tinfo->ipvs->net instead.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_sync.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 304eade977d2..cd32e3ab0c4d 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -193,7 +193,7 @@ union ip_vs_sync_conn {
 #define IPVS_OPT_F_PARAM	(1 << (IPVS_OPT_PARAM-1))
 
 struct ip_vs_sync_thread_data {
-	struct net *net;
+	struct netns_ipvs *ipvs;
 	struct socket *sock;
 	char *buf;
 	int id;
@@ -1685,7 +1685,7 @@ next_sync_buff(struct netns_ipvs *ipvs, struct ipvs_master_sync_state *ms)
 static int sync_thread_master(void *data)
 {
 	struct ip_vs_sync_thread_data *tinfo = data;
-	struct netns_ipvs *ipvs = net_ipvs(tinfo->net);
+	struct netns_ipvs *ipvs = tinfo->ipvs;
 	struct ipvs_master_sync_state *ms = &ipvs->ms[tinfo->id];
 	struct sock *sk = tinfo->sock->sk;
 	struct ip_vs_sync_buff *sb;
@@ -1741,7 +1741,7 @@ done:
 static int sync_thread_backup(void *data)
 {
 	struct ip_vs_sync_thread_data *tinfo = data;
-	struct netns_ipvs *ipvs = net_ipvs(tinfo->net);
+	struct netns_ipvs *ipvs = tinfo->ipvs;
 	int len;
 
 	pr_info("sync thread started: state = BACKUP, mcast_ifn = %s, "
@@ -1763,7 +1763,7 @@ static int sync_thread_backup(void *data)
 				break;
 			}
 
-			ip_vs_process_message(tinfo->net, tinfo->buf, len);
+			ip_vs_process_message(ipvs->net, tinfo->buf, len);
 		}
 	}
 
@@ -1880,7 +1880,7 @@ int start_sync_thread(struct netns_ipvs *ipvs, struct ipvs_sync_daemon_cfg *c,
 		tinfo = kmalloc(sizeof(*tinfo), GFP_KERNEL);
 		if (!tinfo)
 			goto outsocket;
-		tinfo->net = ipvs->net;
+		tinfo->ipvs = ipvs;
 		tinfo->sock = sock;
 		if (state == IP_VS_STATE_BACKUP) {
 			tinfo->buf = kmalloc(ipvs->bcfg.sync_maxlen,
-- 
2.2.1

