From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 2/3] ipvs: add backup_only flag to avoid loops
Date: Tue, 19 Mar 2013 21:40:49 +0900
Message-ID: <1363696850-14766-3-git-send-email-horms@verge.net.au>
References: <1363696850-14766-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1363696850-14766-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

Dmitry Akindinov is reporting for a problem where SYNs are looping
between the master and backup server when the backup server is used as
real server in DR mode and has IPVS rules to function as director.

Even when the backup function is enabled we continue to forward
traffic and schedule new connections when the current master is using
the backup server as real server. While this is not a problem for NAT,
for DR and TUN method the backup server can not determine if a request
comes from client or from director.

To avoid such loops add new sysctl flag backup_only. It can be needed
for DR/TUN setups that do not need backup and director function at the
same time. When the backup function is enabled we stop any forwarding
and pass the traffic to the local stack (real server mode). The flag
disables the director function when the backup function is enabled.

For setups that enable backup function for some virtual services and
director function for other virtual services there should be another
more complex solution to support DR/TUN mode, may be to assign
per-virtual service syncid value, so that we can differentiate the
requests.

Reported-by: Dmitry Akindinov <dimak@stalker.com>
Tested-by: German Myzovsky <lawyer@sipnet.ru>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 Documentation/networking/ipvs-sysctl.txt |    7 +++++++
 include/net/ip_vs.h                      |   12 ++++++++++++
 net/netfilter/ipvs/ip_vs_core.c          |   12 ++++++++----
 net/netfilter/ipvs/ip_vs_ctl.c           |    7 +++++++
 4 files changed, 34 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/ipvs-sysctl.txt b/Documentation/networking/ipvs-sysctl.txt
index f2a2488..9573d0c 100644
--- a/Documentation/networking/ipvs-sysctl.txt
+++ b/Documentation/networking/ipvs-sysctl.txt
@@ -15,6 +15,13 @@ amemthresh - INTEGER
         enabled and the variable is automatically set to 2, otherwise
         the strategy is disabled and the variable is  set  to 1.
 
+backup_only - BOOLEAN
+	0 - disabled (default)
+	not 0 - enabled
+
+	If set, disable the director function while the server is
+	in backup mode to avoid packet loops for DR/TUN methods.
+
 conntrack - BOOLEAN
 	0 - disabled (default)
 	not 0 - enabled
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 68c69d5..fce8e6b 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -976,6 +976,7 @@ struct netns_ipvs {
 	int			sysctl_sync_retries;
 	int			sysctl_nat_icmp_send;
 	int			sysctl_pmtu_disc;
+	int			sysctl_backup_only;
 
 	/* ip_vs_lblc */
 	int			sysctl_lblc_expiration;
@@ -1067,6 +1068,12 @@ static inline int sysctl_pmtu_disc(struct netns_ipvs *ipvs)
 	return ipvs->sysctl_pmtu_disc;
 }
 
+static inline int sysctl_backup_only(struct netns_ipvs *ipvs)
+{
+	return ipvs->sync_state & IP_VS_STATE_BACKUP &&
+	       ipvs->sysctl_backup_only;
+}
+
 #else
 
 static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
@@ -1114,6 +1121,11 @@ static inline int sysctl_pmtu_disc(struct netns_ipvs *ipvs)
 	return 1;
 }
 
+static inline int sysctl_backup_only(struct netns_ipvs *ipvs)
+{
+	return 0;
+}
+
 #endif
 
 /*
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 47edf5a..18b4bc5 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1577,7 +1577,8 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	}
 	/* ipvs enabled in this netns ? */
 	net = skb_net(skb);
-	if (!net_ipvs(net)->enable)
+	ipvs = net_ipvs(net);
+	if (unlikely(sysctl_backup_only(ipvs) || !ipvs->enable))
 		return NF_ACCEPT;
 
 	ip_vs_fill_iph_skb(af, skb, &iph);
@@ -1654,7 +1655,6 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	}
 
 	IP_VS_DBG_PKT(11, af, pp, skb, 0, "Incoming packet");
-	ipvs = net_ipvs(net);
 	/* Check the server status */
 	if (cp->dest && !(cp->dest->flags & IP_VS_DEST_F_AVAILABLE)) {
 		/* the destination server is not available */
@@ -1815,13 +1815,15 @@ ip_vs_forward_icmp(unsigned int hooknum, struct sk_buff *skb,
 {
 	int r;
 	struct net *net;
+	struct netns_ipvs *ipvs;
 
 	if (ip_hdr(skb)->protocol != IPPROTO_ICMP)
 		return NF_ACCEPT;
 
 	/* ipvs enabled in this netns ? */
 	net = skb_net(skb);
-	if (!net_ipvs(net)->enable)
+	ipvs = net_ipvs(net);
+	if (unlikely(sysctl_backup_only(ipvs) || !ipvs->enable))
 		return NF_ACCEPT;
 
 	return ip_vs_in_icmp(skb, &r, hooknum);
@@ -1835,6 +1837,7 @@ ip_vs_forward_icmp_v6(unsigned int hooknum, struct sk_buff *skb,
 {
 	int r;
 	struct net *net;
+	struct netns_ipvs *ipvs;
 	struct ip_vs_iphdr iphdr;
 
 	ip_vs_fill_iph_skb(AF_INET6, skb, &iphdr);
@@ -1843,7 +1846,8 @@ ip_vs_forward_icmp_v6(unsigned int hooknum, struct sk_buff *skb,
 
 	/* ipvs enabled in this netns ? */
 	net = skb_net(skb);
-	if (!net_ipvs(net)->enable)
+	ipvs = net_ipvs(net);
+	if (unlikely(sysctl_backup_only(ipvs) || !ipvs->enable))
 		return NF_ACCEPT;
 
 	return ip_vs_in_icmp_v6(skb, &r, hooknum, &iphdr);
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c68198b..9e2d1cc 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1808,6 +1808,12 @@ static struct ctl_table vs_vars[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "backup_only",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 #ifdef CONFIG_IP_VS_DEBUG
 	{
 		.procname	= "debug_level",
@@ -3741,6 +3747,7 @@ static int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 	tbl[idx++].data = &ipvs->sysctl_nat_icmp_send;
 	ipvs->sysctl_pmtu_disc = 1;
 	tbl[idx++].data = &ipvs->sysctl_pmtu_disc;
+	tbl[idx++].data = &ipvs->sysctl_backup_only;
 
 
 	ipvs->sysctl_hdr = register_net_sysctl(net, "net/ipv4/vs", tbl);
-- 
1.7.10.4

