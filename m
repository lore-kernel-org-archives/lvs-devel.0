From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipvs: fix crash in ip_vs_control_net_cleanup on unload
Date: Fri, 13 Apr 2012 18:08:43 +0300
Message-ID: <1334329723-12432-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

	commit 14e405461e664b777e2a5636e10b2ebf36a686ec (2.6.39)
("Add __ip_vs_control_{init,cleanup}_sysctl()")
introduced regression due to wrong __net_init for
__ip_vs_control_cleanup_sysctl. This leads to crash when
the ip_vs module is unloaded.

	Fix it by changing __net_init to __net_exit for
the function that is already renamed to ip_vs_control_net_cleanup_sysctl.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 2172fcc..79b131c 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3704,7 +3704,7 @@ int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 	return 0;
 }
 
-void __net_init ip_vs_control_net_cleanup_sysctl(struct net *net)
+void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
@@ -3716,7 +3716,7 @@ void __net_init ip_vs_control_net_cleanup_sysctl(struct net *net)
 #else
 
 int __net_init ip_vs_control_net_init_sysctl(struct net *net) { return 0; }
-void __net_init ip_vs_control_net_cleanup_sysctl(struct net *net) { }
+void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net) { }
 
 #endif
 
-- 
1.7.3.4

