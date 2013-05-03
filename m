From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 1/2] sched: Add cond_resched_rcu_lock() helper
Date: Fri, 3 May 2013 19:04:47 +0200
Message-ID: <20130503170447.GB30733@dyad.programming.kicks-ass.net>
References: <alpine.LFD.2.00.1305012004360.3397@ja.ssi.bg>
 <20130502072623.GE7521@dyad.programming.kicks-ass.net>
 <alpine.LFD.2.00.1305021848450.31548@ja.ssi.bg>
 <20130502173257.GX3780@linux.vnet.ibm.com>
 <alpine.LFD.2.00.1305022140020.31548@ja.ssi.bg>
 <20130502193409.GA3780@linux.vnet.ibm.com>
 <alpine.LFD.2.00.1305022249010.25417@ja.ssi.bg>
 <20130502223107.GB3780@linux.vnet.ibm.com>
 <alpine.LFD.2.00.1305031024080.1657@ja.ssi.bg>
 <20130503163045.GE3780@linux.vnet.ibm.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130503163045.GE3780@linux.vnet.ibm.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Eric Dumazet <eric.dumazet@gmail.com>, Ingo Molnar <mingo@redhat.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>

> The key point is that I don't understand why we cannot get the effect
> we are looking for with the following in sched.h (or wherever):
> 
> static inline int cond_resched_rcu(void)
> {
> #if defined(CONFIG_DEBUG_ATOMIC_SLEEP) || !defined(CONFIG_PREEMPT_RCU)
> 	rcu_read_unlock();
> 	cond_resched();
> 	rcu_read_lock();
> #endif
> }
> 
> This adds absolutely no overhead in non-debug builds of CONFIG_PREEMPT_RCU,
> does the checking in debug builds, and allows voluntary preemption in
> !CONFIG_PREEMPT_RCU builds.  CONFIG_PROVE_RCU builds will check for an
> (illegal) outer rcu_read_lock() in CONFIG_PREEMPT_RCU builds, and you
> will get "scheduling while atomic" in response to an outer rcu_read_lock()
> in !CONFIG_PREEMPT_RCU builds.
> 
> It also seems to me a lot simpler.
> 
> Does this work, or am I still missing something?

It can do quite a number of superfluous rcu_read_unlock()/lock() pairs for
voluntary preemption kernels?
