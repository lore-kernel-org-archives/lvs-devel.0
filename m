From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/3] netfilter: xt_ipvs (netfilter matcher for IPVS)
Date: Wed, 02 Sep 2009 16:54:09 +0200
Message-ID: <4A9E8711.1070807@trash.net>
References: <20090902101417.11561.45663.stgit@jazzy.zrh.corp.google.com> <20090902101527.11561.59498.stgit@jazzy.zrh.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20090902101527.11561.59498.stgit@jazzy.zrh.corp.google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Hannes Eder <heder@google.com>
Cc: lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, =?ISO-8859-15?Q?Fabien_Duch=EAne?= <mad_fab@skynet.be>, Jan Engelhardt <jengelh@medozas.de>, Jean-Luc Fortemaison <jl.fortemaison@uclouvain.be>, Julian Anastasov <ja@ssi.bg>, Julius Volz <julius.volz@gmail.com>, Laurent Grawet <laurent.grawet@uclouvain.be>, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>

Hannes Eder wrote:
> This implements the kernel-space side of the netfilter matcher
> xt_ipvs.

Looks mostly fine to me, just one question:

> +bool ipvs_mt(const struct sk_buff *skb, const struct xt_match_param *par)
> +{
> +	const struct xt_ipvs *data = par->matchinfo;
> +	const u_int8_t family = par->family;
> +	struct ip_vs_iphdr iph;
> +	struct ip_vs_protocol *pp;
> +	struct ip_vs_conn *cp;
> +	int af;
> +	bool match = true;
> +
> +	if (data->bitmask == XT_IPVS_IPVS_PROPERTY) {
> +		match = skb->ipvs_property ^
> +			!!(data->invert & XT_IPVS_IPVS_PROPERTY);
> +		goto out;
> +	}
> +
> +	/* other flags than XT_IPVS_IPVS_PROPERTY are set */
> +	if (!skb->ipvs_property) {
> +		match = false;
> +		goto out;
> +	}
> +
> +	switch (skb->protocol) {
> +	case  htons(ETH_P_IP):
> +		af = AF_INET;
> +		break;
> +#ifdef CONFIG_IP_VS_IPV6
> +	case  htons(ETH_P_IPV6):
> +		af = AF_INET6;
> +		break;
> +#endif
> +	default:
> +		match = false;
> +		goto out;
> +	}

In the NF_INET_LOCAL_OUT hook skb->protocol is invalid. So if you
don't need this, it would make sense to restrict the match to the
other hooks.

Even easier would be to use par->family, which contains the address
family and doesn't need any translation.
