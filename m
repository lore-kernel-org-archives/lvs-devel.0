From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] IPVS: Add handling of incoming ICMPV6_PKT_TOOBIG	messages
Date: Fri, 24 Jul 2009 06:25:25 +0200
Message-ID: <4A6937B5.3040707@gmail.com>
References: <20090624132232.GA9633@egardia> <20090724024711.GA13280@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20090724024711.GA13280@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, David Miller <davem@davemloft.net>, Julius Volz <julius.volz@gmail.com>, Rob Gallagher <robert.gallagher@heanet.ie>

Simon Horman a =E9crit :
> From: Julius Volz <julius.volz@gmail.com>
>=20
> IPVS: Add handling of incoming ICMPV6_PKT_TOOBIG messages
>=20
> Add handling of incoming ICMPv6 Packet Too Big messages. This message
> is received when a realserver sends a packet >PMTU to the client. The
> hop on this path with insufficient MTU will generate an ICMPv6 Packet
> Too Big message back to the VIP. The LVS server receives this message=
,
> but the call to the function handling this has been missing. Thus, IP=
VS
> fails to forward the message to the real server, which then does not
> adjust the path MTU. This patch adds the missing call to
> ip_vs_in_icmp_v6() in ip_vs_in() to handle this situation.
>=20
> Thanks to Rob Gallagher from HEAnet for reporting this issue and for
> testing this patch in production (with direct routing mode).
>=20
> Signed-off-by: Julius Volz <julius.volz@gmail.com>
> Tested-by: Rob Gallagher <robert.gallagher@heanet.ie>
> Signed-off-by: Simon Horman <horms@verge.net.au>
>=20
> ---
>  net/netfilter/ipvs/ip_vs_core.c |   23 +++++++++++++++++------
>  1 files changed, 17 insertions(+), 6 deletions(-)
>=20
> Dave, please consider applying this change.
>=20
> I'm ok with it not going into 2.6.31 as I don't think that
> many people are affected by this problem.
>=20
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_=
vs_core.c
> index 8dddb17..5750800 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1274,13 +1274,24 @@ ip_vs_in(unsigned int hooknum, struct sk_buff=
 *skb,
>  		return NF_ACCEPT;
>  	}
> =20
> -	if (unlikely(iph.protocol =3D=3D IPPROTO_ICMP)) {
> -		int related, verdict =3D ip_vs_in_icmp(skb, &related, hooknum);
> +#ifdef CONFIG_IP_VS_IPV6
> +	if (af =3D=3D AF_INET6) {
> +		if (unlikely(iph.protocol =3D=3D IPPROTO_ICMPV6)) {
> +			int related, verdict =3D ip_vs_in_icmp_v6(skb, &related, hooknum)=
;
> =20
> -		if (related)
> -			return verdict;
> -		ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
> -	}
> +			if (related)
> +				return verdict;
> +			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
> +		}
> +	} else
> +#endif
> +		if (unlikely(iph.protocol =3D=3D IPPROTO_ICMP)) {
> +			int related, verdict =3D ip_vs_in_icmp(skb, &related, hooknum);
> +
> +			if (related)
> +				return verdict;
> +			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
> +		}
> =20
>  	/* Protocol supported? */
>  	pp =3D ip_vs_proto_get(iph.protocol);

I see no reference to ICMPV6_PKT_TOOBIG in this patch, so ChangeLog mig=
ht be
misleading or uncomplete, since other ICMPV6 message types=20
(ICMPV6_DEST_UNREACH/ICMPV6_TIME_EXCEED) will also be forwarded/handled=
 ?


