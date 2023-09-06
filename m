From: Joel Granados <j.granados@samsung.com>
Subject: Re: [GIT PULL] sysctl changes for v6.6-rc1
Date: Wed, 6 Sep 2023 14:35:21 +0200
Message-ID: <20230906123521.xrqcmr3ilpvp2ze6@localhost>
References: <ZO5Yx5JFogGi/cBo@bombadil.infradead.org>
        <CGME20230906115909eucas1p2fcf08f26861b318571224dad6bf5e864@eucas1p2.samsung.com>
        <ZPhpedWW6RwTd9Hf@example.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="l5htxkzwtgg23zjg"
Return-path: <linux-hams-owner@vger.kernel.org>
DKIM-Filter: OpenDKIM Filter v2.11.0 mailout1.w1.samsung.com 20230906123525euoutp01aef263d18f43afc5e0f456b68b34412b~CT2m_4MNh1721017210euoutp01T
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=samsung.com;
        s=mail20170921; t=1694003725;
        bh=kSfDM2PxptQrTVQMPAG5rz9E3Gh0CgYjQq2vX1wh1u8=;
        h=Date:From:To:CC:Subject:In-Reply-To:References:From;
        b=m+6wDQ82ef/d8/4nlWMYTE9kfnIAoWlhMhdqHBBfihfqWuP8iM3eVNlzJjRaHltMU
         2l4lDxXybgq/aUTbfAyOFFW1c/WG3S6g0Slu0hR8E1wgIfPIBWUX5aRY9fX8h2g49x
         0RiNloUw+2A+/56qP9XBwg7AqfowYcMjmZDUd1vg=
Content-Disposition: inline
In-Reply-To: <ZPhpedWW6RwTd9Hf@example.org>
List-ID: <lvs-devel.vger.kernel.org>
To: Alexey Gladkov <legion@kernel.org>
Cc: Luis Chamberlain <mcgrof@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Joel Granados <joel.granados@gmail.com>, linux-fsdevel@vger.kernel.org, rds-devel@oss.oracle.com, "David S. Miller" <davem@davemloft.net>, Florian Westphal <fw@strlen.de>, willy@infradead.org, Jan Karcher <jaka@linux.ibm.com>, Wen Gu <guwen@linux.alibaba.com>, Simon Horman <horms@verge.net.au>, Tony Lu <tonylu@linux.alibaba.com>, linux-wpan@vger.kernel.org, Matthieu Baerts <matthieu.baerts@tessares.net>, Christian Borntraeger <borntraeger@linux.ibm.com>, mptcp@lists.linux.dev, Heiko Carstens <hca@linux.ibm.com>, Stefan Schmidt <stefan@datenfreihafen.org>, Will Deacon <will@kernel.org>, Julian Anastasov <ja@ssi.bg>, netfilter-devel@vger.kernel.org, Joerg Reuter <>

--l5htxkzwtgg23zjg
Content-Type: text/plain; charset="iso-8859-1"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 06, 2023 at 01:58:49PM +0200, Alexey Gladkov wrote:
> On Tue, Aug 29, 2023 at 01:44:55PM -0700, Luis Chamberlain wrote:
> > The following changes since commit 06c2afb862f9da8dc5efa4b6076a0e48c3fb=
aaa5:
> >=20
> >   Linux 6.5-rc1 (2023-07-09 13:53:13 -0700)
> >=20
> > are available in the Git repository at:
> >=20
> >   git://git.kernel.org/pub/scm/linux/kernel/git/mcgrof/linux.git/ tags/=
sysctl-6.6-rc1
> >=20
> > for you to fetch changes up to 53f3811dfd5e39507ee3aaea1be09aabce8f9c98:
> >=20
> >   sysctl: Use ctl_table_size as stopping criteria for list macro (2023-=
08-15 15:26:18 -0700)
> >=20
> > ----------------------------------------------------------------
> > sysctl-6.6-rc1
> >=20
> > Long ago we set out to remove the kitchen sink on kernel/sysctl.c array=
s and
> > placings sysctls to their own sybsystem or file to help avoid merge con=
flicts.
> > Matthew Wilcox pointed out though that if we're going to do that we mig=
ht as
> > well also *save* space while at it and try to remove the extra last sys=
ctl
> > entry added at the end of each array, a sentintel, instead of bloating =
the
> > kernel by adding a new sentinel with each array moved.
> >=20
> > Doing that was not so trivial, and has required slowing down the moves =
of
> > kernel/sysctl.c arrays and measuring the impact on size by each new mov=
e.
> >=20
> > The complex part of the effort to help reduce the size of each sysctl i=
s being
> > done by the patient work of el se=F1or Don Joel Granados. A lot of this=
 is truly
> > painful code refactoring and testing and then trying to measure the sav=
ings of
> > each move and removing the sentinels. Although Joel already has code wh=
ich does
> > most of this work, experience with sysctl moves in the past shows is we=
 need to
> > be careful due to the slew of odd build failures that are possible due =
to the
> > amount of random Kconfig options sysctls use.
> >=20
> > To that end Joel's work is split by first addressing the major housekee=
ping
> > needed to remove the sentinels, which is part of this merge request. Th=
e rest
> > of the work to actually remove the sentinels will be done later in futu=
re
> > kernel releases.
>=20
> This is very interesting for me. I'm also refactoring sysctl based on
> discussion with Linus a while ago.
>=20
> Could you please add me to the Cc in the next patches?
I just sent the next batch for this set for review. You can see it here
https://lore.kernel.org/all/20230906-jag-sysctl_remove_empty_elem_arch-v1-0=
-3935d4854248@samsung.com/
Will add you for the next ones.

Best

>=20
> > At first I was only going to send his first 7 patches of his patch seri=
es,
> > posted 1 month ago, but in retrospect due to the testing the changes ha=
ve
> > received in linux-next and the minor changes they make this goes with t=
he
> > entire set of patches Joel had planned: just sysctl house keeping. Ther=
e are
> > networking changes but these are part of the house keeping too.
> >=20
> > The preliminary math is showing this will all help reduce the overall b=
uild
> > time size of the kernel and run time memory consumed by the kernel by a=
bout
> > ~64 bytes per array where we are able to remove each sentinel in the fu=
ture.
> > That also means there is no more bloating the kernel with the extra ~64=
 bytes
> > per array moved as no new sentinels are created.
> >=20
> > Most of this has been in linux-next for about a month, the last 7 patch=
es took
> > a minor refresh 2 week ago based on feedback.
> >=20
> > ----------------------------------------------------------------
> > Joel Granados (14):
> >       sysctl: Prefer ctl_table_header in proc_sysctl
> >       sysctl: Use ctl_table_header in list_for_each_table_entry
> >       sysctl: Add ctl_table_size to ctl_table_header
> >       sysctl: Add size argument to init_header
> >       sysctl: Add a size arg to __register_sysctl_table
> >       sysctl: Add size to register_sysctl
> >       sysctl: Add size arg to __register_sysctl_init
> >       sysctl: Add size to register_net_sysctl function
> >       ax.25: Update to register_net_sysctl_sz
> >       netfilter: Update to register_net_sysctl_sz
> >       networking: Update to register_net_sysctl_sz
> >       vrf: Update to register_net_sysctl_sz
> >       sysctl: SIZE_MAX->ARRAY_SIZE in register_net_sysctl
> >       sysctl: Use ctl_table_size as stopping criteria for list macro
> >=20
> >  arch/arm64/kernel/armv8_deprecated.c    |  2 +-
> >  arch/s390/appldata/appldata_base.c      |  2 +-
> >  drivers/net/vrf.c                       |  3 +-
> >  fs/proc/proc_sysctl.c                   | 90 +++++++++++++++++--------=
--------
> >  include/linux/sysctl.h                  | 31 +++++++++---
> >  include/net/ipv6.h                      |  2 +
> >  include/net/net_namespace.h             | 10 ++--
> >  ipc/ipc_sysctl.c                        |  4 +-
> >  ipc/mq_sysctl.c                         |  4 +-
> >  kernel/ucount.c                         |  5 +-
> >  net/ax25/sysctl_net_ax25.c              |  3 +-
> >  net/bridge/br_netfilter_hooks.c         |  3 +-
> >  net/core/neighbour.c                    |  8 ++-
> >  net/core/sysctl_net_core.c              |  3 +-
> >  net/ieee802154/6lowpan/reassembly.c     |  8 ++-
> >  net/ipv4/devinet.c                      |  3 +-
> >  net/ipv4/ip_fragment.c                  |  3 +-
> >  net/ipv4/route.c                        |  8 ++-
> >  net/ipv4/sysctl_net_ipv4.c              |  3 +-
> >  net/ipv4/xfrm4_policy.c                 |  3 +-
> >  net/ipv6/addrconf.c                     |  3 +-
> >  net/ipv6/icmp.c                         |  5 ++
> >  net/ipv6/netfilter/nf_conntrack_reasm.c |  3 +-
> >  net/ipv6/reassembly.c                   |  3 +-
> >  net/ipv6/route.c                        |  9 ++++
> >  net/ipv6/sysctl_net_ipv6.c              | 16 ++++--
> >  net/ipv6/xfrm6_policy.c                 |  3 +-
> >  net/mpls/af_mpls.c                      |  6 ++-
> >  net/mptcp/ctrl.c                        |  3 +-
> >  net/netfilter/ipvs/ip_vs_ctl.c          |  8 ++-
> >  net/netfilter/ipvs/ip_vs_lblc.c         | 10 ++--
> >  net/netfilter/ipvs/ip_vs_lblcr.c        | 10 ++--
> >  net/netfilter/nf_conntrack_standalone.c |  4 +-
> >  net/netfilter/nf_log.c                  |  7 +--
> >  net/rds/tcp.c                           |  3 +-
> >  net/sctp/sysctl.c                       |  4 +-
> >  net/smc/smc_sysctl.c                    |  3 +-
> >  net/sysctl_net.c                        | 26 +++++++---
> >  net/unix/sysctl_net_unix.c              |  3 +-
> >  net/xfrm/xfrm_sysctl.c                  |  8 ++-
> >  40 files changed, 222 insertions(+), 113 deletions(-)
>=20
> --=20
> Rgrds, legion
>=20

--=20

Joel Granados

--l5htxkzwtgg23zjg
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQGzBAABCgAdFiEErkcJVyXmMSXOyyeQupfNUreWQU8FAmT4cgkACgkQupfNUreW
QU9+Cwv+PGlN6idIMQ5c8C0f+ZfC5w4Z+JE4kmlQCz1bP2MeE/pPTaPtyWYqpG8L
fCfed2PJj3OndPFVZ8htgmNw43rVuzq+FLpoXoS6A+GQTwt+oFYhkmEHImix1EHY
LgHQwS53MI/8uswyrLCgFK1wB3oWOl2iSsNmafe2N9DNQnjtNMHWA45X9zejzEu3
yIroWgdeLsDjCje7bCASIxWYMQ0mLCcHYnHhLi9t3oLmtCxrfqz/YvUoAtuUGJId
EsmlWY0oVOSbUnAv7/CUX6Vh0zXFxtT91spcvDNl8S1araoo1HlooVdK96Odh/Ly
hiP9KFjySgIdD5HpsT1tSMbEgdx/r1Iv8z4HWJDcpoz4vXeBJRTrdu+H4XJcvXlB
r9R97zixnSmMaNnAIsNh37llJAYe2pmy9I9/lXAB12U/Z/WQ47aMUZCzIHcuyX8F
RTLOFn64GT9n7pWmFNOllKMnkTWbxeCJhzmDbbndW5RhtVt5XbxCBYL8RZ9ne9PD
fMmoGngO
=CaN7
-----END PGP SIGNATURE-----

--l5htxkzwtgg23zjg--
