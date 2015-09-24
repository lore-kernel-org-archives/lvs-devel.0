From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 19/84] ipvs: Pass ipvs not net to ip_vs_add_service
Date: Thu, 24 Sep 2015 09:52:04 +0900
Message-ID: <1443055989-1306-20-git-send-email-horms@verge.net.au>
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
 net/netfilter/ipvs/ip_vs_ctl.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 7aae2dc0f766..ff7f9d19f2c3 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1157,14 +1157,13 @@ static void ip_vs_dest_trash_expire(unsigned long data)
  *	Add a service into the service hash table
  */
 static int
-ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
+ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 		  struct ip_vs_service **svc_p)
 {
 	int ret = 0, i;
 	struct ip_vs_scheduler *sched = NULL;
 	struct ip_vs_pe *pe = NULL;
 	struct ip_vs_service *svc = NULL;
-	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	/* increase the module use count */
 	ip_vs_use_count_inc();
@@ -1255,7 +1254,7 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 	else if (svc->port == 0)
 		atomic_inc(&ipvs->nullsvc_counter);
 
-	ip_vs_start_estimator(net, &svc->stats);
+	ip_vs_start_estimator(ipvs->net, &svc->stats);
 
 	/* Count only IPv4 services for old get/setsockopt interface */
 	if (svc->af == AF_INET)
@@ -2421,7 +2420,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 		if (svc != NULL)
 			ret = -EEXIST;
 		else
-			ret = ip_vs_add_service(net, &usvc, &svc);
+			ret = ip_vs_add_service(ipvs, &usvc, &svc);
 		break;
 	case IP_VS_SO_SET_EDIT:
 		ret = ip_vs_edit_service(svc, &usvc);
@@ -3601,7 +3600,7 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 	switch (cmd) {
 	case IPVS_CMD_NEW_SERVICE:
 		if (svc == NULL)
-			ret = ip_vs_add_service(net, &usvc, &svc);
+			ret = ip_vs_add_service(ipvs, &usvc, &svc);
 		else
 			ret = -EEXIST;
 		break;
-- 
2.1.4
