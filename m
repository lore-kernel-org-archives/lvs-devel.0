From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 1/2] sched: Add cond_resched_rcu_lock() helper
Date: Fri, 3 May 2013 09:30:45 -0700
Message-ID: <20130503163045.GE3780@linux.vnet.ibm.com>
References: <20130501155501.GB7521@dyad.programming.kicks-ass.net>
 <alpine.LFD.2.00.1305012004360.3397@ja.ssi.bg>
 <20130502072623.GE7521@dyad.programming.kicks-ass.net>
 <alpine.LFD.2.00.1305021848450.31548@ja.ssi.bg>
 <20130502173257.GX3780@linux.vnet.ibm.com>
 <alpine.LFD.2.00.1305022140020.31548@ja.ssi.bg>
 <20130502193409.GA3780@linux.vnet.ibm.com>
 <alpine.LFD.2.00.1305022249010.25417@ja.ssi.bg>
 <20130502223107.GB3780@linux.vnet.ibm.com>
 <alpine.LFD.2.00.1305031024080.1657@ja.ssi.bg>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1305031024080.1657@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Peter Zijlstra <peterz@infradead.org>, Simon Horman <horms@verge.net.au>, Eric Dumazet <eric.dumazet@gmail.com>, Ingo Molnar <mingo@redhat.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>

On Fri, May 03, 2013 at 10:52:36AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 2 May 2013, Paul E. McKenney wrote:
> 
> > mainline, and missed the one that you added.  Revisiting that, a
> > question:
> > 
> > > +#ifdef CONFIG_PREEMPT_RCU
> > > +#define PREEMPT_RCU_OFFSET     1
> > 
> > Does this really want to be "1" instead of PREEMPT_OFFSET?
> 
> 	In this case when CONFIG_PREEMPT_RCU is enabled
> we (RCU) do not touch the preempt counters. Instead, the units
> are accounted in current->rcu_read_lock_nesting:
> 
> #define rcu_preempt_depth() (current->rcu_read_lock_nesting)
> 
> __rcu_read_lock:
> 	current->rcu_read_lock_nesting++;
> 
> 	and the path is __might_sleep -> preempt_count_equals ->
> rcu_preempt_depth
> 
> 	For now both places do not use PREEMPT_OFFSET:
> 
> - #define inc_preempt_count() add_preempt_count(1)
> - __rcu_read_lock: current->rcu_read_lock_nesting++;
> 
> 	so, ... it does not matter much for me. In short,
> the trick is in preempt_count_equals() where preempt_offset
> is a combination of preempt count and RCU preempt depth:
> 
> #ifdef CONFIG_PREEMPT_RCU
> #define PREEMPT_RCU_OFFSET      (0 /* preempt */ + 1 /* RCU */)
> #else
> #define PREEMPT_RCU_OFFSET      (PREEMPT_CHECK_OFFSET + 0 /* RCU */)
> #endif
> 
> 	Let me know for your preference about this definition...

OK, after getting some sleep, I might have located the root cause of
my confusion yesterday.

The key point is that I don't understand why we cannot get the effect
we are looking for with the following in sched.h (or wherever):

static inline int cond_resched_rcu(void)
{
#if defined(CONFIG_DEBUG_ATOMIC_SLEEP) || !defined(CONFIG_PREEMPT_RCU)
	rcu_read_unlock();
	cond_resched();
	rcu_read_lock();
#endif
}

This adds absolutely no overhead in non-debug builds of CONFIG_PREEMPT_RCU,
does the checking in debug builds, and allows voluntary preemption in
!CONFIG_PREEMPT_RCU builds.  CONFIG_PROVE_RCU builds will check for an
(illegal) outer rcu_read_lock() in CONFIG_PREEMPT_RCU builds, and you
will get "scheduling while atomic" in response to an outer rcu_read_lock()
in !CONFIG_PREEMPT_RCU builds.

It also seems to me a lot simpler.

Does this work, or am I still missing something?

							Thanx, Paul

