From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] netfilter/ipvs: immediately expire UDP connections
 matching unavailable destination if expire_nodest_conn=1
Date: Mon, 18 May 2020 22:10:32 +0300 (EEST)
Message-ID: <alpine.LFD.2.21.2005182027460.4524@ja.home.ssi.bg>
References: <20200515013556.5582-1-kim.andrewsy@gmail.com> <20200517171654.8194-1-kim.andrewsy@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20200517171654.8194-1-kim.andrewsy@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Sy Kim <kim.andrewsy@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Jakub Kicinski <kuba@kernel.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org


	Hello,

On Sun, 17 May 2020, Andrew Sy Kim wrote:

> If expire_nodest_conn=1 and a UDP destination is deleted, IPVS should
> also expire all matching connections immiediately instead of waiting for
> the next matching packet. This is particulary useful when there are a
> lot of packets coming from a few number of clients. Those clients are
> likely to match against existing entries if a source port in the
> connection hash is reused. When the number of entries in the connection
> tracker is large, we can significantly reduce the number of dropped
> packets by expiring all connections upon deletion.
> 
> Signed-off-by: Andrew Sy Kim <kim.andrewsy@gmail.com>
> ---
>  include/net/ip_vs.h             |  7 ++++++
>  net/netfilter/ipvs/ip_vs_conn.c | 38 +++++++++++++++++++++++++++++++++
>  net/netfilter/ipvs/ip_vs_core.c |  5 -----
>  net/netfilter/ipvs/ip_vs_ctl.c  |  9 ++++++++
>  4 files changed, 54 insertions(+), 5 deletions(-)
> 

> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 02f2f636798d..c69dfbbc3416 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -1366,6 +1366,44 @@ static void ip_vs_conn_flush(struct netns_ipvs *ipvs)
>  		goto flush_again;
>  	}
>  }
> +
> +/*	Flush all the connection entries in the ip_vs_conn_tab with a
> + *	matching destination.
> + */
> +void ip_vs_conn_flush_dest(struct netns_ipvs *ipvs, struct ip_vs_dest *dest)
> +{
> +	int idx;
> +	struct ip_vs_conn *cp, *cp_c;
> +
> +	rcu_read_lock();
> +	for (idx = 0; idx < ip_vs_conn_tab_size; idx++) {
> +		hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[idx], c_list) {
> +			if (cp->ipvs != ipvs)
> +				continue;
> +
> +			if (cp->dest != dest)
> +				continue;
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
> +			IP_VS_DBG(4, "del connection\n");
> +			ip_vs_conn_expire_now(cp);
> +		}
> +		cond_resched_rcu();

	Such kind of loop is correct if done in another context:

1. kthread
or
2. delayed work: mod_delayed_work(system_long_wq, ...)

	Otherwise cond_resched_rcu() can schedule() while holding
__ip_vs_mutex. Also, it will add long delay if many dests are
removed.

	If such loop analyzes instead all cp->dest for 
IP_VS_DEST_F_AVAILABLE, it should be done after calling
__ip_vs_conn_get().

>  static int sysctl_snat_reroute(struct netns_ipvs *ipvs) { return 0; }
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 8d14a1acbc37..f87c03622874 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1225,6 +1225,15 @@ ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
>  	 */
>  	__ip_vs_del_dest(svc->ipvs, dest, false);
>  
> +	/*	If expire_nodest_conn is enabled and protocol is UDP,
> +	 *	attempt best effort flush of all connections with this
> +	 *	destination.
> +	 */
> +	if (sysctl_expire_nodest_conn(svc->ipvs) &&
> +	    dest->protocol == IPPROTO_UDP) {
> +		ip_vs_conn_flush_dest(svc->ipvs, dest);

	Above work should be scheduled from __ip_vs_del_dest().
Check for UDP is not needed, sysctl_expire_nodest_conn() is for
all protocols.

	If the flushing is complex to implement, we can still allow
rescheduling for unavailable dests:

- first we should move this block above the ip_vs_try_to_schedule() 
block because:

	1. the scheduling does not return unavailabel dests, even
	for persistence, so no need to check new connections for
	the flag

	2. it will allow to create new connection if dest for
	existing connection is unavailable

	if (cp && cp->dest && !(cp->dest->flags & IP_VS_DEST_F_AVAILABLE)) {
		/* the destination server is not available */

		if (sysctl_expire_nodest_conn(ipvs)) {
			bool uses_ct = ip_vs_conn_uses_conntrack(cp, skb);

			ip_vs_conn_expire_now(cp);
			__ip_vs_conn_put(cp);
			if (uses_ct)
				return NF_DROP;
			cp = NULL;
		} else {
			__ip_vs_conn_put(cp);
			return NF_DROP;
		}
	}

	if (unlikely(!cp)) {
		int v;

		if (!ip_vs_try_to_schedule(ipvs, af, skb, pd, &v, &cp, &iph))
			return v;
	}

	Before now, we always waited one jiffie connection to expire,
now one packet will:

- schedule expiration for existing connection with unavailable dest,
as before

- create new connection to available destination that will be found
first in lists. But it can work only when sysctl var "conntrack" is 0,
we do not want to create two netfilter conntracks to different
real servers.

	Note that we intentionally removed the timer_pending() check
because we can not see existing ONE_PACKET connections in table.

Regards

--
Julian Anastasov <ja@ssi.bg>
