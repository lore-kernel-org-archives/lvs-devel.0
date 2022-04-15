From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH nf] ipvs: correctly print the memory size of
 ip_vs_conn_tab
Date: Fri, 15 Apr 2022 09:21:47 +0200
Message-ID: <YlkdC1/AnuRCdhnv@vergenet.net>
References: <1649754031-18627-1-git-send-email-yangpc@wangsu.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1649754031-18627-1-git-send-email-yangpc@wangsu.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pengcheng Yang <yangpc@wangsu.com>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org

On Tue, Apr 12, 2022 at 05:00:31PM +0800, Pengcheng Yang wrote:
> The memory size of ip_vs_conn_tab changed after we use hlist
> instead of list.
> 
> Fixes: 731109e78415 ("ipvs: use hlist instead of list")
> Signed-off-by: Pengcheng Yang <yangpc@wangsu.com>

Acked-by: Simon Horman <horms@verge.net.au>

> ---
>  net/netfilter/ipvs/ip_vs_conn.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 2c467c4..e886c74 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -1495,7 +1495,7 @@ int __init ip_vs_conn_init(void)
>  	pr_info("Connection hash table configured "
>  		"(size=%d, memory=%ldKbytes)\n",
>  		ip_vs_conn_tab_size,
> -		(long)(ip_vs_conn_tab_size*sizeof(struct list_head))/1024);
> +		(long)(ip_vs_conn_tab_size*sizeof(struct hlist_head))/1024);
>  	IP_VS_DBG(0, "Each connection entry needs %zd bytes at least\n",
>  		  sizeof(struct ip_vs_conn));
>  
> -- 
> 1.8.3.1
> 
