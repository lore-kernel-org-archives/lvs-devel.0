From: Simon Horman <horms@verge.net.au>
Subject: [patch v2.2 2/4] [PATCH v2.1 2/4] IPVS: make friends with nf_conntrack
Date: Sat, 01 May 2010 13:20:16 +1000
Message-ID: <20100501032120.644762316@vergenet.net>
References: <20100501032014.406353538@vergenet.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=2.patch
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julius Volz <julius.volz@gmail.com>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, Hannes Eder <heder@google.com>

From:	Hannes Eder <heder@google.com>

Update the nf_conntrack tuple in reply direction, as we will see
traffic from the real server (RIP) to the client (CIP).  Once this is
done we can use netfilters SNAT in POSTROUTING, especially with
xt_ipvs, to do source NAT, e.g.:

% iptables -t nat -A POSTROUTING -m ipvs --vaddr 192.168.100.30/32 --vport 80 \
> -j SNAT --to-source 192.168.10.10

Signed-off-by: Hannes Eder <heder@google.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

 net/netfilter/ipvs/Kconfig      |    2 +-
 net/netfilter/ipvs/ip_vs_core.c |   36 ------------------------------------
 net/netfilter/ipvs/ip_vs_xmit.c |   30 ++++++++++++++++++++++++++++++
 3 files changed, 31 insertions(+), 37 deletions(-)

Index: nf-next-2.6/net/netfilter/ipvs/Kconfig
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/Kconfig	2010-04-29 20:11:51.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/Kconfig	2010-04-29 20:11:59.000000000 +0900
@@ -3,7 +3,7 @@
 #
 menuconfig IP_VS
 	tristate "IP virtual server support"
-	depends on NET && INET && NETFILTER
+	depends on NET && INET && NETFILTER && NF_CONNTRACK
 	---help---
 	  IP Virtual Server support will let you build a high-performance
 	  virtual server based on cluster of two or more real servers. This
Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_core.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_core.c	2010-04-29 20:11:51.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_core.c	2010-04-29 20:11:59.000000000 +0900
@@ -521,26 +521,6 @@ int ip_vs_leave(struct ip_vs_service *sv
 	return NF_DROP;
 }
 
-
-/*
- *      It is hooked before NF_IP_PRI_NAT_SRC at the NF_INET_POST_ROUTING
- *      chain, and is used for VS/NAT.
- *      It detects packets for VS/NAT connections and sends the packets
- *      immediately. This can avoid that iptable_nat mangles the packets
- *      for VS/NAT.
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
@@ -1443,14 +1423,6 @@ static struct nf_hook_ops ip_vs_ops[] __
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
@@ -1479,14 +1451,6 @@ static struct nf_hook_ops ip_vs_ops[] __
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
 
Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_xmit.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_xmit.c	2010-04-29 20:11:51.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_xmit.c	2010-04-29 20:11:59.000000000 +0900
@@ -27,6 +27,7 @@
 #include <net/ip6_route.h>
 #include <linux/icmpv6.h>
 #include <linux/netfilter.h>
+#include <net/netfilter/nf_conntrack.h>
 #include <linux/netfilter_ipv4.h>
 
 #include <net/ip_vs.h>
@@ -347,6 +348,31 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb
 }
 #endif
 
+static void
+ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp)
+{
+	struct nf_conn *ct = (struct nf_conn *)skb->nfct;
+	struct nf_conntrack_tuple new_tuple;
+
+	if (ct == NULL || ct == &nf_conntrack_untracked ||
+	    nf_ct_is_confirmed(ct))
+		return;
+
+	/*
+	 * The connection is not yet in the hashtable, so we update it.
+	 * CIP->VIP will remain the same, so leave the tuple in
+	 * IP_CT_DIR_ORIGINAL untouched.  When the reply comes back from the
+	 * real-server we will see RIP->DIP.
+	 */
+	new_tuple = ct->tuplehash[IP_CT_DIR_REPLY].tuple;
+	new_tuple.src.u3 = cp->daddr;
+	/*
+	 * This will also take care of UDP and other protocols.
+	 */
+	new_tuple.src.u.tcp.port = cp->dport;
+	nf_conntrack_alter_reply(ct, &new_tuple);
+}
+
 /*
  *      NAT transmitter (only for outside-to-inside nat forwarding)
  *      Not used for related ICMP
@@ -402,6 +428,8 @@ ip_vs_nat_xmit(struct sk_buff *skb, stru
 
 	IP_VS_DBG_PKT(10, pp, skb, 0, "After DNAT");
 
+	ip_vs_update_conntrack(skb, cp);
+
 	/* FIXME: when application helper enlarges the packet and the length
 	   is larger than the MTU of outgoing device, there will be still
 	   MTU problem. */
@@ -478,6 +506,8 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, s
 
 	IP_VS_DBG_PKT(10, pp, skb, 0, "After DNAT");
 
+	ip_vs_update_conntrack(skb, cp);
+
 	/* FIXME: when application helper enlarges the packet and the length
 	   is larger than the MTU of outgoing device, there will be still
 	   MTU problem. */
