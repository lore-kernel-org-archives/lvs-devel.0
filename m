From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 16/26] IPVS: Add IPv6 xmit forwarding functions.
Date: Wed, 11 Jun 2008 21:55:09 -0400
Message-ID: <485081FD.8000908@hp.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com> <1213204329-10973-17-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1213204329-10973-17-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: "Julius R. Volz" <juliusv@google.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, horms@verge.net.au, davem@davemloft.net, vbusam@google.com

Julius R. Volz wrote:
> +	/* mangle the packet */
> +	if (pp->dnat_handler_v6 && !pp->dnat_handler_v6(skb, pp, cp))
> +		goto tx_error;
> +	ipv6_hdr(skb)->daddr = cp->daddr.v6;

ipv6_addr_copy().

> +	/*
> +	 *	Push down and install the IPIP header.
> +	 */
> +	iph			=	ipv6_hdr(skb);
> +	iph->version		=	6;
> +	iph->nexthdr		=	IPPROTO_IPV6;
> +	iph->payload_len	=	old_iph->payload_len + sizeof(old_iph);
> +	iph->priority		=	old_iph->priority;
> +	memset(&iph->flow_lbl, 0, sizeof(iph->flow_lbl));	
> +	iph->daddr		=	rt->rt6i_dst.addr;
> +	iph->saddr		=	cp->vaddr.v6; /* rt->rt6i_src.addr; */

ipv6_addr_copy().

-Brian

