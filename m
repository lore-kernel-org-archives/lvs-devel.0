From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [RFC PATCH 1/9] ipvs network name space aware
Date: Mon, 18 Oct 2010 10:59:25 +0200
Message-ID: <4CBC0C6D.1080303@free.fr>
References: <201010081316.46690.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <201010081316.46690.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org

On 10/08/2010 01:16 PM, Hans Schillstrom wrote:
> This part contains the include files
> where include/net/netns/ip_vs.h is new and contains all moved vars.
>
> SUMMARY
>
>   include/net/ip_vs.h                     |  136 ++++---
>   include/net/net_namespace.h             |    2 +
>   include/net/netns/ip_vs.h               |  112 +++++
>
> Signed-off-by:Hans Schillstrom<hans.schillstrom@ericsson.com>
> ---
>
>    

[ ... ]

>   #ifdef CONFIG_IP_VS_IPV6
> diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
> index bd10a79..b59cdc5 100644
> --- a/include/net/net_namespace.h
> +++ b/include/net/net_namespace.h
> @@ -15,6 +15,7 @@
>   #include<net/netns/ipv4.h>
>   #include<net/netns/ipv6.h>
>   #include<net/netns/dccp.h>
> +#include<net/netns/ip_vs.h>
>   #include<net/netns/x_tables.h>
>   #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
>   #include<net/netns/conntrack.h>
> @@ -91,6 +92,7 @@ struct net {
>   	struct sk_buff_head	wext_nlevents;
>   #endif
>   	struct net_generic	*gen;
> +	struct netns_ipvs       *ipvs;
>   };
>    

IMHO, it would be better to use the net_generic infra-structure instead 
of adding a new field in the netns structure.

