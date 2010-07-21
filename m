From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch v2.6 4/4] libxt_ipvs: user-space lib for netfilter
 matcher xt_ipvs
Date: Wed, 21 Jul 2010 10:21:47 +0900
Message-ID: <20100721012146.GC22966@verge.net.au>
References: <20100711090342.035149543@vergenet.net>
 <20100711090500.421568837@vergenet.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100711090500.421568837@vergenet.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Malcolm Turnbull <malcolm@loadbalancer.org>, Wensong Zhang <wensong@linux-vs.org>, Julius Volz <julius.volz@gmail.com>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, Hannes Eder <heder@google.com>

On Sun, Jul 11, 2010 at 06:03:46PM +0900, horms@vergenet.net wrote:
> From:	Hannes Eder <heder@google.com>
> 
> The user-space library for the netfilter matcher xt_ipvs.

[snip]

> Index: iptables/include/linux/netfilter/xt_ipvs.h
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ iptables/include/linux/netfilter/xt_ipvs.h	2010-07-04 20:23:30.000000000 +0900
> @@ -0,0 +1,25 @@
> +#ifndef _XT_IPVS_H
> +#define _XT_IPVS_H 1
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

The kernel version of this file has been updated so that
l4proto and fwd_method are __u8. This also needs to be updated.
I will post an updated patch (v2.7).

> +	__be16			vportctl;
> +
> +	__u8			invert;
> +	__u8			bitmask;
> +};
> +
> +#endif /* _XT_IPVS_H */
