From: Simon Horman <horms@verge.net.au>
Subject: Re: [*v2 PATCH 06/22] IPVS: netns preparation for proto_tcp
Date: Tue, 14 Dec 2010 07:18:32 +0900
Message-ID: <20101213221831.GI3221@verge.net.au>
References: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
 <1292247510-753-7-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1292247510-753-7-git-send-email-hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: ja@ssi.bg, daniel.lezcano@free.fr, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans@schillstrom.com

Hi Hans,

I'm not all the way through yet but this series is looking good.
Some minor nits below.

On Mon, Dec 13, 2010 at 02:38:14PM +0100, Hans Schillstrom wrote:
> In this phase (one), all local vars will be moved to ipvs struct.
> 
> Remaining work, add param struct net *net to a couple of
> functions that is common for all protos and use all
> ip_vs_proto_data
> 
> Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> ---
>  include/net/ip_vs.h                  |    7 ++-
>  include/net/netns/ip_vs.h            |    8 +++
>  net/netfilter/ipvs/ip_vs_ftp.c       |    9 ++-
>  net/netfilter/ipvs/ip_vs_proto.c     |   13 ++++-
>  net/netfilter/ipvs/ip_vs_proto_tcp.c |   99 +++++++++++++++++++--------------
>  5 files changed, 87 insertions(+), 49 deletions(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 528c5e8..3765add 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -40,11 +40,12 @@ static inline struct netns_ipvs * net_ipvs(struct net* net) {
>  	return init_net.ipvs;
>  #endif
>  }
> +

This blank line change is spurious here.
There seem to be other cases of blank lines being
spuriously added and removed in this patch set.
They tend to just add noise.

>  /*
>   * Get net ptr from skb in traffic cases
>   * use skb_sknet when call is from userland (ioctl or netlink)
>   */
> -static inline struct net *skb_net(struct sk_buff *skb) {
> +static inline struct net *skb_net(const struct sk_buff *skb) {
>  #ifdef CONFIG_NET_NS
>  #ifdef CONFIG_IP_VS_DEBUG
>  	/*

[ snip ]

> diff --git a/include/net/netns/ip_vs.h b/include/net/netns/ip_vs.h
> index b7d7815..512cdd0 100644
> --- a/include/net/netns/ip_vs.h
> +++ b/include/net/netns/ip_vs.h
> @@ -32,6 +32,14 @@ struct netns_ipvs {
>  	/* ip_vs_proto */
>  	#define IP_VS_PROTO_TAB_SIZE	32	/* must be power of 2 */
>  	struct ip_vs_proto_data *proto_data_table[IP_VS_PROTO_TAB_SIZE];
> +	/* ip_vs_proto_tcp */
> +#ifdef CONFIG_IP_VS_PROTO_TCP
> +	#define	TCP_APP_TAB_BITS	4
> +	#define	TCP_APP_TAB_SIZE	(1 << TCP_APP_TAB_BITS)
> +	#define	TCP_APP_TAB_MASK	(TCP_APP_TAB_SIZE - 1)
> +	struct list_head 	tcp_apps[TCP_APP_TAB_SIZE];

There is a space (not tab) after head.

> +	spinlock_t		tcp_app_lock;
> +#endif
>  
>  	/* ip_vs_lblc */
>  	int 			sysctl_lblc_expiration;
> diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> index 5e4da60..8986b25 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c

[ snip ]

> @@ -459,13 +463,13 @@ static void tcp_timeout_change(struct ip_vs_protocol *pp, int flags)
>  	*/
>  	tcp_state_table = (on? tcp_states_dos : tcp_states);
>  }
> -
> +/* Remove dot used
>  static int
>  tcp_set_state_timeout(struct ip_vs_protocol *pp, char *sname, int to)
>  {
>  	return ip_vs_set_state_timeout(pp->timeout_table, IP_VS_TCP_S_LAST,
>  				       tcp_state_name_table, sname, to);
> -}
> +} */

Can we just remove tcp_set_state_timeout ?

[ snip ]

> @@ -699,8 +712,10 @@ struct ip_vs_protocol ip_vs_protocol_tcp = {
>  	.num_states =		IP_VS_TCP_S_LAST,
>  	.dont_defrag =		0,
>  	.appcnt =		ATOMIC_INIT(0),
> -	.init =			ip_vs_tcp_init,
> -	.exit =			ip_vs_tcp_exit,
> +	.init =			NULL,
> +	.exit =			NULL,
> +	.init_netns =		__ip_vs_tcp_init,
> +	.exit_netns =		__ip_vs_tcp_exit,
>  	.register_app =		tcp_register_app,
>  	.unregister_app =	tcp_unregister_app,
>  	.conn_schedule =	tcp_conn_schedule,
> @@ -714,5 +729,5 @@ struct ip_vs_protocol ip_vs_protocol_tcp = {
>  	.app_conn_bind =	tcp_app_conn_bind,
>  	.debug_packet =		ip_vs_tcpudp_debug_packet,
>  	.timeout_change =	tcp_timeout_change,
> -	.set_state_timeout =	tcp_set_state_timeout,
> +/*	.set_state_timeout =	tcp_set_state_timeout, */
>  };

Can this the commented-out line just be removed?

