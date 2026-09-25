Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4924A3B95E3;
	Fri, 25 Sep 2026 17:51:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790358666; cv=none; b=jcObWZ6imBNecdYXhvgLMIIox07ye5H8ZaAtIfbMD4n6JEacD5Ep0ZJ6Tbl7QU+3LNf4c2TGuP1lzfRBJ9QlMy1PhGiuSTtptAPwUX1s9Kyyr8fxrdu+vJ83FyE7+FCtrA8XKoGQM0Mg47ucsSoXjaUi5e5K9BKb4hvUVrWhoUQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790358666; c=relaxed/simple;
	bh=nz1SBO1R+0x0jCLLINT/y4xflScWkZQLeM98WXZqVlc=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=M3XVK//04HTAWFKlBwbxJM0SqV+3XYkMWJ4luoVY8fqWBpVIjx3YcnUgs9alzj0kXVvFVbJvTTdY9fAXIWlOc5bOdoKd3rOJydaDgqV3KFcBEGSTkO+fdJ/WIOyLvSBbOH8sxCDIC7OCs+NILEnIh1jBW61mWv3TSu4/exKOdsk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=kpo8Awdr; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="kpo8Awdr"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id EBE50213B6;
	Fri, 25 Sep 2026 20:50:58 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=6U2jVolTPyjf0hZOUqxneWpoK28h5julF/NQ/IsfJoo=; b=kpo8Awdr5dg1
	ba4VhMmeSuISIvuTJupwVqw+jEa8gw3OnxwEBhP2vnFB+45eXJosyXqucl1r8ZJ+
	BSz6qNVM3JQRWVlQecmZCwbY9KkrAAViRXOpp9cNzT23CFE83VJRMe5jvqYyWwFS
	MBr0r2WnBqNIQVTscUnCk67ZAx3mt3aCoykW1mHmP9cppK0iJEDb9HzQbz/7FIGc
	IJLy/0kkEtY6pFQSMTasb006UKEnWL2A8qyj8zOHHYW4whSuEEED6JQWsL8FPWDA
	7aoyYRh/65IXBP+i1Lpx+JL27NAgsWqknSH9OAZcvHv7cvkFQA2her3csLkZT8Nr
	eZ9E3pXkVAkqRfq4seb7vr1IW26RXGg/BFID8y0hK0PZfEH7N0WKk/BBmX8OCBPB
	jrX9etrjDUEwQwjO07oU0WEdQb+oMcz1rHV/LzajGClQElNa5T92tpMEshKIP2Gt
	+0/MLNjvzyDtOU8HCL6iAkjT3kGActsrn3fQVHrywubNHvyhVn+SVDll6bJvsXlu
	RiQlLyJYNqvqQmytKuQBuAEwINMjLfwNr9H7b4CIsgtdSvMYlgTVjz+Y80DDOzHv
	+/oZosT4E/fU/ss/ktmrKl8BIMJXkr8SGTRMiUbTRpiAi2Wv3p//rrDJkJ+bxAii
	ztT1JVn/bGZ33B98C9eMYpH+/Qe4tfA=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri, 25 Sep 2026 20:50:58 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id D58746090A;
	Fri, 25 Sep 2026 20:51:00 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68PHowPB063225;
	Fri, 25 Sep 2026 20:50:58 +0300
Date: Fri, 25 Sep 2026 20:50:58 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Axel Mierczuk <axel.mierczuk@1password.com>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        David Ahern <dsahern@kernel.org>, Ido Schimmel <idosch@nvidia.com>,
        Eric Dumazet <edumazet@google.com>, netfilter-devel@vger.kernel.org,
        lvs-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, Willy Tarreau <w@1wt.eu>,
        Keith Hoodlet <keith.hoodlet@1password.com>
Subject: Re: [PATCH nf 0/2] ipvs: fix OOB write when NATing ICMPv6 errors
 quoting non-first fragments
In-Reply-To: <20260925141155.17603-1-axel.mierczuk@1password.com>
Message-ID: <0458880e-5e0f-1f11-7ce2-e0490796c832@ssi.bg>
References: <20260925141155.17603-1-axel.mierczuk@1password.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Fri, 25 Sep 2026, Axel Mierczuk wrote:

> This series fixes a 16-byte OOB write past the verified skb area,
> reachable through ICMPv6 errors that quote non-first fragments.
> Following Julian's suggestion, it preserves ESP ICMPv6 handling.
> 
> Patch 1 includes the embedded IP header in ciph.len at both ICMPv6
> call sites when parsing stops at a non-first fragment. The change
> follows the ip_vs_fill_iph_skb_icmp() calls and does not depend on
> patch 2.
> 
> Patch 2 makes ipv6_find_hdr() set *offset to the fragment payload
> for non-first fragments when target < 0, so every successful return
> updates it. It carries no Fixes tag because it defines an offset
> that was previously unspecified.
> 
> Axel Mierczuk (2):
>   ipvs: avoid out-of-bounds write in ip_vs_nat_icmp_v6
>   ipv6: update *offset for non-first fragments in ipv6_find_hdr()
> 
>  net/ipv6/exthdrs_core.c         |  6 +++++-
>  net/netfilter/ipvs/ip_vs_core.c | 14 ++++++++++++++
>  2 files changed, 19 insertions(+), 1 deletion(-)

	Both patches look good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

	The ipv6 patch needs review from the net team and
may need some Fixes line:

Fixes: b777e0ce7437 ("[NETFILTER]: make ipv6_find_hdr() find transport protocol header")

Regards

--
Julian Anastasov <ja@ssi.bg>

