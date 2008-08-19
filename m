From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: Fix race conditions in lblc scheduler
Date: Tue, 19 Aug 2008 17:45:16 +1000
Message-ID: <20080819074515.GC4387@verge.net.au>
References: <alpine.LNX.1.10.0808180050440.12259@titan.stealer.net> <20080818231946.GB7785@verge.net.au> <alpine.LNX.1.10.0808190128260.12259@titan.stealer.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.1.10.0808190128260.12259@titan.stealer.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sven Wegener <sven.wegener@stealer.net>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, wensong@linux-vs.org, ja@ssi.bg

On Tue, Aug 19, 2008 at 01:38:42AM +0200, Sven Wegener wrote:
> On Tue, 19 Aug 2008, Simon Horman wrote:
> 
> > On Mon, Aug 18, 2008 at 12:52:08AM +0200, Sven Wegener wrote:
> > > We can't access the cache entry outside of our critical read-locked region,
> > > because someone may free that entry. And we also need to check in the critical
> > > region wether the destination is still available, i.e. it's not in the trash.
> > > If we drop our reference counter, the destination can be purged from the trash
> > > at any time. Our caller only guarantees that no destination is moved to the
> > > trash, while we are scheduling. Also there is no need for our own rwlock,
> > > there is already one in the service structure for use in the schedulers.
> > 
> > this looks good to me. I have confirmed that it applies against lvs-2.6
> > (but not net-2.6 as changes that are already in lvs-2.6 are needed).
> 
> Yes, I've based it on your tree.
> 
> > One minor style question.  You have changed struct ip_vs_lblc_table to *tbl
> > in several places, (e.g. sizeof(*tbl) ). I think that I prefer things the
> > way that they were. Was there a reason for this change?
> 
> In this patch series, no. I prefer them like sizeof(*tbl) as it's more 
> robust, when changing the type of tbl. Changing the type of tbl and 
> forgeting the sizeof() in kmalloc will result in hard to track down bugs, 
> if the old type is still valid. Using sizeof(*tbl) will nearly always get 
> you the correct value you want, without keeping all the types in sizeof() 
> in sync. The compiler already knows the type of tbl, so no need to be 
> explicit about it, when allocating memory for it.

Hi Sven,

sorry about the noise on this. I have applied it to lvs-2.6.

