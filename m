From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 15/84] ipvs: Pass ipvs not net to ip_vs_trash_cleanup
Date: Sun, 20 Sep 2015 01:22:31 -0500
Message-ID: <1442730220-32458-15-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 186e49c111f3..ee2ec40d0f12 100644
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
2.2.1
