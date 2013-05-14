From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v3] ipvs: Fix reuse connection if real server is dead
Date: Tue, 14 May 2013 08:35:09 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1305140832320.1620@ja.ssi.bg>
References: <alpine.LFD.2.00.1305111533350.1612@ja.ssi.bg> <1368482184-16985-1-git-send-email-grzegorz.lyczba@gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="280144257-1362470007-1368509711=:1620"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1368482184-16985-1-git-send-email-grzegorz.lyczba@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: =?UTF-8?Q?Grzegorz_=C5=81yczba?= <grzegorz.lyczba@gmail.com>
Cc: lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--280144257-1362470007-1368509711=:1620
Content-Type: TEXT/PLAIN; charset="utf-8"
Content-Transfer-Encoding: 8bit


	Hello,

On Mon, 13 May 2013, Grzegorz Łyczba wrote:

> From: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>
> 
> Expire cached connection for new TCP/SCTP connection if real server is down
> 
> Signed-off-by: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>

	Looks good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_core.c |   36 ++++++++++++++++++++++++++++++++++++
>  1 files changed, 36 insertions(+), 0 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index 47edf5a..2e349ca 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1002,6 +1002,33 @@ static inline int is_tcp_reset(const struct sk_buff *skb, int nh_len)
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
> @@ -1627,6 +1654,15 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
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
> 1.7.5.4

Regards

--
Julian Anastasov <ja@ssi.bg>
--280144257-1362470007-1368509711=:1620--
