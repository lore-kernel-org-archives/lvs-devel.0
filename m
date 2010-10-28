From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence
 support
Date: Thu, 28 Oct 2010 21:11:36 +0900
Message-ID: <20101028121136.GC16206@verge.net.au>
References: <201010261300.09827.hans.schillstrom@ericsson.com>
 <alpine.LFD.2.00.1010272249030.1643@ja.ssi.bg>
 <20101028113511.GA13986@verge.net.au>
 <201010281352.15829.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201010281352.15829.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Julian Anastasov <ja@ssi.bg>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, Daniel Lezcano <daniel.lezcano@free.fr>

On Thu, Oct 28, 2010 at 01:52:15PM +0200, Hans Schillstrom wrote:
> Hello
> 
> On Thursday 28 October 2010 13:35:12 Simon Horman wrote:
> > On Wed, Oct 27, 2010 at 10:58:31PM +0300, Julian Anastasov wrote:
> > >
> > > 	Hello,
> > >
> > > On Wed, 27 Oct 2010, Hans Schillstrom wrote:
> > >
> > > >>A New Spec of Type field:
> > > >>
> > > >>Bit    7        6        . . .      2         1           0
> > > >>  +----------+--------------------------+-------------+-------+
> > > >>  | Opt.Data |          Spare           | Packed IPv6 |  IPv6 |
> > > >>  +----------+--------------------------+-------------+-------+
> > > >
> > > >I can see a better usage of it in Option Type so Type will look like this
> > > >   +-------------------------------------+-------------+-------+
> > > >   |                     Spare           | Packed IPv6 |  IPv6 |
> > > >   +-------------------------------------+-------------+-------+
> > > >
> > > >And "Option Type" in option field would look like this
> > > >
> > > >Bit    7        6        . . .    0    7                      0
> > > >  +----------+----------------------+---------------------------+
> > > >  | Optional |      Option type     |    Option length          |
> > > >  +----------+----------------------+---------------------------+
> >
> > As it stands a little more than 256 bytes may be needed for
> > pe_data (+ pe_name_length + pe_name). This could be resolved by
> > shortening the maximum pe_data length. Or perhaps we could use 16 bytes for
> > Option length, which should ensure its never too small.
> >
> > The 256 byte limit that I made for pe_data was arbitrarily chosen.
> >
> 
> I have PE_NAME and PE_DATA ass different options
> so the limit is actually 255 bytes.
> 
> #define IPVS_OPT_SEQ_DATA 	1
> #define IPVS_OPT_PE_DATA	2
> #define IPVS_OPT_PE_NAME	3
> 
> How ever they are not independant of each other.
>  - PE_NAME never goes alone, only if there is PE_DATA.
>  - In the receiving path, PE_NAME must have PE_DATA to be valid.

Ok, thanks, I haven't reviewed the patches that closely yet :-(

But still, 8 buts for option length does limit us to never ever
having an option longer than 255 bytes. But I guess we can
make sync protocol v3 if we need to cross that bridge.

> > > >We can have a better fine tuning of options in this way.
> > >
> > > 	Yes, that is exactly my idea. I more like the name
> > > "Parameter" instead of "Option", i.e. we have additional
> > > parameters that can be mandatory (usually) but also can be
> > > optional. For now I don't have idea for any optional
> > > parameters but allocating 1 bit for this does not look
> > > fatal.
> >
> > I'm not sure I understand the motivation for optional parameters.
> > I think its important to allow for backwards compatibility. But
> > I don't see that there will be multiple independent implementations
> > of the synchronisation daemon in the near future. So the use-case
> > isn't clear to me.
> 
> Backward compatibility is "one way only"
> a new backup daemon can listen to an old one
> not the other way around.

Yes. I thought that was my point :-)
