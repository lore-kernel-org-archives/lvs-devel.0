From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re: [PATCH 5/5] IPVS: Remove ip_vs_sync_cleanup from section 
	__exit
Date: Tue, 1 Feb 2011 18:12:31 +0100 (CET)
Message-ID: <7j2t3lt.e4ea73185e9c52a3d68dc337ed04b422@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, Randy Dunlap <randy.dunlap@oracle.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Patrick McHardy <kaber@trash.net>

>---- Original Message ----
>From: Simon Horman <horms@verge.net.au>
>To: netdev@vger.kernel.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org
>Cc: "Randy Dunlap" <randy.dunlap@oracle.com>, "Stephen Rothwell" <sfr@canb.auug.org.au>, "Hans Schillstrom" <hans@schillstrom.com>, "Patrick McHardy" <kaber@trash.net>, "Simon Horman" <horms@verge.net.au>
>Sent: Tue, Feb 1, 2011, 11:11 AM
>Subject: [PATCH 5/5] IPVS: Remove ip_vs_sync_cleanup from section __exit
>
>ip_vs_sync_cleanup() may be called from ip_vs_init() on error
>and thus needs to be accesible from section __init
>
>Reporte-by: Randy Dunlap <randy.dunlap@oracle.com>
>Signed-off-by: Simon Horman <horms@verge.net.au>

Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
Tested-by: Hans Schillstrom <hans@schillstrom.com>

>---
> net/netfilter/ipvs/ip_vs_sync.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
>
>diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
>index d5a6e64..2a2a836 100644
>--- a/net/netfilter/ipvs/ip_vs_sync.c
>+++ b/net/netfilter/ipvs/ip_vs_sync.c
>@@ -1686,7 +1686,7 @@ int __init ip_vs_sync_init(void)
> 	return register_pernet_subsys(&ipvs_sync_ops);
> }
> 
>-void __exit ip_vs_sync_cleanup(void)
>+void ip_vs_sync_cleanup(void)
> {
> 	unregister_pernet_subsys(&ipvs_sync_ops);
> }
>-- 
>1.7.2.3
>
>--
>To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
