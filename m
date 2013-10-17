From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC net-next] ipv6: Use destination address determined by
 IPVS
Date: Fri, 18 Oct 2013 02:03:27 +0300 (EEST)
Message-ID: <alpine.LFD.2.03.1310180153250.4554@ssi.bg>
References: <1381881751-6719-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1381881751-6719-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: =?UTF-8?Q?YOSHIFUJI_Hideaki_=2F_=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?= <yoshfuji@linux-ipv6.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Mark Brooks <mark@loadbalancer.org>, Phil Oester <kernel@linuxace.com>


	Hello,

	Here is a solution that should work not only for IPVS.
If the change looks correct I'll send it in a separate message.

[PATCH net] ipv6: always prefer rt6i_gateway if present

From: Julian Anastasov <ja@ssi.bg>

In v3.9 6fd6ce2056de2709 ("ipv6: Do not depend on rt->n in
ip6_finish_output2()." changed the behaviour of ip6_finish_output2()
such that the recently introduced rt6_nexthop() is used
instead of an assigned neighbor.

As rt6_nexthop() prefers rt6i_gateway only for gatewayed
routes this causes a problem for users like IPVS, xt_TEE and
RAW(hdrincl) if they want to use different address for routing
compared to the destination address.

Fix it by considering the rt6i_gateway address in all
cases, so that traffic routed to address on local subnet is
not wrongly diverted to the destination address.

Thanks to Simon Horman and Phil Oester for spotting the
problematic commit.

Reported-by: Phil Oester <kernel@linuxace.com>
Reported-by: Mark Brooks <mark@loadbalancer.org>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

Please review for possible side effects when using
rt6i_gateway without RTF_GATEWAY!

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

Regards

--
Julian Anastasov <ja@ssi.bg>
