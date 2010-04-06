From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] IPVS: replace sprintf to snprintf to avoid stack
 buffer overflow
Date: Tue, 6 Apr 2010 13:26:42 +1000
Message-ID: <20100406032642.GG30359@verge.net.au>
References: <20100406025020.GA2741@localhost.localdomain>
 <k2l412e6f7f1004051958h7c50f439r6b7a84379c35cba5@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <k2l412e6f7f1004051958h7c50f439r6b7a84379c35cba5@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Changli Gao <xiaosuo@gmail.com>
Cc: wzt.wzt@gmail.com, linux-kernel@vger.kernel.org, wensong@linux-vs.org, Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>

On Tue, Apr 06, 2010 at 10:58:28AM +0800, Changli Gao wrote:
> On Tue, Apr 6, 2010 at 10:50 AM,  <wzt.wzt@gmail.com> wrote:
> > IPVS not check the length of pp->name, use sprintf will cause stack=
 buffer overflow.
> > struct ip_vs_protocol{} declare name as char *, if register a proto=
col as:
> > struct ip_vs_protocol ip_vs_test =3D {
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0.name =3D =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 "aaaaaaaa....128...aaa",
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0.debug_packet =3D =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 ip_vs_tcpudp_debug_packet,
> > };
> >
> > when called ip_vs_tcpudp_debug_packet(), sprintf(buf, "%s TRUNCATED=
", pp->name);
> > will cause stack buffer overflow.
> >
>=20
> Long messages will be truncated instead of buffer overflow. We need t=
o
> find a way to handle long messages elegantly.

Its really a corner case. In practice protocol modules don't have reall=
y
long names. And if one was merged that did, the buffer size could be in=
creased
at that time.

So while I think its reasonable to protect against something unexpected
in a protocol-module name crashing the system. Especially as that
can be achieved without any real overhead. I don't think we need
to sanitise the output.
