From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 5/5] net/netfilter/ipvs: Eliminate memory leak
Date: Wed, 25 Aug 2010 10:34:43 +0900
Message-ID: <20100825013443.GC7237@verge.net.au>
References: <Pine.LNX.4.64.1008241639300.15172@ask.diku.dk>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.1008241639300.15172@ask.diku.dk>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julia Lawall <julia@diku.dk>
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

On Tue, Aug 24, 2010 at 04:39:49PM +0200, Julia Lawall wrote:
> From: Julia Lawall <julia@diku.dk>
> 
> __ip_vs_service_get and __ip_vs_svc_fwm_get increment a reference count, so
> that reference count should be decremented before leaving the function in an
> error case.
> 
> A simplified version of the semantic match that finds this problem is:
> (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @r exists@
> local idexpression x;
> expression E;
> identifier f1;
> iterator I;
> @@
> 
> x = __ip_vs_service_get(...);
> <... when != x
>      when != true (x == NULL || ...)
>      when != if (...) { <+...x...+> }
>      when != I (...) { <+...x...+> }
> (
>  x == NULL
> |
>  x == E
> |
>  x->f1
> )
> ...>
> * return ...;
> // </smpl>
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>

Thanks Julia, that looks good to me.

Signed-off-by: Simon Horman <horms@verge.net.au>

Patrick, I guess that this should go through nf-next-2.6.

> 
> ---
>  net/netfilter/ipvs/ip_vs_ctl.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 0f0c079..f98169b 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -2155,7 +2155,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
>  	if (cmd != IP_VS_SO_SET_ADD
>  	    && (svc == NULL || svc->protocol != usvc.protocol)) {
>  		ret = -ESRCH;
> -		goto out_unlock;
> +		goto out_drop_service;
>  	}
>  
>  	switch (cmd) {
> @@ -2189,6 +2189,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
>  		ret = -EINVAL;
>  	}
>  
> +out_drop_service:
>  	if (svc)
>  		ip_vs_service_put(svc);
>  
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
