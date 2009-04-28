From: Simon Horman <horms@verge.net.au>
Subject: [bug] FWMARKs and persistence in IPVS: The Use of Unions
Date: Tue, 28 Apr 2009 18:15:10 +1000
Message-ID: <20090428081509.GA746@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: netfilter-devel <netfilter-devel@vger.kernel.org>, lvs-devel@vger.kernel.org
Cc: Fabien =?iso-8859-1?Q?Duch=EAne?= <fabien.duchene@student.uclouvain.be>, Joseph Mack NA3T <jmack@wm7d.net>, Julius Volz <julius.volz@gmail.com>

[ Moving to netfilter-devel / lvs-devel for discussion on how to resolv=
e this.
  Added Julius Volz to Cc, he wrote most of the IPv6 portion of LVS.
  Remove lvs-users from Cc, it is not an open list. ]

Hi,

The mail below details what appears to be a bug in IPVS.
Thanks to Fabien Duch=EAne for finding it and Joseph Mack for bringing
it to my attention.

The bug seems to be caused by the use of union nf_inet_addr in
the fwmark case. To start, this is what the union looks like:

union nf_inet_addr {
	__u32		all[4];
	__be32		ip;
	__be32		ip6[4];
	struct in_addr	in;
	struct in6_addr	in6;
};

So it has some 32bit values, and some 128 bit values. And is
usually used to store either an IPv6 address or an IPv6 address.
Usually we know which and the functions ip_vs_addr_copy() and
ip_vs_addr_equal(), which are shown below, work quite well.

The problem arrives when a fwmark is used to identify packets.
These could be IPv4 packets or IPv6 packets. Regardless, what
the code currently does is to store the 32bit fwmark in .all[3]
and 0 in the other 3 octets of .all.

In the IPv6 case, this should be fine. When .ip6 is compared
with another .ip6, a 128 bit compare will occur. And this should accura=
tely
compare fwmark values stored in .all as described above.

However, this scheme appears to break down in the IPv4 case. This is
because only .ip is used in comparison and it maps to the first octet o=
f
all, which is always set to 0 in the current scheme.

A simple fix that comes to mind is to just store the fwmark in
the first octet of .all, and set the other octets to zero.
But is .ip always going to be the same as .all[0]?

Is a different approach required? For example, one where we know to com=
pare
=2Eall or perhaps a single octet of .all in the case where fmarks are u=
sed.
This particular change should be easy enough. I believe that fwmarks ar=
e
only used in this way twice, both inside ip_vs_schedule(). But
ip_vs_addr_equal() is more generic, so I'd prefer only to mangle it if
needed.


----- Forwarded message from Simon Horman <horms@verge.net.au> -----

Date: Tue, 28 Apr 2009 17:08:44 +1000
=46rom: Simon Horman <horms@verge.net.au>
To: "LinuxVirtualServer.org users mailing list."
	<lvs-users@linuxvirtualserver.org>
Subject: Re: [lvs-users] FWMARKs and persistence

On Thu, Apr 23, 2009 at 06:23:32PM +0200, Fabien Duch=EAne wrote:
> Hello Joe,
>=20
> Thanks for your reply!
>=20
> Okay for the -SH scheduler, but we have a script that dynamically cha=
nge
> the weight of the servers (because the are very different -hardware
> speaking there-) and i think it wouldn't solve the problem (you'll se=
e why).
> It was very simple to test, a openned the LDAP port on a webserver wi=
th
> a perl script (a server that just write "hello"), and then connected =
to
> this port with a telnet client just after connecting to the web servi=
ce
> with my browser.
> Result: i'm connected to the webserver (via the LDAP mark...).
>=20
> In fact, i looked into the code, and i think that LVS can't handle
> multiple fwmark + persistence services (maybe we found a bug?).
>=20
> If you look in ip_vs.h (in the headers):
>=20
> static inline void ip_vs_addr_copy(int af, union nf_inet_addr *dst,
>                                    const union nf_inet_addr *src)
> {
> #ifdef CONFIG_IP_VS_IPV6
>         if (af =3D=3D AF_INET6)
>                 ipv6_addr_copy(&dst->in6, &src->in6);
>         else
> #endif
>         dst->ip =3D src->ip;
> }
>=20
> static inline int ip_vs_addr_equal(int af, const union nf_inet_addr *=
a,
>                                    const union nf_inet_addr *b)
> {
> #ifdef CONFIG_IP_VS_IPV6
>         if (af =3D=3D AF_INET6)
>                 return ipv6_addr_equal(&a->in6, &b->in6);
> #endif
>=20
>         return a->ip =3D=3D b->ip;
> }
>=20
> These functions are used the check if a template already exist.
> In the fwmarked template, ->ip is always 0.0.0.0 and the ->all[3] (wh=
ere
> the fwmark is written) isn't tested (and not copied as you can see!).
> So, the first template created by a "fwmark persistent service" will
> match every fwmark persistent service (ip =3D 0.0.0.0, it's the same =
for
> all!).
>=20
> Correct me if i'm wrong?
>=20
> If it's a bug, I hope a Dev' could fix this..

Hi Fabien,

that looks like a bug in the IPv4 to me too. If so, it would have been
introduced when the IPv6 code was added to LVS, which was fairly recent=
ly.

It seems to me that it should be easy enough to fix by changing
fwmark in ip_vs_sched_persist() from:

union nf_inet_addr fwmark =3D {
	.all =3D { 0, 0, 0, htonl(svc->fwmark) }
};

to:

union nf_inet_addr fwmark =3D {
	.all =3D { htonl(svc->fwmark), 0, 0, 0 }
};

Assuming that this would result in fwmark->ip being set to
htonl(svc->fwmark), which is relevant if svc->af is AF_INET - that is,
for IPv4. IPv6 should work fine in both cases, as all 4 octets of
all will be tested - which would have presumably been the focus
of the IPv6 work that changed this code.

This assums that the ip element of union nf_inet_addr always correspond=
s
to the first octet of all.

An alternate idea would be to change the af value used for fwmarks,
but this seems to be even less clean than the current (slightly broken)
technique of using nf_inet_addr for IPv4 or IPv6 addresses, or fwmarks.

----- End forwarded message -----

--=20
Simon Horman
  VA Linux Systems Japan K.K. Satellite Lab in Sydney, Australia
  H: www.vergenet.net/~horms/            W: www.valinux.co.jp/en

