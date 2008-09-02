From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHv2 RFC 21/25] IPVS: Add function to determine if IPv6
	address is local
Date: Tue, 2 Sep 2008 17:57:19 +1000
Message-ID: <20080902075718.GK13730@verge.net.au>
References: <1220273782-19901-1-git-send-email-juliusv@google.com> <1220273782-19901-22-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1220273782-19901-22-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Mon, Sep 01, 2008 at 02:56:18PM +0200, Julius Volz wrote:
> From: Vince Busam <vbusam@google.com>
> 
> Add __ip_vs_addr_is_local_v6() to find out if an IPv6 address belongs to a
> local interface. Use this function to decide whether to set the
> IP_VS_CONN_F_LOCALNODE flag for IPv6 destinations.

Hi Vince,

could you please fix the following minor problems that were flagged
by checkpatch.pl ?

ERROR: open brace '{' following function declarations go on the next line
#78: FILE: net/ipv4/ipvs/ip_vs_ctl.c:100:
+static int __ip_vs_addr_is_local_v6(const struct in6_addr *addr) {

ERROR: do not use assignment in if condition
#87: FILE: net/ipv4/ipvs/ip_vs_ctl.c:109:
+	if ((rt = (struct rt6_info *)ip6_route_output(&init_net, NULL, &fl)))

> Signed-off-by: Vince Busam <vbusam@google.com>
> 
>  1 files changed, 46 insertions(+), 7 deletions(-)
> 
> diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
> index fe17504..3ce2873 100644
> --- a/net/ipv4/ipvs/ip_vs_ctl.c
> +++ b/net/ipv4/ipvs/ip_vs_ctl.c
> @@ -35,6 +35,10 @@
>  
>  #include <net/net_namespace.h>
>  #include <net/ip.h>
> +#ifdef CONFIG_IP_VS_IPV6
> +#include <net/ipv6.h>
> +#include <net/ip6_route.h>
> +#endif
>  #include <net/route.h>
>  #include <net/sock.h>
>  #include <net/genetlink.h>
> @@ -91,6 +95,23 @@ int ip_vs_get_debug_level(void)
>  }
>  #endif
>  
> +#ifdef CONFIG_IP_VS_IPV6
> +/* Taken from rt6_fill_node() in net/ipv6/route.c, is there a better way? */
> +static int __ip_vs_addr_is_local_v6(const struct in6_addr *addr) {
> +	struct rt6_info *rt;
> +	struct flowi fl = {
> +		.oif = 0,
> +		.nl_u = {
> +			.ip6_u = {
> +				.daddr = *addr,
> +				.saddr = { .s6_addr32 = {0, 0, 0, 0} }, } },
> +	};
> +	if ((rt = (struct rt6_info *)ip6_route_output(&init_net, NULL, &fl)))
> +		if (rt->rt6i_dev && (rt->rt6i_dev->flags & IFF_LOOPBACK))
> +			return 1;
> +	return 0;
> +}
> +#endif
>  /*
>   *	update_defense_level is called from keventd and from sysctl,
>   *	so it needs to protect itself from softirqs
> @@ -750,10 +771,18 @@ __ip_vs_update_dest(struct ip_vs_service *svc,
>  	conn_flags = udest->conn_flags | IP_VS_CONN_F_INACTIVE;
>  
>  	/* check if local node and update the flags */
> -	if (inet_addr_type(&init_net, udest->addr.ip) == RTN_LOCAL) {
> -		conn_flags = (conn_flags & ~IP_VS_CONN_F_FWD_MASK)
> -			| IP_VS_CONN_F_LOCALNODE;
> -	}
> +#ifdef CONFIG_IP_VS_IPV6
> +	if (svc->af == AF_INET6) {
> +		if (__ip_vs_addr_is_local_v6(&udest->addr.in6)) {
> +			conn_flags = (conn_flags & ~IP_VS_CONN_F_FWD_MASK)
> +				| IP_VS_CONN_F_LOCALNODE;
> +		}
> +	} else
> +#endif
> +		if (inet_addr_type(&init_net, udest->addr.ip) == RTN_LOCAL) {
> +			conn_flags = (conn_flags & ~IP_VS_CONN_F_FWD_MASK)
> +				| IP_VS_CONN_F_LOCALNODE;
> +		}
>  
>  	/* set the IP_VS_CONN_F_NOOUTPUT flag if not masquerading/NAT */
>  	if ((conn_flags & IP_VS_CONN_F_FWD_MASK) != 0) {
> @@ -802,9 +831,19 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
>  
>  	EnterFunction(2);
>  
> -	atype = inet_addr_type(&init_net, udest->addr.ip);
> -	if (atype != RTN_LOCAL && atype != RTN_UNICAST)
> -		return -EINVAL;
> +#ifdef CONFIG_IP_VS_IPV6
> +	if (svc->af == AF_INET6) {
> +		atype = ipv6_addr_type(&udest->addr.in6);
> +		if (!(atype & IPV6_ADDR_UNICAST) &&
> +			!__ip_vs_addr_is_local_v6(&udest->addr.in6))
> +			return -EINVAL;
> +	} else
> +#endif
> +	{
> +		atype = inet_addr_type(&init_net, udest->addr.ip);
> +		if (atype != RTN_LOCAL && atype != RTN_UNICAST)
> +			return -EINVAL;
> +	}
>  
>  	dest = kzalloc(sizeof(struct ip_vs_dest), GFP_ATOMIC);
>  	if (dest == NULL) {
> -- 
> 1.5.4.5
