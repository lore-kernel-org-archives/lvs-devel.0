From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 6/6] ipvs: remove shadow rt variable
Date: Tue, 16 Nov 2010 15:34:58 +0900
Message-ID: <1289889298-17287-7-git-send-email-horms@verge.net.au>
References: <1289889298-17287-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1289889298-17287-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, n
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Simon Horman <horms@verge.net.au>

From: Eric Dumazet <eric.dumazet@gmail.com>

Remove a sparse warning about rt variable.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 10bd39c..50b131c 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -188,7 +188,6 @@ __ip_vs_reroute_locally(struct sk_buff *skb)
 			},
 			.mark = skb->mark,
 		};
-		struct rtable *rt;
 
 		if (ip_route_output_key(net, &rt, &fl))
 			return 0;
-- 
1.7.2.3

