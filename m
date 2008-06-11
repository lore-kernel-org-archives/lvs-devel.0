From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 05/26] IPVS: Use new address family specific debugging
 macros.
Date: Wed, 11 Jun 2008 19:14:53 +0200
Message-ID: <4850080D.30306@trash.net>
References: <1213204329-10973-1-git-send-email-juliusv@google.com> <1213204329-10973-6-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1213204329-10973-6-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: "Julius R. Volz" <juliusv@google.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, horms@verge.net.au, davem@davemloft.net, vbusam@google.com

Julius R. Volz wrote:
> Change debug output to use address family specific debugging macros where
> appropriate.
>
> -		IP_VS_ERR("request control DEL for uncontrolled: "
> -			  "%d.%d.%d.%d:%d to %d.%d.%d.%d:%d\n",
> -			  NIPQUAD(cp->caddr),ntohs(cp->cport),
> -			  NIPQUAD(cp->vaddr),ntohs(cp->vport));
> +		IP_VS_ERR_V4(cp->af, "request control DEL for uncontrolled: "
> +			     "%d.%d.%d.%d:%d to %d.%d.%d.%d:%d\n",
> +			     NIPQUAD(cp->caddr.v4),ntohs(cp->cport),
> +			     NIPQUAD(cp->vaddr.v4),ntohs(cp->vport));
> +
> +		IP_VS_ERR_V6(cp->af, "request control DEL for uncontrolled: "
> +			     NIP6_FMT ":%d to " NIP6_FMT ":%d\n",
> +			     NIP6(cp->caddr.v6),ntohs(cp->cport),
> +			     NIP6(cp->vaddr.v6),ntohs(cp->vport));
> +
>   

This would look at lot cleaner if you'd use a debugging macro that
can take both families.

