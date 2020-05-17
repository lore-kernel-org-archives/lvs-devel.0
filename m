From: Andrew Kim <kim.andrewsy@gmail.com>
Subject: Re: [PATCH] netfilter/ipvs: expire no destination UDP connections
 when expire_nodest_conn=1
Date: Sun, 17 May 2020 13:30:25 -0400
Message-ID: <CABc050HM=yMbqxDqKX1CLt4qKwXQsf_c6VM=9nkVKWz1GBKCQA@mail.gmail.com>
References: <20200515013556.5582-1-kim.andrewsy@gmail.com> <alpine.LFD.2.21.2005152044380.3860@ja.home.ssi.bg>
 <CABc050G5HRaTNp1r0P7HahAUu+RA_Gk2XZBbjDWQsQ40O4VGyw@mail.gmail.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0OZFa7jftTdxWcOSLEpkn4gNpXoELgMCtZ7/ZZaFvoc=;
        b=bVFin6RXaSBqs/HWL6nZvR81KfYNuhyVWJLZyNS84/MnadktkEJcboxJxCvgXw+VE1
         FQe9jEl3xSacnE8AKPGtI+9dS3AMwn1APPFZDevOK7raaxbPaQeJLPo+GZz9tsH5DoBZ
         30ZNkXzHYor4VYEvi5iYT1vvspznozYtX76pSh+541dvBxXY+L41TDX3J9m0cse9U1ru
         gaYcs09gf/paEjDfrGL38sv9CSY+Oxda6JzD1EqV4hradjEvhe0mOfJ2QBJjZlOQFNHd
         tetYucXzh9C78+IzXrdWYA4T4CycFCg8/0rA7yBIm7uj6mazgIHD7IVwyqfQ+f161+OX
         Nwhg==
In-Reply-To: <CABc050G5HRaTNp1r0P7HahAUu+RA_Gk2XZBbjDWQsQ40O4VGyw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, "open list:IPVS" <netdev@vger.kernel.org>, "open list:IPVS" <lvs-devel@vger.kernel.org>, "open list:NETFILTER" <netfilter-devel@vger.kernel.org>, "open list:NETFILTER" <coreteam@netfilter.org>, open list <linux-kernel@vger.kernel.org>

I sent a new patch diff based on my ask above. Please take a look :)

Thanks,

Andrew Sy Kim

On Sun, May 17, 2020 at 1:27 PM Andrew Kim <kim.andrewsy@gmail.com> wrote:
>
> Hi Julian,
>
> Thanks for getting back to me, that makes sense.
>
> Would you be opposed to trying to expire all UDP connections matching
> a deleted destination only if expire_nodest_conn=1?
> Even today with `expire_nodest_conn=1`, many packets could be dropped
> if there are many requests from a single client
> trying to reuse client ports matching a deleted destination. Setting
> `expire_nodest_conn=1` and reducing the UDP timeout
> helps but deleting all connections when the destination is deleted
> seems more efficient.
>
> Looking forward to hearing your thoughts,
>
> Andrew Sy Kim
>
>
> On Fri, May 15, 2020 at 2:07 PM Julian Anastasov <ja@ssi.bg> wrote:
> >
> >
> >         Hello,
> >
> > On Thu, 14 May 2020, Andrew Sy Kim wrote:
> >
> > > When expire_nodest_conn=1 and an IPVS destination is deleted, IPVS
> > > doesn't expire connections with the IP_VS_CONN_F_ONE_PACKET flag set (any
> > > UDP connection). If there are many UDP packets to a virtual server from a
> > > single client and a destination is deleted, many packets are silently
> > > dropped whenever an existing connection entry with the same source port
> > > exists. This patch ensures IPVS also expires UDP connections when a
> > > packet matches an existing connection with no destinations.
> > >
> > > Signed-off-by: Andrew Sy Kim <kim.andrewsy@gmail.com>
> > > ---
> > >  net/netfilter/ipvs/ip_vs_core.c | 3 +--
> > >  1 file changed, 1 insertion(+), 2 deletions(-)
> > >
> > > diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> > > index aa6a603a2425..f0535586fe75 100644
> > > --- a/net/netfilter/ipvs/ip_vs_core.c
> > > +++ b/net/netfilter/ipvs/ip_vs_core.c
> > > @@ -2116,8 +2116,7 @@ ip_vs_in(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int
> > >               else
> > >                       ip_vs_conn_put(cp);
> >
> >         Above ip_vs_conn_put() should free the ONE_PACKET
> > connections because:
> >
> > - such connections never start timer, they are designed
> > to exist just to schedule the packet, then they are released.
> > - noone takes extra references
> >
> >         So, ip_vs_conn_put() simply calls ip_vs_conn_expire()
> > where connections should be released immediately. As result,
> > we can not access cp after this point here. That is why we work
> > just with 'flags' below...
> >
> >         Note that not every UDP connection has ONE_PACKET
> > flag, it is present if you configure it for the service.
> > Do you have -o/--ops flag? If not, the UDP connection
> > should expire before the next jiffie. This is the theory,
> > in practice, you may observe some problem...
> >
> > > -             if (sysctl_expire_nodest_conn(ipvs) &&
> > > -                 !(flags & IP_VS_CONN_F_ONE_PACKET)) {
> > > +             if (sysctl_expire_nodest_conn(ipvs)) {
> > >                       /* try to expire the connection immediately */
> > >                       ip_vs_conn_expire_now(cp);
> > >               }
> >
> >         You can also look at the discussion which resulted in
> > the last patch for this place:
> >
> > http://archive.linuxvirtualserver.org/html/lvs-devel/2018-07/msg00014.html
> >
> > Regards
> >
> > --
> > Julian Anastasov <ja@ssi.bg>
