From: David Windsor <dwindsor@gmail.com>
Subject: [PATCH v2 net] net: free ip_vs_dest structs when refcnt=0
Date: Mon, 23 Jan 2017 22:24:29 -0500
Message-ID: <1485228269-21758-1-git-send-email-dwindsor@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=8F9jr5FJB3a3e9o/6jAD8YR9ym42JnyrdKAYSuNcYiw=;
        b=EJxdE51hoDWVni/SQvJR9p4izPwDQiuA3CIhuRXJSgI8rv7/UjdN91fH6XbvG0pHDy
         haKX6iCqUs9U8PsxSKwzrMAKTv+FBM5P458Ur/GEWF/tKq6/KUDRKLzvT5IZAeM6D7QX
         XH9HaZqsFwDkTE/NAM1t1dfH9cLI4vdFeXXsugBdkgEKl8pIhYfn9MxTcZX+eBxkRSag
         gMVKnFbY3hv5vmfPGbR8HnS2PsT293oyibcTXVhOGiH/7LtDZf4GGB6uz5+0j5hGEz2Q
         DTHsZZz68W2yQHsV33d7QxVc6eJ2KTNlTHkAjc4qQWFXmlXLdFIx3UUyezydqJ7TyS3D
         Et0A==
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, kernel-hardening@lists.openwall.com, netfilter-devel@vger.kernel.org
Cc: lvs-devel@vger.kernel.org, wensong@linux-vs.org, ja@ssi.bg, horms@verge.net.au, pablo@netfilter.org, dwindsor@gmail.com, keescook@chromium.org, elena.reshetova@intel.com, ishkamiel@gmail.com

Currently, the ip_vs_dest cache frees ip_vs_dest objects when their
reference count becomes < 0.  Aside from not being semantically sound,
this is problematic for the new type refcount_t, which will be introduced
shortly in a separate patch. refcount_t is the new kernel type for
holding reference counts, and provides overflow protection and a
constrained interface relative to atomic_t (the type currently being
used for kernel reference counts).

Per Julian Anastasov: "The problem is that dest_trash currently holds
deleted dests (unlinked from RCU lists) with refcnt=0."  Changing
dest_trash to hold dest with refcnt=1 will allow us to free ip_vs_dest
structs when their refcnt=0, in ip_vs_dest_put_and_free().

Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 include/net/ip_vs.h            | 2 +-
 net/netfilter/ipvs/ip_vs_ctl.c | 8 +++-----
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index cd6018a..a3e78ad 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1421,7 +1421,7 @@ static inline void ip_vs_dest_put(struct ip_vs_dest *dest)
 
 static inline void ip_vs_dest_put_and_free(struct ip_vs_dest *dest)
 {
-	if (atomic_dec_return(&dest->refcnt) < 0)
+	if (atomic_dec_and_test(&dest->refcnt))
 		kfree(dest);
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 55e0169..5fc4836 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -711,7 +711,6 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, int dest_af,
 		      dest->vport == svc->port))) {
 			/* HIT */
 			list_del(&dest->t_list);
-			ip_vs_dest_hold(dest);
 			goto out;
 		}
 	}
@@ -741,7 +740,7 @@ static void ip_vs_dest_free(struct ip_vs_dest *dest)
  *  When the ip_vs_control_clearup is activated by ipvs module exit,
  *  the service tables must have been flushed and all the connections
  *  are expired, and the refcnt of each destination in the trash must
- *  be 0, so we simply release them here.
+ *  be 1, so we simply release them here.
  */
 static void ip_vs_trash_cleanup(struct netns_ipvs *ipvs)
 {
@@ -1080,11 +1079,10 @@ static void __ip_vs_del_dest(struct netns_ipvs *ipvs, struct ip_vs_dest *dest,
 	if (list_empty(&ipvs->dest_trash) && !cleanup)
 		mod_timer(&ipvs->dest_trash_timer,
 			  jiffies + (IP_VS_DEST_TRASH_PERIOD >> 1));
-	/* dest lives in trash without reference */
+	/* dest lives in trash with reference */
 	list_add(&dest->t_list, &ipvs->dest_trash);
 	dest->idle_start = 0;
 	spin_unlock_bh(&ipvs->dest_trash_lock);
-	ip_vs_dest_put(dest);
 }
 
 
@@ -1160,7 +1158,7 @@ static void ip_vs_dest_trash_expire(unsigned long data)
 
 	spin_lock(&ipvs->dest_trash_lock);
 	list_for_each_entry_safe(dest, next, &ipvs->dest_trash, t_list) {
-		if (atomic_read(&dest->refcnt) > 0)
+		if (atomic_read(&dest->refcnt) > 1)
 			continue;
 		if (dest->idle_start) {
 			if (time_before(now, dest->idle_start +
-- 
2.7.4

