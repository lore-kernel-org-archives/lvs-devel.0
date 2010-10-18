From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [RFC PATCH 0/9] ipvs network name space (netns) aware
Date: Mon, 18 Oct 2010 13:55:58 +0200
Message-ID: <201010181355.59763.hans.schillstrom@ericsson.com>
References: <201010081316.38317.hans.schillstrom@ericsson.com> <20101017064731.GA8152@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20101017064731.GA8152@verge.net.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "ja@ssi.bg" <ja@ssi.bg>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>

On Sunday 17 October 2010 08:47:31 Simon Horman wrote:
> On Fri, Oct 08, 2010 at 01:16:36PM +0200, Hans Schillstrom wrote:
> > This patch series adds network name space (netns) support to the LVS.
> > 
> > REVISION
> > 
> > This is version 1
> > 
> > OVERVIEW
> > 
> > The patch doesn't remove or add any functionality except for netns.
> > For users that don't use network name space (netns) this patch is
> > completely transparent.
> > 
> > No it's possible to run LVS in a Linux container (see lxc-tools)
> > i.e.  a light weight virtualization. For example it's possible to run
> > one or several lvs on a real server in their own network name spaces.
> > >From the LVS point of view it looks like it runs on it's own machine.
> > 
> > IMPLEMENTATION
> > Basic requirements for netns awareness
> >  - Global variables has to be moved to dyn. allocated memory.
> > 
> > Most global variables now resides in a struct ipvs { } in netns/ip_vs.h.
> > What is moved and what is not ?
> > 
> > Some cache aligned locks are still in global, module init params and some debug_level.
> > 
> > Algorithm files they are untouched.
> > 
> > QUESTIONS
> > Drop rate in ip_vs_ctl per netns or grand total ?

This is a tricky one (I think), 
if the interface is shared with root name-space and/or other name-spaces
 - use grand total
if it's an "own interface"  
 - drop rate can/should be in netns...

> 
> My gut-feeling is that per netns makes more sense.
> 
> > Should more lock variables be moved (or less) ?
> 
> I'm unsure what you are asking here but I will make a general statement
> about locking in IPVS: it needs work.

Some locks still resides as global variables, and others in netns_ipvs struct.
Since you have a lot of experience with IPVS locks, 
you might have ideas what to move and what to not move.

> 
> > 
> > PATCH SET
> > This patch set is based upon net-next-2.6 (2.6.36-rc3) from 4 oct 2010
> > and [patch v4] ipvs: IPv6 tunnel mode
> > 
> > Note: ip_vs_xmit.c will not work without "[patch v4] ipvs: IPv6 tunnel mode"
> 
> Unfortunately the patches don't apply with the persistence engine
> patches which were recently merged into nf-next-2.6 (although
> "[patch v4.1 ]ipvs: IPv6 tunnel mode" is still unmerged).
> 
I do have a patch based on the nf-next without the SIP/PE patch

> I'm happy to work with you to make the required changes there.

I would appreciate that.

> 
> (I realise those patches weren't merged when you made your post.
>  But regardless, either your or me will need to update the patches).
> 
> Another issue is that your patches seem to be split in a way
> where the build breaks along the way. E.g. after applying
> patch 1, the build breaks. Could you please split things up
> in a manner such that this doesn't happen. The reason being
> that it breaks bisection.
> 
Hmm, Daniel also pointed at this,
The Patch is quite large, and will become even larger with pe and sip.
My Idea was to review the patch in pieces and put it together in one or two large patches when submitting it.
I don't know that might be a stupid ?
It's hard to break it up, making the code reentrant causes changes every where.

Daniel L, had another approach break it into many many tiny patches.

> Lastly, could you provide a unique subject for each patch.
> I know its a bit tedious, but it does make a difference when
> browsing the changelog.
> 
Yepp, no problem

> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
