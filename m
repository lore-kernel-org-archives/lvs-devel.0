From: Sven Wegener <sven.wegener@stealer.net>
Subject: Re: [PATCH] ipvs: Fix race conditions in lblc scheduler
Date: Mon, 18 Aug 2008 17:47:53 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0808181507070.12259@titan.stealer.net>
References: <alpine.LNX.1.10.0808180050440.12259@titan.stealer.net> <20080818122018.GA11508@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080818122018.GA11508@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, wensong@linux-vs.org, ja@ssi.bg

On Mon, 18 Aug 2008, Simon Horman wrote:

> On Mon, Aug 18, 2008 at 12:52:08AM +0200, Sven Wegener wrote:
> > We can't access the cache entry outside of our critical read-locked region,
> > because someone may free that entry. And we also need to check in the critical
> > region wether the destination is still available, i.e. it's not in the trash.
> > If we drop our reference counter, the destination can be purged from the trash
> > at any time. Our caller only guarantees that no destination is moved to the
> > trash, while we are scheduling. Also there is no need for our own rwlock,
> > there is already one in the service structure for use in the schedulers.
> 
> I need to look over these changes with a fresh set of eyes in the morning
> - sorry that I didn't do that earlier today.  I am very much in favour of
> the changes that we made last week, and this patch at least looks a lot
> like the changes we discussed.  Do you think these should be pushed
> into 2.6.27? Or perhaps even stable? They are real races, right?

The lblc patch is nearly identical to the last one posted. The lblcr is 
new, but follows the same logic.

They are real races, but are quite unlikely to hit. The lblc and lblcr are 
rarely used schedulers, because they only make sense in fwmark-based 
configurations. The chance of them causing major issues is unlikely, 
because for one you need to catch a destination that is in the trash and 
someone needs to purge it at the same time, which is only possible if that 
someone from user space is moving another destination to the trash and 
then the destination also needs to have all references dropped to be 
purgeable. And the other race is that removing a cache entry races with 
someone accessing that cache entry. For the normal expire time removal it 
means that someone has to access an entry, which hasn't been used for a 
long time. In the end I think it's not urgent to get them in.

Sven
