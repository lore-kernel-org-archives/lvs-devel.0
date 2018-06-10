From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net] ipv6: allow PMTU exceptions to local routes
Date: Mon, 11 Jun 2018 02:02:54 +0300
Message-ID: <20180610230254.6347-1-ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org, Martin KaFai Lau <kafai@fb.com>, kernel-team@fb.com, lvs-devel@vger.kernel.org

IPVS setups with local client and remote tunnel server need
to create exception for the local virtual IP. What we do is to
change PMTU from 64KB (on "lo") to 1460 in the common case.

Suggested-by: Martin KaFai Lau <kafai@fb.com>
Fixes: 45e4fd26683c ("ipv6: Only create RTF_CACHE routes after encountering pmtu exception")
Fixes: 7343ff31ebf0 ("ipv6: Don't create clones of host routes.")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/ipv6/route.c | 3 ---
 1 file changed, 3 deletions(-)

Note: I failed to build 2.6.38 kernel for the test but I think
commit 7343ff31ebf0 looks as the one that added the restriction
to change PMTU for local IPs.

So, I'm not sure from how long time the issue with local IPVS
clients and tunnelling method exists. May be it worked between
2.6.28 and 2.6.37.

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index fb95698..86a0e43 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2307,9 +2307,6 @@ static void __ip6_rt_update_pmtu(struct dst_entry *dst, const struct sock *sk,
 	const struct in6_addr *daddr, *saddr;
 	struct rt6_info *rt6 = (struct rt6_info *)dst;
 
-	if (rt6->rt6i_flags & RTF_LOCAL)
-		return;
-
 	if (dst_metric_locked(dst, RTAX_MTU))
 		return;
 
-- 
2.9.5

