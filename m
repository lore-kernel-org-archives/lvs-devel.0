From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2 1/2] sched: Add cond_resched_rcu_lock() helper
Date: Thu, 2 May 2013 21:55:54 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1305022140020.31548@ja.ssi.bg>
References: <1367290378-29224-2-git-send-email-horms@verge.net.au> <alpine.LFD.2.00.1304301011310.1700@ja.ssi.bg> <20130430072944.GA13959@verge.net.au> <alpine.LFD.2.00.1304301051260.1700@ja.ssi.bg> <20130501091012.GB28253@dyad.programming.kicks-ass.net>
 <alpine.LFD.2.00.1305011344320.1603@ja.ssi.bg> <20130501155501.GB7521@dyad.programming.kicks-ass.net> <alpine.LFD.2.00.1305012004360.3397@ja.ssi.bg> <20130502072623.GE7521@dyad.programming.kicks-ass.net> <alpine.LFD.2.00.1305021848450.31548@ja.ssi.bg>
 <20130502173257.GX3780@linux.vnet.ibm.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130502173257.GX3780@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Simon Horman <horms@verge.net.au>, Eric Dumazet <eric.dumazet@gmail.com>, Ingo Molnar <mingo@redhat.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>


	Hello,

On Thu, 2 May 2013, Paul E. McKenney wrote:

> On Thu, May 02, 2013 at 06:54:05PM +0300, Julian Anastasov wrote:
> > 
> > 	I tested the following patch in 2 variants,
> > TINY_RCU and CONFIG_TREE_PREEMPT_RCU. I see the
> 
> Could you please also try CONFIG_TREE_RCU?

	Note that I'm testing on some 9-year old
UP system, i.e. 1 CPU. Now I enabled SMP to test CONFIG_TREE_RCU
and the results are same. I think, it should be just like
the TINY_RCU in terms of these debuggings (non-preempt). Extra 
rcu_read_lock gives me "Illegal context switch in RCU read-side
critical section" in addition to the "BUG: sleeping function
called from invalid context" message.

> > error if extra rcu_read_lock is added for testing.
> > 
> > 	I'm using the PREEMPT_ACTIVE flag to indicate
> > that we are already under lock. It should work because
> > __might_sleep is not called with such bit. I also tried to
> > add new flag in include/linux/hardirq.h but PREEMPT_ACTIVE
> > depends on the arch, so this alternative looked difficult to
> > implement.

> > +extern int __cond_resched_rcu(void);
> > +
> > +#define cond_resched_rcu() ({					\
> > +	__might_sleep(__FILE__, __LINE__, PREEMPT_ACTIVE |	\
> > +					  PREEMPT_RCU_OFFSET);	\
> > +	__cond_resched_rcu();					\
> > +})
> > +

> > @@ -7062,7 +7076,9 @@ void __might_sleep(const char *file, int line, int preempt_offset)
> >  {
> >  	static unsigned long prev_jiffy;	/* ratelimiting */
> > 
> > -	rcu_sleep_check(); /* WARN_ON_ONCE() by default, no rate limit reqd. */
> > +	/* WARN_ON_ONCE() by default, no rate limit reqd. */
> > +	rcu_sleep_check(preempt_offset & PREEMPT_ACTIVE);
> 
> Color me confused.
> 
> >From what I can see, the two values passed in through preempt_offset
> are PREEMPT_LOCK_OFFSET and SOFTIRQ_DISABLE_OFFSET.  PREEMPT_ACTIVE
> is normally a high-order bit, above PREEMPT_MASK, SOFTIRQ_MASK, and
> HARDIRQ_MASK.
> 
> PREEMPT_LOCK_OFFSET and SOFTIRQ_DISABLE_OFFSET have only low-order bits,
> so I don't see how rcu_sleep_check() is passed anything other than zero.
> Am I going blind, or what?

	Only the new cond_resched_rcu() macro provides
PREEMPT_ACTIVE flag to skip the rcu_preempt_sleep_check()
call. The old macros provide locked=0 as you noticed. Does it
answer your question or I'm missing something?

Regards

--
Julian Anastasov <ja@ssi.bg>
