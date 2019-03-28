From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v7] ipvs: allow tunneling with gue encapsulation
Date: Thu, 28 Mar 2019 13:39:09 +0100
Message-ID: <20190328123909.5uqvokkcxh2sjvfl@verge.net.au>
References: <20190326103121.31083-1-hengqing.hu@gmail.com>
 <20190328095950.66xhna76xndokdp6@verge.net.au>
 <20190328114708.GA10198@i716>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1553776751; bh=Z9crQ9U1LXicVsQnVnEb3KoFUl3NwGnxEZ8Bf62HpWs=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=kB5S8num9gaL3JnqFqecBu8MeBO1fAhYe6BlcmXjgM83oSsrwRJEc3/ZYZreNYffG
         GBr0iAENUH/knPs9SIP+DcYHLdkrgXjaLTcgAEGmm+NPUfNYb/AC/6tACSRmhT6PW2
         JvNj6LBxl1RNHJnR7jyoHbp2LhJOIv48wuGlkjK4=
Content-Disposition: inline
In-Reply-To: <20190328114708.GA10198@i716>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jacky Hu <hengqing.hu@gmail.com>
Cc: jacky.hu@walmart.com, jason.niesz@walmart.com, "David S. Miller" <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

On Thu, Mar 28, 2019 at 07:47:08PM +0800, Jacky Hu wrote:
> Hi Simon,
> On Thu, Mar 28, 2019 at 10:59:50AM +0100, Simon Horman wrote:
> > Hi Jacky,
> > 
> > On Tue, Mar 26, 2019 at 06:31:21PM +0800, Jacky Hu wrote:
> > > ipip packets are blocked in some public cloud environments, this patch
> > > allows gue encapsulation with the tunneling method, which would make
> > > tunneling working in those environments.
> > > 
> > > Signed-off-by: Jacky Hu <hengqing.hu@gmail.com>
> > 
> > It would help a lot if you provided a short summary
> > of what changed between versions of this patch.
> > 
> 
> Here is the summary:
> 
>     v7->v6:
>       1) pass proper gso type mask to gso_inner_segment for gue tunnel
> 
>     v6->v5:
>       1) simply using an if statement for tun_type discrimination
> 
>     v5->v4:
>       1) use __be16 for tun_port and __u16 for tun_type and avoid any
>          atomic_t usage
>       2) fixed sparse warnings
> 
>     v4->v3:
>       1) removed changes to setsockopt interface
>       2) use correct nla_get/put function for tun_port
>       3) moved cp->dest null check to __ip_vs_get_out_rt() and
>          __ip_vs_get_out_rt_v6()
>       4) account the added header when calculating mtu
>       5) use net instead of dev_net(tdev)
>       6) set udest->tun_type to IP_VS_CONN_F_TUNNEL_TYPE_IPIP in
>          ip_vs_copy_udest_compat()
>       7) renamed __build_gue_header to ipvs_gue_encap
>       8) make ip_vs_add_dest() and ip_vs_edit_dest() return EINVAL when
>          GUE comes with port 0.
>       9) feed AF_INET6 to __tun_gso_type_mask in ip_vs_tunnel_xmit_v6
> 
>     v3->v2:
>       1) added missing break statements to a few switch cases
> 
>     v2->v1:
>       1) pass tun_type and tun_port as new optional parameters
>          instead of a few bits in existing conn_flags parameters
> 
> > > ---
> > >  include/net/ip_vs.h             |  5 ++
> > >  include/uapi/linux/ip_vs.h      | 11 +++++
> > >  net/netfilter/ipvs/ip_vs_ctl.c  | 35 +++++++++++++-
> > >  net/netfilter/ipvs/ip_vs_xmit.c | 84 +++++++++++++++++++++++++++++++--
> > >  4 files changed, 130 insertions(+), 5 deletions(-)
> > > 
> > > diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> > > index 047f9a5ccaad..2ac40135b576 100644
> > > --- a/include/net/ip_vs.h
> > > +++ b/include/net/ip_vs.h
> > > @@ -600,6 +600,9 @@ struct ip_vs_dest_user_kern {
> > >  
> > >  	/* Address family of addr */
> > >  	u16			af;
> > > +
> > > +	u16			tun_type;	/* tunnel type */
> > > +	__be16			tun_port;	/* tunnel port */
> > >  };
> > >  
> > >  
> > > @@ -660,6 +663,8 @@ struct ip_vs_dest {
> > >  	atomic_t		conn_flags;	/* flags to copy to conn */
> > >  	atomic_t		weight;		/* server weight */
> > >  	atomic_t		last_weight;	/* server latest weight */
> > > +	__u16			tun_type;	/* tunnel type */
> > > +	__be16			tun_port;	/* tunnel port */
> > >  
> > >  	refcount_t		refcnt;		/* reference counter */
> > >  	struct ip_vs_stats      stats;          /* statistics */
> > > diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
> > > index 1c916b2f89dc..e34f436fc79d 100644
> > > --- a/include/uapi/linux/ip_vs.h
> > > +++ b/include/uapi/linux/ip_vs.h
> > > @@ -124,6 +124,13 @@
> > >  
> > >  #define IP_VS_PEDATA_MAXLEN     255
> > >  
> > > +/* Tunnel types */
> > > +enum {
> > > +	IP_VS_CONN_F_TUNNEL_TYPE_IPIP = 0,	/* IPIP */
> > > +	IP_VS_CONN_F_TUNNEL_TYPE_GUE,		/* GUE */
> > > +	IP_VS_CONN_F_TUNNEL_TYPE_MAX,
> > > +};
> > > +
> > >  /*
> > >   *	The struct ip_vs_service_user and struct ip_vs_dest_user are
> > >   *	used to set IPVS rules through setsockopt.
> > > @@ -392,6 +399,10 @@ enum {
> > >  
> > >  	IPVS_DEST_ATTR_STATS64,		/* nested attribute for dest stats */
> > >  
> > > +	IPVS_DEST_ATTR_TUN_TYPE,	/* tunnel type */
> > > +
> > > +	IPVS_DEST_ATTR_TUN_PORT,	/* tunnel port */
> > > +
> > >  	__IPVS_DEST_ATTR_MAX,
> > >  };
> > >  
> > > diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> > > index 053cd96b9c76..328683452229 100644
> > > --- a/net/netfilter/ipvs/ip_vs_ctl.c
> > > +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> > > @@ -831,6 +831,10 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
> > >  	conn_flags = udest->conn_flags & IP_VS_CONN_F_DEST_MASK;
> > >  	conn_flags |= IP_VS_CONN_F_INACTIVE;
> > >  
> > > +	/* set the tunnel info */
> > > +	dest->tun_type = udest->tun_type;
> > > +	dest->tun_port = udest->tun_port;
> > > +
> > >  	/* set the IP_VS_CONN_F_NOOUTPUT flag if not masquerading/NAT */
> > >  	if ((conn_flags & IP_VS_CONN_F_FWD_MASK) != IP_VS_CONN_F_MASQ) {
> > >  		conn_flags |= IP_VS_CONN_F_NOOUTPUT;
> > > @@ -987,6 +991,13 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
> > >  		return -ERANGE;
> > >  	}
> > >  
> > > +	if (udest->tun_type == IP_VS_CONN_F_TUNNEL_TYPE_GUE) {
> > > +		if (udest->tun_port == 0) {
> > > +			pr_err("%s(): tunnel port is zero\n", __func__);
> > > +			return -EINVAL;
> > > +		}
> > > +	}
> > > +
> > >  	ip_vs_addr_copy(udest->af, &daddr, &udest->addr);
> > >  
> > >  	/* We use function that requires RCU lock */
> > > @@ -1051,6 +1062,13 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
> > >  		return -ERANGE;
> > >  	}
> > >  
> > > +	if (udest->tun_type == IP_VS_CONN_F_TUNNEL_TYPE_GUE) {
> > > +		if (udest->tun_port == 0) {
> > > +			pr_err("%s(): tunnel port is zero\n", __func__);
> > > +			return -EINVAL;
> > > +		}
> > > +	}
> > > +
> > >  	ip_vs_addr_copy(udest->af, &daddr, &udest->addr);
> > >  
> > >  	/* We use function that requires RCU lock */
> > > @@ -2333,6 +2351,7 @@ static void ip_vs_copy_udest_compat(struct ip_vs_dest_user_kern *udest,
> > >  	udest->u_threshold	= udest_compat->u_threshold;
> > >  	udest->l_threshold	= udest_compat->l_threshold;
> > >  	udest->af		= AF_INET;
> > > +	udest->tun_type		= IP_VS_CONN_F_TUNNEL_TYPE_IPIP;
> > >  }
> > >  
> > >  static int
> > > @@ -2890,6 +2909,8 @@ static const struct nla_policy ip_vs_dest_policy[IPVS_DEST_ATTR_MAX + 1] = {
> > >  	[IPVS_DEST_ATTR_PERSIST_CONNS]	= { .type = NLA_U32 },
> > >  	[IPVS_DEST_ATTR_STATS]		= { .type = NLA_NESTED },
> > >  	[IPVS_DEST_ATTR_ADDR_FAMILY]	= { .type = NLA_U16 },
> > > +	[IPVS_DEST_ATTR_TUN_TYPE]	= { .type = NLA_U8 },
> > > +	[IPVS_DEST_ATTR_TUN_PORT]	= { .type = NLA_U16 },
> > >  };
> > >  
> > >  static int ip_vs_genl_fill_stats(struct sk_buff *skb, int container_type,
> > > @@ -3193,6 +3214,10 @@ static int ip_vs_genl_fill_dest(struct sk_buff *skb, struct ip_vs_dest *dest)
> > >  			 IP_VS_CONN_F_FWD_MASK)) ||
> > >  	    nla_put_u32(skb, IPVS_DEST_ATTR_WEIGHT,
> > >  			atomic_read(&dest->weight)) ||
> > > +	    nla_put_u8(skb, IPVS_DEST_ATTR_TUN_TYPE,
> > > +		       dest->tun_type) ||
> > > +	    nla_put_be16(skb, IPVS_DEST_ATTR_TUN_PORT,
> > > +			 dest->tun_port) ||
> > >  	    nla_put_u32(skb, IPVS_DEST_ATTR_U_THRESH, dest->u_threshold) ||
> > >  	    nla_put_u32(skb, IPVS_DEST_ATTR_L_THRESH, dest->l_threshold) ||
> > >  	    nla_put_u32(skb, IPVS_DEST_ATTR_ACTIVE_CONNS,
> > > @@ -3315,12 +3340,14 @@ static int ip_vs_genl_parse_dest(struct ip_vs_dest_user_kern *udest,
> > >  	/* If a full entry was requested, check for the additional fields */
> > >  	if (full_entry) {
> > >  		struct nlattr *nla_fwd, *nla_weight, *nla_u_thresh,
> > > -			      *nla_l_thresh;
> > > +			      *nla_l_thresh, *nla_tun_type, *nla_tun_port;
> > >  
> > >  		nla_fwd		= attrs[IPVS_DEST_ATTR_FWD_METHOD];
> > >  		nla_weight	= attrs[IPVS_DEST_ATTR_WEIGHT];
> > >  		nla_u_thresh	= attrs[IPVS_DEST_ATTR_U_THRESH];
> > >  		nla_l_thresh	= attrs[IPVS_DEST_ATTR_L_THRESH];
> > > +		nla_tun_type	= attrs[IPVS_DEST_ATTR_TUN_TYPE];
> > > +		nla_tun_port	= attrs[IPVS_DEST_ATTR_TUN_PORT];
> > >  
> > >  		if (!(nla_fwd && nla_weight && nla_u_thresh && nla_l_thresh))
> > >  			return -EINVAL;
> > > @@ -3330,6 +3357,12 @@ static int ip_vs_genl_parse_dest(struct ip_vs_dest_user_kern *udest,
> > >  		udest->weight = nla_get_u32(nla_weight);
> > >  		udest->u_threshold = nla_get_u32(nla_u_thresh);
> > >  		udest->l_threshold = nla_get_u32(nla_l_thresh);
> > > +
> > > +		if (nla_tun_type)
> > > +			udest->tun_type = nla_get_u8(nla_tun_type);
> > > +
> > > +		if (nla_tun_port)
> > > +			udest->tun_port = nla_get_be16(nla_tun_port);
> > >  	}
> > >  
> > >  	return 0;
> > > diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> > > index 175349fcf91f..8d6f94b67772 100644
> > > --- a/net/netfilter/ipvs/ip_vs_xmit.c
> > > +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> > > @@ -32,6 +32,7 @@
> > >  #include <linux/slab.h>
> > >  #include <linux/tcp.h>                  /* for tcphdr */
> > >  #include <net/ip.h>
> > > +#include <net/gue.h>
> > >  #include <net/tcp.h>                    /* for csum_tcpudp_magic */
> > >  #include <net/udp.h>
> > >  #include <net/icmp.h>                   /* for icmp_send */
> > > @@ -382,6 +383,10 @@ __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
> > >  		mtu = dst_mtu(&rt->dst);
> > >  	} else {
> > >  		mtu = dst_mtu(&rt->dst) - sizeof(struct iphdr);
> > > +		if (!dest)
> > > +			goto err_put;
> > > +		if (dest->tun_type == IP_VS_CONN_F_TUNNEL_TYPE_GUE)
> > > +			mtu -= sizeof(struct udphdr) + sizeof(struct guehdr);
> > >  		if (mtu < 68) {
> > >  			IP_VS_DBG_RL("%s(): mtu less than 68\n", __func__);
> > >  			goto err_put;
> > > @@ -533,6 +538,10 @@ __ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
> > >  		mtu = dst_mtu(&rt->dst);
> > >  	else {
> > >  		mtu = dst_mtu(&rt->dst) - sizeof(struct ipv6hdr);
> > > +		if (!dest)
> > > +			goto err_put;
> > > +		if (dest->tun_type == IP_VS_CONN_F_TUNNEL_TYPE_GUE)
> > > +			mtu -= sizeof(struct udphdr) + sizeof(struct guehdr);
> > >  		if (mtu < IPV6_MIN_MTU) {
> > >  			IP_VS_DBG_RL("%s(): mtu less than %d\n", __func__,
> > >  				     IPV6_MIN_MTU);
> > > @@ -989,6 +998,41 @@ static inline int __tun_gso_type_mask(int encaps_af, int orig_af)
> > >  	}
> > >  }
> > >  
> > > +static int
> > > +ipvs_gue_encap(struct net *net, struct sk_buff *skb,
> > > +	       struct ip_vs_conn *cp, __u8 *next_protocol)
> > > +{
> > > +	__be16 dport;
> > > +	__be16 sport = udp_flow_src_port(net, skb, 0, 0, false);
> > > +	struct udphdr  *udph;	/* Our new UDP header */
> > > +	struct guehdr  *gueh;	/* Our new GUE header */
> > > +
> > > +	skb_push(skb, sizeof(struct guehdr));
> > > +
> > > +	gueh = (struct guehdr *)skb->data;
> > > +
> > > +	gueh->control = 0;
> > > +	gueh->version = 0;
> > > +	gueh->hlen = 0;
> > > +	gueh->flags = 0;
> > > +	gueh->proto_ctype = *next_protocol;
> > > +
> > > +	skb_push(skb, sizeof(struct udphdr));
> > > +	skb_reset_transport_header(skb);
> > > +
> > > +	udph = udp_hdr(skb);
> > > +
> > > +	dport = cp->dest->tun_port;
> > > +	udph->dest = dport;
> > > +	udph->source = sport;
> > > +	udph->len = htons(skb->len);
> > > +	udph->check = 0;
> > > +
> > > +	*next_protocol = IPPROTO_UDP;
> > > +
> > > +	return 0;
> > > +}
> > > +
> > >  /*
> > >   *   IP Tunneling transmitter
> > >   *
> > > @@ -1025,6 +1069,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
> > >  	struct iphdr  *iph;			/* Our new IP header */
> > >  	unsigned int max_headroom;		/* The extra header space needed */
> > >  	int ret, local;
> > > +	int tun_type, gso_type;
> > >  
> > >  	EnterFunction(10);
> > >  
> > > @@ -1046,6 +1091,11 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
> > >  	 */
> > >  	max_headroom = LL_RESERVED_SPACE(tdev) + sizeof(struct iphdr);
> > >  
> > > +	tun_type = cp->dest->tun_type;
> > > +
> > > +	if (tun_type == IP_VS_CONN_F_TUNNEL_TYPE_GUE)
> > > +		max_headroom += sizeof(struct udphdr) + sizeof(struct guehdr);
> > > +
> > >  	/* We only care about the df field if sysctl_pmtu_disc(ipvs) is set */
> > >  	dfp = sysctl_pmtu_disc(ipvs) ? &df : NULL;
> > >  	skb = ip_vs_prepare_tunneled_skb(skb, cp->af, max_headroom,
> > > @@ -1054,11 +1104,20 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
> > >  	if (IS_ERR(skb))
> > >  		goto tx_error;
> > >  
> > > -	if (iptunnel_handle_offloads(skb, __tun_gso_type_mask(AF_INET, cp->af)))
> > > +	gso_type = __tun_gso_type_mask(AF_INET, cp->af);
> > > +	if (tun_type == IP_VS_CONN_F_TUNNEL_TYPE_GUE)
> > > +		gso_type |= SKB_GSO_UDP_TUNNEL;
> > 
> > Should the gso_type really be __tun_gso_type_mask() | SKB_GSO_UDP_TUNNEL.
> > It seems tome that SKB_GSO_UDP_TUNNEL would be more appropriate.
> > 
> Do you mean you want me to change the code above to:
> 	gso_type = __tun_gso_type_mask(AF_INET, cp->af);
> 	if (tun_type == IP_VS_CONN_F_TUNNEL_TYPE_GUE)
> 		gso_type = __tun_gso_type_mask(AF_INET, cp->af) | SKB_GSO_UDP_TUNNEL;

I am more thinking of:

	if (tun_type == IP_VS_CONN_F_TUNNEL_TYPE_GUE)
		gso_type = SKB_GSO_UDP_TUNNEL;
	else
		gso_type = __tun_gso_type_mask(AF_INET, cp->af);

I think you intentionally changed this since an earlier version
of this patch but I'm not sure why.

> > Also, should there be a mechanism to enable cums in the outer header,
> > and thus use SKB_GSO_UDP_TUNNEL_CSUM?
> > 
> Yep, that we can definitely do it in a follow up patch later, by adding
> some new parameters for check sum control.

Thanks, I think that would be a good follow-up.

> > > +
> > > +	if (iptunnel_handle_offloads(skb, gso_type))
> > >  		goto tx_error;
> > >  
> > >  	skb->transport_header = skb->network_header;
> > >  
> > > +	skb_set_inner_ipproto(skb, next_protocol);
> > > +
> > > +	if (tun_type == IP_VS_CONN_F_TUNNEL_TYPE_GUE)
> > > +		ipvs_gue_encap(net, skb, cp, &next_protocol);
> > > +
> > >  	skb_push(skb, sizeof(struct iphdr));
> > >  	skb_reset_network_header(skb);
> > >  	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
> > > @@ -1102,6 +1161,8 @@ int
> > >  ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
> > >  		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
> > >  {
> > > +	struct netns_ipvs *ipvs = cp->ipvs;
> > > +	struct net *net = ipvs->net;
> > >  	struct rt6_info *rt;		/* Route to the other host */
> > >  	struct in6_addr saddr;		/* Source for tunnel */
> > >  	struct net_device *tdev;	/* Device to other host */
> > > @@ -1112,10 +1173,11 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
> > >  	struct ipv6hdr  *iph;		/* Our new IP header */
> > >  	unsigned int max_headroom;	/* The extra header space needed */
> > >  	int ret, local;
> > > +	int tun_type, gso_type;
> > >  
> > >  	EnterFunction(10);
> > >  
> > > -	local = __ip_vs_get_out_rt_v6(cp->ipvs, cp->af, skb, cp->dest,
> > > +	local = __ip_vs_get_out_rt_v6(ipvs, cp->af, skb, cp->dest,
> > >  				      &cp->daddr.in6,
> > >  				      &saddr, ipvsh, 1,
> > >  				      IP_VS_RT_MODE_LOCAL |
> > > @@ -1134,17 +1196,31 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
> > >  	 */
> > >  	max_headroom = LL_RESERVED_SPACE(tdev) + sizeof(struct ipv6hdr);
> > >  
> > > +	tun_type = cp->dest->tun_type;
> > > +
> > > +	if (tun_type == IP_VS_CONN_F_TUNNEL_TYPE_GUE)
> > > +		max_headroom += sizeof(struct udphdr) + sizeof(struct guehdr);
> > > +
> > >  	skb = ip_vs_prepare_tunneled_skb(skb, cp->af, max_headroom,
> > >  					 &next_protocol, &payload_len,
> > >  					 &dsfield, &ttl, NULL);
> > >  	if (IS_ERR(skb))
> > >  		goto tx_error;
> > >  
> > > -	if (iptunnel_handle_offloads(skb, __tun_gso_type_mask(AF_INET6, cp->af)))
> > > +	gso_type = __tun_gso_type_mask(AF_INET6, cp->af);
> > > +	if (tun_type == IP_VS_CONN_F_TUNNEL_TYPE_GUE)
> > > +		gso_type |= SKB_GSO_UDP_TUNNEL;
> > > +
> > > +	if (iptunnel_handle_offloads(skb, gso_type))
> > >  		goto tx_error;
> > >  
> > >  	skb->transport_header = skb->network_header;
> > >  
> > > +	skb_set_inner_ipproto(skb, next_protocol);
> > 
> > Is the above needed in the non-GUE case?
> Looking at implementation of ipip6_tunnel_xmit and ipip_tunnel_xmit,
> this seems to be needed also.
> > 
> > > +
> > > +	if (tun_type == IP_VS_CONN_F_TUNNEL_TYPE_GUE)
> > > +		ipvs_gue_encap(net, skb, cp, &next_protocol);
> > > +
> > >  	skb_push(skb, sizeof(struct ipv6hdr));
> > >  	skb_reset_network_header(skb);
> > >  	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
> > > @@ -1167,7 +1243,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
> > >  
> > >  	ret = ip_vs_tunnel_xmit_prepare(skb, cp);
> > >  	if (ret == NF_ACCEPT)
> > > -		ip6_local_out(cp->ipvs->net, skb->sk, skb);
> > > +		ip6_local_out(net, skb->sk, skb);
> > >  	else if (ret == NF_DROP)
> > >  		kfree_skb(skb);
> > >  
> > > -- 
> > > 2.21.0
> > > 
> Thanks and Best Regards,
> Jacky
> 
