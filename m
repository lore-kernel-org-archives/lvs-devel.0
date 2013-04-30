From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2 1/2] sched: Add cond_resched_rcu_lock() helper
Date: Tue, 30 Apr 2013 10:52:38 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1304301051260.1700@ja.ssi.bg>
References: <1367290378-29224-1-git-send-email-horms@verge.net.au> <1367290378-29224-2-git-send-email-horms@verge.net.au> <alpine.LFD.2.00.1304301011310.1700@ja.ssi.bg> <20130430072944.GA13959@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130430072944.GA13959@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>


	Hello,

On Tue, 30 Apr 2013, Simon Horman wrote:

> > > +static void inline cond_resched_rcu_lock(void)
> > > +{
> > > +	if (need_resched()) {
> > 
> > 	Ops, it should be without above need_resched.
> 
> Thanks, to clarify, just this:
> 
> static void inline cond_resched_rcu_lock(void)
> {
> 	rcu_read_unlock();
> #ifndef CONFIG_PREEMPT_RCU
> 	cond_resched();
> #endif
> 	rcu_read_lock();
> }

	Yes, thanks!

--
Julian Anastasov <ja@ssi.bg>
