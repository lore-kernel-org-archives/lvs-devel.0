From: Sven Wegener <sven.wegener@stealer.net>
Subject: Re: [GIT] Please pull updates for IPVS
Date: Fri, 15 Aug 2008 08:09:12 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0808150803570.12259@titan.stealer.net>
References: <20080815001250.GC15825@verge.net.au> <20080814.172508.15803616.davem@davemloft.net> <20080815010235.GD15825@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080815010235.GD15825@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: David Miller <davem@davemloft.net>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, juliusv@google.com, wensong@linux-vs.org, ja@ssi.bg

On Fri, 15 Aug 2008, Simon Horman wrote:

> On Thu, Aug 14, 2008 at 05:25:08PM -0700, David Miller wrote:
> > From: Simon Horman <horms@verge.net.au>
> > Date: Fri, 15 Aug 2008 10:12:52 +1000
> > 
> > > Julius, Sven and I would particularly like Julius' two changes to go
> > > in. They add a new interface which is currently unused and thus the
> > > likelihood of breakage seems low.
> > 
> > Actually these are the two changes that should not go in at this
> > time.  This netlink stuff is a new feature, therefore not appropriate
> > to merge outside of the merge window.
> > 
> > Bug fixes only now, please.
> 
> thanks for the clarification. In that case I believe that
> all of these changes can wait.

We should get something cooked up for -next, so that we can push these 
changes this way into wider testing. Having a place for -next might be 
good in general, not for this case only.

Sven
