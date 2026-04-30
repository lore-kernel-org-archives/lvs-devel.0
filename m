Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6A649402BB3;
	Thu, 30 Apr 2026 12:39:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777552782; cv=none; b=B1Hf8kdJGibW1JMYT7oDwgl7X20YmS6+0NZpBy0d4C7maZBi4Hk6zM6Evt0ciJlK3v/wfHU+XJhgS6TE3VaQ12JdjBzzZkFIQvJejNS68EccgQNaib9OLn0nvRa5NoZYwPLR1hXprv0od7XDle8itDYwTsFbv5mYZ9MlBwaAgHA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777552782; c=relaxed/simple;
	bh=alV+aEqi3amymeBneZO+qaYy/kMGzrvTDlQxhrneIGc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=eAxV6dAaKnp1FuO8PfwoK0ROzT6Qk8q4wQqfQOGm5rwPiNw7a59SSEmxvUiw8H42yyhg6v34lsjdNCoX9i+w1QpyRUU4TDe7/DUSbHk9UTtgmCTruG1R6bMxKLDcsOV9oSuDgf6tNomARpwTITVhNpowshZG+VTTMuHBJDAlrSk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=BASPnHlS; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="BASPnHlS"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 64880C2BCB3;
	Thu, 30 Apr 2026 12:39:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1777552782;
	bh=alV+aEqi3amymeBneZO+qaYy/kMGzrvTDlQxhrneIGc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=BASPnHlSE4erbgxSBRbKpd58+iTeXgrirzwC2AxcbZ9RPY9DqI8MiEL/NYCYFuMD+
	 8y7aszXouAd+P5nqPNncrqh0wDvWSSApCuynEtbN9vlRQh4q9sASWkn/gRdcfHTOcu
	 4ict6+SHH4axC2BcX7WGPZj3ZgLw/wJ6FjLTODcG3K66yFTdfxzRXdC3QZ6ht+4E8D
	 jphGYwI2nr1QJNvsGW8a5YcSaLgKXZEspvnVajf73ZYpW9Nc1daugiDrcQT+EOfn1u
	 pG3TEH0Bd7jWRfix4qHua3KsfAVXjjbaqJ40HXqE95lqcsU5sQlXNwVIb4QeNGNoKx
	 Dx80Ld68EnaXQ==
From: Simon Horman <horms@kernel.org>
To: ja@ssi.bg
Cc: 'Simon Horman' <horms@kernel.org>,
	horms@verge.net.au,
	pablo@netfilter.org,
	fw@strlen.de,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
Subject: Re: [PATCH net] ipvs: fix shift-out-of-bounds in ip_vs_rht_desired_size
Date: Thu, 30 Apr 2026 13:39:17 +0100
Message-ID: <20260430123917.1628871-2-horms@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260427234014.86256-1-ja@ssi.bg>
References: <20260427234014.86256-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: 'Simon Horman' <horms@kernel.org>

This is an AI-generated review of your patch. The human sending this
email has considered the AI review valid, or at least plausible.
Full review at: https://sashiko.dev
---
ipvs: fix shift-out-of-bounds in ip_vs_rht_desired_size

This commit addresses a shift-out-of-bounds issue when roundup_pow_of_two()
is called with 0 in ip_vs_rht_desired_size. It updates the assignment to fall
back to 1 if n is 0.

> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index f5b7a2047291..ea450944465f 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -237,7 +237,7 @@ int ip_vs_rht_desired_size(struct netns_ipvs *ipvs, struct ip_vs_rht *t, int n,
>  {
>  	if (!t)
>  		return 1 << min_bits;
> -	n = roundup_pow_of_two(n);
> +	n = n ? roundup_pow_of_two(n) : 1;

The parameter n is a signed int. If n happens to be negative, it will evaluate
to true and be passed to roundup_pow_of_two().

Because roundup_pow_of_two() casts the input to unsigned long, a negative
value like -1 becomes ULONG_MAX. This results in a shift exponent of 64,
triggering a shift-out-of-bounds regression. Would it be safer to check
for n <= 0 instead?

Additionally, if n exceeds 1.07 billion (1 << 30) on systems with large
amounts of RAM, roundup_pow_of_two(n) evaluates to 1UL << 31. Since n is
a 32-bit signed int, assigning 1UL << 31 back to n overflows and results
in a negative number.

Since subsequent bounds checks use signed comparisons:

>  	if (lfactor < 0) {
>  		int factor = min(-lfactor, max_bits);
>  
>  		n = min(n, 1 << (max_bits - factor));

These checks will fail to constrain the size correctly.

[ ... ]

>  	/* Shrink but keep it n * 2 to prevent frequent resizing */
>  	return clamp(n << 1, 1 << min_bits, 1 << max_bits);
>  }

Eventually, the function returns clamp(n << 1, 1 << min_bits, 1 << max_bits).
Shifting a negative number causes undefined behavior, and the clamp operation
will force the hash table to its absolute minimum size.

Could this cause millions of connections to be placed into a minimally sized
hash table, causing severe collisions during RCU hash lookups?
