From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 1/9] ipvs network name space aware
Date: Thu, 21 Oct 2010 08:18:06 -0700
Message-ID: <20101021151806.GC2363@linux.vnet.ibm.com>
References: <201010081316.46690.hans.schillstrom@ericsson.com>
 <201010201025.20950.hans.schillstrom@ericsson.com>
 <20101020160205.GB2386@linux.vnet.ibm.com>
 <201010210945.55252.hans.schillstrom@ericsson.com>
 <1287648072.6871.15.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1287648072.6871.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, Daniel Lezcano <daniel.lezcano@free.fr>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "horms@verge.net.au" <horms@verge.net.au>, "ja@ssi.bg" <ja@ssi.bg>, "wensong@linux-vs.org" <wensong@linux-vs.org>

On Thu, Oct 21, 2010 at 10:01:12AM +0200, Eric Dumazet wrote:
> Le jeudi 21 octobre 2010 =E0 09:45 +0200, Hans Schillstrom a =E9crit =
:
> > I do have this (and some debuging)
> > __rcu_read_lock()
> > =3D> 0xffffffff8108bcf3 <+0>:	push   %rbp
> >    0xffffffff8108bcf4 <+1>:	mov    %rsp,%rbp
> >    0xffffffff8108bcf7 <+4>:	nopl   0x0(%rax,%rax,1)
> >    0xffffffff8108bcfc <+9>:	mov    %gs:0xb540,%rax
> >    0xffffffff8108bd05 <+18>:	mov    0x108(%rax),%edx
> >    0xffffffff8108bd0b <+24>:	inc    %edx
> >    0xffffffff8108bd0d <+26>:	mov    %edx,0x108(%rax)
> >    0xffffffff8108bd13 <+32>:	leaveq
> >    0xffffffff8108bd14 <+33>:	retq
> >=20
> > which is not that many, actually imprerssing few instructions :-)
>=20
> nopl   0x0(%rax,%rax,1) is a filler because of extra instrumentation =
in
> your kernel.
>=20
> Maybe you could find out why your compiler dont use
>=20
> 	incl 0x108(%rax)
>=20
> instead of
>=20
> 	mov    0x108(%rax),%edx
> 	inc    %edx
> 	mov    %edx,0x108(%rax)
>=20
>=20
> So rcu_read_lock() is really _two_ instructions.
>=20
> I agree with Paul with the "few" qualification... :-)

Thank you!  ;-)

And the reason for the three-instruction shuffle is that Hans's kernel
does not yet contain commit 80dcf60e.  That commit is on its way upstre=
am,
and will hopefully make the current merge window.

							Thanx, Paul
