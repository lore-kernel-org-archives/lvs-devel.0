From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] Runtime interception method switch
Date: Fri, 18 Jan 2008 17:52:37 +0900
Message-ID: <20080118085236.GA10957@verge.net.au>
References: <07C2E63F-FDF8-45D5-A20C-0B294C119A5E@endian.com> <Pine.LNX.4.64.0801130758580.32303@wm7d.net> <47C3AD3C-1A21-43AC-B109-EE32E8B4B66A@endian.com> <Pine.LNX.4.64.0801140137470.32097@wm7d.net> <20080115082551.GB8826@verge.net.au> <Pine.LNX.4.64.0801150501120.22826@wm7d.net> <20080116075044.GA19249@verge.net.au> <478DE783.5070203@tis.icnet.pl> <DEEA1E66-8621-43E7-A985-9FD05BE967DE@endian.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <DEEA1E66-8621-43E7-A985-9FD05BE967DE@endian.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: Raphael Vallazza <raphael@endian.com>
Cc: LVS Devel <lvs-devel@vger.kernel.org>

On Wed, Jan 16, 2008 at 12:28:21PM +0100, Raphael Vallazza wrote:
> I've added the documentation for the input_hook switch, and attached  
> both patches for net-2.6.25 (i hope the mailer doesn't mess up things  
> this time :).

Indeed, this seems a lot better :-)


These patches are looking quite good. I only have two minor issues
at this stage.

1) The last fragment of the first patch seems spurious as its
   just a whitespace change. But I'm happy to send it on to DaveM
   and netdev as is.

@@ -1059,7 +1087,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
 		.hooknum        = NF_INET_POST_ROUTING,
-		.priority       = NF_IP_PRI_NAT_SRC-1,
+		.priority       = NF_IP_PRI_NAT_SRC - 1,
 	},
 };

2) I am still getting errors with the second patch which
   I can resolve by moving the hook definitions to below
   ip_vs_register_hooks() and ip_vs_unregister_hooks()

   The gcc version and errors are bellow.
   As is a patch to do the re-ordering - that is all it does.

   If you are happy with this change I can fold it into your
   patch and send it on to DaveM and netdev, or you can send me
   a fresh patch if you would prefer. I do belive this error is real,
   perhaps your gcc is a different (older?) version and is ignoring
   this?

# gcc --version
i686-unknown-linux-gnu-gcc (GCC) 3.4.5
Copyright (C) 2004 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is
NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE.

# make
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  CALL    scripts/checksyscalls.sh
  CHK     include/linux/compile.h
  CC      net/ipv4/ipvs/ip_vs_core.o
net/ipv4/ipvs/ip_vs_core.c: In function `ip_vs_register_hooks':
net/ipv4/ipvs/ip_vs_core.c:1043: error: `ip_vs_ops_local_in' undeclared (first use in this function)
net/ipv4/ipvs/ip_vs_core.c:1043: error: (Each undeclared identifier is reported only once
net/ipv4/ipvs/ip_vs_core.c:1043: error: for each function it appears in.)
net/ipv4/ipvs/ip_vs_core.c:1044: warning: type defaults to `int' in declaration of `type name'
net/ipv4/ipvs/ip_vs_core.c:1044: warning: type defaults to `int' in declaration of `type name'
net/ipv4/ipvs/ip_vs_core.c:1044: error: size of array `type name' is negative
net/ipv4/ipvs/ip_vs_core.c:1048: error: `ip_vs_ops_forward' undeclared (first use in this function)
net/ipv4/ipvs/ip_vs_core.c:1049: warning: type defaults to `int' in declaration of `type name'
net/ipv4/ipvs/ip_vs_core.c:1049: warning: type defaults to `int' in declaration of `type name'
net/ipv4/ipvs/ip_vs_core.c:1049: error: size of array `type name' is negative
net/ipv4/ipvs/ip_vs_core.c:1053: error: `ip_vs_ops_pre_routing' undeclared (first use in this function)
net/ipv4/ipvs/ip_vs_core.c:1054: warning: type defaults to `int' in declaration of `type name'
net/ipv4/ipvs/ip_vs_core.c:1054: warning: type defaults to `int' in declaration of `type name'
net/ipv4/ipvs/ip_vs_core.c:1054: error: size of array `type name' is negative
net/ipv4/ipvs/ip_vs_core.c:1066: error: `ip_vs_ops_generic' undeclared (first use in this function)
net/ipv4/ipvs/ip_vs_core.c:1067: warning: type defaults to `int' in declaration of `type name'
net/ipv4/ipvs/ip_vs_core.c:1067: warning: type defaults to `int' in declaration of `type name'
net/ipv4/ipvs/ip_vs_core.c:1067: error: size of array `type name' is negative
net/ipv4/ipvs/ip_vs_core.c: In function `ip_vs_unregister_hooks':
net/ipv4/ipvs/ip_vs_core.c:1091: error: `ip_vs_ops_local_in' undeclared (first use in this function)
net/ipv4/ipvs/ip_vs_core.c:1092: warning: type defaults to `int' in declaration of `type name'
net/ipv4/ipvs/ip_vs_core.c:1092: warning: type defaults to `int' in declaration of `type name'
net/ipv4/ipvs/ip_vs_core.c:1092: error: size of array `type name' is negative
net/ipv4/ipvs/ip_vs_core.c:1095: error: `ip_vs_ops_forward' undeclared (first use in this function)
net/ipv4/ipvs/ip_vs_core.c:1096: warning: type defaults to `int' in declaration of `type name'
net/ipv4/ipvs/ip_vs_core.c:1096: warning: type defaults to `int' in declaration of `type name'
net/ipv4/ipvs/ip_vs_core.c:1096: error: size of array `type name' is negative
net/ipv4/ipvs/ip_vs_core.c:1099: error: `ip_vs_ops_pre_routing' undeclared (first use in this function)
net/ipv4/ipvs/ip_vs_core.c:1100: warning: type defaults to `int' in declaration of `type name'
net/ipv4/ipvs/ip_vs_core.c:1100: warning: type defaults to `int' in declaration of `type name'
net/ipv4/ipvs/ip_vs_core.c:1100: error: size of array `type name' is negative
net/ipv4/ipvs/ip_vs_core.c:1107: error: `ip_vs_ops_generic' undeclared (first use in this function)
net/ipv4/ipvs/ip_vs_core.c:1107: warning: type defaults to `int' in declaration of `type name'
net/ipv4/ipvs/ip_vs_core.c:1107: warning: type defaults to `int' in declaration of `type name'
net/ipv4/ipvs/ip_vs_core.c:1107: error: size of array `type name' is negative
net/ipv4/ipvs/ip_vs_core.c: At top level:
net/ipv4/ipvs/ip_vs_core.c:1117: warning: 'ip_vs_ops_local_in' defined but not used
net/ipv4/ipvs/ip_vs_core.c:1131: warning: 'ip_vs_ops_forward' defined but not used
net/ipv4/ipvs/ip_vs_core.c:1152: warning: 'ip_vs_ops_pre_routing' defined but not used
net/ipv4/ipvs/ip_vs_core.c:1166: warning: 'ip_vs_ops_generic' defined but not used
make[3]: *** [net/ipv4/ipvs/ip_vs_core.o] エラー 1
make[2]: *** [net/ipv4/ipvs] エラー 2
make[1]: *** [net/ipv4] エラー 2
make: *** [net] エラー 2


Index: net-2.6.25/net/ipv4/ipvs/ip_vs_core.c
===================================================================
--- net-2.6.25.orig/net/ipv4/ipvs/ip_vs_core.c	2008-01-18 17:34:23.000000000 +0900
+++ net-2.6.25/net/ipv4/ipvs/ip_vs_core.c	2008-01-18 17:35:07.000000000 +0900
@@ -1024,6 +1024,87 @@ ip_vs_forward_icmp(unsigned int hooknum,
 	return ip_vs_in_icmp(skb, &r, hooknum);
 }
 
+
+/* After packet filtering, forward packet through VS/DR, VS/TUN,
+ * or VS/NAT(change destination), so that filtering rules can be
+ * applied to IPVS. */
+static struct nf_hook_ops ip_vs_ops_local_in[] __read_mostly = {
+	{
+		.hook		= ip_vs_in,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET,
+		.hooknum        = NF_INET_LOCAL_IN,
+		.priority       = 100,
+	},
+};
+
+/* Intercept incoming connections after they have traveled through
+ * the INPUT or the FORWARD table. It has the same functionlity of
+ * the "INPUT method", but also processes connections that are
+ * routed through the director, supporting VIP-less setups. */
+static struct nf_hook_ops ip_vs_ops_forward[] __read_mostly = {
+	{
+		.hook		= ip_vs_in,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET,
+		.hooknum        = NF_INET_LOCAL_IN,
+		.priority       = 100,
+	},
+	{
+		.hook		= ip_vs_in,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET,
+		.hooknum        = NF_INET_FORWARD,
+		.priority       = 98,
+	},
+};
+
+/* Intercept incoming connections before DNAT and input filtering
+ * has been applied, this enables ransparent proxying on realnodes
+ * and localnode. Hook right after MANGLE and before NAT_DST.
+ */
+static struct nf_hook_ops ip_vs_ops_pre_routing[] __read_mostly = {
+	{
+		.hook           = ip_vs_in,
+		.owner          = THIS_MODULE,
+		.pf             = PF_INET,
+		.hooknum        = NF_INET_PRE_ROUTING,
+		.priority       = NF_IP_PRI_NAT_DST - 1,
+	},
+};
+
+/*
+ * Generic Netfilter hooks required for all the input methods
+ */
+
+static struct nf_hook_ops ip_vs_ops_generic[] __read_mostly = {
+	/* After packet filtering, change source only for VS/NAT */
+	{
+		.hook		= ip_vs_out,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET,
+		.hooknum        = NF_INET_FORWARD,
+		.priority       = 100,
+	},
+	/* After packet filtering (but before ip_vs_out_icmp), catch icmp
+	 * destined for 0.0.0.0/0, which is for incoming IPVS connections */
+	{
+		.hook		= ip_vs_forward_icmp,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET,
+		.hooknum        = NF_INET_FORWARD,
+		.priority       = 99,
+	},
+	/* Before the netfilter connection tracking, exit from POST_ROUTING */
+	{
+		.hook		= ip_vs_post_routing,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET,
+		.hooknum        = NF_INET_POST_ROUTING,
+		.priority       = NF_IP_PRI_NAT_SRC - 1,
+	},
+};
+
 /*
  * Register netfilter hook based on input_hook type
  */
@@ -1111,87 +1192,6 @@ int ip_vs_unregister_hooks(int input_hoo
 }
 
 
-/* After packet filtering, forward packet through VS/DR, VS/TUN,
- * or VS/NAT(change destination), so that filtering rules can be
- * applied to IPVS. */
-static struct nf_hook_ops ip_vs_ops_local_in[] __read_mostly = {
-	{
-		.hook		= ip_vs_in,
-		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
-		.hooknum        = NF_INET_LOCAL_IN,
-		.priority       = 100,
-	},
-};
-
-/* Intercept incoming connections after they have traveled through
- * the INPUT or the FORWARD table. It has the same functionlity of
- * the "INPUT method", but also processes connections that are
- * routed through the director, supporting VIP-less setups. */
-static struct nf_hook_ops ip_vs_ops_forward[] __read_mostly = {
-	{
-		.hook		= ip_vs_in,
-		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
-		.hooknum        = NF_INET_LOCAL_IN,
-		.priority       = 100,
-	},
-	{
-		.hook		= ip_vs_in,
-		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
-		.hooknum        = NF_INET_FORWARD,
-		.priority       = 98,
-	},
-};
-
-/* Intercept incoming connections before DNAT and input filtering
- * has been applied, this enables ransparent proxying on realnodes
- * and localnode. Hook right after MANGLE and before NAT_DST.
- */
-static struct nf_hook_ops ip_vs_ops_pre_routing[] __read_mostly = {
-	{
-		.hook           = ip_vs_in,
-		.owner          = THIS_MODULE,
-		.pf             = PF_INET,
-		.hooknum        = NF_INET_PRE_ROUTING,
-		.priority       = NF_IP_PRI_NAT_DST - 1,
-	},
-};
-
-/*
- * Generic Netfilter hooks required for all the input methods
- */
-
-static struct nf_hook_ops ip_vs_ops_generic[] __read_mostly = {
-	/* After packet filtering, change source only for VS/NAT */
-	{
-		.hook		= ip_vs_out,
-		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
-		.hooknum        = NF_INET_FORWARD,
-		.priority       = 100,
-	},
-	/* After packet filtering (but before ip_vs_out_icmp), catch icmp
-	 * destined for 0.0.0.0/0, which is for incoming IPVS connections */
-	{
-		.hook		= ip_vs_forward_icmp,
-		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
-		.hooknum        = NF_INET_FORWARD,
-		.priority       = 99,
-	},
-	/* Before the netfilter connection tracking, exit from POST_ROUTING */
-	{
-		.hook		= ip_vs_post_routing,
-		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
-		.hooknum        = NF_INET_POST_ROUTING,
-		.priority       = NF_IP_PRI_NAT_SRC - 1,
-	},
-};
-
-
 /*
  *	Initialize IP Virtual Server
  */
