From: Jiri Wiesner <jwiesner@suse.de>
Subject: Re: [RFC PATCH 0/4] Use kthreads for stats
Date: Mon, 5 Sep 2022 10:26:42 +0200
Message-ID: <20220905082642.GB18621@incl>
References: <20220827174154.220651-1-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1662366403; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=Ky913n8lbGp/e1G42G+V2wB8HKxEcThmx7Cb3t2cDvU=;
        b=L6//Vlg6PulT3MHiK2H4NcW1stsTC8BM2SH3RtTyExl0bTt8IVR6uHCyBCtGYos094dUlc
        ABdGcBHMtkML8R/L/pXE+ZwaAwzALAhhQnw8tnUGn7lO9bamGhilX40UC1E36SqckHPtfG
        OGBr8h5JwruyuqgmZPGgk74y1ppDm6o=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1662366403;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=Ky913n8lbGp/e1G42G+V2wB8HKxEcThmx7Cb3t2cDvU=;
        b=q2RQRTn+CCQjZT1i/VgVdbGbb8gUsLV7hchPYXJJ5PrG16EGqGNUlx2kv1JsINrotYuKih
        H3A8wRDdD4xx5UAg==
Content-Disposition: inline
In-Reply-To: <20220827174154.220651-1-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, yunhjiang@ebay.com, dust.li@linux.alibaba.com, tangyang@zhihu.com

On Sat, Aug 27, 2022 at 08:41:50PM +0300, Julian Anastasov wrote:
> 	This patchset implements stats estimation in
> kthread context. Simple tests do not show any problem.
> Please review, comment, test, etc.

Thank you for this, Julian.

> RCU Locking:
> 
> - when RCU preemption is enabled the kthreads use just RCU
> lock for walking the chains and we do not need to reschedule.
> May be this is the common case for distribution kernels.
> In this case ip_vs_stop_estimator() is completely lockless.

Yes, it is the case for SUSE since SLES 15.4, which is a recent release.

> - when RCU preemption is not enabled, we reschedule by using
> refcnt for every estimator to track if the currently removed
> estimator is used at the same time by kthread for estimation.
> As RCU lock is unlocked during rescheduling, the deletion
> should wait kd->mutex, so that a new RCU lock is applied
> before the estimator is freed with RCU callback.

I believe allowing the kthread the possibility to block in each iteration - for each estimator - introduces some problems:
1. Non-preemptive kernels should be optimized for throughput not for latency
Using the figure reported earlier (50,000 services required 200 ms of processing time) it takes roughly 3 ms to process one chain (32 * 1024 / 50 services). The processing time per chain will vary with the number of NUMA nodes and CPUs. Nevertheless, this number comparable with the processing time limit of __do_softirq() - 2 ms, which gets converted to 1 jiffy. In term of latency of non-preemptive kernels, it is entirely resonable to let one chain be processed without rescheduling the kthread.
2. The priority of the kthreads could be set to lower values than the default priority for SCHED_OTHER. If a user space process was trying to stop an estimator the pointer to which is held by a currently sleeping kthread this would constitute priority inversion. The kd->mutex would not be released until the lower priority thread, the kthread, has started running again. AFAIK, the mutex() locking primitive does not implement priority inheritance on non-preemptive kernels.
3. Blocking while in ip_vs_estimation_chain() will results in wrong estimates for the remaining estimators in a chain. The 2 second interval would not be kept, rate estimates would be overestimated in that interval and underestimated in one of the future intervals.
In my opinion, any of the above reasons is sufficient to remove ip_vs_est_cond_resched_rcu(), ip_vs_est_wait_resched() and kd->mutex.

> - As stats are now RCU-locked, tot_stats, svc and dest which
> hold estimator structures are now always freed from RCU
> callback. This ensures RCU grace period after the
> ip_vs_stop_estimator() call.

I think this is sound.

> Kthread data:
> 
> - every kthread works over its own data structure and all
> such structures are attached to array

It seems to me there is no upper bound on the number of kthreads that could be forked. Therefore, it should be possible to devise an attack that would force the system to run out of PIDs:
1. Start adding services so that all chains of kthread A would be used.
2. Add one more service to force the forking of kthread B, thus advancing ipvs->est_add_ktid.
3. Remove all but one service from kthread A.
4. Repeat steps 1-3 but with kthread B.
I think I could come up with a reproducer if need be.

> - to add new estimators we use the last added kthread
> context (est_add_ktid). The new estimators are linked to
> the chain just before the estimated one, based on add_row.
> This ensures their estimation will start after 2 seconds.
> If estimators are added in bursts, common case if all
> services and dests are initially configured, we may
> spread the estimators to more chains. This will reduce
> the chain imbalance.
> 
> - the chain imbalance is not so fatal when we use
> kthreads. We design each kthread for part of the
> possible CPU usage, so even if some chain exceeds its
> time slot it would happen all the time or sporadic
> depending on the scheduling but still keeping the
> 2-second interval. The cpulist isolation can make
> the things more stable as a 2-second time interval
> per estimator.

Unbalanced chains would not be fatal to the system but there is risk of introducing scheduling latencies tens or even hundreds of milliseconds long. There are patterns of adding and removing chains that would results in chain imbalance getting so severe that a handful of chains would have estimators in them while the rest would be empty or almost empty. Some examples:
1. Adding a new service each second after sleeping for 1 second. This would use the add_row value at the time of adding the estimator, which would result in 2 chains holding all the estimators.
2. Repeated addition and removal of services. There would always be more services added than removed. The additions would be carried out in bursts. The forking of a new kthread would not be triggered because the number of services would stay under IPVS_EST_MAX_COUNT (32 * 1024).

The problem is that the code does not guarantee that the length of chains always stays under IPVS_EST_MAX_COUNT / IPVS_EST_NCHAINS (32 * 1024 / 50) estimators. A check and a cycle iterating over available rows could be added to ip_vs_start_estimator() to find the rows that still have fewer estimators than IPVS_EST_MAX_COUNT / IPVS_EST_NCHAINS. This would come at the expense of having inaccurate estimates for a few intervals but I think the trade-off is worth it. Also, the estimates will be inaccurate when estimators are added in bursts. If, depending on how services are added and removed, the code could introduce scheduling latencies there would be someone running into this sooner or later. The probability of severe chain imbalance being low is not good enough there should be a guarantee.
-- 
Jiri Wiesner
SUSE Labs
