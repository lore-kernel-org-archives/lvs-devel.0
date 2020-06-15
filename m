From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] netfilter/ipvs: queue delayed work to expire no destination
 connections if expire_nodest_conn=1
Date: Mon, 15 Jun 2020 22:24:26 +0300 (EEST)
Message-ID: <alpine.LFD.2.22.394.2006152210030.17355@ja.home.ssi.bg>
References: <20200608173413.13870-1-kim.andrewsy@gmail.com> <20200608202024.28369-1-kim.andrewsy@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20200608202024.28369-1-kim.andrewsy@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Sy Kim <kim.andrewsy@gmail.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


	Hello,

On Mon, 8 Jun 2020, Andrew Sy Kim wrote:

> When expire_nodest_conn=1 and a destination is deleted, IPVS does not
> expire the existing connections until the next matching incoming packet.
> If there are many connection entries from a single client to a single
> destination, many packets may get dropped before all the connections are
> expired (more likely with lots of UDP traffic). An optimization can be
> made where upon deletion of a destination, IPVS queues up delayed work
> to immediately expire any connections with a deleted destination. This
> ensures any reused source ports from a client (within the IPVS timeouts)
> are scheduled to new real servers instead of silently dropped.
> 
> Signed-off-by: Andrew Sy Kim <kim.andrewsy@gmail.com>

	Looks good to me. But you have to base it on the
following patch that I'll finally post when the trees are open.
You have to use ip_vs_conn_del() in ip_vs_expire_nodest_conn_flush()
and the logic as in ip_vs_conn_flush().

	Here is what you can test:

==========================================================
ipvs: avoid expiring many connections from timer

Add new functions ip_vs_conn_del() and ip_vs_conn_del_put()
to release many IPVS connections in process context.
They are suitable for connections found in table
when we do not want to overload the timers.

Currently, the change is useful for the dropentry delayed
work but it will be used also in following patch
when flushing connections to failed destinations.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_conn.c | 53 +++++++++++++++++++++++----------
 net/netfilter/ipvs/ip_vs_ctl.c  |  6 ++--
 2 files changed, 42 insertions(+), 17 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 02f2f636798d..b3921ae92740 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -807,6 +807,31 @@ static void ip_vs_conn_rcu_free(struct rcu_head *head)
 	kmem_cache_free(ip_vs_conn_cachep, cp);
 }
 
+/* Try to delete connection while not holding reference */
+static void ip_vs_conn_del(struct ip_vs_conn *cp)
+{
+	if (del_timer(&cp->timer)) {
+		/* Drop cp->control chain too */
+		if (cp->control)
+			cp->timeout = 0;
+		ip_vs_conn_expire(&cp->timer);
+	}
+}
+
+/* Try to delete connection while holding reference */
+static void ip_vs_conn_del_put(struct ip_vs_conn *cp)
+{
+	if (del_timer(&cp->timer)) {
+		/* Drop cp->control chain too */
+		if (cp->control)
+			cp->timeout = 0;
+		__ip_vs_conn_put(cp);
+		ip_vs_conn_expire(&cp->timer);
+	} else {
+		__ip_vs_conn_put(cp);
+	}
+}
+
 static void ip_vs_conn_expire(struct timer_list *t)
 {
 	struct ip_vs_conn *cp = from_timer(cp, t, timer);
@@ -827,14 +852,17 @@ static void ip_vs_conn_expire(struct timer_list *t)
 
 		/* does anybody control me? */
 		if (ct) {
+			bool has_ref = !cp->timeout && __ip_vs_conn_get(ct);
+
 			ip_vs_control_del(cp);
 			/* Drop CTL or non-assured TPL if not used anymore */
-			if (!cp->timeout && !atomic_read(&ct->n_control) &&
+			if (has_ref && !atomic_read(&ct->n_control) &&
 			    (!(ct->flags & IP_VS_CONN_F_TEMPLATE) ||
 			     !(ct->state & IP_VS_CTPL_S_ASSURED))) {
 				IP_VS_DBG(4, "drop controlling connection\n");
-				ct->timeout = 0;
-				ip_vs_conn_expire_now(ct);
+				ip_vs_conn_del_put(ct);
+			} else if (has_ref) {
+				__ip_vs_conn_put(ct);
 			}
 		}
 
@@ -1317,8 +1345,7 @@ void ip_vs_random_dropentry(struct netns_ipvs *ipvs)
 
 drop:
 			IP_VS_DBG(4, "drop connection\n");
-			cp->timeout = 0;
-			ip_vs_conn_expire_now(cp);
+			ip_vs_conn_del(cp);
 		}
 		cond_resched_rcu();
 	}
@@ -1341,19 +1368,15 @@ static void ip_vs_conn_flush(struct netns_ipvs *ipvs)
 		hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[idx], c_list) {
 			if (cp->ipvs != ipvs)
 				continue;
-			/* As timers are expired in LIFO order, restart
-			 * the timer of controlling connection first, so
-			 * that it is expired after us.
-			 */
+			if (atomic_read(&cp->n_control))
+				continue;
 			cp_c = cp->control;
-			/* cp->control is valid only with reference to cp */
-			if (cp_c && __ip_vs_conn_get(cp)) {
+			IP_VS_DBG(4, "del connection\n");
+			ip_vs_conn_del(cp);
+			if (cp_c && !atomic_read(&cp_c->n_control)) {
 				IP_VS_DBG(4, "del controlling connection\n");
-				ip_vs_conn_expire_now(cp_c);
-				__ip_vs_conn_put(cp);
+				ip_vs_conn_del(cp_c);
 			}
-			IP_VS_DBG(4, "del connection\n");
-			ip_vs_conn_expire_now(cp);
 		}
 		cond_resched_rcu();
 	}
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 412656c34f20..1a231f518e3f 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -224,7 +224,8 @@ static void defense_work_handler(struct work_struct *work)
 	update_defense_level(ipvs);
 	if (atomic_read(&ipvs->dropentry))
 		ip_vs_random_dropentry(ipvs);
-	schedule_delayed_work(&ipvs->defense_work, DEFENSE_TIMER_PERIOD);
+	queue_delayed_work(system_long_wq, &ipvs->defense_work,
+			   DEFENSE_TIMER_PERIOD);
 }
 #endif
 
@@ -4063,7 +4064,8 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 	ipvs->sysctl_tbl = tbl;
 	/* Schedule defense work */
 	INIT_DELAYED_WORK(&ipvs->defense_work, defense_work_handler);
-	schedule_delayed_work(&ipvs->defense_work, DEFENSE_TIMER_PERIOD);
+	queue_delayed_work(system_long_wq, &ipvs->defense_work,
+			   DEFENSE_TIMER_PERIOD);
 
 	return 0;
 }
-- 
2.26.2
==========================================================

> ---
>  include/net/ip_vs.h             | 29 +++++++++++++++++++++
>  net/netfilter/ipvs/ip_vs_conn.c | 43 +++++++++++++++++++++++++++++++
>  net/netfilter/ipvs/ip_vs_core.c | 45 +++++++++++++--------------------
>  net/netfilter/ipvs/ip_vs_ctl.c  | 22 ++++++++++++++++
>  4 files changed, 112 insertions(+), 27 deletions(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 83be2d93b407..49ca61765298 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -14,6 +14,7 @@
>  #include <linux/spinlock.h>             /* for struct rwlock_t */
>  #include <linux/atomic.h>               /* for struct atomic_t */
>  #include <linux/refcount.h>             /* for struct refcount_t */
> +#include <linux/workqueue.h>
>  
>  #include <linux/compiler.h>
>  #include <linux/timer.h>
> @@ -885,6 +886,8 @@ struct netns_ipvs {
>  	atomic_t		conn_out_counter;
>  
>  #ifdef CONFIG_SYSCTL
> +	/* delayed work for expiring no dest connections */
> +	struct delayed_work	expire_nodest_conn_work;
>  	/* 1/rate drop and drop-entry variables */
>  	struct delayed_work	defense_work;   /* Work handler */
>  	int			drop_rate;
> @@ -1049,6 +1052,11 @@ static inline int sysctl_conn_reuse_mode(struct netns_ipvs *ipvs)
>  	return ipvs->sysctl_conn_reuse_mode;
>  }
>  
> +static inline int sysctl_expire_nodest_conn(struct netns_ipvs *ipvs)
> +{
> +	return ipvs->sysctl_expire_nodest_conn;
> +}
> +
>  static inline int sysctl_schedule_icmp(struct netns_ipvs *ipvs)
>  {
>  	return ipvs->sysctl_schedule_icmp;
> @@ -1136,6 +1144,11 @@ static inline int sysctl_conn_reuse_mode(struct netns_ipvs *ipvs)
>  	return 1;
>  }
>  
> +static inline int sysctl_expire_nodest_conn(struct netns_ipvs *ipvs)
> +{
> +	return 0;
> +}
> +
>  static inline int sysctl_schedule_icmp(struct netns_ipvs *ipvs)
>  {
>  	return 0;
> @@ -1505,6 +1518,22 @@ static inline int ip_vs_todrop(struct netns_ipvs *ipvs)
>  static inline int ip_vs_todrop(struct netns_ipvs *ipvs) { return 0; }
>  #endif
>  
> +#ifdef CONFIG_SYSCTL
> +/* Enqueue delayed work for expiring no dest connections
> + * Only run when sysctl_expire_nodest=1
> + */
> +static inline void ip_vs_enqueue_expire_nodest_conns(struct netns_ipvs *ipvs)
> +{
> +	if (sysctl_expire_nodest_conn(ipvs))
> +		queue_delayed_work(system_long_wq,
> +				   &ipvs->expire_nodest_conn_work, 1);
> +}
> +
> +void ip_vs_expire_nodest_conn_flush(struct netns_ipvs *ipvs);
> +#else
> +static inline void ip_vs_enqueue_expire_nodest_conns(struct netns_ipvs) {}
> +#endif
> +
>  #define IP_VS_DFWD_METHOD(dest) (atomic_read(&(dest)->conn_flags) & \
>  				 IP_VS_CONN_F_FWD_MASK)
>  
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 02f2f636798d..f0d744e8c716 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -1366,6 +1366,49 @@ static void ip_vs_conn_flush(struct netns_ipvs *ipvs)
>  		goto flush_again;
>  	}
>  }
> +
> +#ifdef CONFIG_SYSCTL
> +void ip_vs_expire_nodest_conn_flush(struct netns_ipvs *ipvs)
> +{
> +	int idx;
> +	struct ip_vs_conn *cp, *cp_c;
> +	struct ip_vs_dest *dest;
> +
> +	rcu_read_lock();
> +	for (idx = 0; idx < ip_vs_conn_tab_size; idx++) {
> +		hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[idx], c_list) {
> +			if (cp->ipvs != ipvs)
> +				continue;
> +
> +			dest = cp->dest;
> +			if (!dest || (dest->flags & IP_VS_DEST_F_AVAILABLE))
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
> +
> +			IP_VS_DBG(4, "del connection\n");
> +			ip_vs_conn_expire_now(cp);
> +		}
> +		cond_resched_rcu();
> +
> +		/* netns clean up started, abort delayed work */
> +		if (!ipvs->enable)
> +			return;
> +	}
> +	rcu_read_unlock();
> +}
> +#endif
> +
>  /*
>   * per netns init and exit
>   */
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index aa6a603a2425..2508a9caeae8 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -694,16 +694,10 @@ static int sysctl_nat_icmp_send(struct netns_ipvs *ipvs)
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
>  static int sysctl_nat_icmp_send(struct netns_ipvs *ipvs) { return 0; }
> -static int sysctl_expire_nodest_conn(struct netns_ipvs *ipvs) { return 0; }
>  
>  #endif
>  
> @@ -2095,36 +2089,33 @@ ip_vs_in(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int
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
>  	ip_vs_in_stats(cp, skb);
>  	ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd);
>  	if (cp->packet_xmit)
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 8d14a1acbc37..9e53f517f138 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -210,6 +210,17 @@ static void update_defense_level(struct netns_ipvs *ipvs)
>  	local_bh_enable();
>  }
>  
> +/* Handler for delayed work for expiring no
> + * destination connections
> + */
> +static void expire_nodest_conn_handler(struct work_struct *work)
> +{
> +	struct netns_ipvs *ipvs;
> +
> +	ipvs = container_of(work, struct netns_ipvs,
> +			    expire_nodest_conn_work.work);
> +	ip_vs_expire_nodest_conn_flush(ipvs);
> +}
>  
>  /*
>   *	Timer for checking the defense
> @@ -1163,6 +1174,12 @@ static void __ip_vs_del_dest(struct netns_ipvs *ipvs, struct ip_vs_dest *dest,
>  	list_add(&dest->t_list, &ipvs->dest_trash);
>  	dest->idle_start = 0;
>  	spin_unlock_bh(&ipvs->dest_trash_lock);
> +
> +	/* Queue up delayed work to expire all no estination connections.
> +	 * No-op when CONFIG_SYSCTL is disabled.
> +	 */
> +	if (!cleanup)
> +		ip_vs_enqueue_expire_nodest_conns(ipvs);
>  }
>  
>  
> @@ -4065,6 +4082,10 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
>  	INIT_DELAYED_WORK(&ipvs->defense_work, defense_work_handler);
>  	schedule_delayed_work(&ipvs->defense_work, DEFENSE_TIMER_PERIOD);
>  
> +	/* Init delayed work for expiring no dest conn */
> +	INIT_DELAYED_WORK(&ipvs->expire_nodest_conn_work,
> +			  expire_nodest_conn_handler);
> +
>  	return 0;
>  }
>  
> @@ -4072,6 +4093,7 @@ static void __net_exit ip_vs_control_net_cleanup_sysctl(struct netns_ipvs *ipvs)
>  {
>  	struct net *net = ipvs->net;
>  
> +	cancel_delayed_work_sync(&ipvs->expire_nodest_conn_work);
>  	cancel_delayed_work_sync(&ipvs->defense_work);
>  	cancel_work_sync(&ipvs->defense_work.work);
>  	unregister_net_sysctl_table(ipvs->sysctl_hdr);
> -- 
> 2.20.1

Regards

--
Julian Anastasov <ja@ssi.bg>
