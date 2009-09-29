From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2 0/4] IPVS full NAT support + netfilter 'ipvs' match
 support
Date: Wed, 30 Sep 2009 09:18:48 +1000
Message-ID: <20090929231845.GA7255@verge.net.au>
References: <20090929123501.13798.84004.stgit@jazzy.zrh.corp.google.com>
 <20090929145156.GB19797@verge.net.au>
 <b5ddba180909290807j4d1d1d2dl48af9453542612ff@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <b5ddba180909290807j4d1d1d2dl48af9453542612ff@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Hannes Eder <heder@google.com>
Cc: lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julius Volz <julius.volz@gmail.com>, lvs-users@linuxvirtualserver.org, Laurent Grawet <laurent.grawet@uclouvain.be>, Jean-Luc Fortemaison <jl.fortemaison@uclouvain.be>, linux-kernel@vger.kernel.org, Jan Engelhardt <jengelh@medozas.de>, Julian Anastasov <ja@ssi.bg>, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Fabien =?utf-8?Q?Duch=C3=AAne?= <mad_fab@skynet.be>, Joseph Mack NA3T <jmack@wm7d.net>, Patrick McHardy <kaber@trash.net>

On Tue, Sep 29, 2009 at 05:07:24PM +0200, Hannes Eder wrote:
> On Tue, Sep 29, 2009 at 16:51, Simon Horman <horms@verge.net.au> wrot=
e:
> > On Tue, Sep 29, 2009 at 02:35:15PM +0200, Hannes Eder wrote:
> >> The following series implements full NAT support for IPVS. =C2=A0T=
he
> >> approach is via a minimal change to IPVS (make friends with
> >> nf_conntrack) and adding a netfilter matcher, kernel- and user-spa=
ce
> >> part, i.e. xt_ipvs and libxt_ipvs.
> >
> > Its a bit late in the day for me to review the code, but I have a f=
ew
> > quick comments.
> >
> >>
> >> Example usage:
> >>
> >> % ipvsadm -A -t 192.168.100.30:80 -s rr
> >> % ipvsadm -a -t 192.168.100.30:80 -r 192.168.10.20:80 -m
> >> # ...
> >>
> >> # Source NAT for VIP 192.168.100.30:80
> >> % iptables -t nat -A POSTROUTING -m ipvs --vaddr 192.168.100.30/32=
 \
> >> > --vport 80 -j SNAT --to-source 192.168.10.10
> >>
> >> or SNAT-ing only a specific real server:
> >>
> >> % iptables -t nat -A POSTROUTING --dst 192.168.11.20 \
> >> > -m ipvs --vaddr 192.168.100.30/32 -j SNAT --to-source 192.168.10=
=2E10
> >
> > If the iptables rule is not in place does LVS just use
> > its old NAT behaviour?
>=20
> Yes, without iptables rules LVS NAT does DNAT.

Great.

> >> First of all, thanks for all the feedback. =C2=A0This is the chang=
elog for v2:
> >>
> >> - Make ip_vs_ftp work again. =C2=A0Setup nf_conntrack expectations=
 for
> >> =C2=A0 related data connections (based on Julian's patch see
> >> =C2=A0 http://www.ssi.bg/~ja/nfct/) and let nf_conntrack/nf_nat do=
 the
> >> =C2=A0 packet mangling and the TCP sequence adjusting.
> >>
> >> =C2=A0 This change rises the question how to deal with ip_vs_sync?=
 =C2=A0Does it
> >> =C2=A0 work together with conntrackd? =C2=A0Wild idea: what about =
getting rid of
> >> =C2=A0 ip_vs_sync and piggy packing all on nf_conntrack and use co=
nntrackd?
> >>
> >> =C2=A0 Any comments on this?
> >
> > =C2=A0 =C2=A0That sounds like a reasonable suggestion.
> >
> > =C2=A0 =C2=A0I think that ip_vs_sync came along before conntrackd
> > =C2=A0 =C2=A0and no one has given much thought to merging the funct=
ionality.
>=20
> Okay, I'll dig further in this direction.

Assuming the technical side is clean, I suspect the major problem will =
be
how to migrate users away from ip_vs_sync.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
