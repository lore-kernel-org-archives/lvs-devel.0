From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 39/84] ipvs: Pass ipvs not net to ip_vs_sync_conn_v0
Date: Thu, 24 Sep 2015 09:52:24 +0900
Message-ID: <1443055989-1306-40-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "Eric W. Biederman" <ebiederm@xmission.com>, Simon Horman <horms@verge.net.au>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
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
2.1.4

