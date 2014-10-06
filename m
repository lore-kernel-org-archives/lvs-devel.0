From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] ipvs: Avoid null-pointer deref in debug code
Date: Mon, 6 Oct 2014 22:13:07 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1410062201140.2258@ja.home.ssi.bg>
References: <20141001174526.GA16206@mwanda> <1412556895-26891-1-git-send-email-agartrell@fb.com> <alpine.LFD.2.11.1410060940470.1738@ja.home.ssi.bg> <5432BBB8.9070206@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <5432BBB8.9070206@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: horms@verge.net.au, dan.carpenter@oracle.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, kernel-team@fb.com


	Hello,

On Mon, 6 Oct 2014, Alex Gartrell wrote:

> Hey Julian,
> 
> I've sent an updated patch that does this but I have some questions about
> other stuff that I find mildly confusing.  Specifically I didn't realize until
> looking at the call sites that !dest || daddr = dest->addr.ip (but maybe I'm
> wrong?)
> 
> If that's the case, why do we have the following line in __ip_vs_get_out_rt?
> 
>                 daddr = dest->addr.ip;

	Extra line that is not needed...

> If that's /always/ true then we should add the following line or a comment to
> the same effect to clarify
> 
> 	BUG_ON(dest && dest->addr.ip != daddr);

	IMHO, BUG_ON is not needed.

> If that's not intended to always be true, then should the patch be the
> following?
> 
> 	...%pI4", dest ? &dest->addr.ip : &daddr);

	Using daddr is fine.

Regards

--
Julian Anastasov <ja@ssi.bg>
