From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH] ipvs: Embed user stats structure into kernel stats structure
Date: Mon, 8 Sep 2008 16:07:10 +0200
Message-ID: <f4845fc0809080707i3751e5a4o45da7b7b16f50c4e@mail.gmail.com>
References: <alpine.LNX.2.00.0809081338130.18192@titan.stealer.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220882835; bh=8CKFLkKH7vZPrQLHAKtcw+mwoPA=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References:X-Spam-Report:X-Scanned-By; b=WrNp1
	qSLltc9McyprWgdEuC9bhYQTRK7NbLz37FVJ1zfjreajrqzaBFGLILGwGiIZV+5cvre
	Jw2mGErJ4Pi1QA==
In-Reply-To: <alpine.LNX.2.00.0809081338130.18192@titan.stealer.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Sven Wegener <sven.wegener@stealer.net>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>

On Mon, Sep 8, 2008 at 1:39 PM, Sven Wegener wrote:
> Instead of duplicating the fields, integrate a user stats structure into
> the kernel stats structure. This is more robust when the members are
> changed, because they are now automatically kept in sync.
>
> Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
> ---
>  include/net/ip_vs.h        |   21 +---------------
>  net/ipv4/ipvs/ip_vs_core.c |   30 ++++++++++++------------
>  net/ipv4/ipvs/ip_vs_ctl.c  |   53 +++++++++++++++++--------------------------
>  net/ipv4/ipvs/ip_vs_est.c  |   40 ++++++++++++++++----------------
>  4 files changed, 58 insertions(+), 86 deletions(-)
>
> Based on lvs-next.
>
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 38f4f69..33e2ac6 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -254,27 +254,10 @@ struct ip_vs_estimator {
>
>  struct ip_vs_stats
>  {
> -       __u32                   conns;          /* connections scheduled */
> -       __u32                   inpkts;         /* incoming packets */
> -       __u32                   outpkts;        /* outgoing packets */
> -       __u64                   inbytes;        /* incoming bytes */
> -       __u64                   outbytes;       /* outgoing bytes */
> -
> -       __u32                   cps;            /* current connection rate */
> -       __u32                   inpps;          /* current in packet rate */
> -       __u32                   outpps;         /* current out packet rate */
> -       __u32                   inbps;          /* current in byte rate */
> -       __u32                   outbps;         /* current out byte rate */
> -
> -       /*
> -        * Don't add anything before the lock, because we use memcpy() to copy
> -        * the members before the lock to struct ip_vs_stats_user in
> -        * ip_vs_ctl.c.
> -        */
> +       struct ip_vs_stats_user ustats;         /* statistics */
> +       struct ip_vs_estimator  est;            /* estimator */
>
>        spinlock_t              lock;           /* spin lock */
> -
> -       struct ip_vs_estimator  est;            /* estimator */
>  };
>
>  struct dst_entry;
> diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
> index f5180ac..be42635 100644
> --- a/net/ipv4/ipvs/ip_vs_core.c
> +++ b/net/ipv4/ipvs/ip_vs_core.c
> @@ -102,18 +102,18 @@ ip_vs_in_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
>        struct ip_vs_dest *dest = cp->dest;
>        if (dest && (dest->flags & IP_VS_DEST_F_AVAILABLE)) {
>                spin_lock(&dest->stats.lock);
> -               dest->stats.inpkts++;
> -               dest->stats.inbytes += skb->len;
> +               dest->stats.ustats.inpkts++;
> +               dest->stats.ustats.inbytes += skb->len;
>                spin_unlock(&dest->stats.lock);
>
>                spin_lock(&dest->svc->stats.lock);
> -               dest->svc->stats.inpkts++;
> -               dest->svc->stats.inbytes += skb->len;
> +               dest->svc->stats.ustats.inpkts++;
> +               dest->svc->stats.ustats.inbytes += skb->len;
>                spin_unlock(&dest->svc->stats.lock);
>
>                spin_lock(&ip_vs_stats.lock);
> -               ip_vs_stats.inpkts++;
> -               ip_vs_stats.inbytes += skb->len;
> +               ip_vs_stats.ustats.inpkts++;
> +               ip_vs_stats.ustats.inbytes += skb->len;
>                spin_unlock(&ip_vs_stats.lock);
>        }
>  }
> @@ -125,18 +125,18 @@ ip_vs_out_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
>        struct ip_vs_dest *dest = cp->dest;
>        if (dest && (dest->flags & IP_VS_DEST_F_AVAILABLE)) {
>                spin_lock(&dest->stats.lock);
> -               dest->stats.outpkts++;
> -               dest->stats.outbytes += skb->len;
> +               dest->stats.ustats.outpkts++;
> +               dest->stats.ustats.outbytes += skb->len;
>                spin_unlock(&dest->stats.lock);
>
>                spin_lock(&dest->svc->stats.lock);
> -               dest->svc->stats.outpkts++;
> -               dest->svc->stats.outbytes += skb->len;
> +               dest->svc->stats.ustats.outpkts++;
> +               dest->svc->stats.ustats.outbytes += skb->len;
>                spin_unlock(&dest->svc->stats.lock);
>
>                spin_lock(&ip_vs_stats.lock);
> -               ip_vs_stats.outpkts++;
> -               ip_vs_stats.outbytes += skb->len;
> +               ip_vs_stats.ustats.outpkts++;
> +               ip_vs_stats.ustats.outbytes += skb->len;
>                spin_unlock(&ip_vs_stats.lock);
>        }
>  }
> @@ -146,15 +146,15 @@ static inline void
>  ip_vs_conn_stats(struct ip_vs_conn *cp, struct ip_vs_service *svc)
>  {
>        spin_lock(&cp->dest->stats.lock);
> -       cp->dest->stats.conns++;
> +       cp->dest->stats.ustats.conns++;
>        spin_unlock(&cp->dest->stats.lock);
>
>        spin_lock(&svc->stats.lock);
> -       svc->stats.conns++;
> +       svc->stats.ustats.conns++;
>        spin_unlock(&svc->stats.lock);
>
>        spin_lock(&ip_vs_stats.lock);
> -       ip_vs_stats.conns++;
> +       ip_vs_stats.ustats.conns++;
>        spin_unlock(&ip_vs_stats.lock);
>  }
>
> diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
> index e53efe4..993a83f 100644
> --- a/net/ipv4/ipvs/ip_vs_ctl.c
> +++ b/net/ipv4/ipvs/ip_vs_ctl.c
> @@ -744,18 +744,7 @@ ip_vs_zero_stats(struct ip_vs_stats *stats)
>  {
>        spin_lock_bh(&stats->lock);
>
> -       stats->conns = 0;
> -       stats->inpkts = 0;
> -       stats->outpkts = 0;
> -       stats->inbytes = 0;
> -       stats->outbytes = 0;
> -
> -       stats->cps = 0;
> -       stats->inpps = 0;
> -       stats->outpps = 0;
> -       stats->inbps = 0;
> -       stats->outbps = 0;
> -
> +       memset(&stats->ustats, 0, sizeof(stats->ustats));
>        ip_vs_zero_estimator(stats);
>
>        spin_unlock_bh(&stats->lock);
> @@ -1964,20 +1953,20 @@ static int ip_vs_stats_show(struct seq_file *seq, void *v)
>                   "   Conns  Packets  Packets            Bytes            Bytes\n");
>
>        spin_lock_bh(&ip_vs_stats.lock);
> -       seq_printf(seq, "%8X %8X %8X %16LX %16LX\n\n", ip_vs_stats.conns,
> -                  ip_vs_stats.inpkts, ip_vs_stats.outpkts,
> -                  (unsigned long long) ip_vs_stats.inbytes,
> -                  (unsigned long long) ip_vs_stats.outbytes);
> +       seq_printf(seq, "%8X %8X %8X %16LX %16LX\n\n", ip_vs_stats.ustats.conns,
> +                  ip_vs_stats.ustats.inpkts, ip_vs_stats.ustats.outpkts,
> +                  (unsigned long long) ip_vs_stats.ustats.inbytes,
> +                  (unsigned long long) ip_vs_stats.ustats.outbytes);
>
>  /*                 01234567 01234567 01234567 0123456701234567 0123456701234567 */
>        seq_puts(seq,
>                   " Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s\n");
>        seq_printf(seq,"%8X %8X %8X %16X %16X\n",
> -                       ip_vs_stats.cps,
> -                       ip_vs_stats.inpps,
> -                       ip_vs_stats.outpps,
> -                       ip_vs_stats.inbps,
> -                       ip_vs_stats.outbps);
> +                       ip_vs_stats.ustats.cps,
> +                       ip_vs_stats.ustats.inpps,
> +                       ip_vs_stats.ustats.outpps,
> +                       ip_vs_stats.ustats.inbps,
> +                       ip_vs_stats.ustats.outbps);
>        spin_unlock_bh(&ip_vs_stats.lock);
>
>        return 0;
> @@ -2215,7 +2204,7 @@ static void
>  ip_vs_copy_stats(struct ip_vs_stats_user *dst, struct ip_vs_stats *src)
>  {
>        spin_lock_bh(&src->lock);
> -       memcpy(dst, src, (char*)&src->lock - (char*)src);
> +       memcpy(dst, &src->ustats, sizeof(*dst));
>        spin_unlock_bh(&src->lock);
>  }
>
> @@ -2591,16 +2580,16 @@ static int ip_vs_genl_fill_stats(struct sk_buff *skb, int container_type,
>
>        spin_lock_bh(&stats->lock);
>
> -       NLA_PUT_U32(skb, IPVS_STATS_ATTR_CONNS, stats->conns);
> -       NLA_PUT_U32(skb, IPVS_STATS_ATTR_INPKTS, stats->inpkts);
> -       NLA_PUT_U32(skb, IPVS_STATS_ATTR_OUTPKTS, stats->outpkts);
> -       NLA_PUT_U64(skb, IPVS_STATS_ATTR_INBYTES, stats->inbytes);
> -       NLA_PUT_U64(skb, IPVS_STATS_ATTR_OUTBYTES, stats->outbytes);
> -       NLA_PUT_U32(skb, IPVS_STATS_ATTR_CPS, stats->cps);
> -       NLA_PUT_U32(skb, IPVS_STATS_ATTR_INPPS, stats->inpps);
> -       NLA_PUT_U32(skb, IPVS_STATS_ATTR_OUTPPS, stats->outpps);
> -       NLA_PUT_U32(skb, IPVS_STATS_ATTR_INBPS, stats->inbps);
> -       NLA_PUT_U32(skb, IPVS_STATS_ATTR_OUTBPS, stats->outbps);
> +       NLA_PUT_U32(skb, IPVS_STATS_ATTR_CONNS, stats->ustats.conns);
> +       NLA_PUT_U32(skb, IPVS_STATS_ATTR_INPKTS, stats->ustats.inpkts);
> +       NLA_PUT_U32(skb, IPVS_STATS_ATTR_OUTPKTS, stats->ustats.outpkts);
> +       NLA_PUT_U64(skb, IPVS_STATS_ATTR_INBYTES, stats->ustats.inbytes);
> +       NLA_PUT_U64(skb, IPVS_STATS_ATTR_OUTBYTES, stats->ustats.outbytes);
> +       NLA_PUT_U32(skb, IPVS_STATS_ATTR_CPS, stats->ustats.cps);
> +       NLA_PUT_U32(skb, IPVS_STATS_ATTR_INPPS, stats->ustats.inpps);
> +       NLA_PUT_U32(skb, IPVS_STATS_ATTR_OUTPPS, stats->ustats.outpps);
> +       NLA_PUT_U32(skb, IPVS_STATS_ATTR_INBPS, stats->ustats.inbps);
> +       NLA_PUT_U32(skb, IPVS_STATS_ATTR_OUTBPS, stats->ustats.outbps);
>
>        spin_unlock_bh(&stats->lock);
>
> diff --git a/net/ipv4/ipvs/ip_vs_est.c b/net/ipv4/ipvs/ip_vs_est.c
> index 4fb620e..2eb2860 100644
> --- a/net/ipv4/ipvs/ip_vs_est.c
> +++ b/net/ipv4/ipvs/ip_vs_est.c
> @@ -65,37 +65,37 @@ static void estimation_timer(unsigned long arg)
>                s = container_of(e, struct ip_vs_stats, est);
>
>                spin_lock(&s->lock);
> -               n_conns = s->conns;
> -               n_inpkts = s->inpkts;
> -               n_outpkts = s->outpkts;
> -               n_inbytes = s->inbytes;
> -               n_outbytes = s->outbytes;
> +               n_conns = s->ustats.conns;
> +               n_inpkts = s->ustats.inpkts;
> +               n_outpkts = s->ustats.outpkts;
> +               n_inbytes = s->ustats.inbytes;
> +               n_outbytes = s->ustats.outbytes;
>
>                /* scaled by 2^10, but divided 2 seconds */
>                rate = (n_conns - e->last_conns)<<9;
>                e->last_conns = n_conns;
>                e->cps += ((long)rate - (long)e->cps)>>2;
> -               s->cps = (e->cps+0x1FF)>>10;
> +               s->ustats.cps = (e->cps+0x1FF)>>10;
>
>                rate = (n_inpkts - e->last_inpkts)<<9;
>                e->last_inpkts = n_inpkts;
>                e->inpps += ((long)rate - (long)e->inpps)>>2;
> -               s->inpps = (e->inpps+0x1FF)>>10;
> +               s->ustats.inpps = (e->inpps+0x1FF)>>10;
>
>                rate = (n_outpkts - e->last_outpkts)<<9;
>                e->last_outpkts = n_outpkts;
>                e->outpps += ((long)rate - (long)e->outpps)>>2;
> -               s->outpps = (e->outpps+0x1FF)>>10;
> +               s->ustats.outpps = (e->outpps+0x1FF)>>10;
>
>                rate = (n_inbytes - e->last_inbytes)<<4;
>                e->last_inbytes = n_inbytes;
>                e->inbps += ((long)rate - (long)e->inbps)>>2;
> -               s->inbps = (e->inbps+0xF)>>5;
> +               s->ustats.inbps = (e->inbps+0xF)>>5;
>
>                rate = (n_outbytes - e->last_outbytes)<<4;
>                e->last_outbytes = n_outbytes;
>                e->outbps += ((long)rate - (long)e->outbps)>>2;
> -               s->outbps = (e->outbps+0xF)>>5;
> +               s->ustats.outbps = (e->outbps+0xF)>>5;
>                spin_unlock(&s->lock);
>        }
>        spin_unlock(&est_lock);
> @@ -108,20 +108,20 @@ void ip_vs_new_estimator(struct ip_vs_stats *stats)
>
>        INIT_LIST_HEAD(&est->list);
>
> -       est->last_conns = stats->conns;
> -       est->cps = stats->cps<<10;
> +       est->last_conns = stats->ustats.conns;
> +       est->cps = stats->ustats.cps<<10;
>
> -       est->last_inpkts = stats->inpkts;
> -       est->inpps = stats->inpps<<10;
> +       est->last_inpkts = stats->ustats.inpkts;
> +       est->inpps = stats->ustats.inpps<<10;
>
> -       est->last_outpkts = stats->outpkts;
> -       est->outpps = stats->outpps<<10;
> +       est->last_outpkts = stats->ustats.outpkts;
> +       est->outpps = stats->ustats.outpps<<10;
>
> -       est->last_inbytes = stats->inbytes;
> -       est->inbps = stats->inbps<<5;
> +       est->last_inbytes = stats->ustats.inbytes;
> +       est->inbps = stats->ustats.inbps<<5;
>
> -       est->last_outbytes = stats->outbytes;
> -       est->outbps = stats->outbps<<5;
> +       est->last_outbytes = stats->ustats.outbytes;
> +       est->outbps = stats->ustats.outbps<<5;
>
>        spin_lock_bh(&est_lock);
>        list_add(&est->list, &est_list);

Reviewed-by: Julius Volz <juliusv@google.com>

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
