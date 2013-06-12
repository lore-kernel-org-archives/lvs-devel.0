From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Wed, 12 Jun 2013 23:47:57 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1306122244020.1773@ja.ssi.bg>
References: <20130524120935.GL264@eldamar.org.uk> <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg> <20130524151408.GM264@eldamar.org.uk> <alpine.LFD.2.00.1305272251170.1728@ja.ssi.bg> <20130607081252.GC11902@eldamar.org.uk> <alpine.LFD.2.00.1306102222380.1773@ja.ssi.bg>
 <20130611083806.GA25531@eldamar.org.uk> <alpine.LFD.2.00.1306112240280.1709@ja.ssi.bg> <20130612141018.GC29327@eldamar.org.uk>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130612141018.GC29327@eldamar.org.uk>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Frolkin <avf@eldamar.org.uk>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Wed, 12 Jun 2013, Alexander Frolkin wrote:

> Hi,
> 
> > > I just don't understand why rejecting a client connection when there are
> > > servers available is desirable behaviour.
> > 	The problem is that every move leads to problems:
> > - add/remove destination => mapping is changed for all dests
> > - set weight to 0 and allow fallback => mapping is changed for
> > 	two connections from same IP
> 
> Fair enough, although I would guess two connections from the same IP
> going to different servers wouldn't be an issue in many cases.
> 
> > - persistence implemented with SH => fallback is risky. Usually,
> > we use expire_quiescent_template for such cases when persistence
> > is used.
> 
> Can you elaborate on what you mean by "risky" here?

	Risky means: we break the rules of persistence,
one established connection can continue to work during
weight=0 and we create new connection to another real
server. Users can set weight=0 for seconds, clients
can retry on connection reject and when real server
is back we can continue in the same session.
Of course, all depends on applications. Some applications
are not tolerant to connection rejects.

	Persistence is explained here:

http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.persistent_connection.html

	SH is a poor choice for persistence, there is no
persistence timeout, no client netmask, no control with
expire_quiescent_template. That is why I'm not sure
who and how uses SH.

> > - same mapping for many directors => fallback is desired when
> > config is same on all directors and persistence behaviour is
> > not desired.
> 
> Indeed.
> 
> > Not sure if we can apply the expire_quiescent_template flag to
> > the SH scheduler to control fallback.
> 
> But then it's controlled by a sysctl, not per virtual server, which is
> something we didn't want, I believe.

	Yes

> Are you happy for me to go ahead and add the per-service scheduler
> flags (IP_VS_SVC_F_SCHED1, etc.), like you suggested previously?

	Yes, not sure what others think, may be changes for
ipvsadm will be needed:

git://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git

	And then we can start a wider discussion:

lvs-users@linuxvirtualserver.org
lvs-devel@vger.kernel.org

> At the moment, the patch looks like this (pending a decision on how to
> enable the features):
> 
> diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
> index 0df269d..abd8ed6 100644
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
> @@ -74,7 +78,9 @@ struct ip_vs_sh_state {
>  /*
>   *	Returns hash value for IPVS SH entry
>   */
> -static inline unsigned int ip_vs_sh_hashkey(int af, const union nf_inet_addr *addr)
> +static inline unsigned int ip_vs_sh_hashkey(int af,
> +	const union nf_inet_addr *addr, __be16 port,
> +	unsigned int offset)
>  {
>  	__be32 addr_fold = addr->ip;
>  
> @@ -83,7 +89,8 @@ static inline unsigned int ip_vs_sh_hashkey(int af, const union nf_inet_addr *ad
>  		addr_fold = addr->ip6[0]^addr->ip6[1]^
>  			    addr->ip6[2]^addr->ip6[3];
>  #endif
> -	return (ntohl(addr_fold)*2654435761UL) & IP_VS_SH_TAB_MASK;
> +	return (offset + (ntohs(port) + ntohl(addr_fold))*2654435761UL) &
> +		IP_VS_SH_TAB_MASK;
>  }
>  
>  
> @@ -91,9 +98,11 @@ static inline unsigned int ip_vs_sh_hashkey(int af, const union nf_inet_addr *ad
>   *      Get ip_vs_dest associated with supplied parameters.
>   */
>  static inline struct ip_vs_dest *
> -ip_vs_sh_get(int af, struct ip_vs_sh_state *s, const union nf_inet_addr *addr)
> +ip_vs_sh_get(int af, struct ip_vs_sh_state *s, const union nf_inet_addr *addr,
> +	__be16 port, unsigned int offset)
>  {
> -	return rcu_dereference(s->buckets[ip_vs_sh_hashkey(af, addr)].dest);
> +	return rcu_dereference(
> +		s->buckets[ip_vs_sh_hashkey(af, addr, port, offset)].dest);
>  }
>  
>  
> @@ -232,17 +241,43 @@ ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
>  	struct ip_vs_dest *dest;
>  	struct ip_vs_sh_state *s;
>  	struct ip_vs_iphdr iph;
> +	unsigned int offset;
> +	unsigned int found;

	bool found;

	later use false/true.

>  
>  	ip_vs_fill_iph_addr_only(svc->af, skb, &iph);
>  
>  	IP_VS_DBG(6, "ip_vs_sh_schedule(): Scheduling...\n");
>  
> +	/* XXX if L4 hash */
> +	if (0)
> +		port = ip_vs_sh_get_port(svc, skb, iph);
> +	else
> +		port = 0;
> +
>  	s = (struct ip_vs_sh_state *) svc->sched_data;
> -	dest = ip_vs_sh_get(svc->af, s, &iph.saddr);
> -	if (!dest
> -	    || !(dest->flags & IP_VS_DEST_F_AVAILABLE)

	We should remove all IP_VS_DEST_F_AVAILABLE checks
from the SH and DH schedulers, such checks are needed only
for LBLC and LBLCR because only they can hold removed
dests in the scheduler context.

> -	    || atomic_read(&dest->weight) <= 0
> -	    || is_overloaded(dest)) {
> +	/* XXX if fallback */
> +	if (0) {
> +		found = 0;
> +		for (offset = 0; offset < IP_VS_SH_TAB_SIZE; offset++) {
> +			dest = ip_vs_sh_get(svc->af, s, &iph.saddr,
> +				port, offset);
> +			if (!is_available(dest)) {
> +				IP_VS_DBG_BUF(6, "SH: selected unavailable"
> +					"server %s:%d, retrying with offset"
> +					"%d\n",
> +					IP_VS_DBG_ADDR(svc->af, &dest->addr),
> +					ntohs(dest->port),
> +					offset);
> +			} else {
> +				found = 1;

	May be goto is more appropriate here to avoid second
is_available(dest) call.

> +				break;
> +			}
> +		}
> +	} else {
> +		dest = ip_vs_sh_get(svc->af, s, &iph.saddr, port, 0);
> +		found = 1;
> +	}
> +	if (!found || !is_available(dest)) {
>  		ip_vs_scheduler_err(svc, "no destination available");
>  		return NULL;
>  	}
> @@ -255,6 +290,50 @@ ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
>  	return dest;
>  }
>  
> +/*
> + *	Helper function to determine if server is available
> + */
> +static inline int
> +is_available(struct ip_vs_dest *dest)
> +{
> +	return (!dest ||
> +		!(dest->flags & IP_VS_DEST_F_AVAILABLE) ||
> +		atomic_read(&dest->weight) <= 0 ||
> +		is_overloaded(dest))
> +}
> +
> +/*
> + *	Helper function to get port number
> + */
> +static inline __be16
> +ip_vs_sh_get_port(struct ip_vs_service *svc, const struct sk_buff *skb,
> +	struct ip_vs_iphdr iph)

	Please use *iph here, passing large structure by
value is a bad idea.

> +{
> +	__be16 port;
> +	struct tcphdr _tcph, *th;
> +	struct udphdr _udph, *uh;
> +	sctp_sctphdr_t _sctph, *sh;
> +
> +	switch (svc->protocol) {

	Use iph->protocol instead of svc->protocol because not
all services have correct protocol.

> +	case IPPROTO_TCP:
> +		th = skb_header_pointer(skb, iph.len, sizeof(_tcph), &_tcph);
> +		port = th->source;
> +		break;
> +	case IPPROTO_UDP:
> +		uh = skb_header_pointer(skb, iph.len, sizeof(_udph), &_udph);
> +		port = uh->source;
> +		break;
> +	case IPPROTO_SCTP:
> +		sh = skb_header_pointer(skb, iph.len, sizeof(_sctph), &_sctph);
> +		port = sh->source;
> +		break;
> +	default:
> +		port = 0;
> +	}
> +
> +	return port;
> +}
> +
>  
>  /*
>   *      IPVS SH Scheduler structure
> 
> 
> Alex

Regards

--
Julian Anastasov <ja@ssi.bg>
