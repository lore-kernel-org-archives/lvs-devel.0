From: =?utf-8?Q?Stefan_Bauer?= <stefan.bauer@cubewerk.de>
Subject: AW: How does the mode fullnat work in detail and is implemented?
Date: Tue, 5 Feb 2013 09:15:43 +0100
Message-ID: <zarafa.5110bfaf.73b4.533a691f696964c6@zarafa.cubewerk.int>
References: <20130205014435.GA2394@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130205014435.GA2394@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="macroman"
To: =?utf-8?Q?lvs-devel=40vger=2Ekernel=2Eorg?= <lvs-devel@vger.kernel.org>

-----Urspr=C3=BCngliche Nachricht-----
Von:	Simon Horman <horms@verge.net.au>
Gesendet:	Di 05.02.2013 02:26
Betreff:	Re: How does the mode fullnat work in detail and is implemente=
d?
An:	Stefan Bauer <stefan.bauer@cubewerk.de>;=20
CC:	lvs-devel@vger.kernel.org;=20
> On Sat, Feb 02, 2013 at 10:12:41AM +0100, Stefan Bauer wrote:
> > Dear developers,
> >=20
> > how does the mode fullnat work and how is it implemented?
> >=20
> > I see there are patches at=20
> http://kb.linuxvirtualserver.org/images/a/a5/Lvs-fullnat-synproxy.tar=
=2Egz for=20
> the kernel.
>=20
> I do not believe that is the code that was merged into the kernel.
> Full-nat for IPVS was included in the 2.6.35 kernel and I do not
> details of how to configure it have changed since.

Hi Simon,

I'm more than happy to get this informations. thank you. So the initial=
 patches are not used in the mainline kernel hence can be seen as obsol=
ete. Also the patches for ipvsadm are useless as its used with the regu=
lar NAT mode.

thank you again.

Stefan
