From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch v3] ipvs: allow transmit of GRO aggregated skbs
Date: Tue, 9 Nov 2010 10:18:48 +0900
Message-ID: <20101109011847.GL6502@verge.net.au>
References: <20101109010847.GA13974@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101109010847.GA13974@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Julian Anastasov <ja@ssi.bg>, Herbert Xu <herbert@gondor.apana.org.au>

On Tue, Nov 09, 2010 at 10:08:49AM +0900, Simon Horman wrote:
> Attempt at allowing LVS to transmit skbs of greater than MTU length that
> have been aggregated by GRO and can thus be deaggregated by GSO.
> 
> Cc: Julian Anastasov <ja@ssi.bg>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> --- 
> 
> * LRO is still an outstanding issue, but as its deprecated in favour
>   of GRO perhaps it doesn't need to be solved.
> 
> * v1
>   - Based on 2.6.35
> 
> * v2
>   - Rebase on current nf-next-2.6 tree (~2.6.37-rc1)
> 
> * v3
>   - Use skb_is_gso() instead of netif_needs_gso() as suggested by
>     Julian Anastasov and confirmed by Herbert Xu.

On thinking about this a bit more, I believe that this is material
for stable as its affecting deployed systems. I'll back-port it
and add the appropriate CC once its seen a bit more testing.

> 
> Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_xmit.c
> ===================================================================
> --- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_xmit.c	2010-11-08 16:27:31.000000000 +0900
> +++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_xmit.c	2010-11-08 16:29:19.000000000 +0900
> @@ -408,7 +408,8 @@ ip_vs_bypass_xmit(struct sk_buff *skb, s
>  
>  	/* MTU checking */
>  	mtu = dst_mtu(&rt->dst);
> -	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF))) {
> +	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF)) &&
> +	    !skb_is_gso(skb)) {
>  		ip_rt_put(rt);
>  		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
>  		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
> @@ -461,7 +462,7 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb
>  
>  	/* MTU checking */
>  	mtu = dst_mtu(&rt->dst);
> -	if (skb->len > mtu) {
> +	if (skb->len > mtu && !skb_is_gso(skb)) {
>  		if (!skb->dev) {
>  			struct net *net = dev_net(skb_dst(skb)->dev);
>  
> @@ -560,7 +561,8 @@ ip_vs_nat_xmit(struct sk_buff *skb, stru
>  
>  	/* MTU checking */
>  	mtu = dst_mtu(&rt->dst);
> -	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF))) {
> +	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF)) &&
> +	    !skb_is_gso(skb)) {
>  		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
>  		IP_VS_DBG_RL_PKT(0, AF_INET, pp, skb, 0,
>  				 "ip_vs_nat_xmit(): frag needed for");
> @@ -675,7 +677,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, s
>  
>  	/* MTU checking */
>  	mtu = dst_mtu(&rt->dst);
> -	if (skb->len > mtu) {
> +	if (skb->len > mtu && !skb_is_gso(skb)) {
>  		if (!skb->dev) {
>  			struct net *net = dev_net(skb_dst(skb)->dev);
>  
> @@ -790,8 +792,8 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, s
>  
>  	df |= (old_iph->frag_off & htons(IP_DF));
>  
> -	if ((old_iph->frag_off & htons(IP_DF))
> -	    && mtu < ntohs(old_iph->tot_len)) {
> +	if ((old_iph->frag_off & htons(IP_DF) &&
> +	    mtu < ntohs(old_iph->tot_len) && !skb_is_gso(skb))) {
>  		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
>  		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
>  		goto tx_error_put;
> @@ -903,7 +905,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb
>  	if (skb_dst(skb))
>  		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), mtu);
>  
> -	if (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr)) {
> +	if (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr) &&
> +	    !skb_is_gso(skb)) {
>  		if (!skb->dev) {
>  			struct net *net = dev_net(skb_dst(skb)->dev);
>  
> @@ -1008,7 +1011,8 @@ ip_vs_dr_xmit(struct sk_buff *skb, struc
>  
>  	/* MTU checking */
>  	mtu = dst_mtu(&rt->dst);
> -	if ((iph->frag_off & htons(IP_DF)) && skb->len > mtu) {
> +	if ((iph->frag_off & htons(IP_DF)) && skb->len > mtu &&
> +	    !skb_is_gso(skb)) {
>  		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
>  		ip_rt_put(rt);
>  		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
> @@ -1174,7 +1178,8 @@ ip_vs_icmp_xmit(struct sk_buff *skb, str
>  
>  	/* MTU checking */
>  	mtu = dst_mtu(&rt->dst);
> -	if ((skb->len > mtu) && (ip_hdr(skb)->frag_off & htons(IP_DF))) {
> +	if ((skb->len > mtu) && (ip_hdr(skb)->frag_off & htons(IP_DF)) &&
> +	    !skb_is_gso(skb)) {
>  		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
>  		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
>  		goto tx_error_put;
> @@ -1288,7 +1293,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb,
>  
>  	/* MTU checking */
>  	mtu = dst_mtu(&rt->dst);
> -	if (skb->len > mtu) {
> +	if (skb->len > mtu && !skb_is_gso(skb)) {
>  		if (!skb->dev) {
>  			struct net *net = dev_net(skb_dst(skb)->dev);
>  
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
