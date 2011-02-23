From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2] ipvs: unify the formula to estimate the overhead of
 processing connections
Date: Thu, 24 Feb 2011 08:09:00 +0900
Message-ID: <20110223230859.GN7361@verge.net.au>
References: <1298107948-9224-1-git-send-email-xiaosuo@gmail.com>
 <20110222055553.GA4192@verge.net.au>
 <AANLkTini6JkOQenO+bzF3AbzePPe1vMtMK_5pqfLifzz@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTini6JkOQenO+bzF3AbzePPe1vMtMK_5pqfLifzz@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Wensong Zhang <wensong@linux-vs.org>
Cc: Changli Gao <xiaosuo@gmail.com>, "David S. Miller" <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>, Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

Hi Wensong,

should I add an Acked-by?

On Wed, Feb 23, 2011 at 09:56:54AM +0800, Wensong Zhang wrote:
> Sure, I am ok with this patch. Thanks!
>=20
> On Tue, Feb 22, 2011 at 1:56 PM, Simon Horman <horms@verge.net.au> wr=
ote:
> > On Sat, Feb 19, 2011 at 05:32:28PM +0800, Changli Gao wrote:
> >> lc and wlc use the same formula, but lblc and lblcr use another on=
e. There
> >> is no reason for using two different formulas for the lc variants.
> >>
> >> The formula used by lc is used by all the lc variants in this patc=
h.
> >
> > Wensong, are you ok with this version of the patch?
> >
> >>
> >> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> >> ---
> >> v2: use ip_vs_dest_conn_overhead() instead.
> >> =C2=A0include/net/ip_vs.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0| =C2=A0 14 ++++++++++++++
> >> =C2=A0net/netfilter/ipvs/ip_vs_lblc.c =C2=A0| =C2=A0 13 +++-------=
---
> >> =C2=A0net/netfilter/ipvs/ip_vs_lblcr.c | =C2=A0 25 +++++++--------=
----------
> >> =C2=A0net/netfilter/ipvs/ip_vs_lc.c =C2=A0 =C2=A0| =C2=A0 18 +----=
-------------
> >> =C2=A0net/netfilter/ipvs/ip_vs_wlc.c =C2=A0 | =C2=A0 20 ++--------=
----------
> >> =C2=A05 files changed, 27 insertions(+), 63 deletions(-)
> >> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> >> index 5d75fea..e80ffb7 100644
> >> --- a/include/net/ip_vs.h
> >> +++ b/include/net/ip_vs.h
> >> @@ -1241,6 +1241,20 @@ static inline void ip_vs_conn_drop_conntrac=
k(struct ip_vs_conn *cp)
> >> =C2=A0/* CONFIG_IP_VS_NFCT */
> >> =C2=A0#endif
> >>
> >> +static inline unsigned int
> >> +ip_vs_dest_conn_overhead(struct ip_vs_dest *dest)
> >> +{
> >> + =C2=A0 =C2=A0 /*
> >> + =C2=A0 =C2=A0 =C2=A0* We think the overhead of processing active=
 connections is 256
> >> + =C2=A0 =C2=A0 =C2=A0* times higher than that of inactive connect=
ions in average. (This
> >> + =C2=A0 =C2=A0 =C2=A0* 256 times might not be accurate, we will c=
hange it later) We
> >> + =C2=A0 =C2=A0 =C2=A0* use the following formula to estimate the =
overhead now:
> >> + =C2=A0 =C2=A0 =C2=A0* =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0dest->activeconns*256 + dest->inactconns
> >> + =C2=A0 =C2=A0 =C2=A0*/
> >> + =C2=A0 =C2=A0 return (atomic_read(&dest->activeconns) << 8) +
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 atomic_read(&dest->ina=
ctconns);
> >> +}
> >> +
> >> =C2=A0#endif /* __KERNEL__ */
> >>
> >> =C2=A0#endif =C2=A0 =C2=A0 =C2=A0 /* _NET_IP_VS_H */
> >> diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/=
ip_vs_lblc.c
> >> index 00b5ffa..58ae403 100644
> >> --- a/net/netfilter/ipvs/ip_vs_lblc.c
> >> +++ b/net/netfilter/ipvs/ip_vs_lblc.c
> >> @@ -389,12 +389,7 @@ __ip_vs_lblc_schedule(struct ip_vs_service *s=
vc)
> >> =C2=A0 =C2=A0 =C2=A0 int loh, doh;
> >>
> >> =C2=A0 =C2=A0 =C2=A0 /*
> >> - =C2=A0 =C2=A0 =C2=A0* We think the overhead of processing active=
 connections is fifty
> >> - =C2=A0 =C2=A0 =C2=A0* times higher than that of inactive connect=
ions in average. (This
> >> - =C2=A0 =C2=A0 =C2=A0* fifty times might not be accurate, we will=
 change it later.) We
> >> - =C2=A0 =C2=A0 =C2=A0* use the following formula to estimate the =
overhead:
> >> - =C2=A0 =C2=A0 =C2=A0* =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0dest->activeconns*50 + dest->inactconns
> >> - =C2=A0 =C2=A0 =C2=A0* and the load:
> >> + =C2=A0 =C2=A0 =C2=A0* We use the following formula to estimate t=
he load:
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0* =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0(dest overhead) / dest->weight
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0*
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0* Remember -- no floats in kernel mode!=
!!
> >> @@ -410,8 +405,7 @@ __ip_vs_lblc_schedule(struct ip_vs_service *sv=
c)
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 continue;
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (atomic_read(&=
dest->weight) > 0) {
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 least =3D dest;
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 loh =3D atomic_read(&least->activeconns) * 50
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 + atomic_read(&least->inactconns);
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 loh =3D ip_vs_dest_conn_overhead(least);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 goto nextstage;
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> >> =C2=A0 =C2=A0 =C2=A0 }
> >> @@ -425,8 +419,7 @@ __ip_vs_lblc_schedule(struct ip_vs_service *sv=
c)
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (dest->flags &=
 IP_VS_DEST_F_OVERLOAD)
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 continue;
> >>
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 doh =3D atomic_read(&d=
est->activeconns) * 50
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 + atomic_read(&dest->inactconns);
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 doh =3D ip_vs_dest_con=
n_overhead(dest);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (loh * atomic_=
read(&dest->weight) >
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 doh=
 * atomic_read(&least->weight)) {
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 least =3D dest;
> >> diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs=
/ip_vs_lblcr.c
> >> index bfa25f1..2ddefe8 100644
> >> --- a/net/netfilter/ipvs/ip_vs_lblcr.c
> >> +++ b/net/netfilter/ipvs/ip_vs_lblcr.c
> >> @@ -178,8 +178,7 @@ static inline struct ip_vs_dest *ip_vs_dest_se=
t_min(struct ip_vs_dest_set *set)
> >>
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if ((atomic_read(=
&least->weight) > 0)
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 && =
(least->flags & IP_VS_DEST_F_AVAILABLE)) {
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 loh =3D atomic_read(&least->activeconns) * 50
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 + atomic_read(&least->inactconns);
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 loh =3D ip_vs_dest_conn_overhead(least);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 goto nextstage;
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> >> =C2=A0 =C2=A0 =C2=A0 }
> >> @@ -192,8 +191,7 @@ static inline struct ip_vs_dest *ip_vs_dest_se=
t_min(struct ip_vs_dest_set *set)
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (dest->flags &=
 IP_VS_DEST_F_OVERLOAD)
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 continue;
> >>
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 doh =3D atomic_read(&d=
est->activeconns) * 50
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 + atomic_read(&dest->inactconns);
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 doh =3D ip_vs_dest_con=
n_overhead(dest);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if ((loh * atomic=
_read(&dest->weight) >
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0doh * atomic_read(&least->weight))
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 && =
(dest->flags & IP_VS_DEST_F_AVAILABLE)) {
> >> @@ -228,8 +226,7 @@ static inline struct ip_vs_dest *ip_vs_dest_se=
t_max(struct ip_vs_dest_set *set)
> >> =C2=A0 =C2=A0 =C2=A0 list_for_each_entry(e, &set->list, list) {
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 most =3D e->dest;
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (atomic_read(&=
most->weight) > 0) {
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 moh =3D atomic_read(&most->activeconns) * 50
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 + atomic_read(&most->inactconns);
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 moh =3D ip_vs_dest_conn_overhead(most);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 goto nextstage;
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> >> =C2=A0 =C2=A0 =C2=A0 }
> >> @@ -239,8 +236,7 @@ static inline struct ip_vs_dest *ip_vs_dest_se=
t_max(struct ip_vs_dest_set *set)
> >> =C2=A0 =C2=A0nextstage:
> >> =C2=A0 =C2=A0 =C2=A0 list_for_each_entry(e, &set->list, list) {
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dest =3D e->dest;
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 doh =3D atomic_read(&d=
est->activeconns) * 50
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 + atomic_read(&dest->inactconns);
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 doh =3D ip_vs_dest_con=
n_overhead(dest);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* moh/mw < doh/d=
w =3D=3D> moh*dw < doh*mw, where mw,dw>0 */
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if ((moh * atomic=
_read(&dest->weight) <
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0doh * atomic_read(&most->weight))
> >> @@ -563,12 +559,7 @@ __ip_vs_lblcr_schedule(struct ip_vs_service *=
svc)
> >> =C2=A0 =C2=A0 =C2=A0 int loh, doh;
> >>
> >> =C2=A0 =C2=A0 =C2=A0 /*
> >> - =C2=A0 =C2=A0 =C2=A0* We think the overhead of processing active=
 connections is fifty
> >> - =C2=A0 =C2=A0 =C2=A0* times higher than that of inactive connect=
ions in average. (This
> >> - =C2=A0 =C2=A0 =C2=A0* fifty times might not be accurate, we will=
 change it later.) We
> >> - =C2=A0 =C2=A0 =C2=A0* use the following formula to estimate the =
overhead:
> >> - =C2=A0 =C2=A0 =C2=A0* =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0dest->activeconns*50 + dest->inactconns
> >> - =C2=A0 =C2=A0 =C2=A0* and the load:
> >> + =C2=A0 =C2=A0 =C2=A0* We use the following formula to estimate t=
he load:
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0* =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0(dest overhead) / dest->weight
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0*
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0* Remember -- no floats in kernel mode!=
!!
> >> @@ -585,8 +576,7 @@ __ip_vs_lblcr_schedule(struct ip_vs_service *s=
vc)
> >>
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (atomic_read(&=
dest->weight) > 0) {
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 least =3D dest;
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 loh =3D atomic_read(&least->activeconns) * 50
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 + atomic_read(&least->inactconns);
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 loh =3D ip_vs_dest_conn_overhead(least);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 goto nextstage;
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> >> =C2=A0 =C2=A0 =C2=A0 }
> >> @@ -600,8 +590,7 @@ __ip_vs_lblcr_schedule(struct ip_vs_service *s=
vc)
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (dest->flags &=
 IP_VS_DEST_F_OVERLOAD)
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 continue;
> >>
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 doh =3D atomic_read(&d=
est->activeconns) * 50
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 + atomic_read(&dest->inactconns);
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 doh =3D ip_vs_dest_con=
n_overhead(dest);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (loh * atomic_=
read(&dest->weight) >
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 doh=
 * atomic_read(&least->weight)) {
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 least =3D dest;
> >> diff --git a/net/netfilter/ipvs/ip_vs_lc.c b/net/netfilter/ipvs/ip=
_vs_lc.c
> >> index 4f69db1..160cb80 100644
> >> --- a/net/netfilter/ipvs/ip_vs_lc.c
> >> +++ b/net/netfilter/ipvs/ip_vs_lc.c
> >> @@ -22,22 +22,6 @@
> >>
> >> =C2=A0#include <net/ip_vs.h>
> >>
> >> -
> >> -static inline unsigned int
> >> -ip_vs_lc_dest_overhead(struct ip_vs_dest *dest)
> >> -{
> >> - =C2=A0 =C2=A0 /*
> >> - =C2=A0 =C2=A0 =C2=A0* We think the overhead of processing active=
 connections is 256
> >> - =C2=A0 =C2=A0 =C2=A0* times higher than that of inactive connect=
ions in average. (This
> >> - =C2=A0 =C2=A0 =C2=A0* 256 times might not be accurate, we will c=
hange it later) We
> >> - =C2=A0 =C2=A0 =C2=A0* use the following formula to estimate the =
overhead now:
> >> - =C2=A0 =C2=A0 =C2=A0* =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0dest->activeconns*256 + dest->inactconns
> >> - =C2=A0 =C2=A0 =C2=A0*/
> >> - =C2=A0 =C2=A0 return (atomic_read(&dest->activeconns) << 8) +
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 atomic_read(&dest->ina=
ctconns);
> >> -}
> >> -
> >> -
> >> =C2=A0/*
> >> =C2=A0 * =C2=A0 Least Connection scheduling
> >> =C2=A0 */
> >> @@ -62,7 +46,7 @@ ip_vs_lc_schedule(struct ip_vs_service *svc, con=
st struct sk_buff *skb)
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if ((dest->flags =
& IP_VS_DEST_F_OVERLOAD) ||
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ato=
mic_read(&dest->weight) =3D=3D 0)
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 continue;
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 doh =3D ip_vs_lc_dest_=
overhead(dest);
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 doh =3D ip_vs_dest_con=
n_overhead(dest);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!least || doh=
 < loh) {
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 least =3D dest;
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 loh =3D doh;
> >> diff --git a/net/netfilter/ipvs/ip_vs_wlc.c b/net/netfilter/ipvs/i=
p_vs_wlc.c
> >> index bbddfdb..db751f5 100644
> >> --- a/net/netfilter/ipvs/ip_vs_wlc.c
> >> +++ b/net/netfilter/ipvs/ip_vs_wlc.c
> >> @@ -27,22 +27,6 @@
> >>
> >> =C2=A0#include <net/ip_vs.h>
> >>
> >> -
> >> -static inline unsigned int
> >> -ip_vs_wlc_dest_overhead(struct ip_vs_dest *dest)
> >> -{
> >> - =C2=A0 =C2=A0 /*
> >> - =C2=A0 =C2=A0 =C2=A0* We think the overhead of processing active=
 connections is 256
> >> - =C2=A0 =C2=A0 =C2=A0* times higher than that of inactive connect=
ions in average. (This
> >> - =C2=A0 =C2=A0 =C2=A0* 256 times might not be accurate, we will c=
hange it later) We
> >> - =C2=A0 =C2=A0 =C2=A0* use the following formula to estimate the =
overhead now:
> >> - =C2=A0 =C2=A0 =C2=A0* =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0dest->activeconns*256 + dest->inactconns
> >> - =C2=A0 =C2=A0 =C2=A0*/
> >> - =C2=A0 =C2=A0 return (atomic_read(&dest->activeconns) << 8) +
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 atomic_read(&dest->ina=
ctconns);
> >> -}
> >> -
> >> -
> >> =C2=A0/*
> >> =C2=A0 * =C2=A0 Weighted Least Connection scheduling
> >> =C2=A0 */
> >> @@ -71,7 +55,7 @@ ip_vs_wlc_schedule(struct ip_vs_service *svc, co=
nst struct sk_buff *skb)
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!(dest->flags=
 & IP_VS_DEST_F_OVERLOAD) &&
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ato=
mic_read(&dest->weight) > 0) {
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 least =3D dest;
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 loh =3D ip_vs_wlc_dest_overhead(least);
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 loh =3D ip_vs_dest_conn_overhead(least);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 goto nextstage;
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> >> =C2=A0 =C2=A0 =C2=A0 }
> >> @@ -85,7 +69,7 @@ ip_vs_wlc_schedule(struct ip_vs_service *svc, co=
nst struct sk_buff *skb)
> >> =C2=A0 =C2=A0 =C2=A0 list_for_each_entry_continue(dest, &svc->dest=
inations, n_list) {
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (dest->flags &=
 IP_VS_DEST_F_OVERLOAD)
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 continue;
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 doh =3D ip_vs_wlc_dest=
_overhead(dest);
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 doh =3D ip_vs_dest_con=
n_overhead(dest);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (loh * atomic_=
read(&dest->weight) >
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 doh=
 * atomic_read(&least->weight)) {
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 least =3D dest;
> >>
> >
>=20
