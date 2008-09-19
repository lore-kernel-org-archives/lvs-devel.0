From: David Miller <davem@davemloft.net>
Subject: Re: Should we move IPVS out of net/ipv4 now?
Date: Thu, 18 Sep 2008 17:00:30 -0700 (PDT)
Message-ID: <20080918.170030.32445027.davem@davemloft.net>
References: <20080917.131445.19943427.davem@davemloft.net>
	<f4845fc0809181304y25e3df07xfde0f23406b519a2@mail.gmail.com>
	<20080918235220.GD13536@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080918235220.GD13536@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: horms@verge.net.au
Cc: juliusv@google.com, csnook@redhat.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

From: Simon Horman <horms@verge.net.au>
Date: Fri, 19 Sep 2008 09:52:22 +1000

> On Thu, Sep 18, 2008 at 10:04:28PM +0200, Julius Volz wrote:
> > On Wed, Sep 17, 2008 at 10:14 PM, David Miller wrote:
> > > From: Chris Snook <csnook@redhat.com>
> > > Date: Wed, 17 Sep 2008 14:37:33 -0400
> > >
> > >> Julius Volz wrote:
> > >> > Since IPVS now does partial IPv6, should we finally move it from
> > >> > "net/ipv4/ipvs" to "net" or to "net/netfilter"? I posted that patch a
> > >> > long time ago, but that was before any of the actual v6 features, so
> > >> > there was probably no interest.
> > >>
> > >> Whatever the netfilter people want is fine with me.
> > >
> > > I think, especially in the long term, putting IPVS under net/netfilter/
> > > is the right thing to do.
> > 
> > Ok thanks, I'll send the patch for that once lvs-next-2.6 or
> > net-next-2.6 builds for ARCH=um again (there seems to be some breakage
> > at the moment)...
> 
> Once net-next-2.6 is working again, let me know and I'll pull it
> into lvs-next-2.6.

I can't fix this if people don't tell me what the problem is.

Is there some upstream fix and cures this and all I need to do is
sync net-next-2.6 up with Linus's tree?  Is there some external
fix?

It's totally stupid to stall development because of an issue like this
yet give no direction or diagnostics we can use as a path to resolve
it.
