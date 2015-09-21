From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 24/84] ipvs: Pass ipvs not net to ip_vs_proto_data_get
Date: Mon, 21 Sep 2015 13:02:01 -0500
Message-ID: <1442858581-15869-24-git-send-email-ebiederm@xmission.com>
References: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/ip_vs.h                   |  2 +-
 net/netfilter/ipvs/ip_vs_conn.c       |  4 ++--
 net/netfilter/ipvs/ip_vs_core.c       |  8 ++++----
 net/netfilter/ipvs/ip_vs_ctl.c        | 12 +++++++-----
 net/netfilter/ipvs/ip_vs_proto.c      | 12 ++----------
 net/netfilter/ipvs/ip_vs_proto_sctp.c |  4 ++--
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |  6 +++---
 net/netfilter/ipvs/ip_vs_proto_udp.c  |  4 ++--
 net/netfilter/ipvs/ip_vs_sync.c       |  2 +-
 9 files changed, 24 insertions(+), 30 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 3c7040a313b5..3c077e8a038c 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -541,7 +541,7 @@ struct ip_vs_proto_data {
 };
 
 struct ip_vs_protocol   *ip_vs_proto_get(unsigned short proto);
-struct ip_vs_proto_data *ip_vs_proto_data_get(struct net *net,
+struct ip_vs_proto_data *ip_vs_proto_data_get(struct netns_ipvs *ipvs,
 					      unsigned short proto);
 
 struct ip_vs_conn_param {
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index ce788f8781f4..d0d57f14bc76 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -668,7 +668,7 @@ void ip_vs_try_bind_dest(struct ip_vs_conn *cp)
 #endif
 			ip_vs_bind_xmit(cp);
 
-		pd = ip_vs_proto_data_get(cp->ipvs->net, cp->protocol);
+		pd = ip_vs_proto_data_get(cp->ipvs, cp->protocol);
 		if (pd && atomic_read(&pd->appcnt))
 			ip_vs_bind_app(cp, pd->pp);
 	}
@@ -876,7 +876,7 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p, int dest_af,
 {
 	struct ip_vs_conn *cp;
 	struct netns_ipvs *ipvs = p->ipvs;
-	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(p->ipvs->net,
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(p->ipvs,
 							   p->protocol);
 
 	cp = kmem_cache_alloc(ip_vs_conn_cachep, GFP_ATOMIC);
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 77dcd3ed27de..2e96500c6f3f 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1237,7 +1237,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 				return verdict;
 		}
 
-	pd = ip_vs_proto_data_get(net, iph.protocol);
+	pd = ip_vs_proto_data_get(ipvs, iph.protocol);
 	if (unlikely(!pd))
 		return NF_ACCEPT;
 	pp = pd->pp;
@@ -1470,7 +1470,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 		ipip = true;
 	}
 
-	pd = ip_vs_proto_data_get(net, cih->protocol);
+	pd = ip_vs_proto_data_get(ipvs, cih->protocol);
 	if (!pd)
 		return NF_ACCEPT;
 	pp = pd->pp;
@@ -1633,7 +1633,7 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 
 	net = skb_net(skb);
 	ipvs = net_ipvs(net);
-	pd = ip_vs_proto_data_get(net, ciph.protocol);
+	pd = ip_vs_proto_data_get(ipvs, ciph.protocol);
 	if (!pd)
 		return NF_ACCEPT;
 	pp = pd->pp;
@@ -1765,7 +1765,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 		}
 
 	/* Protocol supported? */
-	pd = ip_vs_proto_data_get(net, iph.protocol);
+	pd = ip_vs_proto_data_get(ipvs, iph.protocol);
 	if (unlikely(!pd)) {
 		/* The only way we'll see this packet again is if it's
 		 * encapsulated, so mark it with ipvs_property=1 so we
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 0b7749ae1e8d..eb3911c69037 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2205,6 +2205,7 @@ static const struct file_operations ip_vs_stats_percpu_fops = {
 static int ip_vs_set_timeout(struct net *net, struct ip_vs_timeout_user *u)
 {
 #if defined(CONFIG_IP_VS_PROTO_TCP) || defined(CONFIG_IP_VS_PROTO_UDP)
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_proto_data *pd;
 #endif
 
@@ -2215,13 +2216,13 @@ static int ip_vs_set_timeout(struct net *net, struct ip_vs_timeout_user *u)
 
 #ifdef CONFIG_IP_VS_PROTO_TCP
 	if (u->tcp_timeout) {
-		pd = ip_vs_proto_data_get(net, IPPROTO_TCP);
+		pd = ip_vs_proto_data_get(ipvs, IPPROTO_TCP);
 		pd->timeout_table[IP_VS_TCP_S_ESTABLISHED]
 			= u->tcp_timeout * HZ;
 	}
 
 	if (u->tcp_fin_timeout) {
-		pd = ip_vs_proto_data_get(net, IPPROTO_TCP);
+		pd = ip_vs_proto_data_get(ipvs, IPPROTO_TCP);
 		pd->timeout_table[IP_VS_TCP_S_FIN_WAIT]
 			= u->tcp_fin_timeout * HZ;
 	}
@@ -2229,7 +2230,7 @@ static int ip_vs_set_timeout(struct net *net, struct ip_vs_timeout_user *u)
 
 #ifdef CONFIG_IP_VS_PROTO_UDP
 	if (u->udp_timeout) {
-		pd = ip_vs_proto_data_get(net, IPPROTO_UDP);
+		pd = ip_vs_proto_data_get(ipvs, IPPROTO_UDP);
 		pd->timeout_table[IP_VS_UDP_S_NORMAL]
 			= u->udp_timeout * HZ;
 	}
@@ -2589,18 +2590,19 @@ static inline void
 __ip_vs_get_timeouts(struct net *net, struct ip_vs_timeout_user *u)
 {
 #if defined(CONFIG_IP_VS_PROTO_TCP) || defined(CONFIG_IP_VS_PROTO_UDP)
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_proto_data *pd;
 #endif
 
 	memset(u, 0, sizeof (*u));
 
 #ifdef CONFIG_IP_VS_PROTO_TCP
-	pd = ip_vs_proto_data_get(net, IPPROTO_TCP);
+	pd = ip_vs_proto_data_get(ipvs, IPPROTO_TCP);
 	u->tcp_timeout = pd->timeout_table[IP_VS_TCP_S_ESTABLISHED] / HZ;
 	u->tcp_fin_timeout = pd->timeout_table[IP_VS_TCP_S_FIN_WAIT] / HZ;
 #endif
 #ifdef CONFIG_IP_VS_PROTO_UDP
-	pd = ip_vs_proto_data_get(net, IPPROTO_UDP);
+	pd = ip_vs_proto_data_get(ipvs, IPPROTO_UDP);
 	u->udp_timeout =
 			pd->timeout_table[IP_VS_UDP_S_NORMAL] / HZ;
 #endif
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 939f7fbe9b46..82ccfd2f235c 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -156,8 +156,8 @@ EXPORT_SYMBOL(ip_vs_proto_get);
 /*
  *	get ip_vs_protocol object data by netns and proto
  */
-static struct ip_vs_proto_data *
-__ipvs_proto_data_get(struct netns_ipvs *ipvs, unsigned short proto)
+struct ip_vs_proto_data *
+ip_vs_proto_data_get(struct netns_ipvs *ipvs, unsigned short proto)
 {
 	struct ip_vs_proto_data *pd;
 	unsigned int hash = IP_VS_PROTO_HASH(proto);
@@ -169,14 +169,6 @@ __ipvs_proto_data_get(struct netns_ipvs *ipvs, unsigned short proto)
 
 	return NULL;
 }
-
-struct ip_vs_proto_data *
-ip_vs_proto_data_get(struct net *net, unsigned short proto)
-{
-	struct netns_ipvs *ipvs = net_ipvs(net);
-
-	return __ipvs_proto_data_get(ipvs, proto);
-}
 EXPORT_SYMBOL(ip_vs_proto_data_get);
 
 /*
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 373a4751c328..8f39e0266ade 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -494,7 +494,7 @@ static int sctp_register_app(struct net *net, struct ip_vs_app *inc)
 	__be16 port = inc->port;
 	int ret = 0;
 	struct netns_ipvs *ipvs = net_ipvs(net);
-	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net, IPPROTO_SCTP);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(ipvs, IPPROTO_SCTP);
 
 	hash = sctp_app_hashkey(port);
 
@@ -513,7 +513,7 @@ out:
 
 static void sctp_unregister_app(struct net *net, struct ip_vs_app *inc)
 {
-	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net, IPPROTO_SCTP);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net_ipvs(net), IPPROTO_SCTP);
 
 	atomic_dec(&pd->appcnt);
 	list_del_rcu(&inc->p_list);
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 48af3ca6be03..975aa69eec9c 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -602,7 +602,7 @@ static int tcp_register_app(struct net *net, struct ip_vs_app *inc)
 	__be16 port = inc->port;
 	int ret = 0;
 	struct netns_ipvs *ipvs = net_ipvs(net);
-	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net, IPPROTO_TCP);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(ipvs, IPPROTO_TCP);
 
 	hash = tcp_app_hashkey(port);
 
@@ -623,7 +623,7 @@ static int tcp_register_app(struct net *net, struct ip_vs_app *inc)
 static void
 tcp_unregister_app(struct net *net, struct ip_vs_app *inc)
 {
-	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net, IPPROTO_TCP);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net_ipvs(net), IPPROTO_TCP);
 
 	atomic_dec(&pd->appcnt);
 	list_del_rcu(&inc->p_list);
@@ -679,7 +679,7 @@ tcp_app_conn_bind(struct ip_vs_conn *cp)
  */
 void ip_vs_tcp_conn_listen(struct net *net, struct ip_vs_conn *cp)
 {
-	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net, IPPROTO_TCP);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net_ipvs(net), IPPROTO_TCP);
 
 	spin_lock_bh(&cp->lock);
 	cp->state = IP_VS_TCP_S_LISTEN;
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index e9f5f7e30bef..1baa7494446a 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -372,7 +372,7 @@ static int udp_register_app(struct net *net, struct ip_vs_app *inc)
 	__be16 port = inc->port;
 	int ret = 0;
 	struct netns_ipvs *ipvs = net_ipvs(net);
-	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net, IPPROTO_UDP);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(ipvs, IPPROTO_UDP);
 
 	hash = udp_app_hashkey(port);
 
@@ -393,7 +393,7 @@ static int udp_register_app(struct net *net, struct ip_vs_app *inc)
 static void
 udp_unregister_app(struct net *net, struct ip_vs_app *inc)
 {
-	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net, IPPROTO_UDP);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net_ipvs(net), IPPROTO_UDP);
 
 	atomic_dec(&pd->appcnt);
 	list_del_rcu(&inc->p_list);
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 9a49c3899f2e..d158e0713ab9 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -941,7 +941,7 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 	} else {
 		struct ip_vs_proto_data *pd;
 
-		pd = ip_vs_proto_data_get(net, protocol);
+		pd = ip_vs_proto_data_get(ipvs, protocol);
 		if (!(flags & IP_VS_CONN_F_TEMPLATE) && pd && pd->timeout_table)
 			cp->timeout = pd->timeout_table[state];
 		else
-- 
2.2.1

