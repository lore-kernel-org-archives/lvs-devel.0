From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: Re: [PATCH] use nf_register_hooks
Date: Wed, 16 Apr 2008 12:02:59 +0900
Message-ID: <200804161202.59417.j.stubbs@linkthink.co.jp>
References: <200804161137.13167.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_jxWBIrmiHz/dOGe"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <200804161137.13167.j.stubbs@linkthink.co.jp>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: LVS Devel <lvs-devel@vger.kernel.org>

--Boundary-00=_jxWBIrmiHz/dOGe
Content-Type: text/plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wednesday 16 April 2008 11:37:13 Jason Stubbs wrote:
> Netfilter contains two nice little functions, nf_register_hooks and
> nf_unregister_hooks, that (un)register a series of hooks and automatically
> handle failure. This patch converts LVS to use these functions so that that
> any future addition/removal of hooks requires less changes and is thus less
> error prone.

Same again but using the ARRAY_SIZE macro instead.

-- 
Jason Stubbs <j.stubbs@linkthink.co.jp>
LINKTHINK INC.
東京都渋谷区桜ヶ丘町22-14 N.E.S S棟 3F
TEL 03-5728-4772  FAX 03-5728-4773

--Boundary-00=_jxWBIrmiHz/dOGe
Content-Type: text/x-diff;
  charset="iso-2022-jp";
  name="ipvs-nf_register_hooks.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="ipvs-nf_register_hooks.patch"

--- net/ipv4/ipvs/ip_vs_core.c.orig	2008-04-16 10:48:45.000000000 +0900
+++ net/ipv4/ipvs/ip_vs_core.c	2008-04-16 12:03:44.000000000 +0900
@@ -1025,43 +1025,45 @@ ip_vs_forward_icmp(unsigned int hooknum,
 }
 
 
-/* After packet filtering, forward packet through VS/DR, VS/TUN,
-   or VS/NAT(change destination), so that filtering rules can be
-   applied to IPVS. */
-static struct nf_hook_ops ip_vs_in_ops = {
-	.hook		= ip_vs_in,
-	.owner		= THIS_MODULE,
-	.pf		= PF_INET,
-	.hooknum        = NF_IP_LOCAL_IN,
-	.priority       = 100,
-};
-
-/* After packet filtering, change source only for VS/NAT */
-static struct nf_hook_ops ip_vs_out_ops = {
-	.hook		= ip_vs_out,
-	.owner		= THIS_MODULE,
-	.pf		= PF_INET,
-	.hooknum        = NF_IP_FORWARD,
-	.priority       = 100,
-};
-
-/* After packet filtering (but before ip_vs_out_icmp), catch icmp
-   destined for 0.0.0.0/0, which is for incoming IPVS connections */
-static struct nf_hook_ops ip_vs_forward_icmp_ops = {
-	.hook		= ip_vs_forward_icmp,
-	.owner		= THIS_MODULE,
-	.pf		= PF_INET,
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
+static struct nf_hook_ops ip_vs_ops[] = {
+	/* After packet filtering, forward packet through VS/DR, VS/TUN,
+	   or VS/NAT(change destination), so that filtering rules can be
+	   applied to IPVS. */
+	{
+		.hook		= ip_vs_in,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET,
+		.hooknum        = NF_IP_LOCAL_IN,
+		.priority       = 100,
+	},
+
+	/* After packet filtering, change source only for VS/NAT */
+	{
+		.hook		= ip_vs_out,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET,
+		.hooknum        = NF_IP_FORWARD,
+		.priority       = 100,
+	},
+
+	/* After packet filtering (but before ip_vs_out_icmp), catch icmp
+	   destined for 0.0.0.0/0, which is for incoming IPVS connections */
+	{
+		.hook		= ip_vs_forward_icmp,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET,
+		.hooknum        = NF_IP_FORWARD,
+		.priority       = 99,
+	},
+
+	/* Before the netfilter connection tracking, exit from POST_ROUTING */
+	{
+		.hook		= ip_vs_post_routing,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET,
+		.hooknum        = NF_IP_POST_ROUTING,
+		.priority       = NF_IP_PRI_NAT_SRC-1,
+	}
 };
 
 
@@ -1092,37 +1094,15 @@ static int __init ip_vs_init(void)
 		goto cleanup_app;
 	}
 
-	ret = nf_register_hook(&ip_vs_in_ops);
+	ret = nf_register_hooks(ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
 	if (ret < 0) {
-		IP_VS_ERR("can't register in hook.\n");
+		IP_VS_ERR("can't register hooks.\n");
 		goto cleanup_conn;
 	}
 
-	ret = nf_register_hook(&ip_vs_out_ops);
-	if (ret < 0) {
-		IP_VS_ERR("can't register out hook.\n");
-		goto cleanup_inops;
-	}
-	ret = nf_register_hook(&ip_vs_post_routing_ops);
-	if (ret < 0) {
-		IP_VS_ERR("can't register post_routing hook.\n");
-		goto cleanup_outops;
-	}
-	ret = nf_register_hook(&ip_vs_forward_icmp_ops);
-	if (ret < 0) {
-		IP_VS_ERR("can't register forward_icmp hook.\n");
-		goto cleanup_postroutingops;
-	}
-
 	IP_VS_INFO("ipvs loaded.\n");
 	return ret;
 
-  cleanup_postroutingops:
-	nf_unregister_hook(&ip_vs_post_routing_ops);
-  cleanup_outops:
-	nf_unregister_hook(&ip_vs_out_ops);
-  cleanup_inops:
-	nf_unregister_hook(&ip_vs_in_ops);
   cleanup_conn:
 	ip_vs_conn_cleanup();
   cleanup_app:
@@ -1136,10 +1116,7 @@ static int __init ip_vs_init(void)
 
 static void __exit ip_vs_cleanup(void)
 {
-	nf_unregister_hook(&ip_vs_forward_icmp_ops);
-	nf_unregister_hook(&ip_vs_post_routing_ops);
-	nf_unregister_hook(&ip_vs_out_ops);
-	nf_unregister_hook(&ip_vs_in_ops);
+	nf_unregister_hooks(ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
 	ip_vs_conn_cleanup();
 	ip_vs_app_cleanup();
 	ip_vs_protocol_cleanup();

--Boundary-00=_jxWBIrmiHz/dOGe--
