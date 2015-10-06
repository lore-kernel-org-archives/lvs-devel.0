From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 08/15] ipv6: Merge ip6_local_out and ip6_local_out_sk
Date: Tue,  6 Oct 2015 13:53:08 -0500
Message-ID: <1444157595-28816-8-git-send-email-ebiederm@xmission.com>
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

Stop hidding the sk paramater with an inline helper function and
make all of the callers pass it, so that it is clear what the
function is doing.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ipvlan/ipvlan_core.c    | 2 +-
 include/net/ip6_tunnel.h            | 2 +-
 include/net/ipv6.h                  | 3 +--
 net/ipv6/ip6_output.c               | 2 +-
 net/ipv6/netfilter/ip6t_SYNPROXY.c  | 2 +-
 net/ipv6/netfilter/nf_dup_ipv6.c    | 2 +-
 net/ipv6/netfilter/nf_reject_ipv6.c | 2 +-
 net/ipv6/output_core.c              | 8 +-------
 net/netfilter/ipvs/ip_vs_xmit.c     | 2 +-
 9 files changed, 9 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index c75ad39c752f..75dcf36c0366 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -401,7 +401,7 @@ static int ipvlan_process_v6_outbound(struct sk_buff *skb)
 	}
 	skb_dst_drop(skb);
 	skb_dst_set(skb, dst);
-	err = ip6_local_out(skb);
+	err = ip6_local_out(skb->sk, skb);
 	if (unlikely(net_xmit_eval(err)))
 		dev->stats.tx_errors++;
 	else
diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index fa915fa0f703..8f18a8b126e9 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -87,7 +87,7 @@ static inline void ip6tunnel_xmit(struct sock *sk, struct sk_buff *skb,
 	int pkt_len, err;
 
 	pkt_len = skb->len - skb_inner_network_offset(skb);
-	err = ip6_local_out_sk(sk, skb);
+	err = ip6_local_out(sk, skb);
 
 	if (net_xmit_eval(err) == 0) {
 		struct pcpu_sw_netstats *tstats = this_cpu_ptr(dev->tstats);
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index be7e7689514b..30eb1821c184 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -866,8 +866,7 @@ int ip6_input(struct sk_buff *skb);
 int ip6_mc_input(struct sk_buff *skb);
 
 int __ip6_local_out(struct sock *sk, struct sk_buff *skb);
-int ip6_local_out_sk(struct sock *sk, struct sk_buff *skb);
-int ip6_local_out(struct sk_buff *skb);
+int ip6_local_out(struct sock *sk, struct sk_buff *skb);
 
 /*
  *	Extension header (options) processing
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 0171e762e03c..31c686b7fcc0 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1692,7 +1692,7 @@ int ip6_send_skb(struct sk_buff *skb)
 	struct rt6_info *rt = (struct rt6_info *)skb_dst(skb);
 	int err;
 
-	err = ip6_local_out(skb);
+	err = ip6_local_out(skb->sk, skb);
 	if (err) {
 		if (err > 0)
 			err = net_xmit_errno(err);
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index c2356602158a..c38c3411150b 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -76,7 +76,7 @@ synproxy_send_tcp(const struct synproxy_net *snet,
 		nf_conntrack_get(nfct);
 	}
 
-	ip6_local_out(nskb);
+	ip6_local_out(nskb->sk, nskb);
 	return;
 
 free_nskb:
diff --git a/net/ipv6/netfilter/nf_dup_ipv6.c b/net/ipv6/netfilter/nf_dup_ipv6.c
index ee0d9a5b16c3..64f3fe5e2719 100644
--- a/net/ipv6/netfilter/nf_dup_ipv6.c
+++ b/net/ipv6/netfilter/nf_dup_ipv6.c
@@ -68,7 +68,7 @@ void nf_dup_ipv6(struct net *net, struct sk_buff *skb, unsigned int hooknum,
 	}
 	if (nf_dup_ipv6_route(net, skb, gw, oif)) {
 		__this_cpu_write(nf_skb_duplicated, true);
-		ip6_local_out(skb);
+		ip6_local_out(skb->sk, skb);
 		__this_cpu_write(nf_skb_duplicated, false);
 	} else {
 		kfree_skb(skb);
diff --git a/net/ipv6/netfilter/nf_reject_ipv6.c b/net/ipv6/netfilter/nf_reject_ipv6.c
index 94b4c6dfb400..a4f73e235ca5 100644
--- a/net/ipv6/netfilter/nf_reject_ipv6.c
+++ b/net/ipv6/netfilter/nf_reject_ipv6.c
@@ -206,7 +206,7 @@ void nf_send_reset6(struct net *net, struct sk_buff *oldskb, int hook)
 		dev_queue_xmit(nskb);
 	} else
 #endif
-		ip6_local_out(nskb);
+		ip6_local_out(nskb->sk, nskb);
 }
 EXPORT_SYMBOL_GPL(nf_send_reset6);
 
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index f93ae1515387..12855811c6a0 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -155,7 +155,7 @@ int __ip6_local_out(struct sock *sk, struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(__ip6_local_out);
 
-int ip6_local_out_sk(struct sock *sk, struct sk_buff *skb)
+int ip6_local_out(struct sock *sk, struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	int err;
@@ -166,10 +166,4 @@ int ip6_local_out_sk(struct sock *sk, struct sk_buff *skb)
 
 	return err;
 }
-EXPORT_SYMBOL_GPL(ip6_local_out_sk);
-
-int ip6_local_out(struct sk_buff *skb)
-{
-	return ip6_local_out_sk(skb->sk, skb);
-}
 EXPORT_SYMBOL_GPL(ip6_local_out);
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index d77503e635d8..2042b9303136 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -1141,7 +1141,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	ret = ip_vs_tunnel_xmit_prepare(skb, cp);
 	if (ret == NF_ACCEPT)
-		ip6_local_out(skb);
+		ip6_local_out(skb->sk, skb);
 	else if (ret == NF_DROP)
 		kfree_skb(skb);
 	rcu_read_unlock();
-- 
2.2.1
