From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 15/84] ipvs: Pass ipvs not net to ip_vs_trash_cleanup
Date: Thu, 24 Sep 2015 09:52:00 +0900
Message-ID: <1443055989-1306-16-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
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
 net/netfilter/ipvs/ip_vs_ctl.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 24dceaccb0a1..b66ab765f36d 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -713,10 +713,9 @@ static void ip_vs_dest_free(struct ip_vs_dest *dest)
  *  are expired, and the refcnt of each destination in the trash must
  *  be 0, so we simply release them here.
  */
-static void ip_vs_trash_cleanup(struct net *net)
+static void ip_vs_trash_cleanup(struct netns_ipvs *ipvs)
 {
 	struct ip_vs_dest *dest, *nxt;
-	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	del_timer_sync(&ipvs->dest_trash_timer);
 	/* No need to use dest_trash_lock */
@@ -4005,7 +4004,7 @@ void __net_exit ip_vs_control_net_cleanup(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	ip_vs_trash_cleanup(net);
+	ip_vs_trash_cleanup(ipvs);
 	ip_vs_control_net_cleanup_sysctl(net);
 	remove_proc_entry("ip_vs_stats_percpu", net->proc_net);
 	remove_proc_entry("ip_vs_stats", net->proc_net);
-- 
2.1.4

