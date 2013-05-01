From: Simon Horman <horms@verge.net.au>
Subject: [PATCH v3 2/2] ipvs: Use cond_resched_rcu_lock() helper when dumping connections
Date: Wed,  1 May 2013 17:57:53 +0900
Message-ID: <1367398673-1253-3-git-send-email-horms@verge.net.au>
References: <1367398673-1253-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1367398673-1253-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>, Julian Anastasov <ja@ssi.bg>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>, Simon Horman <horms@verge.net.au>, Ingo Molnar <mingo@kernel.org>

This avoids the situation where a dump of a large number of connections
may prevent scheduling for a long time while also avoiding excessive
calls to rcu_read_unlock() and rcu_read_lock().

Note that in the case of !CONFIG_PREEMPT_RCU this will
add a call to cond_resched().

Compile tested only.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index a083bda..42a7b33 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -975,8 +975,7 @@ static void *ip_vs_conn_array(struct seq_file *seq, loff_t pos)
 				return cp;
 			}
 		}
-		rcu_read_unlock();
-		rcu_read_lock();
+		cond_resched_rcu_lock();
 	}
 
 	return NULL;
@@ -1015,8 +1014,7 @@ static void *ip_vs_conn_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 			iter->l = &ip_vs_conn_tab[idx];
 			return cp;
 		}
-		rcu_read_unlock();
-		rcu_read_lock();
+		cond_resched_rcu_lock();
 	}
 	iter->l = NULL;
 	return NULL;
-- 
1.8.2.1

