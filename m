From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCH 2/4] ipvs: use kthreads for stats estimation
Date: Wed, 7 Sep 2022 22:01:27 +0300 (EEST)
Message-ID: <6a7bec4b-557-298b-b2e9-f3a517a47489@ssi.bg>
References: <20220827174154.220651-1-ja@ssi.bg> <20220827174154.220651-3-ja@ssi.bg> <20220905131905.GD18621@incl>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20220905131905.GD18621@incl>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Wiesner <jwiesner@suse.de>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com


	Hello,

On Mon, 5 Sep 2022, Jiri Wiesner wrote:

> On Sat, Aug 27, 2022 at 08:41:52PM +0300, Julian Anastasov wrote:
> >  
> > +static void est_reload_work_handler(struct work_struct *work)
> > +{
> > +	struct netns_ipvs *ipvs =
> > +		container_of(work, struct netns_ipvs, est_reload_work.work);
> > +	int genid = atomic_read(&ipvs->est_genid);
> > +	int genid_done = atomic_read(&ipvs->est_genid_done);
> > +	unsigned long delay = HZ / 10;	/* repeat startups after failure */
> > +	bool repeat = false;
> > +	int id;
> > +
> > +	mutex_lock(&ipvs->est_mutex);
> > +	for (id = 0; id < ipvs->est_kt_count; id++) {
> > +		struct ip_vs_est_kt_data *kd = ipvs->est_kt_arr[id];
> > +
> > +		/* netns clean up started, abort delayed work */
> > +		if (!ipvs->enable)
> > +			goto unlock;
> 
> It would save some code to move the ipvs->enable check before the critical section and use a return statement right away.

	I preferred to react to cleanup_net() faster and
avoid creating threads if this is what we try to do here.

> 
> > +		if (!kd)
> > +			continue;
> > +		/* New config ? Stop kthread tasks */
> > +		if (genid != genid_done)
> > +			ip_vs_est_kthread_stop(kd);
> > +		if (!kd->task && ip_vs_est_kthread_start(ipvs, kd) < 0)
> > +			repeat = true;
> > +	}
> > +
> > +	atomic_set(&ipvs->est_genid_done, genid);
> > +
> > +unlock:
> > +	mutex_unlock(&ipvs->est_mutex);
> > +
> > +	if (!ipvs->enable)
> > +		return;
> > +	if (genid != atomic_read(&ipvs->est_genid))
> > +		delay = 1;
> > +	else if (!repeat)
> > +		return;
> > +	queue_delayed_work(system_long_wq, &ipvs->est_reload_work, delay);
> > +}
> > +

> > +		spin_lock_bh(&s->lock);
> 
> Per-CPU counters are updated from softirq context and read by user space processes and kthreads. The per-CPU counters are protected by the syncp member. Kthreads sum up the per-CPU counters and calculate rate estimates. Both the counters sums and rates are read (or reset) by user space processes. What I am building to is: Bottom halves should stay enabled unless it is necessary to disable them to ensure data consistency. It should not be necessary to disable bottom halves here because the spin lock only protects the counter sums and rates and synchronizes kthreads and user space processes. Following this logic, disabling bottom halves could be dropped in ip_vs_copy_stats() and ip_vs_zero_stats(). Am I wrong about this?

	Yes, removing _bh is correct. The risk is the
other processes to spin if kthread is interrupted by BH.
While the correct method to use for processes is mutex,
due to RCU we can not use it. So, I preferred the _bh
calls for now.

> > +		row++;
> > +		if (row >= IPVS_EST_NCHAINS)
> > +			row = 0;
> > +		kd->est_row = row;
> > +		/* add_row best to point after the just estimated row */
> > +		WRITE_ONCE(kd->add_row, row);
> 
> One of the effects of setting add_row here is that it will randomize the chains to which estimators are added when estimators are added in many short bursts with time intervals between the bursts exceeding IPVS_EST_TICK. I guess that is what we want.

	Yes, what we want here is to apply an initial
2-second timer for the newly added ests but the first
priority is to reduce this initial timer if the chain
is overloaded.

	This code just ensures 2-second initial timer,
it gives add_row as a hint if we add few estimators but
if many estimators are added they will occupy more/all
chains, if needed. It can happen before the first
estimation if all config is created at start and
not changed later.

> > +/* Stop (bump=true)/start kthread tasks */
> > +void ip_vs_est_reload_start(struct netns_ipvs *ipvs, bool bump)
> 
> The variable name "bump" is not make it obvious what will be the action taken after setting bump to true.

	Yes, more comments should be added. bump=true causes
restart while bump=false just keeps them started. When
we change ip_vs_start_estimator() to propagate the
errors from ip_vs_est_kthread_start() this var will be
removed.

> > +	/* Start kthread tasks only when services are present */
> > +	if (ipvs->enable) {
> > +		/* On failure, try to start the task again later */
> > +		if (ip_vs_est_kthread_start(ipvs, kd) < 0)
> > +			ip_vs_est_reload_start(ipvs, false);
> > +	}
> > +
> > +	if (arr)
> > +		ipvs->est_kt_count++;
> > +	ipvs->est_kt_arr[id] = kd;
> > +	/* Use most recent kthread for new ests */
> > +	ipvs->est_add_ktid = id;
> > +
> 
> To consolidate the code paths, the out label could be moved here after getting rid of the dead code and changing err.
> 
> > +	mutex_unlock(&ipvs->est_mutex);
> > +
> > +	return 0;
> > +
> > +out:
> > +	mutex_unlock(&ipvs->est_mutex);
> > +	if (kd) {
> 
> The kd variable above does not evaluate to true in this code path. This is dead code:

	Yes, it used to fail on ip_vs_est_kthread_start() failure
but not in this patch version.

> > +		mutex_destroy(&kd->mutex);
> > +		kfree(kd);
> > +	}
> > +	return err;
> > +}
> > +
> > +/* Add estimator to current kthread (est_add_ktid) */
> >  void ip_vs_start_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats)
> >  {
> >  	struct ip_vs_estimator *est = &stats->est;
> > +	struct ip_vs_est_kt_data *kd = NULL;
> > +	int ktid, row;
> > +
> > +	INIT_HLIST_NODE(&est->list);
> > +	ip_vs_est_init_resched_rcu(est);
> > +
> > +	if (ipvs->est_add_ktid < ipvs->est_kt_count) {
> > +		kd = ipvs->est_kt_arr[ipvs->est_add_ktid];
> > +		if (!kd)
> > +			goto add_kt;
> > +		if (kd->est_count < kd->est_max_count)
> > +			goto add_est;
> > +	}
> >  
> > -	INIT_LIST_HEAD(&est->list);
> > +add_kt:
> > +	/* Create new kthread but we can exceed est_max_count on failure */
> > +	if (ip_vs_est_add_kthread(ipvs) < 0) {
> > +		if (!kd || kd->est_count >= INT_MAX / 2)
> > +			goto out;
> > +	}
> > +	kd = ipvs->est_kt_arr[ipvs->est_add_ktid];
> > +	if (!kd)
> > +		goto out;
> > +
> > +add_est:
> > +	ktid = kd->id;
> > +	/* add_row points after the row we should use */
> > +	row = READ_ONCE(kd->add_row) - 1;
> > +	if (row < 0)
> > +		row = IPVS_EST_NCHAINS - 1;
> > +
> > +	kd->est_count++;
> > +	kd->chain_len[row]++;
> > +	/* Multiple ests added together? Fill chains one by one. */
> > +	if (!(kd->chain_len[row] & (IPVS_EST_BURST_LEN - 1)))
> > +		kd->add_row = row;
> > +	est->ktid = ktid;
> > +	est->ktrow = row;
> > +	hlist_add_head_rcu(&est->list, &kd->chains[row]);
> > +
> > +out:
> 
> The out label is needless. There is no error handling. A return statement instead of the gotos would express the intention more clearly. (It applies to other functions in the patch as well.)

	I'll probably change ip_vs_start_estimator to return error.

Regards

--
Julian Anastasov <ja@ssi.bg>

