From: Quentin Armitage <quentin@armitage.org.uk>
Subject: [PATCH 1/5] ipvs: Enable setting IPv6 multicast address for ipvs sync daemon backup
Date: Tue, 14 Jun 2016 02:43:29 +0100
Message-ID: <1465868613-26146-2-git-send-email-quentin@armitage.org.uk>
References: <1465868613-26146-1-git-send-email-quentin@armitage.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1465868613-26146-1-git-send-email-quentin@armitage.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org
Cc: Quentin Armitage <quentin@armitage.org.uk>

When using HEAD from https://git.kernel.org/cgit/utils/kernel/ipvsadm/ipvsadm.git/,
the command:
ipvsadm --start-daemon backup --mcast-interface eth0.60 --mcast-group ff01::1:81
fails with the error message:
Argument list too long

whereas both:
ipvsadm --start-daemon master --mcast-interface eth0.60 --mcast-group ff01::1:81
and:
ipvsadm --start-daemon backup --mcast-interface eth0.60 --mcast-group 224.0.0.81
are successful.

The error message "Argument list too long" isn't helpful. The error occurs
because an IPv6 address is given in backup mode.

The error is in make_receive_sock() in net/netfilter/ipvs/ip_vs_sync.c, since
it fails to set the interface on the address or the socket before calling
inet6_bind() (via sock->ops->bind), where the test 'if (!sk->sk_bound_dev_if)'
failed.

Setting sin6_scope_id on the sockaddr before calling inet6_bind() resolves
the issue.

Signed-off-by: Quentin Armitage <quentin@armitage.org.uk>
---
 net/netfilter/ipvs/ip_vs_sync.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 803001a..85b48f1 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1545,7 +1545,7 @@ error:
 /*
  *      Set up receiving multicast socket over UDP
  */
-static struct socket *make_receive_sock(struct netns_ipvs *ipvs, int id)
+static struct socket *make_receive_sock(struct netns_ipvs *ipvs, int id, int ifindex)
 {
 	/* multicast addr */
 	union ipvs_sockaddr mcast_addr;
@@ -1566,6 +1566,7 @@ static struct socket *make_receive_sock(struct netns_ipvs *ipvs, int id)
 		set_sock_size(sock->sk, 0, result);
 
 	get_mcast_sockaddr(&mcast_addr, &salen, &ipvs->bcfg, id);
+	((struct sockaddr_in6 *)&mcast_addr)->sin6_scope_id = ifindex;
 	result = sock->ops->bind(sock, (struct sockaddr *)&mcast_addr, salen);
 	if (result < 0) {
 		pr_err("Error binding to the multicast addr\n");
@@ -1868,7 +1869,7 @@ int start_sync_thread(struct netns_ipvs *ipvs, struct ipvs_sync_daemon_cfg *c,
 		if (state == IP_VS_STATE_MASTER)
 			sock = make_send_sock(ipvs, id);
 		else
-			sock = make_receive_sock(ipvs, id);
+			sock = make_receive_sock(ipvs, id, dev->ifindex);
 		if (IS_ERR(sock)) {
 			result = PTR_ERR(sock);
 			goto outtinfo;
-- 
1.7.7.6

