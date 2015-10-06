From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] ipvs: Remove possibly unused variables from ip_vs_conn_net_{init,cleanup}
Date: Tue,  6 Oct 2015 17:14:30 +0900
Message-ID: <1444119270-5499-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "Eric W. Biederman" <ebiederm@xmission.com>, Simon Horman <horms@verge.net.au>

If CONFIG_PROC_FS is undefined then the arguments of proc_create()
and remove_proc_entry() are unused. As a result the net variables of
ip_vs_conn_net_{init,cleanup} are unused.

Resolve this by dereferencing net as needed rather than storing it
in a variable.

Fixes: 3d99376689ee ("ipvs: Pass ipvs not net into ip_vs_control_net_(init|cleanup)")
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index d1d168c7fc68..85ca189bdc3d 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1347,23 +1347,20 @@ flush_again:
  */
 int __net_init ip_vs_conn_net_init(struct netns_ipvs *ipvs)
 {
-	struct net *net = ipvs->net;
-
 	atomic_set(&ipvs->conn_count, 0);
 
-	proc_create("ip_vs_conn", 0, net->proc_net, &ip_vs_conn_fops);
-	proc_create("ip_vs_conn_sync", 0, net->proc_net, &ip_vs_conn_sync_fops);
+	proc_create("ip_vs_conn", 0, ipvs->net->proc_net, &ip_vs_conn_fops);
+	proc_create("ip_vs_conn_sync", 0, ipvs->net->proc_net,
+		    &ip_vs_conn_sync_fops);
 	return 0;
 }
 
 void __net_exit ip_vs_conn_net_cleanup(struct netns_ipvs *ipvs)
 {
-	struct net *net = ipvs->net;
