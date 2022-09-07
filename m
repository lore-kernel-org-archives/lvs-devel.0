From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCH 2/4] ipvs: use kthreads for stats estimation
Date: Wed, 7 Sep 2022 21:07:18 +0300 (EEST)
Message-ID: <ff10274b-a0a0-9667-f878-99142a3ecca5@ssi.bg>
References: <20220827174154.220651-1-ja@ssi.bg> <20220827174154.220651-3-ja@ssi.bg> <20220905064725.GB108825@linux.alibaba.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20220905064725.GB108825@linux.alibaba.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "dust.li" <dust.li@linux.alibaba.com>
Cc: Jiri Wiesner <jwiesner@suse.de>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>


	Hello,

On Mon, 5 Sep 2022, dust.li wrote:

> >+static inline void ip_vs_est_wait_resched(struct netns_ipvs *ipvs,
> >+					  struct ip_vs_estimator *est)
> >+{
> >+#ifdef IPVS_EST_RESCHED_RCU
> >+	/* Estimator kthread is rescheduling on deleted est? Wait it! */
> >+	if (!refcount_dec_and_test(&est->refcnt)) {
> >+		struct ip_vs_est_kt_data *kd = ipvs->est_kt_arr[est->ktid];
> >+
> >+		mutex_lock(&kd->mutex);
> >+		mutex_unlock(&kd->mutex);
> 
> IIUC, this mutex_lock/unlock() is just used for waiting for the ipvs-e
> thread schedule back if it had been scheduled out in cond_resched_rcu() ?
> But not to protect data ?

	Yes

> If so, I am wondering if we can remove the mutex_trylock/unlock() in
> ip_vs_est_cond_resched_rcu, and use some wait/wakeup mechanism to do
> this ? Because when I run perf on 'ipvs-e' kthreads, I saw lots of CPU
> cycles are on the mutex_trylock.

	Yes, wait/wakeup would be better alternative, it will
avoid the possible priority inversion as Jiri noticed.

	Probably, the rate of rescheduling can be reduced,
so that we can achieve sub-millisecond latency. But the time
we spend in the for_each_possible_cpu() loop depends on the
number of possible CPUs, they can have different speed.
I thought of checking initially with need_resched() before
mutex_trylock() but when RCU preemption is disabled, the RCU
reader side is a region with disabled preemption and we should
call cond_resched() often to report a quiescent state with
rcu_all_qs().

For example:

- goal: sub-100-microsecond cond_resched rate to
report a quiescent state and to be nice to other kthreads

	if (!(++resched_counter & 15) || need_resched()) ...

	Thank you for the review and testing!

Regards

--
Julian Anastasov <ja@ssi.bg>

