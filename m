From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: Re: Adding SNAT support to LVS/NAT
Date: Tue, 16 Sep 2008 11:04:06 +0900
Message-ID: <200809161104.07239.j.stubbs@linkthink.co.jp>
References: <f4845fc0809130412n41967d79l1240558492c84cb7@mail.gmail.com> <200809161031.58743.j.stubbs@linkthink.co.jp> <Pine.LNX.4.64.0809151852060.9622@wm7d.net>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0809151852060.9622@wm7d.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Joseph Mack NA3T <jmack@wm7d.net>
Cc: Simon Horman <horms@verge.net.au>, Julius Volz <juliusv@google.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Siim =?utf-8?q?P=C3=B5der?= <siim@p6drad-teel.net>

On Tuesday 16 September 2008 10:54:04 Joseph Mack NA3T wrote:
> On Tue, 16 Sep 2008, Jason Stubbs wrote:
>=20
> > For what it's worth, I'm currently using DNAT alongside LVS-NAT
> > for certain connections. It only serves a secondary purpose and
> > there are other ways (although not as simple) to achieve the
> > purpose, but it has proven useful.
>=20
> I'm having a bit of trouble fitting DNAT into the OUTPUT of=20
> a director (at least on the OUTPUT of the inside nic). What=20
> are you doing this for?

Hmm.. with LVS-NAT happening in OUTPUT, it may not be possible - or at
least not useful. I'm using DNAT before LVS-NAT to redirect the VIP to
a different internal IP for certain source addresses. If LVS-NAT
happens before DNAT, DNAT could only be used with RIPs which I can't
imagine to be useful at all...

--=20
Jason Stubbs <j.stubbs@linkthink.co.jp>
LINKTHINK INC.
=E6=9D=B1=E4=BA=AC=E9=83=BD=E6=B8=8B=E8=B0=B7=E5=8C=BA=E6=A1=9C=E3=83=B6=
=E4=B8=98=E7=94=BA22-14 N.E.S S=E6=A3=9F 3F
TEL 03-5728-4772  FAX 03-5728-4773
