From: Jiri Wiesner <jwiesner@suse.de>
Subject: Re: [RFC PATCH 2/4] ipvs: use kthreads for stats estimation
Date: Mon, 5 Sep 2022 15:19:05 +0200
Message-ID: <20220905131905.GD18621@incl>
References: <20220827174154.220651-1-ja@ssi.bg>
 <20220827174154.220651-3-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1662383945; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=kuvdt64Ktz+PiH21mhens6JHHs2FELLocYimQMduWrg=;
        b=NCKWBgJX0xonRLlqAk9ucI7pv7CzMZihzgaSlAWs5lcyW1fk5MpN4qf9xZ1KHe0VJVyXHw
        VMyouVVLFW2ZVcjfFK1uklSzjRJBH5g8F6uIkO9Mn7dwGE1GKd8qejcneZZ+R2BUYTHwIW
        kRW+oDoY/D4Uo44hz+nA0E7u0pDJAR0=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1662383945;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=kuvdt64Ktz+PiH21mhens6JHHs2FELLocYimQMduWrg=;
        b=8mc12ZFXsQSivxblaIkKQtKW8geGIkWZacEw9VWX9aVHY+JBnk1EJxcacZVSaOmjEgLe1d
        gEAxZBq4KALYqYBg==
Content-Disposition: inline
In-Reply-To: <20220827174154.220651-3-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, yunhjiang@ebay.com, dust.li@linux.alibaba.com, tangyang@zhihu.com

On Sat, Aug 27, 2022 at 08:41:52PM +0300, Julian Anastasov wrote:
> @@ -239,8 +239,49 @@ static void defense_work_handler(struct work_struct *work)
>  	queue_delayed_work(system_long_wq, &ipvs->defense_work,
>  			   DEFENSE_TIMER_PERIOD);
>  }
> +
>  #endif
>  
> +static void est_reload_work_handler(struct work_struct *work)
> +{
> +	struct netns_ipvs *ipvs =
> +		container_of(work, struct netns_ipvs, est_reload_work.work);
> +	int genid = atomic_read(&ipvs->est_genid);
> +	int genid_done = atomic_read(&ipvs->est_genid_done);
> +	unsigned long delay = HZ / 10;	/* repeat startups after failure */
> +	bool repeat = false;
> +	int id;
> +
> +	mutex_lock(&ipvs->est_mutex);
> +	for (id = 0; id < ipvs->est_kt_count; id++) {
> +		struct ip_vs_est_kt_data *kd = ipvs->est_kt_arr[id];
> +
> +		/* netns clean up started, abort delayed work */
> +		if (!ipvs->enable)
> +			goto unlock;

It would save some code to move the ipvs->enable check before the critical section and use a return statement right away.

> +		if (!kd)
> +			continue;
> +		/* New config ? Stop kthread tasks */
> +		if (genid != genid_done)
> +			ip_vs_est_kthread_stop(kd);
> +		if (!kd->task && ip_vs_est_kthread_start(ipvs, kd) < 0)
> +			repeat = true;
> +	}
> +
> +	atomic_set(&ipvs->est_genid_done, genid);
> +
> +unlock:
> +	mutex_unlock(&ipvs->est_mutex);
> +
> +	if (!ipvs->enable)
> +		return;
> +	if (genid != atomic_read(&ipvs->est_genid))
> +		delay = 1;
> +	else if (!repeat)
> +		return;
> +	queue_delayed_work(system_long_wq, &ipvs->est_reload_work, delay);
> +}
> +
>  int
>  ip_vs_use_count_inc(void)
>  {

> @@ -47,68 +44,75 @@
>      to 32-bit values for conns, packets, bps, cps and pps.
>  
>    * A lot of code is taken from net/core/gen_estimator.c
> - */
> -
>  
> -/*
> - * Make a summary from each cpu
> +  KEY POINTS:
> +  - cpustats counters are updated per-cpu in SoftIRQ context with BH disabled
> +  - kthreads read the cpustats to update the estimators (svcs, dests, total)
> +  - the states of estimators can be read (get stats) or modified (zero stats)
> +    from processes
> +
> +  KTHREADS:
> +  - kthread contexts are created and attached to array
> +  - the kthread tasks are created when first service is added, before that
> +    the total stats are not estimated
> +  - the kthread context holds lists with estimators (chains) which are
> +    processed every 2 seconds
> +  - as estimators can be added dynamically and in bursts, we try to spread
> +    them to multiple chains which are estimated at different time
>   */
> -static void ip_vs_read_cpu_stats(struct ip_vs_kstats *sum,
> -				 struct ip_vs_cpu_stats __percpu *stats)
> -{
> -	int i;
> -	bool add = false;
>  
> -	for_each_possible_cpu(i) {
> -		struct ip_vs_cpu_stats *s = per_cpu_ptr(stats, i);
> -		unsigned int start;
> -		u64 conns, inpkts, outpkts, inbytes, outbytes;
> -
> -		if (add) {
> -			do {
> -				start = u64_stats_fetch_begin(&s->syncp);
> -				conns = s->cnt.conns;
> -				inpkts = s->cnt.inpkts;
> -				outpkts = s->cnt.outpkts;
> -				inbytes = s->cnt.inbytes;
> -				outbytes = s->cnt.outbytes;
> -			} while (u64_stats_fetch_retry(&s->syncp, start));
> -			sum->conns += conns;
> -			sum->inpkts += inpkts;
> -			sum->outpkts += outpkts;
> -			sum->inbytes += inbytes;
> -			sum->outbytes += outbytes;
> -		} else {
> -			add = true;
> -			do {
> -				start = u64_stats_fetch_begin(&s->syncp);
> -				sum->conns = s->cnt.conns;
> -				sum->inpkts = s->cnt.inpkts;
> -				sum->outpkts = s->cnt.outpkts;
> -				sum->inbytes = s->cnt.inbytes;
> -				sum->outbytes = s->cnt.outbytes;
> -			} while (u64_stats_fetch_retry(&s->syncp, start));
> -		}
> -	}
> -}
> +/* Optimal chain length used to spread bursts of newly added ests */
> +#define IPVS_EST_BURST_LEN	BIT(6)
> +/* Max number of ests per kthread (recommended) */
> +#define IPVS_EST_MAX_COUNT	(32 * 1024)
>  
> +static struct lock_class_key __ipvs_est_key;
>  
> -static void estimation_timer(struct timer_list *t)
> +static void ip_vs_estimation_chain(struct ip_vs_est_kt_data *kd, int row)
>  {
> +	struct hlist_head *chain = &kd->chains[row];
>  	struct ip_vs_estimator *e;
> +	struct ip_vs_cpu_stats *c;
>  	struct ip_vs_stats *s;
>  	u64 rate;
> -	struct netns_ipvs *ipvs = from_timer(ipvs, t, est_timer);
>  
> -	if (!sysctl_run_estimation(ipvs))
> -		goto skip;
> +	rcu_read_lock();
> +	hlist_for_each_entry_rcu(e, chain, list) {
> +		u64 conns, inpkts, outpkts, inbytes, outbytes;
> +		u64 kconns = 0, kinpkts = 0, koutpkts = 0;
> +		u64 kinbytes = 0, koutbytes = 0;
> +		unsigned int start;
> +		int i;
> +
> +		if (kthread_should_stop())
> +			break;
> +		ip_vs_est_cond_resched_rcu(kd, e);
>  
> -	spin_lock(&ipvs->est_lock);
> -	list_for_each_entry(e, &ipvs->est_list, list) {
>  		s = container_of(e, struct ip_vs_stats, est);
> +		for_each_possible_cpu(i) {
> +			c = per_cpu_ptr(s->cpustats, i);
> +			do {
> +				start = u64_stats_fetch_begin(&c->syncp);
> +				conns = c->cnt.conns;
> +				inpkts = c->cnt.inpkts;
> +				outpkts = c->cnt.outpkts;
> +				inbytes = c->cnt.inbytes;
> +				outbytes = c->cnt.outbytes;
> +			} while (u64_stats_fetch_retry(&c->syncp, start));
> +			kconns += conns;
> +			kinpkts += inpkts;
> +			koutpkts += outpkts;
> +			kinbytes += inbytes;
> +			koutbytes += outbytes;
> +		}
> +
> +		spin_lock_bh(&s->lock);

Per-CPU counters are updated from softirq context and read by user space processes and kthreads. The per-CPU counters are protected by the syncp member. Kthreads sum up the per-CPU counters and calculate rate estimates. Both the counters sums and rates are read (or reset) by user space processes. What I am building to is: Bottom halves should stay enabled unless it is necessary to disable them to ensure data consistency. It should not be necessary to disable bottom halves here because the spin lock only protects the counter sums and rates and synchronizes kthreads and user space processes. Following this logic, disabling bottom halves could be dropped in ip_vs_copy_stats() and ip_vs_zero_stats(). Am I wrong about this?

>  
> -		spin_lock(&s->lock);
> -		ip_vs_read_cpu_stats(&s->kstats, s->cpustats);
> +		s->kstats.conns = kconns;
> +		s->kstats.inpkts = kinpkts;
> +		s->kstats.outpkts = koutpkts;
> +		s->kstats.inbytes = kinbytes;
> +		s->kstats.outbytes = koutbytes;
>  
>  		/* scaled by 2^10, but divided 2 seconds */
>  		rate = (s->kstats.conns - e->last_conns) << 9;
> @@ -131,32 +135,288 @@ static void estimation_timer(struct timer_list *t)
>  		rate = (s->kstats.outbytes - e->last_outbytes) << 4;
>  		e->last_outbytes = s->kstats.outbytes;
>  		e->outbps += ((s64)rate - (s64)e->outbps) >> 2;
> -		spin_unlock(&s->lock);
> +		spin_unlock_bh(&s->lock);
> +	}
> +	rcu_read_unlock();
> +}
> +
> +static int ip_vs_estimation_kthread(void *data)
> +{
> +	struct ip_vs_est_kt_data *kd = data;
> +	struct netns_ipvs *ipvs = kd->ipvs;
> +	int row = kd->est_row;
> +	unsigned long now;
> +	long gap;
> +
> +	while (1) {
> +		set_current_state(TASK_IDLE);
> +		if (kthread_should_stop())
> +			break;
> +
> +		/* before estimation, check if we should sleep */
> +		now = READ_ONCE(jiffies);
> +		gap = kd->est_timer - now;
> +		if (gap > 0) {
> +			if (gap > IPVS_EST_TICK) {
> +				kd->est_timer = now - IPVS_EST_TICK;
> +				gap = IPVS_EST_TICK;
> +			}
> +			schedule_timeout(gap);
> +		} else {
> +			__set_current_state(TASK_RUNNING);
> +			if (gap < -8 * IPVS_EST_TICK)
> +				kd->est_timer = now;
> +		}
> +
> +		if (sysctl_run_estimation(ipvs) &&
> +		    !hlist_empty(&kd->chains[row]))
> +			ip_vs_estimation_chain(kd, row);
> +
> +		row++;
> +		if (row >= IPVS_EST_NCHAINS)
> +			row = 0;
> +		kd->est_row = row;
> +		/* add_row best to point after the just estimated row */
> +		WRITE_ONCE(kd->add_row, row);

One of the effects of setting add_row here is that it will randomize the chains to which estimators are added when estimators are added in many short bursts with time intervals between the bursts exceeding IPVS_EST_TICK. I guess that is what we want.

> +		kd->est_timer += IPVS_EST_TICK;
> +	}
> +	__set_current_state(TASK_RUNNING);
> +
> +	return 0;
> +}
> +
> +/* Stop (bump=true)/start kthread tasks */
> +void ip_vs_est_reload_start(struct netns_ipvs *ipvs, bool bump)

The variable name "bump" is not make it obvious what will be the action taken after setting bump to true.

> +{
> +	/* Ignore reloads before first service is added */
> +	if (!ipvs->enable)
> +		return;
> +	/* Bump the kthread configuration genid */
> +	if (bump)
> +		atomic_inc(&ipvs->est_genid);
> +	queue_delayed_work(system_long_wq, &ipvs->est_reload_work,
> +			   bump ? 0 : 1);
> +}
> +
> +/* Start kthread task with current configuration */
> +int ip_vs_est_kthread_start(struct netns_ipvs *ipvs,
> +			    struct ip_vs_est_kt_data *kd)
> +{
> +	unsigned long now;
> +	int ret = 0;
> +	long gap;
> +
> +	lockdep_assert_held(&ipvs->est_mutex);
> +
> +	if (kd->task)
> +		goto out;
> +	now = READ_ONCE(jiffies);
> +	gap = kd->est_timer - now;
> +	/* Sync est_timer if task is starting later */
> +	if (abs(gap) > 4 * IPVS_EST_TICK)
> +		kd->est_timer = now;
> +	kd->task = kthread_create(ip_vs_estimation_kthread, kd, "ipvs-e:%d:%d",
> +				  ipvs->gen, kd->id);
> +	if (IS_ERR(kd->task)) {
> +		ret = PTR_ERR(kd->task);
> +		kd->task = NULL;
> +		goto out;
>  	}
> -	spin_unlock(&ipvs->est_lock);
>  
> -skip:
> -	mod_timer(&ipvs->est_timer, jiffies + 2*HZ);
> +	pr_info("starting estimator thread %d...\n", kd->id);
> +	wake_up_process(kd->task);
> +
> +out:
> +	return ret;
> +}
> +
> +void ip_vs_est_kthread_stop(struct ip_vs_est_kt_data *kd)
> +{
> +	if (kd->task) {
> +		pr_info("stopping estimator thread %d...\n", kd->id);
> +		kthread_stop(kd->task);
> +		kd->task = NULL;
> +	}
>  }
>  
> +/* Create and start estimation kthread in a free or new array slot */
> +static int ip_vs_est_add_kthread(struct netns_ipvs *ipvs)
> +{
> +	struct ip_vs_est_kt_data *kd = NULL;
> +	int id = ipvs->est_kt_count;
> +	int err = -ENOMEM;
> +	void *arr = NULL;
> +	int i;
> +
> +	mutex_lock(&ipvs->est_mutex);
> +
> +	for (i = 0; i < id; i++) {
> +		if (!ipvs->est_kt_arr[i])
> +			break;
> +	}
> +	if (i >= id) {
> +		arr = krealloc_array(ipvs->est_kt_arr, id + 1,
> +				     sizeof(struct ip_vs_est_kt_data *),
> +				     GFP_KERNEL);
> +		if (!arr)
> +			goto out;
> +		ipvs->est_kt_arr = arr;
> +	} else {
> +		id = i;
> +	}
> +	kd = kmalloc(sizeof(*kd), GFP_KERNEL);
> +	if (!kd)
> +		goto out;
> +	kd->ipvs = ipvs;
> +	mutex_init(&kd->mutex);
> +	kd->id = id;
> +	kd->est_count = 0;
> +	kd->est_max_count = IPVS_EST_MAX_COUNT;
> +	kd->add_row = 0;
> +	kd->est_row = 0;
> +	kd->est_timer = jiffies;
> +	for (i = 0; i < ARRAY_SIZE(kd->chains); i++)
> +		INIT_HLIST_HEAD(&kd->chains[i]);
> +	memset(kd->chain_len, 0, sizeof(kd->chain_len));
> +	kd->task = NULL;
> +	/* Start kthread tasks only when services are present */
> +	if (ipvs->enable) {
> +		/* On failure, try to start the task again later */
> +		if (ip_vs_est_kthread_start(ipvs, kd) < 0)
> +			ip_vs_est_reload_start(ipvs, false);
> +	}
> +
> +	if (arr)
> +		ipvs->est_kt_count++;
> +	ipvs->est_kt_arr[id] = kd;
> +	/* Use most recent kthread for new ests */
> +	ipvs->est_add_ktid = id;
> +

To consolidate the code paths, the out label could be moved here after getting rid of the dead code and changing err.

> +	mutex_unlock(&ipvs->est_mutex);
> +
> +	return 0;
> +
> +out:
> +	mutex_unlock(&ipvs->est_mutex);
> +	if (kd) {

The kd variable above does not evaluate to true in this code path. This is dead code:

> +		mutex_destroy(&kd->mutex);
> +		kfree(kd);
> +	}
> +	return err;
> +}
> +
> +/* Add estimator to current kthread (est_add_ktid) */
>  void ip_vs_start_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats)
>  {
>  	struct ip_vs_estimator *est = &stats->est;
> +	struct ip_vs_est_kt_data *kd = NULL;
> +	int ktid, row;
> +
> +	INIT_HLIST_NODE(&est->list);
> +	ip_vs_est_init_resched_rcu(est);
> +
> +	if (ipvs->est_add_ktid < ipvs->est_kt_count) {
> +		kd = ipvs->est_kt_arr[ipvs->est_add_ktid];
> +		if (!kd)
> +			goto add_kt;
> +		if (kd->est_count < kd->est_max_count)
> +			goto add_est;
> +	}
>  
> -	INIT_LIST_HEAD(&est->list);
> +add_kt:
> +	/* Create new kthread but we can exceed est_max_count on failure */
> +	if (ip_vs_est_add_kthread(ipvs) < 0) {
> +		if (!kd || kd->est_count >= INT_MAX / 2)
> +			goto out;
> +	}
> +	kd = ipvs->est_kt_arr[ipvs->est_add_ktid];
> +	if (!kd)
> +		goto out;
> +
> +add_est:
> +	ktid = kd->id;
> +	/* add_row points after the row we should use */
> +	row = READ_ONCE(kd->add_row) - 1;
> +	if (row < 0)
> +		row = IPVS_EST_NCHAINS - 1;
> +
> +	kd->est_count++;
> +	kd->chain_len[row]++;
> +	/* Multiple ests added together? Fill chains one by one. */
> +	if (!(kd->chain_len[row] & (IPVS_EST_BURST_LEN - 1)))
> +		kd->add_row = row;
> +	est->ktid = ktid;
> +	est->ktrow = row;
> +	hlist_add_head_rcu(&est->list, &kd->chains[row]);
> +
> +out:

The out label is needless. There is no error handling. A return statement instead of the gotos would express the intention more clearly. (It applies to other functions in the patch as well.)

> +	;
> +}
>  
> -	spin_lock_bh(&ipvs->est_lock);
> -	list_add(&est->list, &ipvs->est_list);
> -	spin_unlock_bh(&ipvs->est_lock);
> +static void ip_vs_est_kthread_destroy(struct ip_vs_est_kt_data *kd)
> +{
> +	if (kd) {
> +		if (kd->task)
> +			kthread_stop(kd->task);
> +		mutex_destroy(&kd->mutex);
> +		kfree(kd);
> +	}
>  }
>  
> +/* Unlink estimator from list */
>  void ip_vs_stop_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats)
>  {
>  	struct ip_vs_estimator *est = &stats->est;
> +	struct ip_vs_est_kt_data *kd;
> +	int ktid = est->ktid;
> +
> +	/* Failed to add to chain ? */
> +	if (hlist_unhashed(&est->list))
> +		goto out;
> +
> +	hlist_del_rcu(&est->list);
> +	ip_vs_est_wait_resched(ipvs, est);
> +
> +	kd = ipvs->est_kt_arr[ktid];
> +	kd->chain_len[est->ktrow]--;
> +	kd->est_count--;
> +	if (kd->est_count)
> +		goto out;
> +	pr_info("stop unused estimator thread %d...\n", ktid);
> +
> +	mutex_lock(&ipvs->est_mutex);
> +
> +	ip_vs_est_kthread_destroy(kd);
> +	ipvs->est_kt_arr[ktid] = NULL;
> +	if (ktid == ipvs->est_kt_count - 1)
> +		ipvs->est_kt_count--;
> +
> +	mutex_unlock(&ipvs->est_mutex);
> +
> +	if (ktid == ipvs->est_add_ktid) {
> +		int count = ipvs->est_kt_count;
> +		int best = -1;
> +
> +		while (count-- > 0) {
> +			if (!ipvs->est_add_ktid)
> +				ipvs->est_add_ktid = ipvs->est_kt_count;
> +			ipvs->est_add_ktid--;
> +			kd = ipvs->est_kt_arr[ipvs->est_add_ktid];
> +			if (!kd)
> +				continue;
> +			if (kd->est_count < kd->est_max_count) {
> +				best = ipvs->est_add_ktid;
> +				break;
> +			}
> +			if (best < 0)
> +				best = ipvs->est_add_ktid;
> +		}
> +		if (best >= 0)
> +			ipvs->est_add_ktid = best;
> +	}
>  
> -	spin_lock_bh(&ipvs->est_lock);
> -	list_del(&est->list);
> -	spin_unlock_bh(&ipvs->est_lock);
> +out:
> +	;
>  }
>  
>  void ip_vs_zero_estimator(struct ip_vs_stats *stats)

-- 
Jiri Wiesner
SUSE Labs
