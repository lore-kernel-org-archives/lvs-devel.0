From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence
 support
Date: Thu, 28 Oct 2010 20:35:12 +0900
Message-ID: <20101028113511.GA13986@verge.net.au>
References: <201010261300.09827.hans.schillstrom@ericsson.com>
 <alpine.LFD.2.00.1010262331200.1928@ja.ssi.bg>
 <201010271119.21590.hans.schillstrom@ericsson.com>
 <201010271433.06982.hans.schillstrom@ericsson.com>
 <alpine.LFD.2.00.1010272249030.1643@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1010272249030.1643@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, Daniel Lezcano <daniel.lezcano@free.fr>

On Wed, Oct 27, 2010 at 10:58:31PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Wed, 27 Oct 2010, Hans Schillstrom wrote:
> 
> >>A New Spec of Type field:
> >>
> >>Bit    7        6        . . .      2         1           0
> >>  +----------+--------------------------+-------------+-------+
> >>  | Opt.Data |          Spare           | Packed IPv6 |  IPv6 |
> >>  +----------+--------------------------+-------------+-------+
> >
> >I can see a better usage of it in Option Type so Type will look like this
> >   +-------------------------------------+-------------+-------+
> >   |                     Spare           | Packed IPv6 |  IPv6 |
> >   +-------------------------------------+-------------+-------+
> >
> >And "Option Type" in option field would look like this
> >
> >Bit    7        6        . . .    0    7                      0
> >  +----------+----------------------+---------------------------+
> >  | Optional |      Option type     |    Option length          |
> >  +----------+----------------------+---------------------------+

As it stands a little more than 256 bytes may be needed for
pe_data (+ pe_name_length + pe_name). This could be resolved by
shortening the maximum pe_data length. Or perhaps we could use 16 bytes for
Option length, which should ensure its never too small.

The 256 byte limit that I made for pe_data was arbitrarily chosen.

> >We can have a better fine tuning of options in this way.
> 
> 	Yes, that is exactly my idea. I more like the name
> "Parameter" instead of "Option", i.e. we have additional
> parameters that can be mandatory (usually) but also can be
> optional. For now I don't have idea for any optional
> parameters but allocating 1 bit for this does not look
> fatal.

I'm not sure I understand the motivation for optional parameters.
I think its important to allow for backwards compatibility. But
I don't see that there will be multiple independent implementations
of the synchronisation daemon in the near future. So the use-case
isn't clear to me.

That said, I agree that allocating 1 bit isn't a show-stopper.

