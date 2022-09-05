From: "dust.li" <dust.li@linux.alibaba.com>
Subject: Re: [RFC PATCH 0/4] Use kthreads for stats
Date: Mon, 5 Sep 2022 14:34:06 +0800
Message-ID: <20220905063406.GA108825@linux.alibaba.com>
References: <20220827174154.220651-1-ja@ssi.bg>
Reply-To: dust.li@linux.alibaba.com
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20220827174154.220651-1-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>, Jiri Wiesner <jwiesner@suse.de>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, yunhjiang@ebay.com, tangyang@zhihu.com

On Sat, Aug 27, 2022 at 08:41:50PM +0300, Julian Anastasov wrote:
>	Hello,
>
>	This patchset implements stats estimation in
>kthread context. Simple tests do not show any problem.
>Please review, comment, test, etc.

Hi, Julian:

Thanks a lot for your work! I tested the patchset, until now, it all
works well.

On my test server with 64 CPUs and 1 million rules. The total
CPU cost of all ipvs kthreads is about 67% of 1 CPU(31 ipvs threads).
No ping slow detected.

Tested-by: Dust Li <dust.li@linux.alibaba.com>

>
>	Overview of the basic concepts. More in the
>commit messages...
>
>RCU Locking:
>
>- when RCU preemption is enabled the kthreads use just RCU
>lock for walking the chains and we do not need to reschedule.
>May be this is the common case for distribution kernels.
>In this case ip_vs_stop_estimator() is completely lockless.
>
>- when RCU preemption is not enabled, we reschedule by using
>refcnt for every estimator to track if the currently removed
>estimator is used at the same time by kthread for estimation.
>As RCU lock is unlocked during rescheduling, the deletion
>should wait kd->mutex, so that a new RCU lock is applied
>before the estimator is freed with RCU callback.
>
>- As stats are now RCU-locked, tot_stats, svc and dest which
>hold estimator structures are now always freed from RCU
>callback. This ensures RCU grace period after the
>ip_vs_stop_estimator() call.
>
>Kthread data:
>
>- every kthread works over its own data structure and all
>such structures are attached to array
>
>- even while there can be a kthread structure, its task
>may not be running, eg. before first service is added or
>while the sysctl var is set to an empty cpulist or
>when run_estimation is 0.
>
>- a task and its structure may be released if all
>estimators are unlinked from its chains, leaving the
>slot in the array empty
>
>- to add new estimators we use the last added kthread
>context (est_add_ktid). The new estimators are linked to
>the chain just before the estimated one, based on add_row.
>This ensures their estimation will start after 2 seconds.
>If estimators are added in bursts, common case if all
>services and dests are initially configured, we may
>spread the estimators to more chains. This will reduce
>the chain imbalance.
>
>- the chain imbalance is not so fatal when we use
>kthreads. We design each kthread for part of the
>possible CPU usage, so even if some chain exceeds its
>time slot it would happen all the time or sporadic
>depending on the scheduling but still keeping the
>2-second interval. The cpulist isolation can make
>the things more stable as a 2-second time interval
>per estimator.
>
>Julian Anastasov (4):
>  ipvs: add rcu protection to stats
>  ipvs: use kthreads for stats estimation
>  ipvs: add est_cpulist and est_nice sysctl vars
>  ipvs: run_estimation should control the kthread tasks
>
> Documentation/networking/ipvs-sysctl.rst |  24 +-
> include/net/ip_vs.h                      | 144 +++++++-
> net/netfilter/ipvs/ip_vs_core.c          |  10 +-
> net/netfilter/ipvs/ip_vs_ctl.c           | 287 ++++++++++++++--
> net/netfilter/ipvs/ip_vs_est.c           | 408 +++++++++++++++++++----
> 5 files changed, 771 insertions(+), 102 deletions(-)
>
>-- 
>2.37.2
