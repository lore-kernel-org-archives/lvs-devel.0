From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] ipvs: Use cond_resched_rcu_lock() helper when
 dumping connections
Date: Fri, 26 Apr 2013 12:04:28 -0700
Message-ID: <20130426190428.GJ3860@linux.vnet.ibm.com>
References: <1366940708-10180-1-git-send-email-horms@verge.net.au>
 <1366940708-10180-3-git-send-email-horms@verge.net.au>
 <20130426080313.GC8669@dyad.programming.kicks-ass.net>
 <20130426154547.GC3860@linux.vnet.ibm.com>
 <20130426171948.GA31467@dyad.programming.kicks-ass.net>
 <20130426174815.GI3860@linux.vnet.ibm.com>
 <1367000815.8964.243.camel@edumazet-glaptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1367000815.8964.243.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Ingo Molnar <mingo@redhat.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>, dhaval.giani@gmail.com

On Fri, Apr 26, 2013 at 11:26:55AM -0700, Eric Dumazet wrote:
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

A call to rcu_barrier() only blocks on already-queued RCU callbacks, so if
there are no RCU callbacks queued in the system, it need not block at all.

But it might need to wait on some callbacks, and thus might need to
wait for a grace period.  So, is cond_resched() sufficient?
Currently, it depends:

1.	CONFIG_TINY_RCU: Here cond_resched() doesn't do anything unless
	there is at least one other process that is at and appropriate
	priority level.  So if the system has absolutely nothing else
	to do other than run the in-kernel loop containing the
	cond_resched_rcu_lock(), the grace period will never end.

	But as soon as some other process wakes up, there will be a
	context switch and the grace period will end.  Unless you
	are running at some high real-time priority, in which case
	either throttling kicks in after a second or so or you get
	what you deserve.  ;-)

	So for any reasonable workload, cond_resched() will eventually
	suffice.

2.	CONFIG_TREE_RCU without adaptive ticks (which is not yet in
	tree):  Same as #1, except that there is a greater chance
	that the eventual wakeup might happen on some other CPU.

3.	CONFIG_TREE_RCU with adaptive ticks (once it makes it into
	mainline):  After a new jiffies, RCU will kick the offending
	CPU, which will turn on the scheduling-clock interrupt.
	This won't end the grace period, but the kick could do a
	bit more if needed.

4.	CONFIG_TREE_PREEMPT_RCU:  When the next scheduling-clock
	interrupt notices that it happened in an RCU read-side
	critical section and that there is a grace period pending,
	it will set a flag in the task structure.  The next
	rcu_read_unlock() will report a quiescent state to the
	RCU core.

So perhaps RCU should do a bit more in cases #2 and #3.  It used to
send a resched IPI in this case, but if there is no reason to
reschedule, the resched IPI does nothing.  In the worst case, I
can fire up a prio 99 kthread on each CPU and send that kthread a
wakeup from RCU's rcu_gp_fqs() code.

Other thoughts?

							Thanx, Paul

