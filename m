From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 05/22] IPVS: netns, prepare protocol
Date: Thu,  6 Jan 2011 15:16:01 +0900
Message-ID: <1294294578-8601-6-git-send-email-horms@verge.net.au>
References: <1294294578-8601-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1294294578-8601-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Patrick McHardy <kaber@trash.net>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Simon Horman <horms@verge.net.au>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

Add support for protocol data per name-space.
in struct ip_vs_protocol, appcnt will be removed when all protos
are modified for network name-space.

This patch causes warnings of unused functions, they will be used
when next patch will be applied.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h              |   20 +++++++++++-
 include/net/netns/ip_vs.h        |    3 ++
 net/netfilter/ipvs/ip_vs_proto.c |   66 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 88 insertions(+), 1 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index d551e0d..88d4e40 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -352,6 +352,7 @@ struct iphdr;
 struct ip_vs_conn;
 struct ip_vs_app;
 struct sk_buff;
+struct ip_vs_proto_data;
 
 struct ip_vs_protocol {
 	struct ip_vs_protocol	*next;
@@ -366,6 +367,10 @@ struct ip_vs_protocol {
 
 	void (*exit)(struct ip_vs_protocol *pp);
 
+	void (*init_netns)(struct net *net, struct ip_vs_proto_data *pd);
+
+	void (*exit_netns)(struct net *net, struct ip_vs_proto_data *pd);
+
 	int (*conn_schedule)(int af, struct sk_buff *skb,
 			     struct ip_vs_protocol *pp,
 			     int *verdict, struct ip_vs_conn **cpp);
@@ -417,7 +422,20 @@ struct ip_vs_protocol {
 	int (*set_state_timeout)(struct ip_vs_protocol *pp, char *sname, int to);
 };
 
-extern struct ip_vs_protocol * ip_vs_proto_get(unsigned short proto);
+/*
+ * protocol data per netns
+ */
+struct ip_vs_proto_data {
+	struct ip_vs_proto_data	*next;
+	struct ip_vs_protocol	*pp;
+	int			*timeout_table;	/* protocol timeout table */
+	atomic_t		appcnt;		/* counter of proto app incs. */
+	struct tcp_states_t	*tcp_state_table;
+};
+
+extern struct ip_vs_protocol   *ip_vs_proto_get(unsigned short proto);
+extern struct ip_vs_proto_data *ip_vs_proto_data_get(struct net *net,
+						     unsigned short proto);
 
 struct ip_vs_conn_param {
 	const union nf_inet_addr	*caddr;
diff --git a/include/net/netns/ip_vs.h b/include/net/netns/ip_vs.h
index d14581c..6f4e089 100644
--- a/include/net/netns/ip_vs.h
+++ b/include/net/netns/ip_vs.h
@@ -28,6 +28,9 @@ struct netns_ipvs {
 	#define IP_VS_RTAB_MASK (IP_VS_RTAB_SIZE - 1)
 
 	struct list_head	rs_table[IP_VS_RTAB_SIZE];
+	/* ip_vs_proto */
+	#define IP_VS_PROTO_TAB_SIZE	32	/* must be power of 2 */
+	struct ip_vs_proto_data *proto_data_table[IP_VS_PROTO_TAB_SIZE];
 
 	/* ip_vs_lblc */
 	int			sysctl_lblc_expiration;
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 4539294..576e296 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -60,6 +60,31 @@ static int __used __init register_ip_vs_protocol(struct ip_vs_protocol *pp)
 	return 0;
 }
 
+/*
+ *	register an ipvs protocols netns related data
+ */
+static int
+register_ip_vs_proto_netns(struct net *net, struct ip_vs_protocol *pp)
+{
+	struct netns_ipvs *ipvs = net_ipvs(net);
+	unsigned hash = IP_VS_PROTO_HASH(pp->protocol);
+	struct ip_vs_proto_data *pd =
+			kzalloc(sizeof(struct ip_vs_proto_data), GFP_ATOMIC);
+
+	if (!pd) {
+		pr_err("%s(): no memory.\n", __func__);
+		return -ENOMEM;
+	}
+	pd->pp = pp;	/* For speed issues */
+	pd->next = ipvs->proto_data_table[hash];
+	ipvs->proto_data_table[hash] = pd;
+	atomic_set(&pd->appcnt, 0);	/* Init app counter */
+
+	if (pp->init_netns != NULL)
+		pp->init_netns(net, pd);
+
+	return 0;
+}
 
 /*
  *	unregister an ipvs protocol
@@ -82,6 +107,29 @@ static int unregister_ip_vs_protocol(struct ip_vs_protocol *pp)
 	return -ESRCH;
 }
 
+/*
+ *	unregister an ipvs protocols netns data
+ */
+static int
+unregister_ip_vs_proto_netns(struct net *net, struct ip_vs_proto_data *pd)
+{
+	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct ip_vs_proto_data **pd_p;
+	unsigned hash = IP_VS_PROTO_HASH(pd->pp->protocol);
+
+	pd_p = &ipvs->proto_data_table[hash];
+	for (; *pd_p; pd_p = &(*pd_p)->next) {
+		if (*pd_p == pd) {
+			*pd_p = pd->next;
+			if (pd->pp->exit_netns != NULL)
+				pd->pp->exit_netns(net, pd);
+			kfree(pd);
+			return 0;
+		}
+	}
+
+	return -ESRCH;
+}
 
 /*
  *	get ip_vs_protocol object by its proto.
@@ -100,6 +148,24 @@ struct ip_vs_protocol * ip_vs_proto_get(unsigned short proto)
 }
 EXPORT_SYMBOL(ip_vs_proto_get);
 
+/*
+ *	get ip_vs_protocol object data by netns and proto
+ */
+struct ip_vs_proto_data *
+ip_vs_proto_data_get(struct net *net, unsigned short proto)
+{
+	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct ip_vs_proto_data *pd;
+	unsigned hash = IP_VS_PROTO_HASH(proto);
+
+	for (pd = ipvs->proto_data_table[hash]; pd; pd = pd->next) {
+		if (pd->pp->protocol == proto)
+			return pd;
+	}
+
+	return NULL;
+}
+EXPORT_SYMBOL(ip_vs_proto_data_get);
 
 /*
  *	Propagate event for state change to all protocols
-- 
1.7.2.3

