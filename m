From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 15/16] ipv4,ipv6: Pass net into ip_local_out and ip6_local_out
Date: Wed,  7 Oct 2015 16:48:46 -0500
Message-ID: <1444254527-17833-15-git-send-email-ebiederm@xmission.com>
References: <87bnca4aie.fsf_-_@x220.int.ebiederm.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <87bnca4aie.fsf_-_@x220.int.ebiederm.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ipvlan/ipvlan_core.c    | 4 ++--
 drivers/net/ppp/pptp.c              | 2 +-
 drivers/net/vrf.c                   | 4 ++--
 include/net/ip.h                    | 2 +-
 include/net/ip6_tunnel.h            | 2 +-
 include/net/ipv6.h                  | 2 +-
 net/ipv4/igmp.c                     | 4 ++--
 net/ipv4/ip_output.c                | 9 ++++-----
 net/ipv4/ip_tunnel_core.c           | 2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c   | 2 +-
 net/ipv4/netfilter/nf_dup_ipv4.c    | 2 +-
 net/ipv4/netfilter/nf_reject_ipv4.c | 2 +-
 net/ipv6/ip6_output.c               | 2 +-
 net/ipv6/netfilter/ip6t_SYNPROXY.c  | 2 +-
 net/ipv6/netfilter/nf_dup_ipv6.c    | 2 +-
 net/ipv6/netfilter/nf_reject_ipv6.c | 2 +-
 net/ipv6/output_core.c              | 3 +--
 net/netfilter/ipvs/ip_vs_xmit.c     | 4 ++--
 18 files changed, 25 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 976f30b291f6..24f8dbcf854f 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -365,7 +365,7 @@ static int ipvlan_process_v4_outbound(struct sk_buff *skb)
 	}
 	skb_dst_drop(skb);
 	skb_dst_set(skb, &rt->dst);
-	err = ip_local_out(skb->sk, skb);
+	err = ip_local_out(net, skb->sk, skb);
 	if (unlikely(net_xmit_eval(err)))
 		dev->stats.tx_errors++;
 	else
@@ -403,7 +403,7 @@ static int ipvlan_process_v6_outbound(struct sk_buff *skb)
 	}
 	skb_dst_drop(skb);
 	skb_dst_set(skb, dst);
-	err = ip6_local_out(skb->sk, skb);
+	err = ip6_local_out(net, skb->sk, skb);
 	if (unlikely(net_xmit_eval(err)))
 		dev->stats.tx_errors++;
 	else
diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index 5243ab6ed4d4..fc69e41d0950 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -283,7 +283,7 @@ static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	ip_select_ident(net, skb, NULL);
 	ip_send_check(iph);
 
-	ip_local_out(skb->sk, skb);
+	ip_local_out(net, skb->sk, skb);
 	return 1;
 
 tx_error:
diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index b27dc11cd3f2..21bb7deb6d58 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -76,7 +76,7 @@ static struct dst_entry *vrf_ip_check(struct dst_entry *dst, u32 cookie)
 
 static int vrf_ip_local_out(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
-	return ip_local_out(sk, skb);
+	return ip_local_out(net, sk, skb);
 }
 
 static unsigned int vrf_v4_mtu(const struct dst_entry *dst)
@@ -222,7 +222,7 @@ static netdev_tx_t vrf_process_v4_outbound(struct sk_buff *skb,
 					       RT_SCOPE_LINK);
 	}
 
-	ret = ip_local_out(skb->sk, skb);
+	ret = ip_local_out(dev_net(skb_dst(skb)->dev), skb->sk, skb);
 	if (unlikely(net_xmit_eval(ret)))
 		vrf_dev->stats.tx_errors++;
 	else
diff --git a/include/net/ip.h b/include/net/ip.h
index 34b40381fb9b..7febbab784cd 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -113,7 +113,7 @@ int ip_do_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 		   int (*output)(struct net *, struct sock *, struct sk_buff *));
 void ip_send_check(struct iphdr *ip);
 int __ip_local_out(struct net *net, struct sock *sk, struct sk_buff *skb);
-int ip_local_out(struct sock *sk, struct sk_buff *skb);
+int ip_local_out(struct net *net, struct sock *sk, struct sk_buff *skb);
 
 int ip_queue_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl);
 void ip_init(void);
diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index 8f18a8b126e9..aaee6fa02cf1 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -87,7 +87,7 @@ static inline void ip6tunnel_xmit(struct sock *sk, struct sk_buff *skb,
 	int pkt_len, err;
 
 	pkt_len = skb->len - skb_inner_network_offset(skb);
-	err = ip6_local_out(sk, skb);
+	err = ip6_local_out(dev_net(skb_dst(skb)->dev), sk, skb);
 
 	if (net_xmit_eval(err) == 0) {
 		struct pcpu_sw_netstats *tstats = this_cpu_ptr(dev->tstats);
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 42834039cf20..fce8120c2be3 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -866,7 +866,7 @@ int ip6_input(struct sk_buff *skb);
 int ip6_mc_input(struct sk_buff *skb);
 
 int __ip6_local_out(struct net *net, struct sock *sk, struct sk_buff *skb);
-int ip6_local_out(struct sock *sk, struct sk_buff *skb);
+int ip6_local_out(struct net *net, struct sock *sk, struct sk_buff *skb);
 
 /*
  *	Extension header (options) processing
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 43375d9e02ab..64aaf3522a59 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -397,7 +397,7 @@ static int igmpv3_sendpack(struct sk_buff *skb)
 
 	pig->csum = ip_compute_csum(igmp_hdr(skb), igmplen);
 
-	return ip_local_out(skb->sk, skb);
+	return ip_local_out(dev_net(skb_dst(skb)->dev), skb->sk, skb);
 }
 
 static int grec_size(struct ip_mc_list *pmc, int type, int gdel, int sdel)
@@ -739,7 +739,7 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 	ih->group = group;
 	ih->csum = ip_compute_csum((void *)ih, sizeof(struct igmphdr));
 
-	return ip_local_out(skb->sk, skb);
+	return ip_local_out(net, skb->sk, skb);
 }
 
 static void igmp_gq_timer_expire(unsigned long data)
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 39d3fbe66c68..9fe100a41e5d 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -107,9 +107,8 @@ int __ip_local_out(struct net *net, struct sock *sk, struct sk_buff *skb)
 		       dst_output);
 }
 
-int ip_local_out(struct sock *sk, struct sk_buff *skb)
+int ip_local_out(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
-	struct net *net = dev_net(skb_dst(skb)->dev);
 	int err;
 
 	err = __ip_local_out(net, sk, skb);
@@ -169,7 +168,7 @@ int ip_build_and_send_pkt(struct sk_buff *skb, const struct sock *sk,
 	skb->mark = sk->sk_mark;
 
 	/* Send it out. */
-	return ip_local_out(skb->sk, skb);
+	return ip_local_out(net, skb->sk, skb);
 }
 EXPORT_SYMBOL_GPL(ip_build_and_send_pkt);
 
@@ -457,7 +456,7 @@ packet_routed:
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
 
-	res = ip_local_out(sk, skb);
+	res = ip_local_out(net, sk, skb);
 	rcu_read_unlock();
 	return res;
 
@@ -1437,7 +1436,7 @@ int ip_send_skb(struct net *net, struct sk_buff *skb)
 {
 	int err;
 
-	err = ip_local_out(skb->sk, skb);
+	err = ip_local_out(net, skb->sk, skb);
 	if (err) {
 		if (err > 0)
 			err = net_xmit_errno(err);
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index caef8e2c281d..6cb9009c3d96 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -79,7 +79,7 @@ int iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 	iph->ttl	=	ttl;
 	__ip_select_ident(net, iph, skb_shinfo(skb)->gso_segs ?: 1);
 
-	err = ip_local_out(sk, skb);
+	err = ip_local_out(net, sk, skb);
 	if (unlikely(net_xmit_eval(err)))
 		pkt_len = 0;
 	return pkt_len;
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index 473faf73b194..f1a8df8ecc1f 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -63,7 +63,7 @@ synproxy_send_tcp(const struct synproxy_net *snet,
 		nf_conntrack_get(nfct);
 	}
 
-	ip_local_out(nskb->sk, nskb);
+	ip_local_out(net, nskb->sk, nskb);
 	return;
 
 free_nskb:
diff --git a/net/ipv4/netfilter/nf_dup_ipv4.c b/net/ipv4/netfilter/nf_dup_ipv4.c
index 0b9abfbf6577..ceb187308120 100644
--- a/net/ipv4/netfilter/nf_dup_ipv4.c
+++ b/net/ipv4/netfilter/nf_dup_ipv4.c
@@ -92,7 +92,7 @@ void nf_dup_ipv4(struct net *net, struct sk_buff *skb, unsigned int hooknum,
 
 	if (nf_dup_ipv4_route(net, skb, gw, oif)) {
 		__this_cpu_write(nf_skb_duplicated, true);
-		ip_local_out(skb->sk, skb);
+		ip_local_out(net, skb->sk, skb);
 		__this_cpu_write(nf_skb_duplicated, false);
 	} else {
 		kfree_skb(skb);
diff --git a/net/ipv4/netfilter/nf_reject_ipv4.c b/net/ipv4/netfilter/nf_reject_ipv4.c
index dcc125cb0441..c747b2d9eb77 100644
--- a/net/ipv4/netfilter/nf_reject_ipv4.c
+++ b/net/ipv4/netfilter/nf_reject_ipv4.c
@@ -157,7 +157,7 @@ void nf_send_reset(struct net *net, struct sk_buff *oldskb, int hook)
 		dev_queue_xmit(nskb);
 	} else
 #endif
-		ip_local_out(nskb->sk, nskb);
+		ip_local_out(net, nskb->sk, nskb);
 
 	return;
 
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 31c686b7fcc0..98510fac94e9 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1692,7 +1692,7 @@ int ip6_send_skb(struct sk_buff *skb)
 	struct rt6_info *rt = (struct rt6_info *)skb_dst(skb);
 	int err;
 
-	err = ip6_local_out(skb->sk, skb);
+	err = ip6_local_out(net, skb->sk, skb);
 	if (err) {
 		if (err > 0)
 			err = net_xmit_errno(err);
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index c38c3411150b..a10a2a9e9f94 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -76,7 +76,7 @@ synproxy_send_tcp(const struct synproxy_net *snet,
 		nf_conntrack_get(nfct);
 	}
 
-	ip6_local_out(nskb->sk, nskb);
+	ip6_local_out(net, nskb->sk, nskb);
 	return;
 
 free_nskb:
diff --git a/net/ipv6/netfilter/nf_dup_ipv6.c b/net/ipv6/netfilter/nf_dup_ipv6.c
index 64f3fe5e2719..6989c70ae29f 100644
--- a/net/ipv6/netfilter/nf_dup_ipv6.c
+++ b/net/ipv6/netfilter/nf_dup_ipv6.c
@@ -68,7 +68,7 @@ void nf_dup_ipv6(struct net *net, struct sk_buff *skb, unsigned int hooknum,
 	}
 	if (nf_dup_ipv6_route(net, skb, gw, oif)) {
 		__this_cpu_write(nf_skb_duplicated, true);
-		ip6_local_out(skb->sk, skb);
+		ip6_local_out(net, skb->sk, skb);
 		__this_cpu_write(nf_skb_duplicated, false);
 	} else {
 		kfree_skb(skb);
diff --git a/net/ipv6/netfilter/nf_reject_ipv6.c b/net/ipv6/netfilter/nf_reject_ipv6.c
index a4f73e235ca5..7309e475f68b 100644
--- a/net/ipv6/netfilter/nf_reject_ipv6.c
+++ b/net/ipv6/netfilter/nf_reject_ipv6.c
@@ -206,7 +206,7 @@ void nf_send_reset6(struct net *net, struct sk_buff *oldskb, int hook)
 		dev_queue_xmit(nskb);
 	} else
 #endif
-		ip6_local_out(nskb->sk, nskb);
+		ip6_local_out(net, nskb->sk, nskb);
 }
 EXPORT_SYMBOL_GPL(nf_send_reset6);
 
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index 7f64d67b637d..462f2a76b5c2 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -154,9 +154,8 @@ int __ip6_local_out(struct net *net, struct sock *sk, struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(__ip6_local_out);
 
-int ip6_local_out(struct sock *sk, struct sk_buff *skb)
+int ip6_local_out(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
-	struct net *net = dev_net(skb_dst(skb)->dev);
 	int err;
 
 	err = __ip6_local_out(net, sk, skb);
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 2042b9303136..3264cb49b333 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -1049,7 +1049,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	ret = ip_vs_tunnel_xmit_prepare(skb, cp);
 	if (ret == NF_ACCEPT)
-		ip_local_out(skb->sk, skb);
+		ip_local_out(net, skb->sk, skb);
 	else if (ret == NF_DROP)
 		kfree_skb(skb);
 	rcu_read_unlock();
@@ -1141,7 +1141,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	ret = ip_vs_tunnel_xmit_prepare(skb, cp);
 	if (ret == NF_ACCEPT)
-		ip6_local_out(skb->sk, skb);
+		ip6_local_out(cp->ipvs->net, skb->sk, skb);
 	else if (ret == NF_DROP)
 		kfree_skb(skb);
 	rcu_read_unlock();
-- 
2.2.1

