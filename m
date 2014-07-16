From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 2/2] ipvs: Remove dead debug code
Date: Wed, 16 Jul 2014 10:11:30 +0900
Message-ID: <1405473090-10432-3-git-send-email-horms@verge.net.au>
References: <1405473090-10432-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1405473090-10432-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Yannick Brosseau <scientist@fb.com>, Simon Horman <horms@verge.net.au>

From: Yannick Brosseau <scientist@fb.com>

This code section cannot compile as it refer to non existing variable
It also pre-date git history.

Signed-off-by: Yannick Brosseau <scientist@fb.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 86 ------------------------------------------
 1 file changed, 86 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c42e83d..335fdb8 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1807,92 +1807,6 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= proc_dointvec,
 	},
 #endif
-#if 0
-	{
-		.procname	= "timeout_established",
-		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_ESTABLISHED],
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "timeout_synsent",
-		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_SYN_SENT],
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "timeout_synrecv",
-		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_SYN_RECV],
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "timeout_finwait",
-		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_FIN_WAIT],
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "timeout_timewait",
-		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_TIME_WAIT],
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "timeout_close",
-		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_CLOSE],
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "timeout_closewait",
-		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_CLOSE_WAIT],
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "timeout_lastack",
-		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_LAST_ACK],
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "timeout_listen",
-		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_LISTEN],
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "timeout_synack",
-		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_SYNACK],
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "timeout_udp",
-		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_UDP],
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "timeout_icmp",
-		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_ICMP],
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-#endif
 	{ }
 };
 
-- 
2.0.0
