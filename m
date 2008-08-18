From: Sven Wegener <sven.wegener@stealer.net>
Subject: Re: [PATCH] ipvs: Fix race conditions in lblc scheduler
Date: Tue, 19 Aug 2008 01:38:42 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0808190128260.12259@titan.stealer.net>
References: <alpine.LNX.1.10.0808180050440.12259@titan.stealer.net> <20080818231946.GB7785@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20080818231946.GB7785@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, wensong@linux-vs.org, ja@ssi.bg

On Tue, 19 Aug 2008, Simon Horman wrote:

> On Mon, Aug 18, 2008 at 12:52:08AM +0200, Sven Wegener wrote:
> > We can't access the cache entry outside of our critical read-locked region,
> > because someone may free that entry. And we also need to check in the critical
> > region wether the destination is still available, i.e. it's not in the trash.
> > If we drop our reference counter, the destination can be purged from the trash
> > at any time. Our caller only guarantees that no destination is moved to the
> > trash, while we are scheduling. Also there is no need for our own rwlock,
> > there is already one in the service structure for use in the schedulers.
> 
> this looks good to me. I have confirmed that it applies against lvs-2.6
> (but not net-2.6 as changes that are already in lvs-2.6 are needed).

Yes, I've based it on your tree.

> One minor style question.  You have changed struct ip_vs_lblc_table to *tbl
> in several places, (e.g. sizeof(*tbl) ). I think that I prefer things the
> way that they were. Was there a reason for this change?

In this patch series, no. I prefer them like sizeof(*tbl) as it's more 
robust, when changing the type of tbl. Changing the type of tbl and 
forgeting the sizeof() in kmalloc will result in hard to track down bugs, 
if the old type is still valid. Using sizeof(*tbl) will nearly always get 
you the correct value you want, without keeping all the types in sizeof() 
in sync. The compiler already knows the type of tbl, so no need to be 
explicit about it, when allocating memory for it.

Sven
