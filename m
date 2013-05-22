From: Simon Horman <horms@verge.net.au>
Subject: [PATCH ipvs-next v3 1/2] sched: add cond_resched_rcu() helper
Date: Wed, 22 May 2013 14:50:31 +0900
Message-ID: <1369201832-17163-2-git-send-email-horms@verge.net.au>
References: <1369201832-17163-1-git-send-email-horms@verge.net.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369201832-17163-1-git-send-email-horms@verge.net.au>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>, Julian Anastasov <ja@ssi.bg>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>, Simon Horman <horms@verge.net.au>

This is intended for use in loops which read data protected by RCU and may
have a large number of iterations.  Such an example is dumping the list of
connections known to IPVS: ip_vs_conn_array() and ip_vs_conn_seq_next().

The benefits are for CONFIG_PREEMPT_RCU=y where we save CPU cycles
by moving rcu_read_lock and rcu_read_unlock out of large loops
but still allowing the current task to be preempted after every
loop iteration for the CONFIG_PREEMPT_RCU=n case.

The call to cond_resched() is not needed when CONFIG_PREEMPT_RCU=y.
Thanks to Paul E. McKenney for explaining this and for the
final version that checks the context with CONFIG_DEBUG_ATOMIC_SLEEP=y
for all possible configurations.

The function can be empty in the CONFIG_PREEMPT_RCU case,
rcu_read_lock and rcu_read_unlock are not needed in this case
because the task can be preempted on indication from scheduler.
Thanks to Peter Zijlstra for catching this and for his help
in trying a solution that changes __might_sleep.

Initial cond_resched_rcu_lock() function suggested by Eric Dumazet.

Tested-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/linux/sched.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index e692a02..2080446 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2608,6 +2608,15 @@ extern int __cond_resched_softirq(void);
 	__cond_resched_softirq();					\
 })
 
+static inline void cond_resched_rcu(void)
+{
+#if defined(CONFIG_DEBUG_ATOMIC_SLEEP) || !defined(CONFIG_PREEMPT_RCU)
+	rcu_read_unlock();
+	cond_resched();
+	rcu_read_lock();
+#endif
+}
+
 /*
  * Does a critical section need to be broken due to another
  * task waiting?: (technically does not depend on CONFIG_PREEMPT,
-- 
1.8.2.1
