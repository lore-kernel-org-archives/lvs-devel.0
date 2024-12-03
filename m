Received: from Chamillionaire.breakpoint.cc (Chamillionaire.breakpoint.cc [91.216.245.30])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3DDE12E3EE;
	Tue,  3 Dec 2024 11:20:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=91.216.245.30
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1733224856; cv=none; b=EYw9x58IX1EDSHJi2KSrCsN2bqI9lpLcIf9RU/PM1fht/pPlNKKWHvxwAPSIvjMtf3pCGIiBQYN2hedPpGUAtfguKFE+okFmtlznUdDLchT6u8oKWrB2iw3j7eg5m5WPtFcMtuXw/rBZOrN8BpfiLbkj0n4v3AE6ZWo7vaTdkeI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1733224856; c=relaxed/simple;
	bh=mZaCnhhVXLdobmbsL6owS6DX9G3bb+SkPA5Ax5DGX3Q=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=oy4uAxlV0+sLm+ZwfTNHoLTYEIsP+XoIIDcSmqA98CnQ3eIvR6eMz4CxiM+JhveSXxwx9lYdjF2TmyTEezO3BC1ip2x/jq8faKT70aP5gZyg9UzeEIJOBJOYuYBJcW7CdwqsMln11FQN3qMd4gq8/832q/Z6z/mTJDaNMu25ZG8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=strlen.de; spf=pass smtp.mailfrom=breakpoint.cc; arc=none smtp.client-ip=91.216.245.30
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=strlen.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=breakpoint.cc
Received: from fw by Chamillionaire.breakpoint.cc with local (Exim 4.92)
	(envelope-from <fw@breakpoint.cc>)
	id 1tIQxM-0006Cn-Sn; Tue, 03 Dec 2024 12:20:40 +0100
From: Florian Westphal <fw@strlen.de>
To: <netfilter-devel@vger.kernel.org>
Cc: horms@verge.net.au,
	ja@ssi.bg,
	lvs-devel@vger.kernel.org,
	Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next] ipvs: speed up reads from ip_vs_conn proc file
Date: Tue,  3 Dec 2024 12:08:30 +0100
Message-ID: <20241203110840.10411-1-fw@strlen.de>
X-Mailer: git-send-email 2.45.2
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Reading is very slow because ->start() performs a linear re-scan of the
entire hash table until it finds the successor to the last dumped
element.  The current implementation uses 'pos' as the 'number of
elements to skip, then does linear iteration until it has skipped
'pos' entries.

Store the last bucket and the number of elements to skip in that
bucket instead, so we can resume from bucket b directly.

before this patch, its possible to read ~35k entries in one second, but
each read() gets slower as the number of entries to skip grows:

time timeout 60 cat /proc/net/ip_vs_conn > /tmp/all; wc -l /tmp/all
real    1m0.007s
user    0m0.003s
sys     0m59.956s
140386 /tmp/all

Only ~100k more got read in remaining the remaining 59s, and did not get
nowhere near the 1m entries that are stored at the time.

after this patch, dump completes very quickly:
time cat /proc/net/ip_vs_conn > /tmp/all; wc -l /tmp/all
real    0m2.286s
user    0m0.004s
sys     0m2.281s
1000001 /tmp/all

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/netfilter/ipvs/ip_vs_conn.c | 50 ++++++++++++++++++---------------
 1 file changed, 28 insertions(+), 22 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 7aba4760bbff..73f3dac159bb 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1046,28 +1046,35 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p, int dest_af,
 #ifdef CONFIG_PROC_FS
 struct ip_vs_iter_state {
 	struct seq_net_private	p;
-	struct hlist_head	*l;
+	unsigned int		bucket;
+	unsigned int		skip_elems;
 };
 
-static void *ip_vs_conn_array(struct seq_file *seq, loff_t pos)
+static void *ip_vs_conn_array(struct ip_vs_iter_state *iter)
 {
 	int idx;
 	struct ip_vs_conn *cp;
-	struct ip_vs_iter_state *iter = seq->private;
 
-	for (idx = 0; idx < ip_vs_conn_tab_size; idx++) {
+	for (idx = iter->bucket; idx < ip_vs_conn_tab_size; idx++) {
+		unsigned int skip = 0;
+
 		hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[idx], c_list) {
 			/* __ip_vs_conn_get() is not needed by
 			 * ip_vs_conn_seq_show and ip_vs_conn_sync_seq_show
 			 */
-			if (pos-- == 0) {
-				iter->l = &ip_vs_conn_tab[idx];
+			if (skip >= iter->skip_elems) {
+				iter->bucket = idx;
 				return cp;
 			}
+
+			++skip;
 		}
+
+		iter->skip_elems = 0;
 		cond_resched_rcu();
 	}
 
+	iter->bucket = idx;
 	return NULL;
 }
 
@@ -1076,9 +1083,14 @@ static void *ip_vs_conn_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	struct ip_vs_iter_state *iter = seq->private;
 
-	iter->l = NULL;
 	rcu_read_lock();
-	return *pos ? ip_vs_conn_array(seq, *pos - 1) :SEQ_START_TOKEN;
+	if (*pos == 0) {
+		iter->skip_elems = 0;
+		iter->bucket = 0;
+		return SEQ_START_TOKEN;
+	}
+
+	return ip_vs_conn_array(iter);
 }
 
 static void *ip_vs_conn_seq_next(struct seq_file *seq, void *v, loff_t *pos)
@@ -1086,28 +1098,22 @@ static void *ip_vs_conn_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	struct ip_vs_conn *cp = v;
 	struct ip_vs_iter_state *iter = seq->private;
 	struct hlist_node *e;
-	struct hlist_head *l = iter->l;
-	int idx;
 
 	++*pos;
 	if (v == SEQ_START_TOKEN)
-		return ip_vs_conn_array(seq, 0);
+		return ip_vs_conn_array(iter);
 
 	/* more on same hash chain? */
 	e = rcu_dereference(hlist_next_rcu(&cp->c_list));
-	if (e)
+	if (e) {
+		iter->skip_elems++;
 		return hlist_entry(e, struct ip_vs_conn, c_list);
-
-	idx = l - ip_vs_conn_tab;
-	while (++idx < ip_vs_conn_tab_size) {
-		hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[idx], c_list) {
-			iter->l = &ip_vs_conn_tab[idx];
-			return cp;
-		}
-		cond_resched_rcu();
 	}
-	iter->l = NULL;
-	return NULL;
+
+	iter->skip_elems = 0;
+	iter->bucket++;
+
+	return ip_vs_conn_array(iter);
 }
 
 static void ip_vs_conn_seq_stop(struct seq_file *seq, void *v)
-- 
2.45.2

