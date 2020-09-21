From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next] ipvs: Remove unused macros
Date: Mon, 21 Sep 2020 09:24:40 +0200
Message-ID: <20200921072436.GA8437@vergenet.net>
References: <20200918131656.46260-1-yuehaibing@huawei.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20200918131656.46260-1-yuehaibing@huawei.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: YueHaibing <yuehaibing@huawei.com>
Cc: wensong@linux-vs.org, ja@ssi.bg, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, davem@davemloft.net, kuba@kernel.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Fri, Sep 18, 2020 at 09:16:56PM +0800, YueHaibing wrote:
> They are not used since commit e4ff67513096 ("ipvs: add
> sync_maxlen parameter for the sync daemon")
> 
> Signed-off-by: YueHaibing <yuehaibing@huawei.com>

Thanks, this look good to me.

Acked-by: Simon Horman <horms@verge.net.au>

Pablo, please consider this for nf-next.

> ---
>  net/netfilter/ipvs/ip_vs_sync.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index 2b8abbfe018c..16b48064f715 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -242,9 +242,6 @@ struct ip_vs_sync_thread_data {
>        |                    IPVS Sync Connection (1)                   |
>  */
>  
> -#define SYNC_MESG_HEADER_LEN	4
> -#define MAX_CONNS_PER_SYNCBUFF	255 /* nr_conns in ip_vs_sync_mesg is 8 bit */
> -
>  /* Version 0 header */
>  struct ip_vs_sync_mesg_v0 {
>  	__u8                    nr_conns;
> -- 
> 2.17.1
> 
