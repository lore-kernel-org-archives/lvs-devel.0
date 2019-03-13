From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: allow tunneling with gue encapsulation
Date: Wed, 13 Mar 2019 21:19:38 +0200 (EET)
Message-ID: <alpine.LFD.2.21.1903132048350.2385@ja.home.ssi.bg>
References: <20190312071218.21905-1-hengqing.hu@gmail.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20190312071218.21905-1-hengqing.hu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jacky Hu <hengqing.hu@gmail.com>
Cc: jacky.hu@walmart.com, jason.niesz@walmart.com, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org


	Hello,

On Tue, 12 Mar 2019, Jacky Hu wrote:

> ipip packets are blocked in some public cloud environments, this patch
> allows gue encapsulation with the tunneling method, which would make
> tunneling working in those environments.
> 
> Signed-off-by: Jacky Hu <hengqing.hu@gmail.com>
> ---
>  include/uapi/linux/ip_vs.h      | 17 +++++++-
>  net/netfilter/ipvs/ip_vs_ctl.c  |  4 +-
>  net/netfilter/ipvs/ip_vs_xmit.c | 71 ++++++++++++++++++++++++++++++++-
>  3 files changed, 87 insertions(+), 5 deletions(-)
> 
> diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
> index 1c916b2f89dc..6637e45b93f4 100644
> --- a/include/uapi/linux/ip_vs.h
> +++ b/include/uapi/linux/ip_vs.h
> @@ -96,13 +96,25 @@
>  #define IP_VS_CONN_F_TEMPLATE	0x1000		/* template, not connection */
>  #define IP_VS_CONN_F_ONE_PACKET	0x2000		/* forward only one packet */
>  
> +/* tunneling with gue */
> +#define IP_VS_CONN_F_GUE	0x0008
> +
> +/* gue destination port bit 0 */
> +#define IP_VS_CONN_F_GUE_PORT_LSB	0x4000
> +
> +/* gue destination port bit 1-15 */
> +#define IP_VS_CONN_F_GUE_PORT_MSB	0xFFFFE0000
> +
>  /* Initial bits allowed in backup server */
>  #define IP_VS_CONN_F_BACKUP_MASK (IP_VS_CONN_F_FWD_MASK | \
>  				  IP_VS_CONN_F_NOOUTPUT | \
>  				  IP_VS_CONN_F_INACTIVE | \
>  				  IP_VS_CONN_F_SEQ_MASK | \
>  				  IP_VS_CONN_F_NO_CPORT | \
> -				  IP_VS_CONN_F_TEMPLATE \
> +				  IP_VS_CONN_F_TEMPLATE | \
> +				  IP_VS_CONN_F_GUE | \
> +				  IP_VS_CONN_F_GUE_PORT_MSB | \
> +				  IP_VS_CONN_F_GUE_PORT_LSB \
>  				 )
>  
>  /* Bits allowed to update in backup server */
> @@ -116,6 +128,9 @@
>  #define IP_VS_CONN_F_DEST_MASK (IP_VS_CONN_F_FWD_MASK | \
>  				IP_VS_CONN_F_ONE_PACKET | \
>  				IP_VS_CONN_F_NFCT | \
> +				IP_VS_CONN_F_GUE | \
> +				IP_VS_CONN_F_GUE_PORT_MSB | \
> +				IP_VS_CONN_F_GUE_PORT_LSB | \
>  				0)

	It would be better to not touch these flags. The backup
sync server simply ignores the forwarding method by applying the
IP_VS_CONN_F_BACKUP_UPD_MASK mask. The real server is found only
by daddr+dport. It would be enough to provide any new non-default
parameters as optional IPVS_DEST_ATTR_xxx attributes. By this way,
we can later add more tunneling methods.

>  #define IP_VS_SCHEDNAME_MAXLEN	16
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 432141f04af3..cecfb52cdea4 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -3169,7 +3169,7 @@ static int ip_vs_genl_fill_dest(struct sk_buff *skb, struct ip_vs_dest *dest)
>  	    nla_put_be16(skb, IPVS_DEST_ATTR_PORT, dest->port) ||
>  	    nla_put_u32(skb, IPVS_DEST_ATTR_FWD_METHOD,
>  			(atomic_read(&dest->conn_flags) &
> -			 IP_VS_CONN_F_FWD_MASK)) ||
> +			 IP_VS_CONN_F_DEST_MASK)) ||
>  	    nla_put_u32(skb, IPVS_DEST_ATTR_WEIGHT,
>  			atomic_read(&dest->weight)) ||
>  	    nla_put_u32(skb, IPVS_DEST_ATTR_U_THRESH, dest->u_threshold) ||

	We can add the new attributes in this function.

> @@ -3305,7 +3305,7 @@ static int ip_vs_genl_parse_dest(struct ip_vs_dest_user_kern *udest,
>  			return -EINVAL;
>  
>  		udest->conn_flags = nla_get_u32(nla_fwd)
> -				    & IP_VS_CONN_F_FWD_MASK;
> +				    & IP_VS_CONN_F_DEST_MASK;
>  		udest->weight = nla_get_u32(nla_weight);
>  		udest->u_threshold = nla_get_u32(nla_u_thresh);
>  		udest->l_threshold = nla_get_u32(nla_l_thresh);

	Here too.

	Also, note that __ip_vs_update_dest() can update the forwarding
methods, so we should be able to switch them between any method.

> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index 473cce2a5231..2667b587b91d 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -32,6 +32,7 @@
>  #include <linux/slab.h>
>  #include <linux/tcp.h>                  /* for tcphdr */
>  #include <net/ip.h>
> +#include <net/gue.h>
>  #include <net/tcp.h>                    /* for csum_tcpudp_magic */
>  #include <net/udp.h>
>  #include <net/icmp.h>                   /* for icmp_send */
> @@ -989,6 +990,42 @@ static inline int __tun_gso_type_mask(int encaps_af, int orig_af)
>  	}
>  }
>  
> +static int
> +__build_gue_header(struct net *net, struct sk_buff *skb,
> +		   struct ip_vs_conn *cp, __u8 *next_protocol)
> +{
> +	__be16 dport;
> +	__be16 sport;
> +	struct udphdr  *udph;	/* Our new UDP header */
> +	struct guehdr  *gueh;	/* Our new GUE header */
> +
> +	skb_push(skb, sizeof(struct guehdr));
> +
> +	gueh = (struct guehdr *)skb->data;
> +
> +	gueh->control = 0;
> +	gueh->version = 0;
> +	gueh->hlen = 0;
> +	gueh->flags = 0;
> +	gueh->proto_ctype = *next_protocol;
> +
> +	skb_push(skb, sizeof(struct udphdr));
> +	skb_reset_transport_header(skb);
> +
> +	udph = udp_hdr(skb);
> +
> +	dport = htons(((cp->flags >> 16) & 0xFFFE) | ((cp->flags >> 14) & 1));
> +	sport = udp_flow_src_port(net, skb, 0, 0, false);
> +	udph->dest = dport;
> +	udph->source = sport;
> +	udph->len = htons(skb->len);
> +	udph->check = 0;
> +
> +	*next_protocol = IPPROTO_UDP;
> +
> +	return 0;
> +}
> +
>  /*
>   *   IP Tunneling transmitter
>   *
> @@ -1025,6 +1062,8 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
>  	struct iphdr  *iph;			/* Our new IP header */
>  	unsigned int max_headroom;		/* The extra header space needed */
>  	int ret, local;
> +	bool gue = false;
> +	int type;
>  
>  	EnterFunction(10);
>  
> @@ -1041,11 +1080,16 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
>  	rt = skb_rtable(skb);
>  	tdev = rt->dst.dev;
>  

	Then, in this func we should drop traffic when cp->dest is NULL
because we will not know the actual tunneling method. But it can happen
only on misconfigured backup servers, so this is not a big problem.

	Now, the parameters should be available in cp->dest.

> +	gue = (bool)(cp->flags & IP_VS_CONN_F_GUE);
> +
>  	/*
>  	 * Okay, now see if we can stuff it in the buffer as-is.
>  	 */
>  	max_headroom = LL_RESERVED_SPACE(tdev) + sizeof(struct iphdr);
>  
> +	if (gue)
> +		max_headroom += sizeof(struct udphdr) + sizeof(struct guehdr);
> +
>  	/* We only care about the df field if sysctl_pmtu_disc(ipvs) is set */
>  	dfp = sysctl_pmtu_disc(ipvs) ? &df : NULL;
>  	skb = ip_vs_prepare_tunneled_skb(skb, cp->af, max_headroom,
> @@ -1054,11 +1098,19 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
>  	if (IS_ERR(skb))
>  		goto tx_error;
>  
> -	if (iptunnel_handle_offloads(skb, __tun_gso_type_mask(AF_INET, cp->af)))
> +	if (gue)
> +		type = SKB_GSO_UDP_TUNNEL;
> +	else
> +		type = __tun_gso_type_mask(AF_INET, cp->af);
> +
> +	if (iptunnel_handle_offloads(skb, type))
>  		goto tx_error;
>  
>  	skb->transport_header = skb->network_header;
>  
> +	if (gue)
> +		__build_gue_header(dev_net(tdev), skb, cp, &next_protocol);
> +
>  	skb_push(skb, sizeof(struct iphdr));
>  	skb_reset_network_header(skb);
>  	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
> @@ -1112,6 +1164,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
>  	struct ipv6hdr  *iph;		/* Our new IP header */
>  	unsigned int max_headroom;	/* The extra header space needed */
>  	int ret, local;
> +	bool gue = false;
> +	int type;
>  
>  	EnterFunction(10);
>  
> @@ -1129,22 +1183,35 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
>  	rt = (struct rt6_info *) skb_dst(skb);
>  	tdev = rt->dst.dev;
>  
> +	gue = (bool)(cp->flags & IP_VS_CONN_F_GUE);
> +
>  	/*
>  	 * Okay, now see if we can stuff it in the buffer as-is.
>  	 */
>  	max_headroom = LL_RESERVED_SPACE(tdev) + sizeof(struct ipv6hdr);
>  
> +	if (gue)
> +		max_headroom += sizeof(struct udphdr) + sizeof(struct guehdr);
> +
>  	skb = ip_vs_prepare_tunneled_skb(skb, cp->af, max_headroom,
>  					 &next_protocol, &payload_len,
>  					 &dsfield, &ttl, NULL);
>  	if (IS_ERR(skb))
>  		goto tx_error;
>  
> -	if (iptunnel_handle_offloads(skb, __tun_gso_type_mask(AF_INET6, cp->af)))
> +	if (gue)
> +		type = SKB_GSO_UDP_TUNNEL;
> +	else
> +		type = __tun_gso_type_mask(AF_INET6, cp->af);
> +
> +	if (iptunnel_handle_offloads(skb, type))
>  		goto tx_error;
>  
>  	skb->transport_header = skb->network_header;
>  
> +	if (gue)
> +		__build_gue_header(dev_net(tdev), skb, cp, &next_protocol);
> +
>  	skb_push(skb, sizeof(struct ipv6hdr));
>  	skb_reset_network_header(skb);
>  	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
> -- 
> 2.21.0

Regards
