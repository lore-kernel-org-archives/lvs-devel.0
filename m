From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2 1/2] sched: Add cond_resched_rcu_lock() helper
Date: Fri, 3 May 2013 10:52:36 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1305031024080.1657@ja.ssi.bg>
References: <20130501091012.GB28253@dyad.programming.kicks-ass.net> <alpine.LFD.2.00.1305011344320.1603@ja.ssi.bg> <20130501155501.GB7521@dyad.programming.kicks-ass.net> <alpine.LFD.2.00.1305012004360.3397@ja.ssi.bg> <20130502072623.GE7521@dyad.programming.kicks-ass.net>
 <alpine.LFD.2.00.1305021848450.31548@ja.ssi.bg> <20130502173257.GX3780@linux.vnet.ibm.com> <alpine.LFD.2.00.1305022140020.31548@ja.ssi.bg> <20130502193409.GA3780@linux.vnet.ibm.com> <alpine.LFD.2.00.1305022249010.25417@ja.ssi.bg>
 <20130502223107.GB3780@linux.vnet.ibm.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130502223107.GB3780@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Simon Horman <horms@verge.net.au>, Eric Dumazet <eric.dumazet@gmail.com>, Ingo Molnar <mingo@redhat.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>


	Hello,

On Thu, 2 May 2013, Paul E. McKenney wrote:

> mainline, and missed the one that you added.  Revisiting that, a
> question:
> 
> > +#ifdef CONFIG_PREEMPT_RCU
> > +#define PREEMPT_RCU_OFFSET     1
> 
> Does this really want to be "1" instead of PREEMPT_OFFSET?

	In this case when CONFIG_PREEMPT_RCU is enabled
we (RCU) do not touch the preempt counters. Instead, the units
are accounted in current->rcu_read_lock_nesting:

#define rcu_preempt_depth() (current->rcu_read_lock_nesting)

__rcu_read_lock:
	current->rcu_read_lock_nesting++;

	and the path is __might_sleep -> preempt_count_equals ->
rcu_preempt_depth

	For now both places do not use PREEMPT_OFFSET:

- #define inc_preempt_count() add_preempt_count(1)
- __rcu_read_lock: current->rcu_read_lock_nesting++;

	so, ... it does not matter much for me. In short,
the trick is in preempt_count_equals() where preempt_offset
is a combination of preempt count and RCU preempt depth:

#ifdef CONFIG_PREEMPT_RCU
#define PREEMPT_RCU_OFFSET      (0 /* preempt */ + 1 /* RCU */)
#else
#define PREEMPT_RCU_OFFSET      (PREEMPT_CHECK_OFFSET + 0 /* RCU */)
#endif

	Let me know for your preference about this definition...

Regards

--
Julian Anastasov <ja@ssi.bg>
