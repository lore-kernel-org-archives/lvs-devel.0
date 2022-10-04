From: Jiri Wiesner <jwiesner@suse.de>
Subject: Re: [RFC PATCHv4 2/5] ipvs: use kthreads for stats estimation
Date: Tue, 4 Oct 2022 10:39:09 +0200
Message-ID: <20221004083909.GB20326@incl>
References: <20220920135332.153732-1-ja@ssi.bg>
 <20220920135332.153732-3-ja@ssi.bg>
 <20221001105234.GA20326@incl>
 <ee1fceff-6be2-1584-f8f2-cda492fd884@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1664872750; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=qsmPyTDHsE2dW9LcCuL2pqbFa8xNjtXwQczrnsFUqDk=;
        b=vSGVQmX3cXC5FdmvoyTMxqzX/byyTAsTgh+38NZPAMnjmj6i/dL8NEteRV7vtbL05efYCc
        7uDutVwjbgAkQVNVfdWKnBJW7+HLD4+lIBtNPC7IbA5jpaLGYgOpxZ2EhjmeAjbfDlItzp
        YHzJoIEH5uneY/eXSV+S3IGI75rALOQ=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1664872750;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=qsmPyTDHsE2dW9LcCuL2pqbFa8xNjtXwQczrnsFUqDk=;
        b=UPjgVDue1JYuIMAh2/hkJYHBV1vZhRHzGa4YGYI0RAyyiQ9uazJxcS06ToaCma/OK5R00t
        xaOyQtebP2oGgpBQ==
Content-Disposition: inline
In-Reply-To: <ee1fceff-6be2-1584-f8f2-cda492fd884@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com

On Sun, Oct 02, 2022 at 05:12:41PM +0300, Julian Anastasov wrote:
> > In both cases, these are results from a second test. The command were:
> > modprobe ip_vs; perf record -e bus-cycles -a sleep 2 & ipvsadm -A -t 10.10.10.1:2000
> > ipvsadm -D -t 10.10.10.1:2000; modprobe -r ip_vs_wlc ip_vs
> > modprobe ip_vs; perf record -e bus-cycles -a sleep 2 & ipvsadm -A -t 10.10.10.1:2000
> > The kernel log from the first tests contains a warning printed by krealloc_array() because the requested size exceeds the object size that SLUB is able to allocate.
> > 
> > Both the chain_max_len and the profiles (and instructions taking the most time) from the test using est_temp_list estimators are similar to the test with the v4 code. In other words, there is no observable difference between the test using est_temp_list estimators and allocating new estimators in my tests (the machine has 64 CPUs and 2 NUMA nodes). Allocating new estimators in ip_vs_est_calc_limits() seems unnecessary.
> 
> 	OK, so caching effects do not matter.

I must argue against my own argument: I would not claim exactly that. I would be reluctant to generalize the statement even for modern CPUs manufactured by Intel. Whether or not caching (including fetching a cache line from a different NUMA node) matters depends on a particular CPU implementation and architecture. I only showed that always allocating new estimators and reusing the estimators from the est_temp_list yields similar results. A closer look at the results indicates that the first estimate is almost 4 times larger than the second estimate. My hackish modification caused the ntest 1 run to process 2 estimators while making the algorithm think it was testing only 1 estimator, hence the time diffs obtained from the ntest 1 run and the ntest 2 run should be similar. Apparently, they 
 are not:
> [   89.364408][  T493] IPVS: starting estimator thread 0...
> [   89.370467][ T8039] IPVS: calc: nodes 2
> [   89.374824][ T8039] IPVS: calc: diff 4354 ntest 1 min_est 4354 max 21
> [   89.382081][ T8039] IPVS: calc: diff 1125 ntest 2 min_est 562 max 169
> [   89.389329][ T8039] IPVS: calc: diff 2083 ntest 4 min_est 520 max 182
This results could actually be caused by reading cache-cold memory regions. Caching might play a role and the most accurate estimate would be obtained from the very first test. Testing just once and just 1 or 2 estimators (depending on what is available on the est_temp_list) while also switching off interrupts and preemption makes sense to me. The algorithm would be simpler and ip_vs_est_calc_limits() would be done sooner.

> The problem
> of using est_temp_list is that ip_vs_chain_estimation()
> walks the whole chain. It is less risky to do tests
> with allocated chain with known length and it was not a
> big deal to allocate 128 estimators. If allocation could
> fail, we can move 128 entries from est_temp_list to
> the test chain and then to move them back after the test.
> But in any case, if we test with estimators from a
> est_temp_list, as we run without any locked mutex
> the entries could be deleted while we are testing
> them. As result, we do not know how many estimators
> were really tested. More than one test could be needed for
> sure, i.e. the length of the tested temp chain should
> not change before/after the test.

I see that leaving the algorithm as it is and only substituting newly allocated estimators with estimators from the est_temp_list brings more problems than what it solves.

> 	And it would be better to call ip_vs_est_calc_limits
> after all tasks are stopped and estimators moved to
> est_temp_list.
> 
> > > +	for (;;) {
> > > +		/* Too much tests? */
> > > +		if (n >= 128)
> > > +			goto out;
> > > +
> > > +		/* Dequeue old estimators from chain to avoid CPU caching */
> > > +		for (;;) {
> > > +			est = hlist_entry_safe(chain.first,
> > > +					       struct ip_vs_estimator,
> > > +					       list);
> > > +			if (!est)
> > > +				break;
> > > +			hlist_del_init(&est->list);
> > 
> > Unlinking every estimator seems unnecessary - they are discarded before the function exits.
> 
> 	The goal was tested estimators to not be tested again.

The usual approach is to initialize the head and leave the list as it is (since an array holds the pointers, which will be used for deallocation) or splice it onto a different head.

> > > +		}
> > > +
> > > +		cond_resched();
> > > +		if (!is_fifo) {
> > > +			is_fifo = true;
> > > +			sched_set_fifo(current);
> > > +		}
> > > +		rcu_read_lock();
> > 
> > I suggest disabling preemption and interrupts on the local CPU. To get the minimal time need to process an estimator there is no need for interference from interrupt processing or context switches in this specific part of the code.
> 
> 	I preferred not to be so rude to other kthreads in the system.
> I hope several tests give enough approximation for the
> estimation speed.

The way in which the measurement is carried out depends on what value is expected to be measured and how that value is used. There is a catch when it comes to caching, as described above.
1. The value being measured could be the minimal time needed to process an estimator without including the time needed for interrupt processing. As it is written now, the algorithm determines approximately this value despite preemption and interrupts being enabled, which will result in some noise. The result of this approach is that a fully loaded kthread reached more than 50% of CPU utilization on my testing system (2 NUMA nodes, 64 CPUs):
> j=30; time for ((i=0; i < 500000; i++)); do p=$((i % 60000)); if [ $p -eq 0 ]; then j=$((j + 1)); echo 10.10.10.$j; fi; ipvsadm -A -t 10.10.10.$j:$((2000+$p)); done
>   PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
>  7993 root      20   0       0      0      0 R 52.99 0.000   6:16.24 ipvs-e:0:0
> 12913 root      20   0       0      0      0 I 5.090 0.000   0:15.31 ipvs-e:0:1
The debugging kernel printed while estimators were being added:
> [  168.667468] IPVS: starting estimator thread 0...
> [  168.674322] IPVS: calc: chain_max_len=191, single est=496ns, diff=64965, retry=1, ntest=128
> [  168.684550] IPVS: dequeue: 293ns
> [  168.688965] IPVS: using max 9168 ests per chain, 458400 per kthread
> [  170.613320] IPVS: tick time: 1676379ns for 64 CPUs, 1392 ests, 1 chains, chain_max_len=9168
> [  234.634576] IPVS: tick time: 18958330ns for 64 CPUs, 9168 ests, 1 chains, chain_max_len=9168
> ...
> [ 1770.630740] IPVS: tick time: 19127043ns for 64 CPUs, 9168 ests, 1 chains, chain_max_len=9168
This is more than 4 times the expected CPU utilization - 12%. So, minimal time needed to process an estimator would need to be applied in a different way - there would have to be other parameters to scale it to determine the chain length that yields 12% CPU utilization.

2. The value being measured would include interference from interrupt processing but not from context switching (due to preemption being disabled). In this case, a sliding average could be computed or something along these lines.

3. The value being measured would include interference from interrupt processing and from context switching. I cannot imagine a workable approach to use this.

> > > +walk_chain:
> > > +	if (kthread_should_stop())
> > > +		goto unlock;
> > > +	step++;
> > > +	if (!(step & 63)) {
> > > +		/* Give chance estimators to be added (to est_temp_list)
> > > +		 * and deleted (releasing kthread contexts)
> > > +		 */
> > > +		mutex_unlock(&__ip_vs_mutex);
> > > +		cond_resched();
> > > +		mutex_lock(&__ip_vs_mutex);
> > 
> > Is there any data backing the decision to cond_resched() here? What non-functional requirement were used to make this design decision?
> 
> 	kt 0 runs in parallel with netlink, we do not want
> to delay such processes that want to unlink estimators,
> we can be relinking 448800 estimators as in your test.

I commented out the cond_resched() and the locking statement around it, fully loaded a kthread and this was the result:
> [ 5060.214676] IPVS: starting estimator thread 0...
> [ 5060.222050] IPVS: calc: chain_max_len=144, single est=656ns, diff=91657, retry=1, ntest=128
> [ 5060.318628] IPVS: dequeue: 86284729ns
> [ 5060.323527] IPVS: using max 6912 ests per chain, 345600 per kthread
86 milliseconds is far too long, which justifies the cond_resched() and the additional trouble it brings.

-- 
Jiri Wiesner
SUSE Labs
