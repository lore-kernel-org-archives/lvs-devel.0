From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch v2.2 1/4] [PATCH v2.1 1/4] netfilter: xt_ipvs (netfilter
 matcher for IPVS)
Date: Sat, 01 May 2010 18:18:07 +0200
Message-ID: <4BDC543F.7060500@trash.net>
References: <20100501032014.406353538@vergenet.net> <20100501032120.298829234@vergenet.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20100501032120.298829234@vergenet.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julius Volz <julius.volz@gmail.com>, "David S. Miller" <davem@davemloft.net>, Hannes Eder <heder@google.com>, Netfilter Development Mailinglist <netfilter-devel@vger.kernel.org>

Simon Horman wrote:

> @@ -0,0 +1,25 @@
> +#ifndef _XT_IPVS_H
> +#define _XT_IPVS_H 1

You don't need to define a value.

> +config NETFILTER_XT_MATCH_IPVS
> +	tristate '"ipvs" match support'
> +	depends on IP_VS
> +	depends on NETFILTER_ADVANCED
> +	help
> +	  This option allows you to match against IPVS properties of a packet.
> +
> +	  If unsure, say N.

You're using conntrack symbols, so this seems to need a dependency
on NF_CONNTRACK.

> +static bool ipvs_mt_check(const struct xt_mtchk_param *par)

We've changed the signature to "int" in nf-next to be able to
return errno codes. Please rebase your patches onto nf-next-2.6.git.

Please also CC netfilter-devel at least for those parts that affect
non-IPVS netfilter.

> +{
> +	if (par->family != NFPROTO_IPV4
> +#ifdef CONFIG_IP_VS_IPV6
> +	    && par->family != NFPROTO_IPV6
> +#endif
> +		) {
> +		pr_info("protocol family %u not supported\n", par->family);
> +		return false;
> +	}
> +
> +	return true;
> +}

