From: Yannick Brosseau <scientist@fb.com>
Subject: [PATCH] ipvs: Remove dead debug code
Date: Thu, 26 Jun 2014 19:10:26 -0700
Message-ID: <1403835026-5506-1-git-send-email-scientist@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : mime-version : content-type; s=facebook;
 bh=qyfuTMDiZu42U0/1A8xl2Mrdfjsx+hkp61eqmi1UPME=;
 b=cUdJX/twMTuLbXXyofw8rG0iQ2QPQ+CD0ZlQZQfq9mp6l7xYa9Efi/UIVNOmZxZQv0oX
 Mq3hQGuac5zUME5OGgf4eC1ZCSiQ/t2pghSsT0BnG86MfH6ACeNda/YwG/L/Iu+Xds8L
 nc9/wUkFhn8z/LbfZEppZTLJwDmube6PHFU= 
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org
Cc: Yannick Brosseau <scientist@fb.com>

This code section cannot compile as it refer to non existing variable
It also pre-date git history.

Signed-off-by: Yannick Brosseau <scientist@fb.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 86 ------------------------------------------
 1 file changed, 86 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 581a658..8416307 100644
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

