From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: optimize release of connections in OPS mode
Date: Sat, 9 Apr 2016 13:16:15 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1604091313310.2087@ja.home.ssi.bg>
References: <5703e74c.U5rZ4wS4UQ/GgXJn%marcoangaroni@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <5703e74c.U5rZ4wS4UQ/GgXJn%marcoangaroni@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marco Angaroni <marcoangaroni@gmail.com>
Cc: lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>


	Hello,

On Tue, 5 Apr 2016, Marco Angaroni wrote:

> One-packet-scheduling is the most expensive mode in IPVS from
> performance point of view: for each packet to be processed a new
> connection data structure is created and, after packet is sent,
> deleted by starting a new timer set to expire immediately.
> 
> SIP persistent-engine needs OPS mode to have Call-ID based load
> balancing, so OPS mode performance has negative impact in SIP
> protocol load balancing.
> 
> This patch aims to improve performance of OPS mode by means of the
> following changes in the release mechanism of OPS connections:
> a) call expire callback ip_vs_conn_expire() directly instead of
>    starting a timer programmed to fire immediately.
> b) avoid call_rcu() overhead inside expire callback, since OPS
>    connection are not inserted in the hash-table and last just the
>    time to process the packet, hence there is no concurrent access
>    to such data structures.
> 
> Signed-off-by: Marco Angaroni <marcoangaroni@gmail.com>

	Looks good to me. Simon, please apply.

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_conn.c | 26 +++++++++++++++++++++++---
>  1 file changed, 23 insertions(+), 3 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 85ca189..dd75d41 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -104,6 +104,7 @@ static inline void ct_write_unlock_bh(unsigned int key)
>  	spin_unlock_bh(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
>  }
>  
> +static void ip_vs_conn_expire(unsigned long data);
>  
>  /*
>   *	Returns hash value for IPVS connection entry
> @@ -453,10 +454,16 @@ ip_vs_conn_out_get_proto(struct netns_ipvs *ipvs, int af,
>  }
>  EXPORT_SYMBOL_GPL(ip_vs_conn_out_get_proto);
>  
> +static void __ip_vs_conn_put_notimer(struct ip_vs_conn *cp)
> +{
> +	__ip_vs_conn_put(cp);
> +	ip_vs_conn_expire((unsigned long)cp);
> +}
> +
>  /*
>   *      Put back the conn and restart its timer with its timeout
>   */
> -void ip_vs_conn_put(struct ip_vs_conn *cp)
> +static void __ip_vs_conn_put_timer(struct ip_vs_conn *cp)
>  {
>  	unsigned long t = (cp->flags & IP_VS_CONN_F_ONE_PACKET) ?
>  		0 : cp->timeout;
> @@ -465,6 +472,16 @@ void ip_vs_conn_put(struct ip_vs_conn *cp)
>  	__ip_vs_conn_put(cp);
>  }
>  
> +void ip_vs_conn_put(struct ip_vs_conn *cp)
> +{
> +	if ((cp->flags & IP_VS_CONN_F_ONE_PACKET) &&
> +	    (atomic_read(&cp->refcnt) == 1) &&
> +	    !timer_pending(&cp->timer))
> +		/* expire connection immediately */
> +		__ip_vs_conn_put_notimer(cp);
> +	else
> +		__ip_vs_conn_put_timer(cp);
> +}
>  
>  /*
>   *	Fill a no_client_port connection with a client port number
> @@ -834,7 +851,10 @@ static void ip_vs_conn_expire(unsigned long data)
>  		ip_vs_unbind_dest(cp);
>  		if (cp->flags & IP_VS_CONN_F_NO_CPORT)
>  			atomic_dec(&ip_vs_conn_no_cport_cnt);
> -		call_rcu(&cp->rcu_head, ip_vs_conn_rcu_free);
> +		if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
> +			ip_vs_conn_rcu_free(&cp->rcu_head);
> +		else
> +			call_rcu(&cp->rcu_head, ip_vs_conn_rcu_free);
>  		atomic_dec(&ipvs->conn_count);
>  		return;
>  	}
> @@ -850,7 +870,7 @@ static void ip_vs_conn_expire(unsigned long data)
>  	if (ipvs->sync_state & IP_VS_STATE_MASTER)
>  		ip_vs_sync_conn(ipvs, cp, sysctl_sync_threshold(ipvs));
>  
> -	ip_vs_conn_put(cp);
> +	__ip_vs_conn_put_timer(cp);
>  }
>  
>  /* Modify timer, so that it expires as soon as possible.
> -- 
> 1.8.3.1

Regards

--
Julian Anastasov <ja@ssi.bg>
