From: Quentin Armitage <quentin@armitage.org.uk>
Subject: [PATCH net-next v4 1/3] ipvs: Stop calling __dev_get_by_name() repeatedly when starting sync daemon
Date: Thu, 16 Jun 2016 08:00:25 +0100
Message-ID: <1466060427-12988-1-git-send-email-quentin@armitage.org.uk>
References: <Message-id: <alpine.LFD.2.11.1606160912380.2490@ja.home.ssi.bg>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Message-id: <alpine.LFD.2.11.1606160912380.2490@ja.home.ssi.bg>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org
Cc: Quentin Armitage <quentin@armitage.org.uk>

Optimise starting sync daemons by using the result of the first call to
__dev_get_by_name() and pass the result or ifindex to subsequent functions
to avoid them having to call __dev_get_by_name() again.

Signed-off-by: Quentin Armitage <quentin@armitage.org.uk>
---
 net/netfilter/ipvs/ip_vs_sync.c |   60 +++++++++++++--------------------------
 1 files changed, 20 insertions(+), 40 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 1b07578..fbc5ba4 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1356,28 +1356,22 @@ static void set_mcast_pmtudisc(struct sock *sk, int val)
 /*
  *      Specifiy default interface for outgoing multicasts
  */
-static int set_mcast_if(struct sock *sk, char *ifname)
+static int set_mcast_if(struct sock *sk, int ifindex)
 {
-	struct net_device *dev;
 	struct inet_sock *inet = inet_sk(sk);
-	struct net *net = sock_net(sk);
-
-	dev = __dev_get_by_name(net, ifname);
-	if (!dev)
-		return -ENODEV;
 
-	if (sk->sk_bound_dev_if && dev->ifindex != sk->sk_bound_dev_if)
+	if (sk->sk_bound_dev_if && ifindex != sk->sk_bound_dev_if)
 		return -EINVAL;
 
 	lock_sock(sk);
-	inet->mc_index = dev->ifindex;
+	inet->mc_index = ifindex;
 	/*  inet->mc_addr  = 0; */
 #ifdef CONFIG_IP_VS_IPV6
 	if (sk->sk_family == AF_INET6) {
 		struct ipv6_pinfo *np = inet6_sk(sk);
 
 		/* IPV6_MULTICAST_IF */
-		np->mcast_oif = dev->ifindex;
+		np->mcast_oif = ifindex;
 	}
 #endif
 	release_sock(sk);
@@ -1392,23 +1386,18 @@ static int set_mcast_if(struct sock *sk, char *ifname)
  *      in the in_addr structure passed in as a parameter.
  */
 static int
-join_mcast_group(struct sock *sk, struct in_addr *addr, char *ifname)
+join_mcast_group(struct sock *sk, struct in_addr *addr, int ifindex)
 {
-	struct net *net = sock_net(sk);
 	struct ip_mreqn mreq;
-	struct net_device *dev;
 	int ret;
 
 	memset(&mreq, 0, sizeof(mreq));
 	memcpy(&mreq.imr_multiaddr, addr, sizeof(struct in_addr));
 
-	dev = __dev_get_by_name(net, ifname);
-	if (!dev)
-		return -ENODEV;
-	if (sk->sk_bound_dev_if && dev->ifindex != sk->sk_bound_dev_if)
+	if (sk->sk_bound_dev_if && ifindex != sk->sk_bound_dev_if)
 		return -EINVAL;
 
-	mreq.imr_ifindex = dev->ifindex;
+	mreq.imr_ifindex = ifindex;
 
 	lock_sock(sk);
 	ret = ip_mc_join_group(sk, &mreq);
@@ -1419,44 +1408,33 @@ join_mcast_group(struct sock *sk, struct in_addr *addr, char *ifname)
 
 #ifdef CONFIG_IP_VS_IPV6
 static int join_mcast_group6(struct sock *sk, struct in6_addr *addr,
-			     char *ifname)
+			     int ifindex)
 {
-	struct net *net = sock_net(sk);
-	struct net_device *dev;
 	int ret;
 
-	dev = __dev_get_by_name(net, ifname);
-	if (!dev)
-		return -ENODEV;
-	if (sk->sk_bound_dev_if && dev->ifindex != sk->sk_bound_dev_if)
+	if (sk->sk_bound_dev_if && ifindex != sk->sk_bound_dev_if)
 		return -EINVAL;
 
 	lock_sock(sk);
-	ret = ipv6_sock_mc_join(sk, dev->ifindex, addr);
+	ret = ipv6_sock_mc_join(sk, ifindex, addr);
 	release_sock(sk);
 
 	return ret;
 }
 #endif
 
-static int bind_mcastif_addr(struct socket *sock, char *ifname)
+static int bind_mcastif_addr(struct socket *sock, struct net_device *dev)
 {
-	struct net *net = sock_net(sock->sk);
-	struct net_device *dev;
 	__be32 addr;
 	struct sockaddr_in sin;
 
-	dev = __dev_get_by_name(net, ifname);
-	if (!dev)
-		return -ENODEV;
-
 	addr = inet_select_addr(dev, 0, RT_SCOPE_UNIVERSE);
 	if (!addr)
 		pr_err("You probably need to specify IP address on "
 		       "multicast interface.\n");
 
 	IP_VS_DBG(7, "binding socket with (%s) %pI4\n",
-		  ifname, &addr);
+		  dev->name, &addr);
 
 	/* Now bind the socket with the address of multicast interface */
 	sin.sin_family	     = AF_INET;
@@ -1489,7 +1467,8 @@ static void get_mcast_sockaddr(union ipvs_sockaddr *sa, int *salen,
 /*
  *      Set up sending multicast socket over UDP
  */
-static struct socket *make_send_sock(struct netns_ipvs *ipvs, int id)
+static struct socket *make_send_sock(struct netns_ipvs *ipvs, int id,
+				     struct net_device *dev)
 {
 	/* multicast addr */
 	union ipvs_sockaddr mcast_addr;
@@ -1503,7 +1482,7 @@ static struct socket *make_send_sock(struct netns_ipvs *ipvs, int id)
 		pr_err("Error during creation of socket; terminating\n");
 		return ERR_PTR(result);
 	}
-	result = set_mcast_if(sock->sk, ipvs->mcfg.mcast_ifn);
+	result = set_mcast_if(sock->sk, dev->ifindex);
 	if (result < 0) {
 		pr_err("Error setting outbound mcast interface\n");
 		goto error;
@@ -1518,7 +1497,7 @@ static struct socket *make_send_sock(struct netns_ipvs *ipvs, int id)
 		set_sock_size(sock->sk, 1, result);
 
 	if (AF_INET == ipvs->mcfg.mcast_af)
-		result = bind_mcastif_addr(sock, ipvs->mcfg.mcast_ifn);
+		result = bind_mcastif_addr(sock, dev);
 	else
 		result = 0;
 	if (result < 0) {
@@ -1560,6 +1539,7 @@ static struct socket *make_receive_sock(struct netns_ipvs *ipvs, int id,
 		pr_err("Error during creation of socket; terminating\n");
 		return ERR_PTR(result);
 	}
+
 	/* it is equivalent to the REUSEADDR option in user-space */
 	sock->sk->sk_reuse = SK_CAN_REUSE;
 	result = sysctl_sync_sock_size(ipvs);
@@ -1578,11 +1558,11 @@ static struct socket *make_receive_sock(struct netns_ipvs *ipvs, int id,
 #ifdef CONFIG_IP_VS_IPV6
 	if (ipvs->bcfg.mcast_af == AF_INET6)
 		result = join_mcast_group6(sock->sk, &mcast_addr.in6.sin6_addr,
-					   ipvs->bcfg.mcast_ifn);
+					   ifindex);
 	else
 #endif
 		result = join_mcast_group(sock->sk, &mcast_addr.in.sin_addr,
-					  ipvs->bcfg.mcast_ifn);
+					  ifindex);
 	if (result < 0) {
 		pr_err("Error joining to the multicast group\n");
 		goto error;
@@ -1868,7 +1848,7 @@ int start_sync_thread(struct netns_ipvs *ipvs, struct ipvs_sync_daemon_cfg *c,
 	tinfo = NULL;
 	for (id = 0; id < count; id++) {
 		if (state == IP_VS_STATE_MASTER)
-			sock = make_send_sock(ipvs, id);
+			sock = make_send_sock(ipvs, id, dev);
 		else
 			sock = make_receive_sock(ipvs, id, dev->ifindex);
 		if (IS_ERR(sock)) {
-- 
1.7.7.6

