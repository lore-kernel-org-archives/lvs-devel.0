From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 17/84] ipvs: Pass ipvs not net to ip_vs_dest_trash_expire
Date: Thu, 24 Sep 2015 09:52:02 +0900
Message-ID: <1443055989-1306-18-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
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
index b295e2bb706f..20aeb993618f 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1124,8 +1124,7 @@ ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 
 static void ip_vs_dest_trash_expire(unsigned long data)
 {
-	struct net *net = (struct net *) data;
-	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct netns_ipvs *ipvs = (struct netns_ipvs *)data;
 	struct ip_vs_dest *dest, *next;
 	unsigned long now = jiffies;
 
@@ -3966,7 +3965,7 @@ int __net_init ip_vs_control_net_init(struct net *net)
 	INIT_LIST_HEAD(&ipvs->dest_trash);
 	spin_lock_init(&ipvs->dest_trash_lock);
 	setup_timer(&ipvs->dest_trash_timer, ip_vs_dest_trash_expire,
-		    (unsigned long) net);
+		    (unsigned long) ipvs);
 	atomic_set(&ipvs->ftpsvc_counter, 0);
 	atomic_set(&ipvs->nullsvc_counter, 0);
 
-- 
2.1.4
