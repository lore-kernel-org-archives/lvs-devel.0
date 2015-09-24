From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 16/84] ipvs: Pass ipvs not net to __ip_vs_del_dest
Date: Thu, 24 Sep 2015 09:52:01 +0900
Message-ID: <1443055989-1306-17-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "Eric W. Biederman" <ebiederm@xmission.com>, Simon Horman <horms@verge.net.au>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index b66ab765f36d..b295e2bb706f 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1033,12 +1033,10 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 /*
  *	Delete a destination (must be already unlinked from the service)
  */
-static void __ip_vs_del_dest(struct net *net, struct ip_vs_dest *dest,
+static void __ip_vs_del_dest(struct netns_ipvs *ipvs, struct ip_vs_dest *dest,
 			     bool cleanup)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
-
-	ip_vs_stop_estimator(net, &dest->stats);
+	ip_vs_stop_estimator(ipvs->net, &dest->stats);
 
 	/*
 	 *  Remove it from the d-linked list with the real services.
@@ -1117,7 +1115,7 @@ ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	/*
 	 *	Delete the destination
 	 */
-	__ip_vs_del_dest(svc->ipvs->net, dest, false);
+	__ip_vs_del_dest(svc->ipvs, dest, false);
 
 	LeaveFunction(2);
 
@@ -1402,7 +1400,7 @@ static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup)
 	 */
 	list_for_each_entry_safe(dest, nxt, &svc->destinations, n_list) {
 		__ip_vs_unlink_dest(svc, dest, 0);
-		__ip_vs_del_dest(svc->ipvs->net, dest, cleanup);
+		__ip_vs_del_dest(svc->ipvs, dest, cleanup);
 	}
 
 	/*
-- 
2.1.4

