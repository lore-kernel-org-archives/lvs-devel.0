From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 15/15] dst: Pass net into dst->output
Date: Tue,  6 Oct 2015 13:53:15 -0500
Message-ID: <1444157595-28816-15-git-send-email-ebiederm@xmission.com>
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

The network namespace is already passed into dst_output pass it into
dst->output lwt->output and friends.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/vrf.c        |  3 +--
 include/net/dst.h        |  8 ++++----
 include/net/ip.h         |  4 ++--
 include/net/ipv6.h       |  2 +-
 include/net/lwtunnel.h   |  8 ++++----
 include/net/xfrm.h       |  6 +++---
 net/core/dst.c           | 14 +++++++-------
 net/core/lwtunnel.c      |  4 ++--
 net/decnet/dn_route.c    |  6 +++---
 net/ipv4/ip_output.c     |  6 ++----
 net/ipv4/route.c         |  4 ++--
 net/ipv4/xfrm4_output.c  |  4 +---
 net/ipv6/ila.c           |  4 ++--
 net/ipv6/ip6_output.c    |  3 +--
 net/ipv6/route.c         | 14 +++++++-------
 net/ipv6/xfrm6_output.c  |  4 +---
 net/mpls/mpls_iptunnel.c |  2 +-
 net/xfrm/xfrm_policy.c   |  2 +-
 18 files changed, 45 insertions(+), 53 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 5ff8f7cf0396..56f7d8187d8d 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -311,10 +311,9 @@ err:
 	return ret;
 }
 
-static int vrf_output(struct sock *sk, struct sk_buff *skb)
+static int vrf_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct net_device *dev = skb_dst(skb)->dev;
-	struct net *net = dev_net(dev);
 
 	IP_UPD_PO_STATS(net, IPSTATS_MIB_OUT, skb->len);
 
diff --git a/include/net/dst.h b/include/net/dst.h
index fdd01fed1a7b..1279f9b09791 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -45,7 +45,7 @@ struct dst_entry {
 	void			*__pad1;
 #endif
 	int			(*input)(struct sk_buff *);
-	int			(*output)(struct sock *sk, struct sk_buff *skb);
+	int			(*output)(struct net *net, struct sock *sk, struct sk_buff *skb);
 
 	unsigned short		flags;
 #define DST_HOST		0x0001
@@ -365,10 +365,10 @@ static inline void skb_tunnel_rx(struct sk_buff *skb, struct net_device *dev,
 	__skb_tunnel_rx(skb, dev, net);
 }
 
-int dst_discard_sk(struct sock *sk, struct sk_buff *skb);
+int dst_discard_out(struct net *net, struct sock *sk, struct sk_buff *skb);
 static inline int dst_discard(struct sk_buff *skb)
 {
-	return dst_discard_sk(skb->sk, skb);
+	return dst_discard_out(&init_net, skb->sk, skb);
 }
 void *dst_alloc(struct dst_ops *ops, struct net_device *dev, int initial_ref,
 		int initial_obsolete, unsigned short flags);
@@ -456,7 +456,7 @@ static inline void dst_set_expires(struct dst_entry *dst, int timeout)
 /* Output packet to network from transport.  */
 static inline int dst_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
-	return skb_dst(skb)->output(sk, skb);
+	return skb_dst(skb)->output(net, sk, skb);
 }
 
 /* Input packet from network to transport.  */
diff --git a/include/net/ip.h b/include/net/ip.h
index 7febbab784cd..3c904a28d5e5 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -107,8 +107,8 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	   struct net_device *orig_dev);
 int ip_local_deliver(struct sk_buff *skb);
 int ip_mr_input(struct sk_buff *skb);
-int ip_output(struct sock *sk, struct sk_buff *skb);
-int ip_mc_output(struct sock *sk, struct sk_buff *skb);
+int ip_output(struct net *net, struct sock *sk, struct sk_buff *skb);
+int ip_mc_output(struct net *net, struct sock *sk, struct sk_buff *skb);
 int ip_do_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 		   int (*output)(struct net *, struct sock *, struct sk_buff *));
 void ip_send_check(struct iphdr *ip);
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index fce8120c2be3..e1a10b0ac0b0 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -860,7 +860,7 @@ struct dst_entry *ip6_blackhole_route(struct net *net,
  *	skb processing functions
  */
 
-int ip6_output(struct sock *sk, struct sk_buff *skb);
+int ip6_output(struct net *net, struct sock *sk, struct sk_buff *skb);
 int ip6_forward(struct sk_buff *skb);
 int ip6_input(struct sk_buff *skb);
 int ip6_mc_input(struct sk_buff *skb);
diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
index fce0e35e74d0..66350ce3e955 100644
--- a/include/net/lwtunnel.h
+++ b/include/net/lwtunnel.h
@@ -18,7 +18,7 @@ struct lwtunnel_state {
 	__u16		type;
 	__u16		flags;
 	atomic_t	refcnt;
-	int		(*orig_output)(struct sock *sk, struct sk_buff *skb);
+	int		(*orig_output)(struct net *net, struct sock *sk, struct sk_buff *skb);
 	int		(*orig_input)(struct sk_buff *);
 	int             len;
 	__u8            data[0];
@@ -28,7 +28,7 @@ struct lwtunnel_encap_ops {
 	int (*build_state)(struct net_device *dev, struct nlattr *encap,
 			   unsigned int family, const void *cfg,
 			   struct lwtunnel_state **ts);
-	int (*output)(struct sock *sk, struct sk_buff *skb);
+	int (*output)(struct net *net, struct sock *sk, struct sk_buff *skb);
 	int (*input)(struct sk_buff *skb);
 	int (*fill_encap)(struct sk_buff *skb,
 			  struct lwtunnel_state *lwtstate);
@@ -88,7 +88,7 @@ int lwtunnel_fill_encap(struct sk_buff *skb,
 int lwtunnel_get_encap_size(struct lwtunnel_state *lwtstate);
 struct lwtunnel_state *lwtunnel_state_alloc(int hdr_len);
 int lwtunnel_cmp_encap(struct lwtunnel_state *a, struct lwtunnel_state *b);
-int lwtunnel_output(struct sock *sk, struct sk_buff *skb);
+int lwtunnel_output(struct net *net, struct sock *sk, struct sk_buff *skb);
 int lwtunnel_input(struct sk_buff *skb);
 
 #else
@@ -160,7 +160,7 @@ static inline int lwtunnel_cmp_encap(struct lwtunnel_state *a,
 	return 0;
 }
 
-static inline int lwtunnel_output(struct sock *sk, struct sk_buff *skb)
+static inline int lwtunnel_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	return -EOPNOTSUPP;
 }
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index fd176106909a..4a9c21f9b4ea 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -333,7 +333,7 @@ struct xfrm_state_afinfo {
 						const xfrm_address_t *saddr);
 	int			(*tmpl_sort)(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n);
 	int			(*state_sort)(struct xfrm_state **dst, struct xfrm_state **src, int n);
-	int			(*output)(struct sock *sk, struct sk_buff *skb);
+	int			(*output)(struct net *net, struct sock *sk, struct sk_buff *skb);
 	int			(*output_finish)(struct sock *sk, struct sk_buff *skb);
 	int			(*extract_input)(struct xfrm_state *x,
 						 struct sk_buff *skb);
@@ -1527,7 +1527,7 @@ static inline int xfrm4_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 
 int xfrm4_extract_output(struct xfrm_state *x, struct sk_buff *skb);
 int xfrm4_prepare_output(struct xfrm_state *x, struct sk_buff *skb);
-int xfrm4_output(struct sock *sk, struct sk_buff *skb);
+int xfrm4_output(struct net *net, struct sock *sk, struct sk_buff *skb);
 int xfrm4_output_finish(struct sock *sk, struct sk_buff *skb);
 int xfrm4_rcv_cb(struct sk_buff *skb, u8 protocol, int err);
 int xfrm4_protocol_register(struct xfrm4_protocol *handler, unsigned char protocol);
@@ -1552,7 +1552,7 @@ __be32 xfrm6_tunnel_alloc_spi(struct net *net, xfrm_address_t *saddr);
 __be32 xfrm6_tunnel_spi_lookup(struct net *net, const xfrm_address_t *saddr);
 int xfrm6_extract_output(struct xfrm_state *x, struct sk_buff *skb);
 int xfrm6_prepare_output(struct xfrm_state *x, struct sk_buff *skb);
-int xfrm6_output(struct sock *sk, struct sk_buff *skb);
+int xfrm6_output(struct net *net, struct sock *sk, struct sk_buff *skb);
 int xfrm6_output_finish(struct sock *sk, struct sk_buff *skb);
 int xfrm6_find_1stfragopt(struct xfrm_state *x, struct sk_buff *skb,
 			  u8 **prevhdr);
diff --git a/net/core/dst.c b/net/core/dst.c
index 0771c8cb9307..2a1818065e12 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -144,12 +144,12 @@ loop:
 	mutex_unlock(&dst_gc_mutex);
 }
 
-int dst_discard_sk(struct sock *sk, struct sk_buff *skb)
+int dst_discard_out(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	kfree_skb(skb);
 	return 0;
 }
-EXPORT_SYMBOL(dst_discard_sk);
+EXPORT_SYMBOL(dst_discard_out);
 
 const u32 dst_default_metrics[RTAX_MAX + 1] = {
 	/* This initializer is needed to force linker to place this variable
@@ -177,7 +177,7 @@ void dst_init(struct dst_entry *dst, struct dst_ops *ops,
 	dst->xfrm = NULL;
 #endif
 	dst->input = dst_discard;
-	dst->output = dst_discard_sk;
+	dst->output = dst_discard_out;
 	dst->error = 0;
 	dst->obsolete = initial_obsolete;
 	dst->header_len = 0;
@@ -224,7 +224,7 @@ static void ___dst_free(struct dst_entry *dst)
 	 */
 	if (dst->dev == NULL || !(dst->dev->flags&IFF_UP)) {
 		dst->input = dst_discard;
-		dst->output = dst_discard_sk;
+		dst->output = dst_discard_out;
 	}
 	dst->obsolete = DST_OBSOLETE_DEAD;
 }
@@ -352,7 +352,7 @@ static struct dst_ops md_dst_ops = {
 	.family =		AF_UNSPEC,
 };
 
-static int dst_md_discard_sk(struct sock *sk, struct sk_buff *skb)
+static int dst_md_discard_out(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	WARN_ONCE(1, "Attempting to call output on metadata dst\n");
 	kfree_skb(skb);
@@ -375,7 +375,7 @@ static void __metadata_dst_init(struct metadata_dst *md_dst, u8 optslen)
 		 DST_METADATA | DST_NOCACHE | DST_NOCOUNT);
 
 	dst->input = dst_md_discard;
-	dst->output = dst_md_discard_sk;
+	dst->output = dst_md_discard_out;
 
 	memset(dst + 1, 0, sizeof(*md_dst) + optslen - sizeof(*dst));
 }
@@ -430,7 +430,7 @@ static void dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 
 	if (!unregister) {
 		dst->input = dst_discard;
-		dst->output = dst_discard_sk;
+		dst->output = dst_discard_out;
 	} else {
 		dst->dev = dev_net(dst->dev)->loopback_dev;
 		dev_hold(dst->dev);
diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index dfb1a9ca0835..299cfc24d888 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -180,7 +180,7 @@ int lwtunnel_cmp_encap(struct lwtunnel_state *a, struct lwtunnel_state *b)
 }
 EXPORT_SYMBOL(lwtunnel_cmp_encap);
 
-int lwtunnel_output(struct sock *sk, struct sk_buff *skb)
+int lwtunnel_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	const struct lwtunnel_encap_ops *ops;
@@ -199,7 +199,7 @@ int lwtunnel_output(struct sock *sk, struct sk_buff *skb)
 	rcu_read_lock();
 	ops = rcu_dereference(lwtun_encaps[lwtstate->type]);
 	if (likely(ops && ops->output))
-		ret = ops->output(sk, skb);
+		ret = ops->output(net, sk, skb);
 	rcu_read_unlock();
 
 	if (ret == -EOPNOTSUPP)
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index e930321e2c1d..27fce283117b 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -744,7 +744,7 @@ out:
 	return NET_RX_DROP;
 }
 
-static int dn_output(struct sock *sk, struct sk_buff *skb)
+static int dn_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct dn_route *rt = (struct dn_route *)dst;
@@ -832,7 +832,7 @@ drop:
  * Used to catch bugs. This should never normally get
  * called.
  */
-static int dn_rt_bug_sk(struct sock *sk, struct sk_buff *skb)
+static int dn_rt_bug_out(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct dn_skb_cb *cb = DN_SKB_CB(skb);
 
@@ -1469,7 +1469,7 @@ make_route:
 
 	rt->n = neigh;
 	rt->dst.lastuse = jiffies;
-	rt->dst.output = dn_rt_bug_sk;
+	rt->dst.output = dn_rt_bug_out;
 	switch (res.type) {
 	case RTN_UNICAST:
 		rt->dst.input = dn_forward;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 9fe100a41e5d..67404e1fe7d4 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -284,11 +284,10 @@ static int ip_finish_output(struct net *net, struct sock *sk, struct sk_buff *sk
 	return ip_finish_output2(net, sk, skb);
 }
 
-int ip_mc_output(struct sock *sk, struct sk_buff *skb)
+int ip_mc_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct rtable *rt = skb_rtable(skb);
 	struct net_device *dev = rt->dst.dev;
-	struct net *net = dev_net(dev);
 
 	/*
 	 *	If the indicated interface is up and running, send the packet.
@@ -347,10 +346,9 @@ int ip_mc_output(struct sock *sk, struct sk_buff *skb)
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
 
-int ip_output(struct sock *sk, struct sk_buff *skb)
+int ip_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct net_device *dev = skb_dst(skb)->dev;
-	struct net *net = dev_net(dev);
 
 	IP_UPD_PO_STATS(net, IPSTATS_MIB_OUT, skb->len);
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 54297d3a0559..f33d3af7b6ba 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1152,7 +1152,7 @@ static void ipv4_link_failure(struct sk_buff *skb)
 		dst_set_expires(&rt->dst, 0);
 }
 
-static int ip_rt_bug(struct sock *sk, struct sk_buff *skb)
+static int ip_rt_bug(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	pr_debug("%s: %pI4 -> %pI4, %s\n",
 		 __func__, &ip_hdr(skb)->saddr, &ip_hdr(skb)->daddr,
@@ -2317,7 +2317,7 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 
 		new->__use = 1;
 		new->input = dst_discard;
-		new->output = dst_discard_sk;
+		new->output = dst_discard_out;
 
 		new->dev = ort->dst.dev;
 		if (new->dev)
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 17db61f4b439..9f298d0dc9a1 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -94,10 +94,8 @@ static int __xfrm4_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 	return x->outer_mode->afinfo->output_finish(sk, skb);
 }
 
-int xfrm4_output(struct sock *sk, struct sk_buff *skb)
+int xfrm4_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
-	struct net *net = dev_net(skb_dst(skb)->dev);
-
 	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING,
 			    net, sk, skb, NULL, skb_dst(skb)->dev,
 			    __xfrm4_output,
diff --git a/net/ipv6/ila.c b/net/ipv6/ila.c
index 678d2df4b8d9..1a6852e1ac69 100644
--- a/net/ipv6/ila.c
+++ b/net/ipv6/ila.c
@@ -91,7 +91,7 @@ static void update_ipv6_locator(struct sk_buff *skb, struct ila_params *p)
 	*(__be64 *)&ip6h->daddr = p->locator;
 }
 
-static int ila_output(struct sock *sk, struct sk_buff *skb)
+static int ila_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 
@@ -100,7 +100,7 @@ static int ila_output(struct sock *sk, struct sk_buff *skb)
 
 	update_ipv6_locator(skb, ila_params_lwtunnel(dst->lwtstate));
 
-	return dst->lwtstate->orig_output(sk, skb);
+	return dst->lwtstate->orig_output(net, sk, skb);
 
 drop:
 	kfree_skb(skb);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 98510fac94e9..32583b507c2e 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -130,11 +130,10 @@ static int ip6_finish_output(struct net *net, struct sock *sk, struct sk_buff *s
 		return ip6_finish_output2(net, sk, skb);
 }
 
-int ip6_output(struct sock *sk, struct sk_buff *skb)
+int ip6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct net_device *dev = skb_dst(skb)->dev;
 	struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
-	struct net *net = dev_net(dev);
 
 	if (unlikely(idev->cnf.disable_ipv6)) {
 		IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTDISCARDS);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d3d946773a3e..4320ddcac33f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -86,9 +86,9 @@ static void		ip6_dst_ifdown(struct dst_entry *,
 static int		 ip6_dst_gc(struct dst_ops *ops);
 
 static int		ip6_pkt_discard(struct sk_buff *skb);
-static int		ip6_pkt_discard_out(struct sock *sk, struct sk_buff *skb);
+static int		ip6_pkt_discard_out(struct net *net, struct sock *sk, struct sk_buff *skb);
 static int		ip6_pkt_prohibit(struct sk_buff *skb);
-static int		ip6_pkt_prohibit_out(struct sock *sk, struct sk_buff *skb);
+static int		ip6_pkt_prohibit_out(struct net *net, struct sock *sk, struct sk_buff *skb);
 static void		ip6_link_failure(struct sk_buff *skb);
 static void		ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 					   struct sk_buff *skb, u32 mtu);
@@ -308,7 +308,7 @@ static const struct rt6_info ip6_blk_hole_entry_template = {
 		.obsolete	= DST_OBSOLETE_FORCE_CHK,
 		.error		= -EINVAL,
 		.input		= dst_discard,
-		.output		= dst_discard_sk,
+		.output		= dst_discard_out,
 	},
 	.rt6i_flags	= (RTF_REJECT | RTF_NONEXTHOP),
 	.rt6i_protocol  = RTPROT_KERNEL,
@@ -1195,7 +1195,7 @@ struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_ori
 
 		new->__use = 1;
 		new->input = dst_discard;
-		new->output = dst_discard_sk;
+		new->output = dst_discard_out;
 
 		if (dst_metrics_read_only(&ort->dst))
 			new->_metrics = ort->dst._metrics;
@@ -1853,7 +1853,7 @@ int ip6_route_info_create(struct fib6_config *cfg, struct rt6_info **rt_ret)
 		switch (cfg->fc_type) {
 		case RTN_BLACKHOLE:
 			rt->dst.error = -EINVAL;
-			rt->dst.output = dst_discard_sk;
+			rt->dst.output = dst_discard_out;
 			rt->dst.input = dst_discard;
 			break;
 		case RTN_PROHIBIT:
@@ -2446,7 +2446,7 @@ static int ip6_pkt_discard(struct sk_buff *skb)
 	return ip6_pkt_drop(skb, ICMPV6_NOROUTE, IPSTATS_MIB_INNOROUTES);
 }
 
-static int ip6_pkt_discard_out(struct sock *sk, struct sk_buff *skb)
+static int ip6_pkt_discard_out(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	skb->dev = skb_dst(skb)->dev;
 	return ip6_pkt_drop(skb, ICMPV6_NOROUTE, IPSTATS_MIB_OUTNOROUTES);
@@ -2457,7 +2457,7 @@ static int ip6_pkt_prohibit(struct sk_buff *skb)
 	return ip6_pkt_drop(skb, ICMPV6_ADM_PROHIBITED, IPSTATS_MIB_INNOROUTES);
 }
 
-static int ip6_pkt_prohibit_out(struct sock *sk, struct sk_buff *skb)
+static int ip6_pkt_prohibit_out(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	skb->dev = skb_dst(skb)->dev;
 	return ip6_pkt_drop(skb, ICMPV6_ADM_PROHIBITED, IPSTATS_MIB_OUTNOROUTES);
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index c9a5bd5fea9c..9db067a11b52 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -173,10 +173,8 @@ static int __xfrm6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 	return x->outer_mode->afinfo->output_finish(sk, skb);
 }
 
-int xfrm6_output(struct sock *sk, struct sk_buff *skb)
+int xfrm6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
-	struct net *net = dev_net(skb_dst(skb)->dev);
-
 	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING,
 			    net, sk, skb,  NULL, skb_dst(skb)->dev,
 			    __xfrm6_output,
diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
index 21e70bc9af98..67591aef9cae 100644
--- a/net/mpls/mpls_iptunnel.c
+++ b/net/mpls/mpls_iptunnel.c
@@ -37,7 +37,7 @@ static unsigned int mpls_encap_size(struct mpls_iptunnel_encap *en)
 	return en->labels * sizeof(struct mpls_shim_hdr);
 }
 
-int mpls_output(struct sock *sk, struct sk_buff *skb)
+int mpls_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct mpls_iptunnel_encap *tun_encap_info;
 	struct mpls_shim_hdr *hdr;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index f4f2d987f8f0..09bfcbac63bb 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1957,7 +1957,7 @@ purge_queue:
 	xfrm_pol_put(pol);
 }
 
-static int xdst_queue_output(struct sock *sk, struct sk_buff *skb)
+static int xdst_queue_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	unsigned long sched_next;
 	struct dst_entry *dst = skb_dst(skb);
-- 
2.2.1
