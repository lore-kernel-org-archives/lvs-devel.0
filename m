From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch nf-next] IPVS: convert __ip_vs_sched_lock to a spinlock
Date: Fri, 20 Aug 2010 16:56:28 +0200
Message-ID: <1282316188.2484.147.camel@edumazet-laptop>
References: <20100820145249.GB11781@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:subject:from:to:cc
         :in-reply-to:references:content-type:date:message-id:mime-version
         :x-mailer:content-transfer-encoding;
        bh=hJaaTkdA2ZjIAMOfV/aEMc1CCcxlPOx+QBBwLuRrfzI=;
        b=pF+Pfr7qJ03qrva8lkcH5nPssRlfhE1kpe1LJ3tGUK/mpUClO0CwM0n0iyuKN8iV+X
         WIPek9DktCVVM1Ihhf+Sue5L4q2KcCffxcNG5hJplNZt5KpclvcYoex2i49rzZnKWJV2
         +ZvHDJsqyvNbPY3SckWqAzj9lpJ1T3MwsVnZA=
In-Reply-To: <20100820145249.GB11781@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>, Changli Gao <xiaosuo@gmail.com>, yao zhao <dragonlinux@gmail.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

Le vendredi 20 ao=C3=BBt 2010 =C3=A0 23:52 +0900, Simon Horman a =C3=A9=
crit :
> Also rename __ip_vs_sched_lock to ip_vs_sched_lock.
>=20
> Signed-off-by: Simon Horman <horms@verge.net.au>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
