Received: from azure-sdnproxy.icoremail.net (azure-sdnproxy.icoremail.net [13.75.44.102])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 8FA903F4DE2;
	Mon, 13 Jul 2026 11:53:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=13.75.44.102
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783943613; cv=none; b=HTouJ8k+Yy/r4Bw3SoGDIk9ExkNDfvut3Ldju+Fxa3hFnJ0JMmQUH0Hr87hPwWFjWa2MdgkKpQxrzGa64punBRZsG2PbXcR4eefqal2bIeJ8f0AUU3iZsV8dSUY1VyWIhPqQJ0jgaHkCizLYZliA5bybTnGaxvtrgmdXZhGW9uw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783943613; c=relaxed/simple;
	bh=ehmlUeTn+CCUoBayodx9rewfyaxcM/G9JGvga08rz7w=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Wkw78dvQCCezQZZ5xGSANrh6T4yRfILn5ooCZTX/LKfYbMaSgdY3+nJlGHYEjh7FsEnxm/juvGc8XE5P8ecPh/Rn/JJA3tLFtxaXMQVIXBkN7Aj4qbxJvdznH7TV+1AfZeycfvu2jlzQsGgIh2iwvZA415HrQ6rDs6eFyMx4ACo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=lzu.edu.cn; spf=pass smtp.mailfrom=lzu.edu.cn; arc=none smtp.client-ip=13.75.44.102
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=lzu.edu.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lzu.edu.cn
Received: from enjou-Legion-Y7000P-2019 (unknown [123.114.53.210])
	by app1 (Coremail) with SMTP id ygmowAAXOsSU0VRqvicCAQ--.58336S4;
	Mon, 13 Jul 2026 19:53:07 +0800 (CST)
From: Ren Wei <n05ec@lzu.edu.cn>
To: lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Cc: horms@verge.net.au,
	ja@ssi.bg,
	pablo@netfilter.org,
	fw@strlen.de,
	phil@nwl.cc,
	nick@loadbalancer.org,
	kaber@trash.net,
	yuantan098@gmail.com,
	yifanwucs@gmail.com,
	tomapufckgml@gmail.com,
	bird@lzu.edu.cn,
	roxy520tt@gmail.com,
	n05ec@lzu.edu.cn
Subject: [PATCH v2 2/2] ipvs: adjust double hashing when fwd method changes
Date: Mon, 13 Jul 2026 19:52:33 +0800
Message-ID: <f5b5a291ad1546ac9b3acd762f628a6c4c3b78ff.1783917666.git.roxy520tt@gmail.com>
X-Mailer: git-send-email 2.51.0
In-Reply-To: <cover.1783917666.git.roxy520tt@gmail.com>
References: <cover.1783917666.git.roxy520tt@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-CM-TRANSID:ygmowAAXOsSU0VRqvicCAQ--.58336S4
X-Coremail-Antispam: 1UD129KBjvJXoW3Cw4xAr13ury5WFWfuFy8Xwb_yoWDtw48pa
	yYgrZxtFZ2qF9YgF4xJwsxZrsYkw1vkasFyw1fG34rt34DWr1YyFZ7GFWSkF18CanrZr1U
	Jr4Sga4Yka98Z3DanT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUU9S1xkIjI8I6I8E6xAIw20EY4v20xvaj40_Wr0E3s1l1IIY67AE
	w4v_Jr0_Jr4l8cAvFVAK0II2c7xJM28CjxkF64kEwVA0rcxSw2x7M28EF7xvwVC0I7IYx2
	IY67AKxVW5JVW7JwA2z4x0Y4vE2Ix0cI8IcVCY1x0267AKxVWxJVW8Jr1l84ACjcxK6I8E
	87Iv67AKxVW0oVCq3wA2z4x0Y4vEx4A2jsIEc7CjxVAFwI0_GcCE3s1le2I262IYc4CY6c
	8Ij28IcVAaY2xG8wAqx4xG64xvF2IEw4CE5I8CrVC2j2WlYx0E2Ix0cI8IcVAFwI0_Jr0_
	Jr4lYx0Ex4A2jsIE14v26r1j6r4UMcvjeVCFs4IE7xkEbVWUJVW8JwACjcxG0xvY0x0EwI
	xGrwACjI8F5VA0II8E6IAqYI8I648v4I1lFIxGxcIEc7CjxVA2Y2ka0xkIwI1lc7CjxVAa
	w2AFwI0_Jw0_GFyl42xK82IYc2Ij64vIr41l42xK82IY6x8ErcxFaVAv8VW8WwCFx2IqxV
	CFs4IE7xkEbVWUJVW8JwC20s026c02F40E14v26r1j6r18MI8I3I0E7480Y4vE14v26r10
	6r1rMI8E67AF67kF1VAFwI0_Jw0_GFylIxkGc2Ij64vIr41lIxAIcVC0I7IYx2IY67AKxV
	WUJVWUCwCI42IY6xIIjxv20xvEc7CjxVAFwI0_Gr0_Cr1lIxAIcVCF04k26cxKx2IYs7xG
	6r1j6r1xMIIF0xvEx4A2jsIE14v26r1j6r4UMIIF0xvEx4A2jsIEc7CjxVAFwI0_Gr0_Gr
	1UYxBIdaVFxhVjvjDU0xZFpf9x0JUd-B_UUUUU=
X-CM-SenderInfo: zqqvvuo6o23hxhgxhubq/1tbiAQEHCWpUn9kElgAAsk

From: Julian Anastasov <ja@ssi.bg>

Synced conns can be created with one forwarding method
and later updated with different one after the dest
server is configured. This needs adjusting the hashing
for node hn1 because only MASQ supports double hashing.

Modify conn_tab_lock() to support seeking for hash node
hn0 together with adding for hn1. By this way we can
safely modify the forwarding method and hn1.hash_key
under bucket lock for the first node hn0. The forwarding
method is also protected by cp->lock as it is part of
cp->flags.

Fix the usage of stale idx/idx2 values in conn_tab_lock
after jumping to the retry label. Instead, use idx/idx2
values just to order the locking for the old/new tables.

Reported-by: Zhiling Zou <roxy520tt@gmail.com>
Link: https://lore.kernel.org/lvs-devel/1b914f41d725bc064c9ba9830dc8169329737270.1782540466.git.roxy520tt@gmail.com/
Link: https://sashiko.dev/#/patchset/CALMqdkR704S2BG_QD_bgHTFp2%2B1QCi7n0T4zoZyTo8mDZevYSA%40mail.gmail.com
Fixes: f20c73b0460d ("ipvs: use more keys for connection hashing")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_conn.c | 189 +++++++++++++++++++++++++-------
 1 file changed, 147 insertions(+), 42 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 0682cec5f0a7..36c5cba03f5b 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -70,25 +70,45 @@ static struct kmem_cache *ip_vs_conn_cachep __read_mostly;
  * bucket or hash table
  * - hash table resize works like rehash but always rehashes into new table
  * - bit lock on bucket serializes all operations that modify the chain
+ * - on resize, bucket from the old table is locked before bucket from the
+ * new table
  * - cp->lock protects conn fields like cp->flags, cp->dest
  */
 
-/* Lock conn_tab bucket for conn hash/unhash, not for rehash */
+/**
+ * conn_tab_lock - Lock conn_tab buckets for conn hash/unhash, not for rehash
+ * @t:		hash table for hn0, new_tbl when new_hash=true
+ * @t2:		hash table for hn1, new_tbl when new_hash2=true
+ * @cp:		connection
+ * @hash_key:	hash key for hn0
+ * @hash_key2:	hash key for hn1
+ * @use2:	using hn1 (double hashing) based on the forwarding method
+ * @new_hash:	mode for hn0, hash node (true) or seek node (false)
+ * @new_hash2:	mode for hn1, hash node (true) or seek node (false)
+ * @head_ret:	returned head for hn0
+ * @head2_ret:	returned head for hn1
+ *
+ * We support 3 modes:
+ * - seek mode for both nodes, used for unhashing
+ * - hash mode for both nodes, used for hashing
+ * - seek hn0 and hash hn1, used when forwarding method is changed
+ */
 static __always_inline void
-conn_tab_lock(struct ip_vs_rht *t, struct ip_vs_conn *cp, u32 hash_key,
-	      u32 hash_key2, bool use2, bool new_hash,
-	      struct hlist_bl_head **head_ret, struct hlist_bl_head **head2_ret)
+conn_tab_lock(struct ip_vs_rht *t, struct ip_vs_rht *t2, struct ip_vs_conn *cp,
+	      u32 hash_key, u32 hash_key2, bool use2, bool new_hash,
+	      bool new_hash2, struct hlist_bl_head **head_ret,
+	      struct hlist_bl_head **head2_ret)
 {
 	struct hlist_bl_head *head, *head2;
 	u32 hash_key_new, hash_key_new2;
-	struct ip_vs_rht *t2 = t;
-	u32 idx, idx2;
+	int idx = 0, idx2 = 0;
+
+	/* Advance idx2 when new_hash is not set but hash_key2
+	 * is for new table
+	 */
+	if (new_hash2 && use2 && t != t2)
+		idx2++;
 
-	idx = hash_key & t->mask;
-	if (use2)
-		idx2 = hash_key2 & t->mask;
-	else
-		idx2 = idx;
 	if (!new_hash) {
 		/* We need to lock the bucket in the right table */
 
@@ -100,46 +120,45 @@ conn_tab_lock(struct ip_vs_rht *t, struct ip_vs_conn *cp, u32 hash_key,
 			 * both nodes in different tables, use idx/idx2
 			 * for proper lock ordering for heads.
 			 */
-			idx = hash_key & t->mask;
-			idx |= IP_VS_RHT_TABLE_ID_MASK;
-		}
-		if (use2) {
-			if (!ip_vs_rht_same_table(t2, hash_key2)) {
-				/* It is already moved to new table */
-				t2 = rcu_dereference(t2->new_tbl);
-				idx2 = hash_key2 & t2->mask;
-				idx2 |= IP_VS_RHT_TABLE_ID_MASK;
-			}
-		} else {
-			idx2 = idx;
+			idx++;
 		}
 	}
+	if (use2 && !new_hash2 && !ip_vs_rht_same_table(t2, hash_key2)) {
+		/* It is already moved to new table */
+		t2 = rcu_dereference(t2->new_tbl);
+		idx2++;
+	}
 
+	if (!use2)
+		idx2 = idx;
 	head = t->buckets + (hash_key & t->mask);
 	head2 = use2 ? t2->buckets + (hash_key2 & t2->mask) : head;
 
-	local_bh_disable();
-	/* Do not touch seqcount, this is a safe operation */
-
-	if (idx <= idx2) {
+	if (idx > idx2 || (head > head2 && idx == idx2)) {
+		hlist_bl_lock(head2);
 		hlist_bl_lock(head);
-		if (head != head2)
-			hlist_bl_lock(head2);
 	} else {
-		hlist_bl_lock(head2);
 		hlist_bl_lock(head);
+		if (head != head2)
+			hlist_bl_lock(head2);
 	}
 	if (!new_hash) {
+		bool changed;
+
 		/* Ensure hash_key is read under lock */
 		hash_key_new = READ_ONCE(cp->hn0.hash_key);
-		hash_key_new2 = READ_ONCE(cp->hn1.hash_key);
+		changed = hash_key != hash_key_new;
+		if (use2 && !new_hash2) {
+			hash_key_new2 = READ_ONCE(cp->hn1.hash_key);
+			changed |= hash_key2 != hash_key_new2;
+		} else {
+			hash_key_new2 = hash_key2;
+		}
 		/* Hash changed ? */
-		if (hash_key != hash_key_new ||
-		    (hash_key2 != hash_key_new2 && use2)) {
+		if (changed) {
 			if (head != head2)
 				hlist_bl_unlock(head2);
 			hlist_bl_unlock(head);
-			local_bh_enable();
 			hash_key = hash_key_new;
 			hash_key2 = hash_key_new2;
 			goto retry;
@@ -155,7 +174,6 @@ static inline void conn_tab_unlock(struct hlist_bl_head *head,
 	if (head != head2)
 		hlist_bl_unlock(head2);
 	hlist_bl_unlock(head);
-	local_bh_enable();
 }
 
 static void ip_vs_conn_expire(struct timer_list *t);
@@ -268,8 +286,9 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
 		use2 = false;
 	}
 
-	conn_tab_lock(t, cp, hash_key, hash_key2, use2, true /* new_hash */,
-		      &head, &head2);
+	local_bh_disable();
+	conn_tab_lock(t, t, cp, hash_key, hash_key2, use2, true /* new_hash */,
+		      true /* new_hash2 */, &head, &head2);
 
 	cp->flags |= IP_VS_CONN_F_HASHED;
 	WRITE_ONCE(cp->hn0.hash_key, hash_key);
@@ -280,6 +299,7 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
 		hlist_bl_add_head_rcu(&cp->hn1.node, head2);
 
 	conn_tab_unlock(head, head2);
+	local_bh_enable();
 	ret = 1;
 
 	/* Schedule resizing if load increases */
@@ -306,18 +326,20 @@ static inline bool ip_vs_conn_unlink(struct ip_vs_conn *cp)
 		return refcount_dec_if_one(&cp->refcnt);
 
 	rcu_read_lock();
+	local_bh_disable();
 
 	t = rcu_dereference(ipvs->conn_tab);
 	hash_key = READ_ONCE(cp->hn0.hash_key);
 	hash_key2 = READ_ONCE(cp->hn1.hash_key);
 	use2 = ip_vs_conn_use_hash2(cp);
 
-	conn_tab_lock(t, cp, hash_key, hash_key2, use2, false /* new_hash */,
-		      &head, &head2);
+	conn_tab_lock(t, t, cp, hash_key, hash_key2, use2, false /* new_hash */,
+		      false /* new_hash2 */, &head, &head2);
 
 	if (cp->flags & IP_VS_CONN_F_HASHED) {
 		/* Decrease refcnt and unlink conn only if we are last user */
-		if (refcount_dec_if_one(&cp->refcnt)) {
+		if (use2 == ip_vs_conn_use_hash2(cp) &&
+		    refcount_dec_if_one(&cp->refcnt)) {
 			hlist_bl_del_rcu(&cp->hn0.node);
 			if (use2)
 				hlist_bl_del_rcu(&cp->hn1.node);
@@ -328,6 +350,7 @@ static inline bool ip_vs_conn_unlink(struct ip_vs_conn *cp)
 
 	conn_tab_unlock(head, head2);
 
+	local_bh_enable();
 	rcu_read_unlock();
 
 	return ret;
@@ -632,6 +655,7 @@ void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport)
 	int ntbl;
 	int dir;
 
+restart:
 	/* No packets from inside, so we can do it in 2 steps. */
 	dir = use2 ? 1 : 0;
 
@@ -686,6 +710,23 @@ void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport)
 	/* Protect the cp->flags modification */
 	spin_lock_bh(&cp->lock);
 
+	/* Recheck the forwarding method under lock */
+	if (use2 != ip_vs_conn_use_hash2(cp)) {
+		use2 = !use2;
+		if (use2) {
+			spin_unlock_bh(&cp->lock);
+			/* Restart with new use2 value */
+			goto restart;
+		}
+		if (dir) {
+			/* Not started yet, so just skip dir 1 */
+			spin_unlock_bh(&cp->lock);
+			dir--;
+			goto next_dir;
+		}
+		/* Just finish dir 0 */
+	}
+
 	/* Lock seqcount only for the old bucket, even if we are on new table
 	 * because it affects the del operation, not the adding.
 	 */
@@ -752,6 +793,61 @@ void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport)
 		goto next_dir;
 }
 
+/* Change forwarding method for hashed conn */
+static void ip_vs_conn_change_fwd_mask(struct ip_vs_conn *cp, u32 new_flags)
+{
+	struct netns_ipvs *ipvs = cp->ipvs;
+	struct hlist_bl_head *head, *head2;
+	u32 hash2, hash_key, hash_key2;
+	struct ip_vs_rht *t, *t2;
+
+	/* See ip_vs_conn_use_hash2() for reference */
+	if ((cp->flags & IP_VS_CONN_F_TEMPLATE) ||
+	    /* No change in double hashing ? */
+	    (IP_VS_FWD_METHOD(cp) == IP_VS_CONN_F_MASQ) ==
+	    ((new_flags & IP_VS_CONN_F_FWD_MASK) == IP_VS_CONN_F_MASQ)) {
+		cp->flags = new_flags;
+		return;
+	}
+	t = rcu_dereference(ipvs->conn_tab);
+	if (ip_vs_conn_use_hash2(cp)) {
+		/* Stop double hashing */
+		hash_key = READ_ONCE(cp->hn0.hash_key);
+		hash_key2 = READ_ONCE(cp->hn1.hash_key);
+
+		conn_tab_lock(t, t, cp, hash_key, hash_key2, true /* use2 */,
+			      false /* new_hash */, false /* new_hash2 */,
+			      &head, &head2);
+
+		/* Keep both hash keys in same table */
+		hash_key = READ_ONCE(cp->hn0.hash_key);
+		WRITE_ONCE(cp->hn1.hash_key, hash_key);
+		hlist_bl_del_rcu(&cp->hn1.node);
+		cp->flags = new_flags;
+
+		conn_tab_unlock(head, head2);
+	} else {
+		/* Start double hashing */
+
+		hash_key = READ_ONCE(cp->hn0.hash_key);
+
+		t2 = rcu_dereference(t->new_tbl);
+		hash2 = ip_vs_conn_hashkey_conn(t2, cp, true);
+		hash_key2 = ip_vs_rht_build_hash_key(t2, hash2);
+
+		/* Change the forwarding method under locked hn0 */
+		conn_tab_lock(t, t2, cp, hash_key, hash_key2, true /* use2 */,
+			      false /* new_hash */, true /* new_hash2 */,
+			      &head, &head2);
+
+		WRITE_ONCE(cp->hn1.hash_key, hash_key2);
+		cp->flags = new_flags;
+		hlist_bl_add_head_rcu(&cp->hn1.node, head2);
+
+		conn_tab_unlock(head, head2);
+	}
+}
+
 /* Get default load factor to map conn_count/u_thresh to t->size */
 static int ip_vs_conn_default_load_factor(struct netns_ipvs *ipvs)
 {
@@ -1024,9 +1120,18 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 			conn_flags &= ~IP_VS_CONN_F_INACTIVE;
 		/* connections inherit forwarding method from dest */
 		flags &= ~(IP_VS_CONN_F_FWD_MASK | IP_VS_CONN_F_NOOUTPUT);
+		flags |= conn_flags;
+		/* Changing forwarding method for hashed conn can
+		 * happen only under locks
+		 */
+		if (cp->flags & IP_VS_CONN_F_HASHED)
+			ip_vs_conn_change_fwd_mask(cp, flags);
+		else
+			cp->flags = flags;
+	} else {
+		flags |= conn_flags;
+		cp->flags = flags;
 	}
-	flags |= conn_flags;
-	cp->flags = flags;
 	cp->dest = dest;
 
 	IP_VS_DBG_BUF(7, "Bind-dest %s c:%s:%d v:%s:%d "
-- 
2.43.0

