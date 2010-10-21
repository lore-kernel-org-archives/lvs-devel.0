From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 5/9] ipvs network name space aware
Date: Thu, 21 Oct 2010 13:26:54 +0200
Message-ID: <1287660414.6871.85.camel@edumazet-laptop>
References: <201010081317.04167.hans.schillstrom@ericsson.com>
	 <20101021111644.GA25555@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:subject:from:to:cc
         :in-reply-to:references:content-type:date:message-id:mime-version
         :x-mailer:content-transfer-encoding;
        bh=FEz0+CVwpOkaVxLGXMM2qMdQ2eUF3v/Y/WJvkJUwH9Q=;
        b=DzzjnKP8nW9jIuMryG/5ZvVoBy3A77Qs2nfbk3BcaLG6uAqPWkdLUbhvXZyRcikiSa
         c05cmDEjAPGjvkrgA8UOZYxvLrZYgUvDlq6cby45yi3/dJYoLUde2K0YOKB536vJ8YNv
         Rc/TdjoWpH6W7HKJqSegq47UY2Tz//Dmk0kz0=
In-Reply-To: <20101021111644.GA25555@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Simon Horman <horms@verge.net.au>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, ja@ssi.bg, wensong@linux-vs.org, daniel.lezcano@free.fr

Le jeudi 21 octobre 2010 =C3=A0 13:16 +0200, Simon Horman a =C3=A9crit =
:

> > @@ -2680,10 +2664,15 @@ static int ip_vs_genl_dump_services(struct =
sk_buff *skb,
> >  	int idx =3D 0, i;
> >  	int start =3D cb->args[0];
> >  	struct ip_vs_service *svc;
> > -
> > +	struct net *net =3D skb->sk->sk_net;
>=20
> skb->sk->sk_net needs CONFIG_NS_NET.
> Is your plan for IPVS to unconditionally depend on CONFIG_NS_NET?
> It would be nice to avoid that, but I fear it will be too messy.
>=20


struct net *net =3D sock_net(skb->sk);

is your friend ;)


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
