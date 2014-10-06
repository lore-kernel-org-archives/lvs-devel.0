From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] ipvs: remove unnecessary assignment in
 __ip_vs_get_out_rt
Date: Tue, 7 Oct 2014 01:22:00 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1410070112250.2258@ja.home.ssi.bg>
References: <1412627408-13766-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1412627408-13766-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com


	Hello,

On Mon, 6 Oct 2014, Alex Gartrell wrote:

> It is a precondition of the function that daddr be equal to dest->addr.ip
> if dest is non-NULL, so this additional assignment is just confusing for
> stupid engineers like me.
> 
> Signed-off-by: Alex Gartrell <agartrell@fb.com>

Acked-by: Julian Anastasov <ja@ssi.bg>

	Looks like this line appeared unexpectedly
in commit "ipvs: Eliminate rt->rt_dst usage in __ip_vs_get_out_rt()."

> ---
>  net/netfilter/ipvs/ip_vs_xmit.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index 91f17c1..5efa597 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -293,7 +293,6 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
>  				  &dest->addr.ip, &dest_dst->dst_saddr.ip,
>  				  atomic_read(&rt->dst.__refcnt));
>  		}
> -		daddr = dest->addr.ip;
>  		if (ret_saddr)
>  			*ret_saddr = dest_dst->dst_saddr.ip;
>  	} else {
> -- 
> Alex Gartrell <agartrell@fb.com>

Regards

--
Julian Anastasov <ja@ssi.bg>
