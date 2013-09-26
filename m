From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: improved SH fallback strategy
Date: Thu, 26 Sep 2013 23:05:06 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1309262255400.1949@ja.ssi.bg>
References: <20130923115139.GA15034@eldamar.org.uk> <524099BA.5020303@cogentembedded.com> <20130924093238.GD18494@eldamar.org.uk> <20130925003033.GG26081@verge.net.au> <20130925092638.GD19768@eldamar.org.uk> <alpine.LFD.2.00.1309260817290.1640@ja.ssi.bg>
 <20130926100540.GB27583@eldamar.org.uk>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20130926100540.GB27583@eldamar.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Frolkin <avf@eldamar.org.uk>
Cc: Simon Horman <horms@verge.net.au>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org


	Hello,

On Thu, 26 Sep 2013, Alexander Frolkin wrote:

> Improve the SH fallback realserver selection strategy.
> 
> With sh and sh-fallback, if a realserver is down, this attempts to
> distribute the traffic that would have gone to that server evenly
> among the remaining servers.
> 
> Signed-off-by: Alexander Frolkin <avf@eldamar.org.uk>

	Looks correct to me, just fix the below indentations.
Also, please use version number for your patches, eg.
[PATCHv2] ipvs: ...

> diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
> index 3588fae..533ea53 100644
> --- a/net/netfilter/ipvs/ip_vs_sh.c
> +++ b/net/netfilter/ipvs/ip_vs_sh.c

> +	IP_VS_DBG_BUF(6, "SH: selected unavailable server "
> +		"%s:%d, reselecting",
> +		IP_VS_DBG_ADDR(svc->af, &dest->addr),
> +		ntohs(dest->port));

	Indentation:

	IP_VS_DBG_BUF(6, "SH: selected unavailable server %s:%d, reselecting",
		      IP_VS_DBG_ADDR(svc->af, &dest->addr), ntohs(dest->port));


> +		IP_VS_DBG_BUF(6, "SH: selected unavailable "
> +			"server %s:%d (offset %d), reselecting",
> +			IP_VS_DBG_ADDR(svc->af, &dest->addr),
> +			ntohs(dest->port),
> +			roffset);

	Indentation:

		IP_VS_DBG_BUF(6, "SH: selected unavailable "
			      "server %s:%d (offset %d), reselecting",
			      IP_VS_DBG_ADDR(svc->af, &dest->addr),
			      ntohs(dest->port), roffset);

Regards

--
Julian Anastasov <ja@ssi.bg>
