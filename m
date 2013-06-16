From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Sun, 16 Jun 2013 09:52:44 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1306160911001.1579@ja.ssi.bg>
References: <20130524151408.GM264@eldamar.org.uk> <alpine.LFD.2.00.1305272251170.1728@ja.ssi.bg> <20130607081252.GC11902@eldamar.org.uk> <alpine.LFD.2.00.1306102222380.1773@ja.ssi.bg> <20130611083806.GA25531@eldamar.org.uk> <alpine.LFD.2.00.1306112240280.1709@ja.ssi.bg>
 <20130612141018.GC29327@eldamar.org.uk> <alpine.LFD.2.00.1306122244020.1773@ja.ssi.bg> <20130613141804.GB31356@eldamar.org.uk> <alpine.LFD.2.00.1306132250560.1810@ja.ssi.bg> <20130614102210.GA31800@eldamar.org.uk>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130614102210.GA31800@eldamar.org.uk>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Frolkin <avf@eldamar.org.uk>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Fri, 14 Jun 2013, Alexander Frolkin wrote:

> I've done some refactoring to simplify ip_vs_sh_schedule.  Let me know
> what you think.

> diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
> index 0df269d..4bb9636 100644
> --- a/net/netfilter/ipvs/ip_vs_sh.c
> +++ b/net/netfilter/ipvs/ip_vs_sh.c
> @@ -48,6 +48,10 @@
>  
>  #include <net/ip_vs.h>
>  
> +#include <net/tcp.h>
> +#include <linux/udp.h>
> +#include <linux/sctp.h>
> +
>  
>  /*
>   *      IPVS SH bucket
> @@ -71,10 +75,37 @@ struct ip_vs_sh_state {
>  	struct rcu_head			rcu_head;
>  };
>  
> +
> +/*
> + *      If the dest flags is set with IP_VS_DEST_F_OVERLOAD,
> + *      consider that the server is overloaded here.
> + */

	There is already a requirement the multiline
comments in net/ to be in such format:

/* First line
 * ...
 * last line
 */

	Do it for all comments that you add in this patch.

> +static inline int is_overloaded(struct ip_vs_dest *dest)

	'bool' should work even here.

> +{
> +	return dest->flags & IP_VS_DEST_F_OVERLOAD;
> +}
> +

	Only one empty line between functions.

> +
> +/*
> + *	Helper function to determine if server is unavailable
> + */
> +static inline int

	bool

> +is_unavailable(struct ip_vs_dest *dest)

	This is preferred (args on same line):

static inline bool is_unavailable(struct ip_vs_dest *dest)

> +{
> +	return (!dest ||
> +		atomic_read(&dest->weight) <= 0 ||
> +		is_overloaded(dest));

	and without outer ().

> +}
> +
> +
>  /*
>   *	Returns hash value for IPVS SH entry
>   */
> -static inline unsigned int ip_vs_sh_hashkey(int af, const union nf_inet_addr *addr)
> +static inline unsigned int
> +ip_vs_sh_hashkey(int af,
> +		 const union nf_inet_addr *addr,
> +		 __be16 port,
> +		 unsigned int offset)

	May be you can put more args on same line.

>  {
>  	__be32 addr_fold = addr->ip;
>  
> @@ -83,7 +114,8 @@ static inline unsigned int ip_vs_sh_hashkey(int af, const union nf_inet_addr *ad
>  		addr_fold = addr->ip6[0]^addr->ip6[1]^
>  			    addr->ip6[2]^addr->ip6[3];
>  #endif
> -	return (ntohl(addr_fold)*2654435761UL) & IP_VS_SH_TAB_MASK;
> +	return (offset + (ntohs(port) + ntohl(addr_fold))*2654435761UL) &
> +		IP_VS_SH_TAB_MASK;
>  }
>  
>  
> @@ -91,13 +123,55 @@ static inline unsigned int ip_vs_sh_hashkey(int af, const union nf_inet_addr *ad
>   *      Get ip_vs_dest associated with supplied parameters.
>   */
>  static inline struct ip_vs_dest *
> -ip_vs_sh_get(int af, struct ip_vs_sh_state *s, const union nf_inet_addr *addr)
> +ip_vs_sh_get(struct ip_vs_service *svc,
> +	     struct ip_vs_sh_state *s,
> +	     const union nf_inet_addr *addr,

	More args on same line.

> +	     __be16 port)
>  {
> -	return rcu_dereference(s->buckets[ip_vs_sh_hashkey(af, addr)].dest);
> +	struct ip_vs_dest *dest;

	unsigned int hash = ip_vs_sh_hashkey(svc->af, addr, port, 0);
	struct ip_vs_dest *dest = rcu_dereference(s->buckets[hash].dest);

> +
> +	dest = rcu_dereference(
> +		s->buckets[ip_vs_sh_hashkey(svc->af, addr, port, 0)].dest);
> +
> +	return is_unavailable(dest) ? NULL : dest;
>  }
>  
>  
>  /*
> + *	As ip_vs_sh_get, but with fallback if selected server is unavailable
> + */
> +static inline struct ip_vs_dest *
> +ip_vs_sh_get_fallback(struct ip_vs_service *svc,

	More args on same line.

> +		      struct ip_vs_sh_state *s,
> +		      const union nf_inet_addr *addr,
> +		      __be16 port)
> +{
> +	unsigned int offset;
> +	struct ip_vs_dest *dest;
> +
> +	for (offset = 0; offset < IP_VS_SH_TAB_SIZE; offset++) {

		Can we use:

		unsigned int hash = ip_vs_sh_hashkey(svc->af, addr, port,
						     offset);

		dest = rcu_dereference(s->buckets[hash].dest);

> +		dest = rcu_dereference(s->buckets[
> +			ip_vs_sh_hashkey(svc->af, addr, port, offset)].dest);
> +		if (!is_unavailable(dest))
> +			return dest;
> +#ifdef CONFIG_IP_VS_DEBUG

	Remove the CONFIG_IP_VS_DEBUG because we will add 'break'.

> +		else if (dest)
> +			IP_VS_DBG_BUF(6, "SH: selected unavailable server "
> +				"%s:%d (offset %d)",
> +				IP_VS_DBG_ADDR(svc->af, &dest->addr),
> +				ntohs(dest->port),
> +				offset);

	All args to IP_VS_DBG_BUF should be aligned to same column.

> +		else
> +			IP_VS_DBG(6, "SH: selected null server "
> +				"(offset %d)",
> +				offset);

	Here too, also: "(offset %d)", offset);

	Add 'break' for this case when dest is NULL (no
dests). Then we have to add {} for all branches as per
CodingStyle:

	if (!is_unavailable(dest))
		return dest;
	if (dest) {
		IP_VS_DBG_BUF
	} else {
		IP_VS_DBG
		break;
	}

> +#endif
> +	}
> +
> +	return NULL;
> +}
> +
> +/*
>   *      Assign all the hash buckets of the specified table with the service.
>   */
>  static int
> @@ -214,12 +288,34 @@ static int ip_vs_sh_dest_changed(struct ip_vs_service *svc,
>  
>  
>  /*
> - *      If the dest flags is set with IP_VS_DEST_F_OVERLOAD,
> - *      consider that the server is overloaded here.
> + *	Helper function to get port number
>   */
> -static inline int is_overloaded(struct ip_vs_dest *dest)
> +static inline __be16
> +ip_vs_sh_get_port(const struct sk_buff *skb, struct ip_vs_iphdr *iph)
>  {
> -	return dest->flags & IP_VS_DEST_F_OVERLOAD;
> +	__be16 port;
> +	struct tcphdr _tcph, *th;
> +	struct udphdr _udph, *uh;
> +	sctp_sctphdr_t _sctph, *sh;
> +
> +	switch (iph->protocol) {
> +	case IPPROTO_TCP:
> +		th = skb_header_pointer(skb, iph->len, sizeof(_tcph), &_tcph);
> +		port = th->source;
> +		break;
> +	case IPPROTO_UDP:
> +		uh = skb_header_pointer(skb, iph->len, sizeof(_udph), &_udph);
> +		port = uh->source;
> +		break;
> +	case IPPROTO_SCTP:
> +		sh = skb_header_pointer(skb, iph->len, sizeof(_sctph), &_sctph);
> +		port = sh->source;
> +		break;
> +	default:
> +		port = 0;
> +	}
> +
> +	return port;
>  }
>  
>  
> @@ -232,17 +328,23 @@ ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
>  	struct ip_vs_dest *dest;
>  	struct ip_vs_sh_state *s;
>  	struct ip_vs_iphdr iph;

	I just posted the patch that provides iph as argument.

> -
> -	ip_vs_fill_iph_addr_only(svc->af, skb, &iph);
> +	__be16 port = 0;
>  
>  	IP_VS_DBG(6, "ip_vs_sh_schedule(): Scheduling...\n");
>  
> +	ip_vs_fill_iph_skb(svc->af, skb, &iph);
> +
> +	if (svc->flags & IP_VS_SVC_F_SCHED_SH_PORT)
> +		port = ip_vs_sh_get_port(skb, &iph);
> +
>  	s = (struct ip_vs_sh_state *) svc->sched_data;
> -	dest = ip_vs_sh_get(svc->af, s, &iph.saddr);
> -	if (!dest
> -	    || !(dest->flags & IP_VS_DEST_F_AVAILABLE)
> -	    || atomic_read(&dest->weight) <= 0
> -	    || is_overloaded(dest)) {
> +
> +	if (svc->flags & IP_VS_SVC_F_SCHED_SH_FALLBACK)
> +		dest = ip_vs_sh_get_fallback(svc, s, &iph.saddr, port);
> +	else
> +		dest = ip_vs_sh_get(svc, s, &iph.saddr, port);
> +
> +	if (!dest) {
>  		ip_vs_scheduler_err(svc, "no destination available");
>  		return NULL;
>  	}
> 
> 
> Alex

Regards

--
Julian Anastasov <ja@ssi.bg>
