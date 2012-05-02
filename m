From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 17/18] IPVS: ip_vs_proto.c: local functions should not be exposed globally
Date: Wed,  2 May 2012 15:22:41 +0900
Message-ID: <1335939762-1912-18-git-send-email-horms@verge.net.au>
References: <1335939762-1912-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1335939762-1912-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>, H Hartley Sweeten <hartleys@visionengravers.com>, H Hartley Sweeten <hsweeten@visionengravers.com>, "David S. Miller" <davem@davemloft.net>, Simon Horman <horms@verge.net.au>

From: H Hartley Sweeten <hartleys@visionengravers.com>

Functions not referenced outside of a source file should be marked
static to prevent it from being exposed globally.

This quiets the sparse warnings:

warning: symbol '__ipvs_proto_data_get' was not declared. Should it be static?

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_proto.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 8726488..e3f4bb0 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -153,7 +153,7 @@ EXPORT_SYMBOL(ip_vs_proto_get);
 /*
  *	get ip_vs_protocol object data by netns and proto
  */
-struct ip_vs_proto_data *
+static struct ip_vs_proto_data *
 __ipvs_proto_data_get(struct netns_ipvs *ipvs, unsigned short proto)
 {
 	struct ip_vs_proto_data *pd;
-- 
1.7.10
