From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [RFC PATCH 5/9] ipvs network name space aware
Date: Thu, 21 Oct 2010 13:49:25 +0200
Message-ID: <201010211349.25921.hans.schillstrom@ericsson.com>
References: <201010081317.04167.hans.schillstrom@ericsson.com> <20101021111644.GA25555@verge.net.au> <1287660414.6871.85.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287660414.6871.85.camel@edumazet-laptop>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "ja@ssi.bg" <ja@ssi.bg>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>

On Thursday 21 October 2010 13:26:54 Eric Dumazet wrote:
> Le jeudi 21 octobre 2010 =C3=A0 13:16 +0200, Simon Horman a =C3=A9cri=
t :
>
> > > @@ -2680,10 +2664,15 @@ static int ip_vs_genl_dump_services(struc=
t sk_buff *skb,
> > >  	int idx =3D 0, i;
> > >  	int start =3D cb->args[0];
> > >  	struct ip_vs_service *svc;
> > > -
> > > +	struct net *net =3D skb->sk->sk_net;
> >
> > skb->sk->sk_net needs CONFIG_NS_NET.
> > Is your plan for IPVS to unconditionally depend on CONFIG_NS_NET?
> > It would be nice to avoid that, but I fear it will be too messy.
> >
>
>
> struct net *net =3D sock_net(skb->sk);
>
> is your friend ;)
>
>
Tanks Eric,

Simon,
do forget about my last mail....
>

--
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
