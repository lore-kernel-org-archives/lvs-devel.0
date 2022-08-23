From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: add a sysctl switch to control ipvs to bypass
 OUTPUT chain or not
Date: Tue, 23 Aug 2022 21:16:29 +0300 (EEST)
Message-ID: <495ceee5-f8dc-06e-d1ef-258d1889c7b8@ssi.bg>
References: <20220819100702.14889-1-bigclouds@163.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20220819100702.14889-1-bigclouds@163.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "longguang.yue" <bigclouds@163.com>
Cc: horms@verge.net.au, kadlec@netfilter.org, fw@strlen.de, pablo@netfilter.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org


	Hello,

On Fri, 19 Aug 2022, longguang.yue wrote:

> Netfilter's rules are matched in sequence, more rules worse performance.
> IPVS is a special system, its traffic is clear and definite, for better
> performance, should better not be interfered heavily. This patch adds a
> sysctl switch and enable ipvs to control traffic to pass netfilter
> OUTPUT chain or not.
> 
> Signed-off-by: longguang.yue <bigclouds@163.com>
> ---
>  include/net/ip_vs.h             | 11 +++++++++++
>  net/netfilter/ipvs/ip_vs_ctl.c  |  8 ++++++++
>  net/netfilter/ipvs/ip_vs_xmit.c | 31 ++++++++++++++++++++++++-------
>  3 files changed, 43 insertions(+), 7 deletions(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index ff1804a0c469..c1232ef3a1b5 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -932,6 +932,7 @@ struct netns_ipvs {
>  	int			sysctl_schedule_icmp;
>  	int			sysctl_ignore_tunneled;
>  	int			sysctl_run_estimation;
> +	int			sysctl_output_bypass;
>  
>  	/* ip_vs_lblc */
>  	int			sysctl_lblc_expiration;
> @@ -1077,6 +1078,11 @@ static inline int sysctl_run_estimation(struct netns_ipvs *ipvs)
>  	return ipvs->sysctl_run_estimation;
>  }
>  
> +static inline int sysctl_output_bypass(struct netns_ipvs *ipvs)
> +{
> +	return ipvs->sysctl_output_bypass;
> +}
> +
>  #else
>  
>  static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
> @@ -1174,6 +1180,11 @@ static inline int sysctl_run_estimation(struct netns_ipvs *ipvs)
>  	return 1;
>  }
>  
> +static inline int sysctl_output_bypass(struct netns_ipvs *ipvs)
> +{
> +	return 0;
> +}
> +
>  #endif
>  
>  /* IPVS core functions
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index efab2b06d373..8a08a783e85e 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -2019,6 +2019,12 @@ static struct ctl_table vs_vars[] = {
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec,
>  	},
> +	{
> +		.procname	= "output_bypass",
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec,
> +	},
>  #ifdef CONFIG_IP_VS_DEBUG
>  	{
>  		.procname	= "debug_level",
> @@ -4094,6 +4100,8 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
>  	tbl[idx++].data = &ipvs->sysctl_ignore_tunneled;
>  	ipvs->sysctl_run_estimation = 1;
>  	tbl[idx++].data = &ipvs->sysctl_run_estimation;
> +	ipvs->sysctl_output_bypass = 1;

	Default should be 0, so without above line.

> +	tbl[idx++].data = &ipvs->sysctl_output_bypass;
>  #ifdef CONFIG_IP_VS_DEBUG
>  	/* Global sysctls must be ro in non-init netns */
>  	if (!net_eq(net, &init_net))
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index 029171379884..46a34dd2555e 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -653,8 +653,12 @@ static inline int ip_vs_nat_send_or_cont(int pf, struct sk_buff *skb,
>  		skb_forward_csum(skb);
>  		if (skb->dev)
>  			skb_clear_tstamp(skb);
> -		NF_HOOK(pf, NF_INET_LOCAL_OUT, cp->ipvs->net, NULL, skb,
> -			NULL, skb_dst(skb)->dev, dst_output);
> +		if (sysctl_output_bypass(cp->ipvs)) {
> +			dst_output(cp->ipvs->net, NULL, skb);
> +		} else {
> +			NF_HOOK(pf, NF_INET_LOCAL_OUT, cp->ipvs->net, NULL, skb,
> +				NULL, skb_dst(skb)->dev, dst_output);
> +		}
>  	} else
>  		ret = NF_ACCEPT;
>  
> @@ -675,8 +679,12 @@ static inline int ip_vs_send_or_cont(int pf, struct sk_buff *skb,
>  		skb_forward_csum(skb);
>  		if (skb->dev)
>  			skb_clear_tstamp(skb);
> -		NF_HOOK(pf, NF_INET_LOCAL_OUT, cp->ipvs->net, NULL, skb,
> -			NULL, skb_dst(skb)->dev, dst_output);
> +		if (sysctl_output_bypass(cp->ipvs)) {
> +			dst_output(cp->ipvs->net, NULL, skb);
> +		} else {
> +			NF_HOOK(pf, NF_INET_LOCAL_OUT, cp->ipvs->net, NULL, skb,
> +				NULL, skb_dst(skb)->dev, dst_output);
> +		}
>  	} else
>  		ret = NF_ACCEPT;
>  	return ret;
> @@ -1262,10 +1270,19 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
>  	skb->ignore_df = 1;
>  
>  	ret = ip_vs_tunnel_xmit_prepare(skb, cp);
> -	if (ret == NF_ACCEPT)
> -		ip_local_out(net, skb->sk, skb);
> -	else if (ret == NF_DROP)
> +	if (ret == NF_ACCEPT) {
> +		if (sysctl_output_bypass(cp->ipvs)) {
> +			struct iphdr *iph = ip_hdr(skb);
> +
> +			iph->tot_len = htons(skb->len);
> +			ip_send_check(iph);
> +			dst_output(cp->ipvs->net, NULL, skb);

	After our last discussion I still think this is a hack.
If you expand also __ip6_local_out you'll see what maintenance
cost adds such flag. Your patch also warns how much ip_local_out
changed in the years and our NF_HOOK calls look as hacks too.
They were used to avoid duplicate calls like ip_send_check
which we should not have anymore, ip_send_check was added to the
ip_defrag flow in 2015 with commit 0848f6428ba3. So, I think we
should be moving to ip_local_out/ip6_local_out calls which are
risky to duplicate here in the IPVS code.

> +		} else {
> +			ip_local_out(net, skb->sk, skb);
> +		}
> +	} else if (ret == NF_DROP) {
>  		kfree_skb(skb);
> +	}
>  
>  	LeaveFunction(10);

Regards

--
Julian Anastasov <ja@ssi.bg>

