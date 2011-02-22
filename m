From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re: [PATCH] ipvs: fix dst_lock locking on dest update
Date: Tue, 22 Feb 2011 10:11:46 +0100 (CET)
Message-ID: <1bn469k.97a49f75bfb99096f095e3668978fd0f@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>

>---- Original Message ----
>From: Julian Anastasov <ja@ssi.bg>
>To: "David S. Miller" <davem@davemloft.net>
>Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, "Simon Horman" <horms@verge.net.au>
>Sent: Tue, Feb 22, 2011, 9:36 AM
>Subject: [PATCH] ipvs: fix dst_lock locking on dest update
>
>Fix dst_lock usage in __ip_vs_update_dest. We need
>_bh locking because destination is updated in user context.
>Can cause lockups on frequent destination updates.
>Problem reported by Simon Kirby. Bug was introduced
>in 2.6.37 from the "ipvs: changes for local real server"
>change.
>
>Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>

>---
>
> 	Dave, please apply to net-2.6.
>Patch is for 2.6.37+ and applies to 2.6.38-rc6. There is
>little fuzz when applying to net-next, let me know if
>I should provide patch for other trees.

The patch seems to be OK in 2.6.38 expcept for line number.
All my thest runs without any problems.

>
>--- linux-2.6.37/net/netfilter/ipvs/ip_vs_ctl.c	2011-01-06 00:01:23.600069161 +0200
>+++ linux/net/netfilter/ipvs/ip_vs_ctl.c	2011-02-19 23:14:44.463250743 +0200
>@@ -810,9 +810,9 @@ __ip_vs_update_dest(struct ip_vs_service
>  	dest->u_threshold = udest->u_threshold;
>  	dest->l_threshold = udest->l_threshold;
>
>-	spin_lock(&dest->dst_lock);
>+	spin_lock_bh(&dest->dst_lock);
>  	ip_vs_dst_reset(dest);
>-	spin_unlock(&dest->dst_lock);
>+	spin_unlock_bh(&dest->dst_lock);
>
>  	if (add)
>  		ip_vs_new_estimator(&dest->stats);
>--


Hans Schillstrom <hans@schillstrom.com>


