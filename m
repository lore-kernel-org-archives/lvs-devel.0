From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [*v4 PATCH 9/9] IPVS: skb defrag in L7 helpers BAD version
Date: Fri, 12 Nov 2010 10:45:20 +0100
Message-ID: <201011121045.21582.hans.schillstrom@ericsson.com>
References: <Re: [*v2 PATCH 0/9] IPVS: staging head> <1289554892-4487-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1289554892-4487-1-git-send-email-hans.schillstrom@ericsson.com>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: "horms@verge.net.au" <horms@verge.net.au>
Cc: "ja@ssi.bg" <ja@ssi.bg>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>

On Friday 12 November 2010 10:41:32 Hans Schillstr=F6m wrote:
> L7 helpers like sip needs skb defrag
> since L7 data can be fragmented.
>=20
> This patch requires "IPVS Break ports-2 into src_port and dst_port" p=
atch
>=20
> *v3
>   Removed unneeded if (skb_shinfo(skb)->nr_frags)
>   from Julian.
>=20
> Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> ---
>  net/netfilter/ipvs/ip_vs_pe_sip.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/i=
p_vs_pe_sip.c
> index b8b4e96..0d83bc0 100644
> --- a/net/netfilter/ipvs/ip_vs_pe_sip.c
> +++ b/net/netfilter/ipvs/ip_vs_pe_sip.c
> @@ -71,6 +71,7 @@ ip_vs_sip_fill_param(struct ip_vs_conn_param *p, st=
ruct sk_buff *skb)
>  	struct ip_vs_iphdr iph;
>  	unsigned int dataoff, datalen, matchoff, matchlen;
>  	const char *dptr;
> +	int retc;
> =20
>  	ip_vs_fill_iphdr(p->af, skb_network_header(skb), &iph);
> =20
> @@ -83,6 +84,8 @@ ip_vs_sip_fill_param(struct ip_vs_conn_param *p, st=
ruct sk_buff *skb)
>  	if (dataoff >=3D skb->len)
>  		return -EINVAL;
> =20
> +	if ((retc=3Dskb_linearize(skb)) < 0)
> +		return retc;
>  	dptr =3D skb->data + dataoff;
>  	datalen =3D skb->len - dataoff;
> =20

The correct version shoud be v3 (not v4)
--=20
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
