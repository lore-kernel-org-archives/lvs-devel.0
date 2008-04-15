From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: [PATCH 1/6] move ipvs to PRE/POSTROUTING
Date: Tue, 15 Apr 2008 15:40:48 +0900
Message-ID: <200804151540.48799.j.stubbs@linkthink.co.jp>
References: <200804151540.04006.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_w3EBIgZkj3/+PSo"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <200804151540.04006.j.stubbs@linkthink.co.jp>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: LVS Devel <lvs-devel@vger.kernel.org>

--Boundary-00=_w3EBIgZkj3/+PSo
Content-Type: text/plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This patch moves the handling of traffic to VIPs to the end of
POSTROUTING and the handling of traffic from RIPs to the beginning of
PREROUTING. It also drops the post routing hook that prevents LVS'd
traffic from running through POSTROUTING as traffic no longer gets LVS'd
until after POSTROUTING has finished.

-- 
Jason Stubbs <j.stubbs@linkthink.co.jp>
LINKTHINK INC.
東京都渋谷区桜ヶ丘町22-14 N.E.S S棟 3F
TEL 03-5728-4772  FAX 03-5728-4773

--Boundary-00=_w3EBIgZkj3/+PSo
Content-Type: text/x-diff;
  charset="iso-2022-jp";
  name="1-rehook.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="1-rehook.patch"

diff -urp linux.0.orig/net/ipv4/ipvs/ip_vs_core.c linux.1.rehook/net/ipv4/ipvs/ip_vs_core.c
--- linux.0.orig/net/ipv4/ipvs/ip_vs_core.c	2008-04-15 12:11:31.241178382 +0900
+++ linux.1.rehook/net/ipv4/ipvs/ip_vs_core.c	2008-04-15 13:06:14.559201707 +0900
@@ -480,25 +480,6 @@ int ip_vs_leave(struct ip_vs_service *sv
 }
 
 
-/*
- *      It is hooked before NF_IP_PRI_NAT_SRC at the NF_IP_POST_ROUTING
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
@@ -1032,8 +1013,8 @@ static struct nf_hook_ops ip_vs_in_ops =
 	.hook		= ip_vs_in,
 	.owner		= THIS_MODULE,
 	.pf		= PF_INET,
-	.hooknum        = NF_IP_LOCAL_IN,
-	.priority       = 100,
+	.hooknum        = NF_IP_POST_ROUTING,
+	.priority       = NF_IP_PRI_LAST,
 };
 
 /* After packet filtering, change source only for VS/NAT */
@@ -1041,8 +1022,8 @@ static struct nf_hook_ops ip_vs_out_ops 
 	.hook		= ip_vs_out,
 	.owner		= THIS_MODULE,
 	.pf		= PF_INET,
-	.hooknum        = NF_IP_FORWARD,
-	.priority       = 100,
+	.hooknum        = NF_IP_PRE_ROUTING,
+	.priority       = NF_IP_PRI_FIRST + 1,
 };
 
 /* After packet filtering (but before ip_vs_out_icmp), catch icmp
@@ -1051,17 +1032,8 @@ static struct nf_hook_ops ip_vs_forward_
 	.hook		= ip_vs_forward_icmp,
 	.owner		= THIS_MODULE,
 	.pf		= PF_INET,
-	.hooknum        = NF_IP_FORWARD,
-	.priority       = 99,
-};
-
-/* Before the netfilter connection tracking, exit from POST_ROUTING */
-static struct nf_hook_ops ip_vs_post_routing_ops = {
-	.hook		= ip_vs_post_routing,
-	.owner		= THIS_MODULE,
-	.pf		= PF_INET,
-	.hooknum        = NF_IP_POST_ROUTING,
-	.priority       = NF_IP_PRI_NAT_SRC-1,
+	.hooknum        = NF_IP_PRE_ROUTING,
+	.priority       = NF_IP_PRI_FIRST,
 };
 
 
@@ -1103,22 +1075,15 @@ static int __init ip_vs_init(void)
 		IP_VS_ERR("can't register out hook.\n");
 		goto cleanup_inops;
 	}
-	ret = nf_register_hook(&ip_vs_post_routing_ops);
-	if (ret < 0) {
-		IP_VS_ERR("can't register post_routing hook.\n");
-		goto cleanup_outops;
-	}
 	ret = nf_register_hook(&ip_vs_forward_icmp_ops);
 	if (ret < 0) {
 		IP_VS_ERR("can't register forward_icmp hook.\n");
-		goto cleanup_postroutingops;
+		goto cleanup_outops;
 	}
 
 	IP_VS_INFO("ipvs loaded.\n");
 	return ret;
 
-  cleanup_postroutingops:
-	nf_unregister_hook(&ip_vs_post_routing_ops);
   cleanup_outops:
 	nf_unregister_hook(&ip_vs_out_ops);
   cleanup_inops:
@@ -1137,7 +1102,6 @@ static int __init ip_vs_init(void)
 static void __exit ip_vs_cleanup(void)
 {
 	nf_unregister_hook(&ip_vs_forward_icmp_ops);
-	nf_unregister_hook(&ip_vs_post_routing_ops);
 	nf_unregister_hook(&ip_vs_out_ops);
 	nf_unregister_hook(&ip_vs_in_ops);
 	ip_vs_conn_cleanup();

--Boundary-00=_w3EBIgZkj3/+PSo--
