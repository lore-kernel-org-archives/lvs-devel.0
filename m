From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvsadm: Fix wrong format of --pe option in FMT_RULE
 listing
Date: Thu, 22 Aug 2013 15:46:21 +0900
Message-ID: <20130822064620.GC20703@verge.net.au>
References: <1377153951-1975-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1377153951-1975-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Thu, Aug 22, 2013 at 09:45:51AM +0300, Julian Anastasov wrote:
> 'ipvsadm -S' listed the persistence engine option in wrong format
> (' pe ...' instead of ' --pe ...') preventing any service with
> PE from restoring using 'ipvsadm -R'.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Thanks, applied.

> ---
>  ipvsadm.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/ipvsadm.c b/ipvsadm.c
> index 0197515..58f8241 100644
> --- a/ipvsadm.c
> +++ b/ipvsadm.c
> @@ -1485,7 +1485,7 @@ print_service_entry(ipvs_service_entry_t *se, unsigned int format)
>  				}
>  		}
>  		if (se->pe_name[0])
> -			printf(" pe %s", se->pe_name);
> +			printf(" --pe %s", se->pe_name);
>  		if (se->flags & IP_VS_SVC_F_ONEPACKET)
>  			printf(" -o");
>  	} else if (format & FMT_STATS) {
> -- 
> 1.7.3.4
> 
