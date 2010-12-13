From: Simon Horman <horms@verge.net.au>
Subject: Re: [*v2 PATCH 09/22] IPVS: netns preparation for proto_ah_esp
Date: Tue, 14 Dec 2010 07:19:38 +0900
Message-ID: <20101213221938.GJ3221@verge.net.au>
References: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
 <1292247510-753-10-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1292247510-753-10-git-send-email-hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: ja@ssi.bg, daniel.lezcano@free.fr, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans@schillstrom.com

On Mon, Dec 13, 2010 at 02:38:17PM +0100, Hans Schillstrom wrote:
> In this phase (one), all local vars will be moved to ipvs struct.
> 
> Remaining work, add param struct net *net to a couple of
> functions that common for all protos.
> 
> Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> ---
>  net/netfilter/ipvs/ip_vs_proto.c        |    6 ++++++
>  net/netfilter/ipvs/ip_vs_proto_ah_esp.c |   20 ++++----------------
>  2 files changed, 10 insertions(+), 16 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
> index fd3a7a8..1089248 100644
> --- a/net/netfilter/ipvs/ip_vs_proto.c
> +++ b/net/netfilter/ipvs/ip_vs_proto.c
> @@ -316,6 +316,12 @@ static int  __net_init  __ip_vs_protocol_init(struct net *net)
>  #ifdef CONFIG_IP_VS_PROTO_SCTP
>  	register_ip_vs_proto_netns(net, &ip_vs_protocol_sctp);
>  #endif
> +#ifdef CONFIG_IP_VS_PROTO_AH
> +	register_ip_vs_proto_netns(net, &ip_vs_protocol_ah);
> +#endif
> +#ifdef CONFIG_IP_VS_PROTO_ESP
> +	register_ip_vs_proto_netns(net, &ip_vs_protocol_esp);
> +#endif
>  	return 0;
>  }
>  
> diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
> index 3a04611..b8b37fa 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
> @@ -117,26 +117,14 @@ ah_esp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
>  	return 0;
>  }
>  
> -static void ah_esp_init(struct ip_vs_protocol *pp)
> -{
> -	/* nothing to do now */
> -}
> -
> -
> -static void ah_esp_exit(struct ip_vs_protocol *pp)
> -{
> -	/* nothing to do now */
> -}
> -
> -

This code removal is nice :-)
