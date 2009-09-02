From: Hannes Eder <heder@google.com>
Subject: [PATCH 2/3] IPVS: make friends with nf_conntrack
Date: Wed,  2 Sep 2009 16:39:45 +0200 (CEST)
Message-ID: <20090902101538.11561.11911.stgit@jazzy.zrh.corp.google.com>
References: <20090902101417.11561.45663.stgit@jazzy.zrh.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752863AbZIBOk3@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1251902395; bh=3wmkRihpRPqLsSkDBusu0FLEn+o=;
	h=DomainKey-Signature:Subject:To:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:
	 Cc:From:Message-ID:In-Reply-To:References:User-Agent:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:Date:X-System-Of-Record;
	b=ZWoAVJ7Y+pP1Wk9usm+TTqeE0/QDkV+zCn2nYQdvyeXxHlbpUy6/Z/j6L3n0Jnj5V
	rzQYrqklrLG3EfKkoWt5g==
In-Reply-To: <20090902101417.11561.45663.stgit@jazzy.zrh.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, =?ISO-8859-1?Q?Fabien_Duch=EAne?= <mad_fab@skynet.be>, Jan Engelhardt <jengelh@medozas.de>, Jean-Luc Fortemaison <jl.fortemaison@uclouvain.be>, Julian Anastasov <ja@ssi.bg>, Julius Volz <julius.volz@gmail.com>, Laurent Grawet <laurent.grawet@uclouvain.be>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>

Update the nf_conntrack tuple in reply direction, as we will see
traffic from the real server (RIP) to the client (CIP).  Once this is
done we can use netfilters SNAT in POSTROUTING, especially with
xt_ipvs, to do source NAT, e.g.:

% iptables -t nat -A POSTROUTING -m ipvs --vaddr 192.168.100.30/32 --vport 8080 \
> -j SNAT --to-source 192.168.10.10

Signed-off-by: Hannes Eder <heder@google.com>
---

 net/netfilter/ipvs/Kconfig      |    2 +-
 net/netfilter/ipvs/ip_vs_core.c |   36 ------------------------------------
 net/netfilter/ipvs/ip_vs_xmit.c |   27 +++++++++++++++++++++++++++
 3 files changed, 28 insertions(+), 37 deletions(-)

diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index 79a6980..fca5379 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -3,7 +3,7 @@
 #
 menuconfig IP_VS
 	tristate "IP virtual server support"
-	depends on NET && INET && NETFILTER
+	depends on NET && INET && NETFILTER && NF_CONNTRACK
 	---help---
 	  IP Virtual Server support will let you build a high-performance
 	  virtual server based on cluster of two or more real servers. This
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index b227750..27bd002 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -521,26 +521,6 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
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
@@ -1431,14 +1411,6 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
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
@@ -1467,14 +1439,6 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
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
 
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 30b3189..fc7d6a4 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -27,6 +27,7 @@
 #include <net/ip6_route.h>
 #include <linux/icmpv6.h>
 #include <linux/netfilter.h>
+#include <net/netfilter/nf_conntrack.h>
 #include <linux/netfilter_ipv4.h>
 
 #include <net/ip_vs.h>
@@ -347,6 +348,28 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 }
 #endif
 
+static void
+ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp)
+{
+	struct nf_conn *ct = (struct nf_conn *)skb->nfct;
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
+	ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.u3 = cp->daddr;
+	/*
+	 * This will also take care of UDP and other protocols.
+	 */
+	ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.u.tcp.port = cp->dport;
+}
+
 /*
  *      NAT transmitter (only for outside-to-inside nat forwarding)
  *      Not used for related ICMP
@@ -402,6 +425,8 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	IP_VS_DBG_PKT(10, pp, skb, 0, "After DNAT");
 
+	ip_vs_update_conntrack(skb, cp);
+
 	/* FIXME: when application helper enlarges the packet and the length
 	   is larger than the MTU of outgoing device, there will be still
 	   MTU problem. */
@@ -478,6 +503,8 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	IP_VS_DBG_PKT(10, pp, skb, 0, "After DNAT");
 
+	ip_vs_update_conntrack(skb, cp);
+
 	/* FIXME: when application helper enlarges the packet and the length
 	   is larger than the MTU of outgoing device, there will be still
 	   MTU problem. */
