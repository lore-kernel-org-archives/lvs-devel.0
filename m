From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v3] ipvs: add checksum support for gue encapsulation
Date: Thu, 30 May 2019 01:22:06 +0300 (EEST)
Message-ID: <alpine.LFD.2.21.1905300115590.2934@ja.home.ssi.bg>
References: <20190528231107.14197-1-hengqing.hu@gmail.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20190528231107.14197-1-hengqing.hu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jacky Hu <hengqing.hu@gmail.com>
Cc: jacky.hu@walmart.com, jason.niesz@walmart.com, "David S. Miller" <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org


	Hello,

On Wed, 29 May 2019, Jacky Hu wrote:

>  	gueh = (struct guehdr *)skb->data;
>  
>  	gueh->control = 0;
>  	gueh->version = 0;
> -	gueh->hlen = 0;
> +	gueh->hlen = optlen >> 2;
>  	gueh->flags = 0;
>  	gueh->proto_ctype = *next_protocol;
>  
> +	data = &gueh[1];
> +
> +	if (need_priv) {
> +		__be32 *flags = data;
> +		u16 csum_start = skb_checksum_start_offset(skb);
> +		__be16 *pd = data;

	Packet tests show another problem. Fix is to defer
pd assignment after data += GUE_LEN_PRIV:

		__be16 *pd;

> +
> +		gueh->flags |= GUE_FLAG_PRIV;
> +		*flags = 0;
> +		data += GUE_LEN_PRIV;
> +
> +		if (csum_start < hdrlen)
> +			return -EINVAL;
> +
> +		csum_start -= hdrlen;

		pd = data;

> +		pd[0] = htons(csum_start);
> +		pd[1] = htons(csum_start + skb->csum_offset);
> +
> +		if (!skb_is_gso(skb)) {
> +			skb->ip_summed = CHECKSUM_NONE;
> +			skb->encapsulation = 0;
> +		}
> +
> +		*flags |= GUE_PFLAG_REMCSUM;
> +		data += GUE_PLEN_REMCSUM;
> +	}
> +

Regards

--
Julian Anastasov <ja@ssi.bg>
