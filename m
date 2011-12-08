From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] IPVS: Modify the SH scheduler to use weights
Date: Thu, 8 Dec 2011 09:40:09 +0900
Message-ID: <20111208004008.GD4586@verge.net.au>
References: <1323245223-13646-1-git-send-email-horms@verge.net.au>
 <1323245223-13646-2-git-send-email-horms@verge.net.au>
 <20111207113038.GA18166@1984>
 <CAOgH2dsHepr7Dyx7pNOutFNRh5SoO-oC9mx1MLm6Ncai8Ma3rQ@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAOgH2dsHepr7Dyx7pNOutFNRh5SoO-oC9mx1MLm6Ncai8Ma3rQ@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Mike Maxim <mike@okcupid.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Wed, Dec 07, 2011 at 10:24:09AM -0500, Mike Maxim wrote:
> The reason I put that in is because the size of that table becomes
> more relevant/important if you decide to use the weights in the manne=
r
> the patch lets you. It would be conceivable that someone might need t=
o
> increase the size of that table to accommodate their configuration, s=
o
> I thought it would be handy to be able to do that through the regular
> configuration system instead of editing the source.

Hi Mike,

I agree, but I think its also reasonable to consider IP_VS_SH_TAB_BITS =
as
a separate change.

Could you

1. Split the patch into a Kconfig patch and a ip_vs_sh.c patch
2. Remove spurious line additions from the resulting patches?

>=20
> On Wed, Dec 7, 2011 at 6:30 AM, Pablo Neira Ayuso <pablo@netfilter.or=
g> wrote:
> > On Wed, Dec 07, 2011 at 05:07:03PM +0900, Simon Horman wrote:
> >> From: Michael Maxim <mike@okcupid.com>
> >>
> >> Modify the algorithm to build the source hashing hash table to add
> >> extra slots for destinations with higher weight. This has the effe=
ct
> >> of allowing an IPVS SH user to give more connections to hosts that
> >> have been configured to have a higher weight.
> >>
> >> Signed-off-by: Michael Maxim <mike@okcupid.com>
> >> Signed-off-by: Simon Horman <horms@verge.net.au>
> >> ---
> >> =C2=A0net/netfilter/ipvs/Kconfig =C2=A0 =C2=A0| =C2=A0 15 ++++++++=
+++++++
> >> =C2=A0net/netfilter/ipvs/ip_vs_sh.c | =C2=A0 20 ++++++++++++++++++=
--
> >> =C2=A02 files changed, 33 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconf=
ig
> >> index 70bd1d0..af4c0b8 100644
> >> --- a/net/netfilter/ipvs/Kconfig
> >> +++ b/net/netfilter/ipvs/Kconfig
> >> @@ -232,6 +232,21 @@ config =C2=A0 IP_VS_NQ
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 If you want to compile it in kernel, s=
ay Y. To compile it as a
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 module, choose M here. If unsure, say =
N.
> >>
> >> +comment 'IPVS SH scheduler'
> >> +
> >> +config IP_VS_SH_TAB_BITS
> >> + =C2=A0 =C2=A0 int "IPVS source hashing table size (the Nth power=
 of 2)"
> >> + =C2=A0 =C2=A0 range 4 20
> >> + =C2=A0 =C2=A0 default 8
> >> + =C2=A0 =C2=A0 ---help---
> >> + =C2=A0 =C2=A0 =C2=A0 The source hashing scheduler maps source IP=
s to destinations
> >> + =C2=A0 =C2=A0 =C2=A0 stored in a hash table. This table is tiled=
 by each destination
> >> + =C2=A0 =C2=A0 =C2=A0 until all slots in the table are filled. Wh=
en using weights to
> >> + =C2=A0 =C2=A0 =C2=A0 allow destinations to receive more connecti=
ons, the table is
> >> + =C2=A0 =C2=A0 =C2=A0 tiled an amount proportional to the weights=
 specified. The table
> >> + =C2=A0 =C2=A0 =C2=A0 needs to be large enough to effectively fit=
 all the destinations
> >> + =C2=A0 =C2=A0 =C2=A0 multiplied by their respective weights.
> >
> > Hm, does this really belong to this patch?
> >
> >> +
> >> =C2=A0comment 'IPVS application helper'
> >>
> >> =C2=A0config =C2=A0 =C2=A0 =C2=A0 IP_VS_FTP
> >> diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip=
_vs_sh.c
> >> index 33815f4..e0ca520 100644
> >> --- a/net/netfilter/ipvs/ip_vs_sh.c
> >> +++ b/net/netfilter/ipvs/ip_vs_sh.c
> >> @@ -30,6 +30,11 @@
> >> =C2=A0 * server is dead or overloaded, the load balancer can bypas=
s the cache
> >> =C2=A0 * server and send requests to the original server directly.
> >> =C2=A0 *
> >> + * The weight destination attribute can be used to control the
> >> + * distribution of connections to the destinations in servernode.=
 The
> >> + * greater the weight, the more connections the destination
> >> + * will receive.
> >> + *
> >> =C2=A0 */
> >>
> >> =C2=A0#define KMSG_COMPONENT "IPVS"
> >> @@ -99,9 +104,11 @@ ip_vs_sh_assign(struct ip_vs_sh_bucket *tbl, s=
truct ip_vs_service *svc)
> >> =C2=A0 =C2=A0 =C2=A0 struct ip_vs_sh_bucket *b;
> >> =C2=A0 =C2=A0 =C2=A0 struct list_head *p;
> >> =C2=A0 =C2=A0 =C2=A0 struct ip_vs_dest *dest;
> >> + =C2=A0 =C2=A0 int d_count;
> >>
> >> =C2=A0 =C2=A0 =C2=A0 b =3D tbl;
> >> =C2=A0 =C2=A0 =C2=A0 p =3D &svc->destinations;
> >> + =C2=A0 =C2=A0 d_count =3D 0;
> >> =C2=A0 =C2=A0 =C2=A0 for (i=3D0; i<IP_VS_SH_TAB_SIZE; i++) {
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (list_empty(p)=
) {
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 b->dest =3D NULL;
> >> @@ -113,14 +120,23 @@ ip_vs_sh_assign(struct ip_vs_sh_bucket *tbl,=
 struct ip_vs_service *svc)
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 atomic_inc(&dest->refcnt);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 b->dest =3D dest;
> >>
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 p =3D p->next;
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 IP_VS_DBG_BUF(6, "assigned i: %d dest: %s weight: %d\n",
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 i, IP_VS_DBG_ADDR(=
svc->af, &dest->addr),
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 atomic_read(&dest-=
>weight));
> >> +
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 /* Don't move to next dest until filling weight */
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 if (++d_count >=3D atomic_read(&dest->weight)) {
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 p =3D p->next;
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 d_count =3D 0;
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 }
> >> +
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 b++;
> >> =C2=A0 =C2=A0 =C2=A0 }
> >> +
> >> =C2=A0 =C2=A0 =C2=A0 return 0;
> >> =C2=A0}
> >>
> >> -
> >
> > While at it, would you remove this unnecessary deletions/additions.
> >
> > Thanks!
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
