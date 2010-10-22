From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC PATCH 5/9] ipvs network name space aware
Date: Fri, 22 Oct 2010 21:05:48 +0200
Message-ID: <20101022190548.GA24978@verge.net.au>
References: <201010081317.04167.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201010081317.04167.hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
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

> @@ -1539,53 +1511,71 @@ proc_do_sync_threshold(ctl_table *table, int write,
> 
>  /*
>   *	IPVS sysctl table (under the /proc/sys/net/ipv4/vs/)
> + *	Do not change order or insert new entries without
> + *	align with netns init in __ip_vs_control_init()
>   */
> 
>  static struct ctl_table vs_vars[] = {
>  	{
>  		.procname	= "amemthresh",
> -		.data		= &sysctl_ip_vs_amemthresh,
> -		.maxlen		= sizeof(int),
> -		.mode		= 0644,
> -		.proc_handler	= proc_dointvec,
> -	},
> -#ifdef CONFIG_IP_VS_DEBUG
> -	{
> -		.procname	= "debug_level",
> -		.data		= &sysctl_ip_vs_debug_level,
>  		.maxlen		= sizeof(int),
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec,
>  	},
> -#endif
>  	{
>  		.procname	= "am_droprate",
> -		.data		= &sysctl_ip_vs_am_droprate,
>  		.maxlen		= sizeof(int),
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec,
>  	},
>  	{
>  		.procname	= "drop_entry",
> -		.data		= &sysctl_ip_vs_drop_entry,
>  		.maxlen		= sizeof(int),
>  		.mode		= 0644,
>  		.proc_handler	= proc_do_defense_mode,
>  	},
>  	{
>  		.procname	= "drop_packet",
> -		.data		= &sysctl_ip_vs_drop_packet,
>  		.maxlen		= sizeof(int),
>  		.mode		= 0644,
>  		.proc_handler	= proc_do_defense_mode,
>  	},
>  	{
>  		.procname	= "secure_tcp",
> -		.data		= &sysctl_ip_vs_secure_tcp,
>  		.maxlen		= sizeof(int),
>  		.mode		= 0644,
>  		.proc_handler	= proc_do_defense_mode,
>  	},
> +	{
> +		.procname	= "cache_bypass",
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec,
> +	},
> +	{
> +		.procname	= "expire_nodest_conn",
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec,
> +	},
> +	{
> +		.procname	= "expire_quiescent_template",
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec,
> +	},
> +	{
> +		.procname	= "sync_threshold",
> +		.maxlen		= sizeof(sysctl_ip_vs_sync_threshold),
> +		.mode		= 0644,
> +		.proc_handler	= proc_do_sync_threshold,
> +	},
> +	{
> +		.procname	= "nat_icmp_send",
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec,
> +	},
>  #if 0
>  	{
>  		.procname	= "timeout_established",

Hi Hans,

is there a reason that the order some of the entries in
vs_vars has been switched around?

