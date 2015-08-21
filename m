From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 4/4 nf-next] ipvs: add more mcast parameters for the sync daemon
Date: Fri, 21 Aug 2015 09:23:42 -0700
Message-ID: <1440174222-12695-5-git-send-email-horms@verge.net.au>
References: <1440174222-12695-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1440174222-12695-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

- mcast_group: configure the multicast address, now IPv6
is supported too

- mcast_port: configure the multicast port

- mcast_ttl: configure the multicast TTL/HOP_LIMIT

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             |   4 ++
 include/uapi/linux/ip_vs.h      |   4 ++
 net/netfilter/ipvs/ip_vs_ctl.c  |  50 ++++++++++++++-
 net/netfilter/ipvs/ip_vs_sync.c | 138 +++++++++++++++++++++++++++++++++-------
 4 files changed, 172 insertions(+), 24 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 2fdc13caf712..9b9ca87a4210 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -847,8 +847,12 @@ struct ipvs_master_sync_state {
 #define IP_VS_DEST_TRASH_PERIOD		(120 * HZ)
 
 struct ipvs_sync_daemon_cfg {
+	union nf_inet_addr	mcast_group;
 	int			syncid;
 	u16			sync_maxlen;
+	u16			mcast_port;
+	u8			mcast_af;
+	u8			mcast_ttl;
 	/* multicast interface name */
 	char			mcast_ifn[IP_VS_IFNAME_MAXLEN];
 };
diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
index 68377d8c8870..391395c06c7e 100644
--- a/include/uapi/linux/ip_vs.h
+++ b/include/uapi/linux/ip_vs.h
@@ -407,6 +407,10 @@ enum {
 	IPVS_DAEMON_ATTR_MCAST_IFN,	/* multicast interface name */
 	IPVS_DAEMON_ATTR_SYNC_ID,	/* SyncID we belong to */
 	IPVS_DAEMON_ATTR_SYNC_MAXLEN,	/* UDP Payload Size */
+	IPVS_DAEMON_ATTR_MCAST_GROUP,	/* IPv4 Multicast Address */
+	IPVS_DAEMON_ATTR_MCAST_GROUP6,	/* IPv6 Multicast Address */
+	IPVS_DAEMON_ATTR_MCAST_PORT,	/* Multicast Port (base) */
+	IPVS_DAEMON_ATTR_MCAST_TTL,	/* Multicast TTL */
 	__IPVS_DAEMON_ATTR_MAX,
 };
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 96f7bbfd5e1d..1a23e91d50d8 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2819,6 +2819,10 @@ static const struct nla_policy ip_vs_daemon_policy[IPVS_DAEMON_ATTR_MAX + 1] = {
 					    .len = IP_VS_IFNAME_MAXLEN },
 	[IPVS_DAEMON_ATTR_SYNC_ID]	= { .type = NLA_U32 },
 	[IPVS_DAEMON_ATTR_SYNC_MAXLEN]	= { .type = NLA_U16 },
+	[IPVS_DAEMON_ATTR_MCAST_GROUP]	= { .type = NLA_U32 },
+	[IPVS_DAEMON_ATTR_MCAST_GROUP6]	= { .len = sizeof(struct in6_addr) },
+	[IPVS_DAEMON_ATTR_MCAST_PORT]	= { .type = NLA_U16 },
+	[IPVS_DAEMON_ATTR_MCAST_TTL]	= { .type = NLA_U8 },
 };
 
 /* Policy used for attributes in nested attribute IPVS_CMD_ATTR_SERVICE */
@@ -3288,8 +3292,21 @@ static int ip_vs_genl_fill_daemon(struct sk_buff *skb, __u32 state,
 	if (nla_put_u32(skb, IPVS_DAEMON_ATTR_STATE, state) ||
 	    nla_put_string(skb, IPVS_DAEMON_ATTR_MCAST_IFN, c->mcast_ifn) ||
 	    nla_put_u32(skb, IPVS_DAEMON_ATTR_SYNC_ID, c->syncid) ||
-	    nla_put_u16(skb, IPVS_DAEMON_ATTR_SYNC_MAXLEN, c->sync_maxlen))
+	    nla_put_u16(skb, IPVS_DAEMON_ATTR_SYNC_MAXLEN, c->sync_maxlen) ||
+	    nla_put_u16(skb, IPVS_DAEMON_ATTR_MCAST_PORT, c->mcast_port) ||
+	    nla_put_u8(skb, IPVS_DAEMON_ATTR_MCAST_TTL, c->mcast_ttl))
 		goto nla_put_failure;
+#ifdef CONFIG_IP_VS_IPV6
+	if (c->mcast_af == AF_INET6) {
+		if (nla_put_in6_addr(skb, IPVS_DAEMON_ATTR_MCAST_GROUP6,
+				     &c->mcast_group.in6))
+			goto nla_put_failure;
+	} else
+#endif
+		if (c->mcast_af == AF_INET &&
+		    nla_put_in_addr(skb, IPVS_DAEMON_ATTR_MCAST_GROUP,
+				    c->mcast_group.ip))
+			goto nla_put_failure;
 	nla_nest_end(skb, nl_daemon);
 
 	return 0;
@@ -3370,6 +3387,37 @@ static int ip_vs_genl_new_daemon(struct net *net, struct nlattr **attrs)
 	if (a)
 		c.sync_maxlen = nla_get_u16(a);
 
+	a = attrs[IPVS_DAEMON_ATTR_MCAST_GROUP];
+	if (a) {
+		c.mcast_af = AF_INET;
+		c.mcast_group.ip = nla_get_in_addr(a);
+		if (!ipv4_is_multicast(c.mcast_group.ip))
+			return -EINVAL;
+	} else {
+		a = attrs[IPVS_DAEMON_ATTR_MCAST_GROUP6];
+		if (a) {
+#ifdef CONFIG_IP_VS_IPV6
+			int addr_type;
+
+			c.mcast_af = AF_INET6;
+			c.mcast_group.in6 = nla_get_in6_addr(a);
+			addr_type = ipv6_addr_type(&c.mcast_group.in6);
+			if (!(addr_type & IPV6_ADDR_MULTICAST))
+				return -EINVAL;
+#else
+			return -EAFNOSUPPORT;
+#endif
+		}
+	}
+
+	a = attrs[IPVS_DAEMON_ATTR_MCAST_PORT];
+	if (a)
+		c.mcast_port = nla_get_u16(a);
+
+	a = attrs[IPVS_DAEMON_ATTR_MCAST_TTL];
+	if (a)
+		c.mcast_ttl = nla_get_u8(a);
+
 	/* The synchronization protocol is incompatible with mixed family
 	 * services
 	 */
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index e68a43421479..43f140950075 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -262,6 +262,11 @@ struct ip_vs_sync_mesg {
 	/* ip_vs_sync_conn entries start here */
 };
 
+union ipvs_sockaddr {
+	struct sockaddr_in	in;
+	struct sockaddr_in6	in6;
+};
+
 struct ip_vs_sync_buff {
 	struct list_head        list;
 	unsigned long           firstuse;
@@ -1301,6 +1306,14 @@ static void set_mcast_loop(struct sock *sk, u_char loop)
 	/* setsockopt(sock, SOL_IP, IP_MULTICAST_LOOP, &loop, sizeof(loop)); */
 	lock_sock(sk);
 	inet->mc_loop = loop ? 1 : 0;
+#ifdef CONFIG_IP_VS_IPV6
+	if (sk->sk_family == AF_INET6) {
+		struct ipv6_pinfo *np = inet6_sk(sk);
+
+		/* IPV6_MULTICAST_LOOP */
+		np->mc_loop = loop ? 1 : 0;
+	}
+#endif
 	release_sock(sk);
 }
 
@@ -1314,6 +1327,14 @@ static void set_mcast_ttl(struct sock *sk, u_char ttl)
 	/* setsockopt(sock, SOL_IP, IP_MULTICAST_TTL, &ttl, sizeof(ttl)); */
 	lock_sock(sk);
 	inet->mc_ttl = ttl;
+#ifdef CONFIG_IP_VS_IPV6
+	if (sk->sk_family == AF_INET6) {
+		struct ipv6_pinfo *np = inet6_sk(sk);
+
+		/* IPV6_MULTICAST_HOPS */
+		np->mcast_hops = ttl;
+	}
+#endif
 	release_sock(sk);
 }
 
@@ -1325,6 +1346,14 @@ static void set_mcast_pmtudisc(struct sock *sk, int val)
 	/* setsockopt(sock, SOL_IP, IP_MTU_DISCOVER, &val, sizeof(val)); */
 	lock_sock(sk);
 	inet->pmtudisc = val;
+#ifdef CONFIG_IP_VS_IPV6
+	if (sk->sk_family == AF_INET6) {
+		struct ipv6_pinfo *np = inet6_sk(sk);
+
+		/* IPV6_MTU_DISCOVER */
+		np->pmtudisc = val;
+	}
+#endif
 	release_sock(sk);
 }
 
@@ -1347,6 +1376,14 @@ static int set_mcast_if(struct sock *sk, char *ifname)
 	lock_sock(sk);
 	inet->mc_index = dev->ifindex;
 	/*  inet->mc_addr  = 0; */
+#ifdef CONFIG_IP_VS_IPV6
+	if (sk->sk_family == AF_INET6) {
+		struct ipv6_pinfo *np = inet6_sk(sk);
+
+		/* IPV6_MULTICAST_IF */
+		np->mcast_oif = dev->ifindex;
+	}
+#endif
 	release_sock(sk);
 
 	return 0;
@@ -1384,6 +1421,27 @@ join_mcast_group(struct sock *sk, struct in_addr *addr, char *ifname)
 	return ret;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static int join_mcast_group6(struct sock *sk, struct in6_addr *addr,
+			     char *ifname)
+{
+	struct net *net = sock_net(sk);
+	struct net_device *dev;
+	int ret;
+
+	dev = __dev_get_by_name(net, ifname);
+	if (!dev)
+		return -ENODEV;
+	if (sk->sk_bound_dev_if && dev->ifindex != sk->sk_bound_dev_if)
+		return -EINVAL;
+
+	lock_sock(sk);
+	ret = ipv6_sock_mc_join(sk, dev->ifindex, addr);
+	release_sock(sk);
+
+	return ret;
+}
+#endif
 
 static int bind_mcastif_addr(struct socket *sock, char *ifname)
 {
@@ -1412,6 +1470,26 @@ static int bind_mcastif_addr(struct socket *sock, char *ifname)
 	return sock->ops->bind(sock, (struct sockaddr*)&sin, sizeof(sin));
 }
 
+static void get_mcast_sockaddr(union ipvs_sockaddr *sa, int *salen,
+			       struct ipvs_sync_daemon_cfg *c, int id)
+{
+	if (AF_INET6 == c->mcast_af) {
+		sa->in6 = (struct sockaddr_in6) {
+			.sin6_family = AF_INET6,
+			.sin6_port = htons(c->mcast_port + id),
+		};
+		sa->in6.sin6_addr = c->mcast_group.in6;
+		*salen = sizeof(sa->in6);
+	} else {
+		sa->in = (struct sockaddr_in) {
+			.sin_family = AF_INET,
+			.sin_port = htons(c->mcast_port + id),
+		};
+		sa->in.sin_addr = c->mcast_group.in;
+		*salen = sizeof(sa->in);
+	}
+}
+
 /*
  *      Set up sending multicast socket over UDP
  */
@@ -1419,16 +1497,13 @@ static struct socket *make_send_sock(struct net *net, int id)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	/* multicast addr */
-	struct sockaddr_in mcast_addr = {
-		.sin_family		= AF_INET,
-		.sin_port		= cpu_to_be16(IP_VS_SYNC_PORT + id),
-		.sin_addr.s_addr	= cpu_to_be32(IP_VS_SYNC_GROUP),
-	};
+	union ipvs_sockaddr mcast_addr;
 	struct socket *sock;
-	int result;
+	int result, salen;
 
 	/* First create a socket */
-	result = sock_create_kern(net, PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
+	result = sock_create_kern(net, ipvs->mcfg.mcast_af, SOCK_DGRAM,
+				  IPPROTO_UDP, &sock);
 	if (result < 0) {
 		pr_err("Error during creation of socket; terminating\n");
 		return ERR_PTR(result);
@@ -1440,21 +1515,25 @@ static struct socket *make_send_sock(struct net *net, int id)
 	}
 
 	set_mcast_loop(sock->sk, 0);
-	set_mcast_ttl(sock->sk, 1);
+	set_mcast_ttl(sock->sk, ipvs->mcfg.mcast_ttl);
 	/* Allow fragmentation if MTU changes */
 	set_mcast_pmtudisc(sock->sk, IP_PMTUDISC_DONT);
 	result = sysctl_sync_sock_size(ipvs);
 	if (result > 0)
 		set_sock_size(sock->sk, 1, result);
 
-	result = bind_mcastif_addr(sock, ipvs->mcfg.mcast_ifn);
+	if (AF_INET == ipvs->mcfg.mcast_af)
+		result = bind_mcastif_addr(sock, ipvs->mcfg.mcast_ifn);
+	else
+		result = 0;
 	if (result < 0) {
 		pr_err("Error binding address of the mcast interface\n");
 		goto error;
 	}
 
+	get_mcast_sockaddr(&mcast_addr, &salen, &ipvs->mcfg, id);
 	result = sock->ops->connect(sock, (struct sockaddr *) &mcast_addr,
-			sizeof(struct sockaddr), 0);
+				    salen, 0);
 	if (result < 0) {
 		pr_err("Error connecting to the multicast addr\n");
 		goto error;
@@ -1475,16 +1554,13 @@ static struct socket *make_receive_sock(struct net *net, int id)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	/* multicast addr */
-	struct sockaddr_in mcast_addr = {
-		.sin_family		= AF_INET,
-		.sin_port		= cpu_to_be16(IP_VS_SYNC_PORT + id),
-		.sin_addr.s_addr	= cpu_to_be32(IP_VS_SYNC_GROUP),
-	};
+	union ipvs_sockaddr mcast_addr;
 	struct socket *sock;
-	int result;
+	int result, salen;
 
 	/* First create a socket */
-	result = sock_create_kern(net, PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
+	result = sock_create_kern(net, ipvs->bcfg.mcast_af, SOCK_DGRAM,
+				  IPPROTO_UDP, &sock);
 	if (result < 0) {
 		pr_err("Error during creation of socket; terminating\n");
 		return ERR_PTR(result);
@@ -1495,17 +1571,22 @@ static struct socket *make_receive_sock(struct net *net, int id)
 	if (result > 0)
 		set_sock_size(sock->sk, 0, result);
 
-	result = sock->ops->bind(sock, (struct sockaddr *) &mcast_addr,
-			sizeof(struct sockaddr));
+	get_mcast_sockaddr(&mcast_addr, &salen, &ipvs->bcfg, id);
+	result = sock->ops->bind(sock, (struct sockaddr *)&mcast_addr, salen);
 	if (result < 0) {
 		pr_err("Error binding to the multicast addr\n");
 		goto error;
 	}
 
 	/* join the multicast group */
-	result = join_mcast_group(sock->sk,
-			(struct in_addr *) &mcast_addr.sin_addr,
-			ipvs->bcfg.mcast_ifn);
+#ifdef CONFIG_IP_VS_IPV6
+	if (ipvs->bcfg.mcast_af == AF_INET6)
+		result = join_mcast_group6(sock->sk, &mcast_addr.in6.sin6_addr,
+					   ipvs->bcfg.mcast_ifn);
+	else
+#endif
+		result = join_mcast_group(sock->sk, &mcast_addr.in.sin_addr,
+					  ipvs->bcfg.mcast_ifn);
 	if (result < 0) {
 		pr_err("Error joining to the multicast group\n");
 		goto error;
@@ -1721,12 +1802,23 @@ int start_sync_thread(struct net *net, struct ipvs_sync_daemon_cfg *c,
 	} else
 		count = ipvs->threads_mask + 1;
 
+	if (c->mcast_af == AF_UNSPEC) {
+		c->mcast_af = AF_INET;
+		c->mcast_group.ip = cpu_to_be32(IP_VS_SYNC_GROUP);
+	}
+	if (!c->mcast_port)
+		c->mcast_port = IP_VS_SYNC_PORT;
+	if (!c->mcast_ttl)
+		c->mcast_ttl = 1;
+
 	dev = __dev_get_by_name(net, c->mcast_ifn);
 	if (!dev) {
 		pr_err("Unknown mcast interface: %s\n", c->mcast_ifn);
 		return -ENODEV;
 	}
-	hlen = sizeof(struct iphdr) + sizeof(struct udphdr);
+	hlen = (AF_INET6 == c->mcast_af) ?
+	       sizeof(struct ipv6hdr) + sizeof(struct udphdr) :
+	       sizeof(struct iphdr) + sizeof(struct udphdr);
 	mtu = (state == IP_VS_STATE_BACKUP) ?
 		  clamp(dev->mtu, 1500U, 65535U) : 1500U;
 	min_mtu = (state == IP_VS_STATE_BACKUP) ? 1024 : 1;
-- 
2.1.4
