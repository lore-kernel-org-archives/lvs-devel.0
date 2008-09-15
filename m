From: Simon Horman <horms@verge.net.au>
Subject: Re: Adding SNAT support to LVS/NAT
Date: Mon, 15 Sep 2008 11:43:39 +1000
Message-ID: <20080915014337.GA10026@verge.net.au>
References: <f4845fc0809130412n41967d79l1240558492c84cb7@mail.gmail.com> <Pine.LNX.4.64.0809131100320.20936@wm7d.net> <f4845fc0809131731g7f953b21t57aa226ebdc9641e@mail.gmail.com> <Pine.LNX.4.64.0809131835001.12375@wm7d.net> <f4845fc0809140339p1d3be327j98ddcb02c4efc786@mail.gmail.com> <f4845fc0809140747u63f6ad63m43877bbbf09c4778@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f4845fc0809140747u63f6ad63m43877bbbf09c4778@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Julius Volz <juliusv@google.com>
Cc: Joseph Mack NA3T <jmack@wm7d.net>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, j.stubbs@linkthink.co.jp, Siim =?iso-8859-1?Q?P=F5der?= <siim@p6drad-teel.net>

On Sun, Sep 14, 2008 at 04:47:51PM +0200, Julius Volz wrote:
> On Sun, Sep 14, 2008 at 12:39 PM, Julius Volz <juliusv@google.com> wr=
ote:
> > On Sun, Sep 14, 2008 at 3:37 AM, Joseph Mack NA3T <jmack@wm7d.net> =
wrote:
> >> On Sun, 14 Sep 2008, Julius Volz wrote:
> >>
> >>> So maybe it would already work? ;)
> >>
> >> No. Some highly motivated people tried doing SNAT on OUTPUT in an =
attempt to
> >> do F5-SNAT and it didn't work. This lead to the write up in
> >>
> >> http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.non-modifie=
d_realservers.html#F5_snat
> >>
> >> which brings us to where we are now.
> >
> > Thanks for the info! Right, I even said myself in the previous repl=
y
> > that ip_vs_postrouting() stops further processing in the POSTROUTIN=
G
> > chain, so it never reaches netfilter NAT code.
>=20
> Actually, what if we modify or remove that function to allow further
> processing in POSTROUTING? Could SNAT work with IPVS then?
>=20
> The comment above it says that the function specifically wants to
> avoid further NAT by netfilter. But is this always a problem?

Well, it would be a problem if it gets DNATed a second time.
But perhaps we can take a slightly different approach such that
we protect against DNAT while allowing SNAT.


Perhaps it might just be easier to allow iptables to explictly match
packets that have been mangled by LVS-NAT. Perhaps by poviding
a match rule for skb->ipvs_property? Or by using Siim P=F5der's match
against connections in the LVS connection table.

http://lists.graemef.net/pipermail/lvs-users/2008-July/021081.html

--=20
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

