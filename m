From: Simon Horman <horms@verge.net.au>
Subject: [PATCH v3 1/2] sched: Add cond_resched_rcu_lock() helper
Date: Wed,  1 May 2013 17:57:52 +0900
Message-ID: <1367398673-1253-2-git-send-email-horms@verge.net.au>
References: <1367398673-1253-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1367398673-1253-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>, Julian Anastasov <ja@ssi.bg>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>, Simon Horman <horms@verge.net.au>

This is intended for use in loops which read data protected by RCU and may
have a large number of iterations.  Such an example is dumping the list of
connections known to IPVS: ip_vs_conn_array() and ip_vs_conn_seq_next().

The call to cond_resched() is guarded by #ifndef CONFIG_PREEMPT_RCU as in
the case of CONFIG_PREEMPT_RCU _rcu_read_unlock() will check to see if the
RCU core needs to be informed, so there is no need to invoke cond_resched()
in that case. Thanks to Paul E. McKenney for explaining this.

cond_resched_rcu_lock() suggested by Eric Dumazet.
ifndef guard suggested by Paul E. McKenney and Julian Anastasov.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Julian Anastasov <ja@ssi.bg>
Acked-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Simon Horman <horms@verge.net.au>

---

v3
* Remove if (need_resched()), it is no longer needed with
  the guard added in v2.

v2
* Guard the call to cond_resched() with #ifndef CONFIG_PREEMPT_RCU
---
 include/linux/sched.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index e692a02..79cfe6d 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2787,3 +2787,12 @@ static inline unsigned long rlimit_max(unsigned int limit)
 }
 
 #endif
+
+static void inline cond_resched_rcu_lock(void)
+{
+	rcu_read_unlock();
+#ifndef CONFIG_PREEMPT_RCU
+	cond_resched();
+#endif
+	rcu_read_lock();
+}
-- 
1.8.2.1

