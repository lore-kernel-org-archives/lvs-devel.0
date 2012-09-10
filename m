From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: use list_del_init instead of
 list_del/INIT_LIST_HEAD
Date: Mon, 10 Sep 2012 09:01:30 +0900
Message-ID: <20120910000129.GA31408@verge.net.au>
References: <CAPgLHd_JMzWm-Eh48bXcq6xW2viVEQgmkxLU8KgVyD2gUk6sZQ@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAPgLHd_JMzWm-Eh48bXcq6xW2viVEQgmkxLU8KgVyD2gUk6sZQ@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wei Yongjun <weiyj.lk@gmail.com>
Cc: wensong@linux-vs.org, ja@ssi.bg, pablo@netfilter.org, kaber@trash.net, yongjun_wei@trendmicro.com.cn, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org

On Thu, Sep 06, 2012 at 12:21:53PM +0800, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Using list_del_init() instead of list_del() + INIT_LIST_HEAD().
> 
> spatch with a semantic match is used to found this problem.
> (http://coccinelle.lip6.fr/)
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Acked-by: Simon Horman <horms@verge.net.au>

> ---
>  net/netfilter/ipvs/ip_vs_ctl.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index f51013c..9d9f83e 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -539,8 +539,7 @@ static int ip_vs_rs_unhash(struct ip_vs_dest *dest)
>  	 * Remove it from the rs_table table.
>  	 */
>  	if (!list_empty(&dest->d_list)) {
> -		list_del(&dest->d_list);
> -		INIT_LIST_HEAD(&dest->d_list);
> +		list_del_init(&dest->d_list);
>  	}
>  
>  	return 1;
> 
> 
