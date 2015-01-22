From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/3] IPVS: add wlib & wlip schedulers
Date: Thu, 22 Jan 2015 23:07:48 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1501222250220.2572@ja.home.ssi.bg>
References: <Pine.LNX.4.44.0501260832210.17893-100000@nacho.alt.net> <Pine.LNX.4.61.0502010007060.1148@penguin.linux-vs.org> <Pine.LNX.4.64.1501172217420.8217@nacho.alt.net> <alpine.LFD.2.11.1501192342190.2687@ja.home.ssi.bg>
 <Pine.LNX.4.64.1501202316450.8217@nacho.alt.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1501202316450.8217@nacho.alt.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Chris Caputo <ccaputo@alt.net>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org


	Hello,

On Tue, 20 Jan 2015, Chris Caputo wrote:

> On Tue, 20 Jan 2015, Julian Anastasov wrote:
> > > +                      (u64)dr * (u64)lwgt < (u64)lr * (u64)dwgt ||
> [...]
> > > +  	                   (dr == lr && dwgt > lwgt)) {
> > 
> > 	Above check is redundant.
> 
> I accepted your feedback and applied it to the below, except for this 
> item.  I believe if dr and lr are zero (no traffic), we still want to 
> choose the higher weight, thus a separate comparison is needed.

	ok

> +	spin_lock_bh(&svc->sched_lock);
> +	p = (struct list_head *)svc->sched_data;
> +	last = dest = list_entry(p, struct ip_vs_dest, n_list);
> +
> +	do {
> +		list_for_each_entry_continue_rcu(dest,
> +						 &svc->destinations,
> +						 n_list) {
> +			dwgt = (u32)atomic_read(&dest->weight);
> +			if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
> +			    dwgt > 0) {
> +                               spin_lock(&dest->stats.lock);

	May be there is a way to avoid this spin_lock
by using u64_stats_fetch_begin and corresponding
u64_stats_update_begin in estimation_timer(). We can
even remove this ->lock, it will be replaced by ->syncp.
The benefit is for 64-bit platforms where we avoid
lock here in the scheduler. Otherwise, I don't see
other implementation problems in this patch and I'll
check it more carefully this weekend.

Regards

--
Julian Anastasov <ja@ssi.bg>
