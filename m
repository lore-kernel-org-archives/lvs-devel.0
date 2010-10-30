From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC PATCH] IPVS: Backup, Adding IPv6 address packing
Date: Sat, 30 Oct 2010 20:23:50 +0900
Message-ID: <20101030112350.GD28355@verge.net.au>
References: <1288354920-10994-1-git-send-email-hans.schillstrom@ericsson.com>
 <20101030065303.GL26727@verge.net.au>
 <201010301249.20303.hans@schillstrom.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201010301249.20303.hans@schillstrom.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, lvs-devel@vger.kernel.org, ja@ssi.bg, wensong@linux-vs.org, daniel.lezcano@free.fr

On Sat, Oct 30, 2010 at 12:49:19PM +0200, Hans Schillstrom wrote:
> 
> On Saturday, October 30, 2010 08:53:03 Simon Horman wrote:
> > On Fri, Oct 29, 2010 at 02:22:00PM +0200, Hans Schillstrom wrote:
> > > Add pack/unpack of IPv6 address in sync message
> > > in binary form similar to the ASCII ::
> > > 
> > > A packed IPv6 address constists of -
> > > first byte
> > >   high nibble first segment leng in bytes
> > >   low nibble  possition of last segment.
> > > then
> > >   First segemnt i.e. left side of ::
> > >   Last segment right side of ::
> > > 
> > > Examle  FC00::2
> > > unpacked FC00 0000 0000 0000 0000 0000 0000 0002
> > > packed   1F FC02
> > > Example 2 2003::2:100
> > > unpacked 2003 0000 0000 0000 0000 0000 0002 0100
> > > packed   2D 20 03 02 01 00
> > 
> > Hi Hans,
> > 
> > are you sure the space saved is worth the additional complexity
> > that this patch introduces?
> > --
> 
> Hello Simon
> I can see that my first mail 0/1 is still in my outbox.....
> that mail contains just the question above and some calculations
> 
> My conclusion was that if you have 100M interface and a x64 CPU with a more optimized version
> than it might be worth to pack the IPv6 Address.
> On a 32bit CPU with 1G interfce the packing consume the same time that you might earn 
> The patch is just an example of how to do it,
> 
> Sorry for the confusion that I created without the [RFC PATCH 0/1]
> 
> The intension was to ask if anyone thinks that packing of IPv6 address should be there ?
> I would say, much pain for little gain 

I tend to agree with that assessment.

