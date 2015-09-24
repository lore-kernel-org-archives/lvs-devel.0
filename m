From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 58/84] ipvs: Pass ipvs not net into [un]register_ip_vs_proto_netns
Date: Thu, 24 Sep 2015 09:52:43 +0900
Message-ID: <1443055989-1306-59-git-send-email-horms@verge.net.au>
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
 net/netfilter/ipvs/ip_vs_proto.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 82ccfd2f235c..fb581babe5e2 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -63,9 +63,8 @@ static int __used __init register_ip_vs_protocol(struct ip_vs_protocol *pp)
  *	register an ipvs protocols netns related data
  */
 static int
-register_ip_vs_proto_netns(struct net *net, struct ip_vs_protocol *pp)
+register_ip_vs_proto_netns(struct netns_ipvs *ipvs, struct ip_vs_protocol *pp)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	unsigned int hash = IP_VS_PROTO_HASH(pp->protocol);
 	struct ip_vs_proto_data *pd =
 			kzalloc(sizeof(struct ip_vs_proto_data), GFP_KERNEL);
@@ -79,7 +78,7 @@ register_ip_vs_proto_netns(struct net *net, struct ip_vs_protocol *pp)
 	atomic_set(&pd->appcnt, 0);	/* Init app counter */
 
 	if (pp->init_netns != NULL) {
-		int ret = pp->init_netns(net, pd);
+		int ret = pp->init_netns(ipvs->net, pd);
 		if (ret) {
 			/* unlink an free proto data */
 			ipvs->proto_data_table[hash] = pd->next;
@@ -116,9 +115,8 @@ static int unregister_ip_vs_protocol(struct ip_vs_protocol *pp)
  *	unregister an ipvs protocols netns data
  */
 static int
-unregister_ip_vs_proto_netns(struct net *net, struct ip_vs_proto_data *pd)
+unregister_ip_vs_proto_netns(struct netns_ipvs *ipvs, struct ip_vs_proto_data *pd)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_proto_data **pd_p;
 	unsigned int hash = IP_VS_PROTO_HASH(pd->pp->protocol);
 
@@ -127,7 +125,7 @@ unregister_ip_vs_proto_netns(struct net *net, struct ip_vs_proto_data *pd)
 		if (*pd_p == pd) {
 			*pd_p = pd->next;
 			if (pd->pp->exit_netns != NULL)
-				pd->pp->exit_netns(net, pd);
+				pd->pp->exit_netns(ipvs->net, pd);
 			kfree(pd);
 			return 0;
 		}
@@ -329,9 +327,10 @@ int __net_init ip_vs_protocol_net_init(struct net *net)
 	&ip_vs_protocol_esp,
 #endif
 	};
+	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	for (i = 0; i < ARRAY_SIZE(protos); i++) {
-		ret = register_ip_vs_proto_netns(net, protos[i]);
+		ret = register_ip_vs_proto_netns(ipvs, protos[i]);
 		if (ret < 0)
 			goto cleanup;
 	}
@@ -351,7 +350,7 @@ void __net_exit ip_vs_protocol_net_cleanup(struct net *net)
 	/* unregister all the ipvs proto data for this netns */
 	for (i = 0; i < IP_VS_PROTO_TAB_SIZE; i++) {
 		while ((pd = ipvs->proto_data_table[i]) != NULL)
-			unregister_ip_vs_proto_netns(net, pd);
+			unregister_ip_vs_proto_netns(ipvs, pd);
 	}
 }
 
-- 
2.1.4
