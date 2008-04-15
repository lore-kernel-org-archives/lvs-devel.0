From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: [PATCH 6/6] move ipvs to PRE/POSTROUTING
Date: Tue, 15 Apr 2008 15:43:22 +0900
Message-ID: <200804151543.22583.j.stubbs@linkthink.co.jp>
References: <200804151540.04006.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_K6EBIN8oy63oHFQ"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <200804151540.04006.j.stubbs@linkthink.co.jp>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: LVS Devel <lvs-devel@vger.kernel.org>

--Boundary-00=_K6EBIN8oy63oHFQ
Content-Type: text/plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Aliasing LOCALNODE to MASQ means that traffic entering the OUTPUT chain
may be replies for a LVS-NAT'd connection. This patch adds the same
hooks that de-LVS packets at the start of PREROUTING to the start of
OUTPUT too.

-- 
Jason Stubbs <j.stubbs@linkthink.co.jp>
LINKTHINK INC.
東京都渋谷区桜ヶ丘町22-14 N.E.S S棟 3F
TEL 03-5728-4772  FAX 03-5728-4773

--Boundary-00=_K6EBIN8oy63oHFQ
Content-Type: text/x-diff;
  charset="iso-2022-jp";
  name="6-localhooks.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="6-localhooks.patch"

diff -urp linux.5.localmasq/net/ipv4/ipvs/ip_vs_core.c linux.6.localhooks/net/ipv4/ipvs/ip_vs_core.c
--- linux.5.localmasq/net/ipv4/ipvs/ip_vs_core.c	2008-04-15 13:07:04.000000000 +0900
+++ linux.6.localhooks/net/ipv4/ipvs/ip_vs_core.c	2008-04-15 13:16:34.159728801 +0900
@@ -1008,6 +1008,25 @@ static struct nf_hook_ops ip_vs_forward_
 	.owner		= THIS_MODULE,
 	.pf		= PF_INET,
 	.hooknum        = NF_IP_PRE_ROUTING,
+	.priority       = NF_IP_PRI_FIRST + 1,
+};
+
+/* After packet filtering, change source only for VS/NAT */
+static struct nf_hook_ops ip_vs_local_out_ops = {
+	.hook		= ip_vs_out,
+	.owner		= THIS_MODULE,
+	.pf		= PF_INET,
+	.hooknum        = NF_IP_LOCAL_OUT,
+	.priority       = NF_IP_PRI_FIRST,
+};
+
+/* After packet filtering (but before ip_vs_out_icmp), catch icmp
+   destined for 0.0.0.0/0, which is for incoming IPVS connections */
+static struct nf_hook_ops ip_vs_local_icmp_ops = {
+	.hook		= ip_vs_forward_icmp,
+	.owner		= THIS_MODULE,
+	.pf		= PF_INET,
+	.hooknum        = NF_IP_LOCAL_OUT,
 	.priority       = NF_IP_PRI_FIRST,
 };
 
@@ -1050,15 +1069,32 @@ static int __init ip_vs_init(void)
 		IP_VS_ERR("can't register out hook.\n");
 		goto cleanup_inops;
 	}
+
 	ret = nf_register_hook(&ip_vs_forward_icmp_ops);
 	if (ret < 0) {
 		IP_VS_ERR("can't register forward_icmp hook.\n");
 		goto cleanup_outops;
 	}
 
+	ret = nf_register_hook(&ip_vs_local_out_ops);
+	if (ret < 0) {
+		IP_VS_ERR("can't register local out hook.\n");
+		goto cleanup_icmpops;
+	}
+
+	ret = nf_register_hook(&ip_vs_local_icmp_ops);
+	if (ret < 0) {
+		IP_VS_ERR("can't register local icmp hook.\n");
+		goto cleanup_localout;
+	}
+
 	IP_VS_INFO("ipvs loaded.\n");
 	return ret;
 
+  cleanup_localout:
+    nf_unregister_hook(&ip_vs_local_out_ops);
+  cleanup_icmpops:
+    nf_unregister_hook(&ip_vs_forward_icmp_ops);
   cleanup_outops:
 	nf_unregister_hook(&ip_vs_out_ops);
   cleanup_inops:
@@ -1076,6 +1112,8 @@ static int __init ip_vs_init(void)
 
 static void __exit ip_vs_cleanup(void)
 {
+	nf_unregister_hook(&ip_vs_local_icmp_ops);
+	nf_unregister_hook(&ip_vs_local_out_ops);
 	nf_unregister_hook(&ip_vs_forward_icmp_ops);
 	nf_unregister_hook(&ip_vs_out_ops);
 	nf_unregister_hook(&ip_vs_in_ops);

--Boundary-00=_K6EBIN8oy63oHFQ--
