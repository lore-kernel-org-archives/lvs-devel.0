From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 05/15] ipv4: Merge __ip_local_out and __ip_local_out_sk
Date: Tue,  6 Oct 2015 13:53:05 -0500
Message-ID: <1444157595-28816-5-git-send-email-ebiederm@xmission.com>
References: <878u7fesrg.fsf_-_@x220.int.ebiederm.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <878u7fesrg.fsf_-_@x220.int.ebiederm.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/ip.h        | 3 +--
 net/ipv4/ip_output.c    | 9 ++-------
 net/ipv4/route.c        | 2 +-
 net/ipv4/xfrm4_policy.c | 2 +-
 4 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index ea1f721f7224..46272e04f3b6 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -112,8 +112,7 @@ int ip_mc_output(struct sock *sk, struct sk_buff *skb);
 int ip_do_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 		   int (*output)(struct net *, struct sock *, struct sk_buff *));
 void ip_send_check(struct iphdr *ip);
-int __ip_local_out_sk(struct sock *sk, struct sk_buff *skb);
-int __ip_local_out(struct sk_buff *skb);
+int __ip_local_out(struct sock *sk, struct sk_buff *skb);
 int ip_local_out_sk(struct sock *sk, struct sk_buff *skb);
 static inline int ip_local_out(struct sk_buff *skb)
 {
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 25c93af125e4..59cec0af3b2e 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -96,7 +96,7 @@ void ip_send_check(struct iphdr *iph)
 }
 EXPORT_SYMBOL(ip_send_check);
 
-int __ip_local_out_sk(struct sock *sk, struct sk_buff *skb)
+int __ip_local_out(struct sock *sk, struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	struct iphdr *iph = ip_hdr(skb);
@@ -108,17 +108,12 @@ int __ip_local_out_sk(struct sock *sk, struct sk_buff *skb)
 		       dst_output);
 }
 
-int __ip_local_out(struct sk_buff *skb)
-{
-	return __ip_local_out_sk(skb->sk, skb);
-}
-
 int ip_local_out_sk(struct sock *sk, struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	int err;
 
-	err = __ip_local_out_sk(sk, skb);
+	err = __ip_local_out(sk, skb);
 	if (likely(err == 1))
 		err = dst_output(net, sk, skb);
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d1208806e2c6..54297d3a0559 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -165,7 +165,7 @@ static struct dst_ops ipv4_dst_ops = {
 	.link_failure =		ipv4_link_failure,
 	.update_pmtu =		ip_rt_update_pmtu,
 	.redirect =		ip_do_redirect,
-	.local_out =		__ip_local_out_sk,
+	.local_out =		__ip_local_out,
 	.neigh_lookup =		ipv4_neigh_lookup,
 };
 
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index d46d99f9cabd..f2606b9056bb 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -243,7 +243,7 @@ static struct dst_ops xfrm4_dst_ops = {
 	.cow_metrics =		dst_cow_metrics_generic,
 	.destroy =		xfrm4_dst_destroy,
 	.ifdown =		xfrm4_dst_ifdown,
-	.local_out =		__ip_local_out_sk,
+	.local_out =		__ip_local_out,
 	.gc_thresh =		32768,
 };
 
-- 
2.2.1

