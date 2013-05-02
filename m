From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2 1/2] sched: Add cond_resched_rcu_lock() helper
Date: Thu, 2 May 2013 13:06:30 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1305021108430.1676@ja.ssi.bg>
References: <1367290378-29224-1-git-send-email-horms@verge.net.au> <1367290378-29224-2-git-send-email-horms@verge.net.au> <alpine.LFD.2.00.1304301011310.1700@ja.ssi.bg> <20130430072944.GA13959@verge.net.au> <alpine.LFD.2.00.1304301051260.1700@ja.ssi.bg>
 <20130501091012.GB28253@dyad.programming.kicks-ass.net> <alpine.LFD.2.00.1305011344320.1603@ja.ssi.bg> <20130501155501.GB7521@dyad.programming.kicks-ass.net> <alpine.LFD.2.00.1305012004360.3397@ja.ssi.bg>
 <20130502072623.GE7521@dyad.programming.kicks-ass.net>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130502072623.GE7521@dyad.programming.kicks-ass.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: Simon Horman <horms@verge.net.au>, Eric Dumazet <eric.dumazet@gmail.com>, Ingo Molnar <mingo@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>


	Hello,

On Thu, 2 May 2013, Peter Zijlstra wrote:

> On Wed, May 01, 2013 at 09:22:08PM +0300, Julian Anastasov wrote:
> > > +extern int __cond_resched_rcu(void);
> > > +
> > > +#define cond_resched_rcu() ({			\
> > > +	__might_sleep(__FILE__, __LINE__, 0);	\
> > 
> > 	I see your goal. But digging into __might_sleep()
> > I see that rcu_sleep_check() will scream for the non-preempt
> > case because we are under rcu_read_lock.
> 
> 
> #ifdef CONFIG_PREEMPT_RCU
> #define PREEMPT_RCU_OFFSET 0
> #else
> #define PREEMPT_RCU_OFFSET 1
> #endif
> 
> #define cond_resched_rcu() ({	\
> 	__might_sleep(__FILE__, __LINE__, PREEMPT_RCU_OFFSET);	\
> 	__cond_resched_rcu();	\
> })
> 
> Should work I think..

	Looks like CONFIG_DEBUG_ATOMIC_SLEEP selects
CONFIG_PREEMPT_COUNT, so PREEMPT_RCU_OFFSET should be
1 in all cases because preempt_disable() adds 1, while
for CONFIG_PREEMPT_RCU case rcu_preempt_depth() should
return 1:

#ifdef CONFIG_PREEMPT_RCU
#define PREEMPT_RCU_OFFSET 1
#else
#define PREEMPT_RCU_OFFSET PREEMPT_CHECK_OFFSET
#endif

	Now the remaining part is to fix rcu_sleep_check() for
the non-preempt case. As there are no nesting depths in this
case, I don't see a solution so far. We can provide
some argument to rcu_preempt_sleep_check to compare
depth with preempt_count() but currently I don't know
how to differentiate cond_resched_lock() from cond_resched_rcu()
when calling __might_sleep, in both cases we provide
PREEMPT_OFFSET. May be some trick is needed here without
adding new arg to __might_sleep, so that we can properly
check for rcu_lock_map.

Regards

--
Julian Anastasov <ja@ssi.bg>
