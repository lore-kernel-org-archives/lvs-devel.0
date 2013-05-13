From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: Fix reuse connection if real server is dead
Date: Mon, 13 May 2013 10:38:52 +0900
Message-ID: <20130513013852.GE7826@verge.net.au>
References: <alpine.LFD.2.00.1305081012310.1912@ja.ssi.bg>
 <1368264745-15242-1-git-send-email-grzegorz.lyczba@gmail.com>
 <alpine.LFD.2.00.1305111533350.1612@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1305111533350.1612@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="windows-1252"
To: Julian Anastasov <ja@ssi.bg>
Cc: Grzegorz =?utf-8?Q?=C5=81yczba?= <grzegorz.lyczba@gmail.com>, lvs-devel@vger.kernel.org

On Sat, May 11, 2013 at 04:23:33PM +0300, Julian Anastasov wrote:
>=20
> 	Hello,
>=20
> On Sat, 11 May 2013, Grzegorz =C5=81yczba wrote:
>=20
> > From: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>
> >=20
> > Expire cached connection for new TCP/SCTP connection if real server=
 is down
> >=20
> > Signed-off-by: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>
>=20
> 	The change looks correct but you have to fix some
> coding style issues. Otherwise, patch will be rejected.
> You can also check Documentation/CodingStyle
>=20
> # scripts/checkpatch.pl /tmp/patch.diff
> WARNING: braces {} are not necessary for single statement blocks
> #25: FILE: net/netfilter/ipvs/ip_vs_core.c:1012:
> +               if (th =3D=3D NULL) {
> +                       return false;
> +               }
>=20
> WARNING: braces {} are not necessary for single statement blocks
> #34: FILE: net/netfilter/ipvs/ip_vs_core.c:1021:
> +               if (sch =3D=3D NULL) {
> +                       return false;
> +               }
>=20
> total: 0 errors, 2 warnings, 48 lines checked
>=20
> > ---
> >  net/netfilter/ipvs/ip_vs_core.c |   36 +++++++++++++++++++++++++++=
+++++++++
> >  1 files changed, 36 insertions(+), 0 deletions(-)
> >=20
> > diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/i=
p_vs_core.c
> > index 47edf5a..9ee8b70 100644
> > --- a/net/netfilter/ipvs/ip_vs_core.c
> > +++ b/net/netfilter/ipvs/ip_vs_core.c
> > @@ -1002,6 +1002,33 @@ static inline int is_tcp_reset(const struct =
sk_buff *skb, int nh_len)
> >  	return th->rst;
> >  }
> > =20
> > +static inline bool is_new_conn(const struct sk_buff *skb,
> > +	    struct ip_vs_iphdr *iph)
>=20
> 	Above "struct" should be at the same column as "const"
> in first argument, like this:
>=20
> static inline bool is_new_conn(const struct sk_buff *skb,
> 			       struct ip_vs_iphdr *iph)
>=20
> > +{
> > +	switch (iph->protocol) {
>=20
> 	I'm still not sure if this construct is allowed:
>=20
> 	case ...: {
> 	}

I see some evidence of the above style in net/core/
so personally I am fine with it.

>=20
> 	May be it should be:
>=20
> 	case ...:
> 		{
> 		}
> 	case ...
>=20
> 	but CodingStyle does not include rules about it.
> If in doubt, you can use 'if' instead of 'switch' without
> adding new indentation.
>=20
> > +	case IPPROTO_TCP: {
> > +		struct tcphdr _tcph, *th;
>=20
> 	empty line is needed here
>=20
> > +		th =3D skb_header_pointer(skb, iph->len, sizeof(_tcph), &_tcph);
> > +		if (th =3D=3D NULL) {
> > +			return false;
>=20
> 	extra braces
>=20
> > +		}
> > +		return th->syn;
> > +	}
> > +	case IPPROTO_SCTP: {
> > +		sctp_chunkhdr_t *sch, schunk;
>=20
> 	empty line is needed here
>=20
> > +		sch =3D skb_header_pointer(skb, iph->len + sizeof(sctp_sctphdr_t=
),
> > +				sizeof(schunk), &schunk);
> > +		if (sch =3D=3D NULL) {
> > +			return false;
>=20
> 	extra braces
>=20
> > +		}
> > +		return (sch->type =3D=3D SCTP_CID_INIT);
> > +	}
> > +	default:
> > +		return false;
> > +	}
> > +}
> > +
> > +
> >  /* Handle response packets: rewrite addresses and send away...
> >   */
> >  static unsigned int
> > @@ -1627,6 +1654,15 @@ ip_vs_in(unsigned int hooknum, struct sk_buf=
f *skb, int af)
> >  	 * Check if the packet belongs to an existing connection entry
> >  	 */
> >  	cp =3D pp->conn_in_get(af, skb, &iph, 0);
> > +
> > +	if (unlikely(sysctl_expire_nodest_conn(ipvs)) && cp && cp->dest &=
&
> > +	    !iph.fragoffs && unlikely(!atomic_read(&cp->dest->weight)) &&
>=20
> 	Lets move '!iph.fragoffs' after the
> 'unlikely(!atomic_read(&cp->dest->weight))' because fragoffs
> is usually 0. Only IPv6 can see fragments at that point.
>=20
> > +	    is_new_conn(skb, &iph)) {
> > +		ip_vs_conn_expire_now(cp);
> > +		__ip_vs_conn_put(cp);
> > +		cp =3D NULL;
> > +	}
> > +
> >  	if (unlikely(!cp) && !iph.fragoffs) {
> >  		/* No (second) fragments need to enter here, as nf_defrag_ipv6
> >  		 * replayed fragment zero will already have created the cp
> > --=20
> > 1.7.5.4
>=20
> Regards
>=20
> --
> Julian Anastasov <ja@ssi.bg>

