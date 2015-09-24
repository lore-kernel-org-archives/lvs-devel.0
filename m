From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 37/84] ipvs: Store ipvs not net in struct ip_vs_sync_thread_data
Date: Thu, 24 Sep 2015 09:52:22 +0900
Message-ID: <1443055989-1306-38-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "Eric W. Biederman" <ebiederm@xmission.com>, Simon Horman <horms@verge.net.au>

From: "Eric W. Biederman" <ebiederm@xmission.com>

In practice struct netns_ipvs is as meaningful as struct net and more
useful as it holds the ipvs specific data.  So store a pointer to
struct netns_ipvs.

Update the accesses of tinfo->net to access tinfo->ipvs->net instead.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
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
2.1.4

