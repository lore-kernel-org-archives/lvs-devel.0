From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net] ipvs: properly declare tunnel encapsulation
Date: Mon, 25 Aug 2014 10:18:52 +0900
Message-ID: <20140825011852.GB31233@verge.net.au>
References: <1406878577-4506-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1406878577-4506-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Alex Gartrell <agartrell@fb.com>, kernel-team <Kernel-team@fb.com>

On Fri, Aug 01, 2014 at 10:36:17AM +0300, Julian Anastasov wrote:
> The tunneling method should properly use tunnel encapsulation.
> Fixes problem with CHECKSUM_PARTIAL packets when TCP/UDP csum
> offload is supported.
> 
> Thanks to Alex Gartrell for reporting the problem, providing
> solution and for all suggestions.

With this patch is Alex's patch "[PATCH ipvs] ipvs: invoke
skb_checksum_help prior to encapsulation in tunnel xmit " also needed?

> 
> Reported-by: Alex Gartrell <agartrell@fb.com>
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Alex Gartrell <agartrell@fb.com>
> ---
>  net/netfilter/ipvs/ip_vs_xmit.c | 20 ++++++++++++++++----
>  1 file changed, 16 insertions(+), 4 deletions(-)
> 
> I'm not sure if TUN mode worked with HW csum enabled, one with
> such hardware can check if the breakage happens after some kernel
> version.
> 
> Here is what I found for skb->encapsulation and support in drivers
> 
> - GRO started to use CHECKSUM_PARTIAL for TCP long time ago
> 
> - the skb->encapsulation support is added in 3.8
> 
> - BNX2 started to use inner header depending on skb->encapsulation
> in 3.10
> 
> - i40e appears in 3.12 and started to use inner header depending on
> skb->encapsulation
> 
> - iptunnel_handle_offloads() is added in 3.13. This patch
> uses this function.
> 
> - mlx4 started to use inner header depending on skb->encapsulation
> in 3.14
> 
> - benet started to use inner header depending on skb->encapsulation
> in 3.14
> 
> As result, I'm not sure that all devices support tunneled TCP/UDP,
> I see some drivers supported csum offload (CHECKSUM_PARTIAL) only
> if not tunneled. In the future if problem happens with csum
> offload we should check if the driver has support for tunneled
> TCP/UDP. Otherwise, user can disable the csum offload for device
> or as alternative we can add sysctl var in IPVS to call
> iptunnel_handle_offloads with csum_help = true.
> 
> For now I don't know which stable kernels wihout
> iptunnel_handle_offloads() function may need some alternative fix.
> 
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index 73ba1cc..5371654 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -38,6 +38,7 @@
>  #include <net/route.h>                  /* for ip_route_output */
>  #include <net/ipv6.h>
>  #include <net/ip6_route.h>
> +#include <net/ip_tunnels.h>
>  #include <net/addrconf.h>
>  #include <linux/icmpv6.h>
>  #include <linux/netfilter.h>
> @@ -862,11 +863,15 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
>  		old_iph = ip_hdr(skb);
>  	}
>  
> -	skb->transport_header = skb->network_header;
> -
>  	/* fix old IP header checksum */
>  	ip_send_check(old_iph);
>  
> +	skb = iptunnel_handle_offloads(skb, false, SKB_GSO_IPIP);
> +	if (IS_ERR(skb))
> +		goto tx_error;
> +
> +	skb->transport_header = skb->network_header;
> +
>  	skb_push(skb, sizeof(struct iphdr));
>  	skb_reset_network_header(skb);
>  	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
> @@ -900,7 +905,8 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
>  	return NF_STOLEN;
>  
>    tx_error:
> -	kfree_skb(skb);
> +	if (!IS_ERR(skb))
> +		kfree_skb(skb);
>  	rcu_read_unlock();
>  	LeaveFunction(10);
>  	return NF_STOLEN;
> @@ -953,6 +959,11 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
>  		old_iph = ipv6_hdr(skb);
>  	}
>  
> +	/* GSO: we need to provide proper SKB_GSO_ value for IPv6 */
> +	skb = iptunnel_handle_offloads(skb, false, 0); /* SKB_GSO_SIT/IPV6 */
> +	if (IS_ERR(skb))
> +		goto tx_error;
> +
>  	skb->transport_header = skb->network_header;
>  
>  	skb_push(skb, sizeof(struct ipv6hdr));
> @@ -988,7 +999,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
>  	return NF_STOLEN;
>  
>  tx_error:
> -	kfree_skb(skb);
> +	if (!IS_ERR(skb))
> +		kfree_skb(skb);
>  	rcu_read_unlock();
>  	LeaveFunction(10);
>  	return NF_STOLEN;
> -- 
> 1.9.0
> 
