From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 02/26] IPVS: Change IPVS data structures to support IPv6
 addresses.
Date: Wed, 11 Jun 2008 19:12:11 +0200
Message-ID: <4850076B.302@trash.net>
References: <1213204329-10973-1-git-send-email-juliusv@google.com> <1213204329-10973-3-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1213204329-10973-3-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: "Julius R. Volz" <juliusv@google.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, horms@verge.net.au, davem@davemloft.net, vbusam@google.com

Julius R. Volz wrote:
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 9a51eba..b7b181e 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -11,7 +11,12 @@
>  
>  #include <linux/sysctl.h>	/* For ctl_path */
>  
> -#define IP_VS_VERSION_CODE	0x010201
> +#ifdef __KERNEL__
> +#include <linux/in6.h>		/* For struct in6_addr */
> +#include <linux/ipv6.h>		/* For struct ipv6hdr */
>   

include/net is always kernel only. At least it should be that way.
> +#endif	/* __KERNEL */
> +
> +#define IP_VS_VERSION_CODE	0x020000
>  #define NVERSION(version)			\
>  	(version >> 16) & 0xFF,			\
>  	(version >> 8) & 0xFF,			\
> @@ -95,6 +100,20 @@
>  #define IP_VS_SCHEDNAME_MAXLEN	16
>  #define IP_VS_IFNAME_MAXLEN	16
>  
> +union ip_vs_addr_user {
> +	__be32			v4;
> +	struct in6_addr		v6;
> +};
>   

Can't you use nf_inet_addr for this?

