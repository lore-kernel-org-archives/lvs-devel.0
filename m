From: Yannick Brosseau <scientist@fb.com>
Subject: [PATCH] ipvs: Stop traffic to a destination when setting its weight to -1
Date: Tue, 28 Apr 2015 08:10:41 -0700
Message-ID: <1430233841-14944-1-git-send-email-scientist@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : mime-version : content-type; s=facebook;
 bh=tqhuVl2G3zVe5m4V5HFWSTtkm6QwiFJgmOA6WxxvFU0=;
 b=QsiZNTAs48qJr8h8OMIehmk8xTHZP7SyZ8ihl4MVBV0uPmmmyJx7x3g5WFbROw/VFwOV
 lCi5M5UZlEOE/zkHX/WWHXzeEym9eKxC11BBhStmQt2dAyFpDWgtSw5e42ig8ltXBFOz
 gR9zOOdtUl0/lxG41qVkTdPGdMgnzyo+jms= 
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
Cc: lvs-devel@vger.kernel.org, kernel-team@fb.com, Yannick Brosseau <scientist@fb.com>

In some situation, we want to reap all the active connections
to a host that is failing. Setting its weight to zero only stop new
connections to the destination while still forwarding packets part of
an active one.

We need a finer grained version of the sysctl_expire_nodest_conn because
in most case we want to kept the behavior of only blocking new connexion.
But if one host destination is failing we want to cut the traffic to
that one immediately. Sending a RST is preferable than blackholling packets
in that case.

Signed-off-by: Yannick Brosseau <scientist@fb.com>
---
 net/netfilter/ipvs/ip_vs_core.c |  3 ++-
 net/netfilter/ipvs/ip_vs_ctl.c  | 14 +++++++++-----
 2 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 5d2b806..b24791f 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1718,7 +1718,8 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (cp->dest && !(cp->dest->flags & IP_VS_DEST_F_AVAILABLE)) {
 		/* the destination server is not available */
 
-		if (sysctl_expire_nodest_conn(ipvs)) {
+		if (sysctl_expire_nodest_conn(ipvs) ||
+			atomic_read(&cp->dest->weight) == -1) {
 			/* try to expire the connection immediately */
 			ip_vs_conn_expire_now(cp);
 		}
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 4953267..e1a8c39 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -829,7 +829,11 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	}
 
 	/* set the dest status flags */
-	dest->flags |= IP_VS_DEST_F_AVAILABLE;
+	if (atomic_read(&dest->weight) >= 0) {
+		dest->flags |= IP_VS_DEST_F_AVAILABLE;
+	} else {
+		dest->flags &= ~IP_VS_DEST_F_AVAILABLE;
+	}
 
 	if (udest->u_threshold == 0 || udest->u_threshold > dest->u_threshold)
 		dest->flags &= ~IP_VS_DEST_F_OVERLOAD;
@@ -939,8 +943,8 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 
 	EnterFunction(2);
 
-	if (udest->weight < 0) {
-		pr_err("%s(): server weight less than zero\n", __func__);
+	if (udest->weight < -1) {
+		pr_err("%s(): server weight less than -1\n", __func__);
 		return -ERANGE;
 	}
 
@@ -1003,8 +1007,8 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 
 	EnterFunction(2);
 
-	if (udest->weight < 0) {
-		pr_err("%s(): server weight less than zero\n", __func__);
+	if (udest->weight < -1) {
+		pr_err("%s(): server weight less than -1\n", __func__);
 		return -ERANGE;
 	}
 
-- 
2.1.4

