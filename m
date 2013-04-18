From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 5/6] ipvs: fix sparse warnings for some
 parameters
Date: Thu, 18 Apr 2013 23:00:55 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1304182250280.1842@ja.ssi.bg>
References: <1366231850-22188-1-git-send-email-ja@ssi.bg> <1366231850-22188-6-git-send-email-ja@ssi.bg> <20130418115356.GE11486@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130418115356.GE11486@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>


	Hello,

On Thu, 18 Apr 2013, Simon Horman wrote:

> On Wed, Apr 17, 2013 at 11:50:49PM +0300, Julian Anastasov wrote:
> > 	Some service fields are in network order:
> > 
> > - netmask: used once in network order and also as prefix len for IPv6
> > - port
> > 
> > 	Other parameters are in host order:
> > 
> > - struct ip_vs_flags: flags and mask moved between user and kernel only
> > - sync state: moved between user and kernel only
> > - syncid: sent over network as single octet
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > ---
> >  include/net/ip_vs.h             |    8 +++---
> >  include/uapi/linux/ip_vs.h      |    4 +-
> >  net/netfilter/ipvs/ip_vs_core.c |    3 +-
> >  net/netfilter/ipvs/ip_vs_ctl.c  |   40 +++++++++++++++++++++++---------------
> >  4 files changed, 32 insertions(+), 23 deletions(-)
> > 
> > diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> > index f9f5b05..4c062cc 100644
> > --- a/include/net/ip_vs.h
> > +++ b/include/net/ip_vs.h
> > @@ -678,7 +678,7 @@ struct ip_vs_service_user_kern {
> >  	u16			af;
> >  	u16			protocol;
> >  	union nf_inet_addr	addr;		/* virtual ip address */
> > -	u16			port;
> > +	__be16			port;
> >  	u32			fwmark;		/* firwall mark of service */
> >  
> >  	/* virtual service options */
> > @@ -686,14 +686,14 @@ struct ip_vs_service_user_kern {
> >  	char			*pe_name;
> >  	unsigned int		flags;		/* virtual service flags */
> >  	unsigned int		timeout;	/* persistent timeout in sec */
> > -	u32			netmask;	/* persistent netmask */
> > +	__be32			netmask;	/* persistent netmask or plen */
> 
> Its not clear to me that netmask should be __be32 given the
> occurrences of (__force __u32)  below.

	These occurances are only in this diff to
access the prefix len, there are other places that use
the big-endian value.

	The problem comes with the IPVS-IPv6 support:
in same attribute we provide once IPv4 netmask in big-endian
order and second time a prefix length in host order.
Even if we add new attribute for prefix length, we
still have to support old binaries.

> >  };
> >  
> >  
> >  struct ip_vs_dest_user_kern {
> >  	/* destination server address */
> >  	union nf_inet_addr	addr;
> > -	u16			port;
> > +	__be16			port;
> >  
> >  	/* real server options */
> >  	unsigned int		conn_flags;	/* connection flags */
> > @@ -721,7 +721,7 @@ struct ip_vs_service {
> >  	__u32                   fwmark;   /* firewall mark of the service */
> >  	unsigned int		flags;	  /* service status flags */
> >  	unsigned int		timeout;  /* persistent timeout in ticks */
> > -	__be32			netmask;  /* grouping granularity */
> > +	__be32			netmask;  /* grouping granularity, mask/plen */
> >  	struct net		*net;
> >  
> >  	struct list_head	destinations;  /* real server d-linked list */
> > diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
> > index 8a2d438..a245377 100644
> > --- a/include/uapi/linux/ip_vs.h
> > +++ b/include/uapi/linux/ip_vs.h
> > @@ -280,8 +280,8 @@ struct ip_vs_daemon_user {
> >  #define IPVS_GENL_VERSION	0x1
> >  
> >  struct ip_vs_flags {
> > -	__be32 flags;
> > -	__be32 mask;
> > +	__u32 flags;
> > +	__u32 mask;
> >  };
> >  
> >  /* Generic Netlink command attributes */
> > diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> > index f26fe33..a0d7bd3 100644
> > --- a/net/netfilter/ipvs/ip_vs_core.c
> > +++ b/net/netfilter/ipvs/ip_vs_core.c
> > @@ -235,7 +235,8 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
> >  	/* Mask saddr with the netmask to adjust template granularity */
> >  #ifdef CONFIG_IP_VS_IPV6
> >  	if (svc->af == AF_INET6)
> > -		ipv6_addr_prefix(&snet.in6, &iph->saddr.in6, svc->netmask);
> > +		ipv6_addr_prefix(&snet.in6, &iph->saddr.in6,
> > +				 (__force __u32) svc->netmask);
> >  	else
> >  #endif
> >  		snet.ip = iph->saddr.ip & svc->netmask;
> > diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> > index 5a65444..68901e4 100644
> > --- a/net/netfilter/ipvs/ip_vs_ctl.c
> > +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> > @@ -1164,9 +1164,13 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
> >  	}
> >  
> >  #ifdef CONFIG_IP_VS_IPV6
> > -	if (u->af == AF_INET6 && (u->netmask < 1 || u->netmask > 128)) {
> > -		ret = -EINVAL;
> > -		goto out_err;
> > +	if (u->af == AF_INET6) {
> > +		__u32 plen = (__force __u32) u->netmask;
> > +
> > +		if (plen < 1 || plen > 128) {
> > +			ret = -EINVAL;
> > +			goto out_err;
> > +		}
> >  	}
> >  #endif
> >  
> > @@ -1277,9 +1281,13 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
> >  	}
> >  
> >  #ifdef CONFIG_IP_VS_IPV6
> > -	if (u->af == AF_INET6 && (u->netmask < 1 || u->netmask > 128)) {
> > -		ret = -EINVAL;
> > -		goto out;
> > +	if (u->af == AF_INET6) {
> > +		__u32 plen = (__force __u32) u->netmask;
> > +
> > +		if (plen < 1 || plen > 128) {
> > +			ret = -EINVAL;
> > +			goto out;
> > +		}
> >  	}
> >  #endif
> >  
> > @@ -2890,7 +2898,7 @@ static int ip_vs_genl_fill_service(struct sk_buff *skb,
> >  	} else {
> >  		if (nla_put_u16(skb, IPVS_SVC_ATTR_PROTOCOL, svc->protocol) ||
> >  		    nla_put(skb, IPVS_SVC_ATTR_ADDR, sizeof(svc->addr), &svc->addr) ||
> > -		    nla_put_u16(skb, IPVS_SVC_ATTR_PORT, svc->port))
> > +		    nla_put_be16(skb, IPVS_SVC_ATTR_PORT, svc->port))
> >  			goto nla_put_failure;
> >  	}
> >  
> > @@ -2900,7 +2908,7 @@ static int ip_vs_genl_fill_service(struct sk_buff *skb,
> >  	     nla_put_string(skb, IPVS_SVC_ATTR_PE_NAME, svc->pe->name)) ||
> >  	    nla_put(skb, IPVS_SVC_ATTR_FLAGS, sizeof(flags), &flags) ||
> >  	    nla_put_u32(skb, IPVS_SVC_ATTR_TIMEOUT, svc->timeout / HZ) ||
> > -	    nla_put_u32(skb, IPVS_SVC_ATTR_NETMASK, svc->netmask))
> > +	    nla_put_be32(skb, IPVS_SVC_ATTR_NETMASK, svc->netmask))
> >  		goto nla_put_failure;
> >  	if (ip_vs_genl_fill_stats(skb, IPVS_SVC_ATTR_STATS, &svc->stats))
> >  		goto nla_put_failure;
> > @@ -3013,7 +3021,7 @@ static int ip_vs_genl_parse_service(struct net *net,
> >  	} else {
> >  		usvc->protocol = nla_get_u16(nla_protocol);
> >  		nla_memcpy(&usvc->addr, nla_addr, sizeof(usvc->addr));
> > -		usvc->port = nla_get_u16(nla_port);
> > +		usvc->port = nla_get_be16(nla_port);
> >  		usvc->fwmark = 0;
> >  	}
> >  
> > @@ -3053,7 +3061,7 @@ static int ip_vs_genl_parse_service(struct net *net,
> >  		usvc->sched_name = nla_data(nla_sched);
> >  		usvc->pe_name = nla_pe ? nla_data(nla_pe) : NULL;
> >  		usvc->timeout = nla_get_u32(nla_timeout);
> > -		usvc->netmask = nla_get_u32(nla_netmask);
> > +		usvc->netmask = nla_get_be32(nla_netmask);
> >  	}
> >  
> >  	return 0;
> > @@ -3079,7 +3087,7 @@ static int ip_vs_genl_fill_dest(struct sk_buff *skb, struct ip_vs_dest *dest)
> >  		return -EMSGSIZE;
> >  
> >  	if (nla_put(skb, IPVS_DEST_ATTR_ADDR, sizeof(dest->addr), &dest->addr) ||
> > -	    nla_put_u16(skb, IPVS_DEST_ATTR_PORT, dest->port) ||
> > +	    nla_put_be16(skb, IPVS_DEST_ATTR_PORT, dest->port) ||
> >  	    nla_put_u32(skb, IPVS_DEST_ATTR_FWD_METHOD,
> >  			(atomic_read(&dest->conn_flags) &
> >  			 IP_VS_CONN_F_FWD_MASK)) ||
> > @@ -3188,7 +3196,7 @@ static int ip_vs_genl_parse_dest(struct ip_vs_dest_user_kern *udest,
> >  	memset(udest, 0, sizeof(*udest));
> >  
> >  	nla_memcpy(&udest->addr, nla_addr, sizeof(udest->addr));
> > -	udest->port = nla_get_u16(nla_port);
> > +	udest->port = nla_get_be16(nla_port);
> >  
> >  	/* If a full entry was requested, check for the additional fields */
> >  	if (full_entry) {
> > @@ -3213,8 +3221,8 @@ static int ip_vs_genl_parse_dest(struct ip_vs_dest_user_kern *udest,
> >  	return 0;
> >  }
> >  
> > -static int ip_vs_genl_fill_daemon(struct sk_buff *skb, __be32 state,
> > -				  const char *mcast_ifn, __be32 syncid)
> > +static int ip_vs_genl_fill_daemon(struct sk_buff *skb, __u32 state,
> > +				  const char *mcast_ifn, __u32 syncid)
> >  {
> >  	struct nlattr *nl_daemon;
> >  
> > @@ -3235,8 +3243,8 @@ nla_put_failure:
> >  	return -EMSGSIZE;
> >  }
> >  
> > -static int ip_vs_genl_dump_daemon(struct sk_buff *skb, __be32 state,
> > -				  const char *mcast_ifn, __be32 syncid,
> > +static int ip_vs_genl_dump_daemon(struct sk_buff *skb, __u32 state,
> > +				  const char *mcast_ifn, __u32 syncid,
> >  				  struct netlink_callback *cb)
> >  {
> >  	void *hdr;
> > -- 
> > 1.7.3.4

Regards

--
Julian Anastasov <ja@ssi.bg>
