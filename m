From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 07/17] netfilter: ipvs: use GFP_KERNEL allocation where possible
Date: Wed,  2 May 2012 10:24:51 +0900
Message-ID: <1335921901-21284-8-git-send-email-horms@verge.net.au>
References: <1335921901-21284-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1335921901-21284-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Sasha Levin <levinsasha928@gmail.com>, Simon Horman <horms@verge.net.au>

From: Sasha Levin <levinsasha928@gmail.com>

Use GFP_KERNEL instead of GFP_ATOMIC when registering an ipvs protocol.

This is safe since it will always run from a process context.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_proto.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index a981b7c..8726488 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -71,7 +71,7 @@ register_ip_vs_proto_netns(struct net *net, struct ip_vs_protocol *pp)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	unsigned int hash = IP_VS_PROTO_HASH(pp->protocol);
 	struct ip_vs_proto_data *pd =
-			kzalloc(sizeof(struct ip_vs_proto_data), GFP_ATOMIC);
+			kzalloc(sizeof(struct ip_vs_proto_data), GFP_KERNEL);
 
 	if (!pd)
 		return -ENOMEM;
-- 
1.7.9.5

