From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 19/84] ipvs: Pass ipvs not net to ip_vs_add_service
Date: Mon, 21 Sep 2015 13:01:56 -0500
Message-ID: <1442858581-15869-19-git-send-email-ebiederm@xmission.com>
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
2.2.1
