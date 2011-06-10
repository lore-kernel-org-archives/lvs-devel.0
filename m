From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: netfilter: ipvs: clean up the dead code
Date: Fri, 10 Jun 2011 15:11:14 +0800
Message-ID: <1307689874-10890-1-git-send-email-xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:from:to:cc:subject:date:message-id:x-mailer;
        bh=A4Y3oHKq3phYYIJTgrXD6SpejL7ey6DiBJVT1yueYEo=;
        b=Hn57zj5L8CLxh/r6XMcFi2tQ0gvevfGauKGTAldLMZZWEV0L3uOSqSIhcqIfYbQz2h
         CpSCgtf7QfZn8mqbuOiSnT6k16DpCltWgzqUa/6lKvSt9/7WtP9iIi6INaFISRf8LNBs
         s9yJhXZ24eM4RgYIiw1esW9NBpQzqq7myi+5Y=
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>

This dead code has been commented out since 2005, and too many things
have happened. Currently, even vs_timeout_table_dos doesn't exist.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c |   86 -----------------------------------------
 1 file changed, 86 deletions(-)
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 699c79a..f6670da 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1756,92 +1756,6 @@ static struct ctl_table vs_vars[] = {
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
 
