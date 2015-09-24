From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 42/84] ipvs: Pass ipvs not net to ip_vs_proc_sync_conn
Date: Thu, 24 Sep 2015 09:52:27 +0900
Message-ID: <1443055989-1306-43-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "Eric W. Biederman" <ebiederm@xmission.com>, Simon Horman <horms@verge.net.au>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
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
2.1.4
