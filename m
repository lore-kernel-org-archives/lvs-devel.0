From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/2] ipvs: Use cond_resched_rcu_lock() helper when dumping
 connections
Date: Sat, 27 Apr 2013 14:32:48 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1304271342260.1633@ja.ssi.bg>
References: <1366940708-10180-1-git-send-email-horms@verge.net.au>  <1366940708-10180-3-git-send-email-horms@verge.net.au>  <20130426080313.GC8669@dyad.programming.kicks-ass.net>  <20130426154547.GC3860@linux.vnet.ibm.com>  <20130426171948.GA31467@dyad.programming.kicks-ass.net>
  <20130426174815.GI3860@linux.vnet.ibm.com> <1367000815.8964.243.camel@edumazet-glaptop>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1367000815.8964.243.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: paulmck@linux.vnet.ibm.com, Peter Zijlstra <peterz@infradead.org>, Simon Horman <horms@verge.net.au>, Ingo Molnar <mingo@redhat.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>, dhaval.giani@gmail.com


	Hello,

On Fri, 26 Apr 2013, Eric Dumazet wrote:

> On Fri, 2013-04-26 at 10:48 -0700, Paul E. McKenney wrote:
> 
> > Don't get me wrong, I am not opposing cond_resched_rcu_lock() because it
> > will be difficult to validate.  For one thing, until there are a lot of
> > them, manual inspection is quite possible.  So feel free to apply my
> > Acked-by to the patch.
> 
> One question : If some thread(s) is(are) calling rcu_barrier() and
> waiting we exit from rcu_read_lock() section, is need_resched() enough
> for allowing to break the section ?
> 
> If not, maybe we should not test need_resched() at all.
> 
> rcu_read_unlock();
> cond_resched();
> rcu_read_lock();

	So, I assume, to help realtime kernels and rcu_barrier
it is not a good idea to guard rcu_read_unlock with checks.
I see that rcu_read_unlock will try to reschedule in the 
!CONFIG_PREEMPT_RCU case (via preempt_enable), can we
use ifdefs to avoid double TIF_NEED_RESCHED check?:

	rcu_read_unlock();
#if !defined(CONFIG_PREEMPT) || defined(CONFIG_PREEMPT_RCU)
	cond_resched();
#endif
	rcu_read_lock();

Regards

--
Julian Anastasov <ja@ssi.bg>
