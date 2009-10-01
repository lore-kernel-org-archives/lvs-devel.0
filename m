From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/2] net/netfilter/ipvs: Move #define KMSG_COMPONENT to
 Makefile
Date: Wed, 30 Sep 2009 17:50:35 -0700
Message-ID: <1254358235.2960.145.camel@Joe-Laptop.home>
References: <cover.1254349374.git.joe@perches.com>
	 <0026bcf5aad9ae5036e68fc2dcda9c778d30dc47.1254349375.git.joe@perches.com>
	 <alpine.LSU.2.00.0910010042540.782@obet.zrqbmnf.qr>
	 <1254352160.2960.119.camel@Joe-Laptop.home>
	 <alpine.LSU.2.00.0910010219100.7559@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.00.0910010219100.7559@obet.zrqbmnf.qr>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Jan Engelhardt <jengelh@medozas.de>
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org

On Thu, 2009-10-01 at 02:31 +0200, Jan Engelhardt wrote:
> KBUILD_MODNAME is special in that it is derived from the actual
> source filename.

Kind of.  It's derived from the module name, not the filename.

> Of course you could put #define KBUILD_MODNAME "foo"
> in your source file, but that is like putting changelogs there
> when they belong into the git log.

I agree with that.

> Well I personally prefer the #include instead of hiding such in 
> Makefiles. You know, when newcomers could start doing `grep 
> KMSG_COMPONENT *.[ch]`. Perhaps GCC's -include flag in a Makefile
> to avoid #includes in .c files?

I imagine an eventual goal of standardizing the default
pr_fmt define in kernel.h to

	#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

so that all pr_<level> calls get this unless otherwise
specified.

Or perhaps better, to get rid of pr_fmt(fmt) altogether and
have printk emit the filename/modulename, function and/or
code offset by using something like %pS after the level.

I see the Makefile use, which I don't really like too much
because of the information hiding, as an intermediate step
until that's possible.


