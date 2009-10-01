From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/2] net/netfilter/ipvs: Move #define KMSG_COMPONENT to
 Makefile
Date: Thu, 01 Oct 2009 08:55:57 -0700
Message-ID: <1254412557.1799.68.camel@Joe-Laptop.home>
References: <cover.1254349374.git.joe@perches.com>
	 <0026bcf5aad9ae5036e68fc2dcda9c778d30dc47.1254349375.git.joe@perches.com>
	 <alpine.LSU.2.00.0910010042540.782@obet.zrqbmnf.qr>
	 <1254352160.2960.119.camel@Joe-Laptop.home>
	 <alpine.LSU.2.00.0910010219100.7559@obet.zrqbmnf.qr>
	 <1254358235.2960.145.camel@Joe-Laptop.home>
	 <alpine.LSU.2.00.0910011016480.24025@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.00.0910011016480.24025@obet.zrqbmnf.qr>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Jan Engelhardt <jengelh@medozas.de>
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Netfilter Developer Mailing List <netfilter-devel@vger.kernel.org>, netdev@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lvs-devel@vger.kernel.org

On Thu, 2009-10-01 at 10:27 +0200, Jan Engelhardt wrote:
> On Thursday 2009-10-01 02:50, Joe Perches wrote:
> >I imagine an eventual goal of standardizing the default
> >pr_fmt define in kernel.h to
> >	#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> >so that all pr_<level> calls get this unless otherwise
> >specified.
> 
> I like that approach. Saves me adding that line to .c
> files repeatedly.

There aren't too many existing pr_<level> calls so
that this couldn't be considered.

Files with pr_<level> without pr_fmt:

$ grep -rPl --include=*.[ch] \
	"\bpr_(info|warning|err|alert|notice|crit)\b" * |
  xargs grep -Lw "pr_fmt" | wc -l
569

Uses of pr_<level> without pr_fmt:

$ grep -rPl --include=*.[ch] \
	"\bpr_(info|warning|err|alert|notice|crit)\b" * |
  xargs grep -Lw "pr_fmt" |
  xargs grep -P "\bpr_(info|warning|err|alert|notice|crit)\b" |
  wc -l
2885

If you look at the pr_<levels>, it's nearly
a mechanical thing to strip the ones with
some sort of prefix and add a #define pr_fmt
to replace them.  Most all of them without
prefixes might benefit by using a standardized
#define pr_fmt(etc...) in kernel.h, so the
actual count of changes isn't that high.

> >Or perhaps better, to get rid of pr_fmt(fmt) altogether and
> >have printk emit the filename/modulename, function and/or
> >code offset by using something like %pS after the level.
> I object to that. You would be spamming the dmesg ring buffer
> with all that info

Of course printks could not change, there are way too
many of those to consider doing that globally.

But the printks emitted by pr_<level> might change.
Maybe by setting a bit in the string "<level>" or by
some other mechanism.

> filename: you would have to keep filename strings in the kernel.
> Surely I do not find that thrilling when there are ~18000
> non-arch .[ch] files whose pathnames amount to 542K.
> Same goes similar for functions.
> 
> modulename: obj-y files would only get "<built-in>" or something
> for KBUILD_MODNAME. Printing that to dmesg is not too useful.

The removal of KBUILD_MODNAME could only be done
for builds with CONFIG_KALLSYMS or
CONFIG_DYNAMIC_DEBUG.

It might also be possible to use something like
CONFIG_DYNAMIC_DEBUG to control which modules get
MODNAME, __func__, __LINE__ or offset emitted
by the pr_<level> via some boot/module/sysconf
or FTRACE like parameters.

cheers, Joe

