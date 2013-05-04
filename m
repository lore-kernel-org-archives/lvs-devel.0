From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 1/2] sched: Add cond_resched_rcu_lock() helper
Date: Sat, 4 May 2013 11:03:16 -0700
Message-ID: <20130504180315.GB3659@linux.vnet.ibm.com>
References: <20130502072623.GE7521@dyad.programming.kicks-ass.net>
 <alpine.LFD.2.00.1305021848450.31548@ja.ssi.bg>
 <20130502173257.GX3780@linux.vnet.ibm.com>
 <alpine.LFD.2.00.1305022140020.31548@ja.ssi.bg>
 <20130502193409.GA3780@linux.vnet.ibm.com>
 <alpine.LFD.2.00.1305022249010.25417@ja.ssi.bg>
 <20130502223107.GB3780@linux.vnet.ibm.com>
 <alpine.LFD.2.00.1305031024080.1657@ja.ssi.bg>
 <20130503163045.GE3780@linux.vnet.ibm.com>
 <alpine.LFD.2.00.1305041018520.1645@ja.ssi.bg>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1305041018520.1645@ja.ssi.bg>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Peter Zijlstra <peterz@infradead.org>, Simon Horman <horms@verge.net.au>, Eric Dumazet <eric.dumazet@gmail.com>, Ingo Molnar <mingo@redhat.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>

On Sat, May 04, 2013 at 10:23:31AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Fri, 3 May 2013, Paul E. McKenney wrote:
> 
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
> 	Works perfectly. Thanks! Tested CONFIG_PREEMPT_RCU=y/n,
> the errors messages with extra RCU lock.

Very good!  Please send the patch along, and I will ack it.

						Thanx, Paul

