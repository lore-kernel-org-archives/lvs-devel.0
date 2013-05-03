From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 1/2] sched: Add cond_resched_rcu_lock() helper
Date: Fri, 3 May 2013 10:34:44 -0700
Message-ID: <20130503173444.GH3780@linux.vnet.ibm.com>
References: <20130502072623.GE7521@dyad.programming.kicks-ass.net>
 <alpine.LFD.2.00.1305021848450.31548@ja.ssi.bg>
 <20130502173257.GX3780@linux.vnet.ibm.com>
 <alpine.LFD.2.00.1305022140020.31548@ja.ssi.bg>
 <20130502193409.GA3780@linux.vnet.ibm.com>
 <alpine.LFD.2.00.1305022249010.25417@ja.ssi.bg>
 <20130502223107.GB3780@linux.vnet.ibm.com>
 <alpine.LFD.2.00.1305031024080.1657@ja.ssi.bg>
 <20130503163045.GE3780@linux.vnet.ibm.com>
 <20130503170447.GB30733@dyad.programming.kicks-ass.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130503170447.GB30733@dyad.programming.kicks-ass.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Eric Dumazet <eric.dumazet@gmail.com>, Ingo Molnar <mingo@redhat.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>

On Fri, May 03, 2013 at 07:04:47PM +0200, Peter Zijlstra wrote:
> > The key point is that I don't understand why we cannot get the effect
> > we are looking for with the following in sched.h (or wherever):
> > 
> > static inline int cond_resched_rcu(void)
> > {
> > #if defined(CONFIG_DEBUG_ATOMIC_SLEEP) || !defined(CONFIG_PREEMPT_RCU)
> > 	rcu_read_unlock();
> > 	cond_resched();
> > 	rcu_read_lock();
> > #endif
> > }
> > 
> > This adds absolutely no overhead in non-debug builds of CONFIG_PREEMPT_RCU,
> > does the checking in debug builds, and allows voluntary preemption in
> > !CONFIG_PREEMPT_RCU builds.  CONFIG_PROVE_RCU builds will check for an
> > (illegal) outer rcu_read_lock() in CONFIG_PREEMPT_RCU builds, and you
> > will get "scheduling while atomic" in response to an outer rcu_read_lock()
> > in !CONFIG_PREEMPT_RCU builds.
> > 
> > It also seems to me a lot simpler.
> > 
> > Does this work, or am I still missing something?
> 
> It can do quite a number of superfluous rcu_read_unlock()/lock() pairs for
> voluntary preemption kernels?

This happens in only two cases:

1.	CONFIG_PREEMPT_RCU=n kernels.  But in this case, rcu_read_unlock()
	and rcu_read_lock() are free, at least for CONFIG_PROVE_LOCKING=n
	kernels.  And if you have CONFIG_PROVE_LOCKING=y, any contribution
	from rcu_read_unlock() and rcu_read_lock() will be in the noise.

2.	CONFIG_DEBUG_ATOMIC_SLEEP=y kernels -- but in this case, you
	-want- the debugging.

So either the overhead is non-existent, or you explicitly asked for the
resulting debugging.

In particular, CONFIG_PREEMPT_RCU=y kernels have an empty static inline
function, which is free -- unless CONFIG_DEBUG_ATOMIC_SLEEP=y, in which
case you again explicitly asked for the debugging.

So I do not believe that the extra rcu_read_unlock()/lock() pairs are a
problem in any of the possible combinations of configurations.

							Thanx, Paul

