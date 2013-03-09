From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCHv2 net-next 01/15] net: add skb_dst_set_unref
Date: Sat,  9 Mar 2013 23:16:41 +0200
Message-ID: <1362863815-5898-2-git-send-email-ja@ssi.bg>
References: <1362863815-5898-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1362863815-5898-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

	skb_dst_set_unref will use noref version even for
DST_NOCACHE entries because DST_NOCACHE means dst is not
cached in routing structures, still dst could be cached
by routing users and used to produce noref instances.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/linux/skbuff.h |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 821c7f4..4d422af 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -573,6 +573,20 @@ static inline void skb_dst_set(struct sk_buff *skb, struct dst_entry *dst)
 extern void skb_dst_set_noref(struct sk_buff *skb, struct dst_entry *dst);
 
 /**
+ * skb_dst_set_unref - sets skb dst, without a reference
+ * @skb: buffer
+ * @dst: dst entry
+ *
+ * Sets skb dst, assuming a reference was not taken on dst
+ * skb_dst_drop() should not dst_release() this dst
+ */
+static inline void skb_dst_set_unref(struct sk_buff *skb, struct dst_entry *dst)
+{
+	WARN_ON(!rcu_read_lock_held() && !rcu_read_lock_bh_held());
+	skb->_skb_refdst = (unsigned long)dst | SKB_DST_NOREF;
+}
+
+/**
  * skb_dst_is_noref - Test if skb dst isn't refcounted
  * @skb: buffer
  */
-- 
1.7.3.4

