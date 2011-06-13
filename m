From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [PATCH 1/1] IPVS  netns exit causes crash in conntrack
Date: Mon, 13 Jun 2011 09:06:57 +0200
Message-ID: <1307948817-5367-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: kaber@trash.net, hans@schillstrom.com, Hans Schillstrom <hans.schillstrom@ericsson.com>

Quote from Patric Mc Hardy
"This looks like nfnetlink.c excited and destroyed the nfnl socket, but
ip_vs was still holding a reference to a conntrack. When the conntrack
got destroyed it created a ctnetlink event, causing an oops in
netlink_has_listeners when trying to use the destroyed nfnetlink
socket."

If nf_conntrack_netlink is loaded before ip_vs this is not a problem.

This patch simply avoids calling ip_vs_conn_drop_conntrack()
when netns is dying as suggested by Julian.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 net/netfilter/ipvs/ip_vs_conn.c |   10 +++++++++-
 net/netfilter/ipvs/ip_vs_core.c |    1 +
 2 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index bf28ac2..d7dfccb 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -776,8 +776,16 @@ static void ip_vs_conn_expire(unsigned long data)
 		if (cp->control)
 			ip_vs_control_del(cp);
 
-		if (cp->flags & IP_VS_CONN_F_NFCT)
+		if (cp->flags & IP_VS_CONN_F_NFCT) {
 			ip_vs_conn_drop_conntrack(cp);
+		/* Do not access conntracks during subsys cleanup because
+		 * nf_conntrack_find_get can not be used after conntrack
+		 * cleanup for the net.
+		 */
+			smp_rmb();
+			if (ipvs->enable)
+				ip_vs_conn_drop_conntrack(cp);
+		}
 
 		ip_vs_pe_put(cp->pe);
 		kfree(cp->pe_data);
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index bfa808f..6f8c934 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1945,6 +1945,7 @@ static void __net_exit __ip_vs_dev_cleanup(struct net *net)
 {
 	EnterFunction(2);
 	net_ipvs(net)->enable = 0;	/* Disable packet reception */
+	smp_wmb();
 	__ip_vs_sync_cleanup(net);
 	LeaveFunction(2);
 }
-- 
1.6.0.2

