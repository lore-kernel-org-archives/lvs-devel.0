Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 46BA61F949;
	Wed, 11 Dec 2024 16:46:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1733935617; cv=none; b=IYJT3+My8eEwUKu6YzoWt+P8XiDkqPPEq56iNDngfOt6ifY/NKqsOPWT+OBwHZpbdpcIp8ow+beAoPkKntBAaXmrEK2je4mr0pgfIpJjxni2bsdDTKiznL6y5pEN0rfuu/XuMitpWLak/uUz7fCl20fL0XRCM4TMoZZAJ5SLrMY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1733935617; c=relaxed/simple;
	bh=96Cayvso728TmhS6qmHKdvsuIfX5z5hnZTLixJoAqcM=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=jmbtEZ/YPqWP1I7DClVyB0z8s2Bt0jd3A7DvIKTlDobNJTcwMbEydOAfa8js6WoK6hzuddEvMWhhx3vGK54yLIzAqTZyMY5enewCDREboVl/eOAqolTnZWCO6O0ERBxv0SqYBk4lHJMFxABNGkoytiJpqxjkH5vLJoLK+4ya+Y4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=kmc6W85V; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="kmc6W85V"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id CBACC23557;
	Wed, 11 Dec 2024 18:46:45 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=2FvUHXc/TMwGrU7X3V1Wpacmv3StILxOEravI0TKj2E=; b=kmc6W85V+Hog
	L5grwQ6YCMdmMw+56yrRz0b297gPiKDi6cKLeEeEaMq1zYhjDvES2Tcbe52mKpzU
	1tAt2EpWy9TrDpsZVeB9qwJrF9TsH4P7ZErLh3NnpDjs/TwyIhDChoZSXuPVtKha
	0+paW9WzxsmGbjgYfV2iU7b0pJ0dOBc+O0LB8p6ZWqgMuAxSikEmXQbOb/BnJ5Uv
	xZcZBjK2g9uoTUp08xBdZpTfkoQ5xuIWzYga4fl6Hrse2crOqej6YJf0fcF7/TP2
	U2lR3BJ/RILAsVqD9yRqo5gDrBGO8s24ygt0ln3oQPDw31IE6BllsoT2NISwG4Wz
	yAJFFWLp0uY8n2lkLp1Y9oN+BOad4Cky19XMRh0LjGwZ2nWBJLp0duwywh1gvzh3
	q6xnQnh3SbiUvUAeJBgpX+gW9uu3dJsWXCJYTUH93HNyKQqUUnxjBPb1wyEJleBf
	w2DCUTXxrmbCC0Lz7YDFsQ1AlTXpWq/LsdPYdwRirhQdhgkTkvfVn3mCaM1Ca133
	iHiSe2zoqqN8vKhFePBuCCiEUMVVnqYx1ABbzLFluKVA/mnxHN6rk+PcTGE1t2NO
	Gm+Q0DokXHYGuOhBL9g0ERIZv5ogUbdufURKQdwkVGvCIQsxZWx2yOV34/V9iOuF
	lLfSOZviyk8DYDtBNrcHcG72//7XPcw=
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 11 Dec 2024 18:46:44 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id A842015D48;
	Wed, 11 Dec 2024 18:46:36 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.17.1) with ESMTP id 4BBGkRAC056570;
	Wed, 11 Dec 2024 18:46:28 +0200
Date: Wed, 11 Dec 2024 18:46:27 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: David Laight <David.Laight@ACULAB.COM>
cc: "'Dan Carpenter'" <dan.carpenter@linaro.org>,
        Simon Horman <horms@verge.net.au>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@netfilter.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>,
        "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
        "coreteam@netfilter.org" <coreteam@netfilter.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Bartosz Golaszewski <brgl@bgdev.pl>
Subject: RE: [PATCH net] ipvs: Fix clamp() order in ip_vs_conn_init()
In-Reply-To: <7e01a62a5cb4435198f13be27c19de26@AcuMS.aculab.com>
Message-ID: <af5b4872-4645-2bf3-19c1-72a45fda18b1@ssi.bg>
References: <1e0cf09d-406f-4b66-8ff5-25ddc2345e54@stanley.mountain> <7e01a62a5cb4435198f13be27c19de26@AcuMS.aculab.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Wed, 11 Dec 2024, David Laight wrote:

> From: Dan Carpenter
> > Sent: 11 December 2024 13:17
> > 
> > We recently added some build time asserts to detect incorrect calls to
> > clamp and it detected this bug which breaks the build.  The variable
> > in this clamp is "max_avail" and it should be the first argument.  The
> > code currently is the equivalent to max = max(max_avail, max).
> 
> The fix is correct but the description above is wrong.
> When run max_avail is always larger than min so the result is correct.
> But the compiler does some constant propagation (for something that
> can't happen) and wants to calculate the constant 'clamp(max, min, 0)'
> Both max and min are known values so the build assert trips.
> 
> I posted the same patch (with a different message) last week.

	I was still waiting for v2 from David Laight as
he can put more specific explanation for the bad 3rd arg
to clamp() and to add the Fixes header.

	David, let me know what should we do, I prefer
to see v2 from you but if you prefer we can go with the
latest version from Dan...

> > Reported-by: Linux Kernel Functional Testing <lkft@linaro.org>
> > Closes:
> > https://lore.kernel.org/all/CA+G9fYsT34UkGFKxus63H6UVpYi5GRZkezT9MRLfAbM3f6ke0g@mail.gmail.com/
> > Fixes: 4f325e26277b ("ipvs: dynamically limit the connection hash table")
> > Signed-off-by: Dan Carpenter <dan.carpenter@linaro.org>
> > ---
> > I've been trying to add stable CC's to my commits but I'm not sure the
> > netdev policy on this.  Do you prefer to add them yourself?
> > 
> >  net/netfilter/ipvs/ip_vs_conn.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> > index 98d7dbe3d787..9f75ac801301 100644
> > --- a/net/netfilter/ipvs/ip_vs_conn.c
> > +++ b/net/netfilter/ipvs/ip_vs_conn.c
> > @@ -1495,7 +1495,7 @@ int __init ip_vs_conn_init(void)
> >  	max_avail -= 2;		/* ~4 in hash row */
> >  	max_avail -= 1;		/* IPVS up to 1/2 of mem */
> >  	max_avail -= order_base_2(sizeof(struct ip_vs_conn));
> > -	max = clamp(max, min, max_avail);
> > +	max = clamp(max_avail, min, max);
> >  	ip_vs_conn_tab_bits = clamp_val(ip_vs_conn_tab_bits, min, max);
> >  	ip_vs_conn_tab_size = 1 << ip_vs_conn_tab_bits;
> >  	ip_vs_conn_tab_mask = ip_vs_conn_tab_size - 1;
> > --
> > 2.45.2

Regards

--
Julian Anastasov <ja@ssi.bg>

