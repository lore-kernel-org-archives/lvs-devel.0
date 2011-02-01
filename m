From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re: [PATCH 1/5] IPVS: use z modifier for sizeof() argument
Date: Tue, 1 Feb 2011 18:06:04 +0100 (CET)
Message-ID: <7j2t3lt.0bb71e5c0a810a6ca8a0973db50566ea@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, Randy Dunlap <randy.dunlap@oracle.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Patrick McHardy <kaber@trash.net>

>---- Original Message ----
>From: Simon Horman <horms@verge.net.au>
>To: netdev@vger.kernel.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org
>Cc: "Randy Dunlap" <randy.dunlap@oracle.com>, "Stephen Rothwell" <sfr@canb.auug.org.au>, "Hans Schillstrom" <hans@schillstrom.com>, "Patrick McHardy" <kaber@trash.net>, "Simon Horman" <horms@verge.net.au>
>Sent: Tue, Feb 1, 2011, 11:08 AM
>Subject: [PATCH 1/5] IPVS: use z modifier for sizeof() argument
>
>Cc: Hans Schillstrom <hans@schillstrom.com>
>Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
>Signed-off-by: Simon Horman <horms@verge.net.au>

Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
Tested-by: Hans Schillstrom <hans@schillstrom.com>

>---
> net/netfilter/ipvs/ip_vs_core.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
>
>diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
>index d889f4f..4d06617 100644
>--- a/net/netfilter/ipvs/ip_vs_core.c
>+++ b/net/netfilter/ipvs/ip_vs_core.c
>@@ -1887,7 +1887,7 @@ static int __net_init __ip_vs_init(struct net *net)
> 	ipvs->gen = atomic_read(&ipvs_netns_cnt);
> 	atomic_inc(&ipvs_netns_cnt);
> 	net->ipvs = ipvs;
>-	printk(KERN_INFO "IPVS: Creating netns size=%lu id=%d\n",
>+	printk(KERN_INFO "IPVS: Creating netns size=%zu id=%d\n",
> 			 sizeof(struct netns_ipvs), ipvs->gen);
> 	return 0;
> }
>-- 
>1.7.2.3
>
>--
>To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

