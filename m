From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 17/84] ipvs: Pass ipvs not net to ip_vs_dest_trash_expire
Date: Sun, 20 Sep 2015 01:22:33 -0500
Message-ID: <1442730220-32458-17-git-send-email-ebiederm@xmission.com>
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
index 4f08611347a2..9169a27be6e7 100644
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
2.2.1
