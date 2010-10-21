From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC PATCH 5/9] ipvs network name space aware
Date: Thu, 21 Oct 2010 13:16:47 +0200
Message-ID: <20101021111644.GA25555@verge.net.au>
References: <201010081317.04167.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201010081317.04167.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, ja@ssi.bg, wensong@linux-vs.org, daniel.lezcano@free.fr

On Fri, Oct 08, 2010 at 01:17:02PM +0200, Hans Schillstrom wrote:
> This patch just contains ip_vs_ctl
> 
> Signed-off-by:Hans Schillstrom <hans.schillstrom@ericsson.com>
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index ca8ec8c..7e99cbc 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c

[ snip ]

> @@ -2680,10 +2664,15 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
>  	int idx = 0, i;
>  	int start = cb->args[0];
>  	struct ip_vs_service *svc;
> -
> +	struct net *net = skb->sk->sk_net;

skb->sk->sk_net needs CONFIG_NS_NET.
Is your plan for IPVS to unconditionally depend on CONFIG_NS_NET?
It would be nice to avoid that, but I fear it will be too messy.

> +	struct netns_ipvs *ipvs;
> +	if (!net)
> +		net = dev_net(skb->dev);
> +	BUG_ON(!net);
> +	ipvs = net->ipvs;
>  	mutex_lock(&__ip_vs_mutex);
>  	for (i = 0; i < IP_VS_SVC_TAB_SIZE; i++) {
> -		list_for_each_entry(svc, &ip_vs_svc_table[i], s_list) {
> +		list_for_each_entry(svc, &ipvs->ctl_svc_table[i], s_list) {
>  			if (++idx <= start)
>  				continue;
>  			if (ip_vs_genl_dump_service(skb, svc, cb) < 0) {

[ snip ]
