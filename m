From: Hannes Eder <heder@google.com>
Subject: [RFC][PATCH 3/5] IPVS: make friends with nf_conntrack
Date: Mon, 27 Jul 2009 15:46:26 +0200
Message-ID: <20090727134626.12897.7821.stgit@jazzy.zrh.corp.google.com>
References: <20090727134457.12897.272.stgit@jazzy.zrh.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1248708681; bh=N+8EIrcwcsRY/Lma1NDd8UzF418=;
	h=DomainKey-Signature:Subject:To:From:Cc:Date:Message-ID:
	 In-Reply-To:References:User-Agent:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:X-System-Of-Record; b=F7RvV50/yR1hcGHZxt
	AGBdyv6T5PAo+BrGrYQmAvG5AjwcSI6OkrJ51LSWctfs4Siw7fdKPN9ImytWRhe/3j2
	Q==
In-Reply-To: <20090727134457.12897.272.stgit@jazzy.zrh.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org

From: Hannes Eder <hannes@hanneseder.net>

We aim at adding full NAT support to IPVS.  With this patch it is
possible to use netfilters SNAT in POSTROUTING, especially with
xt_ipvs, e.g.:

iptables -t nat -A POSTROUTING -m ipvs --vaddr 192.168.100.30/32 --vport 8080 \
	-j SNAT --to-source 192.168.10.10

There might be other use cases.

Current Status:
  - NAT works
  - DR works
  - IPIP not tested
  - overall: needs more testing
  - Performance impact?

Signed-off-by: Hannes Eder <heder@google.com>

 net/netfilter/ipvs/ip_vs_core.c |   36 ------------------------------------
 net/netfilter/ipvs/ip_vs_xmit.c |   28 ++++++++++++++++++++++++++++
 2 files changed, 28 insertions(+), 36 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 8dddb17..b021464 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -518,26 +518,6 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
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
@@ -1428,14 +1408,6 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
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
@@ -1464,14 +1436,6 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
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
index 425ab14..f3b6810 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -24,6 +24,7 @@
 #include <net/ip6_route.h>
 #include <linux/icmpv6.h>
 #include <linux/netfilter.h>
+#include <net/netfilter/nf_conntrack.h>
 #include <linux/netfilter_ipv4.h>
 
 #include <net/ip_vs.h>
@@ -344,6 +345,29 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 }
 #endif
 
+static void
+ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp)
+{
+	if (skb->nfct) {
+		struct nf_conn *ct = (struct nf_conn *)skb->nfct;
+
+		if (ct != &nf_conntrack_untracked && !nf_ct_is_confirmed(ct)) {
+			/*
+			 * The connection is not yet in the hashtable, so we
+			 * update it.  CIP->VIP will remain the same, so leave
+			 * the tuple in IP_CT_DIR_ORIGINAL untouched.  When the
+			 * reply comes back from the real-server we will see
+			 * RIP->DIP.
+			 */
+
+			ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.u3 = cp->daddr;
+			/* this will also take care for UDP and  */
+			ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.u.tcp.port =
+				cp->dport;
+		}
+	}
+}
+
 /*
  *      NAT transmitter (only for outside-to-inside nat forwarding)
  *      Not used for related ICMP
@@ -399,6 +423,8 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	IP_VS_DBG_PKT(10, pp, skb, 0, "After DNAT");
 
+	ip_vs_update_conntrack(skb, cp);
+
 	/* FIXME: when application helper enlarges the packet and the length
 	   is larger than the MTU of outgoing device, there will be still
 	   MTU problem. */
@@ -475,6 +501,8 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	IP_VS_DBG_PKT(10, pp, skb, 0, "After DNAT");
 
+	ip_vs_update_conntrack(skb, cp);
+
 	/* FIXME: when application helper enlarges the packet and the length
 	   is larger than the MTU of outgoing device, there will be still
 	   MTU problem. */

