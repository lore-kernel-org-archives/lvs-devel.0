From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: Fix reuse connection if real server is dead
Date: Wed, 8 May 2013 10:35:11 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1305081012310.1912@ja.ssi.bg>
References: <1367963680-5213-1-git-send-email-grzegorz.lyczba@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1367963680-5213-1-git-send-email-grzegorz.lyczba@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>
Cc: lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>


	Hello,

On Tue, 7 May 2013, Grzegorz Lyczba wrote:

> Expire cached connection for new TCP connection if real server is down
> 
> Signed-off-by: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>
> ---
>  net/netfilter/ipvs/ip_vs_core.c |   20 ++++++++++++++++++++
>  1 files changed, 20 insertions(+), 0 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index 47edf5a..7c5f083 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1002,6 +1002,17 @@ static inline int is_tcp_reset(const struct sk_buff *skb, int nh_len)
>  	return th->rst;
>  }
>  
> +static inline int is_tcp_syn(const struct sk_buff *skb, int nh_len)
> +{
> +    struct tcphdr _tcph, *th;
> +
> +    th = skb_header_pointer(skb, nh_len, sizeof(_tcph), &_tcph);

	As Hans notes, it is a good idea to support SCTP by
using the iph address as second argument. May be the func can
be named is_new_conn:

static inline bool is_new_conn(const struct sk_buff *skb,
			       struct ip_vs_iphdr *iph)
...

> +    if (th == NULL)
> +        return 0;
> +    return th->syn;
> +}
> +
> +
>  /* Handle response packets: rewrite addresses and send away...
>   */
>  static unsigned int
> @@ -1627,6 +1638,15 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
>  	 * Check if the packet belongs to an existing connection entry
>  	 */
>  	cp = pp->conn_in_get(af, skb, &iph, 0);
> +
> +	if (likely(cp) && likely(cp->dest) &&

	I hope it is appropriate to use the expire_nodest_conn flag:

	if (unlikely(sysctl_expire_nodest_conn(ipvs) && cp && cp->dest &&
...

> +	    unlikely(!atomic_read(&cp->dest->weight)) &&

	We should add '!iph.fragoffs &&' here.

> +	    iph.protocol == IPPROTO_TCP && is_tcp_syn(skb, iph.len)) {
> +		ip_vs_conn_expire_now(cp);
> +		__ip_vs_conn_put(cp);
> +		cp = NULL;
> +	}
> +
>  	if (unlikely(!cp) && !iph.fragoffs) {
>  		/* No (second) fragments need to enter here, as nf_defrag_ipv6
>  		 * replayed fragment zero will already have created the cp

Regards

--
Julian Anastasov <ja@ssi.bg>
