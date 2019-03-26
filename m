From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v6] ipvs: allow tunneling with gue encapsulation
Date: Tue, 26 Mar 2019 09:46:07 +0200 (EET)
Message-ID: <alpine.LFD.2.21.1903260930270.2201@ja.home.ssi.bg>
References: <20190326012831.352-1-hengqing.hu@gmail.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20190326012831.352-1-hengqing.hu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jacky Hu <hengqing.hu@gmail.com>
Cc: jacky.hu@walmart.com, jason.niesz@walmart.com, "David S. Miller" <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org


	Hello,

On Tue, 26 Mar 2019, Jacky Hu wrote:

> ipip packets are blocked in some public cloud environments, this patch
> allows gue encapsulation with the tunneling method, which would make
> tunneling working in those environments.
> 
> Signed-off-by: Jacky Hu <hengqing.hu@gmail.com>
> ---
>  include/net/ip_vs.h             |  5 ++
>  include/uapi/linux/ip_vs.h      | 11 +++++
>  net/netfilter/ipvs/ip_vs_ctl.c  | 35 +++++++++++++-
>  net/netfilter/ipvs/ip_vs_xmit.c | 86 +++++++++++++++++++++++++++++++--
>  4 files changed, 132 insertions(+), 5 deletions(-)
> 

> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index 473cce2a5231..36819c2fabf1 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c

> @@ -1054,11 +1104,21 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
>  	if (IS_ERR(skb))
>  		goto tx_error;
>  
> -	if (iptunnel_handle_offloads(skb, __tun_gso_type_mask(AF_INET, cp->af)))
> +	if (tun_type == IP_VS_CONN_F_TUNNEL_TYPE_GUE)
> +		gso_type = SKB_GSO_UDP_TUNNEL;
> +	else
> +		gso_type = __tun_gso_type_mask(AF_INET, cp->af);

	Looks like we should request the IP segmentation. Looking
at skb_udp_tunnel_segment() we call the proper gso_inner_segment
handler but ipip_gso_segment() still requires its bit in gso_type.
So, in both functions we should do:

	gso_type = __tun_gso_type_mask();
	if (tun_type == IP_VS_CONN_F_TUNNEL_TYPE_GUE)
		gso_type |= SKB_GSO_UDP_TUNNEL;

	Probably, it can be tested with local client sending large
TCP packets...

> @@ -1134,17 +1197,32 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
>  	 */
>  	max_headroom = LL_RESERVED_SPACE(tdev) + sizeof(struct ipv6hdr);
>  
> +	tun_type = cp->dest->tun_type;
> +
> +	if (tun_type == IP_VS_CONN_F_TUNNEL_TYPE_GUE)
> +		max_headroom += sizeof(struct udphdr) + sizeof(struct guehdr);
> +
>  	skb = ip_vs_prepare_tunneled_skb(skb, cp->af, max_headroom,
>  					 &next_protocol, &payload_len,
>  					 &dsfield, &ttl, NULL);
>  	if (IS_ERR(skb))
>  		goto tx_error;
>  
> -	if (iptunnel_handle_offloads(skb, __tun_gso_type_mask(AF_INET6, cp->af)))
> +	if (tun_type == IP_VS_CONN_F_TUNNEL_TYPE_GUE)
> +		gso_type = SKB_GSO_UDP_TUNNEL;
> +	else
> +		gso_type = __tun_gso_type_mask(AF_INET6, cp->af);

	Here too

> +	if (iptunnel_handle_offloads(skb, gso_type))
>  		goto tx_error;

Regards

--
Julian Anastasov <ja@ssi.bg>
