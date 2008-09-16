From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: Re: Adding SNAT support to LVS/NAT
Date: Tue, 16 Sep 2008 10:31:58 +0900
Message-ID: <200809161031.58743.j.stubbs@linkthink.co.jp>
References: <f4845fc0809130412n41967d79l1240558492c84cb7@mail.gmail.com> <20080915014337.GA10026@verge.net.au> <Pine.LNX.4.64.0809150815580.32594@wm7d.net>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0809150815580.32594@wm7d.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Joseph Mack NA3T <jmack@wm7d.net>
Cc: Simon Horman <horms@verge.net.au>, Julius Volz <juliusv@google.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Siim =?utf-8?q?P=C3=B5der?= <siim@p6drad-teel.net>

On Tuesday 16 September 2008 00:24:38 Joseph Mack NA3T wrote:
> On Mon, 15 Sep 2008, Simon Horman wrote:
>=20
> > Well, it would be a problem if it gets DNATed a second time.
>=20
> Are you just being really safe? Are you trying to prevent=20
> someone from adding DNAT rules to OUTPUT?
>=20
> Would it be better (as much as possible) for LVS to appear=20
> to be just another netfilter module, in which case if=20
> someone wants to DNAT in OUTPUT, this should be allowed=20
> (whether it's sensible or not). Currently LVS-NAT doesn't=20
> allow SNAT on OUTPUT, which no-one thought about when=20
> LVS-NAT was first written and it turns out to be useful.

=46or what it's worth, I'm currently using DNAT alongside LVS-NAT
for certain connections. It only serves a secondary purpose and
there are other ways (although not as simple) to achieve the
purpose, but it has proven useful.

--=20
Jason Stubbs <j.stubbs@linkthink.co.jp>
LINKTHINK INC.
=E6=9D=B1=E4=BA=AC=E9=83=BD=E6=B8=8B=E8=B0=B7=E5=8C=BA=E6=A1=9C=E3=83=B6=
=E4=B8=98=E7=94=BA22-14 N.E.S S=E6=A3=9F 3F
TEL 03-5728-4772  FAX 03-5728-4773
