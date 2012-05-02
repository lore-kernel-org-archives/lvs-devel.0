From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 01/17] ipvs: timeout tables do not need GFP_ATOMIC allocation
Date: Wed,  2 May 2012 10:24:45 +0900
Message-ID: <1335921901-21284-2-git-send-email-horms@verge.net.au>
References: <1335921901-21284-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1335921901-21284-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Hans Schillstrom <hans@schillstrom.com>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

	They are called only on initialization.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_proto.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 6eda11d..a981b7c 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -196,7 +196,7 @@ void ip_vs_protocol_timeout_change(struct netns_ipvs *ipvs, int flags)
 int *
 ip_vs_create_timeout_table(int *table, int size)
 {
-	return kmemdup(table, size, GFP_ATOMIC);
+	return kmemdup(table, size, GFP_KERNEL);
 }
 
 
-- 
1.7.9.5

