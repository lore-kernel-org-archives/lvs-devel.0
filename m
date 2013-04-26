From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 1/2] sched: Add cond_resched_rcu_lock() helper
Date: Fri, 26 Apr 2013 10:45:07 +0900
Message-ID: <1366940708-10180-2-git-send-email-horms@verge.net.au>
References: <1366940708-10180-1-git-send-email-horms@verge.net.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1366940708-10180-1-git-send-email-horms@verge.net.au>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>, Julian Anastasov <ja@ssi.bg>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Simon Horman <horms@verge.net.au>

This is intended for use in loops which read data protected by RCU and may
have a large number of iterations.  Such an example is dumping the list of
connections known to IPVS: ip_vs_conn_array() and ip_vs_conn_seq_next().

As suggested by Eric Dumazet.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/linux/sched.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index e692a02..7eec4c7 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2787,3 +2787,12 @@ static inline unsigned long rlimit_max(unsigned int limit)
 }
 
 #endif
+
+static void inline cond_resched_rcu_lock(void)
+{
+	if (need_resched()) {
+		rcu_read_unlock();
+		cond_resched();
+		rcu_read_lock();
+	}
+}
-- 
1.8.2.1
