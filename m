Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A11F45208AB;
	Wed, 30 Sep 2026 17:35:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790789708; cv=none; b=H4QxNrZ42bX6hdzVZdfqP4B76FQi0T5v2OrunF+9wqqYyBbByKREQziTKWBuOBqk7s9LwAtD4BYGTfflo1F3IPKatm5grM/dDYvaNp0EBDyyZ2MomiuekdYLxy+eM9Z2XQ3Lri9n+Yc95D/Q8jYIl2WzGAZCNQbN55Jc9y3mqeo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790789708; c=relaxed/simple;
	bh=CtaDDpiwoaxhSurN8ULwMukCjHDsh2zt45LSXEvWACQ=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=mx2x88vlarzRlpBWX+2csfJkHICS3AqKKFbDUgNc2xPT6ggDBzUnPhIpo/4hKGf/4Qo1eHurguCJxUiTZIntVWcUQosxmIQ2XMDZtyoYgJnRrxYxvTg/s6IAiSG7n5oM2NDfwCZr4+wKT5V5sfxqAEZnvveOH5oSFsG9xD08ySg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=DLyqEo7I; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="DLyqEo7I"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id BA1B521ABA;
	Wed, 30 Sep 2026 20:34:59 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=6qsX1rI09sdlghFg7aI0sWKXjGCI6AnproNq78VzhWs=; b=DLyqEo7IVW/Q
	wPVn+W9U8IRD13QvP7kARkttlCghgMT1V2gul4ebQs6fKNvvHPdcH7CgfifsDgFZ
	AsIT6j8rmWyJMW7VRv9/105Z9yj3qhDqQ1acdw9CzHzjFokWeFblZEmcAmGcaK45
	DRdmkL0E6a1Arj1ZNlCOaAAdf0CHMOljvOw+/4JKfBbnMD10gnbHi9qlLOOIV3L+
	XFpPLwqhDilJpClJhiNyZFuOy674Wtree7xVWKJNGGo61Y1h/q648DJ5ms/K9xp0
	pgpGaNyEe19qJCUYmyZur7x47jV6+y5hHBZjIl/7VZLfVI4aI5r91AuC1A/FMSo8
	PJuUiH+mfWRZAaKIewACGSO+pcDrmwhD2s9hXIpGaQqb2t7XddjJgUrP9sqg1uVk
	YNtvEQ1JhL9tdPwqSxPubdYAcStQi6unUi2jfZR70eDTM4HghfNb93OIJ1VAvZgu
	RPiQmmmBg70YeqzssHv32dBYg4ckrUz49yrR/+7Yf9eofH63LlQWRSkOTwrUe+D9
	iE5eS3sXesjALc3Wb7naei6z4s1/TMsZZLdGgJXfGK2uPgPiy23aom+zLembFFM7
	IpmQMSiku5fpVq2C7nAp8Uf42oHhvto34YCspDXzX66g4rhiZGJOc0UTlgnNGWLT
	67BK3lqTbg0xTtje/IylAT5xKpEdy/Y=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 30 Sep 2026 20:34:59 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id E111861D2F;
	Wed, 30 Sep 2026 20:35:01 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68UHYvHM074166;
	Wed, 30 Sep 2026 20:34:57 +0300
Date: Wed, 30 Sep 2026 20:34:57 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Ido Schimmel <idosch@nvidia.com>
cc: Axel Mierczuk <axel.mierczuk@1password.com>,
        Simon Horman <horms@verge.net.au>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        David Ahern <dsahern@kernel.org>, Eric Dumazet <edumazet@google.com>,
        netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        Willy Tarreau <w@1wt.eu>, Keith Hoodlet <keith.hoodlet@1password.com>
Subject: Re: [PATCH nf 0/2] ipvs: fix OOB write when NATing ICMPv6 errors
 quoting non-first fragments
In-Reply-To: <20260928111538.GA389451@shredder>
Message-ID: <faecbb5a-01bc-ccc3-95e1-03579ba98a4e@ssi.bg>
References: <20260925141155.17603-1-axel.mierczuk@1password.com> <0458880e-5e0f-1f11-7ce2-e0490796c832@ssi.bg> <20260928111538.GA389451@shredder>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 28 Sep 2026, Ido Schimmel wrote:

> On Fri, Sep 25, 2026 at 08:50:58PM +0300, Julian Anastasov wrote:
> > 
> > > Axel Mierczuk (2):
> > >   ipvs: avoid out-of-bounds write in ip_vs_nat_icmp_v6
> > >   ipv6: update *offset for non-first fragments in ipv6_find_hdr()
> > > 
> > >  net/ipv6/exthdrs_core.c         |  6 +++++-
> > >  net/netfilter/ipvs/ip_vs_core.c | 14 ++++++++++++++
> > >  2 files changed, 19 insertions(+), 1 deletion(-)
> > 
> > 	Both patches look good to me, thanks!
> > 
> > Acked-by: Julian Anastasov <ja@ssi.bg>
> > 
> > 	The ipv6 patch needs review from the net team and
> > may need some Fixes line:
> > 
> > Fixes: b777e0ce7437 ("[NETFILTER]: make ipv6_find_hdr() find transport protocol header")
> 
> Doesn't patch 2 make patch 1 redundant? It seems that the comments added
> by patch 1 become stale with patch 2, no?
> 
> If so, why do we need both? Why not send only patch 2 and blame
> 63dca2c0b0e7a?

	The idea was to have IPVS fix that can be backported
alone, if needed.

Regards

--
Julian Anastasov <ja@ssi.bg>

