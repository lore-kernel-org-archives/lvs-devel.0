From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHv2 net-next 1/2] ipvs: fix the IPVS_CMD_ATTR_MAX definition
Date: Thu, 19 Sep 2013 14:24:35 -0700
Message-ID: <20130919212434.GL2918@verge.net.au>
References: <1378974126-9427-1-git-send-email-ja@ssi.bg>
 <1378974126-9427-2-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1378974126-9427-2-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Thu, Sep 12, 2013 at 11:22:05AM +0300, Julian Anastasov wrote:
> It was wrong (bigger) but problem is harmless.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Thanks, I have this in ipvs-next but have been very slow sending it.
And as I am currently on an aeroplane its a bit hard to
prepare a tag for a pull request right now. I will do so soon.

> ---
>  include/uapi/linux/ip_vs.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
> index 2945822..fbcffe8 100644
> --- a/include/uapi/linux/ip_vs.h
> +++ b/include/uapi/linux/ip_vs.h
> @@ -334,7 +334,7 @@ enum {
>  	__IPVS_CMD_ATTR_MAX,
>  };
>  
> -#define IPVS_CMD_ATTR_MAX (__IPVS_SVC_ATTR_MAX - 1)
> +#define IPVS_CMD_ATTR_MAX (__IPVS_CMD_ATTR_MAX - 1)
>  
>  /*
>   * Attributes used to describe a service
> -- 
> 1.7.3.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
