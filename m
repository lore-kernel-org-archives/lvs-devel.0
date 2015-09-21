From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 39/84] ipvs: Pass ipvs not net to ip_vs_sync_conn_v0
Date: Mon, 21 Sep 2015 13:02:16 -0500
Message-ID: <1442858581-15869-39-git-send-email-ebiederm@xmission.com>
References: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
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
index 280e1c03e598..58ec7850ab06 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -533,10 +533,9 @@ set:
  *      Version 0 , could be switched in by sys_ctl.
  *      Add an ip_vs_conn information into the current sync_buff.
  */
-static void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp,
+static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
 			       int pkts)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_sync_mesg_v0 *m;
 	struct ip_vs_sync_conn_v0 *s;
 	struct ip_vs_sync_buff *buff;
@@ -615,7 +614,7 @@ static void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp,
 			pkts = atomic_add_return(1, &cp->in_pkts);
 		else
 			pkts = sysctl_sync_threshold(ipvs);
-		ip_vs_sync_conn(net, cp, pkts);
+		ip_vs_sync_conn(ipvs->net, cp, pkts);
 	}
 }
 
@@ -637,7 +636,7 @@ void ip_vs_sync_conn(struct net *net, struct ip_vs_conn *cp, int pkts)
 
 	/* Handle old version of the protocol */
 	if (sysctl_sync_ver(ipvs) == 0) {
-		ip_vs_sync_conn_v0(net, cp, pkts);
+		ip_vs_sync_conn_v0(ipvs, cp, pkts);
 		return;
 	}
 	/* Do not sync ONE PACKET */
-- 
2.2.1
