From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 06/15] ipv4: Merge ip_local_out and ip_local_out_sk
Date: Tue,  6 Oct 2015 13:53:06 -0500
Message-ID: <1444157595-28816-6-git-send-email-ebiederm@xmission.com>
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

It is confusing and silly hiding a paramater so modify all of
the callers to pass in the appropriate socket or skb->sk if
no socket is known.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ipvlan/ipvlan_core.c    |  2 +-
 drivers/net/ppp/pptp.c              |  2 +-
 drivers/net/vrf.c                   |  4 ++--
 include/net/ip.h                    |  6 +-----
 net/ipv4/igmp.c                     |  4 ++--
 net/ipv4/ip_output.c                | 10 +++++-----
 net/ipv4/ip_tunnel_core.c           |  2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c   |  2 +-
 net/ipv4/netfilter/nf_dup_ipv4.c    |  2 +-
 net/ipv4/netfilter/nf_reject_ipv4.c |  2 +-
 net/netfilter/ipvs/ip_vs_xmit.c     |  2 +-
 11 files changed, 17 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 207f62e8de9a..c75ad39c752f 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -364,7 +364,7 @@ static int ipvlan_process_v4_outbound(struct sk_buff *skb)
 	}
 	skb_dst_drop(skb);
 	skb_dst_set(skb, &rt->dst);
-	err = ip_local_out(skb);
+	err = ip_local_out(skb->sk, skb);
 	if (unlikely(net_xmit_eval(err)))
 		dev->stats.tx_errors++;
 	else
diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index 686f37daa262..6bef7be10671 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -282,7 +282,7 @@ static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	ip_select_ident(sock_net(sk), skb, NULL);
 	ip_send_check(iph);
 
-	ip_local_out(skb);
+	ip_local_out(skb->sk, skb);
 	return 1;
 
 tx_error:
diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 2a02cee0bf95..e3a89257e4b7 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -75,7 +75,7 @@ static struct dst_entry *vrf_ip_check(struct dst_entry *dst, u32 cookie)
 
 static int vrf_ip_local_out(struct sock *sk, struct sk_buff *skb)
 {
-	return ip_local_out_sk(sk, skb);
+	return ip_local_out(sk, skb);
 }
 
 static unsigned int vrf_v4_mtu(const struct dst_entry *dst)
@@ -221,7 +221,7 @@ static netdev_tx_t vrf_process_v4_outbound(struct sk_buff *skb,
 					       RT_SCOPE_LINK);
 	}
 
-	ret = ip_local_out(skb);
+	ret = ip_local_out(skb->sk, skb);
 	if (unlikely(net_xmit_eval(ret)))
 		vrf_dev->stats.tx_errors++;
 	else
diff --git a/include/net/ip.h b/include/net/ip.h
index 46272e04f3b6..03e80f936847 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -113,11 +113,7 @@ int ip_do_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 		   int (*output)(struct net *, struct sock *, struct sk_buff *));
 void ip_send_check(struct iphdr *ip);
 int __ip_local_out(struct sock *sk, struct sk_buff *skb);
-int ip_local_out_sk(struct sock *sk, struct sk_buff *skb);
-static inline int ip_local_out(struct sk_buff *skb)
-{
-	return ip_local_out_sk(skb->sk, skb);
-}
+int ip_local_out(struct sock *sk, struct sk_buff *skb);
 
 int ip_queue_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl);
 void ip_init(void);
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index de6d4c8ba600..43375d9e02ab 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -397,7 +397,7 @@ static int igmpv3_sendpack(struct sk_buff *skb)
 
 	pig->csum = ip_compute_csum(igmp_hdr(skb), igmplen);
 
-	return ip_local_out(skb);
+	return ip_local_out(skb->sk, skb);
 }
 
 static int grec_size(struct ip_mc_list *pmc, int type, int gdel, int sdel)
@@ -739,7 +739,7 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 	ih->group = group;
 	ih->csum = ip_compute_csum((void *)ih, sizeof(struct igmphdr));
 
-	return ip_local_out(skb);
+	return ip_local_out(skb->sk, skb);
 }
 
 static void igmp_gq_timer_expire(unsigned long data)
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 59cec0af3b2e..10366ee03bec 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -108,7 +108,7 @@ int __ip_local_out(struct sock *sk, struct sk_buff *skb)
 		       dst_output);
 }
 
-int ip_local_out_sk(struct sock *sk, struct sk_buff *skb)
+int ip_local_out(struct sock *sk, struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	int err;
@@ -119,7 +119,7 @@ int ip_local_out_sk(struct sock *sk, struct sk_buff *skb)
 
 	return err;
 }
-EXPORT_SYMBOL_GPL(ip_local_out_sk);
+EXPORT_SYMBOL_GPL(ip_local_out);
 
 static inline int ip_select_ttl(struct inet_sock *inet, struct dst_entry *dst)
 {
@@ -169,7 +169,7 @@ int ip_build_and_send_pkt(struct sk_buff *skb, const struct sock *sk,
 	skb->mark = sk->sk_mark;
 
 	/* Send it out. */
-	return ip_local_out(skb);
+	return ip_local_out(skb->sk, skb);
 }
 EXPORT_SYMBOL_GPL(ip_build_and_send_pkt);
 
@@ -456,7 +456,7 @@ packet_routed:
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
 
-	res = ip_local_out(skb);
+	res = ip_local_out(sk, skb);
 	rcu_read_unlock();
 	return res;
 
@@ -1436,7 +1436,7 @@ int ip_send_skb(struct net *net, struct sk_buff *skb)
 {
 	int err;
 
-	err = ip_local_out(skb);
+	err = ip_local_out(skb->sk, skb);
 	if (err) {
 		if (err > 0)
 			err = net_xmit_errno(err);
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 84dce6a92f93..8d85ecd1ced5 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -79,7 +79,7 @@ int iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 	__ip_select_ident(dev_net(rt->dst.dev), iph,
 			  skb_shinfo(skb)->gso_segs ?: 1);
 
-	err = ip_local_out_sk(sk, skb);
+	err = ip_local_out(sk, skb);
 	if (unlikely(net_xmit_eval(err)))
 		pkt_len = 0;
 	return pkt_len;
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index 6a6e762ab27f..473faf73b194 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -63,7 +63,7 @@ synproxy_send_tcp(const struct synproxy_net *snet,
 		nf_conntrack_get(nfct);
 	}
 
-	ip_local_out(nskb);
+	ip_local_out(nskb->sk, nskb);
 	return;
 
 free_nskb:
diff --git a/net/ipv4/netfilter/nf_dup_ipv4.c b/net/ipv4/netfilter/nf_dup_ipv4.c
index ce2a59e5c665..0b9abfbf6577 100644
--- a/net/ipv4/netfilter/nf_dup_ipv4.c
+++ b/net/ipv4/netfilter/nf_dup_ipv4.c
@@ -92,7 +92,7 @@ void nf_dup_ipv4(struct net *net, struct sk_buff *skb, unsigned int hooknum,
 
 	if (nf_dup_ipv4_route(net, skb, gw, oif)) {
 		__this_cpu_write(nf_skb_duplicated, true);
-		ip_local_out(skb);
+		ip_local_out(skb->sk, skb);
 		__this_cpu_write(nf_skb_duplicated, false);
 	} else {
 		kfree_skb(skb);
diff --git a/net/ipv4/netfilter/nf_reject_ipv4.c b/net/ipv4/netfilter/nf_reject_ipv4.c
index 2f5e925d3264..dcc125cb0441 100644
--- a/net/ipv4/netfilter/nf_reject_ipv4.c
+++ b/net/ipv4/netfilter/nf_reject_ipv4.c
@@ -157,7 +157,7 @@ void nf_send_reset(struct net *net, struct sk_buff *oldskb, int hook)
 		dev_queue_xmit(nskb);
 	} else
 #endif
-		ip_local_out(nskb);
+		ip_local_out(nskb->sk, nskb);
 
 	return;
 
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 504d1fcf5454..d77503e635d8 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -1049,7 +1049,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	ret = ip_vs_tunnel_xmit_prepare(skb, cp);
 	if (ret == NF_ACCEPT)
-		ip_local_out(skb);
+		ip_local_out(skb->sk, skb);
 	else if (ret == NF_DROP)
 		kfree_skb(skb);
 	rcu_read_unlock();
-- 
2.2.1

