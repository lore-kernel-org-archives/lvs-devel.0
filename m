From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [RFC PATCH 4/9] ipvs network name space aware
Date: Tue, 12 Oct 2010 18:02:37 +0200
Message-ID: <4CB4869D.9050605@free.fr>
References: <201010081317.01120.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <201010081317.01120.hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org

On 10/08/2010 01:16 PM, Hans Schillstrom wrote:
> This patch just contains ip_vs_core.c
>
> Signed-off-by:Hans Schillstrom<hans.schillstrom@ericsson.com>
>
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index 0c043b6..4fdc5cb 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -52,7 +52,6 @@
>
>   #include<net/ip_vs.h>
>
> -
>   EXPORT_SYMBOL(register_ip_vs_scheduler);
>   EXPORT_SYMBOL(unregister_ip_vs_scheduler);
>   EXPORT_SYMBOL(ip_vs_proto_name);
> @@ -67,6 +66,8 @@ EXPORT_SYMBOL(ip_vs_conn_put);
>   EXPORT_SYMBOL(ip_vs_get_debug_level);
>   #endif
>
> +/* netns cnt used for uniqueness */
> +static atomic_t ipvs_netns_cnt = ATOMIC_INIT(0);
>    

Why is this counter needed ?

[ cut ]

> + *	Initialize IP Virtual Server netns mem.
> + */
> +static int __net_init __ip_vs_init(struct net *net)
> +{
> +	struct netns_ipvs *ipvs = 0;
>
> +	ipvs = kzalloc(sizeof(struct netns_ipvs), GFP_ATOMIC);
> +	if( ipvs == NULL ) {
> +		pr_err("%s(): no memory.\n", __func__);
> +		return -ENOMEM;
> +	}
> +	ipvs->inc = atomic_read(&ipvs_netns_cnt);
>    

AFAICS, this counter is never used. Is it really needed ?

> +	atomic_inc(&ipvs_netns_cnt);
> +	IP_VS_DBG(10, "Creating new netns *net=%p *ipvs=%p size=%lu\n",
> +		     net, ipvs, sizeof(struct netns_ipvs));
> +	net->ipvs = ipvs;
> +
> +	return 0;
> +}
>    

