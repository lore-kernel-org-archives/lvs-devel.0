From: Simon Horman <horms@verge.net.au>
Subject: Re: [nf-next PATCH v2] ipvs: fix build errors related to config
 option combinations
Date: Tue, 23 Oct 2012 09:33:15 +0900
Message-ID: <20121023003314.GC5015@verge.net.au>
References: <20121022192245.12620.84466.stgit@dragon>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121022192245.12620.84466.stgit@dragon>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, fengguang.wu@intel.com, yuanhan.liu@linux.intel.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Hans Schillstrom <hans.schillstrom@ericsson.com>

On Mon, Oct 22, 2012 at 09:22:45PM +0200, Jesper Dangaard Brouer wrote:
> Fix two build error introduced by commit 63dca2c0:
>  "ipvs: Fix faulty IPv6 extension header handling in IPVS"
> 
> First build error was fairly trivial and can occur, when
> CONFIG_IP_VS_IPV6 is disabled.
> 
> The second build error was tricky, and can occur when deselecting
> both all Netfilter and IPVS, but selecting CONFIG_IPV6.  This is
> caused by "kernel/sysctl_binary.c" including "net/ip_vs.h", which
> includes "linux/netfilter_ipv6/ip6_tables.h" causing include
> of "include/linux/netfilter/x_tables.h" which then cannot find
> the typedef nf_hookfn.
> 
> Fix this by only including "linux/netfilter_ipv6/ip6_tables.h" in
> case of CONFIG_IP_VS_IPV6 as its already used to guard the usage
> of ipv6_find_hdr().

Thanks, I have verified both of these fixes and I will send a pull
request ASAP.

I do wonder how we might get earlier test coverage of these kinds of problems.

> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Reported-by: Yuanhan Liu <yuanhan.liu@linux.intel.com>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
> 
>  include/net/ip_vs.h |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index a681ad6..68c69d5 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -22,7 +22,7 @@
>  #include <linux/ip.h>
>  #include <linux/ipv6.h>			/* for struct ipv6hdr */
>  #include <net/ipv6.h>
> -#if IS_ENABLED(CONFIG_IPV6)
> +#if IS_ENABLED(CONFIG_IP_VS_IPV6)
>  #include <linux/netfilter_ipv6/ip6_tables.h>
>  #endif
>  #if IS_ENABLED(CONFIG_NF_CONNTRACK)
> @@ -212,8 +212,9 @@ ip_vs_fill_iph_addr_only(int af, const struct sk_buff *skb,
>  			(struct ipv6hdr *)skb_network_header(skb);
>  		iphdr->saddr.in6 = iph->saddr;
>  		iphdr->daddr.in6 = iph->daddr;
> -	} else {
> +	} else
>  #endif
> +	{
>  		const struct iphdr *iph =
>  			(struct iphdr *)skb_network_header(skb);
>  		iphdr->saddr.ip = iph->saddr;
> 
