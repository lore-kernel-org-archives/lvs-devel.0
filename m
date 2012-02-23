From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [PATCH 1/2] IPVS Bug IPv6 extension header handling faulty.
Date: Thu, 23 Feb 2012 10:46:07 +0100
Message-ID: <201202231046.12790.hans@schillstrom.com>
References: <1329223689-19792-1-git-send-email-hans.schillstrom@ericsson.com> <201202230834.24254.hans@schillstrom.com> <alpine.LFD.2.00.1202231012260.1481@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart5914164.vRMuHlBMZ8";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1202231012260.1481@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, horms@verge.net.au, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, kaber@trash.net, pablo@netfilter.org

--nextPart5914164.vRMuHlBMZ8
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Thursday, February 23, 2012 10:03:52 Julian Anastasov wrote:
>=20
> 	Hello,
>=20
> On Thu, 23 Feb 2012, Hans Schillstrom wrote:
>=20
> > > 	This is not going to work. You are trying to track
> > > any locally delivered fragments. If cp is NULL it will crash.
> > > There is no need to add check for !iph.fragoffs because
> > > for iph.fragoffs !=3D 0 we find cp with data from reasm,
> > > I mean with ip_vs_skb_hdr_ptr.
> > >=20
> > 	cp =3D pp->conn_in_get(af, skb, &iph, 0);
> > 	if (unlikely(!cp) && !iph.fragoffs) {
>=20
> 	OK, then let's just keep the !cp check and
> later if cp is NULL just to NF_ACCEPT packets with
> iph.fragoffs !=3D 0, the check should be before calling
> conn_schedule.

Another solution which might be more clear is to make
conn_schedule() fragment aware then the "&& !iph.fragoffs"
check can be removed.

>=20
> 	In the case after calling ip_vs_lookup_real_service
> is it correct to reject non-first fragment with
> ICMPV6_PORT_UNREACH, is that allowed? May be we should
> avoid sending ICMP errors to non-first fragment, what
> is the right thing to do?

 PACKET_TO_BIG needs to be sent at least

>=20
> > No it is working pretty well, because conn_in_get() is fragment aware.
> > if cp is null it's a new connection and in that case only the first fra=
g will do
> > a schedule.
> > For the following fragments reasm will be used by conn_in_get()
> > so it should normaly return a valid "cp".
>=20
> 	I worry that cp can be expired by force at that
> time, so lets add the above check before scheduling.

making conn_schedule() fragment aware will solve it.

>=20
> > > 	But IPVS is working in LOCAL_IN, even fragments will
> > > come with dst because they will be delivered locally after
> > > input routing.=20
> >=20
> > Well in the case when you have the VIP at the loopback that is true.
> > If you have rules based on fw mark that force packets to IPVS,
> > you will miss all fragments, i.e. the will go to the FORWARD chain
> >=20
> > So that is why skb_dst_copy() is needed.
>=20
> 	You mean, only the first fragment has correct
> mark, the following fragments can not be marked correctly
> because we can not match the ports. And CONNMARK can not help
> us because it depends on conntrack support?

Yes that's right
if you enable conntrack there is an ugly way to solve it.

>=20
> > > So, there is no need to assign dst. In
> > > PREROUTING there will be dst for loopback traffic. The
> > > other traffic will get input route before reaching IPVS.
> > > And it is dangerous to replace dst for the reason that
> > > ip_vs_preroute_frag6 does not know if reasm was tracked
> > > by IPVS, it can be just some netfilter packet.=20
> >=20
> > That's a side effect.=20
> > But I'm working on a solution for ip6tables to keep track on the fragme=
nts
> > most people isn't aware of that you must take care of fragemnts your se=
lf=20
> > in your ip6tables rule-set....
>=20
> 	skb_dst_copy before PREROUTING is wrong even if
> we do it for IPVS traffic, ip6_rcv_finish is going to
> call dst_input. And all transmitters check the skb dst
> to decide how to route the packet, so we have to leave
> this job to transmitters, even for the fragments.

I'll do some more tests with only skb->mark copied.
=46or some reason "ipvs" fragments went into the FORWARD chain=20
instead of INPUT i.e. if there is an input route ip6_rcv_finish()=20
doesn't try to route it.

	if (skb_dst(skb) =3D=3D NULL)
		ip6_route_input(skb);

>=20
> > > May be it is a good idea to set reasm->ipvs_property at
> > > some place, so that we know the packets are tracked
> > > by IPVS. Then we can restrict ip_vs_preroute_frag6 to
> > > work only for IPVS traffic.
> >=20
> > Good idea, thanks !!!
> > I'll will do that
>=20
> 	Yes, it seems it will be needed to copy mark,
> so that all IPVS fragments are forced to have same mark.
>=20
> > > 	Hm, I have to check what happens if we decide to
> > > mangle payload. Also, note that now ip_vs_nat_xmit_v6
> > > should try to NAT ports only for first fragment, is that
> > > handled?=20
> > Yes in xnat_handler(..)
> >=20
> > #ifdef CONFIG_IP_VS_IPV6
> > 	if (cp->af =3D=3D AF_INET6 && iph->fragoffs)
> > 		return 1;
> > #endif
>=20
> 	Yes, there must be checks for fragoffs at some
> places. May be it is a good idea to rename ip_vs_skb_hdr_ptr
> to ip_vs_first_skb_hdr_ptr and to use it only at places
> that need data from first fragment. Places that work
> with current fragment will continue to use skb_header_pointer.
> By this way we will know correctly which skb is accessed.
> May be that is what you do but at least lets have a proper
> func name.

OK, I can rename it

>=20
> > BTW, I have not test ESP & AH but on the other hand the are not subject=
s for fragmentation.
> > The sending of ICMPV6_PKT_TOOBIG seems to be generic so...
>=20
> 	ok
>=20

Regards
Hans=20

--nextPart5914164.vRMuHlBMZ8
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAk9GCuQACgkQsPw1jACzjGZHFwCeJYuzr/wEXeN2Z8oLiGzXDa/q
+dwAoIG2zjsIWNcATLLELfRWyp50Cv7f
=G+6g
-----END PGP SIGNATURE-----

--nextPart5914164.vRMuHlBMZ8--
