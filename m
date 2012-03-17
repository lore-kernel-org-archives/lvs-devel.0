From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 0/8] Changes for IPVS sync
Date: Sat, 17 Mar 2012 13:40:22 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1203171336580.1811@ja.ssi.bg>
References: <1330984808-2343-1-git-send-email-ja@ssi.bg> <20120307133336.GE15145@verge.net.au> <alpine.LFD.2.00.1203072320340.1806@ja.ssi.bg> <20120316232423.GA20332@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20120316232423.GA20332@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Aleksey Chudov <aleksey.chudov@gmail.com>


	Hello,

On Sat, 17 Mar 2012, Simon Horman wrote:

> Hi Julian,
> 
> your patches look good to me and I will see about getting them
> included in 3.4.
> 
> I would like to propose one more patch as follows:
> 
> 
> ipvs: Provide a generic ip_vs_bind_xmit()
> 
> This logic is now used twice so it seems worthwhile avoiding
> the albeit minor code duplication.
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>

	Looks ok,

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_conn.c |   26 +++++++++++++-------------
>  1 files changed, 13 insertions(+), 13 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 1eaec99..2fc9e4f 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -481,7 +481,7 @@ void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport)
>   *	Bind a connection entry with the corresponding packet_xmit.
>   *	Called by ip_vs_conn_new.
>   */
> -static inline void ip_vs_bind_xmit(struct ip_vs_conn *cp)
> +static inline void ip_vs_bind_xmit_v4(struct ip_vs_conn *cp)
>  {
>  	switch (IP_VS_FWD_METHOD(cp)) {
>  	case IP_VS_CONN_F_MASQ:
> @@ -533,6 +533,16 @@ static inline void ip_vs_bind_xmit_v6(struct ip_vs_conn *cp)
>  }
>  #endif
>  
> +static inline void ip_vs_bind_xmit(struct ip_vs_conn *cp)
> +{
> +#ifdef CONFIG_IP_VS_IPV6
> +	if (cp->af == AF_INET6)
> +		ip_vs_bind_xmit_v6(cp);
> +	else
> +#endif
> +		ip_vs_bind_xmit_v4(cp);
> +}
> +
>  
>  static inline int ip_vs_dest_totalconns(struct ip_vs_dest *dest)
>  {
> @@ -637,12 +647,7 @@ struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp)
>  
>  		/* Update its packet transmitter */
>  		cp->packet_xmit = NULL;
> -#ifdef CONFIG_IP_VS_IPV6
> -		if (cp->af == AF_INET6)
> -			ip_vs_bind_xmit_v6(cp);
> -		else
> -#endif
> -			ip_vs_bind_xmit(cp);
> +		ip_vs_bind_xmit(cp);
>  
>  		pd = ip_vs_proto_data_get(ip_vs_conn_net(cp), cp->protocol);
>  		if (pd && atomic_read(&pd->appcnt))
> @@ -916,12 +921,7 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
>  	cp->sync_endtime = jiffies & ~3UL;
>  
>  	/* Bind its packet transmitter */
> -#ifdef CONFIG_IP_VS_IPV6
> -	if (p->af == AF_INET6)
> -		ip_vs_bind_xmit_v6(cp);
> -	else
> -#endif
> -		ip_vs_bind_xmit(cp);
> +	ip_vs_bind_xmit(cp);
>  
>  	if (unlikely(pd && atomic_read(&pd->appcnt)))
>  		ip_vs_bind_app(cp, pd->pp);
> -- 
> 1.7.6.3

Regards

--
Julian Anastasov <ja@ssi.bg>
