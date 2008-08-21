From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH RFC 08/24] IPVS: Make protocol handler functions support
 IPv6
Date: Thu, 21 Aug 2008 09:29:31 -0400
Message-ID: <48AD6DBB.9030607@hp.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com> <1219248931-15064-9-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1219248931-15064-9-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, horms@verge.net.au, kaber@trash.net, vbusam@google.com

Julius Volz wrote:
> +void
> +ip_vs_tcpudp_debug_packet(struct ip_vs_protocol *pp,
> +			  const struct sk_buff *skb,
> +			  int offset,
> +			  const char *msg)
> +{
> +#ifdef CONFIG_IP_VS_IPV6
> +	if (skb->protocol == __constant_htons(ETH_P_IPV6))
> +		ip_vs_tcpudp_debug_packet_v6(pp, skb, offset, msg);
> +	else
> +#endif

I don't think you need the __constant_htons() here, just htons() - 
that's what tcp_ipv6.c does.

> +static void
> +ah_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
> +		int offset, const char *msg)
> +{
> +#ifdef CONFIG_IP_VS_IPV6
> +	if (skb->protocol == __constant_htons(ETH_P_IPV6))
> +		ah_debug_packet_v6(pp, skb, offset, msg);
> +	else
> +#endif

htons()

> +static void
> +esp_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
> +		 int offset, const char *msg)
> +{
> +#ifdef CONFIG_IP_VS_IPV6
> +	if (skb->protocol == __constant_htons(ETH_P_IPV6))
> +		esp_debug_packet_v6(pp, skb, offset, msg);
> +	else
> +#endif

htons()

I think there's more in one of the other patches too.

So why can't you just create one ip_vs_debug_packet_v6() instead of 
these ah and esp ones which are identical?

-Brian
