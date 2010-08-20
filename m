From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch nf-next] IPVS: convert __ip_vs_securetcp_lock to a
 spinlock
Date: Fri, 20 Aug 2010 16:55:36 +0200
Message-ID: <1282316136.2484.144.camel@edumazet-laptop>
References: <20100820145206.GA11781@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:subject:from:to:cc
         :in-reply-to:references:content-type:date:message-id:mime-version
         :x-mailer:content-transfer-encoding;
        bh=HXKhmqKECWWRp8MTfSZrAtHbxHM/Swe+2AItixpcVvs=;
        b=helVOsC7OiAraLEI/aDLyVyPUqyC111shaPEgMjuXgalKchBhaqhiyeQYwatrpiYYA
         s/5zUgNTQKsP1Tnd77qm22dMre2lNiNTPG6hUQlqpkGzINFoYckG+nfYIlqcPqxyA0QY
         yeBXww/k7OOmRHw3skpwFI6wBWbh5u+fx2/UU=
In-Reply-To: <20100820145206.GA11781@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>, Changli Gao <xiaosuo@gmail.com>, yao zhao <dragonlinux@gmail.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

Le vendredi 20 ao=C3=BBt 2010 =C3=A0 23:52 +0900, Simon Horman a =C3=A9=
crit :
> Also rename __ip_vs_securetcp_lock to ip_vs_securetcp_lock.
>=20
> Spinlock conversion was suggested by Eric Dumazet.
>=20
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Simon Horman <horms@verge.net.au>
>=20
> ---=20

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
