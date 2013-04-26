From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 2/2] ipvs: Use cond_resched_rcu_lock() helper when dumping connections
Date: Fri, 26 Apr 2013 10:45:08 +0900
Message-ID: <1366940708-10180-3-git-send-email-horms@verge.net.au>
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

This avoids the situation where a dump of a large number of connections
may prevent scheduling for a long time while also avoiding excessive
calls to rcu_read_unlock() and rcu_read_lock().

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Julian Anastasov <ja@ssi.bg>
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
