From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] ipvs: Use cond_resched_rcu_lock() helper when
 dumping connections
Date: Fri, 26 Apr 2013 08:45:47 -0700
Message-ID: <20130426154547.GC3860@linux.vnet.ibm.com>
References: <1366940708-10180-1-git-send-email-horms@verge.net.au>
 <1366940708-10180-3-git-send-email-horms@verge.net.au>
 <20130426080313.GC8669@dyad.programming.kicks-ass.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130426080313.GC8669@dyad.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: Simon Horman <horms@verge.net.au>, Eric Dumazet <eric.dumazet@gmail.com>, Julian Anastasov <ja@ssi.bg>, Ingo Molnar <mingo@redhat.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>, dhaval.giani@gmail.com

On Fri, Apr 26, 2013 at 10:03:13AM +0200, Peter Zijlstra wrote:
> On Fri, Apr 26, 2013 at 10:45:08AM +0900, Simon Horman wrote:
> 
> > @@ -975,8 +975,7 @@ static void *ip_vs_conn_array(struct seq_file *seq, loff_t pos)
> >  				return cp;
> >  			}
> >  		}
> > -		rcu_read_unlock();
> > -		rcu_read_lock();
> > +		cond_resched_rcu_lock();
> >  	}
> 
> 
> While I agree with the sentiment I do find it a somewhat dangerous construct in
> that it might become far too easy to keep an RCU reference over this break and
> thus violate the RCU premise.
> 
> Is there anything that can detect this? Sparse / cocinelle / smatch? If so it
> would be great to add this to these checkers.

I have done some crude coccinelle patterns in the past, but they are
subject to false positives (from when you transfer the pointer from
RCU protection to reference-count protection) and also false negatives
(when you atomically increment some statistic unrelated to protection).

I could imagine maintaining a per-thread count of the number of outermost
RCU read-side critical sections at runtime, and then associating that
counter with a given pointer at rcu_dereference() time, but this would
require either compiler magic or an API for using a pointer returned
by rcu_dereference().  This API could in theory be enforced by sparse.

Dhaval Giani might have some ideas as well, adding him to CC.

							Thanx, Paul
