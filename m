From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH net 3/4] net/core: move ipv6 gro function declarations to
 net/ipv6
Date: Tue, 2 Feb 2021 17:59:20 +0200
Message-ID: <20210202155920.GC3264866@unreal>
References: <20210202135544.3262383-1-leon@kernel.org>
 <20210202135544.3262383-4-leon@kernel.org>
 <CANn89iLeC8YLt2Spq4P+JA+XBf=GDjF4UT5N68-E08JdS5iPJA@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1612281564;
        bh=xQZUALESxhZKFk3yX/5mSVT37Mz913L8FFWZ44r9JLA=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=Et0G7MTAzaD8iWTsx2txahikP2xGcS3cKw/H6/iQBv89XCUxto92YKk6IKS7JpxBs
         AXVcDFFpPkR3xgRRjk122PEaqbSLE/JOCxEUuGNLEjDOf1RxS3rF4trnsdz6ZSnkc8
         YHFr36eB9OkGuoL7xhsOiWojTa7er74ESxieBTrN12p9uoWN1yyWN0BgqKt6JTTLt3
         rECOYrcE7F0o84U2V46RCiyRZ6knINthWZGU7F8wCxvzfJrkWUU8Dy7hAgp5JPz945
         6WXAIvSnCtw5wQFdKs7l49bE5tH4koOQfq5cho13FhX0HzPtmffOIFHTygYKp96c7T
         GeCaZmquQYRlg==
Content-Disposition: inline
In-Reply-To: <CANn89iLeC8YLt2Spq4P+JA+XBf=GDjF4UT5N68-E08JdS5iPJA@mail.gmail.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Eric Dumazet <edumazet@google.com>
Cc: Jakub Kicinski <kuba@kernel.org>, "David S. Miller" <davem@davemloft.net>, Pablo Neira Ayuso <pablo@netfilter.org>, coreteam@netfilter.org, Florian Westphal <fw@strlen.de>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Julian Anastasov <ja@ssi.bg>, LKML <linux-kernel@vger.kernel.org>, lvs-devel@vger.kernel.org, Matteo Croce <mcroce@redhat.com>, netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>

On Tue, Feb 02, 2021 at 03:57:07PM +0100, Eric Dumazet wrote:
> On Tue, Feb 2, 2021 at 2:56 PM Leon Romanovsky <leon@kernel.org> wrote:
> >
> > From: Leon Romanovsky <leonro@nvidia.com>
> >
> > Fir the following compilation warnings:
> >  1031 | INDIRECT_CALLABLE_SCOPE void udp_v6_early_demux(struct sk_buff *skb)
> >
> > net/ipv6/ip6_offload.c:182:41: warning: no previous prototype for ‘ipv6_gro_receive’ [-Wmissing-prototypes]
> >   182 | INDIRECT_CALLABLE_SCOPE struct sk_buff *ipv6_gro_receive(struct list_head *head,
> >       |                                         ^~~~~~~~~~~~~~~~
> > net/ipv6/ip6_offload.c:320:29: warning: no previous prototype for ‘ipv6_gro_complete’ [-Wmissing-prototypes]
> >   320 | INDIRECT_CALLABLE_SCOPE int ipv6_gro_complete(struct sk_buff *skb, int nhoff)
> >       |                             ^~~~~~~~~~~~~~~~~
> > net/ipv6/ip6_offload.c:182:41: warning: no previous prototype for ‘ipv6_gro_receive’ [-Wmissing-prototypes]
> >   182 | INDIRECT_CALLABLE_SCOPE struct sk_buff *ipv6_gro_receive(struct list_head *head,
> >       |                                         ^~~~~~~~~~~~~~~~
> > net/ipv6/ip6_offload.c:320:29: warning: no previous prototype for ‘ipv6_gro_complete’ [-Wmissing-prototypes]
> >   320 | INDIRECT_CALLABLE_SCOPE int ipv6_gro_complete(struct sk_buff *skb, int nhoff)
> >
> > Fixes: aaa5d90b395a ("net: use indirect call wrappers at GRO network layer")
> > Signed-off-by: Leon Romanovsky <leonro@nvidia.com>
> > ---
> >  include/net/ipv6.h | 3 +++
> >  net/core/dev.c     | 4 +---
> >  2 files changed, 4 insertions(+), 3 deletions(-)
> >
> > diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> > index bd1f396cc9c7..68676e6bd4b1 100644
> > --- a/include/net/ipv6.h
> > +++ b/include/net/ipv6.h
> > @@ -1265,4 +1265,7 @@ static inline void ip6_sock_set_recvpktinfo(struct sock *sk)
> >         release_sock(sk);
> >  }
> >
> > +INDIRECT_CALLABLE_DECLARE(struct sk_buff *ipv6_gro_receive(struct list_head *,
> > +                                                          struct sk_buff *));
> > +INDIRECT_CALLABLE_DECLARE(int ipv6_gro_complete(struct sk_buff *, int));
>
>
> I think we should move this to a new include file.

The ipv6_gro_* used in net/core/dev.c and net/ipv6/ip6_offload.c. This
left me with four options:
1. Use existing and already shared file - include/net/ipv6.h
2. Create new header and put it in net/, so include will be something
like that "../new_file.h".
3. Put new header in one of the folders or core/ or ipv6/.
4. Create new file in include/net just for those two lines.

I preferred option #1, which other option do you want me to redo?

>
> These declarations were static, and had to be made public only because
> of DIRECT call stuff,
> which is an implementation detail.
>
> Polluting include/net/ipv6.h seems not appropriate.

Thanks for the review.
