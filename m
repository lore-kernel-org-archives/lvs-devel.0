From: Julian Anastasov <ja@ssi.bg>
Subject: [RFC PATCHv5 0/6] ipvs: Use kthreads for stats
Date: Sun,  9 Oct 2022 18:37:04 +0300
Message-ID: <20221009153710.125919-1-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Jiri Wiesner <jwiesner@suse.de>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com

	Hello,

	Posting v5 (no new ideas for now). New patch
inserted at 2nd position. Patch 6 just for debugging,
do not apply if not needed. 

	This patchset implements stats estimation in
kthread context. Simple tests do not show any problem.
If testing, check that calculated chain_max does not
deviates much. 

	cache_factor = 4 needs to be tested with different
configurations. Now ip_vs_est_calc_limits() is simpler.
BH locking is used, IRQ locking looks dangerous to me,
it can hurt systems that do not have TSC clocksource,
not sure if that can affect ktime.

	Overview of the basic concepts. More in the
commit messages...

RCU Locking:

- As stats are now RCU-locked, tot_stats, svc and dest which
hold estimator structures are now always freed from RCU
callback. This ensures RCU grace period after the
ip_vs_stop_estimator() call.

Kthread data:

- every kthread works over its own data structure and all
such structures are attached to array. For now we
apply a rlimit as max kthreads to create.

- even while there can be a kthread structure, its task
may not be running, eg. before first service is added or
while the sysctl var is set to an empty cpulist or
when run_estimation is 0.

- the allocated kthread context may grow from 1 to 50
allocated structures for ticks which saves memory for
setups with small number of estimators

- a task and its structure may be released if all
estimators are unlinked from its chains, leaving the
slot in the array empty

- every kthread data structure allows limited number
of estimators. Kthread 0 is also used to initially
calculate the number of estimators to allow in every
chain considering a sub-100 microsecond cond_resched
rate. This number can be from 1 to hundreds.

- kthread 0 has an additional job of optimizing the
adding of estimators: they are first added in
temp list (est_temp_list) and later kthread 0
distributes them to other kthreads. The optimization
is based on the fact that newly added estimator
should be estimated after 2 seconds, so we have the
time to offload the adding to chain from controlling
process to kthread 0.

- to add new estimators we use the last added kthread
context (est_add_ktid). The new estimators are linked to
the chains just before the estimated one, based on add_row.
This ensures their estimation will start after 2 seconds.
If estimators are added in bursts, common case if all
services and dests are initially configured, we may
spread the estimators to more chains. This will reduce
the chain imbalance.

	There are things that I don't like but for now
I don't have a better idea for them:

- calculation of chain_max can go wrong, depending
on the current load, CPU speed, memory speeds, running in
VM, whether tested estimators are in CPU cache, even if
we are doing it in SCHED_FIFO mode or with BH disabled.
I expect such noise to be insignificant but who knows.

- ip_vs_stop_estimator is not a simple unlinking of
list node, we spend cycles to account for the removed
estimator

- __ip_vs_mutex is global mutex for all netns. But it
protects hash tables that are still global ones.


Changes in v5:
Patch 4 (was 3 in v4):
* use ip_vs_est_max_threads() helper
Patch 3 (was 2 in v4):
* kthread 0 now disables BH instead of using SCHED_FIFO mode,
  this should work because now we perform less number of repeated
  test over pre-allocated kd->calc_stats structure. Use
  cache_factor = 4 to approximate the time non-cached (due to large
  number) per-cpu stats are estimated compared to the cached data
  we estimate in calc phase. This needs to be tested with
  different number of CPUs and NUMA nodes.
* limit max threads using the formula 4 * Number of CPUs, not on rlimit
* remove _len suffix from vars like chain_max_len, tick_max_len,
  est_chain_max_len
Patch 2:
* new patch that adds functions for stats allocations

Changes in v4:
Patch 2:
* kthread 0 can start with calculation phase in SCHED_FIFO mode
  to determine chain_max_len suitable for 100us cond_resched
  rate and 12% of 40ms CPU usage in a tick. Current value of
  IPVS_EST_TICK_CHAINS=48 determines tick time of 4.8ms (i.e.
  in units of 100us) which is 12% of max tick time of 40ms.
  The question is how reliable will be such calculation test.
* est_calc_phase indicates a mode where we dequeue estimators
  from kthreads, apply new chain_max_len and enqueue again
  all estimators to kthreads, done by kthread 0
* est->ktid now can be -1 to indicate est is in est_temp_list
  ready to be distributed to kthread by kt 0, done in
  ip_vs_est_drain_temp_list(). kthread 0 data is now released
  only after the data for others kthreads
* ip_vs_start_estimator was not setting ret = 0
* READ_ONCE not needed for volatile jiffies
Patch 3:
* restrict cpulist based on the cpus_allowed of
  process that assigns cpulist, not on cpu_possible_mask
* change of cpulist will trigger calc phase
Patch 5:
* print message every minute, not 2 seconds

Changes in v3:
Patch 2:
* calculate chain_max_len (was IPVS_EST_CHAIN_DEPTH) but
  it needs further tuning based on real estimation test
* est_max_threads set from rlimit(RLIMIT_NPROC). I don't
  see analog to get_ucounts_value() to get the max value.
* the atomic bitop for td->present is not needed,
  remove it
* start filling based on est_row after 2 ticks are
  fully allocated. As 2/50 is 4% this can be increased
  more.

Changes in v2:
Patch 2:
* kd->mutex is gone, cond_resched rate determined by
  IPVS_EST_CHAIN_DEPTH
* IPVS_EST_MAX_COUNT is a hard limit now
* kthread data is now 1-50 allocated tick structures,
  each containing heads for limited chains. Bitmaps
  should allow faster access. We avoid large
  allocations for structs.
* as the td->present bitmap is shared, use atomic bitops
* ip_vs_start_estimator now returns error code
* _bh locking removed from stats->lock
* bump arg is gone from ip_vs_est_reload_start
* prepare for upcoming changes that remove _irq
  from u64_stats_fetch_begin_irq/u64_stats_fetch_retry_irq
* est_add_ktid is now always valid
Patch 3:
* use .. in est_nice docs

Julian Anastasov (6):
  ipvs: add rcu protection to stats
  ipvs: use common functions for stats allocation
  ipvs: use kthreads for stats estimation
  ipvs: add est_cpulist and est_nice sysctl vars
  ipvs: run_estimation should control the kthread tasks
  ipvs: debug the tick time

 Documentation/networking/ipvs-sysctl.rst |  24 +-
 include/net/ip_vs.h                      | 144 +++-
 net/netfilter/ipvs/ip_vs_core.c          |  10 +-
 net/netfilter/ipvs/ip_vs_ctl.c           | 442 +++++++++---
 net/netfilter/ipvs/ip_vs_est.c           | 862 +++++++++++++++++++++--
 5 files changed, 1320 insertions(+), 162 deletions(-)

-- 
2.37.3


