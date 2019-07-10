From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: Delete some unused space characters in Kconfig
Date: Wed, 10 Jul 2019 09:29:48 +0200
Message-ID: <20190710072948.mpg4niors42zrqhc@verge.net.au>
References: <1562473009-29726-1-git-send-email-xianfengting221@163.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1562473009-29726-1-git-send-email-xianfengting221@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: xianfengting221@163.com
Cc: wensong@linux-vs.org, ja@ssi.bg, pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de, davem@davemloft.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, Jul 07, 2019 at 12:16:49PM +0800, xianfengting221@163.com wrote:
> From: Hu Haowen <xianfengting221@163.com>
> 
> The space characters at the end of lines are always unused and
> not easy to find. This patch deleted some of them I have found
> in Kconfig.
> 
> Signed-off-by: Hu Haowen <xianfengting221@163.com>
> ---
> 
> This is my first patch to the Linux kernel, so please forgive
> me if anything went wrong.

Acked-by: Simon Horman <horms+renesas@verge.net.au>

Thanks Hu,

this looks good to me.

Pablo, please consider this for inclusion in nf-next.

> 
>  net/netfilter/ipvs/Kconfig | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
> index f6f1a0d..54afad5 100644
> --- a/net/netfilter/ipvs/Kconfig
> +++ b/net/netfilter/ipvs/Kconfig
> @@ -120,7 +120,7 @@ config	IP_VS_RR
>  
>  	  If you want to compile it in kernel, say Y. To compile it as a
>  	  module, choose M here. If unsure, say N.
> - 
> +
>  config	IP_VS_WRR
>  	tristate "weighted round-robin scheduling"
>  	---help---
> @@ -138,7 +138,7 @@ config	IP_VS_LC
>          tristate "least-connection scheduling"
>  	---help---
>  	  The least-connection scheduling algorithm directs network
> -	  connections to the server with the least number of active 
> +	  connections to the server with the least number of active
>  	  connections.
>  
>  	  If you want to compile it in kernel, say Y. To compile it as a
> @@ -193,7 +193,7 @@ config  IP_VS_LBLCR
>  	tristate "locality-based least-connection with replication scheduling"
>  	---help---
>  	  The locality-based least-connection with replication scheduling
> -	  algorithm is also for destination IP load balancing. It is 
> +	  algorithm is also for destination IP load balancing. It is
>  	  usually used in cache cluster. It differs from the LBLC scheduling
>  	  as follows: the load balancer maintains mappings from a target
>  	  to a set of server nodes that can serve the target. Requests for
> @@ -250,8 +250,8 @@ config	IP_VS_SED
>  	tristate "shortest expected delay scheduling"
>  	---help---
>  	  The shortest expected delay scheduling algorithm assigns network
> -	  connections to the server with the shortest expected delay. The 
> -	  expected delay that the job will experience is (Ci + 1) / Ui if 
> +	  connections to the server with the shortest expected delay. The
> +	  expected delay that the job will experience is (Ci + 1) / Ui if
>  	  sent to the ith server, in which Ci is the number of connections
>  	  on the ith server and Ui is the fixed service rate (weight)
>  	  of the ith server.
> -- 
> 2.7.4
> 
> 
