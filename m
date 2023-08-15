From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH RFC net-next 01/14] rculist_bl: add hlist_bl_for_each_entry_continue_rcu
Date: Tue, 15 Aug 2023 20:30:18 +0300
Message-ID: <20230815173031.168344-2-ja@ssi.bg>
References: <20230815173031.168344-1-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netdev+bounces-27739-gl-netdev-2=m.gmane-mx.org@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1692120736; bh=DmUGBB67o/PyhIKOEYZ9nTkCUuQziqzsg9YKkk9WS1Q=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=EGwTMgwXjWKELpYscuTQrnwYAetTEwnXItcgVJ/NBCfGW2gsTDEKnoVCN8qG1o1z8
	 jofuF72JB/pgq+MIbzb77SS9ux2cCXRRWCuHp2F3aEgjIyqf6KuBJPhcgay3sE7zxG
	 zzx7aZYMGcXiEsERm8RnI26c2dWjyCUJokeiTRCs=
In-Reply-To: <20230815173031.168344-1-ja@ssi.bg>
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:netdev+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:netdev+unsubscribe@vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, "Paul E . McKenney" <paulmck@kernel.org>, rcu@vger.kernel.org, Dust Li <dust.li@linux.alibaba.com>, Jiejian Wu <jiejian@linux.alibaba.com>, Jiri Wiesner <jwiesner@suse.de>

Add hlist_bl_for_each_entry_continue_rcu and hlist_bl_next_rcu

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/linux/rculist_bl.h | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/include/linux/rculist_bl.h b/include/linux/rculist_bl.h
index 0b952d06eb0b..93a757793d83 100644
--- a/include/linux/rculist_bl.h
+++ b/include/linux/rculist_bl.h
@@ -24,6 +24,10 @@ static inline struct hlist_bl_node *hlist_bl_first_rcu(struct hlist_bl_head *h)
 		((unsigned long)rcu_dereference_check(h->first, hlist_bl_is_locked(h)) & ~LIST_BL_LOCKMASK);
 }
 
+/* return the next element in an RCU protected list */
+#define hlist_bl_next_rcu(node)	\
+	(*((struct hlist_bl_node __rcu **)(&(node)->next)))
+
 /**
  * hlist_bl_del_rcu - deletes entry from hash list without re-initialization
  * @n: the element to delete from the hash list.
@@ -98,4 +102,17 @@ static inline void hlist_bl_add_head_rcu(struct hlist_bl_node *n,
 		({ tpos = hlist_bl_entry(pos, typeof(*tpos), member); 1; }); \
 		pos = rcu_dereference_raw(pos->next))
 
+/**
+ * hlist_bl_for_each_entry_continue_rcu - iterate over a list continuing after
+ *   current point
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct hlist_bl_node to use as a loop cursor.
+ * @member:	the name of the hlist_bl_node within the struct.
+ */
+#define hlist_bl_for_each_entry_continue_rcu(tpos, pos, member)		\
+	for (pos = rcu_dereference_raw(hlist_bl_next_rcu(&(tpos)->member)); \
+	     pos &&							\
+	     ({ tpos = hlist_bl_entry(pos, typeof(*tpos), member); 1; }); \
+	     pos = rcu_dereference_raw(hlist_bl_next_rcu(pos)))
+
 #endif
-- 
2.41.0



