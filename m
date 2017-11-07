From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: mark expected switch fall-throughs
Date: Tue, 7 Nov 2017 02:07:29 +0100
Message-ID: <20171107010729.GA23302@salvia>
References: <20171019140616.GA15989@embeddedor.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171019140616.GA15989@embeddedor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org

Hi Gustavo,

On Thu, Oct 19, 2017 at 09:06:16AM -0500, Gustavo A. R. Silva wrote:
> diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
> index cf84f7b..72f654a 100644
> --- a/net/netfilter/ipset/ip_set_core.c
> +++ b/net/netfilter/ipset/ip_set_core.c
> @@ -1386,7 +1386,8 @@ ip_set_dump_start(struct sk_buff *skb, struct netlink_callback *cb)
>  				goto next_set;
>  			if (set->variant->uref)
>  				set->variant->uref(set, cb, true);
> -			/* Fall through and add elements */
> +			/* add elements */
> +			/* fall through */

Just replace this comment by /* fall through */, I think it's enough
to remember that this is intentional.

>  		default:
>  			rcu_read_lock_bh();
>  			ret = set->variant->list(set, skb, cb);
[...]
> diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
> index d8571f4..fa5cdd0 100644
> --- a/net/netfilter/x_tables.c
> +++ b/net/netfilter/x_tables.c
> @@ -1382,7 +1382,8 @@ static void *xt_mttg_seq_next(struct seq_file *seq, void *v, loff_t *ppos,
>  		trav->curr = trav->curr->next;
>  		if (trav->curr != trav->head)
>  			break;
> -		/* fallthru, _stop will unlock */
> +		/* _stop will unlock */

Same thing here, thanks!
