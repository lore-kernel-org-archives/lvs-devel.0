From: Raphael Vallazza <raphael@endian.com>
Subject: Re: [PATCH] Transparent proxy support for LVS with localnode and realservers (WORKING)
Date: Sat, 12 Jan 2008 02:30:26 +0100
Message-ID: <38B8D1A9-BBDB-459A-BF02-E77B852E03B8@endian.com>
References: <C704FCFC-455C-4CFC-AB8C-51604D3CF844@endian.com> <Pine.LNX.4.64.0801100432180.28592@wm7d.net> <1C7F5BEB-8169-40DA-B7A2-2B4BB85B6FFD@endian.com> <20080111041426.GF13135@verge.net.au>
Mime-Version: 1.0 (Apple Message framework v915)
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080111041426.GF13135@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"; delsp="yes"
To: Simon Horman <horms@verge.net.au>
Cc: LVS Devel <lvs-devel@vger.kernel.org>

I've attached patches for net-2.6 (works on 2.6.24-2.6.22) and  
net-2.6.25. I've made some cosmetic/description changes and added a  
"FORWARD" option that puts LVS into INPUT *and* FORWARD hooks, now the  
options are: INPUT, FORWARD and PREROUTING. I think that all of these  
have pros and cons, the user should choose...

> First up, thanks for the patch. Its clean and looks obviously correct.
> I think we should aim to get this in 2.4.25 (I think its a bit late  
> for
> 2.4.24, but perhaps it can go in there).

Thank you for this wonderful project and for giving me a chance to  
contribute :) It would be great if the net-2.6 based patch could be  
incorporated to 2.6.24, because we'd like to use it for the next  
release of Endian Firewall, but it's no problem it's too late ;)

> I had always thought in terms of FORWARD being a good place as
> a) I'm not particularly interested in LVS handling LOCAL_IN traffic,
> even though that it currently all it can do and b) I hadn't considered
> NAT.
>
> But you do make some good points there, and I'm begining to think
> that PREROUTING is correct.
>
> The main thing that I would like to see is that LVS can load-balance
> traffic without needing the VIP to be a local address. PREROUTING  
> seems
> to allow this, so it does look like a good idea to me.

Well, it's hard to say which is "correct" maybe all of them. The  
choice gives the power to the user/administrator and he could choose  
the method that works for a certain setup/environment.

> My other techincal question was do you think it would be
> possible/desirable to make it a run-time option. I'm particularly
> thinking of people with distro kernels and an adversion to  
> recompiling,
> as is the case for enterprise-types.

Absolutely, what do you think about creating a proc file that allows  
to switch at runtime? This way at compile time the user/distribution  
can choose the default behaviour and the user could change it in /proc/ 
sys/net/vs/input_method. If you all agree i'll try to find some to  
implement it.

> * Rediffed for net-2.6.25, available from git.kernel.org.
>  This or its cousin net-2.6 are the trees that the patch is likely to
>  go through to get into the kernel.
>
>  - As a breif explanation. net-2.6.X is for new code. net-2.6 is for
>    bug features and orthoganal features. Your patch could probably
>    go into either tree.

Ok, i've attached patches for both branches :)


> * Whitespace
>
> ...
>
> Could you provide a sign-off line as described in section 5 of
> http://linux.yyz.us/patch-format.html ? That would be great.
>
> Lastly, if you run your patches through ./scripts/checkpatch.pl
> it will pick up a lot of trivial style errors. Which is good because
> its really easy to forget something simple.


Thanks a lot for all your hints, they are very helpful for a kernel  
development newbie like me :) I've followed all your advices, this the  
the patches should be ok (btw, git rules! :)

I've compiled and tested the net-2.6 patch with all the options/ 
methods, it works fine. The net-2.6.25 should also be fine, i'll test  
it throughly tomorrow.

Raphael


##### net-2.6 (2.6.24-2.6.22) #####

[IPVS] Add choice for connection interception method

This patch adds an option to set the position at which IPVS intercepts
incoming connections from Netfilter.

The options are:

1. INPUT (default)
Intercept incoming connections after they have traveled through
the INPUT table, only connections that have the director as
destination address will be processed.

2. FORWARD
Intercept incoming connections after they have traveled through
the INPUT or the FORWARD table. It has the same functionlity of
the "INPUT method", but also processes connections that are
routed through the director, supporting VIP-less setups.

3. PREROUTING
Intercept incoming connections before DNAT and input filtering
has been applied, this enables transparent proxying on realnodes
and localnode.

Signed-off-by: Raphael Vallazza <raphael@endian.com>
---
  net/ipv4/ipvs/Kconfig      |   44 +++++++++++++++++++++++++++++++++++ 
+++
  net/ipv4/ipvs/ip_vs_core.c |   50 +++++++++++++++++++++++++++++++++++ 
+++++---
  2 files changed, 90 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ipvs/Kconfig b/net/ipv4/ipvs/Kconfig
index 09d0c3f..123af4d 100644
--- a/net/ipv4/ipvs/Kconfig
+++ b/net/ipv4/ipvs/Kconfig
@@ -24,6 +24,50 @@ menuconfig IP_VS

  if IP_VS

+choice
+	prompt "IPVS connection interception method"
+	default IP_VS_INPUT_LOCAL_IN
+	help
+	  This option sets the position at which IPVS intercepts incoming
+	  connections from Netfilter. If in doubt select 'LOCAL_IN'.
+
+config IP_VS_INPUT_LOCAL_IN
+	bool "INPUT"
+	---help---
+	  Intercept incoming connections after they have traveled through
+	  the INPUT table, only connections that have the director as
+	  destination address will be processed.
+	
+	  This method allows to apply packet filtering in the INPUT table
+	  before the connection is intercepted by IPVS.
+
+config IP_VS_INPUT_FORWARD
+	bool "FORWARD"
+	---help---
+	  Intercept incoming connections after they have traveled through
+	  the INPUT or the FORWARD table. It has the same functionlity of
+	  the "INPUT method", but also processes connections that are
+	  routed through the director, supporting VIP-less setups.
+	
+	  This method allows to apply packet filtering in the INPUT or
+	  FORWARD table, before the connection is intercepted by IPVS.
+
+config IP_VS_INPUT_PRE_ROUTING
+	bool "PREROUTING"
+	---help---
+	  Intercept incoming connections before DNAT and input filtering
+	  has been applied, this allows transparent proxying on realnodes
+	  and localnode. Incoming connections are intercepted right after
+	  the mangle PREROUTING table and before the nat PREROUTING table,
+	  supporting VIP-less setups.
+	
+	  WARNING: This method doesn't apply any packet filtering before
+	  packets are intercepted by IPVS. To filter the connections that
+	  should be intercepted, you have to mark the traffic in the
+	  mangle PREROUTING table.
+
+endchoice
+
  config	IP_VS_DEBUG
  	bool "IP virtual server debugging"
  	---help---
diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 8fba202..e554ec0 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -1024,10 +1024,10 @@ ip_vs_forward_icmp(unsigned int hooknum,  
struct sk_buff *skb,
  	return ip_vs_in_icmp(skb, &r, hooknum);
  }

-
+#if defined(CONFIG_IP_VS_INPUT_LOCAL_IN) ||  
defined(CONFIG_IP_VS_INPUT_FORWARD)
  /* After packet filtering, forward packet through VS/DR, VS/TUN,
-   or VS/NAT(change destination), so that filtering rules can be
-   applied to IPVS. */
+ * or VS/NAT(change destination), so that filtering rules can be
+ * applied to IPVS. */
  static struct nf_hook_ops ip_vs_in_ops = {
  	.hook		= ip_vs_in,
  	.owner		= THIS_MODULE,
@@ -1035,6 +1035,33 @@ static struct nf_hook_ops ip_vs_in_ops = {
  	.hooknum        = NF_IP_LOCAL_IN,
  	.priority       = 100,
  };
+#endif
+#ifdef CONFIG_IP_VS_INPUT_FORWARD
+/* Intercept incoming connections after they have traveled through
+ * the INPUT or the FORWARD table. It has the same functionlity of
+ * the "INPUT method", but also processes connections that are
+ * routed through the director, supporting VIP-less setups. */
+static struct nf_hook_ops ip_vs_forward_ops = {
+	.hook		= ip_vs_in,
+	.owner		= THIS_MODULE,
+	.pf		= PF_INET,
+	.hooknum        = NF_IP_FORWARD,
+	.priority       = 98,
+};
+#endif
+#ifdef CONFIG_IP_VS_INPUT_PRE_ROUTING
+/* Intercept incoming connections before DNAT and input filtering
+ * has been applied, this enables ransparent proxying on realnodes
+ * and localnode. Hook right after MANGLE and before NAT_DST.
+ */
+static struct nf_hook_ops ip_vs_in_ops = {
+	.hook           = ip_vs_in,
+	.owner          = THIS_MODULE,
+	.pf             = PF_INET,
+	.hooknum        = NF_IP_PRE_ROUTING,
+	.priority       = NF_IP_PRI_NAT_DST - 1,
+};
+#endif

  /* After packet filtering, change source only for VS/NAT */
  static struct nf_hook_ops ip_vs_out_ops = {
@@ -1061,7 +1088,7 @@ static struct nf_hook_ops ip_vs_post_routing_ops  
= {
  	.owner		= THIS_MODULE,
  	.pf		= PF_INET,
  	.hooknum        = NF_IP_POST_ROUTING,
-	.priority       = NF_IP_PRI_NAT_SRC-1,
+	.priority       = NF_IP_PRI_NAT_SRC - 1,
  };


@@ -1114,9 +1141,21 @@ static int __init ip_vs_init(void)
  		goto cleanup_postroutingops;
  	}

+#ifdef CONFIG_IP_VS_INPUT_FORWARD
+	ret = nf_register_hook(&ip_vs_forward_ops);
+	if (ret < 0) {
+		IP_VS_ERR("can't register fwd hook.\n");
+		goto cleanup_forwardicmpops;
+	}
+#endif
+
  	IP_VS_INFO("ipvs loaded.\n");
  	return ret;

+#ifdef CONFIG_IP_VS_INPUT_FORWARD
+cleanup_forwardicmpops:
+	nf_unregister_hook(&ip_vs_forward_icmp_ops);
+#endif
    cleanup_postroutingops:
  	nf_unregister_hook(&ip_vs_post_routing_ops);
    cleanup_outops:
@@ -1140,6 +1179,9 @@ static void __exit ip_vs_cleanup(void)
  	nf_unregister_hook(&ip_vs_post_routing_ops);
  	nf_unregister_hook(&ip_vs_out_ops);
  	nf_unregister_hook(&ip_vs_in_ops);
+#ifdef CONFIG_IP_VS_INPUT_FORWARD
+	nf_unregister_hook(&ip_vs_forward_ops);
+#endif
  	ip_vs_conn_cleanup();
  	ip_vs_app_cleanup();
  	ip_vs_protocol_cleanup();
-- 
1.5.3.7




##### net-2.6.25  #####

[IPVS] Add choice for connection interception method

This patch adds an option to set the position at which IPVS intercepts
incoming connections from Netfilter.

The options are:

1. INPUT (default)
Intercept incoming connections after they have traveled through
the INPUT table, only connections that have the director as
destination address will be processed.

2. FORWARD
Intercept incoming connections after they have traveled through
the INPUT or the FORWARD table. It has the same functionlity of
the "INPUT method", but also processes connections that are
routed through the director, supporting VIP-less setups.

3. PREROUTING
Intercept incoming connections before DNAT and input filtering
has been applied, this enables transparent proxying on realnodes
and localnode.

Signed-off-by: Raphael Vallazza <raphael@endian.com>
---
  net/ipv4/ipvs/Kconfig      |   44 +++++++++++++++++++++++++++++++++++ 
+++++++++
  net/ipv4/ipvs/ip_vs_core.c |   30 +++++++++++++++++++++++++++++-
  2 files changed, 73 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ipvs/Kconfig b/net/ipv4/ipvs/Kconfig
index 09d0c3f..123af4d 100644
--- a/net/ipv4/ipvs/Kconfig
+++ b/net/ipv4/ipvs/Kconfig
@@ -24,6 +24,50 @@ menuconfig IP_VS

  if IP_VS

+choice
+	prompt "IPVS connection interception method"
+	default IP_VS_INPUT_LOCAL_IN
+	help
+	  This option sets the position at which IPVS intercepts incoming
+	  connections from Netfilter. If in doubt select 'LOCAL_IN'.
+
+config IP_VS_INPUT_LOCAL_IN
+	bool "INPUT"
+	---help---
+	  Intercept incoming connections after they have traveled through
+	  the INPUT table, only connections that have the director as
+	  destination address will be processed.
+	
+	  This method allows to apply packet filtering in the INPUT table
+	  before the connection is intercepted by IPVS.
+
+config IP_VS_INPUT_FORWARD
+	bool "FORWARD"
+	---help---
+	  Intercept incoming connections after they have traveled through
+	  the INPUT or the FORWARD table. It has the same functionlity of
+	  the "INPUT method", but also processes connections that are
+	  routed through the director, supporting VIP-less setups.
+	
+	  This method allows to apply packet filtering in the INPUT or
+	  FORWARD table, before the connection is intercepted by IPVS.
+
+config IP_VS_INPUT_PRE_ROUTING
+	bool "PREROUTING"
+	---help---
+	  Intercept incoming connections before DNAT and input filtering
+	  has been applied, this allows transparent proxying on realnodes
+	  and localnode. Incoming connections are intercepted right after
+	  the mangle PREROUTING table and before the nat PREROUTING table,
+	  supporting VIP-less setups.
+	
+	  WARNING: This method doesn't apply any packet filtering before
+	  packets are intercepted by IPVS. To filter the connections that
+	  should be intercepted, you have to mark the traffic in the
+	  mangle PREROUTING table.
+
+endchoice
+
  config	IP_VS_DEBUG
  	bool "IP virtual server debugging"
  	---help---
diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 963981a..0da4ef6 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -1026,6 +1026,7 @@ ip_vs_forward_icmp(unsigned int hooknum, struct  
sk_buff *skb,


  static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
+#if defined(CONFIG_IP_VS_INPUT_LOCAL_IN) ||  
defined(CONFIG_IP_VS_INPUT_FORWARD)
  	/* After packet filtering, forward packet through VS/DR, VS/TUN,
  	 * or VS/NAT(change destination), so that filtering rules can be
  	 * applied to IPVS. */
@@ -1036,6 +1037,33 @@ static struct nf_hook_ops ip_vs_ops[]  
__read_mostly = {
  		.hooknum        = NF_INET_LOCAL_IN,
  		.priority       = 100,
  	},
+#endif
+#ifdef CONFIG_IP_VS_INPUT_FORWARD
+	/* Intercept incoming connections after they have traveled through
+	 * the INPUT or the FORWARD table. It has the same functionlity of
+	 * the "INPUT method", but also processes connections that are
+	 * routed through the director, supporting VIP-less setups. */
+	{
+		.hook		= ip_vs_in,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET,
+		.hooknum        = NF_INET_FORWARD,
+		.priority       = 98,
+	},
+#endif
+#ifdef CONFIG_IP_VS_INPUT_PRE_ROUTING
+	/* Intercept incoming connections before DNAT and input filtering
+	 * has been applied, this enables ransparent proxying on realnodes
+	 * and localnode. Hook right after MANGLE and before NAT_DST.
+	 */
+	{
+		.hook           = ip_vs_in,
+		.owner          = THIS_MODULE,
+		.pf             = PF_INET,
+		.hooknum        = NF_INET_PRE_ROUTING,
+		.priority       = NF_IP_PRI_NAT_DST - 1,
+	},
+#endif
  	/* After packet filtering, change source only for VS/NAT */
  	{
  		.hook		= ip_vs_out,
@@ -1059,7 +1087,7 @@ static struct nf_hook_ops ip_vs_ops[]  
__read_mostly = {
  		.owner		= THIS_MODULE,
  		.pf		= PF_INET,
  		.hooknum        = NF_INET_POST_ROUTING,
-		.priority       = NF_IP_PRI_NAT_SRC-1,
+		.priority       = NF_IP_PRI_NAT_SRC - 1,
  	},
  };

-- 
1.5.3.7


