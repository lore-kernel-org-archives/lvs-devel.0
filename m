From: Sven Wegener <sven.wegener@stealer.net>
Subject: Re: [PATCH] ipvs: Fix race conditions in lblcr scheduler
Date: Tue, 19 Aug 2008 01:42:41 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0808190140180.12259@titan.stealer.net>
References: <alpine.LNX.1.10.0808180052160.12259@titan.stealer.net> <20080818233243.GC7785@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080818233243.GC7785@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, wensong@linux-vs.org, ja@ssi.bg

On Tue, 19 Aug 2008, Simon Horman wrote:

> On Mon, Aug 18, 2008 at 12:53:05AM +0200, Sven Wegener wrote:
> > We can't access the cache entry outside of our critical read-locked region,
> > because someone may free that entry. Also getting an entry under read lock,
> > then locking for write and trying to delete that entry looks fishy, but should
> > be no problem here, because we're only comparing a pointer. Also there is no
> > need for our own rwlock, there is already one in the service structure for use
> > in the schedulers.
> 
> Hi Sven,
> 
> this looks good to me. Just a few minor comments inline.
> 
> > Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
> > ---
> >  net/ipv4/ipvs/ip_vs_lblcr.c |  229 +++++++++++++++++++++----------------------
> >  1 files changed, 114 insertions(+), 115 deletions(-)
> > 
> > diff --git a/net/ipv4/ipvs/ip_vs_lblcr.c b/net/ipv4/ipvs/ip_vs_lblcr.c
> > index f1c8450..96bfdc2 100644
> > --- a/net/ipv4/ipvs/ip_vs_lblcr.c
> > +++ b/net/ipv4/ipvs/ip_vs_lblcr.c
> > @@ -106,7 +106,7 @@ ip_vs_dest_set_insert(struct ip_vs_dest_set *set, struct ip_vs_dest *dest)
> >  			return NULL;
> >  	}
> >  
> > -	e = kmalloc(sizeof(struct ip_vs_dest_list), GFP_ATOMIC);
> > +	e = kmalloc(sizeof(*e), GFP_ATOMIC);
> 
> I think that I prefer using struct ip_vs_dest_list rather than *e.
> Ditto for *tbl below.

Actually, it's part of CodingStyle to use *e.

> > +out:
> >  	IP_VS_DBG(6, "LBLCR: destination IP address %u.%u.%u.%u "
> >  		  "--> server %u.%u.%u.%u:%d\n",
> > -		  NIPQUAD(en->addr),
> > +		  NIPQUAD(iph->addr),
> 
> Minor problem, this should be iph->daddr

Good catch, I've updated my patch locally. Let's get a consensus on the 
sizeof issue and I'll repost.

Sven
