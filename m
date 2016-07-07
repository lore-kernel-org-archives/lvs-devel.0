From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf] ipvs: fix bind to link-local mcast IPv6 address in backup
Date: Thu,  7 Jul 2016 20:30:22 +0200
Message-ID: <1467916222-15595-2-git-send-email-horms@verge.net.au>
References: <1467916222-15595-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1467916229; bh=XUvFR/vsud0j/8YN2r+cy7AaJJzxNF0WX/Cf4fC8kiw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=XNsRpqISpScyklvCdQ+wYzhBq36Sn7AM8V6HKNsG/pF2gfxKMCy0LUCfwjHcqfgpr
	 ZRLQQTaEoRaQ+Yx0CkliHyZLhw35ToGByMZQlKuCiA3JV+ptH2RbdNa5oOO65e5/j1
	 X7AmCvWAqa27SzvypNGEzimbmpeCjgy7V2/13OHY=
In-Reply-To: <1467916222-15595-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Quentin Armitage <quentin@armitage.org.uk>, Simon Horman <horms@verge.net.au>

From: Quentin Armitage <quentin@armitage.org.uk>

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
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sync.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 803001a45aa1..1b07578bedf3 100644
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
2.7.0.rc3.207.g0ac5344

