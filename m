From: GuoYong Zheng <zhenggy@chinatelecom.cn>
Subject: [PATCH] ipvs: remove unused variable for ip_vs_new_dest
Date: Fri,  5 Nov 2021 19:39:40 +0800
Message-ID: <1636112380-11040-1-git-send-email-zhenggy@chinatelecom.cn>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: zhenggy@chinatelecom.cn
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, davem@davemloft.net, kuba@kernel.org, netdev@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, GuoYong Zheng <zhenggy@chinatelecom.cn>

The dest variable is not used after ip_vs_new_dest anymore in
ip_vs_add_dest, do not need pass it to ip_vs_new_dest, remove it.

Signed-off-by: GuoYong Zheng <zhenggy@chinatelecom.cn>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index e62b40b..494399d 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -959,8 +959,7 @@ static void ip_vs_trash_cleanup(struct netns_ipvs *ipvs)
  *	Create a destination for the given service
  */
 static int
-ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
-	       struct ip_vs_dest **dest_p)
+ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 {
 	struct ip_vs_dest *dest;
 	unsigned int atype, i;
@@ -1020,8 +1019,6 @@ static void ip_vs_trash_cleanup(struct netns_ipvs *ipvs)
 	spin_lock_init(&dest->stats.lock);
 	__ip_vs_update_dest(svc, dest, udest, 1);
 
-	*dest_p = dest;
