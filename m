From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] netfilter: ipvs: fix compiler warnings
Date: Sat, 22 Jan 2011 14:12:02 +1100
Message-ID: <20110122031202.GA9142@verge.net.au>
References: <1295604133-6869-1-git-send-email-xiaosuo@gmail.com>
 <20110122022232.GL2661@verge.net.au>
 <AANLkTimoSQbjH-iW6x36FHs6yzDgsey9RS+yFXnKOxq5@mail.gmail.com>
 <20110122031116.GA8443@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110122031116.GA8443@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Changli Gao <xiaosuo@gmail.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

On Sat, Jan 22, 2011 at 02:11:16PM +1100, Simon Horman wrote:
> On Sat, Jan 22, 2011 at 10:34:23AM +0800, Changli Gao wrote:
> > On Sat, Jan 22, 2011 at 10:22 AM, Simon Horman <horms@verge.net.au>=
 wrote:
> > > On Fri, Jan 21, 2011 at 06:02:13PM +0800, Changli Gao wrote:
> > >> Fix compiler warnings when no transport protocol load balancing =
support
> > >> is configured.
> > >>
> > >> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> > >> ---
> > >> =C2=A0net/netfilter/ipvs/ip_vs_core.c =C2=A0| =C2=A0 =C2=A04 +--=
-
> > >> =C2=A0net/netfilter/ipvs/ip_vs_ctl.c =C2=A0 | =C2=A0 =C2=A04 +++=
+
> > >> =C2=A0net/netfilter/ipvs/ip_vs_proto.c | =C2=A0 =C2=A04 ++++
> > >> =C2=A03 files changed, 9 insertions(+), 3 deletions(-)
> > >> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipv=
s/ip_vs_core.c
> > >> index f36a84f..d889f4f 100644
> > >> --- a/net/netfilter/ipvs/ip_vs_core.c
> > >> +++ b/net/netfilter/ipvs/ip_vs_core.c
> > >> @@ -1894,9 +1894,7 @@ static int __net_init __ip_vs_init(struct =
net *net)
> > >>
> > >> =C2=A0static void __net_exit __ip_vs_cleanup(struct net *net)
> > >> =C2=A0{
> > >> - =C2=A0 =C2=A0 struct netns_ipvs *ipvs =3D net_ipvs(net);
> > >> -
> > >> - =C2=A0 =C2=A0 IP_VS_DBG(10, "ipvs netns %d released\n", ipvs->=
gen);
> > >> + =C2=A0 =C2=A0 IP_VS_DBG(10, "ipvs netns %d released\n", net_ip=
vs(net)->gen);
> > >> =C2=A0}
> > >>
> > >
> > > The hunk above seems unrelated to the problem described.
> > > The rest of the changes look good. I will double check and
> > > apply them to my tree.
> > >
> >=20
> > Yes, is a separated patch needed? It is trivial. Thanks.
>=20
> Yes, please send a separate patch.

To clarify, I have applied the other hunks and included
them in a pull request that I sent to Patrick a few moments ago.
