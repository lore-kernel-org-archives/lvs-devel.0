From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 4/5] ipvs: take care of return value from protocol init_netns
Date: Fri, 27 Apr 2012 09:53:58 +0900
Message-ID: <1335488039-13471-5-git-send-email-horms@verge.net.au>
References: <1335488039-13471-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1335488039-13471-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Simon Horman <horms@verge.net.au>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

ip_vs_create_timeout_table() can return NULL
All functions protocol init_netns is affected of this patch.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h                   |    2 +-
 net/netfilter/ipvs/ip_vs_proto.c      |   11 +++++++++--
 net/netfilter/ipvs/ip_vs_proto_sctp.c |    5 ++++-
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |    5 ++++-
 net/netfilter/ipvs/ip_vs_proto_udp.c  |    5 ++++-
 5 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 2bdee51..6d90dda 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -393,7 +393,7 @@ struct ip_vs_protocol {
 
 	void (*exit)(struct ip_vs_protocol *pp);
 
-	void (*init_netns)(struct net *net, struct ip_vs_proto_data *pd);
+	int (*init_netns)(struct net *net, struct ip_vs_proto_data *pd);
 
 	void (*exit_netns)(struct net *net, struct ip_vs_proto_data *pd);
 
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index a62360e..ed835e6 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -78,8 +78,15 @@ register_ip_vs_proto_netns(struct net *net, struct ip_vs_protocol *pp)
 	ipvs->proto_data_table[hash] = pd;
 	atomic_set(&pd->appcnt, 0);	/* Init app counter */
 
-	if (pp->init_netns != NULL)
-		pp->init_netns(net, pd);
+	if (pp->init_netns != NULL) {
+		int ret = pp->init_netns(net, pd);
+		if (ret) {
+			/* unlink an free proto data */
+			ipvs->proto_data_table[hash] = pd->next;
+			kfree(pd);
+			return ret;
+		}
+	}
 
 	return 0;
 }
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 1fbf7a2..9f3fb75 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -1090,7 +1090,7 @@ out:
  *   timeouts is netns related now.
  * ---------------------------------------------
  */
-static void __ip_vs_sctp_init(struct net *net, struct ip_vs_proto_data *pd)
+static int __ip_vs_sctp_init(struct net *net, struct ip_vs_proto_data *pd)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
@@ -1098,6 +1098,9 @@ static void __ip_vs_sctp_init(struct net *net, struct ip_vs_proto_data *pd)
 	spin_lock_init(&ipvs->sctp_app_lock);
 	pd->timeout_table = ip_vs_create_timeout_table((int *)sctp_timeouts,
 							sizeof(sctp_timeouts));
+	if (!pd->timeout_table)
+		return -ENOMEM;
+	return 0;
 }
 
 static void __ip_vs_sctp_exit(struct net *net, struct ip_vs_proto_data *pd)
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index ef8641f..cd609cc 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -677,7 +677,7 @@ void ip_vs_tcp_conn_listen(struct net *net, struct ip_vs_conn *cp)
  *   timeouts is netns related now.
  * ---------------------------------------------
  */
-static void __ip_vs_tcp_init(struct net *net, struct ip_vs_proto_data *pd)
+static int __ip_vs_tcp_init(struct net *net, struct ip_vs_proto_data *pd)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
@@ -685,7 +685,10 @@ static void __ip_vs_tcp_init(struct net *net, struct ip_vs_proto_data *pd)
 	spin_lock_init(&ipvs->tcp_app_lock);
 	pd->timeout_table = ip_vs_create_timeout_table((int *)tcp_timeouts,
 							sizeof(tcp_timeouts));
+	if (!pd->timeout_table)
+		return -ENOMEM;
 	pd->tcp_state_table =  tcp_states;
+	return 0;
 }
 
 static void __ip_vs_tcp_exit(struct net *net, struct ip_vs_proto_data *pd)
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index f4b7262..2fedb2d 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -467,7 +467,7 @@ udp_state_transition(struct ip_vs_conn *cp, int direction,
 	cp->timeout = pd->timeout_table[IP_VS_UDP_S_NORMAL];
 }
 
-static void __udp_init(struct net *net, struct ip_vs_proto_data *pd)
+static int __udp_init(struct net *net, struct ip_vs_proto_data *pd)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
@@ -475,6 +475,9 @@ static void __udp_init(struct net *net, struct ip_vs_proto_data *pd)
 	spin_lock_init(&ipvs->udp_app_lock);
 	pd->timeout_table = ip_vs_create_timeout_table((int *)udp_timeouts,
 							sizeof(udp_timeouts));
+	if (!pd->timeout_table)
+		return -ENOMEM;
+	return 0;
 }
 
 static void __udp_exit(struct net *net, struct ip_vs_proto_data *pd)
-- 
1.7.9.5

