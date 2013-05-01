From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2 1/2] sched: Add cond_resched_rcu_lock() helper
Date: Wed, 1 May 2013 21:22:08 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1305012004360.3397@ja.ssi.bg>
References: <1367290378-29224-1-git-send-email-horms@verge.net.au> <1367290378-29224-2-git-send-email-horms@verge.net.au> <alpine.LFD.2.00.1304301011310.1700@ja.ssi.bg> <20130430072944.GA13959@verge.net.au> <alpine.LFD.2.00.1304301051260.1700@ja.ssi.bg>
 <20130501091012.GB28253@dyad.programming.kicks-ass.net> <alpine.LFD.2.00.1305011344320.1603@ja.ssi.bg> <20130501155501.GB7521@dyad.programming.kicks-ass.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130501155501.GB7521@dyad.programming.kicks-ass.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: Simon Horman <horms@verge.net.au>, Eric Dumazet <eric.dumazet@gmail.com>, Ingo Molnar <mingo@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>


	Hello,

On Wed, 1 May 2013, Peter Zijlstra wrote:

> On Wed, May 01, 2013 at 05:22:05PM +0300, Julian Anastasov wrote:
> 
> > 2. Same without need_resched because cond_resched already
> > performs the same checks:
> > 
> > static void inline cond_resched_rcu_lock(void)
> > {
> > #ifndef CONFIG_PREEMPT_RCU
> > 	rcu_read_unlock();
> > 	cond_resched();
> > 	rcu_read_lock();
> > #endif
> > }
> 
> Ah so the 'problem' with this last version is that it does an unconditional /
> unnessecary rcu_read_unlock().

	It is just a barrier() for the non-preempt case.

> The below would be in line with all the other cond_resched*() implementations.

...

> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 802a751..fd2c77f 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -2449,6 +2449,13 @@ extern int __cond_resched_softirq(void);
>  	__cond_resched_softirq();					\
>  })
>  
> +extern int __cond_resched_rcu(void);
> +
> +#define cond_resched_rcu() ({			\
> +	__might_sleep(__FILE__, __LINE__, 0);	\

	I see your goal. But digging into __might_sleep()
I see that rcu_sleep_check() will scream for the non-preempt
case because we are under rcu_read_lock.

	What about such inline version:

static void inline cond_resched_rcu(void)
{
#ifndef CONFIG_PREEMPT_RCU
	rcu_read_unlock();
	__might_sleep(__FILE__, __LINE__, 0);
	cond_resched();
	rcu_read_lock();
#else
	__might_sleep(__FILE__, __LINE__, 0);
	rcu_lockdep_assert(rcu_preempt_depth() == 1,
		"Illegal cond_resched_rcu() context");
#endif
}

	It will restrict to single RCU lock level for all
RCU implementations. But we don't have _cond_resched_rcu
helper for two reasons:

- __might_sleep uses __FILE__, __LINE__
- only cond_resched generates code, so need_resched() is
avoided

> +	__cond_resched_rcu();			\
> +})
> +
>  /*
>   * Does a critical section need to be broken due to another
>   * task waiting?: (technically does not depend on CONFIG_PREEMPT,
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index 7d7901a..2b3b4e6 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -4358,6 +4358,20 @@ int __sched __cond_resched_softirq(void)
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

Regards

--
Julian Anastasov <ja@ssi.bg>
