From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [rfc] IPVS: convert scheduler management to RCU
Date: Fri, 20 Aug 2010 16:05:50 +0200
Message-ID: <1282313150.2484.65.camel@edumazet-laptop>
References: <20100820133320.GA29311@verge.net.au>
	 <AANLkTimS7V3z1kEwmEFCCvPzJX=D9Oqw=BNEuN-YZ0tx@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:subject:from:to:cc
         :in-reply-to:references:content-type:date:message-id:mime-version
         :x-mailer:content-transfer-encoding;
        bh=LWTghp07qzyqr/hdz9B5G6kLGABCR7uDI4EjFMr/5as=;
        b=imljyMkc1PS7zMe+OqyFqJCC+lImGrFf69qLCTn4EPG/3oC7GV2NfEnDdC8vHwY19z
         8kNHQIJtNV1hGzgLS1MrZAwwH5DnS2KnCx9nBcpFzdoaKB9ijPRkCMKVGtMlU1GyDD79
         gzHimnN5nrsT5DiC/vn15YihdMwx0WkN7hnlA=
In-Reply-To: <AANLkTimS7V3z1kEwmEFCCvPzJX=D9Oqw=BNEuN-YZ0tx@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Changli Gao <xiaosuo@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Paul E McKenney <paulmck@linux.vnet.ibm.com>

Le vendredi 20 ao=C3=BBt 2010 =C3=A0 21:44 +0800, Changli Gao a =C3=A9c=
rit :
> On Fri, Aug 20, 2010 at 9:33 PM, Simon Horman <horms@verge.net.au> wr=
ote:
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> >
> > ---
> >
> > I'm still getting my head around RCU, so review would be greatly ap=
preciated.
> >
> > It occurs to me that this code is not performance critical, so
> > perhaps simply replacing the rwlock with a spinlock would be better=
?
> >
> > Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_sched.c


> > -       write_unlock_bh(&__ip_vs_sched_lock);
> > +       list_del_rcu(&scheduler->n_list);
> > +       spin_unlock_bh(&ip_vs_sched_mutex);
>=20
> Need a rcu_barrier_bh().
>=20
> >
> >        /* decrease the module use count */
> >        ip_vs_use_count_dec();


Quite frankly, if this is not performance critical, just use the
spinlock (and dont use 'mutex' in its name ;) )

Using RCU here will force at least one RCU grace period at dismantle
time...



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
