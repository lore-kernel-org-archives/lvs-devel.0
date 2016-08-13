From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: decrement forwarded packet's IP ttl
Date: Sat, 13 Aug 2016 14:40:58 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1608131412080.1609@ja.home.ssi.bg>
References: <1470801358.31822.4.camel@oc0624138382>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1470801358.31822.4.camel@oc0624138382>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dwip N. Banerjee" <dwip@linux.vnet.ibm.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Tue, 9 Aug 2016, Dwip N. Banerjee wrote:

> We decrement the IP ttl in all the modes in order to prevent infinite
> route loops. The changes were done based on Julian Anastasov's
> suggestions in a prior thread. 
> 
> The (ttl <= 1) check/discard and the actual decrement are done in 
> __ip_vs_get_out_rt() and in __ip_vs_get_out_rt_v6(), for the IPv6
> case. Because of the ttl change, the skb_make_writable() guard is 
> also invoked therein.
> 
> The !ip_vs_iph_icmp(ipvsh) checks are removed from
> ensure_mtu_is_adequate() as they seem unnecessary (icmp code doesn't
> send ICMP error in response to another ICMP error).
> 
> Signed-off-by: Dwip Banerjee <dwip@linux.vnet.ibm.com>
> ---
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c
> b/net/netfilter/ipvs/ip_vs_xmit.c
> index 01d3d89..e3586bd 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -225,7 +225,7 @@ static inline bool ensure_mtu_is_adequate(struct
> netns_ipvs *ipvs, int skb_af,

	Note that your patch is corrupted here. May be the
email client wraps long lines. I guess Documentation/email-clients.txt
has instructions for your email client how to send patches
without modifying them. You can also test it yourself before
sending PATCHv2:

scripts/checkpatch.pl --strict /tmp/ttl1.diff

or

patch -p1 --dry-run < /tmp/ttl1.diff

>  			if (!skb->dev)
>  				skb->dev = net->loopback_dev;
>  			/* only send ICMP too big on first fragment */
> -			if (!ipvsh->fragoffs && !ip_vs_iph_icmp(ipvsh))
> +			if (!ipvsh->fragoffs)
>  				icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);

	Better such change not to be part of this patch.
If you want to remove this call it should happen in
separate patch.

>  			IP_VS_DBG(1, "frag needed for %pI6c\n",
>  				  &ipv6_hdr(skb)->saddr);
> @@ -241,8 +241,7 @@ static inline bool ensure_mtu_is_adequate(struct
> netns_ipvs *ipvs, int skb_af,
>  			return true;
>  
>  		if (unlikely(ip_hdr(skb)->frag_off & htons(IP_DF) &&
> -			     skb->len > mtu && !skb_is_gso(skb) &&
> -			     !ip_vs_iph_icmp(ipvsh))) {
> +			     skb->len > mtu && !skb_is_gso(skb))) {

	Ditto

>  			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
>  				  htonl(mtu));
>  			IP_VS_DBG(1, "frag needed for %pI4\n",
> @@ -266,6 +265,7 @@ __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int
> skb_af, struct sk_buff *skb,
>  	struct rtable *rt;			/* Route to the other host */
>  	int mtu;
>  	int local, noref = 1;
> +	struct iphdr  *iph = ip_hdr(skb);
>  
>  	if (dest) {
>  		dest_dst = __ip_vs_dst_check(dest);
> @@ -326,6 +326,14 @@ __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int
> skb_af, struct sk_buff *skb,
>  		return local;
>  	}
>  
> +	if (iph->ttl <= 1) {
> +		/* Tell the sender its packet died... */
> +		__IP_INC_STATS(dev_net(skb_dst(skb)->dev),
> +			       IPSTATS_MIB_INHDRERRORS);
> +		icmp_send(skb, ICMP_TIME_EXCEEDED, ICMP_EXC_TTL, 0);
> +		goto err_put;
> +	}
> +

	This place is correct. But there is one problem.
When __ip_vs_get_out_rt is called, it is because dest (the real
server) is v4 but we can actually forward IPv6 datagram as indicated
by skb_af.

	This exception can happen only for TUN where we support v4-in-v6
and v6-in-v4 tunnels. So, we have to create new function just like
ensure_mtu_is_adequate where we have to work based on skb_af.
We can hide there the ttl check, the skb_make_writable call and
the ttl decrease. skb_af indicates what kind of outer IP header
we have before processing. The new function will include handling
for both skb_af families just like it is done in ensure_mtu_is_adequate.
We will call it from this place.

>  	if (likely(!(rt_mode & IP_VS_RT_MODE_TUNNEL))) {
>  		mtu = dst_mtu(&rt->dst);
>  	} else {
> @@ -349,6 +357,13 @@ __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int
> skb_af, struct sk_buff *skb,
>  	} else
>  		skb_dst_set(skb, &rt->dst);
>  
> +	/* don't propagate ttl change to cloned packets */
> +	if (!skb_make_writable(skb, sizeof(struct iphdr)))
> +		goto err_put;
> +
> +	/* Decrease ttl */
> +	ip_decrease_ttl(iph);
> +

	For the new function.

>  	return local;
>  
>  err_put:
> @@ -414,6 +429,7 @@ __ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int
> skb_af, struct sk_buff *skb,
>  	struct dst_entry *dst;
>  	int mtu;
>  	int local, noref = 1;
> +	struct ipv6hdr *hdr = ipv6_hdr(skb);
>  
>  	if (dest) {
>  		dest_dst = __ip_vs_dst_check(dest);
> @@ -473,6 +489,19 @@ __ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int
> skb_af, struct sk_buff *skb,
>  		return local;
>  	}
>  
> +	/* check and decrement ttl */
> +	if (hdr->hop_limit <= 1) {
> +		/* Force OUTPUT device used as source address */
> +		if (!dst)
> +			dst = skb_dst(skb);
> +		skb->dev = dst->dev;
> +		icmpv6_send(skb, ICMPV6_TIME_EXCEED, ICMPV6_EXC_HOPLIMIT, 0);
> +		__IP6_INC_STATS(net, ip6_dst_idev(dst),
> +				IPSTATS_MIB_INHDRERRORS);
> +
> +		goto err_put;
> +	}
> +

	We will call the same new function here.

>  	/* MTU checking */
>  	if (likely(!(rt_mode & IP_VS_RT_MODE_TUNNEL)))
>  		mtu = dst_mtu(&rt->dst);
> @@ -498,6 +527,11 @@ __ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int
> skb_af, struct sk_buff *skb,
>  	} else
>  		skb_dst_set(skb, &rt->dst);
>  
> +	/* don't propagate ttl change to cloned packets */
> +	if (!skb_make_writable(skb, sizeof(struct ipv6hdr)))
> +		goto err_put;
> +
> +	hdr->hop_limit--;

	For the new function.

>  	return local;
>  
>  err_put:
> @@ -739,9 +773,6 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct
> ip_vs_conn *cp,
>  	}
>  
>  	/* copy-on-write the packet before mangling it */
> -	if (!skb_make_writable(skb, sizeof(struct iphdr)))
> -		goto tx_error;
> -

	We have to keep this call because our skb_make_writable
in the new function happens only for local=0 while above call
is still needed for the local=1 case.

>  	if (skb_cow(skb, rt->dst.dev->hard_header_len))
>  		goto tx_error;
>  
> @@ -831,9 +862,6 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct
> ip_vs_conn *cp,
>  	}
>  
>  	/* copy-on-write the packet before mangling it */
> -	if (!skb_make_writable(skb, sizeof(struct ipv6hdr)))
> -		goto tx_error;
> -

	Ditto, we have to keep it.

>  	if (skb_cow(skb, rt->dst.dev->hard_header_len))
>  		goto tx_error;
>  
> @@ -1302,9 +1330,6 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct
> ip_vs_conn *cp,
>  	}
>  
>  	/* copy-on-write the packet before mangling it */
> -	if (!skb_make_writable(skb, offset))
> -		goto tx_error;
> -

	May be we have to keep this skb_make_writable in the
case of ICMP because the calling function calculates 'offset'
to include many headers while our new skb_make_writable will
cover only outer IP header. It is needed also for the local=1
case.

>  	if (skb_cow(skb, rt->dst.dev->hard_header_len))
>  		goto tx_error;
>  
> @@ -1394,9 +1419,6 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct
> ip_vs_conn *cp,
>  	}
>  
>  	/* copy-on-write the packet before mangling it */
> -	if (!skb_make_writable(skb, offset))
> -		goto tx_error;
> -

	Ditto, we have to keep it here.

>  	if (skb_cow(skb, rt->dst.dev->hard_header_len))
>  		goto tx_error;

Regards

--
Julian Anastasov <ja@ssi.bg>
