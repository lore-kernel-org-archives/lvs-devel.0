From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch v2.2 3/4] [PATCH v2.1 3/4] IPVS: make FTP work with full
 NAT support
Date: Sat, 01 May 2010 18:26:04 +0200
Message-ID: <4BDC561C.8090102@trash.net>
References: <20100501032014.406353538@vergenet.net> <20100501032120.998807955@vergenet.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20100501032120.998807955@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julius Volz <julius.volz@gmail.com>, "David S. Miller" <davem@davemloft.net>, Hannes Eder <heder@google.com>, Netfilter Development Mailinglist <netfilter-devel@vger.kernel.org>

Simon Horman wrote:

> +#define FMT_TUPLE	"%u.%u.%u.%u:%u->%u.%u.%u.%u:%u/%u"
> +#define ARG_TUPLE(T)	NIPQUAD((T)->src.u3.ip), ntohs((T)->src.u.all), \
> +			NIPQUAD((T)->dst.u3.ip), ntohs((T)->dst.u.all), \
> +			(T)->dst.protonum
> +
> +#define FMT_CONN	"%u.%u.%u.%u:%u->%u.%u.%u.%u:%u->%u.%u.%u.%u:%u/%u:%u"
> +#define ARG_CONN(C)	NIPQUAD((C)->caddr), ntohs((C)->cport), \
> +			NIPQUAD((C)->vaddr), ntohs((C)->vport), \
> +			NIPQUAD((C)->daddr), ntohs((C)->dport), \
> +			(C)->protocol, (C)->state
>  

Please use the appropriate format string (%pI4) instead of NIPQUAD.

> +		buf_len = sprintf(buf, "%u,%u,%u,%u,%u,%u", NIPQUAD(from.ip),
> +				  (ntohs(port)>>8)&255, ntohs(port)&255);
> +
> +		ct = nf_ct_get(skb, &ctinfo);
> +		ret = nf_nat_mangle_tcp_packet(skb,
> +					       ct,
> +					       ctinfo,
> +					       start-data,
> +					       end-start,
> +					       buf,
> +					       buf_len);
> +
> +		if (ct && ct != &nf_conntrack_untracked)

ct is non-NULL, otherwise we'll crash in nf_nat_mangle_tcp_packet().
Are you sure you want to mangle untracked packets above? That doesn't
work when their are size changes.
