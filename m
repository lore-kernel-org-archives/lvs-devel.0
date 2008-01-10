From: Raphael Vallazza <raphael@endian.com>
Subject: [PATCH] Transparent proxy support for LVS with localnode and realservers (WORKING)
Date: Thu, 10 Jan 2008 11:39:19 +0100
Message-ID: <C704FCFC-455C-4CFC-AB8C-51604D3CF844@endian.com>
Mime-Version: 1.0 (Apple Message framework v915)
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"; delsp="yes"
To: LVS Devel <lvs-devel@vger.kernel.org>

Hello,

i wrote a very simple patch for ipvs that enables a kernel config  
option that allows to choose where IPVS intercepts incoming  
connections. These are the options:
- LOCAL_IN (default: works as usual)
- PRE_ROUTING (puts LVS input right after the mangle PREROUTING and  
before the nat PREROUTING chain)

By selecting the PRE_ROUTING option transparent proxying is possible  
(i've tried in DR and NAT mode), because packets are sent to real  
servers before NAT, this way the realserver can do a DNAT/REDIRECT  
etc. to send the packets to the proxy application. This also works for  
the localnode, because packets go thru the PREROUTING after LVS, and  
ther could be DNATed/REDIRECTed.

I tried it on some test boxes and it seems to work pretty well, i'll  
do some stress testing in the next few days. I could send you a setup  
example if you like...

The patch if for 2.6.22, but also applies on 2.6.24.

What's your opinion? :)

Regards,
Raphael Vallazza

-- 
:: e n d i a n
:: open source - open minds
:: http://www.endian.com  :: raphael (AT) endian.com

##### PATCH ######

diff -ruN linux-2.6.22.orig/net/ipv4/ipvs/ip_vs_core.c linux-2.6.22/ 
net/ipv4/ipvs/ip_vs_core.c
--- linux-2.6.22.orig/net/ipv4/ipvs/ip_vs_core.c	2007-07-09  
01:32:17.000000000 +0200
+++ linux-2.6.22/net/ipv4/ipvs/ip_vs_core.c	2008-01-09  
14:50:33.000000000 +0100
@@ -1069,6 +1069,7 @@
  }


+#ifdef CONFIG_IP_VS_INPUT_LOCAL_IN
  /* After packet filtering, forward packet through VS/DR, VS/TUN,
     or VS/NAT(change destination), so that filtering rules can be
     applied to IPVS. */
@@ -1079,6 +1080,21 @@
  	.hooknum        = NF_IP_LOCAL_IN,
  	.priority       = 100,
  };
+#endif
+
+#ifdef CONFIG_IP_VS_INPUT_PRE_ROUTING
+/* Intercept incoming connections before DNAT and input filtering
+   has been applied, this enables ransparent proxying on realnodes
+   and localnode. Hook right after MANGLE and before NAT_DST.
+*/
+static struct nf_hook_ops ip_vs_in_ops = {
+	.hook		= ip_vs_in,
+	.owner		= THIS_MODULE,
+	.pf		= PF_INET,
+	.hooknum        = NF_IP_PRE_ROUTING,
+	.priority       = NF_IP_PRI_NAT_DST - 1,
+};
+#endif

  /* After packet filtering, change source only for VS/NAT */
  static struct nf_hook_ops ip_vs_out_ops = {
diff -ruN linux-2.6.22.orig/net/ipv4/ipvs/Kconfig linux-2.6.22/net/ 
ipv4/ipvs/Kconfig
--- linux-2.6.22.orig/net/ipv4/ipvs/Kconfig	2007-07-09  
01:32:17.000000000 +0200
+++ linux-2.6.22/net/ipv4/ipvs/Kconfig	2008-01-09 14:40:27.000000000  
+0100
@@ -24,6 +24,34 @@

  if IP_VS

+choice
+        prompt "IPVS incoming connection interception"
+        default IP_VS_INPUT_LOCAL_IN
+        help
+	  This option sets the position at which IPVS intercepts incoming
+	  connections from Netfilter. If in doubt select 'LOCAL_IN'.
+
+config  IP_VS_INPUT_LOCAL_IN
+	bool "LOCAL_IN"
+	---help---
+          After packet filtering, forward packet through VS/DR, VS/TUN,
+          or VS/NAT(change destination), so that filtering rules can be
+	  applied to IPVS
+
+config  IP_VS_INPUT_PRE_ROUTING
+	bool "PRE_ROUTING"
+	---help---
+	  Intercept incoming connections before DNAT and input filtering
+	  has been applied, this enables ransparent proxying on realnodes
+	  and localnode.
+	
+	  Incoming connections are intercepted right after the mangle
+	  PREROUTING table and before the nat PREROUTING table. This way
+	  packets are intercepted without any modifications by netfilter
+	  and NAT (if required) can be done on the realservers.
+
+endchoice	
+	
  config	IP_VS_DEBUG
  	bool "IP virtual server debugging"
  	---help---

