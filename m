From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 11/16] ipv4: Cache net in ip_build_and_send_pkt and ip_queue_xmit
Date: Wed,  7 Oct 2015 16:48:42 -0500
Message-ID: <1444254527-17833-11-git-send-email-ebiederm@xmission.com>
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

Compute net and store it in a variable in the functions
ip_build_and_send_pkt and ip_queue_xmit so that it does not need to be
recomputed next time it is needed.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/ip_output.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 10366ee03bec..a7012f2fa68a 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -139,6 +139,7 @@ int ip_build_and_send_pkt(struct sk_buff *skb, const struct sock *sk,
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct rtable *rt = skb_rtable(skb);
+	struct net *net = sock_net(sk);
 	struct iphdr *iph;
 
 	/* Build the IP header. */
@@ -157,7 +158,7 @@ int ip_build_and_send_pkt(struct sk_buff *skb, const struct sock *sk,
 		iph->id = 0;
 	} else {
 		iph->frag_off = 0;
-		__ip_select_ident(sock_net(sk), iph, 1);
+		__ip_select_ident(net, iph, 1);
 	}
 
 	if (opt && opt->opt.optlen) {
@@ -382,6 +383,7 @@ static void ip_copy_addrs(struct iphdr *iph, const struct flowi4 *fl4)
 int ip_queue_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl)
 {
 	struct inet_sock *inet = inet_sk(sk);
+	struct net *net = sock_net(sk);
 	struct ip_options_rcu *inet_opt;
 	struct flowi4 *fl4;
 	struct rtable *rt;
@@ -412,7 +414,7 @@ int ip_queue_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl)
 		 * keep trying until route appears or the connection times
 		 * itself out.
 		 */
-		rt = ip_route_output_ports(sock_net(sk), fl4, sk,
+		rt = ip_route_output_ports(net, fl4, sk,
 					   daddr, inet->inet_saddr,
 					   inet->inet_dport,
 					   inet->inet_sport,
@@ -449,7 +451,7 @@ packet_routed:
 		ip_options_build(skb, &inet_opt->opt, inet->inet_daddr, rt, 0);
 	}
 
-	ip_select_ident_segs(sock_net(sk), skb, sk,
+	ip_select_ident_segs(net, skb, sk,
 			     skb_shinfo(skb)->gso_segs ?: 1);
 
 	/* TODO : should we use skb->sk here instead of sk ? */
@@ -462,7 +464,7 @@ packet_routed:
 
 no_route:
 	rcu_read_unlock();
-	IP_INC_STATS(sock_net(sk), IPSTATS_MIB_OUTNOROUTES);
+	IP_INC_STATS(net, IPSTATS_MIB_OUTNOROUTES);
 	kfree_skb(skb);
 	return -EHOSTUNREACH;
 }
-- 
2.2.1

