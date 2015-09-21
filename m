From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 35/84] ipvs: Pass ipvs not net to make_send_sock
Date: Mon, 21 Sep 2015 13:02:12 -0500
Message-ID: <1442858581-15869-35-git-send-email-ebiederm@xmission.com>
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
 net/netfilter/ipvs/ip_vs_sync.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 0b2e01aa764a..dc987762ca2c 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1493,16 +1493,15 @@ static void get_mcast_sockaddr(union ipvs_sockaddr *sa, int *salen,
 /*
  *      Set up sending multicast socket over UDP
  */
-static struct socket *make_send_sock(struct net *net, int id)
+static struct socket *make_send_sock(struct netns_ipvs *ipvs, int id)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	/* multicast addr */
 	union ipvs_sockaddr mcast_addr;
 	struct socket *sock;
 	int result, salen;
 
 	/* First create a socket */
-	result = sock_create_kern(net, ipvs->mcfg.mcast_af, SOCK_DGRAM,
+	result = sock_create_kern(ipvs->net, ipvs->mcfg.mcast_af, SOCK_DGRAM,
 				  IPPROTO_UDP, &sock);
 	if (result < 0) {
 		pr_err("Error during creation of socket; terminating\n");
@@ -1872,7 +1871,7 @@ int start_sync_thread(struct netns_ipvs *ipvs, struct ipvs_sync_daemon_cfg *c,
 	tinfo = NULL;
 	for (id = 0; id < count; id++) {
 		if (state == IP_VS_STATE_MASTER)
-			sock = make_send_sock(ipvs->net, id);
+			sock = make_send_sock(ipvs, id);
 		else
 			sock = make_receive_sock(ipvs->net, id);
 		if (IS_ERR(sock)) {
-- 
2.2.1

