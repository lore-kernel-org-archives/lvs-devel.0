From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCHv4 2/5] ipvs: use kthreads for stats estimation
Date: Sun, 2 Oct 2022 17:12:41 +0300 (EEST)
Message-ID: <ee1fceff-6be2-1584-f8f2-cda492fd884@ssi.bg>
References: <20220920135332.153732-1-ja@ssi.bg> <20220920135332.153732-3-ja@ssi.bg> <20221001105234.GA20326@incl>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20221001105234.GA20326@incl>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Wiesner <jwiesner@suse.de>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com


	Hello,

On Sat, 1 Oct 2022, Jiri Wiesner wrote:

> On Tue, Sep 20, 2022 at 04:53:29PM +0300, Julian Anastasov wrote:
> > +/* Start estimation for stats */
> > +int ip_vs_start_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats)
> > +{
> > +	struct ip_vs_estimator *est = &stats->est;
> > +	int ret;
> > +
> > +	/* Get rlimit only from process that adds service, not from
> > +	 * net_init/kthread. Clamp limit depending on est->ktid size.
> > +	 */
> > +	if (!ipvs->est_max_threads && ipvs->enable)
> > +		ipvs->est_max_threads = min_t(unsigned long,
> > +					      rlimit(RLIMIT_NPROC), SHRT_MAX);
> 
> For example, the user space limit on the number of processes does not hold any useful value on my testing machine:
> # ulimit -u
> 254318
> while /proc/sys/kernel/pid_max is 65536. The pid_max variable itself depends on the number of CPUs on the system. I also think that user space limits should not directly determine how many kthreads can be created by the kernel. By design, one fully loaded kthread will take up 12% of the CPU time on one CPU. On account of the CPU usage it does not make sense to set ipvs->est_max_threads to a value higher than a multiple (4 or less) of the number of possible CPUs in the system. I think the ipvs->est_max_threads value should not allow CPUs to get saturated. Also, kthreads computing IPVS rate estimates could be created in each net namespace on the system, which alone makes it possible to saturate all the CPUs on the system because ipvs->est_max_threads does not take other namespaces into acc
 ount.
> As for solutions to this problem, I think it would be easiest to implement global counters in ip_vs_est.c (est_kt_count and est_max_threads) that would be tested for the max number of allocated kthreads in ip_vs_est_add_kthread().
> Another possible solution would be to share kthreads among all net namespaces but that would be a step back considering that the current implementation is per net namespace. For the purpose of computing estimates, it does not really matter to which namespace an estimator belongs. This solution is problematic with regards to resource control - cgroups. But from what I have seen, IPVS estimators were always configured in the init net namespace so it would not matter if the kthreads were shared among all net namespaces.

	Yes, considering possible cgroups integration I prefer
namespaces to be isolated. So, 4 * cpumask_weight() would be suitable
ipvs->est_max_threads value. IPVS later can get support for
GENL_UNS_ADMIN_PERM (better netns support) and GFP_KERNEL_ACCOUNT.
In this case, we should somehow control the allocations done
in kthreads.

> > +	est->ktid = -1;
> > +
> > +	/* We prefer this code to be short, kthread 0 will requeue the
> > +	 * estimator to available chain. If tasks are disabled, we
> > +	 * will not allocate much memory, just for kt 0.
> > +	 */
> > +	ret = 0;
> > +	if (!ipvs->est_kt_count || !ipvs->est_kt_arr[0])
> > +		ret = ip_vs_est_add_kthread(ipvs);
> > +	if (ret >= 0)
> > +		hlist_add_head(&est->list, &ipvs->est_temp_list);
> > +	else
> > +		INIT_HLIST_NODE(&est->list);
> > +	return ret;
> > +}
> > +
> 
> > +/* Calculate limits for all kthreads */
> > +static int ip_vs_est_calc_limits(struct netns_ipvs *ipvs, int *chain_max_len)
> 
> I am not happy about all the dynamic allocation happening in this function, which introduces a reason why the function could fail. A simpler approach would use just the estimators that are currently available on ipvs->est_temp_list and run ip_vs_chain_estimation(&chain) in a loop to reach ntest estimators being processed. The rate estimates would need to be reset after the tests are done. When kthread 0 enters calc phase there may very well be only two estimators on ipvs->est_temp_list. Are there any testing results indicating that newly allocated estimators give different results compared to processing the est_temp_list estimators in a loop?

	I avoided using the est_temp_list entries because
they can be min 2 (total + service) and I preferred tests
with more estimators to reduce the effect of rescheduling,
interrupts, etc.

> In both cases, these are results from a second test. The command were:
> modprobe ip_vs; perf record -e bus-cycles -a sleep 2 & ipvsadm -A -t 10.10.10.1:2000
> ipvsadm -D -t 10.10.10.1:2000; modprobe -r ip_vs_wlc ip_vs
> modprobe ip_vs; perf record -e bus-cycles -a sleep 2 & ipvsadm -A -t 10.10.10.1:2000
> The kernel log from the first tests contains a warning printed by krealloc_array() because the requested size exceeds the object size that SLUB is able to allocate.
> 
> Both the chain_max_len and the profiles (and instructions taking the most time) from the test using est_temp_list estimators are similar to the test with the v4 code. In other words, there is no observable difference between the test using est_temp_list estimators and allocating new estimators in my tests (the machine has 64 CPUs and 2 NUMA nodes). Allocating new estimators in ip_vs_est_calc_limits() seems unnecessary.

	OK, so caching effects do not matter. The problem
of using est_temp_list is that ip_vs_chain_estimation()
walks the whole chain. It is less risky to do tests
with allocated chain with known length and it was not a
big deal to allocate 128 estimators. If allocation could
fail, we can move 128 entries from est_temp_list to
the test chain and then to move them back after the test.
But in any case, if we test with estimators from a
est_temp_list, as we run without any locked mutex
the entries could be deleted while we are testing
them. As result, we do not know how many estimators
were really tested. More than one test could be needed for
sure, i.e. the length of the tested temp chain should
not change before/after the test.

	And it would be better to call ip_vs_est_calc_limits
after all tasks are stopped and estimators moved to
est_temp_list.

> > +	for (;;) {
> > +		/* Too much tests? */
> > +		if (n >= 128)
> > +			goto out;
> > +
> > +		/* Dequeue old estimators from chain to avoid CPU caching */
> > +		for (;;) {
> > +			est = hlist_entry_safe(chain.first,
> > +					       struct ip_vs_estimator,
> > +					       list);
> > +			if (!est)
> > +				break;
> > +			hlist_del_init(&est->list);
> 
> Unlinking every estimator seems unnecessary - they are discarded before the function exits.

	The goal was tested estimators to not be tested again.

> > +		}
> > +
> > +		cond_resched();
> > +		if (!is_fifo) {
> > +			is_fifo = true;
> > +			sched_set_fifo(current);
> > +		}
> > +		rcu_read_lock();
> 
> I suggest disabling preemption and interrupts on the local CPU. To get the minimal time need to process an estimator there is no need for interference from interrupt processing or context switches in this specific part of the code.

	I preferred not to be so rude to other kthreads in the system.
I hope several tests give enough approximation for the
estimation speed.

> 
> > +		t1 = ktime_get();
> > +		ip_vs_chain_estimation(&chain);
> > +		t2 = ktime_get();
> > +		rcu_read_unlock();
> > +
> > +		if (!ipvs->enable || kthread_should_stop())
> > +			goto stop;
> > +
> > +		diff = ktime_to_ns(ktime_sub(t2, t1));
> > +		if (diff <= 1 || diff >= NSEC_PER_SEC)
> 
> What is the reason for the diff <= 1? Is it about the CLOCK_MONOTONIC time source not incrementing?

	The timer resolution can be low, a longer test should
succeed :)

> > +walk_chain:
> > +	if (kthread_should_stop())
> > +		goto unlock;
> > +	step++;
> > +	if (!(step & 63)) {
> > +		/* Give chance estimators to be added (to est_temp_list)
> > +		 * and deleted (releasing kthread contexts)
> > +		 */
> > +		mutex_unlock(&__ip_vs_mutex);
> > +		cond_resched();
> > +		mutex_lock(&__ip_vs_mutex);
> 
> Is there any data backing the decision to cond_resched() here? What non-functional requirement were used to make this design decision?

	kt 0 runs in parallel with netlink, we do not want
to delay such processes that want to unlink estimators,
we can be relinking 448800 estimators as in your test.

Regards

--
Julian Anastasov <ja@ssi.bg>

