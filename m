From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch] ipvs: Use atomic operations atomicly
Date: Mon, 31 Aug 2009 14:22:26 +0200
Message-ID: <4A9BC082.3090804@trash.net>
References: <20090828023722.GA12136@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090828023722.GA12136@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, =?UTF-8?B?7ZmN7IugIHNoaW4gaG9uZw==?= <hongshin@gmail.com>, David Miller <davem@davemloft.net>

Simon Horman wrote:
> A pointed out by Shin Hong, IPVS doesn't always use atomic operations
> in an atomic manner. While this seems unlikely to be manifest in
> strange behaviour, it seems appropriate to clean this up.
>=20
> Cc: =ED=99=8D=EC=8B=A0 shin hong <hongshin@gmail.com>
> Signed-off-by: Simon Horman <horms@verge.net.au>

Applied, thanks.

>  	if (af =3D=3D AF_INET &&
>  	    (ip_vs_sync_state & IP_VS_STATE_MASTER) &&
>  	    (((cp->protocol !=3D IPPROTO_TCP ||
>  	       cp->state =3D=3D IP_VS_TCP_S_ESTABLISHED) &&
> -	      (atomic_read(&cp->in_pkts) % sysctl_ip_vs_sync_threshold[1]
> +	      (pkts % sysctl_ip_vs_sync_threshold[1]

It seems that proc_do_sync_threshold() should check whether this value
is zero. The current checks also look racy since incorrect values are
first updated, then overwritten again.

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
