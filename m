From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 1/9] ipvs network name space aware
Date: Thu, 21 Oct 2010 17:24:56 +0200
Message-ID: <1287674696.6871.109.camel@edumazet-laptop>
References: <201010081316.46690.hans.schillstrom@ericsson.com>
	 <201010181523.49568.hans.schillstrom@ericsson.com>
	 <20101019184436.GG2362@linux.vnet.ibm.com>
	 <201010201025.20950.hans.schillstrom@ericsson.com>
	 <20101020160205.GB2386@linux.vnet.ibm.com>
	 <1287651504.6871.44.camel@edumazet-laptop>
	 <20101021151613.GB2363@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:subject:from:to:cc
         :in-reply-to:references:content-type:date:message-id:mime-version
         :x-mailer:content-transfer-encoding;
        bh=P73BGzbR61KvKbrzYIVNSXNSs+TA4/VVBfYgt8VKbWQ=;
        b=F383U/GzPCWCIhpW/oVeB6uebKZ3OzO2p7vpkPhbphVJPxPUt+PDu8Fl++ESboEmzz
         papGTsL5phqDkJGtm0PS0QBxZ3PTKLIYaf/wSTSxZfobX9Y5I7pBN6Z5POF2FftRrwFV
         Hp5Wr9eOlJRwXrpFuWlr+3BG9HjzpBEt8TFlI=
In-Reply-To: <20101021151613.GB2363@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: paulmck@linux.vnet.ibm.com
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, Daniel Lezcano <daniel.lezcano@free.fr>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "horms@verge.net.au" <horms@verge.net.au>, "ja@ssi.bg" <ja@ssi.bg>, "wensong@linux-vs.org" <wensong@linux-vs.org>

Le jeudi 21 octobre 2010 =C3=A0 08:16 -0700, Paul E. McKenney a =C3=A9c=
rit :

> Here is what it looks like in my -rcu tree:
>=20
> void __rcu_read_lock(void)
> {
> 	current->rcu_read_lock_nesting++;
> 	barrier();  /* needed if we ever invoke rcu_read_lock in rcutree.c *=
/
> }
>=20
> So yes, I finally did convince myself that the ACCESS_ONCE was not
> needed.  ;-)
>=20
> This is not yet in mainline, but Ingo sent the series containing this
> commit (80dcf60e) to Linus earlier today, so there is hope!
>=20

Excellent, thanks for taking time to clarify this Paul.



