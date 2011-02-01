From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re: [PATCH 2/5] IPVS: remove duplicate initialisation or 
	rs_table
Date: Tue, 1 Feb 2011 18:06:42 +0100 (CET)
Message-ID: <7j2t3lt.4903adc7917a92d71d2d5a0cc8fed87a@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, Randy Dunlap <randy.dunlap@oracle.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Patrick McHardy <kaber@trash.net>

>---- Original Message ----
>From: Simon Horman <horms@verge.net.au>
>To: netdev@vger.kernel.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org
>Cc: "Randy Dunlap" <randy.dunlap@oracle.com>, "Stephen Rothwell" <sfr@canb.auug.org.au>, "Hans Schillstrom" <hans@schillstrom.com>, "Patrick McHardy" <kaber@trash.net>, "Simon Horman" <horms@verge.net.au>
>Sent: Tue, Feb 1, 2011, 11:11 AM
>Subject: [PATCH 2/5] IPVS: remove duplicate initialisation or rs_table
>
>Cc: Hans Schillstrom <hans@schillstrom.com>
>Signed-off-by: Simon Horman <horms@verge.net.au>

Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
Tested-by: Hans Schillstrom <hans@schillstrom.com>

>---
> net/netfilter/ipvs/ip_vs_ctl.c |    3 ---
> 1 files changed, 0 insertions(+), 3 deletions(-)
>
>diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
>index 98df59a..d7c2fa8 100644
>--- a/net/netfilter/ipvs/ip_vs_ctl.c
>+++ b/net/netfilter/ipvs/ip_vs_ctl.c
>@@ -3515,9 +3515,6 @@ int __net_init __ip_vs_control_init(struct net *net)
> 	}
> 	spin_lock_init(&ipvs->tot_stats->lock);
> 
>-	for (idx = 0; idx < IP_VS_RTAB_SIZE; idx++)
>-		INIT_LIST_HEAD(&ipvs->rs_table[idx]);
>-
> 	proc_net_fops_create(net, "ip_vs", 0, &ip_vs_info_fops);
> 	proc_net_fops_create(net, "ip_vs_stats", 0, &ip_vs_stats_fops);
> 	proc_net_fops_create(net, "ip_vs_stats_percpu", 0,
>-- 
>1.7.2.3
>
>--
>To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

