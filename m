From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 1/2] sched: Add cond_resched_rcu_lock() helper
Date: Wed, 1 May 2013 11:10:12 +0200
Message-ID: <20130501091012.GB28253@dyad.programming.kicks-ass.net>
References: <1367290378-29224-1-git-send-email-horms@verge.net.au>
 <1367290378-29224-2-git-send-email-horms@verge.net.au>
 <alpine.LFD.2.00.1304301011310.1700@ja.ssi.bg>
 <20130430072944.GA13959@verge.net.au>
 <alpine.LFD.2.00.1304301051260.1700@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1304301051260.1700@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, Eric Dumazet <eric.dumazet@gmail.com>, Ingo Molnar <mingo@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>

On Tue, Apr 30, 2013 at 10:52:38AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 30 Apr 2013, Simon Horman wrote:
> 
> > > > +static void inline cond_resched_rcu_lock(void)
> > > > +{
> > > > +	if (need_resched()) {
> > > 
> > > 	Ops, it should be without above need_resched.
> > 
> > Thanks, to clarify, just this:
> > 
> > static void inline cond_resched_rcu_lock(void)
> > {
> > 	rcu_read_unlock();
> > #ifndef CONFIG_PREEMPT_RCU
> > 	cond_resched();
> > #endif
> > 	rcu_read_lock();
> > }
> 
> 	Yes, thanks!

OK, now I'm confused.. PREEMPT_RCU would preempt in any case, so why bother
dropping rcu_read_lock() at all?

That is; the thing that makes sense to me is:

static void inline cond_resched_rcu_lock(void)
{
#ifdef CONFIG_PREEMPT_RCU
	if (need_resched()) {
		rcu_read_unlock();
		cond_resched();
		rcu_read_lock();
	}
#endif /* CONFIG_PREEMPT_RCU */
}

That would have an rcu_read_lock() break and voluntary preemption point for
non-preemptible RCU and not bother with the stuff for preemptible RCU.
