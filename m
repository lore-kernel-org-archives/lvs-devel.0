From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch] ipvs: Use atomic operations atomicly
Date: Wed, 02 Sep 2009 14:56:02 +0200
Message-ID: <4A9E6B62.8080208@trash.net>
References: <20090828023722.GA12136@verge.net.au> <4A9BC082.3090804@trash.net> <20090901015909.GA12252@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090901015909.GA12252@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, =?ISO-8859-15?Q?=3F=3F_shin_hong?= <hongshin@gmail.com>, David Miller <davem@davemloft.net>

Simon Horman wrote:
> On Mon, Aug 31, 2009 at 02:22:26PM +0200, Patrick McHardy wrote:
>> It seems that proc_do_sync_threshold() should check whether this value
>> is zero. The current checks also look racy since incorrect values are
>> first updated, then overwritten again.
> 
> I'm wondering if an approach along the lines of the following is valid.
> The idea is that the value in the ctl_table is essentially a scratch
> value that is used by the parser and then copied into ip_vs_sync_threshold
> if it is valid.

Even simpler would be to use a temporary buffer on the stack for copying
the values from userspace and then copy them to the final buffer after
validation.

> I'm concerned that there are atomicity issues
> surrounding writing ip_vs_sync_threshold while there might be readers.

That might be a problem if they are required to be "synchronized".

> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1362,8 +1362,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
>  	    (ip_vs_sync_state & IP_VS_STATE_MASTER) &&
>  	    (((cp->protocol != IPPROTO_TCP ||
>  	       cp->state == IP_VS_TCP_S_ESTABLISHED) &&
> -	      (pkts % sysctl_ip_vs_sync_threshold[1]
> -	       == sysctl_ip_vs_sync_threshold[0])) ||
> +	      (pkts % ip_vs_sync_threshold[1] == ip_vs_sync_threshold[0])) ||
>  	     ((cp->protocol == IPPROTO_TCP) && (cp->old_state != cp->state) &&
>  	      ((cp->state == IP_VS_TCP_S_FIN_WAIT) ||
>  	       (cp->state == IP_VS_TCP_S_CLOSE_WAIT) ||
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index fba2892..8a9ff21 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -76,6 +76,11 @@ static atomic_t ip_vs_dropentry = ATOMIC_INIT(0);
>  /* number of virtual services */
>  static int ip_vs_num_services = 0;
>  
> +/* threshold handling */
> +static int ip_vs_sync_threshold_min = 0;
> +static int ip_vs_sync_threshold_max = INT_MAX;
> +int ip_vs_sync_threshold[2] = { 3, 50 };
> +

min should be 1 I guess or you still need to manually check
that ip_vs_sync_threshold[1] != 0 to avoid a division be zero.
