From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 2/6] ipvs: fix sparse warnings for ip_vs_conn listing
Date: Wed, 17 Apr 2013 23:50:46 +0300
Message-ID: <1366231850-22188-3-git-send-email-ja@ssi.bg>
References: <1366231850-22188-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1366231850-22188-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>

	kbuild test robot reports for sparse warnings
in commit 088339a57d6042 ("ipvs: convert connection locking"):

net/netfilter/ipvs/ip_vs_conn.c:962:13: warning: context imbalance
	in 'ip_vs_conn_array' - wrong count at exit
include/linux/rcupdate.h:326:30: warning: context imbalance in
	'ip_vs_conn_seq_next' - unexpected unlock
include/linux/rcupdate.h:326:30: warning: context imbalance in
	'ip_vs_conn_seq_stop' - unexpected unlock

	Fix it by running ip_vs_conn_array under RCU lock
to avoid conditional locking and by adding proper RCU
annotations.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_conn.c |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index de64758..a083bda 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -966,7 +966,6 @@ static void *ip_vs_conn_array(struct seq_file *seq, loff_t pos)
 	struct ip_vs_iter_state *iter = seq->private;
 
 	for (idx = 0; idx < ip_vs_conn_tab_size; idx++) {
-		rcu_read_lock();
 		hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[idx], c_list) {
 			/* __ip_vs_conn_get() is not needed by
 			 * ip_vs_conn_seq_show and ip_vs_conn_sync_seq_show
@@ -977,16 +976,19 @@ static void *ip_vs_conn_array(struct seq_file *seq, loff_t pos)
 			}
 		}
 		rcu_read_unlock();
+		rcu_read_lock();
 	}
 
 	return NULL;
 }
 
 static void *ip_vs_conn_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(RCU)
 {
 	struct ip_vs_iter_state *iter = seq->private;
 
 	iter->l = NULL;
+	rcu_read_lock();
 	return *pos ? ip_vs_conn_array(seq, *pos - 1) :SEQ_START_TOKEN;
 }
 
@@ -1006,28 +1008,24 @@ static void *ip_vs_conn_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	e = rcu_dereference(hlist_next_rcu(&cp->c_list));
 	if (e)
 		return hlist_entry(e, struct ip_vs_conn, c_list);
-	rcu_read_unlock();
 
 	idx = l - ip_vs_conn_tab;
 	while (++idx < ip_vs_conn_tab_size) {
-		rcu_read_lock();
 		hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[idx], c_list) {
 			iter->l = &ip_vs_conn_tab[idx];
 			return cp;
 		}
 		rcu_read_unlock();
+		rcu_read_lock();
 	}
 	iter->l = NULL;
 	return NULL;
 }
 
 static void ip_vs_conn_seq_stop(struct seq_file *seq, void *v)
+	__releases(RCU)
 {
-	struct ip_vs_iter_state *iter = seq->private;
-	struct hlist_head *l = iter->l;
