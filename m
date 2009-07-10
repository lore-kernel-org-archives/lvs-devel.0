From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] IPVS: Add handling of incoming ICMPV6_PKT_TOOBIG
	messages
Date: Fri, 10 Jul 2009 19:56:44 +1000
Message-ID: <20090710095644.GB18482@verge.net.au>
References: <20090624132232.GA9633@egardia> <20090628154302.GB21519@verge.net.au> <43ca39800907020743v1ccc1979o5a934d5ead05edc9@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <43ca39800907020743v1ccc1979o5a934d5ead05edc9@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Julius Volz <julius.volz@gmail.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, robert.gallagher@heanet.ie

On Thu, Jul 02, 2009 at 04:43:39PM +0200, Julius Volz wrote:
> Hi Simon,
>=20
> On Sun, Jun 28, 2009 at 5:43 PM, Simon Horman<horms@verge.net.au> wro=
te:
> > On Wed, Jun 24, 2009 at 03:22:32PM +0200, Julius Volz wrote:
> >> Add handling of incoming ICMPv6 Packet Too Big messages. This mess=
age
> >> is received when a realserver sends a packet >PMTU to the client. =
The
> >> hop on this path with insufficient MTU will generate an ICMPv6 Pac=
ket
> >> Too Big message back to the VIP. The LVS server receives this mess=
age,
> >> but the call to the function handling this has been missing. Thus,=
 IPVS
> >> fails to forward the message to the real server, which then does n=
ot
> >> adjust the path MTU. This patch adds the missing call to
> >> ip_vs_in_icmp_v6() in ip_vs_in() to handle this situation.
> >>
> >> Thanks to Rob Gallagher from HEAnet for reporting this issue and f=
or
> >> testing this patch in production (with direct routing mode).
> >>
> >> Signed-off-by: Julius Volz <julius.volz@gmail.com>
> >> Tested-by: Rob Gallagher <robert.gallagher@heanet.ie>
> >
> > Hi Julius, Hi Rob,
> >
> > this seems reasonable to me, although it seems that the following
> > code is common. I wonder if its repetition could be removed.
> >
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (related)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retu=
rn verdict;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ip_vs_fill_iphdr(af,=
 skb_network_header(skb), &iph);
>=20
> I agree, though I see no "nice" way to remove this duplication
> considering the ifs and #ifdefs around this. You could move the
> related and verdict variables to the top of the function and then
> recheck afterwards whether one of these ICMP-handling branches was
> entered and put the common code in there. But this seems more
> cumbersome to me than repeating the code. Maybe you see a nicer way?
> Btw., exactly this structure already exists in ip_vs_out(), which is
> why I adopted it like this for ip_vs_in().

Hi Julius,

sorry for the delay in responding, I've been off-line / recovering from
being off-line.

I couldn't see an obvious way either, though I was hoping that
you might :-) As you can't I'm happy to go with what you originally
posted.

Acked-by: Simon Horman <horms@verge.net.au>
