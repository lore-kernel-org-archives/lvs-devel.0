From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [PATCH 1/2] IPVS Bug IPv6 extension header handling faulty.
Date: Wed, 22 Feb 2012 08:46:52 +0100
Message-ID: <201202220846.58599.hans@schillstrom.com>
References: <1329223689-19792-1-git-send-email-hans.schillstrom@ericsson.com> <1329223689-19792-2-git-send-email-hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1202220040001.1685@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1376956.FWRIoGh3TM";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1202220040001.1685@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, horms@verge.net.au, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, kaber@trash.net, pablo@netfilter.org

--nextPart1376956.FWRIoGh3TM
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hello Julian
On Wednesday, February 22, 2012 02:07:54 Julian Anastasov wrote:
>=20
> 	Hello,
>=20
> On Tue, 14 Feb 2012, Hans Schillstrom wrote:
>=20
> > IPv6 headers must be processed in order of apperence,
> > neither can it be assumed that Upper layer headers is first.
> > If anything else than L4 is the first header IPVS will throw it.
> >=20
> > IPVS will write SNAT & DNAT modifications at a fixed pos witch
> > will corrupt the message. Proper header possition must be found
> > before writing modifying packet.
> >=20
> > Since it is quite costly to scan and find ipv6 headers, it
> > is done once and sent as "struct iphdr *" to affected funcs.
> > This is what causes most of the changes in this patch.
> >=20
> > This patch depends on "NETFILTER added flags to ipv6_find_hdr()" patch
> > http://www.spinics.net/lists/netfilter-devel/msg20684.html
> >=20
> > This also adds a dependence to ip6_tables.
> >=20
> > Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> > ---
>=20
> >  static inline void
> > -ip_vs_fill_iphdr(int af, const void *nh, struct ip_vs_iphdr *iphdr)
> > +ip_vs_fill_ip4hdr(const void *nh, struct ip_vs_iphdr *iphdr)
> >  {
> > +	const struct iphdr *iph =3D nh;
> > +
> > +	iphdr->len =3D iph->ihl * 4;
> > +	iphdr->offs =3D 0;
> > +	iphdr->fragoffs =3D 0;
> > +	iphdr->protocol =3D iph->protocol;
> > +	iphdr->flags =3D 0;
>=20
> 	May be there is no need ip_vs_fill_ip4hdr to initialize
> the new fields that are IPv6 specific.

That's true  offs, fragoffs and flags can be skipped.
Maybe fragoffs still should be set to zero... because it is used in some pl=
aces
I mean for future changes, (it's not needed today)

Like this place in ip_vs_in()=20

if (unlikely(!cp) && !iph.fragoffs) {
=2E.

ip_vs_fill_ip4hdr() is not so heavily used :-)=20
(only in icmp and for fragments in ip_vs_out)




>=20
> > +	iphdr->saddr.ip =3D iph->saddr;
> > +	iphdr->daddr.ip =3D iph->daddr;
> > +}
> > +
>=20
> > @@ -1379,8 +1347,8 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, =
unsigned int hooknum)
> >  	/* do the statistics and put it back */
> >  	ip_vs_in_stats(cp, skb);
> >  	if (IPPROTO_TCP =3D=3D cih->protocol || IPPROTO_UDP =3D=3D cih->proto=
col)
> > -		offset +=3D 2 * sizeof(__u16);
> > -	verdict =3D ip_vs_icmp_xmit(skb, cp, pp, offset, hooknum);
> > +		ciph.len +=3D 2 * sizeof(__u16);
>=20
> 	Can we avoid adding ports to ciph.len? May be we can
> use the offset var and to provide it to ip_vs_icmp_xmit,
> just like for IPv6 below.

Hmm, I don't think so, then offset needs to be updated before i.e. more code
(ciph is a local var and it's not so expensive to use it.)

A change will be like this,=20

	ip_vs_fill_ip4hdr(cih, &ciph);
	ciph.len +=3D offset;
	/* The embedded headers contain source and dest in reverse order */
	cp =3D pp->conn_in_get(AF_INET, skb, &ciph, 1);
[snip]
	/* do the statistics and put it back */
	ip_vs_in_stats(cp, skb);
+   offset =3D ciph.len;
	if (IPPROTO_TCP =3D=3D cih->protocol || IPPROTO_UDP =3D=3D cih->protocol)
=2D		ciph.len +=3D 2 * sizeof(__u16);
+        offset +=3D 2 * sizeof(__u16);
=2D	verdict =3D ip_vs_icmp_xmit(skb, cp, pp, ciph.len, hooknum, &ciph);
+	verdict =3D ip_vs_icmp_xmit(skb, cp, pp, offset, hooknum, &ciph);


>=20
> > +	verdict =3D ip_vs_icmp_xmit(skb, cp, pp, ciph.len, hooknum, &ciph);
> > =20
> >  out:
> >  	__ip_vs_conn_put(cp);
> > @@ -1389,14 +1357,11 @@ out:
> >  }
> > -	if (IPPROTO_TCP =3D=3D cih->nexthdr || IPPROTO_UDP =3D=3D cih->nexthd=
r ||
> > -	    IPPROTO_SCTP =3D=3D cih->nexthdr)
> > -		offset +=3D 2 * sizeof(__u16);
> > -	verdict =3D ip_vs_icmp_xmit_v6(skb, cp, pp, offset, hooknum);
> > +	if (IPPROTO_TCP =3D=3D ciph.protocol || IPPROTO_UDP =3D=3D ciph.proto=
col ||
> > +	    IPPROTO_SCTP =3D=3D ciph.protocol)
> > +		offset =3D ciph.len + (2 * sizeof(__u16));
> > +
> > +	verdict =3D ip_vs_icmp_xmit_v6(skb, cp, pp, offset, hooknum, &ciph);
> > =20
> >  	__ip_vs_conn_put(cp);
> > =20
>=20
> > @@ -1546,7 +1508,8 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *sk=
b, int af)
> > =20
> >  			if (related)
> >  				return verdict;
> > -			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
> > +			/* I don't think this one is needed ... /HS */
> > +			ip_vs_fill_iph_skb(af, skb, &iph);
>=20
> 	Yes, I don't remember why we need this, may be
> there were pointers in the structure long time ago.

I will remove it, it's good to have your opinion too.=20

>=20
> 	As for patch 2, it is dangerous to use skb_dst_copy
> without checking for present dst. And I don't think skb_dst_drop
> will be appropriate before every skb_dst_copy call.
>=20
> 	Do you see any dst and mark in ip_vs_preroute_frag6?

No it's to early

> I mean, isn't nf_ct_frag6_output just passing all fragments
> without any dst and mark?=20

Yes that's why I need to copy them to the 2:nd and following frags.

> May be everything depends on __ipv6_conntrack_in to track the reassembled=
 packet?=20
> What happens if IPVS works without conntrack support?

No we don't need conntrack.
This was the tricky and "hidden" part of the patch :-)
I tried to describe it in part 0/2

The magic thing is done in other hooks
skb->mark and skb_dst_copy() is copied from the first fragment
to the re-assembled skb "reasm" (as a temp storage)
which is visible for all the following fragments

	if (!iph.fragoffs && skb_nfct_reasm(skb)) {
		struct sk_buff *reasm =3D skb_nfct_reasm(skb);
		/* Save route & fw mark to comming frags */
		reasm->mark =3D skb->mark;
		skb_dst_copy(reasm, skb);
	}

In ip_vs_preroute_frag6() the dst and fw-mark will be restord
to 2:nd and following frags.

	if (!iphdr.fragoffs)
		return NF_ACCEPT;
	/* Copy stored mark & dst from ip_vs_in / out */
	skb->mark =3D reasm->mark;
	skb_dst_copy(skb, reasm);

>=20
> 	And what should be the goal? To pass all fragments
> via IPVS SNAT/DNAT and transmitters? So, we must schedule/track
> first fragment in IPVS and all other fragments should be routed
> in the same way?=20

Yes, that is how it works.
skb_dst_copy() in PREROUTING  fix the routing into ip_vs since no
ip6tables rules can do that because they only see fragments.

We have been used this patch in our labs for a while now and it seems to wo=
rk.
NAT and tunnel is not that well tested yet since we don't use it.
It's only tested by me. Local RS seems to work I'm not sure that my
tests cover all ICMPv6 cases.=20

Packet to big, time exceeded and ping is what I have tried=20
That in combinations with/without fragments and routing headers in front.
Also a number of invalid frames have been tested.

Have a look at thc-ipv6-1.8 it can produce a lot of strange packets with so=
me help :-)
iperf -Vu can also produce a lot of IPv6 UDP fragments
(traceroute6 and ping6 also do)

> And the question is how the first fragment
> should be used by all following fragments?=20

I hope it's described above

> It is very difficult to mangle the packets if the fragments do not
> come in single skb as for IPv4. We need to use something
> like ip_defrag, is nf_ct_frag6_gather such analog?
> After working with single skb we can send it to LOCAL_OUT for
> fragmenting.

We are not allowed to do that according to RFC 2460
"Note:=20
   unlike IPv4, fragmentation in IPv6 is performed only by source nodes, no=
t by
   routers along a packet's delivery path"
>=20
> 	As for the dependencies, may be we should also select
> CONFIG_NF_DEFRAG_IPV6 for config IP_VS_IPV6?

Yes, I forgot that

Thanks
 Hans

--nextPart1376956.FWRIoGh3TM
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAk9EnXIACgkQsPw1jACzjGbR5wCfXkMVYV0Enbx/UXLdhXTeB0Ih
1VAAn1uT+AkvIRiLy0/Qq3dJ9Sqrc0gl
=1Qkc
-----END PGP SIGNATURE-----

--nextPart1376956.FWRIoGh3TM--
