From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 42/84] ipvs: Pass ipvs not net to ip_vs_proc_sync_conn
Date: Mon, 21 Sep 2015 13:02:19 -0500
Message-ID: <1442858581-15869-42-git-send-email-ebiederm@xmission.com>
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

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_sync.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 98180904ccd2..e3f72cbc1204 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1064,9 +1064,8 @@ static int ip_vs_proc_str(__u8 *p, unsigned int plen, unsigned int *data_len,
 /*
  *   Process a Version 1 sync. connection
  */
-static inline int ip_vs_proc_sync_conn(struct net *net, __u8 *p, __u8 *msg_end)
+static inline int ip_vs_proc_sync_conn(struct netns_ipvs *ipvs, __u8 *p, __u8 *msg_end)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_sync_conn_options opt;
 	union  ip_vs_sync_conn *s;
 	struct ip_vs_protocol *pp;
@@ -1254,7 +1253,7 @@ static void ip_vs_process_message(struct netns_ipvs *ipvs, __u8 *buffer,
 				return;
 			}
 			/* Process a single sync_conn */
-			retc = ip_vs_proc_sync_conn(ipvs->net, p, msg_end);
+			retc = ip_vs_proc_sync_conn(ipvs, p, msg_end);
 			if (retc < 0) {
 				IP_VS_ERR_RL("BACKUP, Dropping buffer, Err: %d in decoding\n",
 					     retc);
-- 
2.2.1

