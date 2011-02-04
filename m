From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 06/14] IPVS: Add sysctl_expire_nodest_conn()
Date: Fri,  4 Feb 2011 18:46:14 +0900
Message-ID: <1296812782-14953-7-git-send-email-horms@verge.net.au>
References: <1296812782-14953-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1296812782-14953-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>, Simon Horman <horms@verge.net.au>

In preparation for not including sysctl_expire_nodest_conn in
struct netns_ipvs when CONFIG_SYCTL is not defined.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index d7a7fcb..ac13db1 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -613,10 +613,16 @@ static int sysctl_nat_icmp_send(struct net *net)
 	return ipvs->sysctl_nat_icmp_send;
 }
 
+static int sysctl_expire_nodest_conn(struct netns_ipvs *ipvs)
+{
+	return ipvs->sysctl_expire_nodest_conn;
+}
+
 #else
 
 static int sysctl_snat_reroute(struct sk_buff *skb) { return 0; }
 static int sysctl_nat_icmp_send(struct net *net) { return 0; }
+static int sysctl_expire_nodest_conn(struct netns_ipvs *ipvs) { return 0; }
 
 #endif
 
@@ -1605,7 +1611,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (cp->dest && !(cp->dest->flags & IP_VS_DEST_F_AVAILABLE)) {
 		/* the destination server is not available */
 
-		if (ipvs->sysctl_expire_nodest_conn) {
+		if (sysctl_expire_nodest_conn(ipvs)) {
 			/* try to expire the connection immediately */
 			ip_vs_conn_expire_now(cp);
 		}
-- 
1.7.2.3

