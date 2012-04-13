From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re: [PATCH] ipvs: fix crash in ip_vs_control_net_cleanup 
	on unload
Date: Fri, 13 Apr 2012 21:51:13 +0200 (CEST)
Message-ID: <6dfqp4f.0faa011ca6cbe5c145c1b21e1d17f9ad@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org

Hello Julian
It looks  OK

>---- Original Message ----
>From: Julian Anastasov <ja@ssi.bg>
>To: "Simon Horman" <horms@verge.net.au>
>Cc: lvs-devel@vger.kernel.org
>Sent: Fri, Apr 13, 2012, 5:10 PM
>Subject: [PATCH] ipvs: fix crash in ip_vs_control_net_cleanup on unload
>
>commit 14e405461e664b777e2a5636e10b2ebf36a686ec (2.6.39)
>("Add __ip_vs_control_{init,cleanup}_sysctl()")
>introduced regression due to wrong __net_init for
>__ip_vs_control_cleanup_sysctl. This leads to crash when
>the ip_vs module is unloaded.
>
>	Fix it by changing __net_init to __net_exit for
>the function that is already renamed to ip_vs_control_net_cleanup_sysctl.
>
>Signed-off-by: Julian Anastasov <ja@ssi.bg>

Signed-off-by: Hans Schillstrom <hans@schillstrom.com>

>---
> net/netfilter/ipvs/ip_vs_ctl.c |    4 ++--
> 1 files changed, 2 insertions(+), 2 deletions(-)
>
>diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
>index 2172fcc..79b131c 100644
>--- a/net/netfilter/ipvs/ip_vs_ctl.c
>+++ b/net/netfilter/ipvs/ip_vs_ctl.c
>@@ -3704,7 +3704,7 @@ int __net_init ip_vs_control_net_init_sysctl(struct net *net)
> 	return 0;
> }
> 
>-void __net_init ip_vs_control_net_cleanup_sysctl(struct net *net)
>+void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net)
> {
> 	struct netns_ipvs *ipvs = net_ipvs(net);
> 
>@@ -3716,7 +3716,7 @@ void __net_init ip_vs_control_net_cleanup_sysctl(struct net *net)
> #else
> 
> int __net_init ip_vs_control_net_init_sysctl(struct net *net) { return 0; }
>-void __net_init ip_vs_control_net_cleanup_sysctl(struct net *net) { }
>+void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net) { }
> 
> #endif
> 
>-- 
>1.7.3.4
>
>--
>To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

