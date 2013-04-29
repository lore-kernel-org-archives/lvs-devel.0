From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/2] ipvs: Use cond_resched_rcu_lock() helper when dumping
 connections
Date: Tue, 30 Apr 2013 00:08:18 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1304292356220.1822@ja.ssi.bg>
References: <1366940708-10180-1-git-send-email-horms@verge.net.au> <1366940708-10180-3-git-send-email-horms@verge.net.au> <20130426080313.GC8669@dyad.programming.kicks-ass.net> <20130426154547.GC3860@linux.vnet.ibm.com> <20130426171948.GA31467@dyad.programming.kicks-ass.net>
 <20130426174815.GI3860@linux.vnet.ibm.com> <1367000815.8964.243.camel@edumazet-glaptop> <alpine.LFD.2.00.1304271342260.1633@ja.ssi.bg> <20130427162049.GB3780@linux.vnet.ibm.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130427162049.GB3780@linux.vnet.ibm.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Simon Horman <horms@verge.net.au>, Ingo Molnar <mingo@redhat.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>, dhaval.giani@gmail.com


	Hello,

On Sat, 27 Apr 2013, Paul E. McKenney wrote:

> On Sat, Apr 27, 2013 at 02:32:48PM +0300, Julian Anastasov wrote:
> > 
> > 	So, I assume, to help realtime kernels and rcu_barrier
> > it is not a good idea to guard rcu_read_unlock with checks.
> > I see that rcu_read_unlock will try to reschedule in the 
> > !CONFIG_PREEMPT_RCU case (via preempt_enable), can we
> > use ifdefs to avoid double TIF_NEED_RESCHED check?:
> > 
> > 	rcu_read_unlock();
> > #if !defined(CONFIG_PREEMPT) || defined(CONFIG_PREEMPT_RCU)
> 
> I would instead suggest something like:
> 
> #ifndef CONFIG_PREEMPT_RCU
> 
> But yes, in the CONFIG_PREEMPT_RCU case, the cond_resched() is not
> needed.

	Hm, is this correct? If I follow the ifdefs
preempt_schedule is called when CONFIG_PREEMPT is
defined _and_ CONFIG_PREEMPT_RCU is not defined.
Your example for CONFIG_PREEMPT_RCU is the opposite to this?

> 							Thanx, Paul
> 
> > 	cond_resched();
> > #endif
> > 	rcu_read_lock();

Regards

--
Julian Anastasov <ja@ssi.bg>
