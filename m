Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793214948;
	b=V4NF+ibM34pNF4doUWx6t8FCRD7lIK9e8mjaPuMMMl0nhLSLY55yojQ5sA4iwWLjwE10
	 kYn4JRPLXlRKWnS7Vy2on9M5WW9k9ehZmlU7HvbqP2sbmJLWVVhcvrkdnSo+LDS0JVQ89
	 lo2f2b9ccLEgNdw59U4XGGmGdntwcRTbl7D39O2PJYCAXZSvatX8zJpWtaJ5zFSeYepb1
	 sTqCaT0QHydXb4m/flS1JKA/OF2HZ546Vibo/70ui8gA400pbpzvIZMtGP7OVf2OKc61H
	 auTcYX9t5VKFRU667855cNgmM0Nyj2H7qEHzt9uGPV3Tp81JVTT4Z/Pn/+cJNsWi5mQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793214948;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=blfPghdZI13T3uCclhGxzMQPkTNJyMCZwHiprQpcXKc=;
	b=lbJZw3JqHbNMwVqTaSqHnLctM6T3ceinQecD2MImKZZ87vAhHGeEcKKz1cqOcTZUOuNS
	 FABkCzPeSo7CiqAgJ4aQgqSFOCvaGty2mkztd9sY176XZc+DH6WTmr6610kMyfOk0UnU1
	 8UjAgqGWyTalUcGIoDQv2forzUcrT9JJ504vEJm3BlTjeqY0bVylBtrD3uUVW3BfwEjmI
	 eaR/UlxVIBvl7z4mrL1EJe7ogI69m/V6W+x7hP/TwOUdNEvM5uxd1lFe38+tDFJ1nL/9I
	 LeI6CnPbLiUy2IIG+7sA4JPvlhg/A8Azrj/KcNzjlM7N646DRBrCI0Nkk6/fgv8t61w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=Q1UabqJZ;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 55AA7606A324;
	Wed, 28 Oct 2026 19:15:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 55AA7606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=Q1UabqJZ
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 0DFDF21F6D;
	Wed, 28 Oct 2026 21:15:43 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=blfPghdZI13T3uCclhGxzMQPkTNJyMCZwHiprQpcXKc=; b=Q1UabqJZYWB6
	rR/qW5A6C8gHy2zdDxxoRuUmNhzwBJ3k7YLNGeo6D3RE88XT0mvENLa+FKxvJY1A
	1fk0CgJqXvolBR/wzJ5eSm+zvI9YltEWfM9CS0DZLrnd1GMinP8E2xqBi7tCaDT8
	+ovBrfo6/ejTUfNfBA1vjR82YwVWS06c1YjoFvZ4f/ZXLdT5zPfoVq9jAkrbWLuh
	ugebE9Mv8WOXfGTirMWj4zMO37kaqVQy3TMTL4NYoipGZOJWZImm/oZY2ts2HQCn
	AFaI07i9jxL/4MtV78KAGScBEPDg0L9b2ZEtp1D1Q3XNJ/fojX4Gl9V4acDg0h8G
	dxXMb9fxfWa7IPenBkerY23ykBM3Y0j+VlRBUCScD5HFctSLkRGSgWKwZzisTG2u
	1Ff6isz7DNJ5mr+yc0fKNS1ScO0a7CjJIqLF06BZ9wTW4j+wQrfYLZAWc0uahxJ8
	lgijjtljAwgKv15hmRNu2fnd8aflYf2mnk0/qwi6i3XpJFJcHn/hZ/x6V6wdtXDu
	Mbgq4kL1b4KIed5ub+DN9bjEFaAjKv4JpQCbuzngqrwoEJJ1oDHPmFx8bkAqy8Ek
	sbgFJiww11H0WNMdhH8H3B43xya8kl23i6EPHZgRuuSXqrHB4IcsjxJ0D06stylM
	dRv+QGvLih44JabwHQS5XuUI3H95Axo=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 28 Oct 2026 21:15:42 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 68FC06044D;
	Wed, 28 Oct 2026 21:15:42 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 69SJFYVC057702;
	Wed, 28 Oct 2026 21:15:35 +0200
Date: Wed, 28 Oct 2026 21:15:34 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Linkui Xiao <xiaolinkui@126.com>
cc: horms@verge.net.au, dsahern@kernel.org, idosch@nvidia.com,
        davem@davemloft.net, edumazet@kernel.org, kuba@kernel.org,
        pabeni@redhat.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        linux-kernel@vger.kernel.org, Linkui Xiao <xiaolinkui@kylinos.cn>
Subject: Re: [PATCH net-next] ipvs: annotate the lockless read of
 sysctl_sync_threshold[0]
In-Reply-To: <20261026083708.617278-1-xiaolinkui@126.com>
Message-ID: <45d598e6-3625-0879-59b0-51f649ebe509@ssi.bg>
References: <20261026083708.617278-1-xiaolinkui@126.com>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 26 Oct 2026, Linkui Xiao wrote:

> From: Linkui Xiao <xiaolinkui@kylinos.cn>
> 
> sysctl_sync_threshold() reads ipvs->sysctl_sync_threshold[0] from the
> packet path without any synchronization: ip_vs_sync_conn_needed(),
> ip_vs_sync_conn_v0() and ip_vs_sync_conn() run in softirq context on
> behalf of ip_vs_in_hook(), ip_vs_conn_expire() is a timer callback and
> ip_vs_proc_conn() runs in the backup sync kthread. The only writer,
> proc_do_sync_threshold(), updates the array with a plain memcpy() while
> holding ipvs->sync_mutex, a mutex none of the readers ever take.
> 
> Commit 749c42b620a9 ("ipvs: reduce sync rate with time thresholds")
> already recognized this race, but only for the second element of the
> array: "As the sysctl_sync_period now can be 0 use ACCESS_ONCE to avoid
> division by zero". sysctl_sync_threshold() was left with a plain access
> even though both elements live in the same array and are written by the
> same memcpy().

	Yes, ACCESS_ONCE was used to solve possible division-by-zero 
problem, not to solve the data race. Even if memcpy is converted
to 2 int copies on some archs (eg. x86) may be it is time to use
2 WRITE_ONCE instead of the last memcpy. Can you include this
change in v2. Post it when net-next opens again by using nf-next tag.

> A stale value is not dangerous here: the element is only compared
> against a packet counter and stored into cp->in_pkts, and an aligned int
> cannot tear on any supported architecture. What the missing annotation
> does allow is for the compiler to reload the element, so the two
> comparisons in ip_vs_sync_conn_needed() can observe different values
> for one and the same packet, and KCSAN reports the unsynchronized
> access.
> 
> Read the element once with READ_ONCE(), exactly like the adjacent
> sysctl_sync_period() has done since 749c42b620a9.
> 
> Fixes: 749c42b620a9 ("ipvs: reduce sync rate with time thresholds")
> Signed-off-by: Linkui Xiao <xiaolinkui@kylinos.cn>
> ---
>  include/net/ip_vs.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 9a83bff32569..5aa6a94ed104 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -1353,7 +1353,7 @@ static inline int sysctl_conn_max(struct netns_ipvs *ipvs)
>  
>  static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
>  {
> -	return ipvs->sysctl_sync_threshold[0];
> +	return READ_ONCE(ipvs->sysctl_sync_threshold[0]);
>  }
>  
>  static inline int sysctl_sync_period(struct netns_ipvs *ipvs)
> -- 
> 2.25.1

Regards

--
Julian Anastasov <ja@ssi.bg>

