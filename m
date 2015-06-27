From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] ipvs: fix ipv6 route unreach panic
Date: Sat, 27 Jun 2015 14:35:00 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1506271431530.19527@ja.home.ssi.bg>
References: <1435313925-107850-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1435313925-107850-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, kernel-team@fb.com


	Hello,

On Fri, 26 Jun 2015, Alex Gartrell wrote:

> Previously there was a trivial panic
> 
> unshare -n /bin/bash <<EOF
> ip addr add dev lo face::1/128
> ipvsadm -A -t [face::1]:15213
> ipvsadm -a -t [face::1]:15213 -r b00c::1
> echo boom | nc face::1 15213
> EOF
> 
> This patch allows us to replicate the net logic above and simply capture
> the skb_dst(skb)->dev and use that for the purpose of the invocation.
> 
> Signed-off-by: Alex Gartrell <agartrell@fb.com>

	Looks good to me, thanks! Simon, patch looks suitable
for ipvs (net) tree.

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_xmit.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index bf66a86..b99d806 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -505,6 +505,13 @@ err_put:
>  	return -1;
>  
>  err_unreach:
> +	/* The ip6_link_failure function requires the dev field to be set
> +	 * in order to get the net (further for the sake of fwmark
> +	 * reflection).
> +	 */
> +	if (!skb->dev)
> +		skb->dev = skb_dst(skb)->dev;
> +
>  	dst_link_failure(skb);
>  	return -1;
>  }
> -- 
> Alex Gartrell <agartrell@fb.com>

Regards

--
Julian Anastasov <ja@ssi.bg>
