From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 1/2] sched: Add cond_resched_rcu_lock() helper
Date: Thu, 2 May 2013 09:27:43 +0200
Message-ID: <20130502072742.GF7521@dyad.programming.kicks-ass.net>
References: <1367290378-29224-1-git-send-email-horms@verge.net.au>
 <1367290378-29224-2-git-send-email-horms@verge.net.au>
 <alpine.LFD.2.00.1304301011310.1700@ja.ssi.bg>
 <20130430072944.GA13959@verge.net.au>
 <alpine.LFD.2.00.1304301051260.1700@ja.ssi.bg>
 <20130501091012.GB28253@dyad.programming.kicks-ass.net>
 <20130501124637.GO3780@linux.vnet.ibm.com>
 <20130501143258.GA31577@linux.vnet.ibm.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130501143258.GA31577@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Eric Dumazet <eric.dumazet@gmail.com>, Ingo Molnar <mingo@redhat.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>

On Wed, May 01, 2013 at 07:32:58AM -0700, Paul E. McKenney wrote:
> Here is how to detect this:
> 
> 	static void inline cond_resched_rcu_lock(void)
> 	{
> 		rcu_read_unlock();
> 		WARN_ON_ONCE(rcu_read_lock_held());
> 	#ifndef CONFIG_PREEMPT_RCU
> 		cond_resched();
> 	#endif
> 		rcu_read_lock();
> 	}

The __might_sleep(__FILE__, __LINE__, PREEMPT_RCU_OFFSET) I posted in the other
email just now should deal with this.
