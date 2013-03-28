From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 01/15] net: add skb_dst_set_noref_force
Date: Thu, 28 Mar 2013 14:39:30 +0900
Message-ID: <1364449184-26672-2-git-send-email-horms@verge.net.au>
References: <1364449184-26672-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1364449184-26672-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

Rename skb_dst_set_noref to __skb_dst_set_noref and
add force flag as suggested by David Miller. The new wrapper
skb_dst_set_noref_force will force dst entries that are not
cached to be attached as skb dst without taking reference
as long as provided dst is reclaimed after RCU grace period.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/linux/skbuff.h |   35 ++++++++++++++++++++++++++++++++++-
 net/core/dst.c         |    9 +++++----
 2 files changed, 39 insertions(+), 5 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index eb2106f..e56d851 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -574,7 +574,40 @@ static inline void skb_dst_set(struct sk_buff *skb, struct dst_entry *dst)
 	skb->_skb_refdst = (unsigned long)dst;
 }
 
-extern void skb_dst_set_noref(struct sk_buff *skb, struct dst_entry *dst);
+extern void __skb_dst_set_noref(struct sk_buff *skb, struct dst_entry *dst,
+				bool force);
+
+/**
+ * skb_dst_set_noref - sets skb dst, hopefully, without taking reference
+ * @skb: buffer
+ * @dst: dst entry
+ *
+ * Sets skb dst, assuming a reference was not taken on dst.
+ * If dst entry is cached, we do not take reference and dst_release
+ * will be avoided by refdst_drop. If dst entry is not cached, we take
+ * reference, so that last dst_release can destroy the dst immediately.
+ */
+static inline void skb_dst_set_noref(struct sk_buff *skb, struct dst_entry *dst)
+{
+	__skb_dst_set_noref(skb, dst, false);
+}
+
+/**
+ * skb_dst_set_noref_force - sets skb dst, without taking reference
+ * @skb: buffer
+ * @dst: dst entry
+ *
+ * Sets skb dst, assuming a reference was not taken on dst.
+ * No reference is taken and no dst_release will be called. While for
+ * cached dsts deferred reclaim is a basic feature, for entries that are
+ * not cached it is caller's job to guarantee that last dst_release for
+ * provided dst happens when nobody uses it, eg. after a RCU grace period.
+ */
+static inline void skb_dst_set_noref_force(struct sk_buff *skb,
+					   struct dst_entry *dst)
+{
+	__skb_dst_set_noref(skb, dst, true);
+}
 
 /**
  * skb_dst_is_noref - Test if skb dst isn't refcounted
diff --git a/net/core/dst.c b/net/core/dst.c
index 35fd12f..df9cc81 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -320,27 +320,28 @@ void __dst_destroy_metrics_generic(struct dst_entry *dst, unsigned long old)
 EXPORT_SYMBOL(__dst_destroy_metrics_generic);
 
 /**
- * skb_dst_set_noref - sets skb dst, without a reference
+ * __skb_dst_set_noref - sets skb dst, without a reference
  * @skb: buffer
  * @dst: dst entry
+ * @force: if force is set, use noref version even for DST_NOCACHE entries
  *
  * Sets skb dst, assuming a reference was not taken on dst
  * skb_dst_drop() should not dst_release() this dst
  */
-void skb_dst_set_noref(struct sk_buff *skb, struct dst_entry *dst)
+void __skb_dst_set_noref(struct sk_buff *skb, struct dst_entry *dst, bool force)
 {
 	WARN_ON(!rcu_read_lock_held() && !rcu_read_lock_bh_held());
 	/* If dst not in cache, we must take a reference, because
 	 * dst_release() will destroy dst as soon as its refcount becomes zero
 	 */
-	if (unlikely(dst->flags & DST_NOCACHE)) {
+	if (unlikely((dst->flags & DST_NOCACHE) && !force)) {
 		dst_hold(dst);
 		skb_dst_set(skb, dst);
 	} else {
 		skb->_skb_refdst = (unsigned long)dst | SKB_DST_NOREF;
 	}
 }
-EXPORT_SYMBOL(skb_dst_set_noref);
+EXPORT_SYMBOL(__skb_dst_set_noref);
 
 /* Dirty hack. We did it in 2.2 (in __dst_free),
  * we have _very_ good reasons not to repeat
-- 
1.7.10.4
