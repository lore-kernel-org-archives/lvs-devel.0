From: yangxingwu <xingwu.yang@gmail.com>
Subject: Re: [PATCH nf-next v5] netfilter: ipvs: Fix reuse connection if RS
 weight is 0
Date: Tue, 2 Nov 2021 10:10:43 +0800
Message-ID: <CA+7U5JtY-K4P2L9V8N8TeA9cUJDd67YRLR-PKWaHEL9WnybEfw@mail.gmail.com>
References: <20211101020416.31402-1-xingwu.yang@gmail.com> <ae67eb7b-a25f-57d3-195f-cdbd9247ef5b@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=FCErorh1OD8co7JK7IKyoKFC4gg1Jidiv0Vg9N7U25s=;
        b=PbBG86CwC/c6+MDLy+G/4bORNzn0WtIUNX/PwsuYQiBSM3XhHeOaOPiQAANC3LrLwM
         PgbX6hOGwVpBqpEQkaFgCgYc3TTcEfNhEoR76tAqWdefuRog9/Kl1We0iHog9h3tkNaR
         yUefUeSpn5W1Jhjeed+ykRU6wD5fdYsXRYSrNgGqNoU4PC+K4RyrBh+Ydji1P+qQzDl7
         q6UyRAVj74zzCfojG3wjP1CcRYkJWcT/e4N/y4fo8p5q/FrSCe5kT0VEqQXKyq/NTFO4
         lyK5IyglD7TdYbB8b2mBO5XpbuaJy6LCOdUcDEmiSst3fSaF+5dyEAfoK9esGtsxU3ZF
         mLLQ==
In-Reply-To: <ae67eb7b-a25f-57d3-195f-cdbd9247ef5b@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Chuanqi Liu <legend050709@qq.com>

Julian,

thanks for your help

A big problem has been fixed :)

On Tue, Nov 2, 2021 at 2:21 AM Julian Anastasov <ja@ssi.bg> wrote:
>
>
>         Hello,
>
> On Mon, 1 Nov 2021, yangxingwu wrote:
>
> > We are changing expire_nodest_conn to work even for reused connections when
> > conn_reuse_mode=0, just as what was done with commit dc7b3eb900aa ("ipvs:
> > Fix reuse connection if real server is dead").
> >
> > For controlled and persistent connections, the new connection will get the
> > needed real server depending on the rules in ip_vs_check_template().
> >
> > Fixes: d752c3645717 ("ipvs: allow rescheduling of new connections when port reuse is detected")
> > Co-developed-by: Chuanqi Liu <legend050709@qq.com>
> > Signed-off-by: Chuanqi Liu <legend050709@qq.com>
> > Signed-off-by: yangxingwu <xingwu.yang@gmail.com>
>
>         Looks good to me, thanks!
>
> Acked-by: Julian Anastasov <ja@ssi.bg>
>
> > ---
> >  Documentation/networking/ipvs-sysctl.rst | 3 +--
> >  net/netfilter/ipvs/ip_vs_core.c          | 8 ++++----
> >  2 files changed, 5 insertions(+), 6 deletions(-)
> >
> > diff --git a/Documentation/networking/ipvs-sysctl.rst b/Documentation/networking/ipvs-sysctl.rst
> > index 2afccc63856e..1cfbf1add2fc 100644
> > --- a/Documentation/networking/ipvs-sysctl.rst
> > +++ b/Documentation/networking/ipvs-sysctl.rst
> > @@ -37,8 +37,7 @@ conn_reuse_mode - INTEGER
> >
> >       0: disable any special handling on port reuse. The new
> >       connection will be delivered to the same real server that was
> > -     servicing the previous connection. This will effectively
> > -     disable expire_nodest_conn.
> > +     servicing the previous connection.
> >
> >       bit 1: enable rescheduling of new connections when it is safe.
> >       That is, whenever expire_nodest_conn and for TCP sockets, when
> > diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> > index 128690c512df..f9d65d2c8da8 100644
> > --- a/net/netfilter/ipvs/ip_vs_core.c
> > +++ b/net/netfilter/ipvs/ip_vs_core.c
> > @@ -1964,7 +1964,6 @@ ip_vs_in(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int
> >       struct ip_vs_proto_data *pd;
> >       struct ip_vs_conn *cp;
> >       int ret, pkts;
> > -     int conn_reuse_mode;
> >       struct sock *sk;
> >
> >       /* Already marked as IPVS request or reply? */
> > @@ -2041,15 +2040,16 @@ ip_vs_in(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int
> >       cp = INDIRECT_CALL_1(pp->conn_in_get, ip_vs_conn_in_get_proto,
> >                            ipvs, af, skb, &iph);
> >
> > -     conn_reuse_mode = sysctl_conn_reuse_mode(ipvs);
> > -     if (conn_reuse_mode && !iph.fragoffs && is_new_conn(skb, &iph) && cp) {
> > +     if (!iph.fragoffs && is_new_conn(skb, &iph) && cp) {
> >               bool old_ct = false, resched = false;
> > +             int conn_reuse_mode = sysctl_conn_reuse_mode(ipvs);
> >
> >               if (unlikely(sysctl_expire_nodest_conn(ipvs)) && cp->dest &&
> >                   unlikely(!atomic_read(&cp->dest->weight))) {
> >                       resched = true;
> >                       old_ct = ip_vs_conn_uses_old_conntrack(cp, skb);
> > -             } else if (is_new_conn_expected(cp, conn_reuse_mode)) {
> > +             } else if (conn_reuse_mode &&
> > +                        is_new_conn_expected(cp, conn_reuse_mode)) {
> >                       old_ct = ip_vs_conn_uses_old_conntrack(cp, skb);
> >                       if (!atomic_read(&cp->n_control)) {
> >                               resched = true;
> > --
> > 2.30.2
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
