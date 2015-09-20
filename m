From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 20/84] ipvs: Pass ipvs not net to ip_vs_flush
Date: Sun, 20 Sep 2015 01:22:36 -0500
Message-ID: <1442730220-32458-20-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 7f0635242c7f..51dab90bf184 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1449,9 +1449,8 @@ static int ip_vs_del_service(struct ip_vs_service *svc)
 /*
  *	Flush all the virtual services
  */
-static int ip_vs_flush(struct net *net, bool cleanup)
+static int ip_vs_flush(struct netns_ipvs *ipvs, bool cleanup)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	int idx;
 	struct ip_vs_service *svc;
 	struct hlist_node *n;
@@ -1487,10 +1486,11 @@ static int ip_vs_flush(struct net *net, bool cleanup)
  */
 void ip_vs_service_net_cleanup(struct net *net)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	EnterFunction(2);
 	/* Check for "full" addressed entries */
 	mutex_lock(&__ip_vs_mutex);
-	ip_vs_flush(net, true);
+	ip_vs_flush(ipvs, true);
 	mutex_unlock(&__ip_vs_mutex);
 	LeaveFunction(2);
 }
@@ -2366,7 +2366,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 	mutex_lock(&__ip_vs_mutex);
 	if (cmd == IP_VS_SO_SET_FLUSH) {
 		/* Flush the virtual service */
-		ret = ip_vs_flush(net, false);
+		ret = ip_vs_flush(ipvs, false);
 		goto out_unlock;
 	} else if (cmd == IP_VS_SO_SET_TIMEOUT) {
 		/* Set timeout values for (tcp tcpfin udp) */
@@ -3524,7 +3524,7 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 	mutex_lock(&__ip_vs_mutex);
 
 	if (cmd == IPVS_CMD_FLUSH) {
-		ret = ip_vs_flush(net, false);
+		ret = ip_vs_flush(ipvs, false);
 		goto out;
 	} else if (cmd == IPVS_CMD_SET_CONFIG) {
 		ret = ip_vs_genl_set_config(net, info->attrs);
-- 
2.2.1

