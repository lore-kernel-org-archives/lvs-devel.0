From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] Transparent proxy support for LVS with localnode and
	realservers (WORKING)
Date: Fri, 11 Jan 2008 13:14:28 +0900
Message-ID: <20080111041426.GF13135@verge.net.au>
References: <C704FCFC-455C-4CFC-AB8C-51604D3CF844@endian.com> <Pine.LNX.4.64.0801100432180.28592@wm7d.net> <1C7F5BEB-8169-40DA-B7A2-2B4BB85B6FFD@endian.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1C7F5BEB-8169-40DA-B7A2-2B4BB85B6FFD@endian.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Raphael Vallazza <raphael@endian.com>
Cc: LVS Devel <lvs-devel@vger.kernel.org>

On Thu, Jan 10, 2008 at 03:50:37PM +0100, Raphael Vallazza wrote:
> Hello,
>
>>> i wrote a very simple patch for ipvs that enables a kernel config  
>>> option that allows to choose where IPVS intercepts incoming  
>>> connections. These are the options:
>>> - LOCAL_IN (default: works as usual)
>>> - PRE_ROUTING (puts LVS input right after the mangle PREROUTING and  
>>> before the nat PREROUTING chain)
>>
>> neat. I thought it was hard enough to move that it wouldn't be just an 
>> option :-)
>
> Hehe, yes, it was pretty easy ;)

First up, thanks for the patch. Its clean and looks obviously correct.
I think we should aim to get this in 2.4.25 (I think its a bit late for
2.4.24, but perhaps it can go in there).

>> what we'd really like is ipvs hooked into the FORWARD chain. Can you  
>> do this too?
>
> To be honest i don't understand the reason for hooking LVS into the  
> FORWARD chain, because this way it would not get the LOCAL_IN traffic  
> and at the same time it would have the same NAT problem as with the  
> LOCAL_IN hook. Maybe i'm missing something, but it seems that PREROUTING 
> is the best point for LVS to act like a real router, because it gets 
> packets that haven't been NATed yet.
> The only negative thing is that traffic can't be filtered in a regular  
> way, but using fwmark and the mangle table the user can select the  
> traffic that has to be handled by LVS.
>
> If you like i can also add this option, but i'm not sure if it's really 
> useful :)

I had always thought in terms of FORWARD being a good place as
a) I'm not particularly interested in LVS handling LOCAL_IN traffic,
even though that it currently all it can do and b) I hadn't considered
NAT.

But you do make some good points there, and I'm begining to think
that PREROUTING is correct.

The main thing that I would like to see is that LVS can load-balance
traffic without needing the VIP to be a local address. PREROUTING seems
to allow this, so it does look like a good idea to me.

>>> I tried it on some test boxes and it seems to work pretty well, i'll 
>>> do some stress testing in the next few days. I could send you a setup 
>>> example if you like...

Great.


My other techincal question was do you think it would be
possible/desirable to make it a run-time option. I'm particularly
thinking of people with distro kernels and an adversion to recompiling,
as is the case for enterprise-types.


Specifically about the patch. Below is a rediffed version that addresses
a few cosmetic problems.

* Rediffed for net-2.6.25, available from git.kernel.org.
  This or its cousin net-2.6 are the trees that the patch is likely to
  go through to get into the kernel.

  - As a breif explanation. net-2.6.X is for new code. net-2.6 is for
    bug features and orthoganal features. Your patch could probably
    go into either tree.

* Whitespace

  - There seem to be a few places where 8 spaces have been used instead
    of a tab
  - There seems to be a few places where a line ends in trailing
    whitespace
  - And there were a few places where random leading whistepace
    was present in the diff context.
  - Perhaps your local version of the code has mangled whitespace,
    perhaps your mail-reader mangled it on sending, or perhaps I did
    something silly at my end.

* The commenting style in LVS often doesn't follow the prefered
  style for linux networking code. I believe that for multi-line
  comments that is:

  /* some
   * text
   */


Could you provide a sign-off line as described in section 5 of
http://linux.yyz.us/patch-format.html ? That would be great.

Lastly, if you run your patches through ./scripts/checkpatch.pl
it will pick up a lot of trivial style errors. Which is good because
its really easy to forget something simple.

Thanks again.

-- 
Horms

Index: net-2.6.25/net/ipv4/ipvs/ip_vs_core.c
===================================================================
--- net-2.6.25.orig/net/ipv4/ipvs/ip_vs_core.c	2008-01-11 12:57:55.000000000 +0900
+++ net-2.6.25/net/ipv4/ipvs/ip_vs_core.c	2008-01-11 13:00:09.000000000 +0900
@@ -1026,6 +1026,7 @@ ip_vs_forward_icmp(unsigned int hooknum,
 
 
 static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
+#ifdef CONFIG_IP_VS_INPUT_LOCAL_IN
 	/* After packet filtering, forward packet through VS/DR, VS/TUN,
 	 * or VS/NAT(change destination), so that filtering rules can be
 	 * applied to IPVS. */
@@ -1036,6 +1037,20 @@ static struct nf_hook_ops ip_vs_ops[] __
 		.hooknum        = NF_INET_LOCAL_IN,
 		.priority       = 100,
 	},
+#endif
+#ifdef CONFIG_IP_VS_INPUT_PRE_ROUTING
+	/* Intercept incoming connections before DNAT and input filtering
+	 * has been applied, this enables ransparent proxying on realnodes
+	 * and localnode. Hook right after MANGLE and before NAT_DST.
+	 */
+	static struct nf_hook_ops ip_vs_in_ops = {
+		.hook		= ip_vs_in,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET,
+		.hooknum	= NF_IP_PRE_ROUTING,
+		.priority	= NF_IP_PRI_NAT_DST - 1,
+	},
+#endif
 	/* After packet filtering, change source only for VS/NAT */
 	{
 		.hook		= ip_vs_out,
Index: net-2.6.25/net/ipv4/ipvs/Kconfig
===================================================================
--- net-2.6.25.orig/net/ipv4/ipvs/Kconfig	2008-01-02 16:46:53.000000000 +0900
+++ net-2.6.25/net/ipv4/ipvs/Kconfig	2008-01-11 13:02:40.000000000 +0900
@@ -24,6 +24,34 @@ menuconfig IP_VS
 
 if IP_VS
 
+choice
+	 prompt "IPVS incoming connection interception"
+	 default IP_VS_INPUT_LOCAL_IN
+	 help
+	  This option sets the position at which IPVS intercepts incoming
+	  connections from Netfilter. If in doubt select 'LOCAL_IN'.
+
+config  IP_VS_INPUT_LOCAL_IN
+	bool "LOCAL_IN"
+	---help---
+	   After packet filtering, forward packet through VS/DR, VS/TUN,
+	   or VS/NAT(change destination), so that filtering rules can be
+	   applied to IPVS
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
