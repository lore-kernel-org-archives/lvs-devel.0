Received: from mail-lj1-f182.google.com (mail-lj1-f182.google.com [209.85.208.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6EDC32336BD
	for <lvs-devel@vger.kernel.org>; Wed, 11 Dec 2024 13:53:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.182
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1733925222; cv=none; b=TMIG/SIfCjHaMF6K3oJrkhTdrS0OSmMSkXm8bbypeGWDOTl7J51x5gO+7iNfg/wEOo3bVogt8URjQCM0gcZUOqlIr+GMIfP6b4Dnqz0Itko4R3AdZwIQFNJmwo/zZkRdCNA3zj3nTarzra428JBs9Zjx0ik/3nwe0KJd6Fcivrs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1733925222; c=relaxed/simple;
	bh=1ler+6t5wwhzmcNaLGwLWs8a2MX4ASG3Zvx3gT94VPY=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=Q8SjtTDdjnhewbTLN711qeA68+Jce5IU3zmTgzR8R7pQ2+zjKM47XiAg6iqXeNNLLGW6s3Pfxt8RW1YtqX9FfeNbQNHAwQMTs7e91L1qyzVjAA2JbvfoJmpHX2AubBDcPg3QRJEQwavIlL7tFjIzsCy+vmWGW+U5lNMEvmlX/xk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=bgdev.pl; spf=none smtp.mailfrom=bgdev.pl; dkim=pass (2048-bit key) header.d=bgdev-pl.20230601.gappssmtp.com header.i=@bgdev-pl.20230601.gappssmtp.com header.b=omDj3KJs; arc=none smtp.client-ip=209.85.208.182
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=bgdev.pl
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bgdev.pl
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=bgdev-pl.20230601.gappssmtp.com header.i=@bgdev-pl.20230601.gappssmtp.com header.b="omDj3KJs"
Received: by mail-lj1-f182.google.com with SMTP id 38308e7fff4ca-30229d5b229so26492931fa.0
        for <lvs-devel@vger.kernel.org>; Wed, 11 Dec 2024 05:53:40 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=bgdev-pl.20230601.gappssmtp.com; s=20230601; t=1733925218; x=1734530018; darn=vger.kernel.org;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=jyglwL7lcLajD1vfvAC6TyqBHbq3YqYRZog/vZd+lPo=;
        b=omDj3KJsPkdP7UDkEBkr8I8BmUFjLlncQnR8U1KHRmWs4eX2Od9WNA0Ge1slgLs74D
         hYp6a4U1CyacZbInWvPD/TL56ag2IN1BQUOKGZ24bAQo1knFloHJGpw6RLyKLgMI/Ich
         FQ/eIr5U5m601YqwpLL3O61FD+9kURKiEawOMu3v9ORmtUW1sFkB3D9mopTziG+ajVix
         8e0RXBaq3HeM/bK2ndvdwgZ4lgGxZ7oVSqCK3Y6ZlazYDPlzbcUJuk9BnvualA6K12vy
         36remNoOn6ih/pluAhyQBzIt1XF6dN0GBvAskyEvdi7SBuoKVEa+r0ga5WUGsgSibr6l
         nCRA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1733925218; x=1734530018;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=jyglwL7lcLajD1vfvAC6TyqBHbq3YqYRZog/vZd+lPo=;
        b=f8AdOA6np6WBd+Rj4YvqU1KJBy04i4RWrraOifFSAhqAhh/7k28+co1PVK0XsJepYG
         rz4uxzsbUAod5ACVCb6CJluFXUndnUqazWVyNauHAJ4jZk6XPPDqoZWBBvArbVUDkiqy
         eMP/yEpMpbyGXkPD5uo7+EI9O3nk2K7dL49h2ObnXYogngYogYt5T50Qn7SDAnDjtf58
         IJxpArupOqZ5AWizPQzTsI68NOceoNlR5TSYj4GBiuPAOdVcO4sd0t8gacPF5+7PUsfT
         aqT3zzXK+/BGR0ElU5rwD/XCS3Gx1D3NZOOFJS2OtF0kgqEZl6bzXVvfRKECk8S2G+0L
         27Eg==
X-Forwarded-Encrypted: i=1; AJvYcCU/v4eQMTqufc+v1GE5EMcb5646BchOcgDkVkShwFu2yVk6p59ul8yjh+HfnSn0kt5nnVeIZCKxub8=@vger.kernel.org
X-Gm-Message-State: AOJu0YwpZZG/Da+fQZfqzLLeLkjmmYYv8sZyYGySxOXD1VLGrGSm6VLW
	EslGN9ubMgccDEsEN+sghHhWNkDQ02l1O6dErdZfRnTTfAyPWcWfxhHBHm2N5qupSnZUjWkLvoR
	MGIWUfEqNPrclizcLOpXjNnx8AG7/Wrv3UjWsww==
X-Gm-Gg: ASbGncuoJ1rXbBWo9U3p6SabifZvoFHhc4c7tVhWg9oi67SHTd7kyMg9cARthue5J9I
	lv4M+Uy2JdyyQJTnhmQo/sgbypaT0gZR1losUYO8dua8k6PXgK2N/RJ65KJRhvhMAaz4=
X-Google-Smtp-Source: AGHT+IGPGpFba0wsi4op1Gj+i5/QGCDpVBGPrx3rA3uLS79Kse28wu78qqyJ+hwtxlmidsvWthwfkHUhBW/gtPRZ2IA=
X-Received: by 2002:a05:651c:1542:b0:300:33b1:f0d7 with SMTP id
 38308e7fff4ca-30240c9fc57mr9357831fa.5.1733925218339; Wed, 11 Dec 2024
 05:53:38 -0800 (PST)
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <1e0cf09d-406f-4b66-8ff5-25ddc2345e54@stanley.mountain>
In-Reply-To: <1e0cf09d-406f-4b66-8ff5-25ddc2345e54@stanley.mountain>
From: Bartosz Golaszewski <brgl@bgdev.pl>
Date: Wed, 11 Dec 2024 14:53:27 +0100
Message-ID: <CAMRc=McCc3G4D4rHVMfGBTdvi6z5Nbxqzg+k8iN11+vazffSnw@mail.gmail.com>
Subject: Re: [PATCH net] ipvs: Fix clamp() order in ip_vs_conn_init()
To: Dan Carpenter <dan.carpenter@linaro.org>
Cc: Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, 
	Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, 
	"David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, 
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org, 
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, 
	coreteam@netfilter.org, linux-kernel@vger.kernel.org, 
	David Laight <David.Laight@aculab.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 11, 2024 at 2:16=E2=80=AFPM Dan Carpenter <dan.carpenter@linaro=
.org> wrote:
>
> We recently added some build time asserts to detect incorrect calls to
> clamp and it detected this bug which breaks the build.  The variable
> in this clamp is "max_avail" and it should be the first argument.  The
> code currently is the equivalent to max =3D max(max_avail, max).
>
> Reported-by: Linux Kernel Functional Testing <lkft@linaro.org>
> Closes: https://lore.kernel.org/all/CA+G9fYsT34UkGFKxus63H6UVpYi5GRZkezT9=
MRLfAbM3f6ke0g@mail.gmail.com/
> Fixes: 4f325e26277b ("ipvs: dynamically limit the connection hash table")
> Signed-off-by: Dan Carpenter <dan.carpenter@linaro.org>
> ---
> I've been trying to add stable CC's to my commits but I'm not sure the
> netdev policy on this.  Do you prefer to add them yourself?
>
>  net/netfilter/ipvs/ip_vs_conn.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_c=
onn.c
> index 98d7dbe3d787..9f75ac801301 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -1495,7 +1495,7 @@ int __init ip_vs_conn_init(void)
>         max_avail -=3D 2;         /* ~4 in hash row */
>         max_avail -=3D 1;         /* IPVS up to 1/2 of mem */
>         max_avail -=3D order_base_2(sizeof(struct ip_vs_conn));
> -       max =3D clamp(max, min, max_avail);
> +       max =3D clamp(max_avail, min, max);
>         ip_vs_conn_tab_bits =3D clamp_val(ip_vs_conn_tab_bits, min, max);
>         ip_vs_conn_tab_size =3D 1 << ip_vs_conn_tab_bits;
>         ip_vs_conn_tab_mask =3D ip_vs_conn_tab_size - 1;
> --
> 2.45.2
>

Tested-by: Bartosz Golaszewski <bartosz.golaszewski@linaro.org>
Reviewed-by: Bartosz Golaszewski <bartosz.golaszewski@linaro.org>
