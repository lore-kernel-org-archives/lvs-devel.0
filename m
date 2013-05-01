From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 1/2] sched: Add cond_resched_rcu_lock() helper
Date: Wed, 1 May 2013 17:55:02 +0200
Message-ID: <20130501155501.GB7521@dyad.programming.kicks-ass.net>
References: <1367290378-29224-1-git-send-email-horms@verge.net.au>
 <1367290378-29224-2-git-send-email-horms@verge.net.au>
 <alpine.LFD.2.00.1304301011310.1700@ja.ssi.bg>
 <20130430072944.GA13959@verge.net.au>
 <alpine.LFD.2.00.1304301051260.1700@ja.ssi.bg>
 <20130501091012.GB28253@dyad.programming.kicks-ass.net>
 <alpine.LFD.2.00.1305011344320.1603@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1305011344320.1603@ja.ssi.bg>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, Eric Dumazet <eric.dumazet@gmail.com>, Ingo Molnar <mingo@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>

On Wed, May 01, 2013 at 05:22:05PM +0300, Julian Anastasov wrote:

> > static void inline cond_resched_rcu_lock(void)
> > {
> > #ifdef CONFIG_PREEMPT_RCU
> 
> 	You mean '#ifndef' here, right? But in the non-preempt
> case is using the need_resched() needed? rcu_read_unlock
> and rcu_read_lock do not generate code.

Uhm... yes!

> > 	if (need_resched()) {
> > 		rcu_read_unlock();
> > 		cond_resched();
> > 		rcu_read_lock();
> > 	}
> > #endif /* CONFIG_PREEMPT_RCU */
> > }
> > 
> > That would have an rcu_read_lock() break and voluntary preemption point for
> > non-preemptible RCU and not bother with the stuff for preemptible RCU.
> 
> 	I see. So, can we choose one of both variants:
> 
> 1. Your variant but with ifndef:
> 
> static void inline cond_resched_rcu_lock(void)
> {
> #ifndef CONFIG_PREEMPT_RCU
> 	if (need_resched()) {
> 		rcu_read_unlock();
> 		cond_resched();
> 		rcu_read_lock();
> 	}
> #endif
> }
> 
> 2. Same without need_resched because cond_resched already
> performs the same checks:
> 
> static void inline cond_resched_rcu_lock(void)
> {
> #ifndef CONFIG_PREEMPT_RCU
> 	rcu_read_unlock();
> 	cond_resched();
> 	rcu_read_lock();
> #endif
> }

Ah so the 'problem' with this last version is that it does an unconditional /
unnessecary rcu_read_unlock().

The below would be in line with all the other cond_resched*() implementations.

---
 include/linux/sched.h |  7 +++++++
 kernel/sched/core.c   | 14 ++++++++++++++
 2 files changed, 21 insertions(+)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 802a751..fd2c77f 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2449,6 +2449,13 @@ extern int __cond_resched_softirq(void);
 	__cond_resched_softirq();					\
 })
 
+extern int __cond_resched_rcu(void);
+
+#define cond_resched_rcu() ({			\
+	__might_sleep(__FILE__, __LINE__, 0);	\
+	__cond_resched_rcu();			\
+})
+
 /*
  * Does a critical section need to be broken due to another
  * task waiting?: (technically does not depend on CONFIG_PREEMPT,
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 7d7901a..2b3b4e6 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -4358,6 +4358,20 @@ int __sched __cond_resched_softirq(void)
 }
 EXPORT_SYMBOL(__cond_resched_softirq);
 
+int __sched __cond_resched_rcu(void)
+{
+#ifndef CONFIG_PREEMPT_RCU
+	if (should_resched()) {
+		rcu_read_unlock();
+		__cond_resched();
+		rcu_read_lock();
+		return 1;
+	}
+#endif
+	return 0;
+}
+EXPORT_SYMBOL(__cond_resched_rcu);
+
 /**
  * yield - yield the current processor to other threads.
  *

