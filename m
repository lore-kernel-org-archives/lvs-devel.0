From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 08/16] ipv6: Merge __ip6_local_out and __ip6_local_out_sk
Date: Wed,  7 Oct 2015 16:48:39 -0500
Message-ID: <1444254527-17833-8-git-send-email-ebiederm@xmission.com>
References: <87bnca4aie.fsf_-_@x220.int.ebiederm.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <87bnca4aie.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

Only __ip6_local_out_sk has callers so rename __ip6_local_out_sk
__ip6_local_out and remove the previous __ip6_local_out.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/ipv6.h      | 3 +--
 net/ipv6/output_core.c  | 9 ++-------
 net/ipv6/route.c        | 2 +-
 net/ipv6/xfrm6_policy.c | 2 +-
 4 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 56920262dbe9..be7e7689514b 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -865,8 +865,7 @@ int ip6_forward(struct sk_buff *skb);
 int ip6_input(struct sk_buff *skb);
 int ip6_mc_input(struct sk_buff *skb);
 
-int __ip6_local_out_sk(struct sock *sk, struct sk_buff *skb);
-int __ip6_local_out(struct sk_buff *skb);
+int __ip6_local_out(struct sock *sk, struct sk_buff *skb);
 int ip6_local_out_sk(struct sock *sk, struct sk_buff *skb);
 int ip6_local_out(struct sk_buff *skb);
 
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index e5affb5fe095..f93ae1515387 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -138,7 +138,7 @@ int ip6_dst_hoplimit(struct dst_entry *dst)
 EXPORT_SYMBOL(ip6_dst_hoplimit);
 #endif
 
-int __ip6_local_out_sk(struct sock *sk, struct sk_buff *skb)
+int __ip6_local_out(struct sock *sk, struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	int len;
@@ -153,11 +153,6 @@ int __ip6_local_out_sk(struct sock *sk, struct sk_buff *skb)
 		       net, sk, skb, NULL, skb_dst(skb)->dev,
 		       dst_output);
 }
-
-int __ip6_local_out(struct sk_buff *skb)
-{
-	return __ip6_local_out_sk(skb->sk, skb);
-}
 EXPORT_SYMBOL_GPL(__ip6_local_out);
 
 int ip6_local_out_sk(struct sock *sk, struct sk_buff *skb)
@@ -165,7 +160,7 @@ int ip6_local_out_sk(struct sock *sk, struct sk_buff *skb)
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	int err;
 
-	err = __ip6_local_out_sk(sk, skb);
+	err = __ip6_local_out(sk, skb);
 	if (likely(err == 1))
 		err = dst_output(net, sk, skb);
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index b62a507cc1a5..d3d946773a3e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -226,7 +226,7 @@ static struct dst_ops ip6_dst_ops_template = {
 	.link_failure		=	ip6_link_failure,
 	.update_pmtu		=	ip6_rt_update_pmtu,
 	.redirect		=	rt6_do_redirect,
-	.local_out		=	__ip6_local_out_sk,
+	.local_out		=	__ip6_local_out,
 	.neigh_lookup		=	ip6_neigh_lookup,
 };
 
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index f7876830f263..08c9c93f3527 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -285,7 +285,7 @@ static struct dst_ops xfrm6_dst_ops = {
 	.cow_metrics =		dst_cow_metrics_generic,
 	.destroy =		xfrm6_dst_destroy,
 	.ifdown =		xfrm6_dst_ifdown,
-	.local_out =		__ip6_local_out_sk,
+	.local_out =		__ip6_local_out,
 	.gc_thresh =		32768,
 };
 
-- 
2.2.1
