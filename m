From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 38/84] ipvs: Pass ipvs not net to ip_vs_process_message
Date: Thu, 24 Sep 2015 09:52:23 +0900
Message-ID: <1443055989-1306-39-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
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
 net/netfilter/ipvs/ip_vs_sync.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index cd32e3ab0c4d..280e1c03e598 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1204,10 +1204,9 @@ out:
  *      ip_vs_conn entries.
  *      Handles Version 0 & 1
  */
-static void ip_vs_process_message(struct net *net, __u8 *buffer,
+static void ip_vs_process_message(struct netns_ipvs *ipvs, __u8 *buffer,
 				  const size_t buflen)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_sync_mesg *m2 = (struct ip_vs_sync_mesg *)buffer;
 	__u8 *p, *msg_end;
 	int i, nr_conns;
@@ -1257,7 +1256,7 @@ static void ip_vs_process_message(struct net *net, __u8 *buffer,
 				return;
 			}
 			/* Process a single sync_conn */
-			retc = ip_vs_proc_sync_conn(net, p, msg_end);
+			retc = ip_vs_proc_sync_conn(ipvs->net, p, msg_end);
 			if (retc < 0) {
 				IP_VS_ERR_RL("BACKUP, Dropping buffer, Err: %d in decoding\n",
 					     retc);
@@ -1763,7 +1762,7 @@ static int sync_thread_backup(void *data)
 				break;
 			}
 
-			ip_vs_process_message(ipvs->net, tinfo->buf, len);
+			ip_vs_process_message(ipvs, tinfo->buf, len);
 		}
 	}
 
-- 
2.1.4

