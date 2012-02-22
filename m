From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 1/2] IPVS Bug IPv6 extension header handling faulty.
Date: Wed, 22 Feb 2012 03:07:54 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1202220040001.1685@ja.ssi.bg>
References: <1329223689-19792-1-git-send-email-hans.schillstrom@ericsson.com> <1329223689-19792-2-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1329223689-19792-2-git-send-email-hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, kaber@trash.net, pablo@netfilter.org, hans@schillstrom.com


	Hello,

On Tue, 14 Feb 2012, Hans Schillstrom wrote:

> IPv6 headers must be processed in order of apperence,
> neither can it be assumed that Upper layer headers is first.
> If anything else than L4 is the first header IPVS will throw it.
> 
> IPVS will write SNAT & DNAT modifications at a fixed pos witch
> will corrupt the message. Proper header possition must be found
> before writing modifying packet.
> 
> Since it is quite costly to scan and find ipv6 headers, it
> is done once and sent as "struct iphdr *" to affected funcs.
> This is what causes most of the changes in this patch.
> 
> This patch depends on "NETFILTER added flags to ipv6_find_hdr()" patch
> http://www.spinics.net/lists/netfilter-devel/msg20684.html
> 
> This also adds a dependence to ip6_tables.
> 
> Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> ---

>  static inline void
> -ip_vs_fill_iphdr(int af, const void *nh, struct ip_vs_iphdr *iphdr)
> +ip_vs_fill_ip4hdr(const void *nh, struct ip_vs_iphdr *iphdr)
>  {
> +	const struct iphdr *iph = nh;
> +
> +	iphdr->len = iph->ihl * 4;
> +	iphdr->offs = 0;
> +	iphdr->fragoffs = 0;
> +	iphdr->protocol = iph->protocol;
> +	iphdr->flags = 0;

	May be there is no need ip_vs_fill_ip4hdr to initialize
the new fields that are IPv6 specific.

> +	iphdr->saddr.ip = iph->saddr;
> +	iphdr->daddr.ip = iph->daddr;
> +}
> +

> @@ -1379,8 +1347,8 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
>  	/* do the statistics and put it back */
>  	ip_vs_in_stats(cp, skb);
>  	if (IPPROTO_TCP == cih->protocol || IPPROTO_UDP == cih->protocol)
> -		offset += 2 * sizeof(__u16);
> -	verdict = ip_vs_icmp_xmit(skb, cp, pp, offset, hooknum);
> +		ciph.len += 2 * sizeof(__u16);

	Can we avoid adding ports to ciph.len? May be we can
use the offset var and to provide it to ip_vs_icmp_xmit,
just like for IPv6 below.

> +	verdict = ip_vs_icmp_xmit(skb, cp, pp, ciph.len, hooknum, &ciph);
>  
>  out:
>  	__ip_vs_conn_put(cp);
> @@ -1389,14 +1357,11 @@ out:
>  }
> -	if (IPPROTO_TCP == cih->nexthdr || IPPROTO_UDP == cih->nexthdr ||
> -	    IPPROTO_SCTP == cih->nexthdr)
> -		offset += 2 * sizeof(__u16);
> -	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, offset, hooknum);
> +	if (IPPROTO_TCP == ciph.protocol || IPPROTO_UDP == ciph.protocol ||
> +	    IPPROTO_SCTP == ciph.protocol)
> +		offset = ciph.len + (2 * sizeof(__u16));
> +
> +	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, offset, hooknum, &ciph);
>  
>  	__ip_vs_conn_put(cp);
>  

> @@ -1546,7 +1508,8 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
>  
>  			if (related)
>  				return verdict;
> -			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
> +			/* I don't think this one is needed ... /HS */
> +			ip_vs_fill_iph_skb(af, skb, &iph);

	Yes, I don't remember why we need this, may be
there were pointers in the structure long time ago.

	As for patch 2, it is dangerous to use skb_dst_copy
without checking for present dst. And I don't think skb_dst_drop
will be appropriate before every skb_dst_copy call.

	Do you see any dst and mark in ip_vs_preroute_frag6?
I mean, isn't nf_ct_frag6_output just passing all fragments
without any dst and mark? May be everything depends on
__ipv6_conntrack_in to track the reassembled packet? What
happens if IPVS works without conntrack support?

	And what should be the goal? To pass all fragments
via IPVS SNAT/DNAT and transmitters? So, we must schedule/track
first fragment in IPVS and all other fragments should be routed
in the same way? And the question is how the first fragment
should be used by all following fragments? It is very
difficult to mangle the packets if the fragments do not
come in single skb as for IPv4. We need to use something
like ip_defrag, is nf_ct_frag6_gather such analog?
After working with single skb we can send it to LOCAL_OUT for
fragmenting.

	As for the dependencies, may be we should also select
CONFIG_NF_DEFRAG_IPV6 for config IP_VS_IPV6?

Regards

--
Julian Anastasov <ja@ssi.bg>
