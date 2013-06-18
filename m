From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Tue, 18 Jun 2013 23:52:00 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1306182342290.1889@ja.ssi.bg>
References: <20130612141018.GC29327@eldamar.org.uk> <alpine.LFD.2.00.1306122244020.1773@ja.ssi.bg> <20130613141804.GB31356@eldamar.org.uk> <alpine.LFD.2.00.1306132250560.1810@ja.ssi.bg> <20130614102210.GA31800@eldamar.org.uk> <alpine.LFD.2.00.1306160911001.1579@ja.ssi.bg>
 <20130617083204.GA13101@eldamar.org.uk> <alpine.LFD.2.00.1306171202330.10428@ja.ssi.bg> <20130617111113.GC13101@eldamar.org.uk> <alpine.LFD.2.00.1306172257060.1564@ja.ssi.bg> <20130618093008.GA17536@eldamar.org.uk>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130618093008.GA17536@eldamar.org.uk>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Frolkin <avf@eldamar.org.uk>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Tue, 18 Jun 2013, Alexander Frolkin wrote:

> Hi,
> 
> Latest version of SH patch:
> 
> diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
> index a245377..2945822 100644
> --- a/include/uapi/linux/ip_vs.h
> +++ b/include/uapi/linux/ip_vs.h
> @@ -20,6 +20,12 @@
>  #define IP_VS_SVC_F_PERSISTENT	0x0001		/* persistent port */
>  #define IP_VS_SVC_F_HASHED	0x0002		/* hashed entry */
>  #define IP_VS_SVC_F_ONEPACKET	0x0004		/* one-packet scheduling */
> +#define IP_VS_SVC_F_SCHED1	0x0008		/* scheduler flag 1 */
> +#define IP_VS_SVC_F_SCHED2	0x0010		/* scheduler flag 2 */
> +#define IP_VS_SVC_F_SCHED3	0x0020		/* scheduler flag 3 */
> +
> +#define IP_VS_SVC_F_SCHED_SH_FALLBACK	IP_VS_SVC_F_SCHED1 /* SH fallback */
> +#define IP_VS_SVC_F_SCHED_SH_PORT	IP_VS_SVC_F_SCHED2 /* SH use port */
>  
>  /*
>   *      Destination Server Flags
> diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
> index e0130f8..caa3eee 100644
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
> @@ -71,10 +75,19 @@ struct ip_vs_sh_state {
>  	struct rcu_head			rcu_head;
>  };
>  
> +/* Helper function to determine if server is unavailable */
> +static inline bool is_unavailable(struct ip_vs_dest *dest)
> +{
> +	return atomic_read(&dest->weight) <= 0 ||
> +	       dest->flags & IP_VS_DEST_F_OVERLOAD;
> +}
> +
>  /*
>   *	Returns hash value for IPVS SH entry
>   */
> -static inline unsigned int ip_vs_sh_hashkey(int af, const union nf_inet_addr *addr)
> +static inline unsigned int
> +ip_vs_sh_hashkey(int af, const union nf_inet_addr *addr,
> +		 __be16 port, unsigned int offset)
>  {
>  	__be32 addr_fold = addr->ip;
>  
> @@ -83,7 +96,8 @@ static inline unsigned int ip_vs_sh_hashkey(int af, const union nf_inet_addr *ad
>  		addr_fold = addr->ip6[0]^addr->ip6[1]^
>  			    addr->ip6[2]^addr->ip6[3];
>  #endif
> -	return (ntohl(addr_fold)*2654435761UL) & IP_VS_SH_TAB_MASK;
> +	return (offset + (ntohs(port) + ntohl(addr_fold))*2654435761UL) &
> +		IP_VS_SH_TAB_MASK;
>  }
>  
>  
> @@ -91,12 +105,43 @@ static inline unsigned int ip_vs_sh_hashkey(int af, const union nf_inet_addr *ad
>   *      Get ip_vs_dest associated with supplied parameters.
>   */
>  static inline struct ip_vs_dest *
> -ip_vs_sh_get(int af, struct ip_vs_sh_state *s, const union nf_inet_addr *addr)
> +ip_vs_sh_get(struct ip_vs_service *svc, struct ip_vs_sh_state *s,
> +	     const union nf_inet_addr *addr, __be16 port)
>  {
> -	return rcu_dereference(s->buckets[ip_vs_sh_hashkey(af, addr)].dest);
> +	unsigned int hash = ip_vs_sh_hashkey(svc->af, addr, port, 0);
> +	struct ip_vs_dest *dest = rcu_dereference(s->buckets[hash].dest);
> +
> +	return (!dest || is_unavailable(dest)) ? NULL : dest;
>  }
>  
>  
> +/* As ip_vs_sh_get, but with fallback if selected server is unavailable

	You can also fix this comment.

> + */
> +static inline struct ip_vs_dest *
> +ip_vs_sh_get_fallback(struct ip_vs_service *svc, struct ip_vs_sh_state *s,
> +		      const union nf_inet_addr *addr, __be16 port)
> +{
> +	unsigned int offset;
> +	unsigned int hash;
> +	struct ip_vs_dest *dest;
> +
> +	for (offset = 0; offset < IP_VS_SH_TAB_SIZE; offset++) {
> +		hash = ip_vs_sh_hashkey(svc->af, addr, port, offset);
> +		dest = rcu_dereference(s->buckets[hash].dest);
> +		if (!dest)
> +			break;
> +		if (is_unavailable(dest))
> +			IP_VS_DBG_BUF(6, "SH: selected unavailable server "
> +				      "%s:%d (offset %d)",
> +				      IP_VS_DBG_ADDR(svc->af, &dest->addr),
> +				      ntohs(dest->port), offset);
> +		else
> +			return dest;
> +	}
> +
> +	return NULL;
> +}
> +
>  /*
>   *      Assign all the hash buckets of the specified table with the service.
>   */
> @@ -213,13 +258,33 @@ static int ip_vs_sh_dest_changed(struct ip_vs_service *svc,
>  }
>  
>  
> -/*
> - *      If the dest flags is set with IP_VS_DEST_F_OVERLOAD,
> - *      consider that the server is overloaded here.
> - */
> -static inline int is_overloaded(struct ip_vs_dest *dest)
> +/* Helper function to get port number */
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
> @@ -232,15 +297,21 @@ ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
>  {
>  	struct ip_vs_dest *dest;
>  	struct ip_vs_sh_state *s;
> +	__be16 port = 0;
>  
>  	IP_VS_DBG(6, "ip_vs_sh_schedule(): Scheduling...\n");
>  
> +	if (svc->flags & IP_VS_SVC_F_SCHED_SH_PORT)
> +		port = ip_vs_sh_get_port(skb, iph);
> +
>  	s = (struct ip_vs_sh_state *) svc->sched_data;
> -	dest = ip_vs_sh_get(svc->af, s, &iph->saddr);
> -	if (!dest
> -	    || !(dest->flags & IP_VS_DEST_F_AVAILABLE)
> -	    || atomic_read(&dest->weight) <= 0
> -	    || is_overloaded(dest)) {
> +
> +	if (svc->flags & IP_VS_SVC_F_SCHED_SH_FALLBACK)
> +		dest = ip_vs_sh_get_fallback(svc, s, &iph->saddr, port);
> +	else
> +		dest = ip_vs_sh_get(svc, s, &iph->saddr, port);
> +
> +	if (!dest) {
>  		ip_vs_scheduler_err(svc, "no destination available");
>  		return NULL;
>  	}
> 
> 
> Alex

	After fixing above comment and if tests looks ok
you can post an official patch.

Regards

--
Julian Anastasov <ja@ssi.bg>
