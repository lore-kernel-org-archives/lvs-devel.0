From: Simon Horman <horms@verge.net.au>
Subject: Re: [rfc] IPVS: convert scheduler management to RCU
Date: Fri, 20 Aug 2010 23:00:02 +0900
Message-ID: <20100820140002.GC17980@verge.net.au>
References: <20100820133320.GA29311@verge.net.au>
 <AANLkTimS7V3z1kEwmEFCCvPzJX=D9Oqw=BNEuN-YZ0tx@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTimS7V3z1kEwmEFCCvPzJX=D9Oqw=BNEuN-YZ0tx@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Changli Gao <xiaosuo@gmail.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Paul E McKenney <paulmck@linux.vnet.ibm.com>

On Fri, Aug 20, 2010 at 09:44:08PM +0800, Changli Gao wrote:
> On Fri, Aug 20, 2010 at 9:33 PM, Simon Horman <horms@verge.net.au> wr=
ote:
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> >
> > ---
> >
> > I'm still getting my head around RCU, so review would be greatly ap=
preciated.
> >
> > It occurs to me that this code is not performance critical, so
> > perhaps simply replacing the rwlock with a spinlock would be better=
?
> >
> > Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_sched.c
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > --- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_sched.c =C2=A0 2010-0=
8-20 22:21:01.000000000 +0900
> > +++ nf-next-2.6/net/netfilter/ipvs/ip_vs_sched.c =C2=A0 =C2=A0 =C2=A0=
 =C2=A02010-08-20 22:21:51.000000000 +0900
> > @@ -35,7 +35,7 @@
> > =C2=A0static LIST_HEAD(ip_vs_schedulers);
> >
> > =C2=A0/* lock for service table */
> > -static DEFINE_RWLOCK(__ip_vs_sched_lock);
> > +static DEFINE_SPINLOCK(ip_vs_sched_mutex);
> >
> >
> > =C2=A0/*
> > @@ -91,9 +91,9 @@ static struct ip_vs_scheduler *ip_vs_sch
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0IP_VS_DBG(2, "%s(): sched_name \"%s\"\n"=
, __func__, sched_name);
> >
> > - =C2=A0 =C2=A0 =C2=A0 read_lock_bh(&__ip_vs_sched_lock);
> > + =C2=A0 =C2=A0 =C2=A0 rcu_read_lock_bh();
> >
> > - =C2=A0 =C2=A0 =C2=A0 list_for_each_entry(sched, &ip_vs_schedulers=
, n_list) {
> > + =C2=A0 =C2=A0 =C2=A0 list_for_each_entry_rcu(sched, &ip_vs_schedu=
lers, n_list) {
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Test and =
get the modules atomically
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> > @@ -105,14 +105,14 @@ static struct ip_vs_scheduler *ip_vs_sch
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (strcmp(s=
ched_name, sched->name)=3D=3D0) {
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* HIT */
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 read_unlock_bh(&__ip_vs_sched_lock);
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 rcu_read_unlock_bh();
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0return sched;
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (sched->m=
odule)
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0module_put(sched->module);
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> >
> > - =C2=A0 =C2=A0 =C2=A0 read_unlock_bh(&__ip_vs_sched_lock);
> > + =C2=A0 =C2=A0 =C2=A0 rcu_read_unlock_bh();
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0return NULL;
> > =C2=A0}
> >
> > @@ -167,10 +167,10 @@ int register_ip_vs_scheduler(struct ip_v
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/* increase the module use count */
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0ip_vs_use_count_inc();
> >
> > - =C2=A0 =C2=A0 =C2=A0 write_lock_bh(&__ip_vs_sched_lock);
> > + =C2=A0 =C2=A0 =C2=A0 spin_lock_bh(&ip_vs_sched_mutex);
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!list_empty(&scheduler->n_list)) {
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 write_unlock_bh(=
&__ip_vs_sched_lock);
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock_bh(&=
ip_vs_sched_mutex);
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ip_vs_use_co=
unt_dec();
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_err("%s()=
: [%s] scheduler already linked\n",
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 __func__, scheduler->name);
> > @@ -181,9 +181,9 @@ int register_ip_vs_scheduler(struct ip_v
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 * =C2=A0Make sure that the scheduler wi=
th this name doesn't exist
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 * =C2=A0in the scheduler list.
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> > - =C2=A0 =C2=A0 =C2=A0 list_for_each_entry(sched, &ip_vs_schedulers=
, n_list) {
> > + =C2=A0 =C2=A0 =C2=A0 list_for_each_entry_rcu(sched, &ip_vs_schedu=
lers, n_list) {
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (strcmp(s=
cheduler->name, sched->name) =3D=3D 0) {
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 write_unlock_bh(&__ip_vs_sched_lock);
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 spin_unlock_bh(&ip_vs_sched_mutex);
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0ip_vs_use_count_dec();
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0pr_err("%s(): [%s] scheduler already existed "
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "in the system\n", __func__, schedu=
ler->name);
> > @@ -193,8 +193,8 @@ int register_ip_vs_scheduler(struct ip_v
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 * =C2=A0 =C2=A0 =C2=A0Add it into the d=
-linked scheduler list
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> > - =C2=A0 =C2=A0 =C2=A0 list_add(&scheduler->n_list, &ip_vs_schedule=
rs);
> > - =C2=A0 =C2=A0 =C2=A0 write_unlock_bh(&__ip_vs_sched_lock);
> > + =C2=A0 =C2=A0 =C2=A0 list_add_rcu(&scheduler->n_list, &ip_vs_sche=
dulers);
> > + =C2=A0 =C2=A0 =C2=A0 spin_unlock_bh(&ip_vs_sched_mutex);
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_info("[%s] scheduler registered.\n", =
scheduler->name);
> >
> > @@ -212,9 +212,9 @@ int unregister_ip_vs_scheduler(struct ip
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EINV=
AL;
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> >
> > - =C2=A0 =C2=A0 =C2=A0 write_lock_bh(&__ip_vs_sched_lock);
> > + =C2=A0 =C2=A0 =C2=A0 spin_lock_bh(&ip_vs_sched_mutex);
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (list_empty(&scheduler->n_list)) {
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 write_unlock_bh(=
&__ip_vs_sched_lock);
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock_bh(&=
ip_vs_sched_mutex);
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_err("%s()=
: [%s] scheduler is not in the list. failed\n",
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 __func__, scheduler->name);
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EINV=
AL;
> > @@ -223,8 +223,8 @@ int unregister_ip_vs_scheduler(struct ip
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 * =C2=A0 =C2=A0 =C2=A0Remove it from th=
e d-linked scheduler list
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> > - =C2=A0 =C2=A0 =C2=A0 list_del(&scheduler->n_list);
> > - =C2=A0 =C2=A0 =C2=A0 write_unlock_bh(&__ip_vs_sched_lock);
> > + =C2=A0 =C2=A0 =C2=A0 list_del_rcu(&scheduler->n_list);
> > + =C2=A0 =C2=A0 =C2=A0 spin_unlock_bh(&ip_vs_sched_mutex);
>=20
> Need a rcu_barrier_bh().

Thanks.

>=20
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/* decrease the module use count */
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0ip_vs_use_count_dec();
>=20
>=20
>=20
> --=20
> Regards,
> Changli Gao(xiaosuo@gmail.com)
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-d=
evel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
