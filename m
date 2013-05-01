From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 1/2] sched: Add cond_resched_rcu_lock() helper
Date: Wed, 1 May 2013 09:02:18 -0700
Message-ID: <20130501160218.GQ3780@linux.vnet.ibm.com>
References: <1367290378-29224-1-git-send-email-horms@verge.net.au>
 <1367290378-29224-2-git-send-email-horms@verge.net.au>
 <alpine.LFD.2.00.1304301011310.1700@ja.ssi.bg>
 <20130430072944.GA13959@verge.net.au>
 <alpine.LFD.2.00.1304301051260.1700@ja.ssi.bg>
 <20130501091012.GB28253@dyad.programming.kicks-ass.net>
 <20130501124637.GO3780@linux.vnet.ibm.com>
 <20130501151752.GA7521@dyad.programming.kicks-ass.net>
 <1367422195.11020.46.camel@edumazet-glaptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1367422195.11020.46.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Ingo Molnar <mingo@redhat.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>

On Wed, May 01, 2013 at 08:29:55AM -0700, Eric Dumazet wrote:
> On Wed, 2013-05-01 at 17:17 +0200, Peter Zijlstra wrote:
> > On Wed, May 01, 2013 at 05:46:37AM -0700, Paul E. McKenney wrote:
> > 
> > > If the only goal is to allow preemption, and if long grace periods are
> > > not a concern, then this alternate approach would work fine as well.
> > 
> > Hmm.. if that were the goal I'd like it to have a different name;
> > cond_resched*() has always been about preemption.
> 
> BTW, I do not remember why cond_resched() is not an empty macro
> when CONFIG_PREEMPT=y ?

My guess would be for the case where sched_preempt_enable_no_resched()
is followed some time later by cond_resched().

							Thanx, Paul

