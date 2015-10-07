From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 14/16] ipv4,ipv6: Pass net into __ip_local_out and __ip6_local_out
Date: Wed,  7 Oct 2015 16:48:45 -0500
Message-ID: <1444254527-17833-14-git-send-email-ebiederm@xmission.com>
References: <87bnca4aie.fsf_-_@x220.int.ebiederm.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87bnca4aie.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/vrf.c      | 2 +-
 include/net/dst_ops.h  | 3 ++-
 include/net/ip.h       | 2 +-
 include/net/ipv6.h     | 2 +-
 net/ipv4/ip_output.c   | 5 ++---
 net/ipv6/output_core.c | 5 ++---
 net/xfrm/xfrm_output.c | 2 +-
 7 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 231f9d85d4eb..b27dc11cd3f2 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -74,7 +74,7 @@ static struct dst_entry *vrf_ip_check(struct dst_entry *dst, u32 cookie)
 	return dst;
 }
 
-static int vrf_ip_local_out(struct sock *sk, struct sk_buff *skb)
+static int vrf_ip_local_out(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	return ip_local_out(sk, skb);
 }
diff --git a/include/net/dst_ops.h b/include/net/dst_ops.h
index 3f26a6af444e..a0d443ca16fc 100644
--- a/include/net/dst_ops.h
+++ b/include/net/dst_ops.h
@@ -9,6 +9,7 @@ struct kmem_cachep;
 struct net_device;
 struct sk_buff;
 struct sock;
+struct net;
 
 struct dst_ops {
 	unsigned short		family;
@@ -28,7 +29,7 @@ struct dst_ops {
 					       struct sk_buff *skb, u32 mtu);
 	void			(*redirect)(struct dst_entry *dst, struct sock *sk,
 					    struct sk_buff *skb);
-	int			(*local_out)(struct sock *sk, struct sk_buff *skb);
+	int			(*local_out)(struct net *net, struct sock *sk, struct sk_buff *skb);
 	struct neighbour *	(*neigh_lookup)(const struct dst_entry *dst,
 						struct sk_buff *skb,
 						const void *daddr);
diff --git a/include/net/ip.h b/include/net/ip.h
index 03e80f936847..34b40381fb9b 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -112,7 +112,7 @@ int ip_mc_output(struct sock *sk, struct sk_buff *skb);
 int ip_do_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 		   int (*output)(struct net *, struct sock *, struct sk_buff *));
 void ip_send_check(struct iphdr *ip);
-int __ip_local_out(struct sock *sk, struct sk_buff *skb);
+int __ip_local_out(struct net *net, struct sock *sk, struct sk_buff *skb);
 int ip_local_out(struct sock *sk, struct sk_buff *skb);
 
 int ip_queue_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl);
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 30eb1821c184..42834039cf20 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -865,7 +865,7 @@ int ip6_forward(struct sk_buff *skb);
 int ip6_input(struct sk_buff *skb);
 int ip6_mc_input(struct sk_buff *skb);
 
-int __ip6_local_out(struct sock *sk, struct sk_buff *skb);
+int __ip6_local_out(struct net *net, struct sock *sk, struct sk_buff *skb);
 int ip6_local_out(struct sock *sk, struct sk_buff *skb);
 
 /*
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index a7012f2fa68a..39d3fbe66c68 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -96,9 +96,8 @@ void ip_send_check(struct iphdr *iph)
 }
 EXPORT_SYMBOL(ip_send_check);
 
-int __ip_local_out(struct sock *sk, struct sk_buff *skb)
+int __ip_local_out(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
-	struct net *net = dev_net(skb_dst(skb)->dev);
 	struct iphdr *iph = ip_hdr(skb);
 
 	iph->tot_len = htons(skb->len);
@@ -113,7 +112,7 @@ int ip_local_out(struct sock *sk, struct sk_buff *skb)
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	int err;
 
-	err = __ip_local_out(sk, skb);
+	err = __ip_local_out(net, sk, skb);
 	if (likely(err == 1))
 		err = dst_output(net, sk, skb);
 
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index 12855811c6a0..7f64d67b637d 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -138,9 +138,8 @@ int ip6_dst_hoplimit(struct dst_entry *dst)
 EXPORT_SYMBOL(ip6_dst_hoplimit);
 #endif
 
-int __ip6_local_out(struct sock *sk, struct sk_buff *skb)
+int __ip6_local_out(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
-	struct net *net = dev_net(skb_dst(skb)->dev);
 	int len;
 
 	len = skb->len - sizeof(struct ipv6hdr);
@@ -160,7 +159,7 @@ int ip6_local_out(struct sock *sk, struct sk_buff *skb)
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	int err;
 
-	err = __ip6_local_out(sk, skb);
+	err = __ip6_local_out(net, sk, skb);
 	if (likely(err == 1))
 		err = dst_output(net, sk, skb);
 
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index a7a254fe7985..cc3676eb6239 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -136,7 +136,7 @@ int xfrm_output_resume(struct sk_buff *skb, int err)
 	while (likely((err = xfrm_output_one(skb, err)) == 0)) {
 		nf_reset(skb);
 
-		err = skb_dst(skb)->ops->local_out(skb->sk, skb);
+		err = skb_dst(skb)->ops->local_out(net, skb->sk, skb);
 		if (unlikely(err != 1))
 			goto out;
 
-- 
2.2.1

