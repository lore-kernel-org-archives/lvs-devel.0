From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch] ipvs: Use atomic operations atomicly
Date: Tue, 1 Sep 2009 00:49:09 +1000
Message-ID: <20090831144909.GB2271@verge.net.au>
References: <20090828023722.GA12136@verge.net.au>
 <4A9BC082.3090804@trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A9BC082.3090804@trash.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Patrick McHardy <kaber@trash.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, =?utf-8?B?7ZmN7Iug?= shin hong <hongshin@gmail.com>, David Miller <davem@davemloft.net>

On Mon, Aug 31, 2009 at 02:22:26PM +0200, Patrick McHardy wrote:
> Simon Horman wrote:
> > A pointed out by Shin Hong, IPVS doesn't always use atomic operatio=
ns
> > in an atomic manner. While this seems unlikely to be manifest in
> > strange behaviour, it seems appropriate to clean this up.
> >=20
> > Cc: =ED=99=8D=EC=8B=A0 shin hong <hongshin@gmail.com>
> > Signed-off-by: Simon Horman <horms@verge.net.au>
>=20
> Applied, thanks.
>=20
> >  	if (af =3D=3D AF_INET &&
> >  	    (ip_vs_sync_state & IP_VS_STATE_MASTER) &&
> >  	    (((cp->protocol !=3D IPPROTO_TCP ||
> >  	       cp->state =3D=3D IP_VS_TCP_S_ESTABLISHED) &&
> > -	      (atomic_read(&cp->in_pkts) % sysctl_ip_vs_sync_threshold[1]
> > +	      (pkts % sysctl_ip_vs_sync_threshold[1]
>=20
> It seems that proc_do_sync_threshold() should check whether this valu=
e
> is zero. The current checks also look racy since incorrect values are
> first updated, then overwritten again.

Thanks, I'll look into that.
