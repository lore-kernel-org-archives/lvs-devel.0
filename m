From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCHv2 net-next 01/15] net: add skb_dst_set_unref
Date: Sun, 10 Mar 2013 15:37:34 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1303101527530.1608@ja.ssi.bg>
References: <1362863815-5898-1-git-send-email-ja@ssi.bg> <1362863815-5898-2-git-send-email-ja@ssi.bg> <20130310.051735.1281635372029510938.davem@davemloft.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130310.051735.1281635372029510938.davem@davemloft.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, netdev@vger.kernel.org


	Hello,

On Sun, 10 Mar 2013, David Miller wrote:

> From: Julian Anastasov <ja@ssi.bg>
> Date: Sat,  9 Mar 2013 23:16:41 +0200
> 
> > 	skb_dst_set_unref will use noref version even for
> > DST_NOCACHE entries because DST_NOCACHE means dst is not
> > cached in routing structures, still dst could be cached
> > by routing users and used to produce noref instances.
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> 
> I'm fine with this approach, but I think the name of this
> interface could be better.
> 
> In fact you could do something like:
> 
> 1) Rename skb_dst_set_noref() to __skb_dst_set_noref() and add
>    a new "bool force" parameter.  DST_NOCACHE check is overriden
>    when 'force' is true.
> 
> 2) skb_dst_set_noref() is an inline that passes 'force' as false.
> 
> 3) New interface skb_dst_set_noref_force() passes 'force' as true
>    and will be used by your IPVS changes.
> 
> Then all of the RCU checks etc. happen in one shared function.

	The idea looks good, here is the implementation.
Can I use it in this form for next patchset versions?

net: add skb_dst_set_noref_force

	Rename skb_dst_set_noref to __skb_dst_set_noref and
add force flag as suggested by David Miller. The new wrapper
skb_dst_set_noref_force will force dst entries that are not
cached to be attached as skb dst without taking reference
as long as provided dst is reclaimed after RCU grace period.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/linux/skbuff.h |   35 ++++++++++++++++++++++++++++++++++-
 net/core/dst.c         |    7 ++++---
 2 files changed, 38 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 821c7f4..e8ae1d6 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -570,7 +570,40 @@ static inline void skb_dst_set(struct sk_buff *skb, struct dst_entry *dst)
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
index 35fd12f..488d53c 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -320,20 +320,21 @@ void __dst_destroy_metrics_generic(struct dst_entry *dst, unsigned long old)
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
+	if (unlikely(dst->flags & DST_NOCACHE && !force)) {
 		dst_hold(dst);
 		skb_dst_set(skb, dst);
 	} else {
-- 
1.7.3.4

