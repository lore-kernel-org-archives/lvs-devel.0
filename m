From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2 1/2] sched: Add cond_resched_rcu_lock() helper
Date: Thu, 2 May 2013 23:19:12 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1305022249010.25417@ja.ssi.bg>
References: <20130430072944.GA13959@verge.net.au> <alpine.LFD.2.00.1304301051260.1700@ja.ssi.bg> <20130501091012.GB28253@dyad.programming.kicks-ass.net> <alpine.LFD.2.00.1305011344320.1603@ja.ssi.bg> <20130501155501.GB7521@dyad.programming.kicks-ass.net>
 <alpine.LFD.2.00.1305012004360.3397@ja.ssi.bg> <20130502072623.GE7521@dyad.programming.kicks-ass.net> <alpine.LFD.2.00.1305021848450.31548@ja.ssi.bg> <20130502173257.GX3780@linux.vnet.ibm.com> <alpine.LFD.2.00.1305022140020.31548@ja.ssi.bg>
 <20130502193409.GA3780@linux.vnet.ibm.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130502193409.GA3780@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Simon Horman <horms@verge.net.au>, Eric Dumazet <eric.dumazet@gmail.com>, Ingo Molnar <mingo@redhat.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>


	Hello,

On Thu, 2 May 2013, Paul E. McKenney wrote:

> > 	Only the new cond_resched_rcu() macro provides
> > PREEMPT_ACTIVE flag to skip the rcu_preempt_sleep_check()
> > call. The old macros provide locked=0 as you noticed. Does it
> > answer your question or I'm missing something?
> 
> PREEMPT_ACTIVE's value is usually 0x10000000.  Did it change
> since 3.9?  If not, rcu_sleep_check(preempt_offset & PREEMPT_ACTIVE)
> is the same as rcu_sleep_check(0).

	Yes, the different platforms use different bit,
that is why I mentioned about my failed attempt at
changing hardirq.h. PREEMPT_ACTIVE is always != 0.

	But I don't understand what do you mean by
'preempt_offset & PREEMPT_ACTIVE' being always 0.
It is always 0 for cond_resched(), cond_resched_lock()
and cond_resched_softirq(), not for cond_resched_rcu():

(PREEMPT_ACTIVE | PREEMPT_RCU_OFFSET) & PREEMPT_ACTIVE
should give PREEMPT_ACTIVE, not 0. We have 2 cases in
rcu_sleep_check() for the if:

1. !(PREEMPT_ACTIVE) => FALSE for cond_resched_rcu
2. !(0) => TRUE for other cond_resched_* macros

	On x86 the code is:

__might_sleep:
        pushl   %ebp    #
        testl   $268435456, %ecx        #, preempt_offset
...
        jne     .L240   #,
	// rcu_lock_map checked when PREEMPT_ACTIVE is missing
.L240:
	// rcu_bh_lock_map checked

Regards

--
Julian Anastasov <ja@ssi.bg>
