From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 2/3] IPVS: make friends with nf_conntrack
Date: Thu, 3 Sep 2009 21:04:13 +1000
Message-ID: <20090903110349.GA5393@verge.net.au>
References: <20090902101417.11561.45663.stgit@jazzy.zrh.corp.google.com>
 <20090902101538.11561.11911.stgit@jazzy.zrh.corp.google.com>
 <4A9E8788.1090901@trash.net>
 <b5ddba180909030322h42aa9337o4c20696b86029b71@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <b5ddba180909030322h42aa9337o4c20696b86029b71@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Hannes Eder <heder@google.com>
Cc: Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Fabien =?iso-8859-1?Q?Duch=EAne?= <mad_fab@skynet.be>, Jan Engelhardt <jengelh@medozas.de>, Jean-Luc Fortemaison <jl.fortemaison@uclouvain.be>, Julian Anastasov <ja@ssi.bg>, Julius Volz <julius.volz@gmail.com>, Laurent Grawet <laurent.grawet@uclouvain.be>, Wensong Zhang <wensong@linux-vs.org>

On Thu, Sep 03, 2009 at 12:22:53PM +0200, Hannes Eder wrote:
> On Wed, Sep 2, 2009 at 16:56, Patrick McHardy<kaber@trash.net> wrote:
> > Hannes Eder wrote:
> >> Update the nf_conntrack tuple in reply direction, as we will see
> >> traffic from the real server (RIP) to the client (CIP). =A0Once th=
is is
> >> done we can use netfilters SNAT in POSTROUTING, especially with
> >> xt_ipvs, to do source NAT, e.g.:
> >>
> >> % iptables -t nat -A POSTROUTING -m ipvs --vaddr 192.168.100.30/32=
 --vport 8080 \
> >>> -j SNAT --to-source 192.168.10.10
> >>
> >
> >> +static void
> >> +ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp=
)
> >> +{
> >> + =A0 =A0 struct nf_conn *ct =3D (struct nf_conn *)skb->nfct;
> >> +
> >> + =A0 =A0 if (ct =3D=3D NULL || ct =3D=3D &nf_conntrack_untracked =
||
> >> + =A0 =A0 =A0 =A0 nf_ct_is_confirmed(ct))
> >> + =A0 =A0 =A0 =A0 =A0 =A0 return;
> >> +
> >> + =A0 =A0 /*
> >> + =A0 =A0 =A0* The connection is not yet in the hashtable, so we u=
pdate it.
> >> + =A0 =A0 =A0* CIP->VIP will remain the same, so leave the tuple i=
n
> >> + =A0 =A0 =A0* IP_CT_DIR_ORIGINAL untouched. =A0When the reply com=
es back from the
> >> + =A0 =A0 =A0* real-server we will see RIP->DIP.
> >> + =A0 =A0 =A0*/
> >> + =A0 =A0 ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.u3 =3D cp->dadd=
r;
> >> + =A0 =A0 /*
> >> + =A0 =A0 =A0* This will also take care of UDP and other protocols=
=2E
> >> + =A0 =A0 =A0*/
> >> + =A0 =A0 ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.u.tcp.port =3D =
cp->dport;
> >> +}
> >
> > How does IPVS interact with conntrack helpers? If it does actually
> > intend to use them (which will happen automatically), it might make
> > sense to use nf_conntrack_alter_reply(), which will perform a new
> > helper lookup based on the changed tuple.
>=20
> Good point, I'll use nf_conntrack_alter_reply().  IHMO IPVS only deal=
s
> with ftp in a special way, I think something need to be done there as
> well, I'll investigate that.

Yes, I think that is correct. FTP is the only protocol helper in IPVS.

