Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2BD922C325C;
	Wed, 22 Jul 2026 10:23:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784715794; cv=none; b=HK1X+MKdQW8ik8CPN1HhHNN09BsYJkrHjmE/RlO1uWNbtz2qW2OST1irQzVBv2enBhu7GJqD2HXKUZGnQIo5EoDxD7xPnR4V2Jd7h3pHWxvPtcRITgr20RamlwUtYkQfiAp95vAmKHggmpLNyBcdHwNL4l6iQgu62heo51nafOU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784715794; c=relaxed/simple;
	bh=ExHwgVLtll9aMIzB8eJHAbcug99jAA//vF+V3yHJwq8=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=uFc5tAqtqkKIh+mYtSAfLwQKyyhixgfonBJEgOOxUONAp7xqz5dgFy/ZAQSPaxTQFtPXv7v43KPERjK0eLcwfMaGq+U0fTsDMC/1znLt5c/dqDkcVdhVQWAAzg4jA/hiCVXlnmbaePdklrfFLTVK/bOfAwZnKghGdhcjUBRIUQc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=VmNNtbW7; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="VmNNtbW7"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 033F32150E;
	Wed, 22 Jul 2026 13:23:10 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=yVOFNA4066QDbQHivrhnPklaovhzm1qPytXmlxUK2AU=; b=VmNNtbW7DphN
	JVJE8aZbG5ZNGF6cAKjAPdv1mB0cunVJPIqTx/hHAu6WS46jqZ0NsQOpBFqIUDiw
	63O6EC2IKhcQ7AXhzY0qvT65EiBVYwwb/RoFfnV8UBE8tEfXoS5Ks7aBU8uBvPIa
	rdlyNDVqoUMl26Klr+dsUP21xjNB/LuQ35WK+CfQGfpwONIdgt6965f/LX2Zvu5M
	jIZ2/Om01p0RqN2TG86132WKQLsdn9vCEOLRJ0yt6zfSVPapyu5i8sanm1DVWe/w
	fXCIXwxdqlmDugzKHqS7zn1PUrxIio33WC8XK/ZJJam0GK54NU82wR43B9t+mZQq
	sTaw5BiGd5gr/BGnXZi9deb0/ewyhPogPXZlIC+jfegaIGjwnaGlg0Rovf2LgmBn
	bfPiBd9ChYLXWk1ZB0eezl15HiCcNwLTBDF30kpDZQUJ5njceq+a+GLddomJ/UsZ
	cTsW3DYrsGxCucOjgOauBkvjj+92HQ8r9tGITPf6SZOKHUAVfADSdss+fBnwwLtc
	X7Vq9rJai/gm8t3HoSw5wmFPUj2mpiow13qkot8WJJ0UPTCLso8aaeUTg3a8QDmP
	uv+Nr5M6bI9JL/1pA4Wwp+PN/ftN31lhHOtTOK0fmYFlcowqxmrHxz7bRNeE0Un6
	FEbcrj047qRk3P33Wsw+XLmK7c46xbw=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 22 Jul 2026 13:23:09 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 1F0F160400;
	Wed, 22 Jul 2026 13:23:10 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 66MAN4Gr037332;
	Wed, 22 Jul 2026 13:23:05 +0300
Date: Wed, 22 Jul 2026 13:23:04 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Subasri S <subasris1210@gmail.com>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>,
        netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH nf-next] ipvs: use type-safe allocation helpers in
 ip_vs_rht_alloc
In-Reply-To: <20260716-nf-next-ipvs-deprecated-v1-1-4aad24f87cb8@gmail.com>
Message-ID: <67f5b073-f410-1191-2723-d859bdac8915@ssi.bg>
References: <20260716-nf-next-ipvs-deprecated-v1-1-4aad24f87cb8@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Thu, 16 Jul 2026, Subasri S wrote:

> As per Documentation/process/deprecated.rst, open-coded kmalloc
> assignments for struct objects are deprecated. Replace
> kzalloc(sizeof(*ptr), GFP_KERNEL) with kzalloc_obj() and
> kvmalloc_array(n, sizeof(*ptr), GFP_KERNEL) with kvmalloc_objs()
> in ip_vs_rht_alloc().
> 
> Compile tested with CONFIG_IP_VS=y and runtime tested using
> tools/testing/selftests/net/netfilter/ipvs.sh on x86_64/QEMU.
> 
> Signed-off-by: Subasri S <subasris1210@gmail.com>

	Looks good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_core.c | 9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index 35cbe821c259..74047bf1e32d 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -176,7 +176,7 @@ void ip_vs_rht_rcu_free(struct rcu_head *head)
>  
>  struct ip_vs_rht *ip_vs_rht_alloc(int buckets, int scounts, int locks)
>  {
> -	struct ip_vs_rht *t = kzalloc(sizeof(*t), GFP_KERNEL);
> +	struct ip_vs_rht *t = kzalloc_obj(*t);
>  	int i;
>  
>  	if (!t)
> @@ -186,7 +186,7 @@ struct ip_vs_rht *ip_vs_rht_alloc(int buckets, int scounts, int locks)
>  
>  		scounts = min(scounts, buckets);
>  		scounts = min(scounts, ml);
> -		t->seqc = kvmalloc_array(scounts, sizeof(*t->seqc), GFP_KERNEL);
> +		t->seqc = kvmalloc_objs(*t->seqc, scounts);
>  		if (!t->seqc)
>  			goto err;
>  		for (i = 0; i < scounts; i++)
> @@ -194,8 +194,7 @@ struct ip_vs_rht *ip_vs_rht_alloc(int buckets, int scounts, int locks)
>  
>  		if (locks) {
>  			locks = min(locks, scounts);
> -			t->lock = kvmalloc_array(locks, sizeof(*t->lock),
> -						 GFP_KERNEL);
> +			t->lock = kvmalloc_objs(*t->lock, locks);
>  			if (!t->lock)
>  				goto err;
>  			for (i = 0; i < locks; i++)
> @@ -203,7 +202,7 @@ struct ip_vs_rht *ip_vs_rht_alloc(int buckets, int scounts, int locks)
>  		}
>  	}
>  
> -	t->buckets = kvmalloc_array(buckets, sizeof(*t->buckets), GFP_KERNEL);
> +	t->buckets = kvmalloc_objs(*t->buckets, buckets);
>  	if (!t->buckets)
>  		goto err;
>  	for (i = 0; i < buckets; i++)
> 
> ---
> base-commit: f6f3b36c15ed44de1fbb44e645e4fae8c4a4453e
> change-id: 20260714-nf-next-ipvs-deprecated-232667142d84
> 
> Best regards,
> -- 
> Subasri S <subasris1210@gmail.com>

Regards

--
Julian Anastasov <ja@ssi.bg>

