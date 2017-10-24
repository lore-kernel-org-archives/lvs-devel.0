From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] netfilter: ipvs: Convert timers to use timer_setup()
Date: Tue, 24 Oct 2017 22:07:03 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1710242203100.2078@ja.home.ssi.bg>
References: <20171024084521.GA23684@beast>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171024084521.GA23684@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>
Cc: "David S. Miller" <davem@davemloft.net>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org


	Hello,

On Tue, 24 Oct 2017, Kees Cook wrote:

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Wensong Zhang <wensong@linux-vs.org>
> Cc: Simon Horman <horms@verge.net.au>
> Cc: Julian Anastasov <ja@ssi.bg>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
> Cc: Florian Westphal <fw@strlen.de>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> Cc: lvs-devel@vger.kernel.org
> Cc: netfilter-devel@vger.kernel.org
> Cc: coreteam@netfilter.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

	Looks good to me,

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_conn.c  | 10 +++++-----
>  net/netfilter/ipvs/ip_vs_ctl.c   |  7 +++----
>  net/netfilter/ipvs/ip_vs_est.c   |  6 +++---
>  net/netfilter/ipvs/ip_vs_lblc.c  | 11 ++++++-----
>  net/netfilter/ipvs/ip_vs_lblcr.c | 11 ++++++-----
>  5 files changed, 23 insertions(+), 22 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 3d2ac71a83ec..3a43b3470331 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -104,7 +104,7 @@ static inline void ct_write_unlock_bh(unsigned int key)
>  	spin_unlock_bh(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
>  }
>  
> -static void ip_vs_conn_expire(unsigned long data);
> +static void ip_vs_conn_expire(struct timer_list *t);
>  
>  /*
>   *	Returns hash value for IPVS connection entry
> @@ -457,7 +457,7 @@ EXPORT_SYMBOL_GPL(ip_vs_conn_out_get_proto);
>  static void __ip_vs_conn_put_notimer(struct ip_vs_conn *cp)
>  {
>  	__ip_vs_conn_put(cp);
> -	ip_vs_conn_expire((unsigned long)cp);
> +	ip_vs_conn_expire(&cp->timer);
>  }
>  
>  /*
> @@ -817,9 +817,9 @@ static void ip_vs_conn_rcu_free(struct rcu_head *head)
>  	kmem_cache_free(ip_vs_conn_cachep, cp);
>  }
>  
> -static void ip_vs_conn_expire(unsigned long data)
> +static void ip_vs_conn_expire(struct timer_list *t)
>  {
> -	struct ip_vs_conn *cp = (struct ip_vs_conn *)data;
> +	struct ip_vs_conn *cp = from_timer(cp, t, timer);
>  	struct netns_ipvs *ipvs = cp->ipvs;
>  
>  	/*
> @@ -909,7 +909,7 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p, int dest_af,
>  	}
>  
>  	INIT_HLIST_NODE(&cp->c_list);
> -	setup_timer(&cp->timer, ip_vs_conn_expire, (unsigned long)cp);
> +	timer_setup(&cp->timer, ip_vs_conn_expire, 0);
>  	cp->ipvs	   = ipvs;
>  	cp->af		   = p->af;
>  	cp->daf		   = dest_af;
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 4f940d7eb2f7..b47e266c6eca 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1146,9 +1146,9 @@ ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
>  	return 0;
>  }
>  
> -static void ip_vs_dest_trash_expire(unsigned long data)
> +static void ip_vs_dest_trash_expire(struct timer_list *t)
>  {
> -	struct netns_ipvs *ipvs = (struct netns_ipvs *)data;
> +	struct netns_ipvs *ipvs = from_timer(ipvs, t, dest_trash_timer);
>  	struct ip_vs_dest *dest, *next;
>  	unsigned long now = jiffies;
>  
> @@ -4019,8 +4019,7 @@ int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
>  
>  	INIT_LIST_HEAD(&ipvs->dest_trash);
>  	spin_lock_init(&ipvs->dest_trash_lock);
> -	setup_timer(&ipvs->dest_trash_timer, ip_vs_dest_trash_expire,
> -		    (unsigned long) ipvs);
> +	timer_setup(&ipvs->dest_trash_timer, ip_vs_dest_trash_expire, 0);
>  	atomic_set(&ipvs->ftpsvc_counter, 0);
>  	atomic_set(&ipvs->nullsvc_counter, 0);
>  	atomic_set(&ipvs->conn_out_counter, 0);
> diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
> index 457c6c193e13..489055091a9b 100644
> --- a/net/netfilter/ipvs/ip_vs_est.c
> +++ b/net/netfilter/ipvs/ip_vs_est.c
> @@ -97,12 +97,12 @@ static void ip_vs_read_cpu_stats(struct ip_vs_kstats *sum,
>  }
>  
>  
> -static void estimation_timer(unsigned long arg)
> +static void estimation_timer(struct timer_list *t)
>  {
>  	struct ip_vs_estimator *e;
>  	struct ip_vs_stats *s;
>  	u64 rate;
> -	struct netns_ipvs *ipvs = (struct netns_ipvs *)arg;
> +	struct netns_ipvs *ipvs = from_timer(ipvs, t, est_timer);
>  
>  	spin_lock(&ipvs->est_lock);
>  	list_for_each_entry(e, &ipvs->est_list, list) {
> @@ -192,7 +192,7 @@ int __net_init ip_vs_estimator_net_init(struct netns_ipvs *ipvs)
>  {
>  	INIT_LIST_HEAD(&ipvs->est_list);
>  	spin_lock_init(&ipvs->est_lock);
> -	setup_timer(&ipvs->est_timer, estimation_timer, (unsigned long)ipvs);
> +	timer_setup(&ipvs->est_timer, estimation_timer, 0);
>  	mod_timer(&ipvs->est_timer, jiffies + 2 * HZ);
>  	return 0;
>  }
> diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
> index b6aa4a970c6e..d625179de485 100644
> --- a/net/netfilter/ipvs/ip_vs_lblc.c
> +++ b/net/netfilter/ipvs/ip_vs_lblc.c
> @@ -106,6 +106,7 @@ struct ip_vs_lblc_table {
>  	struct rcu_head		rcu_head;
>  	struct hlist_head	bucket[IP_VS_LBLC_TAB_SIZE];  /* hash bucket */
>  	struct timer_list       periodic_timer; /* collect stale entries */
> +	struct ip_vs_service	*svc;		/* pointer back to service */
>  	atomic_t                entries;        /* number of entries */
>  	int                     max_size;       /* maximum size of entries */
>  	int                     rover;          /* rover for expire check */
> @@ -294,10 +295,10 @@ static inline void ip_vs_lblc_full_check(struct ip_vs_service *svc)
>   *             of the table.
>   *      The full expiration check is for this purpose now.
>   */
> -static void ip_vs_lblc_check_expire(unsigned long data)
> +static void ip_vs_lblc_check_expire(struct timer_list *t)
>  {
> -	struct ip_vs_service *svc = (struct ip_vs_service *) data;
> -	struct ip_vs_lblc_table *tbl = svc->sched_data;
> +	struct ip_vs_lblc_table *tbl = from_timer(tbl, t, periodic_timer);
> +	struct ip_vs_service *svc = tbl->svc;
>  	unsigned long now = jiffies;
>  	int goal;
>  	int i, j;
> @@ -369,12 +370,12 @@ static int ip_vs_lblc_init_svc(struct ip_vs_service *svc)
>  	tbl->rover = 0;
>  	tbl->counter = 1;
>  	tbl->dead = 0;
> +	tbl->svc = svc;
>  
>  	/*
>  	 *    Hook periodic timer for garbage collection
>  	 */
> -	setup_timer(&tbl->periodic_timer, ip_vs_lblc_check_expire,
> -			(unsigned long)svc);
> +	timer_setup(&tbl->periodic_timer, ip_vs_lblc_check_expire, 0);
>  	mod_timer(&tbl->periodic_timer, jiffies + CHECK_EXPIRE_INTERVAL);
>  
>  	return 0;
> diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
> index c13ff575f9f7..84c57b62a588 100644
> --- a/net/netfilter/ipvs/ip_vs_lblcr.c
> +++ b/net/netfilter/ipvs/ip_vs_lblcr.c
> @@ -278,6 +278,7 @@ struct ip_vs_lblcr_table {
>  	atomic_t                entries;        /* number of entries */
>  	int                     max_size;       /* maximum size of entries */
>  	struct timer_list       periodic_timer; /* collect stale entries */
> +	struct ip_vs_service	*svc;		/* pointer back to service */
>  	int                     rover;          /* rover for expire check */
>  	int                     counter;        /* counter for no expire */
>  	bool			dead;
> @@ -458,10 +459,10 @@ static inline void ip_vs_lblcr_full_check(struct ip_vs_service *svc)
>   *             of the table.
>   *      The full expiration check is for this purpose now.
>   */
> -static void ip_vs_lblcr_check_expire(unsigned long data)
> +static void ip_vs_lblcr_check_expire(struct timer_list *t)
>  {
> -	struct ip_vs_service *svc = (struct ip_vs_service *) data;
> -	struct ip_vs_lblcr_table *tbl = svc->sched_data;
> +	struct ip_vs_lblcr_table *tbl = from_timer(tbl, t, periodic_timer);
> +	struct ip_vs_service *svc = tbl->svc;
>  	unsigned long now = jiffies;
>  	int goal;
>  	int i, j;
> @@ -532,12 +533,12 @@ static int ip_vs_lblcr_init_svc(struct ip_vs_service *svc)
>  	tbl->rover = 0;
>  	tbl->counter = 1;
>  	tbl->dead = 0;
> +	tbl->svc = svc;
>  
>  	/*
>  	 *    Hook periodic timer for garbage collection
>  	 */
> -	setup_timer(&tbl->periodic_timer, ip_vs_lblcr_check_expire,
> -			(unsigned long)svc);
> +	timer_setup(&tbl->periodic_timer, ip_vs_lblcr_check_expire, 0);
>  	mod_timer(&tbl->periodic_timer, jiffies + CHECK_EXPIRE_INTERVAL);
>  
>  	return 0;
> -- 
> 2.7.4
> 
> 
> -- 
> Kees Cook
> Pixel Security

Regards

--
Julian Anastasov <ja@ssi.bg>
