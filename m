From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCHv5 3/6] ipvs: use kthreads for stats estimation
Date: Sat, 29 Oct 2022 17:12:28 +0300 (EEST)
Message-ID: <753051f-655d-bef5-70f-cbc41928adeb@ssi.bg>
References: <20221009153710.125919-1-ja@ssi.bg> <20221009153710.125919-4-ja@ssi.bg> <20221015092158.GA3484@incl> <64d2975-357d-75f7-1d34-c43a1b3fc72a@ssi.bg> <20221022181513.GB3484@incl> <b279182b-58ee-1c76-e194-31539d95982@ssi.bg>
 <20221027180751.GC3484@incl>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20221027180751.GC3484@incl>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Wiesner <jwiesner@suse.de>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com


	Hello,

On Thu, 27 Oct 2022, Jiri Wiesner wrote:

> On Mon, Oct 24, 2022 at 06:01:32PM +0300, Julian Anastasov wrote:
> > 
> > 	Hm, can it be some cpufreq/ondemand issue causing this?
> > Test can be affected by CPU speed.
> 
> Yes, my testing confirms that it is the CPU frequency governor. On my Intel testing machine, the intel_pstate driver can use the powersave governor (which is similar to the ondemand cpufreq governor) or the performance governor (which is, again, similar to the ondemand cpufreq governor but ramps up CPU frequency rapidly when a CPU is utilized). Chain_max ends up being 12 up to 35 when the powersave governor is used. It may happen that the powersave governor does not manage to ramp up CPU frequency before the calc phase is over so chain_max can be as low as 12. Chain_max exceeds 50 when the performance governor is used.

	OK, then we can try some sequence of 3 x (pause+4) tests,
for example, pause, t1, t2, t3, t4, pause, t5... t12.
More tests and especially the delay in time will ensure the
CPU speed is increased.

> This leads to the following scenario: What if someone set the performance governor, added many estimators and changed the governor to powersave? It seems the current algorithm leaves enough headroom for this sequence of steps not to saturate the CPUs:

	We hope our test pattern will reduce the difference
in governors to acceptable levels :)

> > cpupower frequency-set -g performance
> > [ 3796.171742] IPVS: starting estimator thread 0...
> > [ 3796.177723] IPVS: calc: chain_max=53, single est=1775ns, diff=1775, loops=1, ntest=3
> > [ 3796.187205] IPVS: dequeue: 35ns
> > [ 3796.191513] IPVS: using max 2544 ests per chain, 127200 per kthread
> > [ 3798.081076] IPVS: tick time: 64306ns for 64 CPUs, 89 ests, 1 chains, chain_max=2544
> > [ 3898.081668] IPVS: tick time: 661019ns for 64 CPUs, 743 ests, 1 chains, chain_max=2544
> > [ 3959.127101] IPVS: starting estimator thread 1...
> This is the output of top with the performance governor and a fully loaded kthread:
> >   PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
> > 31138 root      20   0       0      0      0 I 4.651 0.000   0:06.02 ipvs-e:0:0
> > 39644 root      20   0       0      0      0 I 0.332 0.000   0:00.28 ipvs-e:0:1
> > cpupower frequency-set -g powersave
> > [ 3962.083052] IPVS: tick time: 2047264ns for 64 CPUs, 2544 ests, 1 chains, chain_max=2544
> > [ 4026.083100] IPVS: tick time: 2074317ns for 64 CPUs, 2544 ests, 1 chains, chain_max=2544
> > [ 4090.086794] IPVS: tick time: 5758102ns for 64 CPUs, 2544 ests, 1 chains, chain_max=2544
> > [ 4154.086788] IPVS: tick time: 5753057ns for 64 CPUs, 2544 ests, 1 chains, chain_max=2544

	5.7ms vs desired 4.8ms, not bad

> This is the output of top with the powersave governor and a fully loaded kthread:
> >   PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
> > 31138 root      20   0       0      0      0 I 13.91 0.000   0:16.34 ipvs-e:0:0
> > 39644 root      20   0       0      0      0 I 1.656 0.000   0:01.32 ipvs-e:0:1
> So, the CPU time more than doubles but is still reasonable.

	Yep, desired is 12.5% :)

> 
> Next, I tried the same with a 4 NUMA node ARM server, which uses the cppc_cpufreq driver. I checked the chain_max under different governors:
> > cpupower frequency-set -g powersave > /dev/null
> > ipvsadm -A -t 10.10.10.1:2000
> > ipvsadm -D -t 10.10.10.1:2000; modprobe -r ip_vs_wlc ip_vs
> > [ 8833.384789] IPVS: starting estimator thread 0...
> > [ 8833.743439] IPVS: calc: chain_max=1, single est=66250ns, diff=66250, loops=1, ntest=3
> > [ 8833.751989] IPVS: dequeue: 460ns
> > [ 8833.755955] IPVS: using max 48 ests per chain, 2400 per kthread
> > [ 8835.723480] IPVS: tick time: 49150ns for 128 CPUs, 2 ests, 1 chains, chain_max=48
> > cpupower frequency-set -g ondemand > /dev/null
> > ipvsadm -A -t 10.10.10.1:2000
> > ipvsadm -D -t 10.10.10.1:2000; modprobe -r ip_vs_wlc ip_vs
> > [ 8865.160082] IPVS: starting estimator thread 0...
> > [ 8865.523554] IPVS: calc: chain_max=7, single est=13090ns, diff=71140, loops=1, ntest=3

	Low values for chain_max such as 1 and 7 are real
issue due to the large number of CPUs. Not sure how to
optimize this, we do not know which CPUs are engaged
in network traffic, not to mention that OUTPUT traffic
can come from any CPU that serves local applications.
We spend many cycles to read stats from unused CPUs.

> > [ 8865.532119] IPVS: dequeue: 470ns
> > [ 8865.536098] IPVS: using max 336 ests per chain, 16800 per kthread
> > [ 8867.503530] IPVS: tick time: 90650ns for 128 CPUs, 2 ests, 1 chains, chain_max=336
> > cpupower frequency-set -g performance > /dev/null
> > ipvsadm -A -t 10.10.10.1:2000
> > ipvsadm -D -t 10.10.10.1:2000; modprobe -r ip_vs_wlc ip_vs
> > [ 9064.480977] IPVS: starting estimator thread 0...
> > [ 9064.843404] IPVS: calc: chain_max=11, single est=8230ns, diff=8230, loops=1, ntest=3
> > [ 9064.851836] IPVS: dequeue: 50ns
> > [ 9064.855668] IPVS: using max 528 ests per chain, 26400 per kthread
> > [ 9066.823414] IPVS: tick time: 8020ns for 128 CPUs, 2 ests, 1 chains, chain_max=528
> 
> I created a fully loaded kthread under the performance governor and switched to more energy-saving governors after that:
> > cpupower frequency-set -g performance > /dev/null
> > [ 9174.806973] IPVS: starting estimator thread 0...
> > [ 9175.163406] IPVS: calc: chain_max=12, single est=7890ns, diff=7890, loops=1, ntest=3
> > [ 9175.171834] IPVS: dequeue: 80ns
> > [ 9175.175663] IPVS: using max 576 ests per chain, 28800 per kthread
> > [ 9177.143429] IPVS: tick time: 21080ns for 128 CPUs, 2 ests, 1 chains, chain_max=576
> > [ 9241.145020] IPVS: tick time: 1608270ns for 128 CPUs, 576 ests, 1 chains, chain_max=576

	1.6ms, expected was 4.8ms, does it mean we underestimate
by 3 times?

> > [ 9246.984959] IPVS: starting estimator thread 1...
> >    PID USER      PR  NI    VIRT    RES    SHR S    %CPU  %MEM     TIME+ COMMAND
> >   7071 root      20   0       0      0      0 I   3.630 0.000   0:03.24 ipvs-e:0:0
> >  35898 root      20   0       0      0      0 I   1.320 0.000   0:00.78 ipvs-e:0:1
> > [ 9305.145029] IPVS: tick time: 1617990ns for 128 CPUs, 576 ests, 1 chains, chain_max=576
> > cpupower frequency-set -g ondemand > /dev/null
> > [ 9369.148006] IPVS: tick time: 4575030ns for 128 CPUs, 576 ests, 1 chains, chain_max=576
> > [ 9433.147149] IPVS: tick time: 3725910ns for 128 CPUs, 576 ests, 1 chains, chain_max=576
> >    PID USER      PR  NI    VIRT    RES    SHR S    %CPU  %MEM     TIME+ COMMAND
> >   7071 root      20   0       0      0      0 I  11.148 0.000   0:53.90 ipvs-e:0:0
> >  35898 root      20   0       0      0      0 I   5.902 0.000   0:26.94 ipvs-e:0:1
> > [ 9497.149206] IPVS: tick time: 5564490ns for 128 CPUs, 576 ests, 1 chains, chain_max=576
> > [ 9561.147165] IPVS: tick time: 3735390ns for 128 CPUs, 576 ests, 1 chains, chain_max=576
> > [ 9625.146803] IPVS: tick time: 3382870ns for 128 CPUs, 576 ests, 1 chains, chain_max=576
> > [ 9689.148018] IPVS: tick time: 4580270ns for 128 CPUs, 576 ests, 1 chains, chain_max=576

	We are lucky here, 4.5ms, 11.1%

> > cpupower frequency-set -g powersave > /dev/null
> > [ 9753.152504] IPVS: tick time: 8979300ns for 128 CPUs, 576 ests, 1 chains, chain_max=576
> > [ 9817.152433] IPVS: tick time: 8985520ns for 128 CPUs, 576 ests, 1 chains, chain_max=576
> >    PID USER      PR  NI    VIRT    RES    SHR S    %CPU  %MEM     TIME+ COMMAND
> >   7071 root      20   0       0      0      0 I  22.293 0.000   1:04.82 ipvs-e:0:0
> >  35898 root      20   0       0      0      0 I   8.599 0.000   0:31.48 ipvs-e:0:1
> To my slight suprise, the result is not disasterous even on this platform, which has much more of a difference between a CPU running in powersave and a CPU in performance mode.

	8.9ms is going hot ...

> > 	Then I'll add such pause between the tests in the next
> > version. Let me know if you see any problems with different NUMA
> > configurations due to the chosen cache_factor.
> 
> I think ip_vs_est_calc_limits() could do more to obtain a more realistic chain_max value. There should definitely be a finite number of iterations taken by the for loop - in hundreds, I guess. Instead of just collecting the minimum value of min_est, ip_vs_est_calc_limits() should check for its convergence. Once the difference from a previous iteration gets below a threshold (say, expressed as a fraction of the min_est value), a condition checking this would terminate the loop before completing all of the iterations. A sliding average and bit shifting could be used to check for convergence.

	Our tests are probably on idle system. If the
CPUs we use get network traffic, the reality can be scary :)
So, I'm not sure if any averages can make any difference
because what we will detect is a noise from load which is different
during initial tests and later during service. For now, it looks
like we can ignore the problems due to changing the cpufreq
governor.

> > 	For now, I don't have a good idea how to change the
> > algorithm to use feedback from real estimation without
> > complicating it further. The only way to safely change
> > the chain limit immediately is as it is implemented now: stop
> > tasks, reallocate, relink and start tasks. If we want to
> > do it without stopping tasks, it violates the RCU-list
> > rules: we can not relink entries without RCU grace period.
> > 
> > 	So, we have the following options:
> > 
> > 1. Use this algorithm if it works in different configurations
> 
> I think the current algorithm is a major improvement over what is currently in mainline. The current mainline algorithm just shamelessly steals hundreds of milliseconds from processes and causes havoc in terms of latency.

	Yep, only that for multi-CPU systems the whole
stats estimation looks problematic, before and now.

> > 2. Use this algorithm but trigger recalculation (stop, relink,
> > start) if a kthread with largest number of entries detects
> > big difference for chain_max
> > 3. Implement different data structure to store estimators
> > 
> > 	Currently, the problem comes from the fact that we
> > store estimators in chains. We should cut these chains if
> > chain_max should be reduced. Second option would be to
> > put estimators in ptr arrays but then there is a problem
> > with fragmentation on add/del and as result, slower walking.
> > Arrays probably can allow the limit used for cond_resched,
> > that is now chain_max, to be applied without relinking
> > entries.
> > 
> > 	To summarize, the goals are:
> > 
> > - allocations for linking estimators should not be large (many
> > pages), prefer to allocate in small steps
> > 
> > - due to RCU-list rules we can not relink without task stop+start
> > 
> > - real estimation should give more accurate values for
> > the parameters: cond_resched rate
> > 
> > - fast lock-free walking of estimators by kthreads
> > 
> > - fast add/del of estimators, by netlink
> > 
> > - if possible, a way to avoid estimations for estimators
> > that are not updated, eg. added service/dest but no
> > traffic
> > 
> > - fast and safe way to apply a new chain_max or similar
> > parameter for cond_resched rate. If possible, without
> > relinking. stop+start can be slow too.
> 
> I am still wondering where the requirement for 100 us latency in non-preemtive kernels comes from. Typical time slices assigned by a time-sharing scheduler are measured in milliseconds. A kernel with volutary preemption does not need any cond_resched statements in ip_vs_tick_estimation() because every spin_unlock() in ip_vs_chain_estimation() is a preemption point, which actually puts the accuracy of the computed estimates at risk but nothing can be done about that, I guess.

	I'm not sure about the 100us requirements for non-RT
kernels, this document covers only RT requirements, I think:

Documentation/RCU/Design/Requirements/Requirements.rst

	In fact, I don't worry for the RCU-preemptible
case where we can be rescheduled at any time. In this
case cond_resched_rcu() is NOP and chain_max has only
one purpose of limiting ests in kthread, i.e. not to
determine period between cond_resched calls which is
its 2nd purpose for the non-preemptible case.

	As for the non-preemptible case,
rcu_read_lock/rcu_read_unlock are just preempt_disable/preempt_enable 
which means the spin locking can not preempt us, the only way is
we to call rcu_read_unlock which is just preempt_count_dec()
or a simple barrier() but __preempt_schedule() is not
called as it happens on CONFIG_PREEMPTION. So, only
cond_resched() can allow rescheduling.

	Also, there are some configurations like nohz_full
that expect cond_resched() to check for any pending
rcu_urgent_qs condition via rcu_all_qs(). I'm not
expert in areas such as RCU and scheduling, so I'm
not sure about the 100us latency budget for the
non-preemptible cases we cover:

1. PREEMPT_NONE "No Forced Preemption (Server)"
2. PREEMPT_VOLUNTARY "Voluntary Kernel Preemption (Desktop)"

	Where the latency can matter is setups where the
IPVS kthreads are set to some low priority, as a
way to work in idle times and to allow app servers
to react to clients' requests faster. Once request
is served with short delay, app blocks somewhere and
our kthreads run again running in idle times.

	In short, the IPVS kthreads do not have an
urgent work, they should do their 4.8ms work in 40ms
or even more but it is preferred not to delay other
more-priority tasks such as applications or even other
kthreads. That is why I think we should stick to some low
period between cond_resched calls without causing
it to take large part of our CPU usage.

	If we want to reduce its rate, it can be
in this way, for example:

	int n = 0;

	/* 400us for forced cond_resched() but reschedule on demand */
	if (!(++n & 3) || need_resched()) {
		cond_resched_rcu();
		n = 0;
	}

	This controls both the RCU requirements and
reacts faster on scheduler's indication. There will be
an useless need_resched() call for the RCU-preemptible
case, though, where cond_resched_rcu is NOP.

Regards

--
Julian Anastasov <ja@ssi.bg>

