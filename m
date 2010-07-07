From: Simon Horman <horms@verge.net.au>
Subject: Re: IPVS: Incorrect helper use for SCTP [was:
 wensong@linux-vs.org, horms@verge.net.au]
Date: Wed, 7 Jul 2010 21:21:11 +0900
Message-ID: <20100707122110.GF17967@verge.net.au>
References: <AANLkTinEKn_UBpjf3k2DZn1euMM6z2UM_yeDPvdEQkav@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTinEKn_UBpjf3k2DZn1euMM6z2UM_yeDPvdEQkav@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="windows-1252"
To: xiaoyu Du <tingsrain@gmail.com>
Cc: lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org

[CCed netdev]

Thanks,

that looks correct to me. Have you tested this change?
If so could you provided a Signed-off-by line
as per section 12 of Documentation/SubmittingPatches?

On Wed, Jul 07, 2010 at 05:19:06PM +0800, xiaoyu Du wrote:
> Hi=EF=BC=8Call
>=20
> After I compared the sctp with tcp and udp, I thinkt his a bug that
> sctp_dnat_handler Incorrectly invoked ip_vs_app_pkt_out.
> below is the patch.
>=20
> ---
>  net/netfilter/ipvs/ip_vs_proto_sctp.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c
> b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> index c9a3f7a..db55759 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> @@ -173,7 +173,7 @@ sctp_dnat_handler(struct sk_buff *skb,
>                        return 0;
>=20
>                /* Call application helper if needed */
> -               if (!ip_vs_app_pkt_out(cp, skb))
> +               if (!ip_vs_app_pkt_in(cp, skb))
>                        return 0;
>        }
>=20
> --
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
