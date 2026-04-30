Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 058B2466B5B;
	Thu, 30 Apr 2026 16:14:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777565689; cv=none; b=aoClCkqx5l+ylh6/Ldq3l4DF99VxMhE2BhY8wKazt3chA6LssYfHtbIadDkWhggOncFtDyWlBbY+PNjTm91Xo4+apxw1RNYdWeRBR/bIzIIIIkScH1ZEmCchWaj/735w/FP/MfVAfyS7paU3PIcZ+KopkqNa78qZED97nRiBU1Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777565689; c=relaxed/simple;
	bh=didMmUOq4YVReOy/Tx9HyBYvthTgIjxbXvHNSdqUFqg=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=c9WJ4n8EssMm+58eQfB2JdaCCMF9JsUJwJS+HMAQhQPpAV7+tmm7t84/RYY8VdYkQzp+mG1MfTflGGT0YhCuvpIMsFVBD5Kvbj7dgG25MIEA3zUg3OdI6IjFOEyMP00sZnz0YbKdvDV4qkqzvUt9bdQ2+fYHxqfdVcrmx5DJLdU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=EFdtb16h; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="EFdtb16h"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6D4CAC2BCB3;
	Thu, 30 Apr 2026 16:14:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1777565688;
	bh=didMmUOq4YVReOy/Tx9HyBYvthTgIjxbXvHNSdqUFqg=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=EFdtb16hVjn2t2wads0aBgok8iAQmBwvLHGD2wjb1XS8WCokWhQzDTC6Tb0SY3tl2
	 0llNI4UE88KytD+S+w/zkXCRVU667SHuog6MSTXuj/062kdujU5h5pCg0dcMcCcUrW
	 09pDxHT+oxfB8PDc/pOf3ontt5bQ5Mfv2dMgbOaFS3W8Yd1Hex5EFAScWUuZXpNGab
	 HY3j21NmbrnkgjVZOht0lYLotJj0jvvCgsvy+PUhDHgyZV0cyftm1epXrDdU9C0f0D
	 VKaDAoReYdmBwYxYrC38QBMlIoW+yGzqUH65eQ2uS1zmJ5/c0NTfs1WZgHUVf66REe
	 DebPt2YlS6uuA==
Date: Thu, 30 Apr 2026 17:14:44 +0100
From: Simon Horman <horms@kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: pablo@netfilter.org, fw@strlen.de, lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Subject: Re: [PATCH net] ipvs: fix shift-out-of-bounds in
 ip_vs_rht_desired_size
Message-ID: <20260430161444.GB900403@horms.kernel.org>
References: <20260427234014.86256-1-ja@ssi.bg>
 <20260430123917.1628871-2-horms@kernel.org>
 <fec8dc99-9611-7311-5ec0-0d5d3895b1cc@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fec8dc99-9611-7311-5ec0-0d5d3895b1cc@ssi.bg>

On Thu, Apr 30, 2026 at 04:10:16PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 30 Apr 2026, Simon Horman wrote:
> 
> > From: 'Simon Horman' <horms@kernel.org>
> > 
> > This is an AI-generated review of your patch. The human sending this
> > email has considered the AI review valid, or at least plausible.
> > Full review at: https://sashiko.dev
> > ---
> > ipvs: fix shift-out-of-bounds in ip_vs_rht_desired_size
> > 
> > This commit addresses a shift-out-of-bounds issue when roundup_pow_of_two()
> > is called with 0 in ip_vs_rht_desired_size. It updates the assignment to fall
> > back to 1 if n is 0.
> > 
> > > diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> > > index f5b7a2047291..ea450944465f 100644
> > > --- a/net/netfilter/ipvs/ip_vs_core.c
> > > +++ b/net/netfilter/ipvs/ip_vs_core.c
> > > @@ -237,7 +237,7 @@ int ip_vs_rht_desired_size(struct netns_ipvs *ipvs, struct ip_vs_rht *t, int n,
> > >  {
> > >  	if (!t)
> > >  		return 1 << min_bits;
> > > -	n = roundup_pow_of_two(n);
> > > +	n = n ? roundup_pow_of_two(n) : 1;
> 
> 	To overflow it on 64-bit we need 600GB+ memory, the
> conns are ~300 bytes.
> 
> 	In v2 I changed it to n > 0. To solve it completely
> we may need to introduce some kind of "conn_max" sysctl,
> now per-netns. It can help to limit the conns which are
> created GFP_ATOMIC while for other structures we will switch
> to GFP_KERNEL_ACCOUNT.

Thanks, I agree with this approach.

> 
> > The parameter n is a signed int. If n happens to be negative, it will evaluate
> > to true and be passed to roundup_pow_of_two().
> > 
> > Because roundup_pow_of_two() casts the input to unsigned long, a negative
> > value like -1 becomes ULONG_MAX. This results in a shift exponent of 64,
> > triggering a shift-out-of-bounds regression. Would it be safer to check
> > for n <= 0 instead?
> > 
> > Additionally, if n exceeds 1.07 billion (1 << 30) on systems with large
> > amounts of RAM, roundup_pow_of_two(n) evaluates to 1UL << 31. Since n is
> > a 32-bit signed int, assigning 1UL << 31 back to n overflows and results
> > in a negative number.
> > 
> > Since subsequent bounds checks use signed comparisons:
> > 
> > >  	if (lfactor < 0) {
> > >  		int factor = min(-lfactor, max_bits);
> > >  
> > >  		n = min(n, 1 << (max_bits - factor));
> > 
> > These checks will fail to constrain the size correctly.
> > 
> > [ ... ]
> > 
> > >  	/* Shrink but keep it n * 2 to prevent frequent resizing */
> > >  	return clamp(n << 1, 1 << min_bits, 1 << max_bits);
> > >  }
> > 
> > Eventually, the function returns clamp(n << 1, 1 << min_bits, 1 << max_bits).
> > Shifting a negative number causes undefined behavior, and the clamp operation
> > will force the hash table to its absolute minimum size.
> > 
> > Could this cause millions of connections to be placed into a minimally sized
> > hash table, causing severe collisions during RCU hash lookups?
> 
> 	All that is valid without conn/mem limits.

Sorry, my previous email was supposed to come with some commentary
that I think that this is a pre-existing issue that can be treated
separately from this patch.
