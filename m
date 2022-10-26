From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: use explicitly signed chars
Date: Wed, 26 Oct 2022 17:20:03 +0300 (EEST)
Message-ID: <4cc36ff5-46fd-c2b3-3292-d6369337fec1@ssi.bg>
References: <20221026123216.1575440-1-Jason@zx2c4.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20221026123216.1575440-1-Jason@zx2c4.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Simon Horman <horms@verge.net.au>, stable@vger.kernel.org


	Hello,

On Wed, 26 Oct 2022, Jason A. Donenfeld wrote:

> The `char` type with no explicit sign is sometimes signed and sometimes
> unsigned. This code will break on platforms such as arm, where char is
> unsigned. So mark it here as explicitly signed, so that the
> todrop_counter decrement and subsequent comparison is correct.
> 
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Cc: Julian Anastasov <ja@ssi.bg>
> Cc: Simon Horman <horms@verge.net.au>
> Cc: stable@vger.kernel.org
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>

	Looks good to me for -next, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_conn.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 8c04bb57dd6f..7c4866c04343 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -1249,40 +1249,40 @@ static const struct seq_operations ip_vs_conn_sync_seq_ops = {
>  	.next  = ip_vs_conn_seq_next,
>  	.stop  = ip_vs_conn_seq_stop,
>  	.show  = ip_vs_conn_sync_seq_show,
>  };
>  #endif
>  
>  
>  /* Randomly drop connection entries before running out of memory
>   * Can be used for DATA and CTL conns. For TPL conns there are exceptions:
>   * - traffic for services in OPS mode increases ct->in_pkts, so it is supported
>   * - traffic for services not in OPS mode does not increase ct->in_pkts in
>   * all cases, so it is not supported
>   */
>  static inline int todrop_entry(struct ip_vs_conn *cp)
>  {
>  	/*
>  	 * The drop rate array needs tuning for real environments.
>  	 * Called from timer bh only => no locking
>  	 */
> -	static const char todrop_rate[9] = {0, 1, 2, 3, 4, 5, 6, 7, 8};
> -	static char todrop_counter[9] = {0};
> +	static const signed char todrop_rate[9] = {0, 1, 2, 3, 4, 5, 6, 7, 8};
> +	static signed char todrop_counter[9] = {0};
>  	int i;
>  
>  	/* if the conn entry hasn't lasted for 60 seconds, don't drop it.
>  	   This will leave enough time for normal connection to get
>  	   through. */
>  	if (time_before(cp->timeout + jiffies, cp->timer.expires + 60*HZ))
>  		return 0;
>  
>  	/* Don't drop the entry if its number of incoming packets is not
>  	   located in [0, 8] */
>  	i = atomic_read(&cp->in_pkts);
>  	if (i > 8 || i < 0) return 0;
>  
>  	if (!todrop_rate[i]) return 0;
>  	if (--todrop_counter[i] > 0) return 0;
>  
>  	todrop_counter[i] = todrop_rate[i];
>  	return 1;
>  }
> -- 
> 2.38.1

Regards

--
Julian Anastasov <ja@ssi.bg>

