From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ip_vs_sh: fix build
Date: Wed, 29 May 2013 23:59:06 +0900
Message-ID: <20130529145906.GA9929@verge.net.au>
References: <51A611CF02000078000D99A6@nat28.tlf.novell.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51A611CF02000078000D99A6@nat28.tlf.novell.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Beulich <JBeulich@suse.com>
Cc: wensong@linux-vs.org, ja@ssi.bg, pablo@netfilter.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Wed, May 29, 2013 at 01:33:51PM +0100, Jan Beulich wrote:
> kfree_rcu() requires offsetof(..., rcu_head) < 4096, which can get
> violated with a sufficiently high CONFIG_IP_VS_SH_TAB_BITS.
> 
> Signed-off-by: Jan Beulich <jbeulich@suse.com>

Thanks Jan.

Pablo, could you take this one directly into your tree?

Signed-off-by: Simon Horman <horms@verge.net.au>

> 
> ---
>  net/netfilter/ipvs/ip_vs_sh.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- 3.10-rc3/net/netfilter/ipvs/ip_vs_sh.c
> +++ 3.10-rc3-ip_vs_sh-build/net/netfilter/ipvs/ip_vs_sh.c
> @@ -67,8 +67,8 @@ struct ip_vs_sh_bucket {
>  #define IP_VS_SH_TAB_MASK               (IP_VS_SH_TAB_SIZE - 1)
>  
>  struct ip_vs_sh_state {
> -	struct ip_vs_sh_bucket		buckets[IP_VS_SH_TAB_SIZE];
>  	struct rcu_head			rcu_head;
> +	struct ip_vs_sh_bucket		buckets[IP_VS_SH_TAB_SIZE];
>  };
>  
>  /*
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
