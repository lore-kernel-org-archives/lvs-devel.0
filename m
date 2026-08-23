Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 99627367B77;
	Sun, 23 Aug 2026 10:50:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787482245; cv=none; b=aTUSvkaXksr46Mq4ho4mSvXjgobsMR34FeGS1nNO8vmYGvJzs+o5a58te70fuWbUFs33SxJpqt267XiZ4WnefGj+zplk7K8Xxo2IN+ElFKP7A7lZ/IljDVVuHvzXITZbPf8l5NMweuOzqZvMZ4cYSk39b+YRE+AONEnhCHngRH4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787482245; c=relaxed/simple;
	bh=hoi7dFiiHaX84zkJzVtgHKiih+GgjzAXD+n0OMiiPsA=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=nwzSgvasW7ruqAtojVjFJ7T6dlc6l9PbkBhBqdYB0+oJJ5ZFXQM+NgK+DGhErk/ap0k64WbiDRgr74xpgxOj0jgjApsiEgPyYzayLbEWOyaamY5W7G2floyLt0PecWFfnOzlWtog07F9FN63Lyg5KaT+pOHHElMZWpl3eNCdVbA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=bF4qbOKX; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="bF4qbOKX"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 2F2E020DBF;
	Sun, 23 Aug 2026 13:50:27 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=/ldh8AB2RL+qyzwvI7GUcFQNbDMQpeWupqvdrUfhEOI=; b=bF4qbOKXTVzf
	bUSYeezx63IkbOQCpCg02SNf3rZEgBboSLih7MYUA7onU2wFxp9fDHQCU695YcP/
	mnvRYvxxQeaNwD6VM1F5jgCKb0q0V2cHSm2HVRVar8zoOyDPdT710mMXdAk5n7F/
	VbGM2DPaXP24cRcoSj5imKHs5DDvbdm8RggH1A+g75nUSNSTOSaJMrI2+Qn0AceM
	2XkwIQ3/MzkWcvAjw4mX7fxUKOhyMGqRLoBbT3HnZucefnefPAv35yUrAFFqyi/i
	82InuEFbJ8GudIoTqokZ/dZZABvmbt3rqMplW0oGVHSJr1uBRe4o4Zknh13puZkz
	zWbvCaae0jE7XR74pQ9vazWT5EdXTbD1tfxDiRR8TrgWlXjev14BVWzXkMEH7Y4r
	CGIQm1pSfZs1wKxPj3lvcC4H3BS/9SHOKFjQS5V18VGl8ArRQmFYm57ACcLeLypy
	OmYmA9d/p3yC8/uvQUb6wWdD8OlMxnH6xvGum6OnLrzaCGjFBXBG9TVuGXvwgyme
	nntJ1cRBa9txrodgwEqW4jyD7xgkXYgRAziR0FHYxCEjW4Dlp2hSmrsQsdzivPKb
	H/Uq/4ymmnV2dgqYlEy2eKLjvIRLAM22lDP80TlydlUAFurMtrqly8D3AWBS772X
	ahuqeErQv++0TBtZF3Zry3JQiQ0sTMo=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sun, 23 Aug 2026 13:50:27 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id BAC17600AE;
	Sun, 23 Aug 2026 13:50:29 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 67NAoDf1017518;
	Sun, 23 Aug 2026 13:50:15 +0300
Date: Sun, 23 Aug 2026 13:50:13 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Zhiling Zou <zhilinz@nebusec.ai>
cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Simon Horman <horms@verge.net.au>, pablo@netfilter.org, fw@strlen.de,
        phil@nwl.cc, vega@nebusec.ai
Subject: Re: [PATCH nf v3 1/1] ipvs: bound LBLCR and LBLC cache growth
In-Reply-To: <0bdd5abe9968ded7ca2b9cb6844ba83d94cc8d53.1787318053.git.zhilinz@nebusec.ai>
Message-ID: <20eeca42-d18e-ce1c-ca2f-07a144a0bdff@ssi.bg>
References: <cover.1787318053.git.zhilinz@nebusec.ai> <0bdd5abe9968ded7ca2b9cb6844ba83d94cc8d53.1787318053.git.zhilinz@nebusec.ai>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Fri, 21 Aug 2026, Zhiling@mx.ssi.bg wrote:

> From: Zhiling Zou <zhilinz@nebusec.ai>
> 
> ip_vs_lblcr_new() and ip_vs_lblc_new() create cache entries for
> every previously unseen destination address. The table max_size only
> tells the periodic collector to reclaim entries after the cache has
> already exceeded the limit. It does not reclaim entries that the
> attacker continues to use.
> 
> Reject new cache entries once either table reaches max_size * 3 / 2.
> The extra headroom lets the periodic collector catch up while the
> existing scheduler fallback continues to use the selected destination
> when cache creation fails. New traffic therefore stays serviceable
> without growing the tables further.
> 
> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> Cc: stable@vger.kernel.org
> Reported-by: Vega <vega@nebusec.ai>
> Suggested-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Zhiling Zou <zhilinz@nebusec.ai>

	Looks good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
> changes in v3:
> - Allow 50% headroom above max_size before rejecting new cache entries,
>   as suggested by Julian Anastasov.
> - Apply the max_size * 3 / 2 cutoff to both LBLC and LBLCR.
> - v2 Link: https://lore.kernel.org/all/17cbb1d0649f4e19aa2e407ab4b528d42b8edac4.1786949472.git.zhilinz@nebusec.ai/
> 
> changes in v2:
> - Change the LBLCR limit check from >= max_size to > max_size.
> - Apply the same cache growth bound to LBLC.
> - Add Suggested-by: Julian Anastasov <ja@ssi.bg>.
> - v1 Link: https://lore.kernel.org/all/62790a9f94ac5318f107a1811cff5a1f2fc7e0bf.1786884824.git.zhilinz@nebusec.ai/
>  net/netfilter/ipvs/ip_vs_lblc.c  | 3 +++
>  net/netfilter/ipvs/ip_vs_lblcr.c | 3 +++
>  2 files changed, 6 insertions(+)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
> index 693bcc82ccb77..8180a7ba9f538 100644
> --- a/net/netfilter/ipvs/ip_vs_lblc.c
> +++ b/net/netfilter/ipvs/ip_vs_lblc.c
> @@ -204,6 +204,9 @@ ip_vs_lblc_new(struct ip_vs_lblc_table *tbl, const union nf_inet_addr *daddr,
>  			return en;
>  		ip_vs_lblc_del(en);
>  	}
> +	if (atomic_read(&tbl->entries) >= tbl->max_size * 3 / 2)
> +		return NULL;
> +
>  	en = kmalloc_obj(*en, GFP_ATOMIC);
>  	if (!en)
>  		return NULL;
> diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
> index f53f05ceea36f..858393b1d2d17 100644
> --- a/net/netfilter/ipvs/ip_vs_lblcr.c
> +++ b/net/netfilter/ipvs/ip_vs_lblcr.c
> @@ -363,6 +363,9 @@ ip_vs_lblcr_new(struct ip_vs_lblcr_table *tbl, const union nf_inet_addr *daddr,
>  
>  	en = ip_vs_lblcr_get(af, tbl, daddr);
>  	if (!en) {
> +		if (atomic_read(&tbl->entries) >= tbl->max_size * 3 / 2)
> +			return NULL;
> +
>  		en = kmalloc_obj(*en, GFP_ATOMIC);
>  		if (!en)
>  			return NULL;
> -- 
> 2.43.0

Regards

--
Julian Anastasov <ja@ssi.bg>

