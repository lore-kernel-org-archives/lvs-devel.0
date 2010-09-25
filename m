From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [rfc] IPVS: Masq local real-servers
Date: Sat, 25 Sep 2010 16:54:51 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1009251556410.6881@u.domain.uli>
References: <20100920090911.GA4646@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20100920090911.GA4646@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>, Wensong Zhang <wensong@linux-vs.org>


 	Hello,

On Mon, 20 Sep 2010, Simon Horman wrote:

> IPVS has a special Local forwarding mechanism that is used if the
> real-server is a local IP address. Like the Route and Tunnel forwarding
> mechanism Local does not allow port mapping, and thus the port of the
> real-server is always set to be the same as the virtual service.
>
> The Masq forwarding mechanism does allow port mapping, and this causes some
> confusion when the real-server happens to be local.
>
> This patch addresses this confusion by not using the Local forwarding
> mechanism if the masq forwarding mechanism is requested. That is, the masq
> forwarding mechanism will be used, and the real-servers may have a
> different port to the virtual service.

 	Idea is good but there are some things to consider:

- ip_vs_nat_xmit should check the route to real server IP
but must return NF_ACCEPT instead of creating loops by
sending the packets with IP_VS_XMIT. Checks for MTU,
hard_header_len and replacing of skb_dst should be avoided
for the 'rt->rt_flags & RTCF_LOCAL' case. As result,
the packet will be DNAT-ed by IPVS and the conntrack
will be altered to expect reply from the correct local port
and then just like ip_vs_null_xmit the traffic will
reach local stack. 127.0.0.1/8 should be rejected
for the MASQ method because the output routing called
by local stack will not want to send such saddr in replies.

- We have to check if ip_vs_out is prepared to work in
LOCAL_OUT: I hope icmp_send works from this hook.

> Signed-off-by: Simon Horman <horms@verge.net.au>
>
> ---
>
> I considered using Local for the case where the real-server and virtual
> service ports are the same. However, this would require updating the
> real-servers if the port of the virtual-service was changed, however
> editing the forwarding mechanism of a real-server currently isn't
> supported and the extra complexity for an unmeasured performance gain seems
> to be at best left for another patch.
>
> Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_core.c
> ===================================================================
> --- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_core.c	2010-09-19 20:51:30.000000000 +0900
> +++ nf-next-2.6/net/netfilter/ipvs/ip_vs_core.c	2010-09-20 16:30:59.000000000 +0900
> @@ -1496,6 +1496,22 @@ static struct nf_hook_ops ip_vs_ops[] __
> 		.hooknum        = NF_INET_FORWARD,
> 		.priority       = 100,
> 	},

 	Double block?:

> +	/* change source only for local VS/NAT */
> +	{
> +	       .hook           = ip_vs_out,
> +	       .owner          = THIS_MODULE,
> +	       .pf             = PF_INET,
> +	       .hooknum        = NF_INET_LOCAL_OUT,
> +	       .priority       = 100,
> +	},
> +	/* change source only for local VS/NAT */
> +	{
> +	       .hook           = ip_vs_out,
> +	       .owner          = THIS_MODULE,
> +	       .pf             = PF_INET,
> +	       .hooknum        = NF_INET_LOCAL_OUT,
> +	       .priority       = 100,
> +	},
> 	/* After packet filtering (but before ip_vs_out_icmp), catch icmp
> 	 * destined for 0.0.0.0/0, which is for incoming IPVS connections */
> 	{
> Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_ctl.c
> ===================================================================
> --- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_ctl.c	2010-09-20 15:07:27.000000000 +0900
> +++ nf-next-2.6/net/netfilter/ipvs/ip_vs_ctl.c	2010-09-20 17:45:46.000000000 +0900
> @@ -766,7 +766,7 @@ ip_vs_zero_stats(struct ip_vs_stats *sta
>  *	Update a destination in the given service
>  */
> static void

 	'_' in __ip_vs_update_dest was lost?:

> -__ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
> +_ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
> 		    struct ip_vs_dest_user_kern *udest, int add)
> {
> 	int conn_flags;
> @@ -777,18 +777,22 @@ __ip_vs_update_dest(struct ip_vs_service
> 	conn_flags |= IP_VS_CONN_F_INACTIVE;
>
> 	/* check if local node and update the flags */

 	I think, it should work for svc->fwmark too, eg.
consolidating traffic for many virtual IPs to single
listening socket.

> +	if ((conn_flags & IP_VS_CONN_F_FWD_MASK) != IP_VS_CONN_F_MASQ ||
> +	    svc->fwmark) {
> #ifdef CONFIG_IP_VS_IPV6
> -	if (svc->af == AF_INET6) {
> -		if (__ip_vs_addr_is_local_v6(&udest->addr.in6)) {
> -			conn_flags = (conn_flags & ~IP_VS_CONN_F_FWD_MASK)
> -				| IP_VS_CONN_F_LOCALNODE;
> -		}
> -	} else
> +		if (svc->af == AF_INET6) {
> +			if (__ip_vs_addr_is_local_v6(&udest->addr.in6)) {
> +				conn_flags = (conn_flags &
> +					      ~IP_VS_CONN_F_FWD_MASK) |
> +					IP_VS_CONN_F_LOCALNODE;
> +			}
> +		} else
> #endif
> 		if (inet_addr_type(&init_net, udest->addr.ip) == RTN_LOCAL) {
> 			conn_flags = (conn_flags & ~IP_VS_CONN_F_FWD_MASK)
> 				| IP_VS_CONN_F_LOCALNODE;
> 		}
> +	}
>
> 	/* set the IP_VS_CONN_F_NOOUTPUT flag if not masquerading/NAT */
> 	if ((conn_flags & IP_VS_CONN_F_FWD_MASK) != IP_VS_CONN_F_MASQ) {
>

Regards

--
Julian Anastasov <ja@ssi.bg>
