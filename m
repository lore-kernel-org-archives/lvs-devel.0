From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 20/26] IPVS: Add IPv6 Netfilter hooks and add/modify support
 functions.
Date: Wed, 11 Jun 2008 21:55:35 -0400
Message-ID: <48508217.1070006@hp.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com> <1213204329-10973-21-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1213204329-10973-21-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: "Julius R. Volz" <juliusv@google.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, horms@verge.net.au, davem@davemloft.net, vbusam@google.com

Julius R. Volz wrote:
> +#ifdef CONFIG_IP_VS_IPV6
> +void ip_vs_nat_icmp_v6(struct sk_buff *skb, struct ip_vs_protocol *pp,
> +		    struct ip_vs_conn *cp, int inout)
> +{
> +	struct ipv6hdr *iph	 = ipv6_hdr(skb);
> +	unsigned int icmp_offset = sizeof(struct ipv6hdr);
> +	struct icmp6hdr *icmph	 = (struct icmp6hdr *)(skb_network_header(skb) +
> +						      icmp_offset);
> +	struct ipv6hdr *ciph	 = (struct ipv6hdr *)(icmph + 1);
> +
> +	if (inout) {
> +		iph->saddr = cp->vaddr.v6;
> +		ciph->daddr = cp->vaddr.v6;
> +	} else {
> +		iph->daddr = cp->daddr.v6;
> +		ciph->saddr = cp->daddr.v6;
> +	}

ipv6_addr_copy().

> +	/* mangle the packet */
> +	if (pp->snat_handler_v6 && !pp->snat_handler_v6(skb, pp, cp))
> +		goto drop;
> +	ipv6_hdr(skb)->saddr = cp->vaddr.v6;

ipv6_addr_copy().

-Brian
