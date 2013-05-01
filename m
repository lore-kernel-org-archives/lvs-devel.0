From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 1/2] sched: Add cond_resched_rcu_lock() helper
Date: Wed, 1 May 2013 07:32:58 -0700
Message-ID: <20130501143258.GA31577@linux.vnet.ibm.com>
References: <1367290378-29224-1-git-send-email-horms@verge.net.au>
 <1367290378-29224-2-git-send-email-horms@verge.net.au>
 <alpine.LFD.2.00.1304301011310.1700@ja.ssi.bg>
 <20130430072944.GA13959@verge.net.au>
 <alpine.LFD.2.00.1304301051260.1700@ja.ssi.bg>
 <20130501091012.GB28253@dyad.programming.kicks-ass.net>
 <20130501124637.GO3780@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130501124637.GO3780@linux.vnet.ibm.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Eric Dumazet <eric.dumazet@gmail.com>, Ingo Molnar <mingo@redhat.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>

On Wed, May 01, 2013 at 05:46:37AM -0700, Paul E. McKenney wrote:
> On Wed, May 01, 2013 at 11:10:12AM +0200, Peter Zijlstra wrote:
> > On Tue, Apr 30, 2013 at 10:52:38AM +0300, Julian Anastasov wrote:
> > > 
> > > 	Hello,
> > > 
> > > On Tue, 30 Apr 2013, Simon Horman wrote:
> > > 
> > > > > > +static void inline cond_resched_rcu_lock(void)
> > > > > > +{
> > > > > > +	if (need_resched()) {
> > > > > 
> > > > > 	Ops, it should be without above need_resched.
> > > > 
> > > > Thanks, to clarify, just this:
> > > > 
> > > > static void inline cond_resched_rcu_lock(void)
> > > > {
> > > > 	rcu_read_unlock();
> > > > #ifndef CONFIG_PREEMPT_RCU
> > > > 	cond_resched();
> > > > #endif
> > > > 	rcu_read_lock();
> > > > }
> > > 
> > > 	Yes, thanks!
> > 
> > OK, now I'm confused.. PREEMPT_RCU would preempt in any case, so why bother
> > dropping rcu_read_lock() at all?
> 
> Good point, I was assuming that the goal was to let grace periods end
> as well as to allow preemption.  The momentary dropping out of the
> RCU read-side critical section allows the grace periods to end.
> 
> > That is; the thing that makes sense to me is:
> > 
> > static void inline cond_resched_rcu_lock(void)
> > {
> > #ifdef CONFIG_PREEMPT_RCU
> > 	if (need_resched()) {
> > 		rcu_read_unlock();
> > 		cond_resched();
> > 		rcu_read_lock();
> > 	}
> > #endif /* CONFIG_PREEMPT_RCU */
> > }
> > 
> > That would have an rcu_read_lock() break and voluntary preemption point for
> > non-preemptible RCU and not bother with the stuff for preemptible RCU.
> 
> If the only goal is to allow preemption, and if long grace periods are
> not a concern, then this alternate approach would work fine as well.

But now that I think about it, there is one big advantage to the
unconditional exiting and reentering the RCU read-side critical section:
It allows easy placement of unconditional lockdep debug code to catch
the following type of bug:

	rcu_read_lock();
	...
	rcu_read_lock();
	...
	cond_resched_rcu_lock();
	...
	rcu_read_unlock();
	...
	rcu_read_unlock();

Here is how to detect this:

	static void inline cond_resched_rcu_lock(void)
	{
		rcu_read_unlock();
		WARN_ON_ONCE(rcu_read_lock_held());
	#ifndef CONFIG_PREEMPT_RCU
		cond_resched();
	#endif
		rcu_read_lock();
	}

Of course, we could do this in your implementation as well:

	static void inline cond_resched_rcu_lock(void)
	{
	#ifdef CONFIG_PREEMPT_RCU
		if (need_resched()) {
			rcu_read_unlock();
			WARN_ON_ONCE(rcu_read_lock_held());
			cond_resched();
			rcu_read_lock();
		}
	#endif /* CONFIG_PREEMPT_RCU */
	}

But this would fail to detect the bug -- and would silently fail -- on
!CONFIG_PREEMPT_RCU systems.

							Thanx, Paul

> Of course, both approaches assume that the caller is in a place
> where having all RCU-protected data disappear is OK!
> 
> 							Thanx, Paul

