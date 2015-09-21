From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 16/84] ipvs: Pass ipvs not net to __ip_vs_del_dest
Date: Mon, 21 Sep 2015 13:01:53 -0500
Message-ID: <1442858581-15869-16-git-send-email-ebiederm@xmission.com>
References: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
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
2.2.1
