From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHv2 RFC 16/25] IPVS: Add/adjust Netfilter hook functions
	and helpers for v6
Date: Tue, 2 Sep 2008 17:40:51 +1000
Message-ID: <20080902074049.GH13730@verge.net.au>
References: <1220273782-19901-1-git-send-email-juliusv@google.com> <1220273782-19901-17-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1220273782-19901-17-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Mon, Sep 01, 2008 at 02:56:13PM +0200, Julius Volz wrote:
> Add Netfilter hook functions or modify existing ones, if possible, to
> process IPv6 packets. Some support functions are also added/modified for
> this. ip_vs_nat_icmp_v6() was already added in the patch that added the v6
> xmit functions, as it is called from one of them.
> 
> Signed-off-by: Julius Volz <juliusv@google.com>

Please run checkpatch.pl over this patch.

>  1 files changed, 326 insertions(+), 36 deletions(-)
> 
> diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
> index 8bfd7c2..0bf871c 100644
> --- a/net/ipv4/ipvs/ip_vs_core.c
> +++ b/net/ipv4/ipvs/ip_vs_core.c
> @@ -39,6 +39,11 @@
>  #include <linux/netfilter.h>
>  #include <linux/netfilter_ipv4.h>
>  
> +#ifdef CONFIG_IP_VS_IPV6
> +#include <net/ipv6.h>
> +#include <linux/netfilter_ipv6.h>
> +#endif
> +
>  #include <net/ip_vs.h>
>  
>  
> @@ -60,6 +65,7 @@ EXPORT_SYMBOL(ip_vs_get_debug_level);
>  
>  /* ID used in ICMP lookups */
>  #define icmp_id(icmph)          (((icmph)->un).echo.id)
> +#define icmpv6_id(icmph)        (icmph->icmp6_dataun.u_echo.identifier)

Should this be ((icmph)->icmp6_dataun.u_echo.identifier) ?
