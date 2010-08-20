From: Simon Horman <horms@verge.net.au>
Subject: Re: [rfc] IPVS: convert scheduler management to RCU
Date: Fri, 20 Aug 2010 23:33:59 +0900
Message-ID: <20100820143359.GB2277@verge.net.au>
References: <20100820133320.GA29311@verge.net.au>
 <AANLkTimS7V3z1kEwmEFCCvPzJX=D9Oqw=BNEuN-YZ0tx@mail.gmail.com>
 <1282313150.2484.65.camel@edumazet-laptop>
 <AANLkTi=t7wDZO23Cim1LJ_Ot2FUe4bR+XG6H5uJfTuG+@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTi=t7wDZO23Cim1LJ_Ot2FUe4bR+XG6H5uJfTuG+@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: yao zhao <dragonlinux@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Changli Gao <xiaosuo@gmail.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Paul E McKenney <paulmck@linux.vnet.ibm.com>

On Fri, Aug 20, 2010 at 10:16:23AM -0400, yao zhao wrote:
> On Fri, Aug 20, 2010 at 10:05 AM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
> > Le vendredi 20 ao=C3=BBt 2010 =C3=A0 21:44 +0800, Changli Gao a =C3=
=A9crit :
> >> On Fri, Aug 20, 2010 at 9:33 PM, Simon Horman <horms@verge.net.au>=
 wrote:
> >> > Signed-off-by: Simon Horman <horms@verge.net.au>
> >> >
> >> > ---
> >> >
> >> > I'm still getting my head around RCU, so review would be greatly=
 appreciated.
> >> >
> >> > It occurs to me that this code is not performance critical, so
> >> > perhaps simply replacing the rwlock with a spinlock would be bet=
ter?
> >> >
> >> > Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_sched.c
> >
> >
> >> > - =C2=A0 =C2=A0 =C2=A0 write_unlock_bh(&__ip_vs_sched_lock);
> >> > + =C2=A0 =C2=A0 =C2=A0 list_del_rcu(&scheduler->n_list);
> >> > + =C2=A0 =C2=A0 =C2=A0 spin_unlock_bh(&ip_vs_sched_mutex);
> >>
> >> Need a rcu_barrier_bh().
> >>
> >> >
> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/* decrease the module use count */
> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0ip_vs_use_count_dec();
> >
> >
> > Quite frankly, if this is not performance critical, just use the
> > spinlock (and dont use 'mutex' in its name ;) )
> >
> if it is not performance critical, you should use  the
> read_lock/write_lock, it should make the readers happier than
> spinlock.

The whole point of the exercise is to stop using read_lock/write_lock
because they are generally slower than a spinlock.

> the name "mutex" is a little bit confuse.
> synchronize_rcu() is not necessary when you only need to delete from =
a
> list as it is atomic.
>
> > Using RCU here will force at least one RCU grace period at dismantl=
e
> > time...
> >
> >
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.=
html
> >
>=20
> yao
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
