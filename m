From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 1/2] sched: Add cond_resched_rcu_lock() helper
Date: Thu, 2 May 2013 10:32:57 -0700
Message-ID: <20130502173257.GX3780@linux.vnet.ibm.com>
References: <1367290378-29224-2-git-send-email-horms@verge.net.au>
 <alpine.LFD.2.00.1304301011310.1700@ja.ssi.bg>
 <20130430072944.GA13959@verge.net.au>
 <alpine.LFD.2.00.1304301051260.1700@ja.ssi.bg>
 <20130501091012.GB28253@dyad.programming.kicks-ass.net>
 <alpine.LFD.2.00.1305011344320.1603@ja.ssi.bg>
 <20130501155501.GB7521@dyad.programming.kicks-ass.net>
 <alpine.LFD.2.00.1305012004360.3397@ja.ssi.bg>
 <20130502072623.GE7521@dyad.programming.kicks-ass.net>
 <alpine.LFD.2.00.1305021848450.31548@ja.ssi.bg>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1305021848450.31548@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Peter Zijlstra <peterz@infradead.org>, Simon Horman <horms@verge.net.au>, Eric Dumazet <eric.dumazet@gmail.com>, Ingo Molnar <mingo@redhat.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>

On Thu, May 02, 2013 at 06:54:05PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 2 May 2013, Peter Zijlstra wrote:
> 
> > On Wed, May 01, 2013 at 09:22:08PM +0300, Julian Anastasov wrote:
> > > > +extern int __cond_resched_rcu(void);
> > > > +
> > > > +#define cond_resched_rcu() ({			\
> > > > +	__might_sleep(__FILE__, __LINE__, 0);	\
> > > 
> > > 	I see your goal. But digging into __might_sleep()
> > > I see that rcu_sleep_check() will scream for the non-preempt
> > > case because we are under rcu_read_lock.
> > 
> > 
> > #ifdef CONFIG_PREEMPT_RCU
> > #define PREEMPT_RCU_OFFSET 0
> > #else
> > #define PREEMPT_RCU_OFFSET 1
> > #endif
> > 
> > #define cond_resched_rcu() ({	\
> > 	__might_sleep(__FILE__, __LINE__, PREEMPT_RCU_OFFSET);	\
> > 	__cond_resched_rcu();	\
> > })
> > 
> > Should work I think..
> 
> 	I implemented your idea.
> 
> 	I tested the following patch in 2 variants,
> TINY_RCU and CONFIG_TREE_PREEMPT_RCU. I see the

Could you please also try CONFIG_TREE_RCU?

> error if extra rcu_read_lock is added for testing.
> 
> 	I'm using the PREEMPT_ACTIVE flag to indicate
> that we are already under lock. It should work because
> __might_sleep is not called with such bit. I also tried to
> add new flag in include/linux/hardirq.h but PREEMPT_ACTIVE
> depends on the arch, so this alternative looked difficult to
> implement.
> 
>  include/linux/rcupdate.h |    7 ++++---
>  include/linux/sched.h    |   14 ++++++++++++++
>  kernel/sched/core.c      |   20 ++++++++++++++++++--
>  3 files changed, 36 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
> index b758ce1..b594759 100644
> --- a/include/linux/rcupdate.h
> +++ b/include/linux/rcupdate.h
> @@ -480,9 +480,10 @@ static inline void rcu_preempt_sleep_check(void)
>  }
>  #endif /* #else #ifdef CONFIG_PROVE_RCU */
> 
> -#define rcu_sleep_check()						\
> +#define rcu_sleep_check(locked)						\
>  	do {								\
> -		rcu_preempt_sleep_check();				\
> +		if (!(locked))						\
> +			rcu_preempt_sleep_check();			\
>  		rcu_lockdep_assert(!lock_is_held(&rcu_bh_lock_map),	\
>  				   "Illegal context switch in RCU-bh"	\
>  				   " read-side critical section");	\
> @@ -494,7 +495,7 @@ static inline void rcu_preempt_sleep_check(void)
>  #else /* #ifdef CONFIG_PROVE_RCU */
> 
>  #define rcu_lockdep_assert(c, s) do { } while (0)
> -#define rcu_sleep_check() do { } while (0)
> +#define rcu_sleep_check(locked) do { } while (0)
> 
>  #endif /* #else #ifdef CONFIG_PROVE_RCU */
> 
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index e692a02..027deea 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -2608,6 +2608,20 @@ extern int __cond_resched_softirq(void);
>  	__cond_resched_softirq();					\
>  })
> 
> +#ifdef CONFIG_PREEMPT_RCU
> +#define PREEMPT_RCU_OFFSET	1
> +#else
> +#define PREEMPT_RCU_OFFSET	PREEMPT_CHECK_OFFSET
> +#endif
> +
> +extern int __cond_resched_rcu(void);
> +
> +#define cond_resched_rcu() ({					\
> +	__might_sleep(__FILE__, __LINE__, PREEMPT_ACTIVE |	\
> +					  PREEMPT_RCU_OFFSET);	\
> +	__cond_resched_rcu();					\
> +})
> +
>  /*
>   * Does a critical section need to be broken due to another
>   * task waiting?: (technically does not depend on CONFIG_PREEMPT,
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index 67d0465..2724be7 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -2793,7 +2793,7 @@ static inline void schedule_debug(struct task_struct *prev)
>  	 */
>  	if (unlikely(in_atomic_preempt_off() && !prev->exit_state))
>  		__schedule_bug(prev);
> -	rcu_sleep_check();
> +	rcu_sleep_check(0);
> 
>  	profile_hit(SCHED_PROFILING, __builtin_return_address(0));
> 
> @@ -4364,6 +4364,20 @@ int __sched __cond_resched_softirq(void)
>  }
>  EXPORT_SYMBOL(__cond_resched_softirq);
> 
> +int __sched __cond_resched_rcu(void)
> +{
> +#ifndef CONFIG_PREEMPT_RCU
> +	if (should_resched()) {
> +		rcu_read_unlock();
> +		__cond_resched();
> +		rcu_read_lock();
> +		return 1;
> +	}
> +#endif
> +	return 0;
> +}
> +EXPORT_SYMBOL(__cond_resched_rcu);
> +
>  /**
>   * yield - yield the current processor to other threads.
>   *
> @@ -7062,7 +7076,9 @@ void __might_sleep(const char *file, int line, int preempt_offset)
>  {
>  	static unsigned long prev_jiffy;	/* ratelimiting */
> 
> -	rcu_sleep_check(); /* WARN_ON_ONCE() by default, no rate limit reqd. */
> +	/* WARN_ON_ONCE() by default, no rate limit reqd. */
> +	rcu_sleep_check(preempt_offset & PREEMPT_ACTIVE);

Color me confused.

From what I can see, the two values passed in through preempt_offset
are PREEMPT_LOCK_OFFSET and SOFTIRQ_DISABLE_OFFSET.  PREEMPT_ACTIVE
is normally a high-order bit, above PREEMPT_MASK, SOFTIRQ_MASK, and
HARDIRQ_MASK.

PREEMPT_LOCK_OFFSET and SOFTIRQ_DISABLE_OFFSET have only low-order bits,
so I don't see how rcu_sleep_check() is passed anything other than zero.
Am I going blind, or what?

							Thanx, Paul

> +	preempt_offset &= ~PREEMPT_ACTIVE;
>  	if ((preempt_count_equals(preempt_offset) && !irqs_disabled()) ||
>  	    system_state != SYSTEM_RUNNING || oops_in_progress)
>  		return;
> -- 
> 1.7.3.4
> 
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

