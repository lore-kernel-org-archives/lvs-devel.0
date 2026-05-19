Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6FE4023C8C7;
	Tue, 19 May 2026 17:09:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779210560; cv=none; b=p7qqgPOekXpyP7gG8VDDpmzBiIz8qziIN+SMxxyMX4HaCUHXF5rP7A+zsCfDcNA2knzQ/DppnZ4vpVH2y7djDoJ4r0ipuZP0VOWExsCCTwQ1aDpOFcMsUMiHG1dkwHsngt757Dj1du2mOAiruTBPEErg6YgT9wFcvJ1BsdgMqfk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779210560; c=relaxed/simple;
	bh=LI1eQL9UBmdi4kNgkPA+B3M/HnlOdRPHjQ3+NXKXXDY=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=uLZ/LMK6B/D1/l3txn4gKkfq4fJQGFzk/8qWewmMP0xD0RWa476/YFVyUhNHWwS/ObQjdhn+uzJlD8eEE1hPUse3x7bUlPT8AYHCH1oppRefqzhugv2MDFjtviKae0hN8SnYEveDcYXWIs0kXSA6qLqJ74LzDk813cp6vV0KF1w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=Z/evs9Vp; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="Z/evs9Vp"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id BDDA021827;
	Tue, 19 May 2026 20:09:06 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=+n0LC3udyTK6Z34nl0HlEBNyfpkRv8c0a1fvjYDG9E4=; b=Z/evs9VpgyuV
	zzRtPxH6t1s3332ZUaxWK1mdVt27JHbINHkN6LZbYjSJGeJZx35E7O/uFSdB4fR2
	HGevwgikx62Y1kcVlfApFQqKqA2cWdpku18SSUJUFnqCG0LKwvGWX8A/nQYSi3I5
	NmqDrPHrl/TTDauu7raCCw+smypTvdnEbSxuM+VXqRuhyk79gGOF6GsFl6HZqClO
	IviLc6Fq+GZ8e1eFlL3urbB4YBCg5kFUpgOQVjNxZV5iEYaaw+5uJ6uD8ajipHU7
	3Rk/hZinKGez2UGPdNhPftGUsd7ZKxG2+09scaQ6F7ZmkxU2sESy3oQByPvCY1uK
	/9FEIZYJe6VNgdadYYUDQEy/e+NJrOgJn7SYB7xrGkcVS3nSiyI2LXXpLYiExjnM
	iRRI607XwcV9P0OJmWENC2FdTtiu+wwlg3/2paeQOKlNU3hCoAEZBOrnHpC1nd+X
	T94olYrLWVfewnd/D4+niI/ZmJXdUXYAgUmLLWPEu14W8DPZJVDuBS7mkqYqEIka
	IKMlYhE8SEnzxOO2xThDWc+2DjhGwqKhbjkqDUE0nVk8WovF7/Y87D3e3J6PtPCX
	6hulrKSi4LxAa8YL/UgjgIJsnsBhXVfunoia+0f6pSehJjur2Yz0TjlqxJY6Gey7
	8etn8FyWNA72YS7QyetWhfPfv3WW+s8=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 19 May 2026 20:09:06 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 27EE860B31;
	Tue, 19 May 2026 20:09:05 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.1) with ESMTP id 64JH8wqi052805;
	Tue, 19 May 2026 20:08:58 +0300
Date: Tue, 19 May 2026 20:08:58 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Rosen Penev <rosenp@gmail.com>
cc: netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>,
        "open list:IPVS" <netdev@vger.kernel.org>,
        "open list:IPVS" <lvs-devel@vger.kernel.org>,
        "open list:NETFILTER" <coreteam@netfilter.org>,
        open list <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] ipvs: Use flexible array for MH lookup table
In-Reply-To: <20260519015506.634185-1-rosenp@gmail.com>
Message-ID: <190213d9-f2d3-8a8a-88f7-1fd8aa8eddd8@ssi.bg>
References: <20260519015506.634185-1-rosenp@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 18 May 2026, Rosen Penev wrote:

> Store the Maglev hash lookup table in the scheduler state
> allocation instead of allocating it separately.
> 
> This keeps the lookup table tied to the RCU-freed state lifetime and
> simplifies the allocation and cleanup paths.
> 
> Assisted-by: Codex:GPT-5.5
> Signed-off-by: Rosen Penev <rosenp@gmail.com>
> ---
>  net/netfilter/ipvs/ip_vs_mh.c | 11 ++---------
>  1 file changed, 2 insertions(+), 9 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_mh.c b/net/netfilter/ipvs/ip_vs_mh.c
> index 020863047562..d31d3c6d4216 100644
> --- a/net/netfilter/ipvs/ip_vs_mh.c
> +++ b/net/netfilter/ipvs/ip_vs_mh.c
> @@ -59,11 +59,11 @@ static int primes[] = {251, 509, 1021, 2039, 4093,
>  
>  struct ip_vs_mh_state {
>  	struct rcu_head			rcu_head;
> -	struct ip_vs_mh_lookup		*lookup;
>  	struct ip_vs_mh_dest_setup	*dest_setup;
>  	hsiphash_key_t			hash1, hash2;
>  	int				gcd;
>  	int				rshift;
> +	struct ip_vs_mh_lookup		lookup[];
>  };
>  
>  static inline void generate_hash_secret(hsiphash_key_t *hash1,
> @@ -372,7 +372,6 @@ static void ip_vs_mh_state_free(struct rcu_head *head)

	We can even drop this function and replace it with
kfree(s) in ip_vs_mh_init_svc() and with kfree_rcu(s, rcu_head)
in ip_vs_mh_done_svc(), you can see ip_vs_dh.c for reference...

>  	struct ip_vs_mh_state *s;
>  
>  	s = container_of(head, struct ip_vs_mh_state, rcu_head);
> -	kfree(s->lookup);
>  	kfree(s);
>  }
>  
> @@ -382,16 +381,10 @@ static int ip_vs_mh_init_svc(struct ip_vs_service *svc)
>  	struct ip_vs_mh_state *s;
>  
>  	/* Allocate the MH table for this service */
> -	s = kzalloc_obj(*s);
> +	s = kzalloc_flex(*s, lookup, IP_VS_MH_TAB_SIZE);
>  	if (!s)
>  		return -ENOMEM;
>  
> -	s->lookup = kzalloc_objs(struct ip_vs_mh_lookup, IP_VS_MH_TAB_SIZE);
> -	if (!s->lookup) {
> -		kfree(s);
> -		return -ENOMEM;
> -	}
> -
>  	generate_hash_secret(&s->hash1, &s->hash2);
>  	s->gcd = ip_vs_mh_gcd_weight(svc);
>  	s->rshift = ip_vs_mh_shift_weight(svc, s->gcd);
> -- 
> 2.54.0

Regards

--
Julian Anastasov <ja@ssi.bg>

