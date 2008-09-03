From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHv3 16/24] IPVS: Add/adjust Netfilter hook functions and
	helpers for v6
Date: Wed, 3 Sep 2008 15:44:00 +1000
Message-ID: <20080903054359.GB16875@verge.net.au>
References: <1220363755-9854-1-git-send-email-juliusv@google.com> <1220363755-9854-17-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1220363755-9854-17-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Tue, Sep 02, 2008 at 03:55:47PM +0200, Julius Volz wrote:
> Add Netfilter hook functions or modify existing ones, if possible, to
> process IPv6 packets. Some support functions are also added/modified for
> this. ip_vs_nat_icmp_v6() was already added in the patch that added the v6
> xmit functions, as it is called from one of them.

Hi Julius,

I was looking over this code a bit more closely to rebase someone
elses patch (which I intend to post very soon). I noticed two
minor things.

1) ipl doesn't seem to be needed in ip_vs_out_icmp() any more.
   But actually I'm quite ok with it staying there because the
   patch I was working on will need it.

2) I wonder if iph could be initialised earleir in ip_vs_out_icmp_v6()

[snip]

> @@ -727,11 +759,117 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related)

>  	return verdict;
>  }
>  
> -static inline int is_tcp_reset(const struct sk_buff *skb)
> +#ifdef CONFIG_IP_VS_IPV6
> +static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related)
> +{
> +	struct ipv6hdr *iph;
> +	struct icmp6hdr	_icmph, *ic;
> +	struct ipv6hdr	_ciph, *cih;	/* The ip header contained
> +					   within the ICMP */
> +	struct ip_vs_iphdr ciph;
> +	struct ip_vs_conn *cp;
> +	struct ip_vs_protocol *pp;
> +	unsigned int offset, verdict;
> +
> +	*related = 1;
> +
> +	/* reassemble IP fragments */
> +	if (ipv6_hdr(skb)->nexthdr == IPPROTO_FRAGMENT) {
> +		if (ip_vs_gather_frags_v6(skb, IP_DEFRAG_VS_OUT))
> +			return NF_STOLEN;
> +	}
> +
> +	iph = ipv6_hdr(skb);

Would it be worthwhile rearanging things so that iph is intialised
before "/* reassemble IP fragments */" and used instead
of ipv6_hdr(skb)->nexthdr in the if statement?

> +	offset = sizeof(struct ipv6hdr);
> +	ic = skb_header_pointer(skb, offset, sizeof(_icmph), &_icmph);
> +	if (ic == NULL)
> +		return NF_DROP;
> +
> +	IP_VS_DBG(12, "Outgoing ICMPv6 (%d,%d) " NIP6_FMT "->" NIP6_FMT "\n",
> +		  ic->icmp6_type, ntohs(icmpv6_id(ic)),
> +		  NIP6(iph->saddr), NIP6(iph->daddr));

[snip]

