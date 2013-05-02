From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2 1/2] sched: Add cond_resched_rcu_lock() helper
Date: Thu, 2 May 2013 22:24:55 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1305022211420.25417@ja.ssi.bg>
References: <1367290378-29224-2-git-send-email-horms@verge.net.au> <alpine.LFD.2.00.1304301011310.1700@ja.ssi.bg> <20130430072944.GA13959@verge.net.au> <alpine.LFD.2.00.1304301051260.1700@ja.ssi.bg> <20130501091012.GB28253@dyad.programming.kicks-ass.net>
 <alpine.LFD.2.00.1305011344320.1603@ja.ssi.bg> <20130501155501.GB7521@dyad.programming.kicks-ass.net> <alpine.LFD.2.00.1305012004360.3397@ja.ssi.bg> <20130502072623.GE7521@dyad.programming.kicks-ass.net> <alpine.LFD.2.00.1305021848450.31548@ja.ssi.bg>
 <20130502173257.GX3780@linux.vnet.ibm.com> <alpine.LFD.2.00.1305022140020.31548@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1305022140020.31548@ja.ssi.bg>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Simon Horman <horms@verge.net.au>, Eric Dumazet <eric.dumazet@gmail.com>, Ingo Molnar <mingo@redhat.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>


	Hello,

On Thu, 2 May 2013, Julian Anastasov wrote:

> 	Note that I'm testing on some 9-year old
> UP system, i.e. 1 CPU. Now I enabled SMP to test CONFIG_TREE_RCU
> and the results are same. I think, it should be just like
> the TINY_RCU in terms of these debuggings (non-preempt). Extra 
> rcu_read_lock gives me "Illegal context switch in RCU read-side
> critical section" in addition to the "BUG: sleeping function
> called from invalid context" message.

	Just to clarify about the test with extra
rcu_read_lock because above paragraph is very confusing:

- The __might_sleep call with PREEMPT_ACTIVE | PREEMPT_RCU_OFFSET
just warns with "BUG: sleeping function called from invalid context"
because its rcu_sleep_check is silenced. We match the
nesting depth only.

- but __cond_resched -> __schedule -> schedule_debug warns about
the extra rcu_read_lock() with "BUG: scheduling while atomic" and
then with "Illegal context switch in RCU read-side critical section"
from rcu_sleep_check(0).

Regards

--
Julian Anastasov <ja@ssi.bg>
