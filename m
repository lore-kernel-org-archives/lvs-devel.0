From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] ipvs: Use cond_resched_rcu_lock() helper when
 dumping connections
Date: Sat, 27 Apr 2013 09:17:32 -0700
Message-ID: <20130427161732.GA3780@linux.vnet.ibm.com>
References: <1366940708-10180-1-git-send-email-horms@verge.net.au>
 <1366940708-10180-3-git-send-email-horms@verge.net.au>
 <20130426080313.GC8669@dyad.programming.kicks-ass.net>
 <20130426154547.GC3860@linux.vnet.ibm.com>
 <20130426171948.GA31467@dyad.programming.kicks-ass.net>
 <20130426174815.GI3860@linux.vnet.ibm.com>
 <1367000815.8964.243.camel@edumazet-glaptop>
 <20130426190428.GJ3860@linux.vnet.ibm.com>
 <20130427071814.GA31700@dyad.programming.kicks-ass.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130427071814.GA31700@dyad.programming.kicks-ass.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Ingo Molnar <mingo@redhat.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>, dhaval.giani@gmail.com

On Sat, Apr 27, 2013 at 09:18:15AM +0200, Peter Zijlstra wrote:
> > In the worst case, I
> > can fire up a prio 99 kthread on each CPU and send that kthread a
> > wakeup from RCU's rcu_gp_fqs() code.
> 
> You just know that's going to be _so_ popular ;-)

;-) ;-) ;-)

I must confess that I would prefer a somewhat less heavy-handed approach.

							Thanx, Paul

