From: Jiri Wiesner <jwiesner@suse.de>
Subject: Re: [RFC PATCHv4 2/5] ipvs: use kthreads for stats estimation
Date: Sat, 1 Oct 2022 12:52:34 +0200
Message-ID: <20221001105234.GA20326@incl>
References: <20220920135332.153732-1-ja@ssi.bg>
 <20220920135332.153732-3-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1664621555; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=FazZwi9+vchJ1IhecpVy/1d0o6XWg3wLlB6Khecxntw=;
        b=mq/PpQf3243m9KwqOgtPw3y0y36PgAnXI9yxIi8wTO+JZRtiVxMSMXKiv49x+5NdNWTnx+
        TzIankwDUZXGLttfYhHGW2kWPZHc0NvC0flQOouwhVJGTm+w8jsRv/gwTz1rT8KRZB/v4r
        EMMrObklOxXMpIkLnpAnkHPjz1zHQkw=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1664621555;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=FazZwi9+vchJ1IhecpVy/1d0o6XWg3wLlB6Khecxntw=;
        b=z5ND651ISKlt4Dgbgk3KV/r/P0Y6atsZPlFQbVLRiTy7PtzzBXC8kqCBoaBAvWm+k7LlHw
        TTAbjjCMz/8fDABw==
Content-Disposition: inline
In-Reply-To: <20220920135332.153732-3-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com

Apologies for the late response. I got tied up at work.

On Tue, Sep 20, 2022 at 04:53:29PM +0300, Julian Anastasov wrote:
> +/* Start estimation for stats */
> +int ip_vs_start_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats)
> +{
> +	struct ip_vs_estimator *est = &stats->est;
> +	int ret;
> +
> +	/* Get rlimit only from process that adds service, not from
> +	 * net_init/kthread. Clamp limit depending on est->ktid size.
> +	 */
> +	if (!ipvs->est_max_threads && ipvs->enable)
> +		ipvs->est_max_threads = min_t(unsigned long,
> +					      rlimit(RLIMIT_NPROC), SHRT_MAX);

For example, the user space limit on the number of processes does not hold any useful value on my testing machine:
# ulimit -u
254318
while /proc/sys/kernel/pid_max is 65536. The pid_max variable itself depends on the number of CPUs on the system. I also think that user space limits should not directly determine how many kthreads can be created by the kernel. By design, one fully loaded kthread will take up 12% of the CPU time on one CPU. On account of the CPU usage it does not make sense to set ipvs->est_max_threads to a value higher than a multiple (4 or less) of the number of possible CPUs in the system. I think the ipvs->est_max_threads value should not allow CPUs to get saturated. Also, kthreads computing IPVS rate estimates could be created in each net namespace on the system, which alone makes it possible to saturate all the CPUs on the system because ipvs->est_max_threads does not take other namespaces into accou
 nt.
As for solutions to this problem, I think it would be easiest to implement global counters in ip_vs_est.c (est_kt_count and est_max_threads) that would be tested for the max number of allocated kthreads in ip_vs_est_add_kthread().
Another possible solution would be to share kthreads among all net namespaces but that would be a step back considering that the current implementation is per net namespace. For the purpose of computing estimates, it does not really matter to which namespace an estimator belongs. This solution is problematic with regards to resource control - cgroups. But from what I have seen, IPVS estimators were always configured in the init net namespace so it would not matter if the kthreads were shared among all net namespaces.

> +
> +	est->ktid = -1;
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
> +

> +/* Calculate limits for all kthreads */
> +static int ip_vs_est_calc_limits(struct netns_ipvs *ipvs, int *chain_max_len)

I am not happy about all the dynamic allocation happening in this function, which introduces a reason why the function could fail. A simpler approach would use just the estimators that are currently available on ipvs->est_temp_list and run ip_vs_chain_estimation(&chain) in a loop to reach ntest estimators being processed. The rate estimates would need to be reset after the tests are done. When kthread 0 enters calc phase there may very well be only two estimators on ipvs->est_temp_list. Are there any testing results indicating that newly allocated estimators give different results compared to processing the est_temp_list estimators in a loop?

When est_temp_list estimators are processed in a loop the estimator objects will be cached, possibly even in caches above the last level cache, and the per CPU counters will be cached. Annotated disassembly from perf profiling with the bus-cycles event (tested on the v2 of the patchset) indicates that the majority of time in ip_vs_estimation_kthread() is spent on the first instruction that reads a per CPU counter value, i.e.
hlist_for_each_entry_rcu(e, chain, list) {
      for_each_possible_cpu(i) {
              c = per_cpu_ptr(s->cpustats, i);
              do {
                      conns = c->cnt.conns;
the disassembly:
 Percent |      Source code & Disassembly of kcore for bus-cycles (13731 samples, percent: local period)
         :   ffffffffc0f34880 <ip_vs_estimation_kthread>:
...
    0.91 :   ffffffffc0f349ed:       cltq
    0.00 :   ffffffffc0f349ef:       mov    0x68(%rbx),%rsi
    3.35 :   ffffffffc0f349f3:       add    -0x71856520(,%rax,8),%rsi
    1.03 :   ffffffffc0f349fb:       add    (%rsi),%r15
   76.52 :   ffffffffc0f349fe:       add    0x8(%rsi),%r14
    4.52 :   ffffffffc0f34a02:       add    0x10(%rsi),%r13
    1.59 :   ffffffffc0f34a06:       add    0x18(%rsi),%r12
    1.44 :   ffffffffc0f34a0a:       add    0x20(%rsi),%rbp
    1.64 :   ffffffffc0f34a0e:       add    $0x1,%ecx
    0.47 :   ffffffffc0f34a11:       xor    %r9d,%r9d
    0.65 :   ffffffffc0f34a14:       xor    %r8d,%r8d
    1.12 :   ffffffffc0f34a17:       movslq %ecx,%rcx
    1.29 :   ffffffffc0f34a1a:       xor    %esi,%esi
    0.66 :   ffffffffc0f34a1c:       mov    $0xffffffff8ecd5760,%rdi
    0.42 :   ffffffffc0f34a23:       call   0xffffffff8d75edc0
    0.53 :   ffffffffc0f34a28:       mov    -0x3225ec9e(%rip),%edx        # 0xffffffff8ecd5d90
    0.74 :   ffffffffc0f34a2e:       mov    %eax,%ecx
    0.78 :   ffffffffc0f34a30:       cmp    %eax,%edx
    0.00 :   ffffffffc0f34a32:       ja     0xffffffffc0f349ed
The bus-cycles event allows a skid so the high percentage of samples is actually on ffffffffc0f349fb. The performance of instructions reading per CPU counter values strongly depends on node-to-node latency on NUMA machines. The disassembly above is from a test on a 4 NUMA node machine but 2 NUMA node machines give similar results.

Even the currently used solution loads parts of the estimator objects into the cache before gets to ip_vs_chain_estimation() run, see comments below. Whether or not est_temp_list estimators can be used depends whether node-to-node latency for the per CPU counters on NUMA machines disappears after the first loads.

I ran tests using est_temp_list estimators. I applied this diff over the v4 code:
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index e214aa0b3abe..f96fb273a4b3 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -638,6 +638,11 @@ static int ip_vs_est_calc_limits(struct netns_ipvs *ipvs, int *chain_max_len)
        int retry = 0;
        int max = 2;
        int ret = 1;
+       int nodes = 0;
+
+       hlist_for_each_entry(est, &ipvs->est_temp_list, list)
+               ++nodes;
+       pr_info("calc: nodes %d\n", nodes);

        INIT_HLIST_HEAD(&chain);
        for (;;) {
@@ -688,7 +693,10 @@ static int ip_vs_est_calc_limits(struct netns_ipvs *ipvs, int *chain_max_len)
                }
                rcu_read_lock();
                t1 = ktime_get();
-               ip_vs_chain_estimation(&chain);
+               j = 0;
+               do
+                       ip_vs_chain_estimation(&ipvs->est_temp_list);
+               while (++j < ntest / nodes);
                t2 = ktime_get();
                rcu_read_unlock();

@@ -711,6 +719,8 @@ static int ip_vs_est_calc_limits(struct netns_ipvs *ipvs, int *chain_max_len)
                                max = 1;
                        }
                }
+               pr_info("calc: diff %lld ntest %d min_est %d max %d\n",
+                       diff, ntest, min_est, max);
                /* aim is to test below 100us */
                if (diff < 50 * NSEC_PER_USEC)
                        ntest *= 2;

For using est_temp_list estimators, the kernel log showed:
[   89.364408][  T493] IPVS: starting estimator thread 0...
[   89.370467][ T8039] IPVS: calc: nodes 2
[   89.374824][ T8039] IPVS: calc: diff 4354 ntest 1 min_est 4354 max 21
[   89.382081][ T8039] IPVS: calc: diff 1125 ntest 2 min_est 562 max 169
[   89.389329][ T8039] IPVS: calc: diff 2083 ntest 4 min_est 520 max 182
[   89.396589][ T8039] IPVS: calc: diff 4102 ntest 8 min_est 512 max 185
[   89.403868][ T8039] IPVS: calc: diff 8381 ntest 16 min_est 512 max 185
[   89.411288][ T8039] IPVS: calc: diff 16519 ntest 32 min_est 512 max 185
[   89.418913][ T8039] IPVS: calc: diff 34162 ntest 64 min_est 512 max 185
[   89.426705][ T8039] IPVS: calc: diff 65121 ntest 128 min_est 508 max 187
[   89.434238][ T8039] IPVS: calc: chain_max_len=187, single est=508ns, diff=65121, retry=1, ntest=128
[   89.444494][ T8039] IPVS: dequeue: 492ns
[   89.448906][ T8039] IPVS: using max 8976 ests per chain, 448800 per kthread
[   91.308814][ T8039] IPVS: tick time: 5745ns for 64 CPUs, 2 ests, 1 chains, chain_max_len=8976

I added just the second pr_info() to the v4 of the patchset, the kernel log showed:
[  115.823618][  T491] IPVS: starting estimator thread 0...
[  115.829696][ T8005] IPVS: calc: diff 1228 ntest 1 min_est 1228 max 77
[  115.836962][ T8005] IPVS: calc: diff 1391 ntest 2 min_est 695 max 136
[  115.844220][ T8005] IPVS: calc: diff 2135 ntest 4 min_est 533 max 178
[  115.851481][ T8005] IPVS: calc: diff 4022 ntest 8 min_est 502 max 189
[  115.858762][ T8005] IPVS: calc: diff 8017 ntest 16 min_est 501 max 189
[  115.866185][ T8005] IPVS: calc: diff 15821 ntest 32 min_est 494 max 192
[  115.873795][ T8005] IPVS: calc: diff 31726 ntest 64 min_est 494 max 192
[  115.881599][ T8005] IPVS: calc: diff 68796 ntest 128 min_est 494 max 192
[  115.889133][ T8005] IPVS: calc: chain_max_len=192, single est=494ns, diff=68796, retry=1, ntest=128
[  115.899363][ T8005] IPVS: dequeue: 245ns
[  115.903788][ T8005] IPVS: using max 9216 ests per chain, 460800 per kthread
[  117.767174][ T8005] IPVS: tick time: 6117ns for 64 CPUs, 2 ests, 1 chains, chain_max_len=9216

I rigged the v4 code to iterate in the for loop until krealloc_array() reports an error. This allowed me to record a profile with the bus-cycles event:
[ 4115.532161][ T3537] IPVS: starting estimator thread 0...
[ 4116.969559][ T8126] IPVS: calc: chain_max_len=233, single est=407ns, diff=53822, retry=4095, ntest=128
[ 4117.077102][ T8126] IPVS: dequeue: 760ns
[ 4117.081525][ T8126] IPVS: using max 11184 ests per chain, 559200 per kthread
[ 4119.053120][ T8126] IPVS: tick time: 8406ns for 64 CPUs, 2 ests, 1 chains, chain_max_len=11184
The profile:
# Samples: 6K of event 'bus-cycles'
# Event count (approx.): 35207766
# Overhead  Command          Shared Object             Symbol
    26.69%  ipvs-e:0:0       [kernel.kallsyms]         [k] memset_erms
    21.40%  ipvs-e:0:0       [kernel.kallsyms]         [k] _find_next_bit
    11.96%  ipvs-e:0:0       [kernel.kallsyms]         [k] ip_vs_chain_estimation
     6.30%  ipvs-e:0:0       [kernel.kallsyms]         [k] pcpu_alloc
     4.29%  ipvs-e:0:0       [kernel.kallsyms]         [k] mutex_lock_killable
     2.89%  ipvs-e:0:0       [kernel.kallsyms]         [k] ip_vs_estimation_kthread
     2.84%  ipvs-e:0:0       [kernel.kallsyms]         [k] __slab_free
     2.52%  ipvs-e:0:0       [kernel.kallsyms]         [k] pcpu_next_md_free_region
The disassembly of ip_vs_chain_estimation (not inlined in v4 code):
         :   ffffffffc0ce3a40 <ip_vs_chain_estimation>:
    5.78 :   ffffffffc0ce3a87:       cltq
    0.00 :   ffffffffc0ce3a89:       mov    0x68(%rbx),%rsi
    0.44 :   ffffffffc0ce3a8d:       add    -0x43054520(,%rax,8),%rsi
    0.00 :   ffffffffc0ce3a95:       add    (%rsi),%r14
   65.20 :   ffffffffc0ce3a98:       add    0x8(%rsi),%r15
    8.89 :   ffffffffc0ce3a9c:       add    0x10(%rsi),%r13
    5.18 :   ffffffffc0ce3aa0:       add    0x18(%rsi),%r12
    6.96 :   ffffffffc0ce3aa4:       add    0x20(%rsi),%rbp
    3.55 :   ffffffffc0ce3aa8:       add    $0x1,%ecx
    0.00 :   ffffffffc0ce3aab:       xor    %r9d,%r9d
    0.00 :   ffffffffc0ce3aae:       xor    %r8d,%r8d
    0.00 :   ffffffffc0ce3ab1:       movslq %ecx,%rcx
    0.30 :   ffffffffc0ce3ab4:       xor    %esi,%esi
    0.44 :   ffffffffc0ce3ab6:       mov    $0xffffffffbd4d6420,%rdi
    0.44 :   ffffffffc0ce3abd:       callq  0xffffffffbbf5ef20
    0.30 :   ffffffffc0ce3ac2:       mov    -0x380d078(%rip),%edx        # 0xffffffffbd4d6a50
    0.00 :   ffffffffc0ce3ac8:       mov    %eax,%ecx
    0.00 :   ffffffffc0ce3aca:       cmp    %eax,%edx
    0.00 :   ffffffffc0ce3acc:       ja     0xffffffffc0ce3a87

I did the same for my version using est_temp_list estimators:
[  268.250061][ T3494] IPVS: starting estimator thread 0...
[  268.256118][ T7983] IPVS: calc: nodes 2
[  269.656713][ T7983] IPVS: calc: chain_max_len=230, single est=412ns, diff=55492, retry=4095, ntest=128
[  269.763749][ T7983] IPVS: dequeue: 810ns
[  269.768171][ T7983] IPVS: using max 11040 ests per chain, 552000 per kthread
[  271.739763][ T7983] IPVS: tick time: 7376ns for 64 CPUs, 2 ests, 1 chains, chain_max_len=11040
The profile:
# Samples: 6K of event 'bus-cycles'
# Event count (approx.): 34135939
# Overhead  Command          Shared Object             Symbol
    26.86%  ipvs-e:0:0       [kernel.kallsyms]         [k] memset_erms
    20.74%  ipvs-e:0:0       [kernel.kallsyms]         [k] _find_next_bit
    12.11%  ipvs-e:0:0       [kernel.kallsyms]         [k] ip_vs_chain_estimation
     6.05%  ipvs-e:0:0       [kernel.kallsyms]         [k] pcpu_alloc
     4.02%  ipvs-e:0:0       [kernel.kallsyms]         [k] mutex_lock_killable
     2.81%  ipvs-e:0:0       [kernel.kallsyms]         [k] __slab_free
     2.63%  ipvs-e:0:0       [kernel.kallsyms]         [k] ip_vs_estimation_kthread
     2.25%  ipvs-e:0:0       [kernel.kallsyms]         [k] pcpu_next_md_free_region
The disassembly of ip_vs_chain_estimation (not inlined in v4 code):
         : 5                ffffffffc075aa40 <ip_vs_chain_estimation>:
    4.99 :   ffffffffc075aa87:       cltq
    0.00 :   ffffffffc075aa89:       mov    0x68(%rbx),%rsi
    0.00 :   ffffffffc075aa8d:       add    -0x48054520(,%rax,8),%rsi
    0.15 :   ffffffffc075aa95:       add    (%rsi),%r14
   65.92 :   ffffffffc075aa98:       add    0x8(%rsi),%r15
   10.11 :   ffffffffc075aa9c:       add    0x10(%rsi),%r13
    6.49 :   ffffffffc075aaa0:       add    0x18(%rsi),%r12
    6.33 :   ffffffffc075aaa4:       add    0x20(%rsi),%rbp
    3.60 :   ffffffffc075aaa8:       add    $0x1,%ecx
    0.00 :   ffffffffc075aaab:       xor    %r9d,%r9d
    0.00 :   ffffffffc075aaae:       xor    %r8d,%r8d
    0.00 :   ffffffffc075aab1:       movslq %ecx,%rcx
    0.15 :   ffffffffc075aab4:       xor    %esi,%esi
    0.45 :   ffffffffc075aab6:       mov    $0xffffffffb84d6420,%rdi
    0.91 :   ffffffffc075aabd:       callq  0xffffffffb6f5ef20
    0.00 :   ffffffffc075aac2:       mov    -0x8284078(%rip),%edx        # 0xffffffffb84d6a50
    0.00 :   ffffffffc075aac8:       mov    %eax,%ecx
    0.00 :   ffffffffc075aaca:       cmp    %eax,%edx
    0.00 :   ffffffffc075aacc:       ja     0xffffffffc075aa87

In both cases, these are results from a second test. The command were:
modprobe ip_vs; perf record -e bus-cycles -a sleep 2 & ipvsadm -A -t 10.10.10.1:2000
ipvsadm -D -t 10.10.10.1:2000; modprobe -r ip_vs_wlc ip_vs
modprobe ip_vs; perf record -e bus-cycles -a sleep 2 & ipvsadm -A -t 10.10.10.1:2000
The kernel log from the first tests contains a warning printed by krealloc_array() because the requested size exceeds the object size that SLUB is able to allocate.

Both the chain_max_len and the profiles (and instructions taking the most time) from the test using est_temp_list estimators are similar to the test with the v4 code. In other words, there is no observable difference between the test using est_temp_list estimators and allocating new estimators in my tests (the machine has 64 CPUs and 2 NUMA nodes). Allocating new estimators in ip_vs_est_calc_limits() seems unnecessary.

> +{
> +	struct ip_vs_stats **arr = NULL, **a, *s;
> +	struct ip_vs_estimator *est;
> +	int i, j, n = 0, ntest = 1;
> +	struct hlist_head chain;
> +	bool is_fifo = false;
> +	s32 min_est = 0;
> +	ktime_t t1, t2;
> +	s64 diff, val;
> +	int retry = 0;
> +	int max = 2;
> +	int ret = 1;
> +
> +	INIT_HLIST_HEAD(&chain);
> +	for (;;) {
> +		/* Too much tests? */
> +		if (n >= 128)
> +			goto out;
> +
> +		/* Dequeue old estimators from chain to avoid CPU caching */
> +		for (;;) {
> +			est = hlist_entry_safe(chain.first,
> +					       struct ip_vs_estimator,
> +					       list);
> +			if (!est)
> +				break;
> +			hlist_del_init(&est->list);

Unlinking every estimator seems unnecessary - they are discarded before the function exits.

> +		}
> +
> +		/* Use only new estimators for test */
> +		a = krealloc_array(arr, n + ntest, sizeof(*arr), GFP_KERNEL);
> +		if (!a)
> +			goto out;
> +		arr = a;
> +
> +		for (j = 0; j < ntest; j++) {
> +			arr[n] = kcalloc(1, sizeof(*arr[n]), GFP_KERNEL);
> +			if (!arr[n])
> +				goto out;
> +			s = arr[n];
> +			n++;
> +
> +			spin_lock_init(&s->lock);

This statement loads part of the estimator object into the CPU cache.

> +			s->cpustats = alloc_percpu(struct ip_vs_cpu_stats);

I am not sure whether part of the allocated object is loaded into the cache of each CPU as a side effect of alloc_percpu(). Assigning to s->cpustats is another store into the estimator object but it probably is the same cache line as s->lock.

> +			if (!s->cpustats)
> +				goto out;
> +			for_each_possible_cpu(i) {
> +				struct ip_vs_cpu_stats *cs;
> +
> +				cs = per_cpu_ptr(s->cpustats, i);
> +				u64_stats_init(&cs->syncp);

This statement is most probably optimized out on 64bit archs so no caching happens here.

> +			}
> +			hlist_add_head(&s->est.list, &chain);

This statement loads part of the estimator object into the CPU cache. And who know what the HW prefetcher does because of the accesses to the estimator object.

> +		}
> +
> +		cond_resched();
> +		if (!is_fifo) {
> +			is_fifo = true;
> +			sched_set_fifo(current);
> +		}
> +		rcu_read_lock();

I suggest disabling preemption and interrupts on the local CPU. To get the minimal time need to process an estimator there is no need for interference from interrupt processing or context switches in this specific part of the code.

> +		t1 = ktime_get();
> +		ip_vs_chain_estimation(&chain);
> +		t2 = ktime_get();
> +		rcu_read_unlock();
> +
> +		if (!ipvs->enable || kthread_should_stop())
> +			goto stop;
> +
> +		diff = ktime_to_ns(ktime_sub(t2, t1));
> +		if (diff <= 1 || diff >= NSEC_PER_SEC)

What is the reason for the diff <= 1? Is it about the CLOCK_MONOTONIC time source not incrementing?

> +			continue;
> +		val = diff;
> +		do_div(val, ntest);
> +		if (!min_est || val < min_est) {
> +			min_est = val;
> +			/* goal: 95usec per chain */
> +			val = 95 * NSEC_PER_USEC;
> +			if (val >= min_est) {
> +				do_div(val, min_est);
> +				max = (int)val;
> +			} else {
> +				max = 1;
> +			}
> +		}
> +		/* aim is to test below 100us */
> +		if (diff < 50 * NSEC_PER_USEC)
> +			ntest *= 2;
> +		else
> +			retry++;
> +		/* Do at least 3 large tests to avoid scheduling noise */
> +		if (retry >= 3)
> +			break;
> +	}
> +
> +out:
> +	if (is_fifo)
> +		sched_set_normal(current, 0);
> +	for (;;) {
> +		est = hlist_entry_safe(chain.first, struct ip_vs_estimator,
> +				       list);
> +		if (!est)
> +			break;
> +		hlist_del_init(&est->list);
> +	}
> +	for (i = 0; i < n; i++) {
> +		free_percpu(arr[i]->cpustats);
> +		kfree(arr[i]);
> +	}
> +	kfree(arr);
> +	*chain_max_len = max;
> +	return ret;
> +
> +stop:
> +	ret = 0;
> +	goto out;
> +}
> +
> +/* Calculate the parameters and apply them in context of kt #0
> + * ECP: est_calc_phase
> + * ECML: est_chain_max_len
> + * ECP	ECML	Insert Chain	enable	Description
> + * ---------------------------------------------------------------------------
> + * 0	0	est_temp_list	0	create kt #0 context
> + * 0	0	est_temp_list	0->1	service added, start kthread #0 task
> + * 0->1	0	est_temp_list	1	kt task #0 started, enters calc phase
> + * 1	0	est_temp_list	1	kt #0: determine est_chain_max_len,
> + *					stop tasks, move ests to est_temp_list
> + *					and free kd for kthreads 1..last
> + * 1->0	0->N	kt chains	1	ests can go to kthreads
> + * 0	N	kt chains	1	drain est_temp_list, create new kthread
> + *					contexts, start tasks, estimate
> + */
> +static void ip_vs_est_calc_phase(struct netns_ipvs *ipvs)
> +{
> +	int genid = atomic_read(&ipvs->est_genid);
> +	struct ip_vs_est_tick_data *td;
> +	struct ip_vs_est_kt_data *kd;
> +	struct ip_vs_estimator *est;
> +	struct ip_vs_stats *stats;
> +	int chain_max_len;
> +	int id, row, cid;
> +	bool last, last_td;
> +	int step;
> +
> +	if (!ip_vs_est_calc_limits(ipvs, &chain_max_len))
> +		return;
> +
> +	mutex_lock(&__ip_vs_mutex);
> +
> +	/* Stop all other tasks, so that we can immediately move the
> +	 * estimators to est_temp_list without RCU grace period
> +	 */
> +	mutex_lock(&ipvs->est_mutex);
> +	for (id = 1; id < ipvs->est_kt_count; id++) {
> +		/* netns clean up started, abort */
> +		if (!ipvs->enable)
> +			goto unlock2;
> +		kd = ipvs->est_kt_arr[id];
> +		if (!kd)
> +			continue;
> +		ip_vs_est_kthread_stop(kd);
> +	}
> +	mutex_unlock(&ipvs->est_mutex);
> +
> +	/* Move all estimators to est_temp_list but carefully,
> +	 * all estimators and kthread data can be released while
> +	 * we reschedule. Even for kthread 0.
> +	 */
> +	step = 0;
> +
> +next_kt:
> +	/* Destroy contexts backwards */
> +	id = ipvs->est_kt_count - 1;
> +	if (id < 0)
> +		goto end_dequeue;
> +	kd = ipvs->est_kt_arr[id];
> +	if (!kd)
> +		goto end_dequeue;
> +	/* kt 0 can exist with empty chains */
> +	if (!id && kd->est_count <= 1)
> +		goto end_dequeue;
> +
> +	row = -1;
> +
> +next_row:
> +	row++;
> +	if (row >= IPVS_EST_NTICKS)
> +		goto next_kt;
> +	if (!ipvs->enable)
> +		goto unlock;
> +	td = rcu_dereference_protected(kd->ticks[row], 1);
> +	if (!td)
> +		goto next_row;
> +
> +	cid = 0;
> +
> +walk_chain:
> +	if (kthread_should_stop())
> +		goto unlock;
> +	step++;
> +	if (!(step & 63)) {
> +		/* Give chance estimators to be added (to est_temp_list)
> +		 * and deleted (releasing kthread contexts)
> +		 */
> +		mutex_unlock(&__ip_vs_mutex);
> +		cond_resched();
> +		mutex_lock(&__ip_vs_mutex);

Is there any data backing the decision to cond_resched() here? What non-functional requirement were used to make this design decision?

> +
> +		/* Current kt released ? */
> +		if (id + 1 != ipvs->est_kt_count)
> +			goto next_kt;
> +		if (kd != ipvs->est_kt_arr[id])
> +			goto end_dequeue;
> +		/* Current td released ? */
> +		if (td != rcu_dereference_protected(kd->ticks[row], 1))
> +			goto next_row;
> +		/* No fatal changes on the current kd and td */
> +	}
> +	est = hlist_entry_safe(td->chains[cid].first, struct ip_vs_estimator,
> +			       list);
> +	if (!est) {
> +		cid++;
> +		if (cid >= IPVS_EST_TICK_CHAINS)
> +			goto next_row;
> +		goto walk_chain;
> +	}
> +	/* We can cheat and increase est_count to protect kt 0 context
> +	 * from release but we prefer to keep the last estimator
> +	 */
> +	last = kd->est_count <= 1;
> +	/* Do not free kt #0 data */
> +	if (!id && last)
> +		goto end_dequeue;
> +	last_td = kd->tick_len[row] <= 1;
> +	stats = container_of(est, struct ip_vs_stats, est);
> +	ip_vs_stop_estimator(ipvs, stats);
> +	/* Tasks are stopped, move without RCU grace period */
> +	est->ktid = -1;
> +	hlist_add_head(&est->list, &ipvs->est_temp_list);
> +	/* kd freed ? */
> +	if (last)
> +		goto next_kt;
> +	/* td freed ? */
> +	if (last_td)
> +		goto next_row;
> +	goto walk_chain;
> +
> +end_dequeue:
> +	/* All estimators removed while calculating ? */
> +	if (!ipvs->est_kt_count)
> +		goto unlock;
> +	kd = ipvs->est_kt_arr[0];
> +	if (!kd)
> +		goto unlock;
> +	ipvs->est_chain_max_len = chain_max_len;
> +	ip_vs_est_set_params(ipvs, kd);
> +
> +	pr_info("using max %d ests per chain, %d per kthread\n",
> +		kd->chain_max_len, kd->est_max_count);
> +
> +	mutex_lock(&ipvs->est_mutex);
> +
> +	/* We completed the calc phase, new calc phase not requested */
> +	if (genid == atomic_read(&ipvs->est_genid))
> +		ipvs->est_calc_phase = 0;
> +
> +unlock2:
> +	mutex_unlock(&ipvs->est_mutex);
> +
> +unlock:
> +	mutex_unlock(&__ip_vs_mutex);
>  }

-- 
Jiri Wiesner
SUSE Labs
