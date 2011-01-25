From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 1/2] IPVS netns BUG, register sysctl for root ns
Date: Tue, 25 Jan 2011 23:17:05 +1000
Message-ID: <1295961426-7402-2-git-send-email-horms@verge.net.au>
References: <1295961426-7402-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1295961426-7402-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Changli Gao <xiaosuo@gmail.com>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Simon Horman <horms@verge.net.au>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

The newly created table was not used when register sysctl for a new namespace.
I.e. sysctl doesn't work for other than root namespace (init_net)

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 68b8033..98df59a 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3556,7 +3556,7 @@ int __net_init __ip_vs_control_init(struct net *net)
 
 
 	ipvs->sysctl_hdr = register_net_sysctl_table(net, net_vs_ctl_path,
-						  vs_vars);
+						     tbl);
 	if (ipvs->sysctl_hdr == NULL)
 		goto err_reg;
 	ip_vs_new_estimator(net, ipvs->tot_stats);
-- 
1.7.2.3

