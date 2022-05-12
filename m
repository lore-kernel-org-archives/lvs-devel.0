From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next v2] net: ipvs: randomize starting destination
 of RR/WRR scheduler
Date: Thu, 12 May 2022 13:33:39 +0300 (EEST)
Message-ID: <bb1d68e0-de27-985f-19b-208fb546a0b1@ssi.bg>
References: <20220510074301.480941-1-imagedong@tencent.com> <8983fedf-5095-59a4-b4b3-83f1864be055@ssi.bg> <CADxym3aREm=ZPucm=C6ZRnPbQJMvCxkcnKge2EAcy-Rs0CTtfg@mail.gmail.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CADxym3aREm=ZPucm=C6ZRnPbQJMvCxkcnKge2EAcy-Rs0CTtfg@mail.gmail.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Menglong Dong <menglong8.dong@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Menglong Dong <imagedong@tencent.com>, Jiang Biao <benbjiang@tencent.com>, Hao Peng <flyingpeng@tencent.com>


	Hello,

On Thu, 12 May 2022, Menglong Dong wrote:

> Yeah, WLC and MH are excellent schedulers. As for SH, my
> fellows' feedback says that it doesn't work well. In fact, it's their
> fault, they just forget to enable port hash and just use the
> default ip hash. With my direction, this case is solved by sh.
> 
> Now, I'm not sure if this feature is necessary. Maybe someone
> needs it? Such as someone, who need RR/WRR and a random
> start......

	If there is some more clever way to add randomness.
The problem is that random start should be applied after
initial configuration only. But there is no clear point between
where configuration is completed and when service starts.
This is not bad for RR but is bad for WRR.

	One way would be the user tool to add dests in random
order. IIRC, this should not affect setups with backup servers
as long as they share the same set of real servers, i.e.
order in svc->destinations does not matter for SYNC but
the real servers should be present in all directors.

	Another option would be __ip_vs_update_dest() to
use list_add_rcu() or list_add_tail_rcu() per dest depending
on some switch that enables random ordering for the svc.
But it will affect only schedulers that do not order
later the dests. So, it should help for RR, WRR (random
order per same weight). In this case, scheduler's code
is not affected.

	For RR, the scheduler does not use weights and
dests are usually not updated. But for WRR the weights
can be changed and this affects order of selection without
changing the order in svc->destinations.

	OTOH, WRR is a scheduler that can support frequent
update of dest weights. This is not true for MH which can
easily change only between 0 and some fixed weight without
changing its table. As result, ip_vs_wrr_dest_changed()
can be called frequently even after the initial configuration,
at the same time while packets are scheduled.

	When you mentioned that ip_vs_wrr_gcd_weight() is
slow, I see that ip_vs_wrr_dest_changed() can be improved
to reduce the time while holding the lock. May be
in separate patch we can call ip_vs_wrr_gcd_weight() and
ip_vs_wrr_max_weight() before the spin_lock_bh() by using
two new tmp vars.

> Anyway, I have made a V3 according to your advice. I can
> send it with any positive reply :/

	You can use [RFC tag] for this, so that we can
at least review it and further decide what can be done.

Regards

--
Julian Anastasov <ja@ssi.bg>

