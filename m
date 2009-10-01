From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 1/2] net/netfilter/ipvs: Move #define KMSG_COMPONENT to
 Makefile
Date: Thu, 1 Oct 2009 10:27:48 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0910011016480.24025@obet.zrqbmnf.qr>
References: <cover.1254349374.git.joe@perches.com>  <0026bcf5aad9ae5036e68fc2dcda9c778d30dc47.1254349375.git.joe@perches.com>  <alpine.LSU.2.00.0910010042540.782@obet.zrqbmnf.qr>  <1254352160.2960.119.camel@Joe-Laptop.home>  <alpine.LSU.2.00.0910010219100.7559@obet.zrqbmnf.qr>
 <1254358235.2960.145.camel@Joe-Laptop.home>
Mime-Version: 1.0
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932150AbZJAI1s@vger.kernel.org>
In-Reply-To: <1254358235.2960.145.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Netfilter Developer Mailing List <netfilter-devel@vger.kernel.org>, netdev@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lvs-devel@vger.kernel.org


On Thursday 2009-10-01 02:50, Joe Perches wrote:
>On Thu, 2009-10-01 at 02:31 +0200, Jan Engelhardt wrote:
>> Well I personally prefer the #include instead of hiding such in 
>> Makefiles. You know, when newcomers could start doing `grep 
>> KMSG_COMPONENT *.[ch]`. Perhaps GCC's -include flag in a Makefile
>> to avoid #includes in .c files?
>
>I imagine an eventual goal of standardizing the default
>pr_fmt define in kernel.h to
>
>	#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
>
>so that all pr_<level> calls get this unless otherwise
>specified.

I like that approach. Saves me adding that line to .c
files repeatedly.

>Or perhaps better, to get rid of pr_fmt(fmt) altogether and
>have printk emit the filename/modulename, function and/or
>code offset by using something like %pS after the level.

I object to that. You would be spamming the dmesg ring buffer
with all that info, plus

filename: you would have to keep filename strings in the kernel.
Surely I do not find that thrilling when there are ~18000
non-arch .[ch] files whose pathnames amount to 542K.
Same goes similar for functions.

modulename: obj-y files would only get "<built-in>" or something
for KBUILD_MODNAME. Printing that to dmesg is not too useful.

I would rather keep plain printk as-is.
