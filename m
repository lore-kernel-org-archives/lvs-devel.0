From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 10/16] ipv4: Cache net in iptunnel_xmit
Date: Wed,  7 Oct 2015 16:48:41 -0500
Message-ID: <1444254527-17833-10-git-send-email-ebiederm@xmission.com>
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

Store net in a variable in ip_tunnel_xmit so it does not need
to be recomputed when it is used again.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/ip_tunnel_core.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 8d85ecd1ced5..caef8e2c281d 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -53,6 +53,7 @@ int iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 		  __u8 tos, __u8 ttl, __be16 df, bool xnet)
 {
 	int pkt_len = skb->len - skb_inner_network_offset(skb);
+	struct net *net = dev_net(rt->dst.dev);
 	struct iphdr *iph;
 	int err;
 
@@ -76,8 +77,7 @@ int iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 	iph->daddr	=	dst;
 	iph->saddr	=	src;
 	iph->ttl	=	ttl;
-	__ip_select_ident(dev_net(rt->dst.dev), iph,
-			  skb_shinfo(skb)->gso_segs ?: 1);
+	__ip_select_ident(net, iph, skb_shinfo(skb)->gso_segs ?: 1);
 
 	err = ip_local_out(sk, skb);
 	if (unlikely(net_xmit_eval(err)))
-- 
2.2.1
