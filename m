From: =?UTF-8?B?RmFiaWVuIER1Y2jDqm5l?= 
	<fabien.duchene@student.uclouvain.be>
Subject: Re: [bug] FWMARKs and persistence in IPVS: The Use of Unions
Date: Tue, 28 Apr 2009 13:30:26 +0200
Message-ID: <49F6E8D2.8010403@student.uclouvain.be>
References: <20090428081509.GA746@verge.net.au> <alpine.LSU.2.00.0904281103250.27149@fbirervta.pbzchgretzou.qr> <20090428092351.GC8165@verge.net.au> <20090428105941.GA20907@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090428105941.GA20907@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Simon Horman <horms@verge.net.au>
Cc: Jan Engelhardt <jengelh@medozas.de>, netfilter-devel <netfilter-devel@vger.kernel.org>, lvs-devel@vger.kernel.org, Joseph Mack NA3T <jmack@wm7d.net>, Julius Volz <julius.volz@gmail.com>

Simon Horman a =C3=A9crit :
> On Tue, Apr 28, 2009 at 07:23:55PM +1000, Simon Horman wrote:
>> On Tue, Apr 28, 2009 at 11:07:40AM +0200, Jan Engelhardt wrote:
>>> On Tuesday 2009-04-28 10:15, Simon Horman wrote:
>>>> It seems to me that it should be easy enough to fix by changing
>>>> fwmark in ip_vs_sched_persist() from:
>>>>
>>>> union nf_inet_addr fwmark =3D {
>>>> 	.all =3D { 0, 0, 0, htonl(svc->fwmark) }
>>>> };
>>>>
>>>> to:
>>>>
>>>> union nf_inet_addr fwmark =3D {
>>>> 	.all =3D { htonl(svc->fwmark), 0, 0, 0 }
>>>> };
>>>>
>>>> Assuming that this would result in fwmark->ip being set to
>>>> htonl(svc->fwmark), which is relevant if svc->af is AF_INET - that=
 is,
>>>> for IPv4.[...]
>>>> An alternate idea would be to change the af value used for fwmarks=
,
>>>> but this seems to be even less clean than the current (slightly br=
oken)
>>>> technique of using nf_inet_addr for IPv4 or IPv6 addresses, or fwm=
arks.
>>> If you use ->all, then using NFPROTO_UNSPEC as af
>>> seems to me like a good match.
>=20
> I am guessing that AF_UNSPEC is more appropriate than NFPROTO_UNSPEC.
> Please correct me if I am wrong.
>=20
>> That seems reasonable, though ip_vs_ct_in_get() would still
>> need to use the real af for the cp->af =3D=3D af and
>> ip_vs_addr_equal(af, s_addr, &cp->caddr) portinos of the check.
>=20
> It looks like checking for proto =3D=3D IPPROTO_IP can tell us if
> the destination is a fwmark. This is based on the assumption that
> iph.protocol can never be IPPROTO_IP in ip_vs_sched_persist().
>=20
> The following patch expresses these ideas as they crrently stand.
> Fabien, is it possible for you to test this?
>=20
Yep!

I'll do it right now.
> Index: net-next-2.6/net/netfilter/ipvs/ip_vs_conn.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net-next-2.6.orig/net/netfilter/ipvs/ip_vs_conn.c	2009-04-28 20:3=
7:48.000000000 +1000
> +++ net-next-2.6/net/netfilter/ipvs/ip_vs_conn.c	2009-04-28 20:37:51.=
000000000 +1000
> @@ -260,7 +260,10 @@ struct ip_vs_conn *ip_vs_ct_in_get
>  	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
>  		if (cp->af =3D=3D af &&
>  		    ip_vs_addr_equal(af, s_addr, &cp->caddr) &&
> -		    ip_vs_addr_equal(af, d_addr, &cp->vaddr) &&
> +		    /* protocol should only be IPPROTO_IP if
> +		     * d_addr is a fwmark */
> +		    ip_vs_addr_equal(protocol =3D=3D IPPROTO_IP ? AF_UNSPEC : af,
> +		                     d_addr, &cp->vaddr) &&
>  		    s_port =3D=3D cp->cport && d_port =3D=3D cp->vport &&
>  		    cp->flags & IP_VS_CONN_F_TEMPLATE &&
>  		    protocol =3D=3D cp->protocol) {
> @@ -698,7 +701,9 @@ ip_vs_conn_new(int af, int proto, const=20
>  	cp->cport	   =3D cport;
>  	ip_vs_addr_copy(af, &cp->vaddr, vaddr);
>  	cp->vport	   =3D vport;
> -	ip_vs_addr_copy(af, &cp->daddr, daddr);
> +	/* proto should only be IPPROTO_IP if d_addr is a fwmark */
> +	ip_vs_addr_copy(proto =3D=3D IPPROTO_IP ? AF_UNSPEC : af,
> +			&cp->daddr, daddr);
>  	cp->dport          =3D dport;
>  	cp->flags	   =3D flags;
>  	spin_lock_init(&cp->lock);
> Index: net-next-2.6/net/netfilter/ipvs/ip_vs_core.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net-next-2.6.orig/net/netfilter/ipvs/ip_vs_core.c	2009-04-28 20:3=
7:48.000000000 +1000
> +++ net-next-2.6/net/netfilter/ipvs/ip_vs_core.c	2009-04-28 20:37:51.=
000000000 +1000
> @@ -278,7 +278,7 @@ ip_vs_sched_persist(struct ip_vs_service
>  		 */
>  		if (svc->fwmark) {
>  			union nf_inet_addr fwmark =3D {
> -				.all =3D { 0, 0, 0, htonl(svc->fwmark) }
> +				.ip =3D htonl(svc->fwmark)
>  			};
> =20
>  			ct =3D ip_vs_ct_in_get(svc->af, IPPROTO_IP, &snet, 0,
> @@ -306,7 +306,7 @@ ip_vs_sched_persist(struct ip_vs_service
>  			 */
>  			if (svc->fwmark) {
>  				union nf_inet_addr fwmark =3D {
> -					.all =3D { 0, 0, 0, htonl(svc->fwmark) }
> +					.ip =3D htonl(svc->fwmark)
>  				};
> =20
>  				ct =3D ip_vs_conn_new(svc->af, IPPROTO_IP,
>=20
>=20

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
