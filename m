From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [patch net-next 1/4] [patch nf-next v2] IPVS: ICMPv6 checksum
 calculation
Date: Thu, 26 Aug 2010 22:36:24 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.1008262234270.3055@u.domain.uli>
References: <20100826125427.056491061@vergenet.net> <20100826125726.621600393@vergenet.net>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100826125726.621600393@vergenet.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, Xiaoyu Du <tingsrain@gmail.com>


	Hello,

On Thu, 26 Aug 2010, Simon Horman wrote:

> Cc: Xiaoyu Du <tingsrain@gmail.com>
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_core.c
> ===================================================================
> --- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_core.c	2010-08-25 16:57:37.000000000 +0900
> +++ nf-next-2.6/net/netfilter/ipvs/ip_vs_core.c	2010-08-25 17:02:35.000000000 +0900
> @@ -637,9 +637,11 @@ void ip_vs_nat_icmp_v6(struct sk_buff *s
>  	}
>  
>  	/* And finally the ICMP checksum */
> -	icmph->icmp6_cksum = 0;
> -	/* TODO IPv6: is this correct for ICMPv6? */
> -	ip_vs_checksum_complete(skb, icmp_offset);
> +	icmph->icmp6_cksum = ~csum_ipv6_magic(&iph->saddr, &iph->daddr,
> +					      skb->len - icmp_offset,
> +					      IPPROTO_ICMPV6, 0);
> +	skb->csum_start = skb_network_header(skb) - skb->head + icmp_offset;
> +	skb->csum_offset = offsetof(struct icmp6hdr, icmp6_cksum);
>  	skb->ip_summed = CHECKSUM_UNNECESSARY;

	Ops, this should be CHECKSUM_PARTIAL

>  	if (inout)

Regards

--
Julian Anastasov <ja@ssi.bg>
