From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [PATCH] netfilter: ipvs: fix compiler warnings
Date: Tue, 25 Jan 2011 07:49:55 +0100
Message-ID: <201101250749.57135.hans@schillstrom.com>
References: <1295930418-14980-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1295930418-14980-1-git-send-email-xiaosuo@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: Changli Gao <xiaosuo@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

On Tuesday, January 25, 2011 05:40:18 Changli Gao wrote:
> Fix compiler warnings when IP_VS_DBG() isn't defined.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Acked-by: Hans Schillstrom <hans.schillstrom@ericsson.com>

> ---
>  net/netfilter/ipvs/ip_vs_core.c  |    4 +---
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
>  static struct pernet_operations ipvs_core_ops = {
> --
Thanks I forgot that one.

Regards
Hans Schillstrom
