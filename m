From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] IPVS: Add handling of incoming ICMPV6_PKT_TOOBIG
	messages
Date: Sun, 28 Jun 2009 17:43:02 +0200
Message-ID: <20090628154302.GB21519@verge.net.au>
References: <20090624132232.GA9633@egardia>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090624132232.GA9633@egardia>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <julius.volz@gmail.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, robert.gallagher@heanet.ie

On Wed, Jun 24, 2009 at 03:22:32PM +0200, Julius Volz wrote:
> Add handling of incoming ICMPv6 Packet Too Big messages. This message
> is received when a realserver sends a packet >PMTU to the client. The
> hop on this path with insufficient MTU will generate an ICMPv6 Packet
> Too Big message back to the VIP. The LVS server receives this message,
> but the call to the function handling this has been missing. Thus, IPVS
> fails to forward the message to the real server, which then does not
> adjust the path MTU. This patch adds the missing call to
> ip_vs_in_icmp_v6() in ip_vs_in() to handle this situation.
> 
> Thanks to Rob Gallagher from HEAnet for reporting this issue and for
> testing this patch in production (with direct routing mode).
> 
> Signed-off-by: Julius Volz <julius.volz@gmail.com>
> Tested-by: Rob Gallagher <robert.gallagher@heanet.ie>

Hi Julius, Hi Rob,

this seems reasonable to me, although it seems that the following
code is common. I wonder if its repetition could be removed.

			if (related)
				return verdict;
			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);

On a not very related note, I'm currently on holidays and
my net access is very sporadic. I'll be back at my desk on the 8th.

> ---
>  net/netfilter/ipvs/ip_vs_core.c |   23 +++++++++++++++++------
>  1 files changed, 17 insertions(+), 6 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index 8dddb17..5750800 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1274,13 +1274,24 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
>  		return NF_ACCEPT;
>  	}
>  
> -	if (unlikely(iph.protocol == IPPROTO_ICMP)) {
> -		int related, verdict = ip_vs_in_icmp(skb, &related, hooknum);
> +#ifdef CONFIG_IP_VS_IPV6
> +	if (af == AF_INET6) {
> +		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
> +			int related, verdict = ip_vs_in_icmp_v6(skb, &related, hooknum);
>  
> -		if (related)
> -			return verdict;
> -		ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
> -	}
> +			if (related)
> +				return verdict;
> +			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
> +		}
> +	} else
> +#endif
> +		if (unlikely(iph.protocol == IPPROTO_ICMP)) {
> +			int related, verdict = ip_vs_in_icmp(skb, &related, hooknum);
> +
> +			if (related)
> +				return verdict;
> +			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
> +		}
>  
>  	/* Protocol supported? */
>  	pp = ip_vs_proto_get(iph.protocol);
> -- 
> 1.6.0.4
