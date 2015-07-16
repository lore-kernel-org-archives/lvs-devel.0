From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf 2/6] ipvs: do not use random local source address for tunnels
Date: Thu, 16 Jul 2015 11:14:09 +0900
Message-ID: <1437012853-7318-3-git-send-email-horms@verge.net.au>
References: <1437012853-7318-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1437012853-7318-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

Michael Vallaly reports about wrong source address used
in rare cases for tunneled traffic. Looks like
__ip_vs_get_out_rt in 3.10+ is providing uninitialized
dest_dst->dst_saddr.ip because ip_vs_dest_dst_alloc uses
kmalloc. While we retry after seeing EINVAL from routing
for data that does not look like valid local address, it
still succeeded when this memory was previously used from
other dests and with different local addresses. As result,
we can use valid local address that is not suitable for
our real server.

Fix it by providing 0.0.0.0 every time our cache is refreshed.
By this way we will get preferred source address from routing.

Reported-by: Michael Vallaly <lvs@nolatency.com>
Fixes: 026ace060dfe ("ipvs: optimize dst usage for real server")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index b99d80695b1f..ec30d68ccc0b 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -130,7 +130,6 @@ static struct rtable *do_output_route4(struct net *net, __be32 daddr,
 
 	memset(&fl4, 0, sizeof(fl4));
 	fl4.daddr = daddr;
-	fl4.saddr = (rt_mode & IP_VS_RT_MODE_CONNECT) ? *saddr : 0;
 	fl4.flowi4_flags = (rt_mode & IP_VS_RT_MODE_KNOWN_NH) ?
 			   FLOWI_FLAG_KNOWN_NH : 0;
 
-- 
2.1.4
