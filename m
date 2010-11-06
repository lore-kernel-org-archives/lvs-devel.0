From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC v2] ipvs: allow transmit of GRO aggregated skbs
Date: Sat, 6 Nov 2010 16:18:21 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1011061608510.4009@ja.ssi.bg>
References: <20101105135222.GA8714@verge.net.au> <20101105235411.GA2443@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101105235411.GA2443@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org


 	Hello,

On Sat, 6 Nov 2010, Simon Horman wrote:

> This is a first attempt at allowing LVS to transmit
> skbs of greater than MTU length that have been aggregated by GRO.
>
> I have lightly tested the ip_vs_dr_xmit() portion of this patch and
> although it seems to work I am unsure that netif_needs_gso() is the correct
> test to use.

 	ip_forward() uses !skb_is_gso(skb), so may be it is
enough to check for GRO instead of using netif_needs_gso?

> Signed-off-by: Simon Horman <horms@verge.net.au>
>
> ---
>
> * LRO is still an outstanding issue, but as its deprecated in favour
>  of GRO perhaps it doesn't need to be solved.
>
> * v1
>  - Based on 2.6.35
>
> * v2
>  - Rebase on current nf-next-2.6 tree (~2.6.37-rc1)

> --- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_xmit.c	2010-10-30 11:43:37.000000000 +0900
> +++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_xmit.c	2010-11-06 08:09:17.000000000 +0900

> @@ -1008,7 +1012,8 @@ ip_vs_dr_xmit(struct sk_buff *skb, struc
>
> 	/* MTU checking */
> 	mtu = dst_mtu(&rt->dst);
> -	if ((iph->frag_off & htons(IP_DF)) && skb->len > mtu) {
> +	if ((iph->frag_off & htons(IP_DF)) && skb->len > mtu &&
> +	    !netif_needs_gso(rt->dst.dev, skb)) {
> 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
> 		ip_rt_put(rt);
> 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);

Regards

--
Julian Anastasov <ja@ssi.bg>
