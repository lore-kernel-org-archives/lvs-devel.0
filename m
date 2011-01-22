From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] netfilter: ipvs: fix compiler warnings
Date: Sat, 22 Jan 2011 13:22:33 +1100
Message-ID: <20110122022232.GL2661@verge.net.au>
References: <1295604133-6869-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1295604133-6869-1-git-send-email-xiaosuo@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Changli Gao <xiaosuo@gmail.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

On Fri, Jan 21, 2011 at 06:02:13PM +0800, Changli Gao wrote:
> Fix compiler warnings when no transport protocol load balancing support
> is configured.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  net/netfilter/ipvs/ip_vs_core.c  |    4 +---
>  net/netfilter/ipvs/ip_vs_ctl.c   |    4 ++++
>  net/netfilter/ipvs/ip_vs_proto.c |    4 ++++
>  3 files changed, 9 insertions(+), 3 deletions(-)
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index f36a84f..d889f4f 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1894,9 +1894,7 @@ static int __net_init __ip_vs_init(struct net *net)
>  
>  static void __net_exit __ip_vs_cleanup(struct net *net)
>  {
> -	struct netns_ipvs *ipvs = net_ipvs(net);
> -
> -	IP_VS_DBG(10, "ipvs netns %d released\n", ipvs->gen);
> +	IP_VS_DBG(10, "ipvs netns %d released\n", net_ipvs(net)->gen);
>  }
>  

The hunk above seems unrelated to the problem described.
The rest of the changes look good. I will double check and
apply them to my tree.

Patrick, I have another fix. So I think it would be best
to take this fix though my tree and. I'll send you a pull
request shortly.

>  static struct pernet_operations ipvs_core_ops = {
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 09ca2ce..68b8033 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -2062,7 +2062,9 @@ static const struct file_operations ip_vs_stats_percpu_fops = {
>   */
>  static int ip_vs_set_timeout(struct net *net, struct ip_vs_timeout_user *u)
>  {
> +#if defined(CONFIG_IP_VS_PROTO_TCP) || defined(CONFIG_IP_VS_PROTO_UDP)
>  	struct ip_vs_proto_data *pd;
> +#endif
>  
>  	IP_VS_DBG(2, "Setting timeout tcp:%d tcpfin:%d udp:%d\n",
>  		  u->tcp_timeout,
> @@ -2405,7 +2407,9 @@ __ip_vs_get_dest_entries(struct net *net, const struct ip_vs_get_dests *get,
>  static inline void
>  __ip_vs_get_timeouts(struct net *net, struct ip_vs_timeout_user *u)
>  {
> +#if defined(CONFIG_IP_VS_PROTO_TCP) || defined(CONFIG_IP_VS_PROTO_UDP)
>  	struct ip_vs_proto_data *pd;
> +#endif
>  
>  #ifdef CONFIG_IP_VS_PROTO_TCP
>  	pd = ip_vs_proto_data_get(net, IPPROTO_TCP);
> diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
> index 6ac986c..17484a4 100644
> --- a/net/netfilter/ipvs/ip_vs_proto.c
> +++ b/net/netfilter/ipvs/ip_vs_proto.c
> @@ -60,6 +60,9 @@ static int __used __init register_ip_vs_protocol(struct ip_vs_protocol *pp)
>  	return 0;
>  }
>  
> +#if defined(CONFIG_IP_VS_PROTO_TCP) || defined(CONFIG_IP_VS_PROTO_UDP) || \
> +    defined(CONFIG_IP_VS_PROTO_SCTP) || defined(CONFIG_IP_VS_PROTO_AH) || \
> +    defined(CONFIG_IP_VS_PROTO_ESP)
>  /*
>   *	register an ipvs protocols netns related data
>   */
> @@ -85,6 +88,7 @@ register_ip_vs_proto_netns(struct net *net, struct ip_vs_protocol *pp)
>  
>  	return 0;
>  }
> +#endif
>  
>  /*
>   *	unregister an ipvs protocol
> 
