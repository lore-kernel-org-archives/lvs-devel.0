From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCHv5 net-next] ipvs: remove dependency on ip6_tables
Date: Mon, 31 Aug 2020 20:12:05 +0300 (EEST)
Message-ID: <alpine.LFD.2.23.451.2008312005270.4425@ja.home.ssi.bg>
References: <alpine.LFD.2.23.451.2008291233110.3043@ja.home.ssi.bg> <20200829135953.20228-1-iam@lach.pw>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20200829135953.20228-1-iam@lach.pw>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yaroslav Bolyukin <iam@lach.pw>
Cc: "David S. Miller" <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Jakub Kicinski <kuba@kernel.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org


	Hello,

On Sat, 29 Aug 2020, Yaroslav Bolyukin wrote:

> This dependency was added because ipv6_find_hdr was in iptables specific
> code but is no longer required
> 
> Fixes: f8f626754ebe ("ipv6: Move ipv6_find_hdr() out of Netfilter code.")
> Fixes: 63dca2c0b0e7 ("ipvs: Fix faulty IPv6 extension header handling in IPVS").
> Signed-off-by: Yaroslav Bolyukin <iam@lach.pw>

	Looks good to me, thanks! May be maintainers will
remove the extra dot after the Fixes line.

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  Missed canonical patch format section, subsystem is now spevified
> 
>  include/net/ip_vs.h        | 3 ---
>  net/netfilter/ipvs/Kconfig | 1 -
>  2 files changed, 4 deletions(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 9a59a3378..d609e957a 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -25,9 +25,6 @@
>  #include <linux/ip.h>
>  #include <linux/ipv6.h>			/* for struct ipv6hdr */
>  #include <net/ipv6.h>
> -#if IS_ENABLED(CONFIG_IP_VS_IPV6)
> -#include <linux/netfilter_ipv6/ip6_tables.h>
> -#endif
>  #if IS_ENABLED(CONFIG_NF_CONNTRACK)
>  #include <net/netfilter/nf_conntrack.h>
>  #endif
> diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
> index 2c1593089..eb0e329f9 100644
> --- a/net/netfilter/ipvs/Kconfig
> +++ b/net/netfilter/ipvs/Kconfig
> @@ -29,7 +29,6 @@ if IP_VS
>  config	IP_VS_IPV6
>  	bool "IPv6 support for IPVS"
>  	depends on IPV6 = y || IP_VS = IPV6
> -	select IP6_NF_IPTABLES
>  	select NF_DEFRAG_IPV6
>  	help
>  	  Add IPv6 support to IPVS.
> --
> 2.28.0

Regards
