From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 1/2] net/netfilter/ipvs: Move #define KMSG_COMPONENT to
 Makefile
Date: Thu, 1 Oct 2009 02:31:24 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0910010219100.7559@obet.zrqbmnf.qr>
References: <cover.1254349374.git.joe@perches.com>  <0026bcf5aad9ae5036e68fc2dcda9c778d30dc47.1254349375.git.joe@perches.com>  <alpine.LSU.2.00.0910010042540.782@obet.zrqbmnf.qr> <1254352160.2960.119.camel@Joe-Laptop.home>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1254352160.2960.119.camel@Joe-Laptop.home>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org


On Thursday 2009-10-01 01:09, Joe Perches wrote:
>On Thu, 2009-10-01 at 00:46 +0200, Jan Engelhardt wrote:
>> On Thursday 2009-10-01 00:37, Joe Perches wrote:
>> >This centralizes the definition and removes the
>> >replicated #defines from all files
>
>I think this increased command line length hardly matters.
>
>I think a reasonable complaint might be that it separates
>the definition of a macro from the code.  I think it's
>similar to the already used KBUILD_MODNAME macro though.

KBUILD_MODNAME is special in that it is derived from the actual
source filename. Of course you could put #define KBUILD_MODNAME "foo"
in your source file, but that is like putting changelogs there
when they belong into the git log.

>> How about an #include file for the ipvs private things?
>
>It's not just IPVS, this style could be used treewide
>without requiring extra #includes.

Well I personally prefer the #include instead of hiding such in 
Makefiles. You know, when newcomers could start doing `grep 
KMSG_COMPONENT *.[ch]`. Perhaps GCC's -include flag in a Makefile
to avoid #includes in .c files?
