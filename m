From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/2] ipvs: Use cond_resched_rcu_lock() helper when dumping
 connections
Date: Tue, 30 Apr 2013 02:12:10 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1304300148260.1822@ja.ssi.bg>
References: <1366940708-10180-1-git-send-email-horms@verge.net.au> <1366940708-10180-3-git-send-email-horms@verge.net.au> <20130426080313.GC8669@dyad.programming.kicks-ass.net> <20130426154547.GC3860@linux.vnet.ibm.com> <20130426171948.GA31467@dyad.programming.kicks-ass.net>
 <20130426174815.GI3860@linux.vnet.ibm.com> <1367000815.8964.243.camel@edumazet-glaptop> <alpine.LFD.2.00.1304271342260.1633@ja.ssi.bg> <20130427162049.GB3780@linux.vnet.ibm.com> <alpine.LFD.2.00.1304292356220.1822@ja.ssi.bg>
 <20130429213002.GP3780@linux.vnet.ibm.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130429213002.GP3780@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Simon Horman <horms@verge.net.au>, Ingo Molnar <mingo@redhat.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>, dhaval.giani@gmail.com


	Hello,

On Mon, 29 Apr 2013, Paul E. McKenney wrote:

> On Tue, Apr 30, 2013 at 12:08:18AM +0300, Julian Anastasov wrote:
> > 
> > 	Hello,
> > 
> > On Sat, 27 Apr 2013, Paul E. McKenney wrote:
> > 
> > > I would instead suggest something like:
> > > 
> > > #ifndef CONFIG_PREEMPT_RCU
> > > 
> > > But yes, in the CONFIG_PREEMPT_RCU case, the cond_resched() is not
> > > needed.
> > 
> > 	Hm, is this correct? If I follow the ifdefs
> > preempt_schedule is called when CONFIG_PREEMPT is
> > defined _and_ CONFIG_PREEMPT_RCU is not defined.
> > Your example for CONFIG_PREEMPT_RCU is the opposite to this?
> 
> Yep, I really did intend to say "#ifndef CONFIG_PREEMPT_RCU".
> 
> A couple of things to keep in mind:
> 
> 1.	Although rcu_read_unlock() does map to preempt_enable() for
> 	CONFIG_TINY_RCU and CONFIG_TREE_RCU, the current Kconfig refuses
> 	to allow either CONFIG_TINY_RCU or CONFIG_TREE_RCU to be selected
> 	if CONFIG_PREEMPT=y.

	I see, CONFIG_PREEMPT_RCU depends on CONFIG_PREEMPT

> 2.	In the CONFIG_PREEMPT_RCU case, __rcu_read_unlock() will check
> 	to see if the RCU core needs to be informed, so there is no
> 	need to invoke cond_resched() in that case.

	OK

> 3.	If we drop your "|| defined(CONFIG_PREEMPT_RCU)", we get an
> 	almost-synonym for my "#ifndef CONFIG_PREEMPT_RCU".  The "almost"
> 	applies to older kernels due to the possibility of having a
> 	CONFIG_TINY_PREEMPT_RCU kernel -- but this possibility is going
> 	away soon.
> 
> Make sense?

	Yes, thanks for the explanation!

	Simon, so lets do it as suggested by Eric and Paul:

	rcu_read_unlock();
#ifndef CONFIG_PREEMPT_RCU
	cond_resched();
#endif
	rcu_read_lock();

Regards

--
Julian Anastasov <ja@ssi.bg>
