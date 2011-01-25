From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 2/2] netfilter: ipvs: fix compiler warnings
Date: Tue, 25 Jan 2011 23:17:06 +1000
Message-ID: <1295961426-7402-3-git-send-email-horms@verge.net.au>
References: <1295961426-7402-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1295961426-7402-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Changli Gao <xiaosuo@gmail.com>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>

From: Changli Gao <xiaosuo@gmail.com>

Fix compiler warnings when IP_VS_DBG() isn't defined.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index f36a84f..d889f4f 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1894,9 +1894,7 @@ static int __net_init __ip_vs_init(struct net *net)
 
 static void __net_exit __ip_vs_cleanup(struct net *net)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
