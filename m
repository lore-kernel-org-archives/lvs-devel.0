From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC PATCH 0/9] ipvs network name space (netns) aware
Date: Sun, 17 Oct 2010 08:47:31 +0200
Message-ID: <20101017064731.GA8152@verge.net.au>
References: <201010081316.38317.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201010081316.38317.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, ja@ssi.bg, wensong@linux-vs.org, daniel.lezcano@free.fr

On Fri, Oct 08, 2010 at 01:16:36PM +0200, Hans Schillstrom wrote:
> This patch series adds network name space (netns) support to the LVS.
> 
> REVISION
> 
> This is version 1
> 
> OVERVIEW
> 
> The patch doesn't remove or add any functionality except for netns.
> For users that don't use network name space (netns) this patch is
> completely transparent.
> 
> No it's possible to run LVS in a Linux container (see lxc-tools)
> i.e.  a light weight virtualization. For example it's possible to run
> one or several lvs on a real server in their own network name spaces.
> >From the LVS point of view it looks like it runs on it's own machine.
> 
> IMPLEMENTATION
> Basic requirements for netns awareness
>  - Global variables has to be moved to dyn. allocated memory.
> 
> Most global variables now resides in a struct ipvs { } in netns/ip_vs.h.
> What is moved and what is not ?
> 
> Some cache aligned locks are still in global, module init params and some debug_level.
> 
> Algorithm files they are untouched.
> 
> QUESTIONS
> Drop rate in ip_vs_ctl per netns or grand total ?

My gut-feeling is that per netns makes more sense.

> Should more lock variables be moved (or less) ?

I'm unsure what you are asking here but I will make a general statement
about locking in IPVS: it needs work.

> 
> PATCH SET
> This patch set is based upon net-next-2.6 (2.6.36-rc3) from 4 oct 2010
> and [patch v4] ipvs: IPv6 tunnel mode
> 
> Note: ip_vs_xmit.c will not work without "[patch v4] ipvs: IPv6 tunnel mode"

Unfortunately the patches don't apply with the persistence engine
patches which were recently merged into nf-next-2.6 (although
"[patch v4.1 ]ipvs: IPv6 tunnel mode" is still unmerged).

I'm happy to work with you to make the required changes there.

(I realise those patches weren't merged when you made your post.
 But regardless, either your or me will need to update the patches).

Another issue is that your patches seem to be split in a way
where the build breaks along the way. E.g. after applying
patch 1, the build breaks. Could you please split things up
in a manner such that this doesn't happen. The reason being
that it breaks bisection.

Lastly, could you provide a unique subject for each patch.
I know its a bit tedious, but it does make a difference when
browsing the changelog.

