From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] ipvs: Avoid null-pointer deref in debug code
Date: Mon, 6 Oct 2014 09:49:57 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1410060940470.1738@ja.home.ssi.bg>
References: <20141001174526.GA16206@mwanda> <1412556895-26891-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1412556895-26891-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: horms@verge.net.au, dan.carpenter@oracle.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, kernel-team@fb.com


	Hello,

On Sun, 5 Oct 2014, Alex Gartrell wrote:

> Ensure that the pointer is non-NULL before dereferencing it for debugging
> purposes.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Alex Gartrell <agartrell@fb.com>
> ---
>  net/netfilter/ipvs/ip_vs_xmit.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index 91f17c1..06bba9b 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -316,7 +316,7 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
>  	if (unlikely(crosses_local_route_boundary(skb_af, skb, rt_mode,
>  						  local))) {
>  		IP_VS_DBG_RL("We are crossing local and non-local addresses"
> -			     " daddr=%pI4\n", &dest->addr.ip);
> +			     " daddr=%pI4\n", dest ? &dest->addr.ip : NULL);
>  		goto err_put;
>  	}
>  
> @@ -458,7 +458,7 @@ __ip_vs_get_out_rt_v6(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
>  	if (unlikely(crosses_local_route_boundary(skb_af, skb, rt_mode,
>  						  local))) {
>  		IP_VS_DBG_RL("We are crossing local and non-local addresses"
> -			     " daddr=%pI6\n", &dest->addr.in6);
> +			     " daddr=%pI6\n", dest ? &dest->addr.in6 : NULL);
>  		goto err_put;
>  	}

	You have to print the "daddr" variable as
it was done before your patchset in the
"Stopping traffic to %s address, dest: %p..." message
because dest is not present in all cases, for example,
for *bypass_xmit. Other places provide cp->daddr but
for backup server some conns can live without cp->dest.

Regards

--
Julian Anastasov <ja@ssi.bg>
