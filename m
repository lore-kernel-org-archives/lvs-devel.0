From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 04/16] net: Pass net into dst_output and remove dst_output_okfn
Date: Wed,  7 Oct 2015 16:48:35 -0500
Message-ID: <1444254527-17833-4-git-send-email-ebiederm@xmission.com>
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

Replace dst_output_okfn with dst_output

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/dst.h               | 6 +-----
 net/decnet/dn_nsp_out.c         | 4 ++--
 net/ipv4/ip_forward.c           | 2 +-
 net/ipv4/ip_output.c            | 7 ++++---
 net/ipv4/ip_vti.c               | 2 +-
 net/ipv4/ipmr.c                 | 2 +-
 net/ipv4/raw.c                  | 2 +-
 net/ipv4/xfrm4_output.c         | 2 +-
 net/ipv6/ip6_output.c           | 4 ++--
 net/ipv6/ip6_vti.c              | 2 +-
 net/ipv6/ip6mr.c                | 2 +-
 net/ipv6/mcast.c                | 4 ++--
 net/ipv6/ndisc.c                | 2 +-
 net/ipv6/output_core.c          | 5 +++--
 net/ipv6/raw.c                  | 2 +-
 net/ipv6/xfrm6_output.c         | 2 +-
 net/netfilter/ipvs/ip_vs_xmit.c | 4 ++--
 net/xfrm/xfrm_output.c          | 2 +-
 net/xfrm/xfrm_policy.c          | 2 +-
 19 files changed, 28 insertions(+), 30 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 779206c15f8b..fdd01fed1a7b 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -454,14 +454,10 @@ static inline void dst_set_expires(struct dst_entry *dst, int timeout)
 }
 
 /* Output packet to network from transport.  */
-static inline int dst_output(struct sock *sk, struct sk_buff *skb)
+static inline int dst_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	return skb_dst(skb)->output(sk, skb);
 }
-static inline int dst_output_okfn(struct net *net, struct sock *sk, struct sk_buff *skb)
-{
-	return dst_output(sk, skb);
-}
 
 /* Input packet from network to transport.  */
 static inline int dst_input(struct sk_buff *skb)
diff --git a/net/decnet/dn_nsp_out.c b/net/decnet/dn_nsp_out.c
index 4b02dd300f50..849805e7af52 100644
--- a/net/decnet/dn_nsp_out.c
+++ b/net/decnet/dn_nsp_out.c
@@ -85,7 +85,7 @@ static void dn_nsp_send(struct sk_buff *skb)
 	if (dst) {
 try_again:
 		skb_dst_set(skb, dst);
-		dst_output(skb->sk, skb);
+		dst_output(&init_net, skb->sk, skb);
 		return;
 	}
 
@@ -582,7 +582,7 @@ static __inline__ void dn_nsp_do_disc(struct sock *sk, unsigned char msgflg,
 	 * associations.
 	 */
 	skb_dst_set(skb, dst_clone(dst));
-	dst_output(skb->sk, skb);
+	dst_output(&init_net, skb->sk, skb);
 }
 
 
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index d66cfb35ba74..da0d7ce85844 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -72,7 +72,7 @@ static int ip_forward_finish(struct net *net, struct sock *sk, struct sk_buff *s
 		ip_forward_options(skb);
 
 	skb_sender_cpu_clear(skb);
-	return dst_output(sk, skb);
+	return dst_output(net, sk, skb);
 }
 
 int ip_forward(struct sk_buff *skb)
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 1030f48d66e1..c94efb22f380 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -105,7 +105,7 @@ static int __ip_local_out_sk(struct sock *sk, struct sk_buff *skb)
 	ip_send_check(iph);
 	return nf_hook(NFPROTO_IPV4, NF_INET_LOCAL_OUT,
 		       net, sk, skb, NULL, skb_dst(skb)->dev,
-		       dst_output_okfn);
+		       dst_output);
 }
 
 int __ip_local_out(struct sk_buff *skb)
@@ -115,11 +115,12 @@ int __ip_local_out(struct sk_buff *skb)
 
 int ip_local_out_sk(struct sock *sk, struct sk_buff *skb)
 {
+	struct net *net = dev_net(skb_dst(skb)->dev);
 	int err;
 
 	err = __ip_local_out_sk(sk, skb);
 	if (likely(err == 1))
-		err = dst_output(sk, skb);
+		err = dst_output(net, sk, skb);
 
 	return err;
 }
@@ -276,7 +277,7 @@ static int ip_finish_output(struct net *net, struct sock *sk, struct sk_buff *sk
 	/* Policy lookup after SNAT yielded a new policy */
 	if (skb_dst(skb)->xfrm) {
 		IPCB(skb)->flags |= IPSKB_REROUTED;
-		return dst_output(sk, skb);
+		return dst_output(net, sk, skb);
 	}
 #endif
 	mtu = ip_skb_dst_mtu(skb);
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 3b87ec5178f9..4d8f0b698777 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -197,7 +197,7 @@ static netdev_tx_t vti_xmit(struct sk_buff *skb, struct net_device *dev,
 	skb_dst_set(skb, dst);
 	skb->dev = skb_dst(skb)->dev;
 
-	err = dst_output(skb->sk, skb);
+	err = dst_output(tunnel->net, skb->sk, skb);
 	if (net_xmit_eval(err) == 0)
 		err = skb->len;
 	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index cfcb996ec51b..fc42525d8694 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1689,7 +1689,7 @@ static inline int ipmr_forward_finish(struct net *net, struct sock *sk,
 	if (unlikely(opt->optlen))
 		ip_forward_options(skb);
 
-	return dst_output(sk, skb);
+	return dst_output(net, sk, skb);
 }
 
 /*
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 09a07e8b2f35..8c0d0bdc2a7c 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -413,7 +413,7 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 
 	err = NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_OUT,
 		      net, sk, skb, NULL, rt->dst.dev,
-		      dst_output_okfn);
+		      dst_output);
 	if (err > 0)
 		err = net_xmit_errno(err);
 	if (err)
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index cd6be736e19f..17db61f4b439 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -87,7 +87,7 @@ static int __xfrm4_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 #ifdef CONFIG_NETFILTER
 	if (!x) {
 		IPCB(skb)->flags |= IPSKB_REROUTED;
-		return dst_output(sk, skb);
+		return dst_output(net, sk, skb);
 	}
 #endif
 
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index caf7d14a1bdd..0171e762e03c 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -233,7 +233,7 @@ int ip6_xmit(const struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 		 */
 		return NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT,
 			       net, (struct sock *)sk, skb, NULL, dst->dev,
-			       dst_output_okfn);
+			       dst_output);
 	}
 
 	skb->dev = dst->dev;
@@ -333,7 +333,7 @@ static inline int ip6_forward_finish(struct net *net, struct sock *sk,
 				     struct sk_buff *skb)
 {
 	skb_sender_cpu_clear(skb);
-	return dst_output(sk, skb);
+	return dst_output(net, sk, skb);
 }
 
 static unsigned int ip6_dst_mtu_forward(const struct dst_entry *dst)
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index f96f1c19b4a8..0a8610b33d79 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -482,7 +482,7 @@ vti6_xmit(struct sk_buff *skb, struct net_device *dev, struct flowi *fl)
 		return -EMSGSIZE;
 	}
 
-	err = dst_output(skb->sk, skb);
+	err = dst_output(t->net, skb->sk, skb);
 	if (net_xmit_eval(err) == 0) {
 		struct pcpu_sw_netstats *tstats = this_cpu_ptr(dev->tstats);
 
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 5e5d16e7ce85..ad19136086dd 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1991,7 +1991,7 @@ static inline int ip6mr_forward2_finish(struct net *net, struct sock *sk, struct
 			 IPSTATS_MIB_OUTFORWDATAGRAMS);
 	IP6_ADD_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
 			 IPSTATS_MIB_OUTOCTETS, skb->len);
-	return dst_output(sk, skb);
+	return dst_output(net, sk, skb);
 }
 
 /*
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index a8bf57ca74d3..124338a39e29 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1646,7 +1646,7 @@ static void mld_sendpack(struct sk_buff *skb)
 
 	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT,
 		      net, net->ipv6.igmp_sk, skb, NULL, skb->dev,
-		      dst_output_okfn);
+		      dst_output);
 out:
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(net, idev, ICMPV6_MLD2_REPORT);
@@ -2010,7 +2010,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 	skb_dst_set(skb, dst);
 	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT,
 		      net, sk, skb, NULL, skb->dev,
-		      dst_output_okfn);
+		      dst_output);
 out:
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(net, idev, type);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 7089c305245c..b18012f9f9fc 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -465,7 +465,7 @@ static void ndisc_send_skb(struct sk_buff *skb,
 
 	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT,
 		      net, sk, skb, NULL, dst->dev,
-		      dst_output_okfn);
+		      dst_output);
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(net, idev, type);
 		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index e77102c4f804..4337147ee23d 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -151,7 +151,7 @@ static int __ip6_local_out_sk(struct sock *sk, struct sk_buff *skb)
 
 	return nf_hook(NFPROTO_IPV6, NF_INET_LOCAL_OUT,
 		       net, sk, skb, NULL, skb_dst(skb)->dev,
-		       dst_output_okfn);
+		       dst_output);
 }
 
 int __ip6_local_out(struct sk_buff *skb)
@@ -162,11 +162,12 @@ EXPORT_SYMBOL_GPL(__ip6_local_out);
 
 int ip6_local_out_sk(struct sock *sk, struct sk_buff *skb)
 {
+	struct net *net = dev_net(skb_dst(skb)->dev);
 	int err;
 
 	err = __ip6_local_out_sk(sk, skb);
 	if (likely(err == 1))
-		err = dst_output(sk, skb);
+		err = dst_output(net, sk, skb);
 
 	return err;
 }
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index fec0151522a2..dc65ec198f7c 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -655,7 +655,7 @@ static int rawv6_send_hdrinc(struct sock *sk, struct msghdr *msg, int length,
 
 	IP6_UPD_PO_STATS(net, rt->rt6i_idev, IPSTATS_MIB_OUT, skb->len);
 	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, net, sk, skb,
-		      NULL, rt->dst.dev, dst_output_okfn);
+		      NULL, rt->dst.dev, dst_output);
 	if (err > 0)
 		err = net_xmit_errno(err);
 	if (err)
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 4cefda009f53..c9a5bd5fea9c 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -147,7 +147,7 @@ static int __xfrm6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 #ifdef CONFIG_NETFILTER
 	if (!x) {
 		IP6CB(skb)->flags |= IP6SKB_REROUTED;
-		return dst_output(sk, skb);
+		return dst_output(net, sk, skb);
 	}
 #endif
 
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 77182b9750cd..504d1fcf5454 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -576,7 +576,7 @@ static inline int ip_vs_nat_send_or_cont(int pf, struct sk_buff *skb,
 		if (!skb->sk)
 			skb_sender_cpu_clear(skb);
 		NF_HOOK(pf, NF_INET_LOCAL_OUT, cp->ipvs->net, NULL, skb,
-			NULL, skb_dst(skb)->dev, dst_output_okfn);
+			NULL, skb_dst(skb)->dev, dst_output);
 	} else
 		ret = NF_ACCEPT;
 
@@ -598,7 +598,7 @@ static inline int ip_vs_send_or_cont(int pf, struct sk_buff *skb,
 		if (!skb->sk)
 			skb_sender_cpu_clear(skb);
 		NF_HOOK(pf, NF_INET_LOCAL_OUT, cp->ipvs->net, NULL, skb,
-			NULL, skb_dst(skb)->dev, dst_output_okfn);
+			NULL, skb_dst(skb)->dev, dst_output);
 	} else
 		ret = NF_ACCEPT;
 	return ret;
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index c48a4b8582bb..88752b0c07d8 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -141,7 +141,7 @@ int xfrm_output_resume(struct sk_buff *skb, int err)
 			goto out;
 
 		if (!skb_dst(skb)->xfrm)
-			return dst_output(skb->sk, skb);
+			return dst_output(net, skb->sk, skb);
 
 		err = nf_hook(skb_dst(skb)->ops->family,
 			      NF_INET_POST_ROUTING, net, skb->sk, skb,
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index be1776bc5673..f4f2d987f8f0 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1944,7 +1944,7 @@ static void xfrm_policy_queue_process(unsigned long arg)
 		skb_dst_drop(skb);
 		skb_dst_set(skb, dst);
 
-		dst_output(skb->sk, skb);
+		dst_output(net, skb->sk, skb);
 	}
 
 out:
-- 
2.2.1
