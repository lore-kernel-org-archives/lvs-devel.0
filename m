From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 11/18] IPVS: Add expire_quiescent_template()
Date: Sun,  6 Mar 2011 08:45:53 +0900
Message-ID: <1299368760-14271-12-git-send-email-horms@verge.net.au>
References: <1299368760-14271-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1299368760-14271-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>, Simon Horman <horms@verge.net.au>

In preparation for not including sysctl_expire_quiescent_template in
struct netns_ipvs when CONFIG_SYCTL is not defined.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 9c2a517..f289306 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -680,6 +680,16 @@ static inline void ip_vs_unbind_dest(struct ip_vs_conn *cp)
 	atomic_dec(&dest->refcnt);
 }
 
+static int expire_quiescent_template(struct netns_ipvs *ipvs,
+				     struct ip_vs_dest *dest)
+{
+#ifdef CONFIG_SYSCTL
+	return ipvs->sysctl_expire_quiescent_template &&
+		(atomic_read(&dest->weight) == 0);
+#else
+	return 0;
+#endif
+}
 
 /*
  *	Checking if the destination of a connection template is available.
@@ -696,8 +706,7 @@ int ip_vs_check_template(struct ip_vs_conn *ct)
 	 */
 	if ((dest == NULL) ||
 	    !(dest->flags & IP_VS_DEST_F_AVAILABLE) ||
-	    (ipvs->sysctl_expire_quiescent_template &&
-	     (atomic_read(&dest->weight) == 0))) {
+	    expire_quiescent_template(ipvs, dest)) {
 		IP_VS_DBG_BUF(9, "check_template: dest not available for "
 			      "protocol %s s:%s:%d v:%s:%d "
 			      "-> d:%s:%d\n",
-- 
1.7.2.3

