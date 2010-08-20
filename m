From: Simon Horman <horms@verge.net.au>
Subject: Re: [rfc] IPVS: convert scheduler management to RCU
Date: Fri, 20 Aug 2010 23:31:52 +0900
Message-ID: <20100820143148.GA2277@verge.net.au>
References: <20100820133320.GA29311@verge.net.au>
 <AANLkTimS7V3z1kEwmEFCCvPzJX=D9Oqw=BNEuN-YZ0tx@mail.gmail.com>
 <1282313150.2484.65.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1282313150.2484.65.camel@edumazet-laptop>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Changli Gao <xiaosuo@gmail.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Paul E McKenney <paulmck@linux.vnet.ibm.com>

On Fri, Aug 20, 2010 at 04:05:50PM +0200, Eric Dumazet wrote:
> Le vendredi 20 ao=C3=BBt 2010 =C3=A0 21:44 +0800, Changli Gao a =C3=A9=
crit :
> > On Fri, Aug 20, 2010 at 9:33 PM, Simon Horman <horms@verge.net.au> =
wrote:
> > > Signed-off-by: Simon Horman <horms@verge.net.au>
> > >
> > > ---
> > >
> > > I'm still getting my head around RCU, so review would be greatly =
appreciated.
> > >
> > > It occurs to me that this code is not performance critical, so
> > > perhaps simply replacing the rwlock with a spinlock would be bett=
er?
> > >
> > > Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_sched.c
>=20
>=20
> > > -       write_unlock_bh(&__ip_vs_sched_lock);
> > > +       list_del_rcu(&scheduler->n_list);
> > > +       spin_unlock_bh(&ip_vs_sched_mutex);
> >=20
> > Need a rcu_barrier_bh().
> >=20
> > >
> > >        /* decrease the module use count */
> > >        ip_vs_use_count_dec();
>=20
>=20
> Quite frankly, if this is not performance critical, just use the
> spinlock (and dont use 'mutex' in its name ;) )

Will do.

> Using RCU here will force at least one RCU grace period at dismantle
> time...
>=20
>=20
