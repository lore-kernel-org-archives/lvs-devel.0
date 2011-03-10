From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 03/18] ipvs: zero percpu stats
Date: Thu, 10 Mar 2011 10:34:42 +0900
Message-ID: <20110310013442.GD3028@verge.net.au>
References: <1299368760-14271-1-git-send-email-horms@verge.net.au>
 <1299368760-14271-4-git-send-email-horms@verge.net.au>
 <1299402367.2758.87.camel@edumazet-laptop>
 <alpine.LFD.2.00.1103061218470.1879@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1103061218470.1879@ja.ssi.bg>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org, Hans Schillstrom <hans@schillstrom.com>

On Sun, Mar 06, 2011 at 02:18:35PM +0200, Julian Anastasov wrote:

[ snip ]

> 	Zero the new percpu stats because we copy from there.
> Use the stats spin lock to synchronize the percpu zeroing with
> the percpu reading, both in user context and not in a hot path.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Eric, do you have any thoughts on this?
It seems clean to me.

> ---
> 
> diff -urp lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_ctl.c linux/net/netfilter/ipvs/ip_vs_ctl.c
> --- lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_ctl.c	2011-03-06 13:39:59.000000000 +0200
> +++ linux/net/netfilter/ipvs/ip_vs_ctl.c	2011-03-06 13:44:56.108275455 +0200
> @@ -713,8 +713,25 @@ static void ip_vs_trash_cleanup(struct n
>  static void
>  ip_vs_zero_stats(struct ip_vs_stats *stats)
>  {
> +	struct ip_vs_cpu_stats *cpustats = stats->cpustats;
> +	int i;
> +
>  	spin_lock_bh(&stats->lock);
> 
> +	for_each_possible_cpu(i) {
> +		struct ip_vs_cpu_stats *u = per_cpu_ptr(cpustats, i);
> +		unsigned int start;
> +
> +		/* Do not pretend to be writer, it is enough to
> +		 * sync with writers that modify the u64 counters
> +		 * because under stats->lock there are no other readers
> +		 */
> +		do {
> +			start = u64_stats_fetch_begin(&u->syncp);
> +			memset(&u->ustats, 0, sizeof(u->ustats));
> +		} while (u64_stats_fetch_retry(&u->syncp, start));
> +	}
> +
>  	memset(&stats->ustats, 0, sizeof(stats->ustats));
>  	ip_vs_zero_estimator(stats);
> 
> @@ -2015,16 +2032,19 @@ static int ip_vs_stats_percpu_show(struc
>  	seq_printf(seq,
>  		   "CPU    Conns  Packets  Packets            Bytes            Bytes\n");
> 
> +	/* Use spin lock early to synchronize with percpu zeroing */
> +	spin_lock_bh(&tot_stats->lock);
> +
>  	for_each_possible_cpu(i) {
>  		struct ip_vs_cpu_stats *u = per_cpu_ptr(cpustats, i);
>  		unsigned int start;
>  		__u64 inbytes, outbytes;
> 
>  		do {
> -			start = u64_stats_fetch_begin_bh(&u->syncp);
> +			start = u64_stats_fetch_begin(&u->syncp);
>  			inbytes = u->ustats.inbytes;
>  			outbytes = u->ustats.outbytes;
> -		} while (u64_stats_fetch_retry_bh(&u->syncp, start));
> +		} while (u64_stats_fetch_retry(&u->syncp, start));
> 
>  		seq_printf(seq, "%3X %8X %8X %8X %16LX %16LX\n",
>  			   i, u->ustats.conns, u->ustats.inpkts,
> @@ -2032,7 +2052,6 @@ static int ip_vs_stats_percpu_show(struc
>  			   (__u64)outbytes);
>  	}
> 
> -	spin_lock_bh(&tot_stats->lock);
>  	seq_printf(seq, "  ~ %8X %8X %8X %16LX %16LX\n\n",
>  		   tot_stats->ustats.conns, tot_stats->ustats.inpkts,
>  		   tot_stats->ustats.outpkts,
> 
