From: Sven Wegener <sven.wegener@stealer.net>
Subject: Re: [RFC,PATCH] ipvs: Fix race condition in lblb and lblcr
 schedulers
Date: Wed, 13 Aug 2008 12:36:59 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0808131119560.12259@titan.stealer.net>
References: <alpine.LNX.1.10.0808112202270.12259@titan.stealer.net> <20080812021053.GD22142@verge.net.au> <alpine.LNX.1.10.0808120606200.12259@titan.stealer.net> <alpine.LNX.1.10.0808121007130.12259@titan.stealer.net> <20080813054247.GA21168@verge.net.au>
 <alpine.LNX.1.10.0808130842540.12259@titan.stealer.net> <20080813071221.GB4872@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20080813071221.GB4872@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Wed, 13 Aug 2008, Simon Horman wrote:

> On Wed, Aug 13, 2008 at 08:59:32AM +0200, Sven Wegener wrote:
> > On Wed, 13 Aug 2008, Simon Horman wrote:
> > 
> > > On Tue, Aug 12, 2008 at 03:07:48PM +0200, Sven Wegener wrote:
> > > > 
> > > > +
> > > > +		/*
> > > > +		 * If the destination is not available, i.e. it's in the trash,
> > > > +		 * ignore it, as it may be removed from under our feet
> > > > +		 */
> > > > +
> > > > +		if (!(dest->flags & IP_VS_DEST_F_AVAILABLE))
> > > > +			dest = NULL;
> > > >  	}
> > > > -	en->lastuse = jiffies;
> > > 
> > > At this point we know that dest exists and is not in the trash.
> > > We know that dest can't disapear given that its not already
> > > in the trash and our caller holds a read lock on __ip_vs_svc_lock.
> > > So dest will be safe until after ip_vs_lblc_schedule() returns.
> > > 
> > > Dest seems ok :-)
> > > 
> > > Ok, that seems complex but non-racy to me :-)
> > > 
> > > Perhaps a longer comment would be in order.
> > 
> > Yeah, that's the point where we prevent the race with the trash purging. 
> > We could change the purging of destinations from the trash to be under 
> > __ip_vs_svc_lock write locked, then we know that all destinations, even 
> > the ones in the trash are valid. Might make more sense than duplicating 
> > this logic in other schedulers.
> 
> That sounds like a good way to simplify things.

Looking at the code it doesn't seem that simple. We lock __ip_vs_svc_lock 
for writing and then wait for all current users of the service to go away. 
But it's still possible that we clean up destinations from other services. 
And when we restrict it to only clean up the destinations that match our 
service, we have a chance of leaving destinations in the trash for good.

Sven
