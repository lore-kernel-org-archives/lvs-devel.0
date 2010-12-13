From: Simon Horman <horms@verge.net.au>
Subject: Re: [*v2 PATCH 08/22] IPVS: netns preparation for proto_sctp
Date: Tue, 14 Dec 2010 07:23:01 +0900
Message-ID: <20101213222300.GK3221@verge.net.au>
References: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
 <1292247510-753-9-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1292247510-753-9-git-send-email-hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: ja@ssi.bg, daniel.lezcano@free.fr, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans@schillstrom.com

On Mon, Dec 13, 2010 at 02:38:16PM +0100, Hans Schillstrom wrote:
> In this phase (one), all local vars will be moved to ipvs struct.
> 
> Remaining work, add param struct net *net to a couple of
> functions that is common for all protos and use ip_vs_proto_data
> 
> Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>

[ snip ]

> diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> index 521b827..108ae0c 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c

[ snip ]

> @@ -1101,43 +1098,51 @@ static int sctp_app_conn_bind(struct ip_vs_conn *cp)
>  			goto out;
>  		}
>  	}
> -	spin_unlock(&sctp_app_lock);
> +	spin_unlock(&ipvs->sctp_app_lock);
>  out:
>  	return result;
>  }
>  
> -static void ip_vs_sctp_init(struct ip_vs_protocol *pp)
> +/* ---------------------------------------------
> + *   timeouts is netns related now.
> + * ---------------------------------------------
> + */
> +static void __ip_vs_sctp_init(struct net *net, struct ip_vs_proto_data *pd)
>  {
> -	IP_VS_INIT_HASH_TABLE(sctp_apps);
> -	pp->timeout_table = sctp_timeouts;
> -}
> +	struct netns_ipvs *ipvs = net_ipvs(net);
>  
> +	ip_vs_init_hash_table(ipvs->sctp_apps, SCTP_APP_TAB_SIZE);
> +	spin_lock_init(&ipvs->tcp_app_lock);
> +	pd->timeout_table = ip_vs_create_timeout_table((int*)sctp_timeouts,
> +							sizeof(sctp_timeouts));
> +}
>  
> -static void ip_vs_sctp_exit(struct ip_vs_protocol *pp)
> +static void __ip_vs_sctp_exit(struct net *net, struct ip_vs_proto_data *pd)
>  {
> -
> +	kfree(pd->timeout_table);
>  }
>  
>  struct ip_vs_protocol ip_vs_protocol_sctp = {
> -	.name = "SCTP",
> -	.protocol = IPPROTO_SCTP,
> -	.num_states = IP_VS_SCTP_S_LAST,
> -	.dont_defrag = 0,
> -	.appcnt = ATOMIC_INIT(0),
> -	.init = ip_vs_sctp_init,
> -	.exit = ip_vs_sctp_exit,
> -	.register_app = sctp_register_app,
> +	.name		= "SCTP",
> +	.protocol	= IPPROTO_SCTP,
> +	.num_states	= IP_VS_SCTP_S_LAST,
> +	.dont_defrag	= 0,
> +	.init 		= NULL,
> +	.exit 		= NULL,
> +	.init_netns 	= __ip_vs_sctp_init,
> +	.exit_netns 	= __ip_vs_sctp_exit,
> +	.register_app	= sctp_register_app,
>  	.unregister_app = sctp_unregister_app,
> -	.conn_schedule = sctp_conn_schedule,
> -	.conn_in_get = ip_vs_conn_in_get_proto,
> -	.conn_out_get = ip_vs_conn_out_get_proto,
> -	.snat_handler = sctp_snat_handler,
> -	.dnat_handler = sctp_dnat_handler,
> -	.csum_check = sctp_csum_check,
> -	.state_name = sctp_state_name,
> +	.conn_schedule	= sctp_conn_schedule,
> +	.conn_in_get	= ip_vs_conn_in_get_proto,
> +	.conn_out_get	= ip_vs_conn_out_get_proto,
> +	.snat_handler	= sctp_snat_handler,
> +	.dnat_handler	= sctp_dnat_handler,
> +	.csum_check	= sctp_csum_check,
> +	.state_name	= sctp_state_name,
>  	.state_transition = sctp_state_transition,
> -	.app_conn_bind = sctp_app_conn_bind,
> -	.debug_packet = ip_vs_tcpudp_debug_packet,
> -	.timeout_change = sctp_timeout_change,
> -	.set_state_timeout = sctp_set_state_timeout,
> +	.app_conn_bind	= sctp_app_conn_bind,
> +	.debug_packet	= ip_vs_tcpudp_debug_packet,
> +	.timeout_change	= NULL,
> +/*	.set_state_timeout = sctp_set_state_timeout, */
>  };

While I'm not a big fan or the original formatting,
the whitespace changes above make it rather difficult to see
what is really being changed. Could you either drop
the whitespace changes or move them into a separate patch?

