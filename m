From: Simon Horman <horms@verge.net.au>
Subject: Re: How does the mode fullnat work in detail and is implemented?
Date: Tue, 5 Feb 2013 17:51:17 +0900
Message-ID: <20130205085116.GB20270@verge.net.au>
References: <20130205014435.GA2394@verge.net.au>
 <zarafa.5110bfaf.73b4.533a691f696964c6@zarafa.cubewerk.int>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <zarafa.5110bfaf.73b4.533a691f696964c6@zarafa.cubewerk.int>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Stefan Bauer <stefan.bauer@cubewerk.de>
Cc: "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>

On Tue, Feb 05, 2013 at 09:15:43AM +0100, Stefan Bauer wrote:
> -----Urspr=C3=BCngliche Nachricht-----
> Von:	Simon Horman <horms@verge.net.au>
> Gesendet:	Di 05.02.2013 02:26
> Betreff:	Re: How does the mode fullnat work in detail and is implemen=
ted?
> An:	Stefan Bauer <stefan.bauer@cubewerk.de>;=20
> CC:	lvs-devel@vger.kernel.org;=20
> > On Sat, Feb 02, 2013 at 10:12:41AM +0100, Stefan Bauer wrote:
> > > Dear developers,
> > >=20
> > > how does the mode fullnat work and how is it implemented?
> > >=20
> > > I see there are patches at=20
> > http://kb.linuxvirtualserver.org/images/a/a5/Lvs-fullnat-synproxy.t=
ar.gz for=20
> > the kernel.
> >=20
> > I do not believe that is the code that was merged into the kernel.
> > Full-nat for IPVS was included in the 2.6.35 kernel and I do not
> > details of how to configure it have changed since.
>=20
> Hi Simon,
>=20
> I'm more than happy to get this informations. thank you. So the initi=
al patches are not used in the mainline kernel hence can be seen as obs=
olete. Also the patches for ipvsadm are useless as its used with the re=
gular NAT mode.

Yes, AFIC that is correct.
