From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: [PATCH] use nf_register_hooks
Date: Wed, 16 Apr 2008 11:37:13 +0900
Message-ID: <200804161137.13167.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_ZZWBIPMPE0paWEB"
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: LVS Devel <lvs-devel@vger.kernel.org>

--Boundary-00=_ZZWBIPMPE0paWEB
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Netfilter contains two nice little functions, nf_register_hooks and=20
nf_unregister_hooks, that (un)register a series of hooks and automatically=
=20
handle failure. This patch converts LVS to use these functions so that that=
=20
any future addition/removal of hooks requires less changes and is thus less=
=20
error prone.

=2D-=20
Jason Stubbs <j.stubbs@linkthink.co.jp>
LINKTHINK INC.
=E6=9D=B1=E4=BA=AC=E9=83=BD=E6=B8=8B=E8=B0=B7=E5=8C=BA=E6=A1=9C=E3=83=B6=E4=
=B8=98=E7=94=BA22-14 N.E.S S=E6=A3=9F 3F
TEL 03-5728-4772  FAX 03-5728-4773

--Boundary-00=_ZZWBIPMPE0paWEB
Content-Type: text/x-diff;
  charset="utf-8";
  name="ipvs-nf_register_hooks.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="ipvs-nf_register_hooks.patch"

--- net/ipv4/ipvs/ip_vs_core.c.orig	2008-04-16 10:48:45.000000000 +0900
+++ net/ipv4/ipvs/ip_vs_core.c	2008-04-16 11:27:46.000000000 +0900
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
+	ret = nf_register_hooks(ip_vs_ops, sizeof(ip_vs_ops) / sizeof(struct nf_hook_ops));
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
+	nf_unregister_hooks(ip_vs_ops, sizeof(ip_vs_ops) / sizeof(struct nf_hook_ops));
 	ip_vs_conn_cleanup();
 	ip_vs_app_cleanup();
 	ip_vs_protocol_cleanup();

--Boundary-00=_ZZWBIPMPE0paWEB--
