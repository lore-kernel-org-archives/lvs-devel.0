From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2] ipvs: add a 'default' case in do_ip_vs_set_ctl()
Date: Mon, 12 Dec 2022 16:20:41 +0200 (EET)
Message-ID: <c3ca27a-f923-6eb6-bbe4-5e99b65c5940@ssi.bg>
References: <272315c8-5e3b-e8ca-3c7f-68eccd0f2430@nfschina.com> <20221212074351.26440-1-liqiong@nfschina.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20221212074351.26440-1-liqiong@nfschina.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Li Qiong <liqiong@nfschina.com>
Cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, kernel-janitors@vger.kernel.org, coreteam@netfilter.org, Yu Zhe <yuzhe@nfschina.com>


	Hello,

On Mon, 12 Dec 2022, Li Qiong wrote:

> It is better to return the default switch case with
> '-EINVAL', in case new commands are added. otherwise,
> return a uninitialized value of ret.
> 
> Signed-off-by: Li Qiong <liqiong@nfschina.com>
> Reviewed-by: Simon Horman <horms@verge.net.au>

	Change looks correct to me for -next, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

	Still, the comment can explain that this code
is currently unreachable and that some parsers need
the default case to avoid report for uninitialized 'ret'.

> ---
> v2: Add 'default' case instead of initializing 'ret'.
> ---
>  net/netfilter/ipvs/ip_vs_ctl.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 988222fff9f0..97f6a1c8933a 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -2590,6 +2590,11 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, sockptr_t ptr, unsigned int len)
>  		break;
>  	case IP_VS_SO_SET_DELDEST:
>  		ret = ip_vs_del_dest(svc, &udest);
> +		break;
> +	default:
> +		WARN_ON_ONCE(1);
> +		ret = -EINVAL;
> +		break;
>  	}
>  
>    out_unlock:
> -- 
> 2.11.0

Regards

--
Julian Anastasov <ja@ssi.bg>

