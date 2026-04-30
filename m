Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AEBBF3A4F32;
	Thu, 30 Apr 2026 13:10:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777554629; cv=none; b=J2J3koKzFegNJGOB8Dyt27Un4KwYidenMn4FK/IGVD9hdCtoTg7Hce2aG3ulWo3b7gYQkI6TTe7uRlkbQvf3J5LAGvmp8MOhb7E8+EQdUIeOfb6ZQycNNurRGaMdqucTyrkeH9nBIJuj3sPY3woVi70TV55+okAK62ynVzgddqY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777554629; c=relaxed/simple;
	bh=KZPypeK+VvHN7tyvMnyAUYzimRriKTvsTR9yLNw6TwY=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=MgzgbxTQ8Mxs9ZQqd/MoqnTyBv9HrGwkGTetb8vMjpC3j29yicCyyQwwO0rTpfuRVa5BivbtE+A1wQEtMpYNtw2Imw0UUy8yYcEeT3eUAubNt0X9P07oS9H+1P4Fa7sRq3BBbYKLWij0I2MiwNTuLrBa8w6MtCJG5o4Pw6GyPtA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=JW8j6XN/; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="JW8j6XN/"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 487772292F;
	Thu, 30 Apr 2026 16:10:20 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=6eOycCEcSlmpqyMHk/j1cnGYIXhhIxDgKIaphAvfliY=; b=JW8j6XN/CKVg
	X6N6SdA3Y+3snjIQYwid2OKIULVpcgrObZebAQm2wodcsdZDpXvDaOoXd7sQzssx
	DIhjUHRiMk03UoJ4wRUNyGeGwACn8vNtrHkg/P6fgy/zZ88UyFvx8FgUOlGE3228
	rdEc83Y6hUb5QQQYu+wzEHyjQI3c0qIzJUe7Wse7ROWjzAhAqSX9K7HbEJpF2iD7
	dug0v/6zfT6j620MpUsUVEJxlQgpqGvdvMXSEAk27I1OjI3WM449dRSfb60b3ZzR
	ebbNria9iZHv2i+IJY8JoPJtrpyn/+waqXhzWEg4QVCYBcr0csnEaaI9iEHrC1HD
	ivUSg2tcImf+Xt680DosojUMURY/W41qzWuliuRarFFi3ydpW0szGaF7ZqJ6OAWz
	Ej5/aweE5fbuNgBks5/hRxUFytp2lL7ap8hXi5px4xpvEAiAI2k5MfNc6MWXfkOO
	6E8neZy+LuIh3LYkfNZ+cEp01lEAnoIkQtEstxYY2q6PoF2bfiBBhz61GkRxFvMK
	jWNL9beFaAhJv4AEOona5QHgh+637xQzoWuSMoW6lTUFsyADf8WaMP/u6MxITfFq
	2W2NbweKnamW+mTL9BwownE3mflRLLZ830Ofmk8t8R/VPvDZvgK5k8/ElwwZZltw
	ciJfd9lrOPwZejpE0NUzWjDnBdq8/Rw=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 30 Apr 2026 16:10:19 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id C365A61C02;
	Thu, 30 Apr 2026 16:10:17 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63UDAGec055756;
	Thu, 30 Apr 2026 16:10:16 +0300
Date: Thu, 30 Apr 2026 16:10:16 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@kernel.org>
cc: horms@verge.net.au, pablo@netfilter.org, fw@strlen.de,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org
Subject: Re: [PATCH net] ipvs: fix shift-out-of-bounds in
 ip_vs_rht_desired_size
In-Reply-To: <20260430123917.1628871-2-horms@kernel.org>
Message-ID: <fec8dc99-9611-7311-5ec0-0d5d3895b1cc@ssi.bg>
References: <20260427234014.86256-1-ja@ssi.bg> <20260430123917.1628871-2-horms@kernel.org>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Thu, 30 Apr 2026, Simon Horman wrote:

> From: 'Simon Horman' <horms@kernel.org>
> 
> This is an AI-generated review of your patch. The human sending this
> email has considered the AI review valid, or at least plausible.
> Full review at: https://sashiko.dev
> ---
> ipvs: fix shift-out-of-bounds in ip_vs_rht_desired_size
> 
> This commit addresses a shift-out-of-bounds issue when roundup_pow_of_two()
> is called with 0 in ip_vs_rht_desired_size. It updates the assignment to fall
> back to 1 if n is 0.
> 
> > diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> > index f5b7a2047291..ea450944465f 100644
> > --- a/net/netfilter/ipvs/ip_vs_core.c
> > +++ b/net/netfilter/ipvs/ip_vs_core.c
> > @@ -237,7 +237,7 @@ int ip_vs_rht_desired_size(struct netns_ipvs *ipvs, struct ip_vs_rht *t, int n,
> >  {
> >  	if (!t)
> >  		return 1 << min_bits;
> > -	n = roundup_pow_of_two(n);
> > +	n = n ? roundup_pow_of_two(n) : 1;

	To overflow it on 64-bit we need 600GB+ memory, the
conns are ~300 bytes.

	In v2 I changed it to n > 0. To solve it completely
we may need to introduce some kind of "conn_max" sysctl,
now per-netns. It can help to limit the conns which are
created GFP_ATOMIC while for other structures we will switch
to GFP_KERNEL_ACCOUNT.

> The parameter n is a signed int. If n happens to be negative, it will evaluate
> to true and be passed to roundup_pow_of_two().
> 
> Because roundup_pow_of_two() casts the input to unsigned long, a negative
> value like -1 becomes ULONG_MAX. This results in a shift exponent of 64,
> triggering a shift-out-of-bounds regression. Would it be safer to check
> for n <= 0 instead?
> 
> Additionally, if n exceeds 1.07 billion (1 << 30) on systems with large
> amounts of RAM, roundup_pow_of_two(n) evaluates to 1UL << 31. Since n is
> a 32-bit signed int, assigning 1UL << 31 back to n overflows and results
> in a negative number.
> 
> Since subsequent bounds checks use signed comparisons:
> 
> >  	if (lfactor < 0) {
> >  		int factor = min(-lfactor, max_bits);
> >  
> >  		n = min(n, 1 << (max_bits - factor));
> 
> These checks will fail to constrain the size correctly.
> 
> [ ... ]
> 
> >  	/* Shrink but keep it n * 2 to prevent frequent resizing */
> >  	return clamp(n << 1, 1 << min_bits, 1 << max_bits);
> >  }
> 
> Eventually, the function returns clamp(n << 1, 1 << min_bits, 1 << max_bits).
> Shifting a negative number causes undefined behavior, and the clamp operation
> will force the hash table to its absolute minimum size.
> 
> Could this cause millions of connections to be placed into a minimally sized
> hash table, causing severe collisions during RCU hash lookups?

	All that is valid without conn/mem limits.

Regards

--
Julian Anastasov <ja@ssi.bg>

