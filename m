From: yangxingwu <xingwu.yang@gmail.com>
Subject: Re: [PATCH v2] ipvs: Fix reuse connection if RS weight is 0
Date: Sat, 30 Oct 2021 10:42:27 +0800
Message-ID: <CA+7U5Juzh+2+3Bnxc9jVPWT71=h6pwfVoWAtam7Cuxasr28C4Q@mail.gmail.com>
References: <20211029032604.5432-1-xingwu.yang@gmail.com> <8bdab9e0-3bd4-c37-94e9-ca1f74883356@ssi.bg>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qMW69CHxQGpNnhAkNKPRDDtsEZGfHtFrwwNPa8aIYaY=;
        b=k/hTgn3lRJV/6kfSO/s5arnLWVXhmg6ujrGaBU3d8kb/iy8MKUHJjvbuljDJLaeboS
         Ax2ZJCREMw6F3o3Td9o2XVPPV20suzFi7wS9efLeNiWnyo/SiKV6nvu147bvucQJqiXn
         DdQVMHa9A6aXPbk8KdTeuImsXPCSb1+l1HA4sfnD5C8k+x041y8ZGqJ2rER5EDNwjtwB
         VeJMjlebHqbOVdrY4XMwjzWCVHM1Qb5rM2NczgNOTyLntSoRWC79CHc0od7A6tZ7OuAO
         MA80EKRdAG24mUnYTESjcyclT1gw1nEDL4wqPDJkQVQf7vAy9aZQrNTMB7i3QKoGw9Hd
         sIJg==
In-Reply-To: <8bdab9e0-3bd4-c37-94e9-ca1f74883356@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, legend050709@qq.com

thanks Julian

I will do that

On Sat, Oct 30, 2021 at 3:25 AM Julian Anastasov <ja@ssi.bg> wrote:
>
>
>         Hello,
>
> On Fri, 29 Oct 2021, yangxingwu wrote:
>
> > Since commit dc7b3eb900aa ("ipvs: Fix reuse connection if real server is
> > dead"), new connections to dead servers are redistributed immediately to
> > new servers.
> >
> > Then commit d752c3645717 ("ipvs: allow rescheduling of new connections when
> > port reuse is detected") disable expire_nodest_conn if conn_reuse_mode is
> > 0. And new connection may be distributed to a real server with weight 0.
>
>         Can you better explain in commit message that we are changing
> expire_nodest_conn to work even for reused connections when
> conn_reuse_mode=0 but without affecting the controlled/persistent
> connections during the grace period while server is with weight=0.
>
>         Even if you target -next trees adding commit d752c3645717
> as Fixes line would be a good idea. Make sure the tree is specified
> after the v3 tag.
>
> > Co-developed-by: Chuanqi Liu <legend050709@qq.com>
> > Signed-off-by: Chuanqi Liu <legend050709@qq.com>
> > Signed-off-by: yangxingwu <xingwu.yang@gmail.com>
> > ---
> >  Documentation/networking/ipvs-sysctl.rst | 3 +--
> >  net/netfilter/ipvs/ip_vs_core.c          | 7 ++++---
> >  2 files changed, 5 insertions(+), 5 deletions(-)
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
> > index 128690c512df..374f4b0b7080 100644
> > --- a/net/netfilter/ipvs/ip_vs_core.c
> > +++ b/net/netfilter/ipvs/ip_vs_core.c
> > @@ -2042,14 +2042,15 @@ ip_vs_in(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int
> >                            ipvs, af, skb, &iph);
> >
> >       conn_reuse_mode = sysctl_conn_reuse_mode(ipvs);
> > -     if (conn_reuse_mode && !iph.fragoffs && is_new_conn(skb, &iph) && cp) {
> > +     if (!iph.fragoffs && is_new_conn(skb, &iph) && cp) {
>
>         It is even better to move the !cp->control check above:
>
>         if (!iph.fragoffs && is_new_conn(skb, &iph) && cp && !cp->control) {
>
>         Then is not needed in is_new_conn_expected() anymore.
>
> >               bool old_ct = false, resched = false;
>
>         And now you can move conn_reuse_mode here:
>
>                 int conn_reuse_mode = sysctl_conn_reuse_mode(ipvs);
>
> >               if (unlikely(sysctl_expire_nodest_conn(ipvs)) && cp->dest &&
> > -                 unlikely(!atomic_read(&cp->dest->weight))) {
> > +                 unlikely(!atomic_read(&cp->dest->weight)) && !cp->control) {
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
