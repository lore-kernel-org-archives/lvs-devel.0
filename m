From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [nf-next PATCH] ipvs: fix build error when CONFIG_IP_VS_IPV6 is
 disabled
Date: Mon, 22 Oct 2012 17:39:43 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1210221732480.3065@ask.diku.dk>
References: <20121022121711.31397.6231.stgit@dragon>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20121022121711.31397.6231.stgit@dragon>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Simon Horman <horms@verge.net.au>, fengguang.wu@intel.com, yuanhan.liu@linux.intel.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


Hi Pablo,

Argh - there is one more CONFIG option combi that can cause issues.

  *So hold off on this patch*

Which is related to including linux/netfilter_ipv6/ip6_tables.h under 
CONFIG_IPV6 when CONFIG_NETFILTER is disabled, as kernel/sysctl_binary.c 
include net/ip_vs.h.  I'll send a new patch soon!

--Jesper


On Mon, 22 Oct 2012, Jesper Dangaard Brouer wrote:

> From: Yuanhan Liu <yuanhan.liu@linux.intel.com>
>
> Fix build error introduced by commit 63dca2c0:
> "ipvs: Fix faulty IPv6 extension header handling in IPVS"
>
> The build error only occur, when CONFIG_IP_VS_IPV6 is disabled.
>
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Yuanhan Liu <yuanhan.liu@linux.intel.com>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
>
> include/net/ip_vs.h |    3 ++-
> 1 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index a681ad6..d930749 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -212,8 +212,9 @@ ip_vs_fill_iph_addr_only(int af, const struct sk_buff *skb,
> 			(struct ipv6hdr *)skb_network_header(skb);
> 		iphdr->saddr.in6 = iph->saddr;
> 		iphdr->daddr.in6 = iph->daddr;
> -	} else {
> +	} else
> #endif
> +	{
> 		const struct iphdr *iph =
> 			(struct iphdr *)skb_network_header(skb);
> 		iphdr->saddr.ip = iph->saddr;
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
