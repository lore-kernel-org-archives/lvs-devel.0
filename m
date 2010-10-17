From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 03/12] ipvs: switch to notrack mode
Date: Sun, 17 Oct 2010 16:21:07 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010171617220.20665@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; format="flowed"; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


 	Change skb->ipvs_property semantic. This is preparation
to support ip_vs_out processing in LOCAL_OUT. ipvs_property=1
will be used to avoid expensive lookups for traffic sent by
transmitters. Now when conntrack support is not used we call
ip_vs_notrack method to avoid problems in OUTPUT and
POST_ROUTING hooks instead of exiting POST_ROUTING as before.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp nf-next-2.6-a91fd26/linux/include/net/ip_vs.h linux/include/net/ip_vs.h
--- nf-next-2.6-a91fd26/linux/include/net/ip_vs.h	2010-10-13 22:22:35.000000000 +0300
+++ linux/include/net/ip_vs.h	2010-10-16 12:55:29.134355468 +0300
@@ -25,7 +25,7 @@
  #include <linux/ip.h>
  #include <linux/ipv6.h>			/* for struct ipv6hdr */
  #include <net/ipv6.h>			/* for ipv6_addr_copy */
-#ifdef CONFIG_IP_VS_NFCT
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
  #include <net/netfilter/nf_conntrack.h>
  #endif

@@ -1009,6 +1009,24 @@ static inline __wsum ip_vs_check_diff2(_
  	return csum_partial(diff, sizeof(diff), oldsum);
  }

+/*
+ * Forget current conntrack (unconfirmed) and attach notrack entry
+ */
+static inline void ip_vs_notrack(struct sk_buff *skb)
+{
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
+
+	if (!ct || !nf_ct_is_untracked(ct)) {
+		nf_reset(skb);
+		skb->nfct = &nf_ct_untracked_get()->ct_general;
+		skb->nfctinfo = IP_CT_NEW;
+		nf_conntrack_get(skb->nfct);
+	}
+#endif
+}
+
  #ifdef CONFIG_IP_VS_NFCT
  /*
   *      Netfilter connection tracking
diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_core.c linux/net/netfilter/ipvs/ip_vs_core.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_core.c	2010-10-13 22:22:35.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_core.c	2010-10-16 12:55:29.136353771 +0300
@@ -507,23 +507,6 @@ int ip_vs_leave(struct ip_vs_service *sv
  	return NF_DROP;
  }

-/*
- * It is hooked before NF_IP_PRI_NAT_SRC at the NF_INET_POST_ROUTING
- * chain and is used to avoid double NAT and confirmation when we do
- * not want to keep the conntrack structure
- */
-static unsigned int ip_vs_post_routing(unsigned int hooknum,
-				       struct sk_buff *skb,
-				       const struct net_device *in,
-				       const struct net_device *out,
-				       int (*okfn)(struct sk_buff *))
-{
-	if (!skb->ipvs_property)
-		return NF_ACCEPT;
-	/* The packet was sent from IPVS, exit this chain */
-	return NF_STOP;
-}
-
  __sum16 ip_vs_checksum_complete(struct sk_buff *skb, int offset)
  {
  	return csum_fold(skb_checksum(skb, offset, skb->len - offset, 0));
@@ -682,8 +665,9 @@ static int handle_response_icmp(int af,
  	/* do the statistics and put it back */
  	ip_vs_out_stats(cp, skb);

+	skb->ipvs_property = 1;
  	if (!(cp->flags & IP_VS_CONN_F_NFCT))
-		skb->ipvs_property = 1;
+		ip_vs_notrack(skb);
  	else
  		ip_vs_update_conntrack(skb, cp, 0);
  	verdict = NF_ACCEPT;
@@ -929,8 +913,9 @@ handle_response(int af, struct sk_buff *

  	ip_vs_out_stats(cp, skb);
  	ip_vs_set_state(cp, IP_VS_DIR_OUTPUT, skb, pp);
+	skb->ipvs_property = 1;
  	if (!(cp->flags & IP_VS_CONN_F_NFCT))
-		skb->ipvs_property = 1;
+		ip_vs_notrack(skb);
  	else
  		ip_vs_update_conntrack(skb, cp, 0);
  	ip_vs_conn_put(cp);
@@ -1496,14 +1481,6 @@ static struct nf_hook_ops ip_vs_ops[] __
  		.hooknum        = NF_INET_FORWARD,
  		.priority       = 99,
  	},
-	/* Before the netfilter connection tracking, exit from POST_ROUTING */
-	{
-		.hook		= ip_vs_post_routing,
-		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
-		.hooknum        = NF_INET_POST_ROUTING,
-		.priority       = NF_IP_PRI_NAT_SRC-1,
-	},
  #ifdef CONFIG_IP_VS_IPV6
  	/* After packet filtering, forward packet through VS/DR, VS/TUN,
  	 * or VS/NAT(change destination), so that filtering rules can be
@@ -1532,14 +1509,6 @@ static struct nf_hook_ops ip_vs_ops[] __
  		.hooknum        = NF_INET_FORWARD,
  		.priority       = 99,
  	},
-	/* Before the netfilter connection tracking, exit from POST_ROUTING */
-	{
-		.hook		= ip_vs_post_routing,
-		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
-		.hooknum        = NF_INET_POST_ROUTING,
-		.priority       = NF_IP6_PRI_NAT_SRC-1,
-	},
  #endif
  };

diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_xmit.c linux/net/netfilter/ipvs/ip_vs_xmit.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_xmit.c	2010-10-13 22:22:35.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_xmit.c	2010-10-16 12:55:29.137354829 +0300
@@ -197,6 +197,7 @@ ip_vs_dst_reset(struct ip_vs_dest *dest)
  ({								\
  	int __ret = NF_ACCEPT;					\
  								\
+	(skb)->ipvs_property = 1;				\
  	if (unlikely((cp)->flags & IP_VS_CONN_F_NFCT))		\
  		__ret = ip_vs_confirm_conntrack(skb, cp);	\
  	if (__ret == NF_ACCEPT) {				\
@@ -208,8 +209,9 @@ ip_vs_dst_reset(struct ip_vs_dest *dest)

  #define IP_VS_XMIT_NAT(pf, skb, cp)				\
  do {							\
+	(skb)->ipvs_property = 1;			\
  	if (likely(!((cp)->flags & IP_VS_CONN_F_NFCT)))	\
-		(skb)->ipvs_property = 1;		\
+		ip_vs_notrack(skb);			\
  	else						\
  		ip_vs_update_conntrack(skb, cp, 1);	\
  	skb_forward_csum(skb);				\
@@ -219,8 +221,9 @@ do {							\

  #define IP_VS_XMIT(pf, skb, cp)				\
  do {							\
+	(skb)->ipvs_property = 1;			\
  	if (likely(!((cp)->flags & IP_VS_CONN_F_NFCT)))	\
-		(skb)->ipvs_property = 1;		\
+		ip_vs_notrack(skb);			\
  	skb_forward_csum(skb);				\
  	NF_HOOK(pf, NF_INET_LOCAL_OUT, (skb), NULL,	\
  		skb_dst(skb)->dev, dst_output);		\
