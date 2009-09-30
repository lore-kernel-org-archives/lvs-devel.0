From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/2] net/netfilter/ipvs: Move #define KMSG_COMPONENT to
 Makefile
Date: Wed, 30 Sep 2009 16:09:20 -0700
Message-ID: <1254352160.2960.119.camel@Joe-Laptop.home>
References: <cover.1254349374.git.joe@perches.com>
	 <0026bcf5aad9ae5036e68fc2dcda9c778d30dc47.1254349375.git.joe@perches.com>
	 <alpine.LSU.2.00.0910010042540.782@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.00.0910010042540.782@obet.zrqbmnf.qr>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Jan Engelhardt <jengelh@medozas.de>
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org

On Thu, 2009-10-01 at 00:46 +0200, Jan Engelhardt wrote:
> On Thursday 2009-10-01 00:37, Joe Perches wrote:
> >This centralizes the definition and removes the
> >replicated #defines from all files
> And increases the length of the command line. Not that Linux does not
> support long command lines (in fact, configure often determines huge
> possible values on the max length test), but sometimes, developers
> have to inspect the command lines anyway for bugs, or something. It
> is already pretty long due to all the compiler flags.

Hi Jan.

I think this increased command line length hardly matters.

I think a reasonable complaint might be that it separates
the definition of a macro from the code.  I think it's
similar to the already used KBUILD_MODNAME macro though.

> How about an #include file for the ipvs private things?

It's not just IPVS, this style could be used treewide
without requiring extra #includes.

cheers, Joe

