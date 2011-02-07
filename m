From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re: [patch] IPVS: precedence bug in ip_vs_sync_switch_mode()
Date: Mon, 7 Feb 2011 10:34:46 +0100 (CET)
Message-ID: <div5b80.5723d88b3447e2cae7eaaffaea275f79@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Dan Carpenter <error27@gmail.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, hans.schillstrom@ericsson.com, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, kernel-janitors@vger.kernel.org

>---- Original Message ----
>From: Dan Carpenter <error27@gmail.com>
>To: "Wensong Zhang" <wensong@linux-vs.org>
>Cc: "Simon Horman" <horms@verge.net.au>, "Julian Anastasov" <ja@ssi.bg>, hans.schillstrom@ericsson.com, "Patrick McHardy" <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, kernel-janitors@vger.kernel.org
>Sent: Mon, Feb 7, 2011, 9:39 AM
>Subject: [patch] IPVS: precedence bug in ip_vs_sync_switch_mode()
>
>'!' has higher precedence than '&'.  IP_VS_STATE_MASTER is 0x1 so
>the original code is equivelent to if (!ipvs->sync_state) ...
>
Oops,
Thanks
Hans

>Signed-off-by: Dan Carpenter <error27@gmail.com>
Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>

>
>diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
>index 2a2a836..d1b7298 100644
>--- a/net/netfilter/ipvs/ip_vs_sync.c
>+++ b/net/netfilter/ipvs/ip_vs_sync.c
>@@ -392,7 +392,7 @@ void ip_vs_sync_switch_mode(struct net *net, int mode)
> {
> 	struct netns_ipvs *ipvs = net_ipvs(net);
> 
>-	if (!ipvs->sync_state & IP_VS_STATE_MASTER)
>+	if (!(ipvs->sync_state & IP_VS_STATE_MASTER))
> 		return;
> 	if (mode == ipvs->sysctl_sync_ver || !ipvs->sync_buff)
> 		return;
>--


