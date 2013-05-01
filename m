From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2 1/2] sched: Add cond_resched_rcu_lock() helper
Date: Wed, 1 May 2013 17:22:05 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1305011344320.1603@ja.ssi.bg>
References: <1367290378-29224-1-git-send-email-horms@verge.net.au> <1367290378-29224-2-git-send-email-horms@verge.net.au> <alpine.LFD.2.00.1304301011310.1700@ja.ssi.bg> <20130430072944.GA13959@verge.net.au> <alpine.LFD.2.00.1304301051260.1700@ja.ssi.bg>
 <20130501091012.GB28253@dyad.programming.kicks-ass.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130501091012.GB28253@dyad.programming.kicks-ass.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: Simon Horman <horms@verge.net.au>, Eric Dumazet <eric.dumazet@gmail.com>, Ingo Molnar <mingo@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>


	Hello,

On Wed, 1 May 2013, Peter Zijlstra wrote:

> On Tue, Apr 30, 2013 at 10:52:38AM +0300, Julian Anastasov wrote:
> > 
> > 	Hello,
> > 
> > On Tue, 30 Apr 2013, Simon Horman wrote:
> > 
> > > Thanks, to clarify, just this:
> > > 
> > > static void inline cond_resched_rcu_lock(void)
> > > {
> > > 	rcu_read_unlock();
> > > #ifndef CONFIG_PREEMPT_RCU
> > > 	cond_resched();
> > > #endif
> > > 	rcu_read_lock();
> > > }
> > 
> > 	Yes, thanks!
> 
> OK, now I'm confused.. PREEMPT_RCU would preempt in any case, so why bother
> dropping rcu_read_lock() at all?
> 
> That is; the thing that makes sense to me is:
> 
> static void inline cond_resched_rcu_lock(void)
> {
> #ifdef CONFIG_PREEMPT_RCU

	You mean '#ifndef' here, right? But in the non-preempt
case is using the need_resched() needed? rcu_read_unlock
and rcu_read_lock do not generate code.

> 	if (need_resched()) {
> 		rcu_read_unlock();
> 		cond_resched();
> 		rcu_read_lock();
> 	}
> #endif /* CONFIG_PREEMPT_RCU */
> }
> 
> That would have an rcu_read_lock() break and voluntary preemption point for
> non-preemptible RCU and not bother with the stuff for preemptible RCU.

	I see. So, can we choose one of both variants:

1. Your variant but with ifndef:

static void inline cond_resched_rcu_lock(void)
{
#ifndef CONFIG_PREEMPT_RCU
	if (need_resched()) {
		rcu_read_unlock();
		cond_resched();
		rcu_read_lock();
	}
#endif
}

2. Same without need_resched because cond_resched already
performs the same checks:

static void inline cond_resched_rcu_lock(void)
{
#ifndef CONFIG_PREEMPT_RCU
	rcu_read_unlock();
	cond_resched();
	rcu_read_lock();
#endif
}

Regards

--
Julian Anastasov <ja@ssi.bg>
