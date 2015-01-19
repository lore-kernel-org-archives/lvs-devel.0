From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 1/2] IPVS: add wlib & wlip schedulers
Date: Tue, 20 Jan 2015 01:17:35 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1501192342190.2687@ja.home.ssi.bg>
References: <Pine.LNX.4.44.0501260832210.17893-100000@nacho.alt.net> <Pine.LNX.4.61.0502010007060.1148@penguin.linux-vs.org> <Pine.LNX.4.64.1501172217420.8217@nacho.alt.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1501172217420.8217@nacho.alt.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Chris Caputo <ccaputo@alt.net>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org


	Hello,

On Sat, 17 Jan 2015, Chris Caputo wrote:

> From: Chris Caputo <ccaputo@alt.net> 
> 
> IPVS wlib (Weighted Least Incoming Byterate) and wlip (Weighted Least Incoming 
> Packetrate) schedulers, updated for 3.19-rc4.

	The IPVS estimator uses 2-second timer to update
the stats, isn't that a problem for such schedulers?
Also, you schedule by incoming traffic rate which is
ok when clients mostly upload. But in the common case
clients mostly download and IPVS processes download
traffic only for NAT method.

	May be not so useful idea: use sum of both directions
or control it with svc->flags & IP_VS_SVC_F_SCHED_WLIB_xxx
flags, see how "sh" scheduler supports flags. I.e.
inbps + outbps.

	Another problem: pps and bps are shifted values,
see how ip_vs_read_estimator() reads them. ip_vs_est.c
contains comments that this code handles couple of
gigabits. May be inbps and outbps in struct ip_vs_estimator
should be changed to u64 to support more gigabits, with
separate patch.

> Signed-off-by: Chris Caputo <ccaputo@alt.net>
> ---
> +++ linux-3.19-rc4/net/netfilter/ipvs/ip_vs_wlib.c	2015-01-17 22:47:35.421861075 +0000

> +/* Weighted Least Incoming Byterate scheduling */
> +static struct ip_vs_dest *
> +ip_vs_wlib_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
> +		    struct ip_vs_iphdr *iph)
> +{
> +	struct list_head *p, *q;
> +	struct ip_vs_dest *dest, *least = NULL;
> +	u32 dr, lr = -1;
> +	int dwgt, lwgt = 0;

	To support u64 result from 32-bit multiply we can
change the vars as follows:

u32 dwgt, lwgt = 0;

> +	spin_lock_bh(&svc->sched_lock);
> +	p = (struct list_head *)svc->sched_data;
> +	p = list_next_rcu(p);

	Note that dests are deleted from svc->destinations
out of any lock (from __ip_vs_unlink_dest), above lock
svc->sched_lock protects only svc->sched_data.

	So, RCU dereference is needed here, list_next_rcu is
not enough. Better to stick to the list walking from the
rr algorithm in ip_vs_rr.c.

> +	q = p;
> +	do {
> +		/* skip list head */
> +		if (q == &svc->destinations) {
> +			q = list_next_rcu(q);
> +			continue;
> +		}
> +
> +		dest = list_entry_rcu(q, struct ip_vs_dest, n_list);
> +		dwgt = atomic_read(&dest->weight);

	This will be dwgt = (u32) atomic_read(&dest->weight);

> +		if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) && dwgt > 0) {
> +			spin_lock(&dest->stats.lock);
> +			dr = dest->stats.ustats.inbps;
> +			spin_unlock(&dest->stats.lock);
> +
> +			if (!least ||
> +			    (u64)dr * (u64)lwgt < (u64)lr * (u64)dwgt ||

	This will be (u64)dr * lwgt < (u64)lr * dwgt ||

	See commit c16526a7b99c1c for 32x32 multiply.

> +			    (dr == lr && dwgt > lwgt)) {

	Above check is redundant.

> +				least = dest;
> +				lr = dr;
> +				lwgt = dwgt;
> +				svc->sched_data = q;

	Better to update sched_data at final, see below...

> +			}
> +		}
> +		q = list_next_rcu(q);
> +	} while (q != p);

	if (least)
		svc->sched_data = &least->n_list;

> +	spin_unlock_bh(&svc->sched_lock);

	Same comments for wlip.

Regards

--
Julian Anastasov <ja@ssi.bg>
