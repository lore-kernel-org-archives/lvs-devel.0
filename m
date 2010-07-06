From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch v2.3 1/4] netfilter: xt_ipvs (netfilter matcher for IPVS)
Date: Tue, 06 Jul 2010 13:32:48 +0200
Message-ID: <4C331460.7050509@trash.net>
References: <20100704113246.562399500@vergenet.net> <20100704114808.459045895@vergenet.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100704114808.459045895@vergenet.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org, Malcolm Turnbull <malcolm@loadbalancer.org>, Wensong Zhang <wensong@linux-vs.org>, Julius Volz <julius.volz@gmail.com>, "David S. Miller" <davem@davemloft.net>, Hannes Eder <heder@google.com>

Simon Horman wrote:
> From:	Hannes Eder <heder@google.com>
>
> This implements the kernel-space side of the netfilter matcher xt_ipvs.
>   
> @@ -0,0 +1,25 @@
> +#ifndef _XT_IPVS_H
> +#define _XT_IPVS_H
> +
> +#define XT_IPVS_IPVS_PROPERTY	(1 << 0) /* all other options imply this one */
> +#define XT_IPVS_PROTO		(1 << 1)
> +#define XT_IPVS_VADDR		(1 << 2)
> +#define XT_IPVS_VPORT		(1 << 3)
> +#define XT_IPVS_DIR		(1 << 4)
> +#define XT_IPVS_METHOD		(1 << 5)
> +#define XT_IPVS_VPORTCTL	(1 << 6)
> +#define XT_IPVS_MASK		((1 << 7) - 1)
> +#define XT_IPVS_ONCE_MASK	(XT_IPVS_MASK & ~XT_IPVS_IPVS_PROPERTY)
> +
> +struct xt_ipvs_mtinfo {
> +	union nf_inet_addr	vaddr, vmask;
> +	__be16			vport;
> +	__u16			l4proto;
> +	__u16			fwd_method;
>   
It seems you could use __u8 for both l4proto and fwd_method
and reduce the match size by 2 bytes.

> +	__be16			vportctl;
> +
> +	__u8			invert;
> +	__u8			bitmask;
> +};
> +static bool
> +ipvs_mt(const struct sk_buff *skb, struct xt_action_param *par)
> +...
>   
> +	if (data->bitmask & XT_IPVS_DIR) {
> +		enum ip_conntrack_info ctinfo;
> +		struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
> +
> +		if (ct == NULL || ct == &nf_conntrack_untracked) {
>   
We're using per-cpu structures for nf_conntrack_untracked in the
current net-next/nf-next tree, so this doesn't work anymore. You
need to use nf_ct_is_untracked() instead.

> +			match = false;
> +			goto out_put_cp;
> +		}

