From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: replace atomic_add_return()
Date: Tue, 17 Nov 2020 22:57:52 +0200 (EET)
Message-ID: <9cd77e1e-1c52-d647-9443-485510b4a9b1@ssi.bg>
References: <1605513707-7579-1-git-send-email-yejune.deng@gmail.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1605513707-7579-1-git-send-email-yejune.deng@gmail.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yejune Deng <yejune.deng@gmail.com>
Cc: wensong@linux-vs.org, horms@verge.net.au, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, davem@davemloft.net, kuba@kernel.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org


	Hello,

On Mon, 16 Nov 2020, Yejune Deng wrote:

> atomic_inc_return() looks better
> 
> Signed-off-by: Yejune Deng <yejune.deng@gmail.com>

	Looks good to me for -next, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_core.c | 2 +-
>  net/netfilter/ipvs/ip_vs_sync.c | 4 ++--
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index c0b8215..54e086c 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -2137,7 +2137,7 @@ static int ip_vs_in_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
>  	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
>  		pkts = sysctl_sync_threshold(ipvs);
>  	else
> -		pkts = atomic_add_return(1, &cp->in_pkts);
> +		pkts = atomic_inc_return(&cp->in_pkts);
>  
>  	if (ipvs->sync_state & IP_VS_STATE_MASTER)
>  		ip_vs_sync_conn(ipvs, cp, pkts);
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index 16b4806..9d43277 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -615,7 +615,7 @@ static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
>  	cp = cp->control;
>  	if (cp) {
>  		if (cp->flags & IP_VS_CONN_F_TEMPLATE)
> -			pkts = atomic_add_return(1, &cp->in_pkts);
> +			pkts = atomic_inc_return(&cp->in_pkts);
>  		else
>  			pkts = sysctl_sync_threshold(ipvs);
>  		ip_vs_sync_conn(ipvs, cp, pkts);
> @@ -776,7 +776,7 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
>  	if (!cp)
>  		return;
>  	if (cp->flags & IP_VS_CONN_F_TEMPLATE)
> -		pkts = atomic_add_return(1, &cp->in_pkts);
> +		pkts = atomic_inc_return(&cp->in_pkts);
>  	else
>  		pkts = sysctl_sync_threshold(ipvs);
>  	goto sloop;
> -- 
> 1.9.1

Regards

--
Julian Anastasov <ja@ssi.bg>

