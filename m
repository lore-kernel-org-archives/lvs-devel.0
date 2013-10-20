From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net 1/3] ipv6: always prefer rt6i_gateway if present
Date: Sun, 20 Oct 2013 15:43:03 +0300
Message-ID: <1382272985-1528-2-git-send-email-ja@ssi.bg>
References: <1382272985-1528-1-git-send-email-ja@ssi.bg>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1382272985-1528-1-git-send-email-ja@ssi.bg>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

In v3.9 6fd6ce2056de2709 ("ipv6: Do not depend on rt->n in
ip6_finish_output2()." changed the behaviour of ip6_finish_output2()
such that the recently introduced rt6_nexthop() is used
instead of an assigned neighbor.

As rt6_nexthop() prefers rt6i_gateway only for gatewayed
routes this causes a problem for users like IPVS, xt_TEE and
RAW(hdrincl) if they want to use different address for routing
compared to the destination address.

Another case is when redirect can create RTF_DYNAMIC
route without RTF_GATEWAY flag, we ignore the rt6i_gateway
in rt6_nexthop().

Fix the above problems by considering the rt6i_gateway if
present, so that traffic routed to address on local subnet is
not wrongly diverted to the destination address.

Thanks to Simon Horman and Phil Oester for spotting the
problematic commit.

Thanks to Hannes Frederic Sowa for his review and help in testing.

Reported-by: Phil Oester <kernel@linuxace.com>
Reported-by: Mark Brooks <mark@loadbalancer.org>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip6_route.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index f525e70..481404a 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -196,7 +196,7 @@ static inline int ip6_skb_dst_mtu(struct sk_buff *skb)
 
 static inline struct in6_addr *rt6_nexthop(struct rt6_info *rt, struct in6_addr *dest)
 {
-	if (rt->rt6i_flags & RTF_GATEWAY)
+	if (rt->rt6i_flags & RTF_GATEWAY || !ipv6_addr_any(&rt->rt6i_gateway))
 		return &rt->rt6i_gateway;
 	return dest;
 }
-- 
1.8.3.1

