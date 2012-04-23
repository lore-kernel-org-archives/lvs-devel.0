From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2 7/8] ipvs: add support for sync threads
Date: Tue, 24 Apr 2012 07:29:21 +0900
Message-ID: <20120423222921.GC580@verge.net.au>
References: <1334872199-8826-1-git-send-email-ja@ssi.bg>
 <1334872199-8826-8-git-send-email-ja@ssi.bg>
 <20120423125412.GD20296@verge.net.au>
 <alpine.LFD.2.00.1204232241060.1890@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1204232241060.1890@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Aleksey Chudov <aleksey.chudov@gmail.com>

On Mon, Apr 23, 2012 at 10:43:33PM +0300, Julian Anastasov wrote:
>=20
> 	Hello,
>=20
> On Mon, 23 Apr 2012, Simon Horman wrote:
>=20
> > > +	return ((int) cp >> (1 + ilog2(sizeof(*cp)))) & ipvs->threads_m=
ask;
> > >  }
> >=20
> > Hi Julian,
> >=20
> > My gcc running on x86_64 doesn't seem to like this cast.
> >=20
> > # gcc --version
> > gcc (Debian 4.6.3-1) 4.6.3
> > # make
> > ...
> >   CC      net/netfilter/ipvs/ip_vs_est.o
> > net/netfilter/ipvs/ip_vs_sync.c: In function =E2=80=98select_master=
_thread_id=E2=80=99:
> > net/netfilter/ipvs/ip_vs_sync.c:398:10: warning: cast from pointer =
to integer of different size [-Wpointer-to-int-cast]
>=20
> 	Ops. I'll change this '(int)' with '(long)'. You
> want new version for the whole patchset or just for this patch?

Just an update of patch 7 is fine.

