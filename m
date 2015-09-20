From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 36/84] ipvs: Pass ipvs not net to make_receive_sock
Date: Sun, 20 Sep 2015 01:22:52 -0500
Message-ID: <1442730220-32458-36-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_sync.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index dc987762ca2c..304eade977d2 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1549,16 +1549,15 @@ error:
 /*
  *      Set up receiving multicast socket over UDP
  */
-static struct socket *make_receive_sock(struct net *net, int id)
+static struct socket *make_receive_sock(struct netns_ipvs *ipvs, int id)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	/* multicast addr */
 	union ipvs_sockaddr mcast_addr;
 	struct socket *sock;
 	int result, salen;
 
 	/* First create a socket */
-	result = sock_create_kern(net, ipvs->bcfg.mcast_af, SOCK_DGRAM,
+	result = sock_create_kern(ipvs->net, ipvs->bcfg.mcast_af, SOCK_DGRAM,
 				  IPPROTO_UDP, &sock);
 	if (result < 0) {
 		pr_err("Error during creation of socket; terminating\n");
@@ -1873,7 +1872,7 @@ int start_sync_thread(struct netns_ipvs *ipvs, struct ipvs_sync_daemon_cfg *c,
 		if (state == IP_VS_STATE_MASTER)
 			sock = make_send_sock(ipvs, id);
 		else
-			sock = make_receive_sock(ipvs->net, id);
+			sock = make_receive_sock(ipvs, id);
 		if (IS_ERR(sock)) {
 			result = PTR_ERR(sock);
 			goto outtinfo;
-- 
2.2.1
