From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] IPVS: Update CONFIG_IP_VS_IPV6 description and help
	text
Date: Mon, 20 Oct 2008 09:37:12 +1100
Message-ID: <20081019223710.GA17139@verge.net.au>
References: <1224245091-30426-1-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1224245091-30426-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, davem@davemloft.net, vbusam@google.com

On Fri, Oct 17, 2008 at 02:04:51PM +0200, Julius Volz wrote:
> This adds a URL to further info to the CONFIG_IP_VS_IPV6 Kconfig help
> text.

Thanks, that looks good to me.

Dave, can we put this into 2.6.28, or does it need to wait?

> Also, I think it should be ok to remove the "DANGEROUS" label in the
> description line at this point to get people to try it out and find all
> the bugs ;) It's still marked as experimental, of course.

I'm fine with that too.


> Signed-off-by: Julius Volz <juliusv@google.com>
> 
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
> index 05048e4..79a6980 100644
> --- a/net/netfilter/ipvs/Kconfig
> +++ b/net/netfilter/ipvs/Kconfig
> @@ -25,11 +25,13 @@ menuconfig IP_VS
>  if IP_VS
>  
>  config	IP_VS_IPV6
> -	bool "IPv6 support for IPVS (DANGEROUS)"
> +	bool "IPv6 support for IPVS"
>  	depends on EXPERIMENTAL && (IPV6 = y || IP_VS = IPV6)
>  	---help---
>  	  Add IPv6 support to IPVS. This is incomplete and might be dangerous.
>  
> +	  See http://www.mindbasket.com/ipvs for more information.
> +
>  	  Say N if unsure.
>  
>  config	IP_VS_DEBUG
> -- 
> 1.5.4.5

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

