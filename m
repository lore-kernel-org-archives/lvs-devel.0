From: Simon Horman <horms@verge.net.au>
Subject: [PATCH ipvs-next] ipvs: Remove rcu_read_unlock();rcu_read_lock();
Date: Thu, 25 Apr 2013 10:12:33 +0900
Message-ID: <1366852353-32561-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>

It is unclear to me that there is any utility in the following:

	 rcu_read_unlock();
	 rcu_read_lock();

So this patch removes the two instances of the above from ip_vs_conn.c.

This was introduced in 7cf2eb7bccbe0d7a8ab1d1382c4faa2b3abf817f ("ipvs: fix
sparse warnings for ip_vs_conn listing") as part of cleaning up warnings
flagged by sparse.

Compile and sparse tested only.

Cc: Julian Anastasov <ja@ssi.bg>
Reported-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index a083bda..458dc68 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -975,8 +975,6 @@ static void *ip_vs_conn_array(struct seq_file *seq, loff_t pos)
 				return cp;
 			}
 		}
-		rcu_read_unlock();
-		rcu_read_lock();
 	}
 
 	return NULL;
@@ -1015,8 +1013,6 @@ static void *ip_vs_conn_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 			iter->l = &ip_vs_conn_tab[idx];
 			return cp;
 		}
-		rcu_read_unlock();
-		rcu_read_lock();
 	}
 	iter->l = NULL;
 	return NULL;
-- 
1.8.2.1

