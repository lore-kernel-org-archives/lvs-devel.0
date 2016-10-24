From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] netfilter: ip_vs_sync: fix bogus maybe-uninitialized warning
Date: Mon, 24 Oct 2016 22:21:59 +0200
Message-ID: <12460209.DFK3VxnryE@wuerfel>
References: <20161024153454.2766113-1-arnd@arndb.de> <alpine.LFD.2.11.1610242226310.2276@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1610242226310.2276@ja.home.ssi.bg>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, Quentin Armitage <quentin@armitage.org.uk>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Monday, October 24, 2016 10:47:54 PM CEST Julian Anastasov wrote:
> > diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> > index 1b07578bedf3..9350530c16c1 100644
> > --- a/net/netfilter/ipvs/ip_vs_sync.c
> > +++ b/net/netfilter/ipvs/ip_vs_sync.c
> > @@ -283,6 +283,7 @@ struct ip_vs_sync_buff {
> >   */
> >  static void ntoh_seq(struct ip_vs_seq *no, struct ip_vs_seq *ho)
> >  {
> > +     memset(ho, 0, sizeof(*ho));
> >       ho->init_seq       = get_unaligned_be32(&no->init_seq);
> >       ho->delta          = get_unaligned_be32(&no->delta);
> >       ho->previous_delta = get_unaligned_be32(&no->previous_delta);
> 
>         So, now there is a double write here?

Correct. I would hope that a sane version of gcc would just not
perform the first write. What happens instead is that the version
that produces the warning here moves the initialization to the
top of the calling function.

>         What about such constructs?:
> 
>         *ho = (struct ip_vs_seq) {
>                 .init_seq       = get_unaligned_be32(&no->init_seq),
>                 ...
>         };
> 
>         Any difference in the compiled code or warnings?

Yes, it's one of many things I tried. What happens here is that
the warning remains as long as all fields are initialized together,
e.g. these two produces the same warning:

a)
    ho->init_seq       = get_unaligned_be32(&no->init_seq);
    ho->delta          = get_unaligned_be32(&no->delta);
    ho->previous_delta = get_unaligned_be32(&no->previous_delta);

b)
   *ho = (struct ip_vs_seq) {
       .init_seq       = get_unaligned_be32(&no->init_seq);
       .delta          = get_unaligned_be32(&no->delta);
       .previous_delta = get_unaligned_be32(&no->previous_delta);
   };

but this one does not:

c)
   *ho = (struct ip_vs_seq) {
       .delta          = get_unaligned_be32(&no->delta);
       .previous_delta = get_unaligned_be32(&no->previous_delta);
   };
   ho->init_seq       = get_unaligned_be32(&no->init_seq);

I have absolutely no idea what is going on inside of gcc here.

	Arnd
