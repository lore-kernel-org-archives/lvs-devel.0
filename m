From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] netfilter: ip_vs_sync: fix bogus maybe-uninitialized
 warning
Date: Tue, 25 Oct 2016 16:15:16 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB020A210@AcuExch.aculab.com>
References: <20161024153454.2766113-1-arnd@arndb.de>
 <alpine.LFD.2.11.1610242226310.2276@ja.home.ssi.bg>
 <12460209.DFK3VxnryE@wuerfel>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <12460209.DFK3VxnryE@wuerfel>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: 'Arnd Bergmann' <arnd@arndb.de>, Julian Anastasov <ja@ssi.bg>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, Quentin Armitage <quentin@armitage.org.uk>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "coreteam@netfilter.org" <coreteam@netfilter.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

From: Arnd Bergmann
> Sent: 24 October 2016 21:22
> On Monday, October 24, 2016 10:47:54 PM CEST Julian Anastasov wrote:
> > > diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> > > index 1b07578bedf3..9350530c16c1 100644
> > > --- a/net/netfilter/ipvs/ip_vs_sync.c
> > > +++ b/net/netfilter/ipvs/ip_vs_sync.c
> > > @@ -283,6 +283,7 @@ struct ip_vs_sync_buff {
> > >   */
> > >  static void ntoh_seq(struct ip_vs_seq *no, struct ip_vs_seq *ho)
> > >  {
> > > +     memset(ho, 0, sizeof(*ho));
> > >       ho->init_seq       = get_unaligned_be32(&no->init_seq);
> > >       ho->delta          = get_unaligned_be32(&no->delta);
> > >       ho->previous_delta = get_unaligned_be32(&no->previous_delta);
> >
> >         So, now there is a double write here?
> 
> Correct. I would hope that a sane version of gcc would just not
> perform the first write. What happens instead is that the version
> that produces the warning here moves the initialization to the
> top of the calling function.

Maybe doing the 3 get_unaligned_be32() before the memset will stop
the double-writes.
The problem is that the compiler doesn't know that the two structures
don't alias each other.

	David

