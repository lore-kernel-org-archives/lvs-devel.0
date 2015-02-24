From: Alex Gartrell <agartrell@fb.com>
Subject: [RFC PATCH net-next 3/4] ipvs: check return value of add_dest
Date: Mon, 23 Feb 2015 21:07:41 -0800
Message-ID: <1424754462-3253312-4-git-send-email-agartrell@fb.com>
References: <1424754462-3253312-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=yRnVFLH3oNhTbuNGehINwMPgU5DeC4nC3eXCm2ovdy4=;
 b=TQKbFmBMFNwl/lGk72sQrx/BbFSticOFPcACWOpWSnJV4RRI0SygtvGdBJ/6VtzPvFE4
 x0MmhBtjACipAQKipdoTSmZOiPssLyxROBma5NLDLddBA+YMD4MLVWC0kBsIvND4kFeO
 87KF2mfck0KPItaZL4Bgu6uXwkcW/6clXgs= 
In-Reply-To: <1424754462-3253312-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
Cc: lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

If the scheduler's add_dest function fails, free the newly allocated or
reclaimed dest and then return the error code to the user.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 28 +++++++++++++++++++++-------
 1 file changed, 21 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 6341e3f..d384b7f 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -787,7 +787,7 @@ ip_vs_zero_stats(struct ip_vs_stats *stats)
 /*
  *	Update a destination in the given service
  */
-static void
+static int
 __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 		    struct ip_vs_dest_user_kern *udest, int add)
 {
@@ -795,6 +795,7 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	struct ip_vs_service *old_svc;
 	struct ip_vs_scheduler *sched;
 	int conn_flags;
+	int ret = 0;
 
 	/* We cannot modify an address and change the address family */
 	BUG_ON(!add && udest->af != dest->af);
@@ -850,12 +851,20 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 		ip_vs_start_estimator(svc->net, &dest->stats);
 		list_add_rcu(&dest->n_list, &svc->destinations);
 		svc->num_dests++;
-		if (sched->add_dest)
-			sched->add_dest(svc, dest);
+		if (sched->add_dest) {
+			ret = sched->add_dest(svc, dest);
+			if (ret) {
+				ip_vs_stop_estimator(svc->net, &dest->stats);
+				list_del_rcu(&dest->n_list);
+				svc->num_dests--;
+			}
+		}
 	} else {
 		if (sched->upd_dest)
 			sched->upd_dest(svc, dest);
 	}
+
+	return ret;
 }
 
 
@@ -867,6 +876,7 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 {
 	struct ip_vs_dest *dest;
 	unsigned int atype, i;
+	int ret;
 
 	EnterFunction(2);
 
@@ -915,10 +925,13 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	INIT_HLIST_NODE(&dest->d_list);
 	spin_lock_init(&dest->dst_lock);
 	spin_lock_init(&dest->stats.lock);
-	__ip_vs_update_dest(svc, dest, udest, 1);
+
+	ret = __ip_vs_update_dest(svc, dest, udest, 1);
+	if (ret)
+		kfree(dest);
 
 	LeaveFunction(2);
-	return 0;
+	return ret;
 
 err_alloc:
 	kfree(dest);
@@ -977,8 +990,9 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 			      IP_VS_DBG_ADDR(svc->af, &dest->vaddr),
 			      ntohs(dest->vport));
 
-		__ip_vs_update_dest(svc, dest, udest, 1);
-		ret = 0;
+		ret = __ip_vs_update_dest(svc, dest, udest, 1);
+		if (ret)
+			ip_vs_trash_put_dest(net_ipvs(svc->net), dest, false);
 	} else {
 		/*
 		 * Allocate and initialize the dest structure
-- 
Alex Gartrell <agartrell@fb.com>

