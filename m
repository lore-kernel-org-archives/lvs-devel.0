From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: make "no destination available" message more
 informative
Date: Wed, 16 Feb 2011 14:52:46 +0900
Message-ID: <20110216055246.GC31955@verge.net.au>
References: <1297429272.8485.18.camel@lat1>
 <20110215220407.GN8703@verge.net.au>
 <20110215223118.GO8703@verge.net.au>
 <1297833167.4466.57.camel@lat1>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1297833167.4466.57.camel@lat1>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick Schaaf <netdev@bof.de>
Cc: lvs-devel@vger.kernel.org

On Wed, Feb 16, 2011 at 06:12:47AM +0100, Patrick Schaaf wrote:
> Hi Simon,
> 
> On Wed, 2011-02-16 at 07:31 +0900, Simon Horman wrote: 
> > > Thanks, this looks good to me.
> > > I will apply it with the minor modification noted below.
> >
> > I have slightly modified the IPv4/IPv6 logic in ip_vs_scheduler_err()
> > and tested the code with both IPv4 and IPv6. It seems to work well :-)
> >
> > I also did some indentation reformatting of ip_vs_scheduler_err()
> > while I was there.
> 
> Thank you for taking your time and looking at it. I'm fine with your
> changes. Signoff follows.

Thanks.

> The first hunk of your patch deletes an empty line in ip_vs.h that is
> unrelated to the other changes. Fine with me too, just thought I'd note
> it.

Ooops, I'll remove that hunk.
