From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 59/84] ipvs: Pass ipvs not net into init_netns and exit_netns
Date: Thu, 24 Sep 2015 09:52:44 +0900
Message-ID: <1443055989-1306-60-git-send-email-horms@verge.net.au>
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
 include/net/ip_vs.h                   | 4 ++--
 net/netfilter/ipvs/ip_vs_proto.c      | 4 ++--
 net/netfilter/ipvs/ip_vs_proto_sctp.c | 6 ++----
 net/netfilter/ipvs/ip_vs_proto_tcp.c  | 6 ++----
 net/netfilter/ipvs/ip_vs_proto_udp.c  | 6 ++----
 5 files changed, 10 insertions(+), 16 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 728a670d69fd..fe3373c9bb3b 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -483,9 +483,9 @@ struct ip_vs_protocol {
 
 	void (*exit)(struct ip_vs_protocol *pp);
 
-	int (*init_netns)(struct net *net, struct ip_vs_proto_data *pd);
+	int (*init_netns)(struct netns_ipvs *ipvs, struct ip_vs_proto_data *pd);
 
-	void (*exit_netns)(struct net *net, struct ip_vs_proto_data *pd);
+	void (*exit_netns)(struct netns_ipvs *ipvs, struct ip_vs_proto_data *pd);
 
 	int (*conn_schedule)(int af, struct sk_buff *skb,
 			     struct ip_vs_proto_data *pd,
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index fb581babe5e2..f05ee668a1d1 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -78,7 +78,7 @@ register_ip_vs_proto_netns(struct netns_ipvs *ipvs, struct ip_vs_protocol *pp)
 	atomic_set(&pd->appcnt, 0);	/* Init app counter */
 
 	if (pp->init_netns != NULL) {
-		int ret = pp->init_netns(ipvs->net, pd);
+		int ret = pp->init_netns(ipvs, pd);
 		if (ret) {
 			/* unlink an free proto data */
 			ipvs->proto_data_table[hash] = pd->next;
@@ -125,7 +125,7 @@ unregister_ip_vs_proto_netns(struct netns_ipvs *ipvs, struct ip_vs_proto_data *p
 		if (*pd_p == pd) {
 			*pd_p = pd->next;
 			if (pd->pp->exit_netns != NULL)
-				pd->pp->exit_netns(ipvs->net, pd);
+				pd->pp->exit_netns(ipvs, pd);
 			kfree(pd);
 			return 0;
 		}
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 345fc7485f2e..3e9418ab276a 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -561,10 +561,8 @@ out:
  *   timeouts is netns related now.
  * ---------------------------------------------
  */
-static int __ip_vs_sctp_init(struct net *net, struct ip_vs_proto_data *pd)
+static int __ip_vs_sctp_init(struct netns_ipvs *ipvs, struct ip_vs_proto_data *pd)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
-
 	ip_vs_init_hash_table(ipvs->sctp_apps, SCTP_APP_TAB_SIZE);
 	pd->timeout_table = ip_vs_create_timeout_table((int *)sctp_timeouts,
 							sizeof(sctp_timeouts));
@@ -573,7 +571,7 @@ static int __ip_vs_sctp_init(struct net *net, struct ip_vs_proto_data *pd)
 	return 0;
 }
 
-static void __ip_vs_sctp_exit(struct net *net, struct ip_vs_proto_data *pd)
+static void __ip_vs_sctp_exit(struct netns_ipvs *ipvs, struct ip_vs_proto_data *pd)
 {
 	kfree(pd->timeout_table);
 }
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 94bea31ec388..93ba6b1fe9d1 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -691,10 +691,8 @@ void ip_vs_tcp_conn_listen(struct net *net, struct ip_vs_conn *cp)
  *   timeouts is netns related now.
  * ---------------------------------------------
  */
-static int __ip_vs_tcp_init(struct net *net, struct ip_vs_proto_data *pd)
+static int __ip_vs_tcp_init(struct netns_ipvs *ipvs, struct ip_vs_proto_data *pd)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
-
 	ip_vs_init_hash_table(ipvs->tcp_apps, TCP_APP_TAB_SIZE);
 	pd->timeout_table = ip_vs_create_timeout_table((int *)tcp_timeouts,
 							sizeof(tcp_timeouts));
@@ -704,7 +702,7 @@ static int __ip_vs_tcp_init(struct net *net, struct ip_vs_proto_data *pd)
 	return 0;
 }
 
-static void __ip_vs_tcp_exit(struct net *net, struct ip_vs_proto_data *pd)
+static void __ip_vs_tcp_exit(struct netns_ipvs *ipvs, struct ip_vs_proto_data *pd)
 {
 	kfree(pd->timeout_table);
 }
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 234521ec9703..382dcc9cfe11 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -472,10 +472,8 @@ udp_state_transition(struct ip_vs_conn *cp, int direction,
 	cp->timeout = pd->timeout_table[IP_VS_UDP_S_NORMAL];
 }
 
-static int __udp_init(struct net *net, struct ip_vs_proto_data *pd)
+static int __udp_init(struct netns_ipvs *ipvs, struct ip_vs_proto_data *pd)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
-
 	ip_vs_init_hash_table(ipvs->udp_apps, UDP_APP_TAB_SIZE);
 	pd->timeout_table = ip_vs_create_timeout_table((int *)udp_timeouts,
 							sizeof(udp_timeouts));
@@ -484,7 +482,7 @@ static int __udp_init(struct net *net, struct ip_vs_proto_data *pd)
 	return 0;
 }
 
-static void __udp_exit(struct net *net, struct ip_vs_proto_data *pd)
+static void __udp_exit(struct netns_ipvs *ipvs, struct ip_vs_proto_data *pd)
 {
 	kfree(pd->timeout_table);
 }
-- 
2.1.4

