From: Jiri Wiesner <jwiesner@suse.de>
Subject: Re: [RFC PATCHv6 4/7] ipvs: use kthreads for stats estimation
Date: Mon, 21 Nov 2022 17:05:27 +0100
Message-ID: <20221121160527.GN3484@incl>
References: <20221031145647.156930-1-ja@ssi.bg>
 <20221031145647.156930-5-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1669046731; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=gVyUdIDA3Ihuwjc68fHdPWfeJ315QODrubdDrD6OAO0=;
        b=tBbGw8ZrJHUnScGQomVqsyjfhTqFArAs22WaqughusyS0uCYBgb0pTqTCdkRe0XQi9uEKa
        47ZbUcRFB66ptJ9+PvBuXkU7wZit//qn852YuyU1zpzQWYoVrH2hkpTIgyUK7vNFywmXNL
        uujPl7FSjAtYoZWm4IzHu/CmfYYzFs4=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1669046731;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=gVyUdIDA3Ihuwjc68fHdPWfeJ315QODrubdDrD6OAO0=;
        b=DeB0Tc3yZsO6+WGbed3eS9y32QDf2VdznEKtzmz4TjUNV/e/LVyV/na5xW0g0gZUG0WXZs
        80Rwt4NSGFZ+OGDw==
Content-Disposition: inline
In-Reply-To: <20221031145647.156930-5-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com

On Mon, Oct 31, 2022 at 04:56:44PM +0200, Julian Anastasov wrote:
> Estimating all entries in single list in timer context
> causes large latency with multiple rules.
> 
> Spread the estimator structures in multiple chains and
> use kthread(s) for the estimation. Every chain is
> processed under RCU lock. First kthread determines
> parameters to use, eg. maximum number of estimators to
> process per kthread based on chain's length, allowing
> sub-100us cond_resched rate and estimation taking 1/8
> of the CPU.
> 
> First kthread also plays the role of distributor of
> added estimators to all kthreads.
> 
> We also add delayed work est_reload_work that will
> make sure the kthread tasks are properly started/stopped.
> 
> ip_vs_start_estimator() is changed to report errors
> which allows to safely store the estimators in
> allocated structures.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---

Tested-by: Jiri Wiesner <jwiesner@suse.de>
Reviewed-by: Jiri Wiesner <jwiesner@suse.de>

> @@ -953,9 +1005,17 @@ struct netns_ipvs {
>  	struct ctl_table_header	*lblcr_ctl_header;
>  	struct ctl_table	*lblcr_ctl_table;
>  	/* ip_vs_est */
> -	struct list_head	est_list;	/* estimator list */
> -	spinlock_t		est_lock;
> -	struct timer_list	est_timer;	/* Estimation timer */
> +	struct delayed_work	est_reload_work;/* Reload kthread tasks */
> +	struct mutex		est_mutex;	/* protect kthread tasks */
> +	struct hlist_head	est_temp_list;	/* Ests during calc phase */
> +	struct ip_vs_est_kt_data **est_kt_arr;	/* Array of kthread data ptrs */
> +	unsigned long		est_max_threads;/* rlimit */

Not an rlimit anymore.

> +	int			est_calc_phase;	/* Calculation phase */
> +	int			est_chain_max;	/* Calculated chain_max */
> +	int			est_kt_count;	/* Allocated ptrs */
> +	int			est_add_ktid;	/* ktid where to add ests */
> +	atomic_t		est_genid;	/* kthreads reload genid */
> +	atomic_t		est_genid_done;	/* applied genid */
>  	/* ip_vs_sync */
>  	spinlock_t		sync_lock;
>  	struct ipvs_master_sync_state *ms;

> -	INIT_LIST_HEAD(&est->list);
> +/* Start estimation for stats */
> +int ip_vs_start_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats)
> +{
> +	struct ip_vs_estimator *est = &stats->est;
> +	int ret;
> +
> +	if (!ipvs->est_max_threads && ipvs->enable)
> +		ipvs->est_max_threads = 4 * num_possible_cpus();

To avoid the magic number - 4, a symbolic constant could be used. The 4 is related to the design decision that a fully loaded kthread should take 1/8 of the CPU time of a CPU.

> +
> +	est->ktid = -1;
> +	est->ktrow = IPVS_EST_NTICKS - 1;	/* Initial delay */
> +
> +	/* We prefer this code to be short, kthread 0 will requeue the
> +	 * estimator to available chain. If tasks are disabled, we
> +	 * will not allocate much memory, just for kt 0.
> +	 */
> +	ret = 0;
> +	if (!ipvs->est_kt_count || !ipvs->est_kt_arr[0])
> +		ret = ip_vs_est_add_kthread(ipvs);
> +	if (ret >= 0)
> +		hlist_add_head(&est->list, &ipvs->est_temp_list);
> +	else
> +		INIT_HLIST_NODE(&est->list);
> +	return ret;
> +}

-- 
Jiri Wiesner
SUSE Labs
