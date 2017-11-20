From: Inju Song <inju.song@navercorp.com>
Subject: Re: [PATCH] netfilter: ipvs: Add Maglev consistent hashing scheduler
Date: Tue, 21 Nov 2017 01:36:08 +0900
Message-ID: <20171120163607.GA26139@centos7.nhncorp.com>
References: <20171119063507.GA9306@centos7.nhncorp.com>
 <alpine.LFD.2.20.1711191748110.2409@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.20.1711191748110.2409@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, =?iso-8859-1?Q?=A0Wensong?= Zhang <wensong@linux-vs.org>, =?iso-8859-1?Q?=A0Simon?= Horman <horms@verge.net.au>

Hello, Julian

Thank you for your a lot of comments.

On Sun, Nov 19, 2017 at 06:04:35PM +0200, Julian Anastasov wrote:
>=20
> 	Hello,
>=20
> On Sun, 19 Nov 2017, Inju Song wrote:
>=20
> > Implements the Google's Maglev hashing algorithm as a IPVS scheduler.
> >=20
> > Basically it provides consistent hashing but=A0offers some special
> > features about disruption and load balancing.
> >=20
> >   1)=A0minimal disruption: when the set of destinations changes,
> >      a connection will likely be sent to the same destination
> >      as it was before.
> >=20
> >   2)=A0load balancing: each destination will receive an almost
> >      equal number of connections.
> >=20
> > Seel also for detail: [3.4 Consistent Hasing] in
> > https://static.googleusercontent.com/media/research.google.com/ko//pubs=
/archive/44824.pdf
>=20
> 	 I see that the PDF shows implementation only for servers
> with same weight. It would be better to see implementation that
> considers dest->weight.
>=20

I agree. In this case, weight value is same weight or zero.
So I will consider this case when I patch the source.

I have read your comments about memory allocation fail,
caching table, setting the entry table with NULLs and so on.

I will do fix it and send v2 patchsets.

> > Signed-off-by: Inju Song <inju.song@navercorp.com>
> > ---
> >  net/netfilter/ipvs/ip_vs_mh.c | 402 ++++++++++++++++++++++++++++++++++=
++++++++
> >  1 file changed, 402 insertions(+)
> >  create mode 100644 net/netfilter/ipvs/ip_vs_mh.c
> >=20
> > diff --git a/net/netfilter/ipvs/ip_vs_mh.c b/net/netfilter/ipvs/ip_vs_m=
h.c
> > new file mode 100644
> > index 0000000..534a9f5
> > --- /dev/null
> > +++ b/net/netfilter/ipvs/ip_vs_mh.c
>=20
> > +static inline int
> > +ip_vs_mh_populate(struct ip_vs_mh_state *s, struct ip_vs_service *svc,
> > +		  unsigned int **permutation)
> > +{
> > +	int i;
> > +	unsigned int *next;
> > +	struct ip_vs_mh_lookup *entry, *l;
> > +	struct list_head *p;
> > +	struct ip_vs_dest *dest;
> > +	int dcnt;
> > +	unsigned int n, c;
> > +
> > +	dcnt =3D svc->num_dests;
>=20
> 	While calling del_dest svc->num_dests can be 0, this should
> be considered in ip_vs_mh_permutate and ip_vs_mh_populate. We should
> set the table with NULLs in such case.
>=20
> > +	next =3D kcalloc(dcnt, sizeof(unsigned int), GFP_KERNEL);
> > +	entry =3D kcalloc(IP_VS_MH_LOOKUP_SIZE, sizeof(*entry),
> > +			GFP_KERNEL);
>=20
> 	It is current drawback that add_dest, upd_dest and del_dest
> are considered as non-failing methods, we can not fail the operation
> if memory allocation fails, for example. This is bad for add_dest,
> not so for upd_dest and del_dest. In this regard, I think, the MH
> scheduler should not crash if allocation fails.
>=20
> > +/* Assign all the hash buckets of the specified table with the service.
> > + */
> > +static int
> > +ip_vs_mh_reassign(struct ip_vs_mh_state *s, struct ip_vs_service *svc)
> > +{
> > +	int dcnt;
> > +	unsigned int **permutation;
> > +
> > +	/* flush all the hash entry before assigning mh entry */
> > +	ip_vs_mh_flush(s);
>=20
> 	ip_vs_mh_reassign should not call ip_vs_mh_flush.
> ip_vs_mh_populate while copying the temp table to s->lookup[]
> should put the refcnt to old dests (as in SH:ip_vs_sh_reassign)
> and then to assign new value. NULL should be assigned if
> svc->num_dests =3D 0.
>=20
> > +/* IPVS MH Scheduler structure */
> > +static struct ip_vs_scheduler ip_vs_mh_scheduler =3D {
> > +	.name =3D			"mh",
> > +	.refcnt =3D		ATOMIC_INIT(0),
> > +	.module =3D		THIS_MODULE,
> > +	.n_list	 =3D		LIST_HEAD_INIT(ip_vs_mh_scheduler.n_list),
> > +	.init_service =3D		ip_vs_mh_init_svc,
> > +	.done_service =3D		ip_vs_mh_done_svc,
> > +	.add_dest =3D		ip_vs_mh_dest_changed,
> > +	.del_dest =3D		ip_vs_mh_dest_changed,
> > +	.upd_dest =3D		ip_vs_mh_dest_changed,
>=20
> 	As upd_dest is called only when weight changes, the SH and MH
> schedulers should not handle this method. Their goal is to fill
> the table with all added dests by ignoring health state (it is
> considered only on dest selection).
>=20
> 	I guess, the correct configuration for SH and MH would be:
>=20
> 1.1 Add all dests with specific weight, so that the schedulers can
> fill their table based on the weights.
> 1.2 Set weight to 0 for all servers that are not healthy. SH and MH
> should ignore these configuration events.
>=20
> after the initial configuration:
>=20
> 2. Traffic will ignore non-healthy servers, fallbacks to healthy ones.
> 3. If other servers become unavailable, change their weight to 0
>=20
> Regards
>=20
> --
> Julian Anastasov <ja@ssi.bg>

Regards

--=20
Inju Song
NAVER Corporation

