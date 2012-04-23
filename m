From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 2/2] ipvs: fix crash in ip_vs_control_net_cleanup on unload
Date: Mon, 23 Apr 2012 22:12:12 +0900
Message-ID: <1335186732-16002-3-git-send-email-horms@verge.net.au>
References: <1335186732-16002-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1335186732-16002-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Sasha Levin <levinsasha928@gmail.com>, stable@vger.kernel.org, Hans Schillstrom <hans@schillstrom.com>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

	commit 14e405461e664b777e2a5636e10b2ebf36a686ec (2.6.39)
("Add __ip_vs_control_{init,cleanup}_sysctl()")
introduced regression due to wrong __net_init for
__ip_vs_control_cleanup_sysctl. This leads to crash when
the ip_vs module is unloaded.

	Fix it by changing __net_init to __net_exit for
the function that is already renamed to ip_vs_control_net_cleanup_sysctl.

Cc: stable@vger.kernel.org
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index b3afe18..376d2b1 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3680,7 +3680,7 @@ int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 	return 0;
 }
 
-void __net_init ip_vs_control_net_cleanup_sysctl(struct net *net)
+void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
@@ -3692,7 +3692,7 @@ void __net_init ip_vs_control_net_cleanup_sysctl(struct net *net)
 #else
 
 int __net_init ip_vs_control_net_init_sysctl(struct net *net) { return 0; }
-void __net_init ip_vs_control_net_cleanup_sysctl(struct net *net) { }
+void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net) { }
 
 #endif
 
-- 
1.7.9.5
