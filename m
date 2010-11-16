From: Simon Horman <horms@verge.net.au>
Subject: Re: [*v4 PATCH 0/3] IPVS: Backup Adding Ipv6 and Persistence
 support
Date: Tue, 16 Nov 2010 17:08:51 +0900
Message-ID: <20101116080849.GB10516@verge.net.au>
References: <201011151931.26789.hans.schillstrom@ericsson.com>
 <20101116064436.GA19642@verge.net.au>
 <201011160822.35551.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201011160822.35551.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Julian Anastasov <ja@ssi.bg>, LVS-Devel <lvs-devel@vger.kernel.org>, Daniel Lezcano <daniel.lezcano@free.fr>

On Tue, Nov 16, 2010 at 08:22:35AM +0100, Hans Schillstrom wrote:
> On Tuesday 16 November 2010 07:44:39 Simon Horman wrote:
> > On Mon, Nov 15, 2010 at 07:31:26PM +0100, Hans Schillstrom wrote:
> > > This patch series adds/(updates) the following functionality
> > > in the synchronization between master and backup daemons.
> > > 
> > >  - IPv6
> > >  - Persistence Engine
> > >  - Firewall marks transferred
> > >  - Time-outs transferred.
> > >  - Flag field increased to 32 bits.
> > > 
> > > Note:
> > > It depends on Patch 1-9 in staging branch.
> > > "IPVS: Backup, Prepare for transferring firewall marks (fwmark) to the backup daemon."
> > > to ...
> > > "IPVS: skb defrag in L7 helpers"
> > 
> > Hi Hans,
> > 
> > unfortuantely I am a bit confused about which tree your patches apply to.
> 
> I was your staging branch, as you suggested.

Ok, perhaps I messed something up on my end.
Sorry about that.
