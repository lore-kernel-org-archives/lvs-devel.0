From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] Remove ipvs v6 dependency on iptables
Date: Thu, 27 Aug 2020 23:59:24 +0300 (EEST)
Message-ID: <alpine.LFD.2.23.451.2008272357240.4567@ja.home.ssi.bg>
References: <20200827194802.1164-1-iam@lach.pw>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20200827194802.1164-1-iam@lach.pw>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lach <iam@lach.pw>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org


	Hello,

On Fri, 28 Aug 2020, Lach wrote:

> This dependency was added in 63dca2c0b0e7a92cb39d1b1ecefa32ffda201975, because this commit had dependency on
> ipv6_find_hdr, which was located in iptables-specific code
> 
> But it is no longer required, because f8f626754ebeca613cf1af2e6f890cfde0e74d5b moved them to a more common location

	May be then we should also not include ip6_tables.h from
include/net/ip_vs.h ?

> ---
>  net/netfilter/ipvs/Kconfig | 1 -
>  1 file changed, 1 deletion(-)
> 
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

--
Julian Anastasov <ja@ssi.bg>

