From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] netfilter/ipvs: immediately expire no destination
 connections in kthread if expire_nodest_conn=1
Date: Wed, 27 May 2020 00:24:55 +0300 (EEST)
Message-ID: <alpine.LFD.2.22.394.2005262008500.3853@ja.home.ssi.bg>
References: <alpine.LFD.2.21.2005192139500.3504@ja.home.ssi.bg> <20200524213105.14805-1-kim.andrewsy@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20200524213105.14805-1-kim.andrewsy@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Sy Kim <kim.andrewsy@gmail.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


	Hello,

	Long CC list trimmed...

On Sun, 24 May 2020, Andrew Sy Kim wrote:

> If expire_nodest_conn=1 and a destination is deleted, IPVS should
> also expire all matching connections immiediately instead of waiting for
> the next matching packet. This is particulary useful when there are a
> lot of packets coming from a few number of clients. Those clients are
> likely to match against existing entries if a source port in the
> connection hash is reused. When the number of entries in the connection
> tracker is large, we can significantly reduce the number of dropped
> packets by expiring all connections upon deletion in a kthread.
> 
> Signed-off-by: Andrew Sy Kim <kim.andrewsy@gmail.com>
> ---
>  include/net/ip_vs.h             | 12 +++++++++
>  net/netfilter/ipvs/ip_vs_conn.c | 48 +++++++++++++++++++++++++++++++++
>  net/netfilter/ipvs/ip_vs_core.c | 45 +++++++++++++------------------
>  net/netfilter/ipvs/ip_vs_ctl.c  | 16 +++++++++++
>  4 files changed, 95 insertions(+), 26 deletions(-)
> 

>  /* Get reference to gain full access to conn.
>   * By default, RCU read-side critical sections have access only to
>   * conn fields and its PE data, see ip_vs_conn_rcu_free() for reference.
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 02f2f636798d..111fa0e287a2 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -1366,6 +1366,54 @@ static void ip_vs_conn_flush(struct netns_ipvs *ipvs)
>  		goto flush_again;
>  	}
>  }
> +
> +/*	Thread function to flush all the connection entries in the
> + *	ip_vs_conn_tab with a matching destination.
> + */
> +int ip_vs_conn_flush_dest(void *data)
> +{
> +	struct ip_vs_conn_flush_dest_tinfo *tinfo = data;
> +	struct netns_ipvs *ipvs = tinfo->ipvs;
> +	struct ip_vs_dest *dest = tinfo->dest;

	Starting a kthread just for single dest can cause storms
when many dests are used. IMHO, we should work this way:

- do not use kthreads: they are hard to manage, start only from
process context (we can not retry from timer if creating a kthread
fails for some reason).

- use delayed_work, similar to our defense_work but this time
we should use queue_delayed_work(system_long_wq,...) instead of 
schedule_delayed_work(). Just cancel_delayed_work_sync() is needed
to stop the work. The callback function will not start the
work timer.

- we will use one work for the netns (struct netns_ipvs *ipvs):
__ip_vs_del_dest() will start it for next jiffie (delay=1) to
catch more dests for flusing. As result, the first destination
will start the work timer, other dests will do nothing while timer
is pending. When timer expires, the work is queued to worker,
so next dests will start the timer again, even while the work
is executing the callback function.

> +
> +	int idx;
> +	struct ip_vs_conn *cp, *cp_c;
> +
> +	IP_VS_DBG_BUF(4, "flushing all connections with destination %s:%d",
> +		      IP_VS_DBG_ADDR(dest->af, &dest->addr), ntohs(dest->port));

	We will not provide current dest. Still, above was not
safe because we do not hold reference to dest.

> +
> +	rcu_read_lock();
> +	for (idx = 0; idx < ip_vs_conn_tab_size; idx++) {
> +		hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[idx], c_list) {
> +			if (cp->ipvs != ipvs)
> +				continue;
> +
> +			if (cp->dest != dest)
> +				continue;

			struct ip_vs_dest *dest = cp->dest;

			if (!dest || (dest->flags & IP_VS_DEST_F_AVAILABLE))
				continue;

			We can access dest because under RCU grace period
			we have access to the cp->dest fields. But we 
			should read cp->dest once as done above.

> +
> +			/* As timers are expired in LIFO order, restart
> +			 * the timer of controlling connection first, so
> +			 * that it is expired after us.
> +			 */
> +			cp_c = cp->control;
> +			/* cp->control is valid only with reference to cp */
> +			if (cp_c && __ip_vs_conn_get(cp)) {
> +				IP_VS_DBG(4, "del controlling connection\n");
> +				ip_vs_conn_expire_now(cp_c);
> +				__ip_vs_conn_put(cp);
> +			}
> +
> +			IP_VS_DBG(4, "del connection\n");
> +			ip_vs_conn_expire_now(cp);
> +		}
> +		cond_resched_rcu();

		if (!ipvs->enable)
			break;

		Abort immediately if netns cleanup is started.

> +	}
> +	rcu_read_unlock();
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(ip_vs_conn_flush_dest);
> +
>  /*
>   * per netns init and exit
>   */
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index aa6a603a2425..ff052e57e054 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -24,6 +24,7 @@
>  
>  #include <linux/module.h>
>  #include <linux/kernel.h>
> +#include <linux/kthread.h>
>  #include <linux/ip.h>
>  #include <linux/tcp.h>
>  #include <linux/sctp.h>
> @@ -694,11 +695,6 @@ static int sysctl_nat_icmp_send(struct netns_ipvs *ipvs)
>  	return ipvs->sysctl_nat_icmp_send;
>  }
>  
> -static int sysctl_expire_nodest_conn(struct netns_ipvs *ipvs)
> -{
> -	return ipvs->sysctl_expire_nodest_conn;
> -}
> -
>  #else
>  
>  static int sysctl_snat_reroute(struct netns_ipvs *ipvs) { return 0; }
> @@ -2095,36 +2091,33 @@ ip_vs_in(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int
>  		}
>  	}
>  
> -	if (unlikely(!cp)) {
> -		int v;
> -
> -		if (!ip_vs_try_to_schedule(ipvs, af, skb, pd, &v, &cp, &iph))
> -			return v;
> -	}
> -
> -	IP_VS_DBG_PKT(11, af, pp, skb, iph.off, "Incoming packet");
> -
>  	/* Check the server status */
> -	if (cp->dest && !(cp->dest->flags & IP_VS_DEST_F_AVAILABLE)) {
> +	if (cp && cp->dest && !(cp->dest->flags & IP_VS_DEST_F_AVAILABLE)) {
>  		/* the destination server is not available */
>  
> -		__u32 flags = cp->flags;
> -
> -		/* when timer already started, silently drop the packet.*/
> -		if (timer_pending(&cp->timer))
> -			__ip_vs_conn_put(cp);
> -		else
> -			ip_vs_conn_put(cp);
> +		if (sysctl_expire_nodest_conn(ipvs)) {
> +			bool uses_ct = ip_vs_conn_uses_conntrack(cp, skb);
>  
> -		if (sysctl_expire_nodest_conn(ipvs) &&
> -		    !(flags & IP_VS_CONN_F_ONE_PACKET)) {
> -			/* try to expire the connection immediately */
>  			ip_vs_conn_expire_now(cp);
> +			__ip_vs_conn_put(cp);
> +			if (uses_ct)
> +				return NF_DROP;
> +			cp = NULL;
> +		} else {
> +			__ip_vs_conn_put(cp);
> +			return NF_DROP;
>  		}
> +	}
>  
> -		return NF_DROP;
> +	if (unlikely(!cp)) {
> +		int v;
> +
> +		if (!ip_vs_try_to_schedule(ipvs, af, skb, pd, &v, &cp, &iph))
> +			return v;
>  	}
>  
> +	IP_VS_DBG_PKT(11, af, pp, skb, iph.off, "Incoming packet");
> +

	The above code in ip_vs_in() is correct.

>  	ip_vs_in_stats(cp, skb);
>  	ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd);
>  	if (cp->packet_xmit)
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 8d14a1acbc37..fa48268368fc 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1163,6 +1163,22 @@ static void __ip_vs_del_dest(struct netns_ipvs *ipvs, struct ip_vs_dest *dest,
>  	list_add(&dest->t_list, &ipvs->dest_trash);
>  	dest->idle_start = 0;
>  	spin_unlock_bh(&ipvs->dest_trash_lock);
> +
> +	/*	If expire_nodest_conn is enabled, expire all connections
> +	 *	immediately in a kthread.
> +	 */
> +	if (sysctl_expire_nodest_conn(ipvs)) {

	Looks like we should not start work when 'cleanup' is true, it 
indicates that we are doing final release of all resources.

	if (sysctl_expire_nodest_conn(ipvs) && !cleanup)
		queue_delayed_work(system_long_wq, &ipvs->expire_nodest_work, 1);

> +		struct ip_vs_conn_flush_dest_tinfo *tinfo = NULL;
> +
> +		tinfo = kcalloc(1, sizeof(struct ip_vs_conn_flush_dest_tinfo),
> +				GFP_KERNEL);
> +		tinfo->ipvs = ipvs;
> +		tinfo->dest = dest;
> +
> +		IP_VS_DBG(3, "flushing connections in kthread\n");
> +		kthread_run(ip_vs_conn_flush_dest,
> +			    tinfo, "ipvs-flush-dest-conn");
> +	}
>  }

Regards

--
Julian Anastasov <ja@ssi.bg>
