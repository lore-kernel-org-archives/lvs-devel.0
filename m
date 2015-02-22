From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] ipvs: add missing ip_vs_pe_put in sync code
Date: Sun, 22 Feb 2015 16:25:00 -0500
Message-ID: <1424640300-30364-2-git-send-email-horms@verge.net.au>
References: <1424640300-30364-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1424640300-30364-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

ip_vs_conn_fill_param_sync() gets in param.pe a module
reference for persistence engine from __ip_vs_pe_getbyname()
but forgets to put it. Problem occurs in backup for
sync protocol v1 (2.6.39).

Also, pe_data usually comes in sync messages for
connection templates and ip_vs_conn_new() copies
the pointer only in this case. Make sure pe_data
is not leaked if it comes unexpectedly for normal
connections. Leak can happen only if bogus messages
are sent to backup server.

Fixes: fe5e7a1efb66 ("IPVS: Backup, Adding Version 1 receive capability")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sync.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index c47ffd7..d93ceeb 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -896,6 +896,8 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 			IP_VS_DBG(2, "BACKUP, add new conn. failed\n");
 			return;
 		}
+		if (!(flags & IP_VS_CONN_F_TEMPLATE))
+			kfree(param->pe_data);
 	}
 
 	if (opt)
@@ -1169,6 +1171,7 @@ static inline int ip_vs_proc_sync_conn(struct net *net, __u8 *p, __u8 *msg_end)
 				(opt_flags & IPVS_OPT_F_SEQ_DATA ? &opt : NULL)
 				);
 #endif
+	ip_vs_pe_put(param.pe);
 	return 0;
 	/* Error exit */
 out:
-- 
2.1.4

