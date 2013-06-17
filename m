From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Mon, 17 Jun 2013 23:05:33 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1306172257060.1564@ja.ssi.bg>
References: <20130611083806.GA25531@eldamar.org.uk> <alpine.LFD.2.00.1306112240280.1709@ja.ssi.bg> <20130612141018.GC29327@eldamar.org.uk> <alpine.LFD.2.00.1306122244020.1773@ja.ssi.bg> <20130613141804.GB31356@eldamar.org.uk> <alpine.LFD.2.00.1306132250560.1810@ja.ssi.bg>
 <20130614102210.GA31800@eldamar.org.uk> <alpine.LFD.2.00.1306160911001.1579@ja.ssi.bg> <20130617083204.GA13101@eldamar.org.uk> <alpine.LFD.2.00.1306171202330.10428@ja.ssi.bg> <20130617111113.GC13101@eldamar.org.uk>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130617111113.GC13101@eldamar.org.uk>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Frolkin <avf@eldamar.org.uk>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Mon, 17 Jun 2013, Alexander Frolkin wrote:

> I've moved things around a bit:

> diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
> index e0130f8..2f52129 100644
> --- a/net/netfilter/ipvs/ip_vs_sh.c
> +++ b/net/netfilter/ipvs/ip_vs_sh.c

> +/* Helper function to determine if server is unavailable
> + */

	If not a multi-line, the comment can be:

/* Helper function to determine if server is unavailable */

	But some function names are too obvious :)

> +static inline bool is_unavailable(struct ip_vs_dest *dest)

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
> +		else if (is_unavailable(dest))

	No need for extra 'else'

> @@ -232,15 +299,21 @@ ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
>  {
>  	struct ip_vs_dest *dest;
>  	struct ip_vs_sh_state *s;
> +	__be16 port = 0;
>  
>  	IP_VS_DBG(6, "ip_vs_sh_schedule(): Scheduling...\n");
>  
> +	if (svc->flags & IP_VS_SVC_F_SCHED_SH_PORT)
> +		port = ip_vs_sh_get_port(skb, &iph);

	May be 'iph', not '&iph' ?

Regards

--
Julian Anastasov <ja@ssi.bg>
