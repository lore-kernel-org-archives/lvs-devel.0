From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net] ipvs: do not use random local source address for tunnels
Date: Sat, 27 Jun 2015 14:39:30 +0300
Message-ID: <1435405170-21023-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org, Michael Vallaly <lvs@nolatency.com>

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
---
 net/netfilter/ipvs/ip_vs_xmit.c | 1 -
 1 file changed, 1 deletion(-)

 Should work on any stable kernel, tested on
v3.10.81, v3.12.44, v3.14.45, v3.16.7, v3.18.16, v4.0.6

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 19986ec..5fb7fd9 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -130,7 +130,6 @@ static struct rtable *do_output_route4(struct net *net, __be32 daddr,
 
 	memset(&fl4, 0, sizeof(fl4));
 	fl4.daddr = daddr;
-	fl4.saddr = (rt_mode & IP_VS_RT_MODE_CONNECT) ? *saddr : 0;
 	fl4.flowi4_flags = (rt_mode & IP_VS_RT_MODE_KNOWN_NH) ?
 			   FLOWI_FLAG_KNOWN_NH : 0;
 
-- 
1.9.3

