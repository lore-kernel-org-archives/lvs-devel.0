From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: fix dst_lock locking on dest update
Date: Wed, 23 Feb 2011 09:26:24 +0900
Message-ID: <20110223002622.GI22597@verge.net.au>
References: <alpine.LFD.2.00.1102220949510.2388@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1102220949510.2388@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

On Tue, Feb 22, 2011 at 10:40:25AM +0200, Julian Anastasov wrote:
> 
> 	Fix dst_lock usage in __ip_vs_update_dest. We need
> _bh locking because destination is updated in user context.
> Can cause lockups on frequent destination updates.
> Problem reported by Simon Kirby. Bug was introduced
> in 2.6.37 from the "ipvs: changes for local real server"
> change.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Acked-by: Simon Horman <horms@verge.net.au>

> ---
> 
> 	Dave, please apply to net-2.6.
> Patch is for 2.6.37+ and applies to 2.6.38-rc6. There is
> little fuzz when applying to net-next, let me know if
> I should provide patch for other trees.
> 
> --- linux-2.6.37/net/netfilter/ipvs/ip_vs_ctl.c	2011-01-06 00:01:23.600069161 +0200
> +++ linux/net/netfilter/ipvs/ip_vs_ctl.c	2011-02-19 23:14:44.463250743 +0200
> @@ -810,9 +810,9 @@ __ip_vs_update_dest(struct ip_vs_service
>  	dest->u_threshold = udest->u_threshold;
>  	dest->l_threshold = udest->l_threshold;
> 
> -	spin_lock(&dest->dst_lock);
> +	spin_lock_bh(&dest->dst_lock);
>  	ip_vs_dst_reset(dest);
> -	spin_unlock(&dest->dst_lock);
> +	spin_unlock_bh(&dest->dst_lock);
> 
>  	if (add)
>  		ip_vs_new_estimator(&dest->stats);
> 
