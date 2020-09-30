From: yue longguang <yuelongguang@gmail.com>
Subject: Re: [PATCH v5] ipvs: adjust the debug info in function set_tcp_state
Date: Wed, 30 Sep 2020 13:39:04 +0800
Message-ID: <CAPaK2r_haEH1x2HQVBNqrHe-pRCA-2V-=Lvu1nmMOOW7ZeUqvQ@mail.gmail.com>
References: <alpine.LFD.2.23.451.2009271625160.35554@ja.home.ssi.bg>
 <20200928024938.97121-1-bigclouds@163.com> <alpine.LFD.2.23.451.2009300803110.6056@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=r6/0Ch+k5Ys1E3IXfQI20t3y10+qXJytvRGG7bTZJQo=;
        b=WQhC5GPzOi63cEdwhuuRS2V/6t6FhbwGZD+icnCQzTX5JiIIeS2NGQA1sY2jYNAYJh
         6yt5FygqqfQ9MCaaZ7YDJaNskKt/1DI2Soiau+RjF+53iQCdMk0FkvfdKCPcvPnRPoyh
         ET/PKwPd+kKfAYhF9mUKRS1df0IlHseezAhielfA21q0doB6useN46c6+f8yqpWApWIo
         v2hBAoHniHySz0W/2OrW6aFY7+jArVx5CWHrniVcc52LmTOBoJr3LF6OAF5HX2tiyar2
         oTb8XD4vFGDILlPb99DYLKXInkWdUkplvqAR3FLNDclxMc0V80FZgUdVKXGZqWhTpZKz
         F7Yg==
In-Reply-To: <alpine.LFD.2.23.451.2009300803110.6056@ja.home.ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: "longguang.yue" <bigclouds@163.com>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, "open list:IPVS" <netdev@vger.kernel.org>, "open list:IPVS" <lvs-devel@vger.kernel.org>, "open list:NETFILTER" <netfilter-devel@vger.kernel.org>, "open list:NETFILTER" <coreteam@netfilter.org>, open list <linux-kernel@vger.kernel.org>

It's  done.


On Wed, Sep 30, 2020 at 1:08 PM Julian Anastasov <ja@ssi.bg> wrote:
>
>
>         Hello,
>
> On Mon, 28 Sep 2020, longguang.yue wrote:
>
> > Outputting client,virtual,dst addresses info when tcp state changes,
> > which makes the connection debug more clear
> >
> > Signed-off-by: longguang.yue <bigclouds@163.com>
>
>         OK, v5 can be used instead of fixing v4.
>
> Acked-by: Julian Anastasov <ja@ssi.bg>
>
> > ---
>     Changelogs:
>       v5: fix indentation
>       v4: fix checkpatch
>       v3: fix checkpatch
>       v2: IP_VS_DBG_BUF outputs src,virtual,dst of ip_vs_conn
>       v1: fix the inverse of src and dst address
>
>         longguang.yue, at this place after --- you can add info
> for changes between versions, eg:
> v5: fix indentation
>
>         Use this for other patches, so that we know what is
> changed between versions.
>
> >  net/netfilter/ipvs/ip_vs_proto_tcp.c | 10 ++++++----
> >  1 file changed, 6 insertions(+), 4 deletions(-)
> >
> > diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> > index dc2e7da2742a..7da51390cea6 100644
> > --- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
> > +++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> > @@ -539,8 +539,8 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
> >       if (new_state != cp->state) {
> >               struct ip_vs_dest *dest = cp->dest;
> >
> > -             IP_VS_DBG_BUF(8, "%s %s [%c%c%c%c] %s:%d->"
> > -                           "%s:%d state: %s->%s conn->refcnt:%d\n",
> > +             IP_VS_DBG_BUF(8, "%s %s [%c%c%c%c] c:%s:%d v:%s:%d "
> > +                           "d:%s:%d state: %s->%s conn->refcnt:%d\n",
> >                             pd->pp->name,
> >                             ((state_off == TCP_DIR_OUTPUT) ?
> >                              "output " : "input "),
> > @@ -548,10 +548,12 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
> >                             th->fin ? 'F' : '.',
> >                             th->ack ? 'A' : '.',
> >                             th->rst ? 'R' : '.',
> > -                           IP_VS_DBG_ADDR(cp->daf, &cp->daddr),
> > -                           ntohs(cp->dport),
> >                             IP_VS_DBG_ADDR(cp->af, &cp->caddr),
> >                             ntohs(cp->cport),
> > +                           IP_VS_DBG_ADDR(cp->af, &cp->vaddr),
> > +                           ntohs(cp->vport),
> > +                           IP_VS_DBG_ADDR(cp->daf, &cp->daddr),
> > +                           ntohs(cp->dport),
> >                             tcp_state_name(cp->state),
> >                             tcp_state_name(new_state),
> >                             refcount_read(&cp->refcnt));
> > --
> > 2.20.1 (Apple Git-117)
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
>
