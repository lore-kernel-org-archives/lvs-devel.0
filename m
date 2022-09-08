From: Julian Anastasov <ja@ssi.bg>
Subject: [RFC PATCHv2 0/4] ipvs: Use kthreads for stats
Date: Fri,  9 Sep 2022 01:21:05 +0300
Message-ID: <20220908222109.147452-1-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Jiri Wiesner <jwiesner@suse.de>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com

	Hello,

	This patchset implements stats estimation in
kthread context. Simple tests do not show any problem.

	As it is late here, I'm sending v2 for
review. It is interesting to know what value for
IPVS_EST_TICK_CHAINS to use, it is used for the
IPVS_EST_MAX_COUNT calculation. We should determine
it from tests once the loops are in final form.
Now the limit increased a little bit to 38400.
Tomorrow I'll check again the patches for possible
problems.

	Overview of the basic concepts. More in the
commit messages...

RCU Locking:

- As stats are now RCU-locked, tot_stats, svc and dest which
hold estimator structures are now always freed from RCU
callback. This ensures RCU grace period after the
ip_vs_stop_estimator() call.

Kthread data:

- every kthread works over its own data structure and all
such structures are attached to array

- even while there can be a kthread structure, its task
may not be running, eg. before first service is added or
while the sysctl var is set to an empty cpulist or
when run_estimation is 0.

- a task and its structure may be released if all
estimators are unlinked from its chains, leaving the
slot in the array empty

- every kthread data structure allows limited number
of estimators

- to add new estimators we use the last added kthread
context (est_add_ktid). The new estimators are linked to
the chains just before the estimated one, based on add_row.
This ensures their estimation will start after 2 seconds.
If estimators are added in bursts, common case if all
services and dests are initially configured, we may
spread the estimators to more chains. This will reduce
the chain imbalance.

Not done yet:
* limit for kthreads (sysctl var)

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

Julian Anastasov (4):
  ipvs: add rcu protection to stats
  ipvs: use kthreads for stats estimation
  ipvs: add est_cpulist and est_nice sysctl vars
  ipvs: run_estimation should control the kthread tasks

 Documentation/networking/ipvs-sysctl.rst |  24 +-
 include/net/ip_vs.h                      | 122 +++++-
 net/netfilter/ipvs/ip_vs_core.c          |  10 +-
 net/netfilter/ipvs/ip_vs_ctl.c           | 367 +++++++++++++++---
 net/netfilter/ipvs/ip_vs_est.c           | 450 +++++++++++++++++++----
 5 files changed, 843 insertions(+), 130 deletions(-)

-- 
2.37.3


