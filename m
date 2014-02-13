From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] sections, ipvs: Remove useless __read_mostly for ipvs
 genl_ops
Date: Thu, 13 Feb 2014 16:05:38 +0900
Message-ID: <20140213070538.GA11245@verge.net.au>
References: <1391846221-30240-1-git-send-email-ak@linux.intel.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1391846221-30240-1-git-send-email-ak@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@linux.intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org

On Sat, Feb 08, 2014 at 08:57:01AM +0100, Andi Kleen wrote:
> const __read_mostly does not make any sense, because const
> data is already read-only. Remove the __read_mostly
> for the ipvs genl_ops. This avoids a LTO
> section conflict compile problem.

Thanks Andi, applied to ipvs-next.

> Cc: Simon Horman <horms@verge.net.au>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: lvs-devel@vger.kernel.org
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> ---
>  net/netfilter/ipvs/ip_vs_ctl.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 35be035..2a68a38 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -3580,7 +3580,7 @@ out:
>  }
>  
>  
> -static const struct genl_ops ip_vs_genl_ops[] __read_mostly = {
> +static const struct genl_ops ip_vs_genl_ops[] = {
>  	{
>  		.cmd	= IPVS_CMD_NEW_SERVICE,
>  		.flags	= GENL_ADMIN_PERM,
> -- 
> 1.8.5.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
