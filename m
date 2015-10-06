From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: Remove possibly unused net variable from
 ip_vs_out
Date: Tue, 6 Oct 2015 21:24:09 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1510062122310.1745@ja.home.ssi.bg>
References: <1444119324-5653-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1444119324-5653-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, "Eric W. Biederman" <ebiederm@xmission.com>


	Hello,

On Tue, 6 Oct 2015, Simon Horman wrote:

> Since 6f2bcea9917d ("ipvs: Pass ipvs into ip_vs_in_icmp and
> ip_vs_in_icmp_v6") the net variable in ip_vs_out() appears to be unused
> unless CONFIG_IP_VS_IPV6 is set. To resolve this remove the net variable
> and dereference net asneeded.
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>

	Both patches look good to me

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_core.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index d08df435c2aa..3773154d9b71 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1172,7 +1172,6 @@ drop:
>  static unsigned int
>  ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int af)
>  {
> -	struct net *net = ipvs->net;
>  	struct ip_vs_iphdr iph;
>  	struct ip_vs_protocol *pp;
>  	struct ip_vs_proto_data *pd;
> @@ -1272,7 +1271,7 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
>  #ifdef CONFIG_IP_VS_IPV6
>  				if (af == AF_INET6) {
>  					if (!skb->dev)
> -						skb->dev = net->loopback_dev;
> +						skb->dev = ipvs->net->loopback_dev;
>  					icmpv6_send(skb,
>  						    ICMPV6_DEST_UNREACH,
>  						    ICMPV6_PORT_UNREACH,
> -- 
> 2.1.4

Regards

--
Julian Anastasov <ja@ssi.bg>
