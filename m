From: Alex Gartrell <agartrell@fb.com>
Subject: [RFC PATCH net-next 1/4] ipvs: move ip_vs_trash_put_dest into its own function
Date: Mon, 23 Feb 2015 21:07:39 -0800
Message-ID: <1424754462-3253312-2-git-send-email-agartrell@fb.com>
References: <1424754462-3253312-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=YaS4YD9KMaaEW4c1OqnRamhUzna2UIHv9s6ujErAM68=;
 b=dgIOdCQsKodmMk+DVr6BTMTBc0RIMqcNJtGuYgqXm8ppao8vlhNk/uQC4faDdG86HyFx
 YCsW28Fkacko3L7o/rezGSMOWb5VTLIUcJri7hBe5fG0I/PCpXXy8wqWcVx8YLvkO7PU
 KXKlMrG41K0M6yrbfu8p3nEll709YRhdo5M= 
In-Reply-To: <1424754462-3253312-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
Cc: lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

This corresponds better with ip_vs_trash_get_dest and we'll need to all it
directly if the scheduler add dest fails.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 31 +++++++++++++++++++------------
 1 file changed, 19 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index e557590..11da053 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -696,6 +696,24 @@ out:
 	return dest;
 }
 
+static inline void ip_vs_trash_put_dest(struct netns_ipvs *ipvs,
+					struct ip_vs_dest *dest,
+					bool cleanup)
+{
+	spin_lock_bh(&ipvs->dest_trash_lock);
+	IP_VS_DBG_BUF(3, "Moving dest %s:%u into trash, dest->refcnt=%d\n",
+		      IP_VS_DBG_ADDR(dest->af, &dest->addr), ntohs(dest->port),
+		      atomic_read(&dest->refcnt));
+	if (list_empty(&ipvs->dest_trash) && !cleanup)
+		mod_timer(&ipvs->dest_trash_timer,
+			  jiffies + (IP_VS_DEST_TRASH_PERIOD >> 1));
+	/* dest lives in trash without reference */
+	list_add(&dest->t_list, &ipvs->dest_trash);
+	dest->idle_start = 0;
+	spin_unlock_bh(&ipvs->dest_trash_lock);
+	ip_vs_dest_put(dest);
+}
+
 static void ip_vs_dest_free(struct ip_vs_dest *dest)
 {
 	struct ip_vs_service *svc = rcu_dereference_protected(dest->svc, 1);
@@ -1032,18 +1050,7 @@ static void __ip_vs_del_dest(struct net *net, struct ip_vs_dest *dest,
 	 */
 	ip_vs_rs_unhash(dest);
 
-	spin_lock_bh(&ipvs->dest_trash_lock);
-	IP_VS_DBG_BUF(3, "Moving dest %s:%u into trash, dest->refcnt=%d\n",
-		      IP_VS_DBG_ADDR(dest->af, &dest->addr), ntohs(dest->port),
-		      atomic_read(&dest->refcnt));
-	if (list_empty(&ipvs->dest_trash) && !cleanup)
-		mod_timer(&ipvs->dest_trash_timer,
-			  jiffies + (IP_VS_DEST_TRASH_PERIOD >> 1));
-	/* dest lives in trash without reference */
-	list_add(&dest->t_list, &ipvs->dest_trash);
-	dest->idle_start = 0;
-	spin_unlock_bh(&ipvs->dest_trash_lock);
-	ip_vs_dest_put(dest);
+	ip_vs_trash_put_dest(ipvs, dest, cleanup);
 }
 
 
-- 
Alex Gartrell <agartrell@fb.com>

