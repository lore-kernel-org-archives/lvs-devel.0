From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 3/5] ipvs: fixed sparse warning
Date: Fri, 10 Aug 2012 10:41:32 +0900
Message-ID: <1344562895-22790-4-git-send-email-horms@verge.net.au>
References: <1344562895-22790-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1344562895-22790-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Claudiu Ghioc <claudiughioc@gmail.com>, Claudiu Ghioc <claudiu.ghioc@gmail.com>, Simon Horman <horms@verge.net.au>

From: Claudiu Ghioc <claudiughioc@gmail.com>

Removed the following sparse warnings, wether CONFIG_SYSCTL
is defined or not:
*       warning: symbol 'ip_vs_control_net_init_sysctl' was not
	declared. Should it be static?
*       warning: symbol 'ip_vs_control_net_cleanup_sysctl' was
	not declared. Should it be static?

Signed-off-by: Claudiu Ghioc <claudiu.ghioc@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 84444dd..d6d5cca 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3675,7 +3675,7 @@ static void ip_vs_genl_unregister(void)
  * per netns intit/exit func.
  */
 #ifdef CONFIG_SYSCTL
-int __net_init ip_vs_control_net_init_sysctl(struct net *net)
+static int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 {
 	int idx;
 	struct netns_ipvs *ipvs = net_ipvs(net);
@@ -3743,7 +3743,7 @@ int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 	return 0;
 }
 
-void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net)
+static void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
@@ -3754,8 +3754,8 @@ void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net)
 
 #else
 
-int __net_init ip_vs_control_net_init_sysctl(struct net *net) { return 0; }
-void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net) { }
+static int __net_init ip_vs_control_net_init_sysctl(struct net *net) { return 0; }
+static void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net) { }
 
 #endif
 
-- 
1.7.10.2.484.gcd07cc5

