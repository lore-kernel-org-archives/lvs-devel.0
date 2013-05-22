From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/2] ipvs: Fix reuse connection if real server is dead
Date: Wed, 22 May 2013 10:06:17 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1305221003250.2242@ja.ssi.bg>
References: <1369202209-18570-1-git-send-email-horms@verge.net.au> <1369202209-18570-3-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1369202209-18570-3-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Grzegorz Lyczba <grzegorz.lyczba@gmail.com>


	Hello,

On Wed, 22 May 2013, Simon Horman wrote:

> From: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>
> 
> Expire cached connection for new TCP/SCTP connection if real server is down
> 
> Signed-off-by: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>
> Acked-by Hans Schillstrom <hans@schillstrom.com>

	Above line should have a ':' after 'Acked-by'.
You can also add my ack for both patches:

Acked-by: Julian Anastasov <ja@ssi.bg>

> Signed-off-by: Simon Horman <horms@verge.net.au>
> ---
>  net/netfilter/ipvs/ip_vs_core.c | 36 ++++++++++++++++++++++++++++++++++++
>  1 file changed, 36 insertions(+)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index 085b588..7967d12 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1001,6 +1001,33 @@ static inline int is_tcp_reset(const struct sk_buff *skb, int nh_len)
>  	return th->rst;
>  }
>  
> +static inline bool is_new_conn(const struct sk_buff *skb,
> +			       struct ip_vs_iphdr *iph)
> +{
> +	switch (iph->protocol) {
> +	case IPPROTO_TCP: {
> +		struct tcphdr _tcph, *th;
> +
> +		th = skb_header_pointer(skb, iph->len, sizeof(_tcph), &_tcph);
> +		if (th == NULL)
> +			return false;
> +		return th->syn;
> +	}
> +	case IPPROTO_SCTP: {
> +		sctp_chunkhdr_t *sch, schunk;
> +
> +		sch = skb_header_pointer(skb, iph->len + sizeof(sctp_sctphdr_t),
> +				sizeof(schunk), &schunk);
> +		if (sch == NULL)
> +			return false;
> +		return (sch->type == SCTP_CID_INIT);
> +	}
> +	default:
> +		return false;
> +	}
> +}
> +
> +
>  /* Handle response packets: rewrite addresses and send away...
>   */
>  static unsigned int
> @@ -1612,6 +1639,15 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
>  	 * Check if the packet belongs to an existing connection entry
>  	 */
>  	cp = pp->conn_in_get(af, skb, &iph, 0);
> +
> +	if (unlikely(sysctl_expire_nodest_conn(ipvs)) && cp && cp->dest &&
> +	    unlikely(!atomic_read(&cp->dest->weight)) && !iph.fragoffs &&
> +	    is_new_conn(skb, &iph)) {
> +		ip_vs_conn_expire_now(cp);
> +		__ip_vs_conn_put(cp);
> +		cp = NULL;
> +	}
> +
>  	if (unlikely(!cp) && !iph.fragoffs) {
>  		/* No (second) fragments need to enter here, as nf_defrag_ipv6
>  		 * replayed fragment zero will already have created the cp
> -- 
> 1.8.2.1

Regards

--
Julian Anastasov <ja@ssi.bg>
