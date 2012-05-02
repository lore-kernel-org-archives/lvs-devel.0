From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 04/18] ipvs: WRR scheduler does not need GFP_ATOMIC allocation
Date: Wed,  2 May 2012 15:22:28 +0900
Message-ID: <1335939762-1912-5-git-send-email-horms@verge.net.au>
References: <1335939762-1912-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1335939762-1912-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Hans Schillstrom <hans@schillstrom.com>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

	Schedulers are initialized and bound to services only
on commands.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_wrr.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wrr.c
index fd0d4e0..231be7d 100644
--- a/net/netfilter/ipvs/ip_vs_wrr.c
+++ b/net/netfilter/ipvs/ip_vs_wrr.c
@@ -84,7 +84,7 @@ static int ip_vs_wrr_init_svc(struct ip_vs_service *svc)
 	/*
 	 *    Allocate the mark variable for WRR scheduling
 	 */
-	mark = kmalloc(sizeof(struct ip_vs_wrr_mark), GFP_ATOMIC);
+	mark = kmalloc(sizeof(struct ip_vs_wrr_mark), GFP_KERNEL);
 	if (mark == NULL)
 		return -ENOMEM;
 
-- 
1.7.10

