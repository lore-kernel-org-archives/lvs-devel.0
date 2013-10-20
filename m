From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net 2/3] ipv6: fill rt6i_gateway with nexthop address
Date: Sun, 20 Oct 2013 15:43:04 +0300
Message-ID: <1382272985-1528-3-git-send-email-ja@ssi.bg>
References: <1382272985-1528-1-git-send-email-ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1382272985-1528-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

Make sure rt6i_gateway contains nexthop information in
all routes returned from lookup or when routes are directly
attached to skb for generated ICMP packets.

The effect of this patch should be a faster version of
rt6_nexthop() and the consideration of local addresses as
nexthop.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip6_route.h | 6 ++----
 net/ipv6/ip6_output.c   | 4 ++--
 net/ipv6/route.c        | 8 ++++++--
 3 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 481404a..2b786b7 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -194,11 +194,9 @@ static inline int ip6_skb_dst_mtu(struct sk_buff *skb)
 	       skb_dst(skb)->dev->mtu : dst_mtu(skb_dst(skb));
 }
 
-static inline struct in6_addr *rt6_nexthop(struct rt6_info *rt, struct in6_addr *dest)
+static inline struct in6_addr *rt6_nexthop(struct rt6_info *rt)
 {
-	if (rt->rt6i_flags & RTF_GATEWAY || !ipv6_addr_any(&rt->rt6i_gateway))
-		return &rt->rt6i_gateway;
-	return dest;
+	return &rt->rt6i_gateway;
 }
 
 #endif
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index a54c45c..2b404df 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -105,7 +105,7 @@ static int ip6_finish_output2(struct sk_buff *skb)
 	}
 
 	rcu_read_lock_bh();
-	nexthop = rt6_nexthop((struct rt6_info *)dst, &ipv6_hdr(skb)->daddr);
+	nexthop = rt6_nexthop((struct rt6_info *)dst);
 	neigh = __ipv6_neigh_lookup_noref(dst->dev, nexthop);
 	if (unlikely(!neigh))
 		neigh = __neigh_create(&nd_tbl, nexthop, dst->dev, false);
@@ -874,7 +874,7 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 	 */
 	rt = (struct rt6_info *) *dst;
 	rcu_read_lock_bh();
-	n = __ipv6_neigh_lookup_noref(rt->dst.dev, rt6_nexthop(rt, &fl6->daddr));
+	n = __ipv6_neigh_lookup_noref(rt->dst.dev, rt6_nexthop(rt));
 	err = n && !(n->nud_state & NUD_VALID) ? -EINVAL : 0;
 	rcu_read_unlock_bh();
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c979dd9..c1ee381 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -851,7 +851,6 @@ static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort,
 			if (ort->rt6i_dst.plen != 128 &&
 			    ipv6_addr_equal(&ort->rt6i_dst.addr, daddr))
 				rt->rt6i_flags |= RTF_ANYCAST;
-			rt->rt6i_gateway = *daddr;
 		}
 
 		rt->rt6i_flags |= RTF_CACHE;
@@ -1338,6 +1337,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	rt->dst.flags |= DST_HOST;
 	rt->dst.output  = ip6_output;
 	atomic_set(&rt->dst.__refcnt, 1);
+	rt->rt6i_gateway  = fl6->daddr;
 	rt->rt6i_dst.addr = fl6->daddr;
 	rt->rt6i_dst.plen = 128;
 	rt->rt6i_idev     = idev;
@@ -1873,7 +1873,10 @@ static struct rt6_info *ip6_rt_copy(struct rt6_info *ort,
 			in6_dev_hold(rt->rt6i_idev);
 		rt->dst.lastuse = jiffies;
 
-		rt->rt6i_gateway = ort->rt6i_gateway;
+		if (ort->rt6i_flags & RTF_GATEWAY)
+			rt->rt6i_gateway = ort->rt6i_gateway;
+		else
+			rt->rt6i_gateway = *dest;
 		rt->rt6i_flags = ort->rt6i_flags;
 		if ((ort->rt6i_flags & (RTF_DEFAULT | RTF_ADDRCONF)) ==
 		    (RTF_DEFAULT | RTF_ADDRCONF))
@@ -2160,6 +2163,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 	else
 		rt->rt6i_flags |= RTF_LOCAL;
 
+	rt->rt6i_gateway  = *addr;
 	rt->rt6i_dst.addr = *addr;
 	rt->rt6i_dst.plen = 128;
 	rt->rt6i_table = fib6_get_table(net, RT6_TABLE_LOCAL);
-- 
1.8.3.1
