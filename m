From: Quentin Armitage <quentin@armitage.org.uk>
Subject: [PATCH v4 net] ipvs: fix bind to link-local mcast IPv6 address in backup
Date: Thu, 16 Jun 2016 08:00:14 +0100
Message-ID: <1466060414-12944-1-git-send-email-quentin@armitage.org.uk>
References: <Message-id: <alpine.LFD.2.11.1606160912380.2490@ja.home.ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Message-id: <alpine.LFD.2.11.1606160912380.2490@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org
Cc: Quentin Armitage <quentin@armitage.org.uk>

When using HEAD from
https://git.kernel.org/cgit/utils/kernel/ipvsadm/ipvsadm.git/,
the command:
ipvsadm --start-daemon backup --mcast-interface eth0.60 \
    --mcast-group ff02::1:81
fails with the error message:
Argument list too long

whereas both:
ipvsadm --start-daemon master --mcast-interface eth0.60 \
    --mcast-group ff02::1:81
and:
ipvsadm --start-daemon backup --mcast-interface eth0.60 \
    --mcast-group 224.0.0.81
are successful.

The error message "Argument list too long" isn't helpful. The error occurs
because an IPv6 address is given in backup mode.

The error is in make_receive_sock() in net/netfilter/ipvs/ip_vs_sync.c,
since it fails to set the interface on the address or the socket before
calling inet6_bind() (via sock->ops->bind), where the test
'if (!sk->sk_bound_dev_if)' failed.

Setting sock->sk->sk_bound_dev_if on the socket before calling
inet6_bind() resolves the issue.

Fixes: d33288172e72 ("ipvs: add more mcast parameters for the sync daemon")
Signed-off-by: Quentin Armitage <quentin@armitage.org.uk>
---
 net/netfilter/ipvs/ip_vs_sync.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 803001a..1b07578 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1545,7 +1545,8 @@ error:
 /*
  *      Set up receiving multicast socket over UDP
  */
-static struct socket *make_receive_sock(struct netns_ipvs *ipvs, int id)
+static struct socket *make_receive_sock(struct netns_ipvs *ipvs, int id,
+					int ifindex)
 {
 	/* multicast addr */
 	union ipvs_sockaddr mcast_addr;
@@ -1566,6 +1567,7 @@ static struct socket *make_receive_sock(struct netns_ipvs *ipvs, int id)
 		set_sock_size(sock->sk, 0, result);
 
 	get_mcast_sockaddr(&mcast_addr, &salen, &ipvs->bcfg, id);
+	sock->sk->sk_bound_dev_if = ifindex;
 	result = sock->ops->bind(sock, (struct sockaddr *)&mcast_addr, salen);
 	if (result < 0) {
 		pr_err("Error binding to the multicast addr\n");
@@ -1868,7 +1870,7 @@ int start_sync_thread(struct netns_ipvs *ipvs, struct ipvs_sync_daemon_cfg *c,
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

