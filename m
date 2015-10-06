From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 04/15] dst: Pass a sk into .local_out
Date: Tue,  6 Oct 2015 13:53:04 -0500
Message-ID: <1444157595-28816-4-git-send-email-ebiederm@xmission.com>
References: <878u7fesrg.fsf_-_@x220.int.ebiederm.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <878u7fesrg.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

For consistency with the other similar methods in the kernel pass a
struct sock into the dst_ops .local_out method.

Simplifying the socket passing case is needed a prequel to passing a struct net
reference into .local_out.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/vrf.c       | 4 ++--
 include/net/dst_ops.h   | 2 +-
 include/net/ip.h        | 1 +
 include/net/ipv6.h      | 1 +
 net/ipv4/ip_output.c    | 2 +-
 net/ipv4/route.c        | 2 +-
 net/ipv4/xfrm4_policy.c | 2 +-
 net/ipv6/output_core.c  | 2 +-
 net/ipv6/route.c        | 2 +-
 net/ipv6/xfrm6_policy.c | 2 +-
 net/xfrm/xfrm_output.c  | 2 +-
 11 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 474396353e7f..2a02cee0bf95 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -73,9 +73,9 @@ static struct dst_entry *vrf_ip_check(struct dst_entry *dst, u32 cookie)
 	return dst;
 }
 
-static int vrf_ip_local_out(struct sk_buff *skb)
+static int vrf_ip_local_out(struct sock *sk, struct sk_buff *skb)
 {
-	return ip_local_out(skb);
+	return ip_local_out_sk(sk, skb);
 }
 
 static unsigned int vrf_v4_mtu(const struct dst_entry *dst)
diff --git a/include/net/dst_ops.h b/include/net/dst_ops.h
index d64253914a6a..3f26a6af444e 100644
--- a/include/net/dst_ops.h
+++ b/include/net/dst_ops.h
@@ -28,7 +28,7 @@ struct dst_ops {
 					       struct sk_buff *skb, u32 mtu);
 	void			(*redirect)(struct dst_entry *dst, struct sock *sk,
 					    struct sk_buff *skb);
-	int			(*local_out)(struct sk_buff *skb);
+	int			(*local_out)(struct sock *sk, struct sk_buff *skb);
 	struct neighbour *	(*neigh_lookup)(const struct dst_entry *dst,
 						struct sk_buff *skb,
 						const void *daddr);
diff --git a/include/net/ip.h b/include/net/ip.h
index dd06ab3669f9..ea1f721f7224 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -112,6 +112,7 @@ int ip_mc_output(struct sock *sk, struct sk_buff *skb);
 int ip_do_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 		   int (*output)(struct net *, struct sock *, struct sk_buff *));
 void ip_send_check(struct iphdr *ip);
+int __ip_local_out_sk(struct sock *sk, struct sk_buff *skb);
 int __ip_local_out(struct sk_buff *skb);
 int ip_local_out_sk(struct sock *sk, struct sk_buff *skb);
 static inline int ip_local_out(struct sk_buff *skb)
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 3dde042bcd3f..56920262dbe9 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -865,6 +865,7 @@ int ip6_forward(struct sk_buff *skb);
 int ip6_input(struct sk_buff *skb);
 int ip6_mc_input(struct sk_buff *skb);
 
+int __ip6_local_out_sk(struct sock *sk, struct sk_buff *skb);
 int __ip6_local_out(struct sk_buff *skb);
 int ip6_local_out_sk(struct sock *sk, struct sk_buff *skb);
 int ip6_local_out(struct sk_buff *skb);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index d80e646bb175..25c93af125e4 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -96,7 +96,7 @@ void ip_send_check(struct iphdr *iph)
 }
 EXPORT_SYMBOL(ip_send_check);
 
-static int __ip_local_out_sk(struct sock *sk, struct sk_buff *skb)
+int __ip_local_out_sk(struct sock *sk, struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	struct iphdr *iph = ip_hdr(skb);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 54297d3a0559..d1208806e2c6 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -165,7 +165,7 @@ static struct dst_ops ipv4_dst_ops = {
 	.link_failure =		ipv4_link_failure,
 	.update_pmtu =		ip_rt_update_pmtu,
 	.redirect =		ip_do_redirect,
-	.local_out =		__ip_local_out,
+	.local_out =		__ip_local_out_sk,
 	.neigh_lookup =		ipv4_neigh_lookup,
 };
 
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index f2606b9056bb..d46d99f9cabd 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -243,7 +243,7 @@ static struct dst_ops xfrm4_dst_ops = {
 	.cow_metrics =		dst_cow_metrics_generic,
 	.destroy =		xfrm4_dst_destroy,
 	.ifdown =		xfrm4_dst_ifdown,
-	.local_out =		__ip_local_out,
+	.local_out =		__ip_local_out_sk,
 	.gc_thresh =		32768,
 };
 
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index 4337147ee23d..e5affb5fe095 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -138,7 +138,7 @@ int ip6_dst_hoplimit(struct dst_entry *dst)
 EXPORT_SYMBOL(ip6_dst_hoplimit);
 #endif
 
-static int __ip6_local_out_sk(struct sock *sk, struct sk_buff *skb)
+int __ip6_local_out_sk(struct sock *sk, struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	int len;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d3d946773a3e..b62a507cc1a5 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -226,7 +226,7 @@ static struct dst_ops ip6_dst_ops_template = {
 	.link_failure		=	ip6_link_failure,
 	.update_pmtu		=	ip6_rt_update_pmtu,
 	.redirect		=	rt6_do_redirect,
-	.local_out		=	__ip6_local_out,
+	.local_out		=	__ip6_local_out_sk,
 	.neigh_lookup		=	ip6_neigh_lookup,
 };
 
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 69cee4e0d728..861a1679f33f 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -284,7 +284,7 @@ static struct dst_ops xfrm6_dst_ops = {
 	.cow_metrics =		dst_cow_metrics_generic,
 	.destroy =		xfrm6_dst_destroy,
 	.ifdown =		xfrm6_dst_ifdown,
-	.local_out =		__ip6_local_out,
+	.local_out =		__ip6_local_out_sk,
 	.gc_thresh =		32768,
 };
 
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 88752b0c07d8..a7a254fe7985 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -136,7 +136,7 @@ int xfrm_output_resume(struct sk_buff *skb, int err)
 	while (likely((err = xfrm_output_one(skb, err)) == 0)) {
 		nf_reset(skb);
 
-		err = skb_dst(skb)->ops->local_out(skb);
+		err = skb_dst(skb)->ops->local_out(skb->sk, skb);
 		if (unlikely(err != 1))
 			goto out;
 
-- 
2.2.1
