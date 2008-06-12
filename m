From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 02/26] IPVS: Change IPVS data structures to support IPv6
 addresses.
Date: Wed, 11 Jun 2008 21:54:48 -0400
Message-ID: <485081E8.80102@hp.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com> <1213204329-10973-3-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1213204329-10973-3-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: "Julius R. Volz" <juliusv@google.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, horms@verge.net.au, davem@davemloft.net, vbusam@google.com

Julius R. Volz wrote:
> +union ip_vs_addr_user {
> +	__be32			v4;
> +	struct in6_addr		v6;
> +};
> +
> +#ifdef CONFIG_IP_VS_IPV6
> +#define ip_vs_addr		ip_vs_addr_user
> +#define ip_vs_copy_addr(a, b)	do { (a) = (b); } while (0)
> +#else
> +union ip_vs_addr {
> +	__be32			v4;
> +};
> +#define ip_vs_copy_addr(a, b)	do { (a).v4 = (b).v4; } while (0)
> +#endif

You need to use ipv6_addr_copy() with IPv6 addresses.  Some of your 
other patches have this same problem, I found some of them...

-Brian
