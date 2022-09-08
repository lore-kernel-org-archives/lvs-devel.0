From: Jiri Wiesner <jwiesner@suse.de>
Subject: Re: [RFC PATCH 0/4] Use kthreads for stats
Date: Thu, 8 Sep 2022 17:35:21 +0200
Message-ID: <20220908153521.GG18621@incl>
References: <20220827174154.220651-1-ja@ssi.bg>
 <20220905082642.GB18621@incl>
 <4e16b591-dd0-86e1-afcf-5759362908b@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1662651321; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=UEF7HIS1ycxzXhUxKUsoEIb9Ka83zXtifGjnH2/P5VA=;
        b=c5Wrai4j5X5KX4DOZhKzfmG3S50sqBfrbKdWD3vaYt21dCAcYDRNOoDFZR/FCEK6jzRdzt
        URSpUjPxtrBIHN1rsjE0+M9xupf+Xgu6cPA0kE47t9Sv2rPHQTzJBHFmyfu125mB5S0tT9
        WeZbg0zI0y5VX6mWV5I+K1bqdr4mkFI=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1662651321;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=UEF7HIS1ycxzXhUxKUsoEIb9Ka83zXtifGjnH2/P5VA=;
        b=K5mwidxjR/wxiA0sXusvgcwAQklRdnk4E7+nfKmyHQMk0ctyCK5vw1wLFWBgZsjnFRHyep
        /zGmhGWQSfoNOXCQ==
Content-Disposition: inline
In-Reply-To: <4e16b591-dd0-86e1-afcf-5759362908b@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com

On Wed, Sep 07, 2022 at 09:33:07PM +0300, Julian Anastasov wrote:
> On Mon, 5 Sep 2022, Jiri Wiesner wrote:
> 
> > I believe allowing the kthread the possibility to block in each iteration - for each estimator - introduces some problems:
> > 1. Non-preemptive kernels should be optimized for throughput not for latency
> > Using the figure reported earlier (50,000 services required 200 ms of processing time) it takes roughly 3 ms to process one chain (32 * 1024 / 50 services). The processing time per chain will vary with the number of NUMA nodes and CPUs. Nevertheless, this number comparable with the processing time limit of __do_softirq() - 2 ms, which gets converted to 1 jiffy. In term of latency of non-preemptive kernels, it is entirely resonable to let one chain be processed without rescheduling the kthread.
> 
> 	My worry is that IPVS_EST_MAX_COUNT is not a hard limit,
> we allow this limit to be exceeded when ip_vs_est_add_kthread()
> fails to create kthread (mostly on ENOMEM)

A design decision has been taken to allow more than IPVS_EST_MAX_COUNT estimators in a kthread. The reason is to be able to add estimators even if there is no memory to create a new kthread. Under such memory conditions, user space would not be able to fork new processes - the shell could not execute commands. The system is practically unusable until the OOM killer frees some memory. No production system should be expected to function in a long term when there is not enough memory to fork new processes. The solutions are: add more RAM, decrease workload or resolve memory leak bugs. Not being able to create a kthread can be expected to occur seldom, and it would have to occur while services or destination are being reconfigured. So, why bother with allowing more than IPVS_EST_MAX_COUNT esti
 mators in a kthread. It is common to return -ENOMEM to user space under such conditions.

> or if we add a limit
> for kthreads, so in such cases we can not refuse to add more
> estimators to existing kthreads.

As for limiting the number of kthreads, the limit could implemented as a sysctl variable. The default should be large enough for most deployments. I guess it could accomodate more than 900,000 estimators, which means 30 kthreads. The maximum number of destinations I have seen on a system was 110,000, with 7,000 services (but I have not seen many production systems running IPVS).

The current design does not take into account estimators that have been removed. As a result, kthreads that are not the last kthread could have fewer than IPVS_EST_MAX_COUNT estimators. This could be prevented by changing ipvs->est_add_ktid in ip_vs_stop_estimator() if the value of est->ktid is lower than the current ipvs->est_add_ktid. Ip_vs_start_estimator() would have to increment ipvs->est_add_ktid until it finds a kthread with fewer than IPVS_EST_MAX_COUNT estimators or it has to create a new kthread.

> > 3. Blocking while in ip_vs_estimation_chain() will results in wrong estimates for the remaining estimators in a chain. The 2 second interval would not be kept, rate estimates would be overestimated in that interval and underestimated in one of the future intervals.
> > In my opinion, any of the above reasons is sufficient to remove ip_vs_est_cond_resched_rcu(), ip_vs_est_wait_resched() and kd->mutex.
> 
> 	The chains can become too long. I'm not sure it is
> good to avoid cond_resched() for long time. Another solution
> would be to allocate more chains for a tick and apply some
> hard limit for these chains. cond_resched() will be called
> after such chain is processed. But it is difficult to
> calculate hard limit for these chains, it depends on the
> cycles we spend (CPU speed and the number of possible CPUs
> we walk in the loop). For example, we can have again 50 ticks
> but 16 chains per tick, so total 800 chains per kthread (50*16).
> 32*1024/800 means 40 estimators per chain before calling
> cond_resched().

OK, this seems workable. All the chains could be in one array
        struct hlist_head       chains[IPVS_EST_NCHAINS * 16];
and you would increment row by 16 in ip_vs_estimation_kthread().

> And a tick can attach more than 16 chains
> if the est_max_count is exceeded. It will cost some memory
> to provide more chains but it will avoid the kd->mutex
> games.
> 
> 	struct hlist_head *tick_chain = &kd->tick_chains[row];
> 
> 	rcu_read_lock();
> 	/* tick_chains has no limit of chains */
> 	hlist_for_each_entry_rcu(chain, tick_chains, list) {
> 		/* This list below is limited */
> 		hlist_for_each_entry_rcu(e, &chain->ests, list) {
> 			...
> 			if (kthread_should_stop())
> 				goto end;
> 			...
> 		}
> 		cond_resched_rcu();
> 	}

So, you set a limit - IPVS_EST_MAX_COUNT - but you also allow this limit to be ignored because of a corner case. As a result, tick_chains must not have a limit of chains because of that. I lean towards keeping the maximum of IPVS_EST_MAX_COUNT estimators per kthread.

There is an alternative design where you could increase kd->est_max_count for all kthreads once all of the available kthreads have kd->est_max_count estimators. Nevertheless, there would also have to be a limit to the value of kd->est_max_count. Imagine the estimation during a single tick would take so long that the gap variable in ip_vs_estimation_kthread() would become negative. You would need to have circa 250,000 estimators per kthread. Since you are already measuring the timeout you need for schedule_timeout() in ip_vs_estimation_kthread(), it should be possible to set the kd->est_max_count limit based on the maximum processing time per chain. It could be half a IPVS_EST_TICK, for example.

But it seems to me that the alternative design - increasing kd->est_max_count - should have some support in what is used in production. Are there servers with more than 983,040 estimators (which would be IPVS_EST_MAX_COUNT * 30 kthreads) or even one third of that?

> 	If we change ip_vs_start_estimator() to return int err
> we can safely allocate new chains and track for ENOMEM.
> I think, this is possible, with some reordering of the
> ip_vs_start_estimator() calls.

I think ip_vs_start_estimator() should return an int.

> > > Kthread data:
> > > 
> > > - every kthread works over its own data structure and all
> > > such structures are attached to array
> > 
> > It seems to me there is no upper bound on the number of kthreads that could be forked. Therefore, it should be possible to devise an attack that would force the system to run out of PIDs:
> > 1. Start adding services so that all chains of kthread A would be used.
> > 2. Add one more service to force the forking of kthread B, thus advancing ipvs->est_add_ktid.
> > 3. Remove all but one service from kthread A.
> > 4. Repeat steps 1-3 but with kthread B.
> > I think I could come up with a reproducer if need be.
> 
> 	Agreed, the chains management can be made more robust.
> This patchset is initial version that can serve as basis.
> We should consider such things:
> 
> - we do not know how many estimators will be added, if we
> limit the number of kthreads, then they will be overloaded

Not all kthreads would be overloaded. The current desing would add all the excess estimators into the last kthread.

> - add/del can be made to allocate memory for chains, if needed.
> We should not spend many cycles in adding/deleting estimators.

The fewer allocations the better. I would not use a linked list as described above - kd->tick_chains.

> - try more hard to spread estimators to chains, even with
> the risk of applying initially a smaller timer for the newly
> added estimator.

Yes.

> > Unbalanced chains would not be fatal to the system but there is risk of introducing scheduling latencies tens or even hundreds of milliseconds long. There are patterns of adding and removing chains that would results in chain imbalance getting so severe that a handful of chains would have estimators in them while the rest would be empty or almost empty. Some examples:
> > 1. Adding a new service each second after sleeping for 1 second. This would use the add_row value at the time of adding the estimator, which would result in 2 chains holding all the estimators.
> > 2. Repeated addition and removal of services. There would always be more services added than removed. The additions would be carried out in bursts. The forking of a new kthread would not be triggered because the number of services would stay under IPVS_EST_MAX_COUNT (32 * 1024).
> > 
> > The problem is that the code does not guarantee that the length of chains always stays under IPVS_EST_MAX_COUNT / IPVS_EST_NCHAINS (32 * 1024 / 50) estimators. A check and a cycle iterating over available rows could be added to ip_vs_start_estimator() to find the rows that still have fewer estimators than IPVS_EST_MAX_COUNT / IPVS_EST_NCHAINS. This would come at the expense of having inaccurate estimates for a few intervals but I think the trade-off is worth it. Also, the estimates will be inaccurate when estimators are added in bursts. If, depending on how services are added and removed, the code could introduce scheduling latencies there would be someone running into this sooner or later. The probability of severe chain imbalance being low is not good enough there should be a guarant
 ee.
> 
> 	About balancing the chains: not sure if it is possible
> while serving some row for current tick, to look ahead and
> advance the current tick work with estimators from the next
> tick. Such decisions can be made every tick. I.e. we do not
> move entries between the chains but we can walk one chain and
> possibly part of the other chain. If we have more chains per
> tick, it will be more easy, for example, if current tick
> processes 16 chains by default, it can process some from the  
> next 16 chains, say 16+8 in total. After 2 seconds, this tick can
> process 16+16+8, for example. It will depend on the currently
> added estimators per tick and its chains. Every 2 seconds
> we can advance with one tick, so that an estimator is
> served every 2 seconds or atleast after 1960ms if such
> chain stealing happens. Such logic will allow the
> estimators to be spread in time even while they are attached   
> to chains and ticks with different length. As result, we will
> process equal number of estimators per tick by slowly
> adjusting to their current number and chain lengths.

I am definitely not suggesting to implement balancing. I propose that each chain have a hard limit on the number of estimators.

-- 
Jiri Wiesner
SUSE Labs
