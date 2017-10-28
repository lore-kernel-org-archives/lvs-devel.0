From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH nf-next 1/1] ipvs: Remove useless ipvsh param of
 frag_safe_skb_hp
Date: Sat, 28 Oct 2017 13:39:43 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1710281338250.1835@ja.home.ssi.bg>
References: <1509007951-8243-1-git-send-email-gfree.wind@vip.163.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1509007951-8243-1-git-send-email-gfree.wind@vip.163.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Gao Feng <gfree.wind@vip.163.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org


	Hello,

On Thu, 26 Oct 2017, gfree.wind@vip.163.com wrote:

> From: Gao Feng <gfree.wind@vip.163.com>
> 
> The param of frag_safe_skb_hp, ipvsh, isn't used now. So remove it and
> change the callers' codes.
> 
> Signed-off-by: Gao Feng <gfree.wind@vip.163.com>

	Looks good to me. Simon, please apply to ipvs-next tree.

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  include/net/ip_vs.h             |  3 +--
>  net/netfilter/ipvs/ip_vs_conn.c |  2 +-
>  net/netfilter/ipvs/ip_vs_core.c | 12 ++++++------
>  3 files changed, 8 insertions(+), 9 deletions(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 4f4f786..6fccd24 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -68,8 +68,7 @@ struct ip_vs_iphdr {
>  };
>  
>  static inline void *frag_safe_skb_hp(const struct sk_buff *skb, int offset,
> -				      int len, void *buffer,
> -				      const struct ip_vs_iphdr *ipvsh)
> +				      int len, void *buffer)
>  {
>  	return skb_header_pointer(skb, offset, len, buffer);
>  }
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 3d2ac71a..9ee73cf 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -322,7 +322,7 @@ struct ip_vs_conn *ip_vs_conn_in_get(const struct ip_vs_conn_param *p)
>  {
>  	__be16 _ports[2], *pptr;
>  
> -	pptr = frag_safe_skb_hp(skb, iph->len, sizeof(_ports), _ports, iph);
> +	pptr = frag_safe_skb_hp(skb, iph->len, sizeof(_ports), _ports);
>  	if (pptr == NULL)
>  		return 1;
>  
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index 5cb7cac..5f6f73c 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -433,7 +433,7 @@ struct ip_vs_conn *
>  	/*
>  	 * IPv6 frags, only the first hit here.
>  	 */
> -	pptr = frag_safe_skb_hp(skb, iph->len, sizeof(_ports), _ports, iph);
> +	pptr = frag_safe_skb_hp(skb, iph->len, sizeof(_ports), _ports);
>  	if (pptr == NULL)
>  		return NULL;
>  
> @@ -566,7 +566,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
>  	struct netns_ipvs *ipvs = svc->ipvs;
>  	struct net *net = ipvs->net;
>  
> -	pptr = frag_safe_skb_hp(skb, iph->len, sizeof(_ports), _ports, iph);
> +	pptr = frag_safe_skb_hp(skb, iph->len, sizeof(_ports), _ports);
>  	if (!pptr)
>  		return NF_DROP;
>  	dport = likely(!ip_vs_iph_inverse(iph)) ? pptr[1] : pptr[0];
> @@ -982,7 +982,7 @@ static int ip_vs_out_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
>  	unsigned int offset;
>  
>  	*related = 1;
> -	ic = frag_safe_skb_hp(skb, ipvsh->len, sizeof(_icmph), &_icmph, ipvsh);
> +	ic = frag_safe_skb_hp(skb, ipvsh->len, sizeof(_icmph), &_icmph);
>  	if (ic == NULL)
>  		return NF_DROP;
>  
> @@ -1214,7 +1214,7 @@ static struct ip_vs_conn *__ip_vs_rs_conn_out(unsigned int hooknum,
>  		return NULL;
>  
>  	pptr = frag_safe_skb_hp(skb, iph->len,
> -				sizeof(_ports), _ports, iph);
> +				sizeof(_ports), _ports);
>  	if (!pptr)
>  		return NULL;
>  
> @@ -1407,7 +1407,7 @@ static struct ip_vs_conn *__ip_vs_rs_conn_out(unsigned int hooknum,
>  		__be16 _ports[2], *pptr;
>  
>  		pptr = frag_safe_skb_hp(skb, iph.len,
> -					 sizeof(_ports), _ports, &iph);
> +					 sizeof(_ports), _ports);
>  		if (pptr == NULL)
>  			return NF_ACCEPT;	/* Not for me */
>  		if (ip_vs_has_real_service(ipvs, af, iph.protocol, &iph.saddr,
> @@ -1741,7 +1741,7 @@ static int ip_vs_in_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
>  
>  	*related = 1;
>  
> -	ic = frag_safe_skb_hp(skb, iph->len, sizeof(_icmph), &_icmph, iph);
> +	ic = frag_safe_skb_hp(skb, iph->len, sizeof(_icmph), &_icmph);
>  	if (ic == NULL)
>  		return NF_DROP;
>  
> -- 
> 1.9.1

Regards

--
Julian Anastasov <ja@ssi.bg>
