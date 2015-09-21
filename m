From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 38/84] ipvs: Pass ipvs not net to ip_vs_process_message
Date: Mon, 21 Sep 2015 13:02:15 -0500
Message-ID: <1442858581-15869-38-git-send-email-ebiederm@xmission.com>
References: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
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
2.2.1

