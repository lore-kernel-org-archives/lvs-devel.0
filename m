From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] IPVS: precedence bug in ip_vs_sync_switch_mode()
Date: Mon,  7 Feb 2011 18:19:41 +0900
Message-ID: <1297070381-24377-2-git-send-email-horms@verge.net.au>
References: <1297070381-24377-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1297070381-24377-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>, Dan Carpenter <error27@gmail.com>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>

From: Dan Carpenter <error27@gmail.com>

'!' has higher precedence than '&'.  IP_VS_STATE_MASTER is 0x1 so
the original code is equivelent to if (!ipvs->sync_state) ...

Signed-off-by: Dan Carpenter <error27@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sync.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 2a2a836..d1b7298 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -392,7 +392,7 @@ void ip_vs_sync_switch_mode(struct net *net, int mode)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	if (!ipvs->sync_state & IP_VS_STATE_MASTER)
+	if (!(ipvs->sync_state & IP_VS_STATE_MASTER))
 		return;
 	if (mode == ipvs->sysctl_sync_ver || !ipvs->sync_buff)
 		return;
-- 
1.7.2.3

