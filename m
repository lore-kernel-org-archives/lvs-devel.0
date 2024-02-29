Received: from mail-ej1-f51.google.com (mail-ej1-f51.google.com [209.85.218.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4456879F1
	for <lvs-devel@vger.kernel.org>; Thu, 29 Feb 2024 18:38:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.218.51
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1709231896; cv=none; b=MO9BSHpUKYGkHkF36ZNGnUi5a1yx8rQ9bBCqeETljVlcj1CQc06OAsvKXmOzBTkiObyMJ+kiclaYY/h97Xlvz8qHXF5WdTkDCMY+dcb261lCW/86FeL0tzjFPGNa9FFvIDYlz2W42jxUVQi6B9yyInUcHIta4TAlfFNjhhhc4UI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1709231896; c=relaxed/simple;
	bh=PgYQgIh/+KvNsPuseTkA2lB8InRhKLTlmDogJoVNi7w=;
	h=From:To:Cc:Subject:In-Reply-To:References:Date:Message-ID:
	 MIME-Version:Content-Type; b=pEt0Vg1YFKCe+j9d50uHANCPvUuslwj0YWya71DOwUR1XP1WTtxkgcbmEdpsEJlFYD+hUjNSCvXuAssG4Pl5HNwu7wu0QsORYO6k5BZps8N9decO2PRAvkPJ9WCJtnaeYvroRJWKZnaL9hjV5HSzra2C8sw3iFJ/KHs2k6Hyvro=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=cloudflare.com; spf=pass smtp.mailfrom=cloudflare.com; dkim=pass (2048-bit key) header.d=cloudflare.com header.i=@cloudflare.com header.b=XvAcN2El; arc=none smtp.client-ip=209.85.218.51
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=cloudflare.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=cloudflare.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=cloudflare.com header.i=@cloudflare.com header.b="XvAcN2El"
Received: by mail-ej1-f51.google.com with SMTP id a640c23a62f3a-a3122b70439so228494566b.3
        for <lvs-devel@vger.kernel.org>; Thu, 29 Feb 2024 10:38:14 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cloudflare.com; s=google09082023; t=1709231893; x=1709836693; darn=vger.kernel.org;
        h=mime-version:user-agent:message-id:date:references:in-reply-to
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=PgYQgIh/+KvNsPuseTkA2lB8InRhKLTlmDogJoVNi7w=;
        b=XvAcN2El5KxCJHnXDpi0C4b2TJv+tSE12S21f/TKBRiDIp1S41qhxgv1q0kiIbGFX5
         islZNOY973/xuEjNRFfhfLw09Vm8kFlWH4ECo175B4vgikc+GgQ/yXqQZ0WccfXwIcrz
         yIIFAjpUhCKJBWDSEumIyS+LA94m9OhXCXdVC1vfVPVcq4dBCV4sNbJZK4CMH3acieg6
         w0nO4pnSQDbEhd6ENagY0wpeHCUKwTuSqJpJ2kXLaDeCiL0wXXkZiuLR3BWcic5EEyri
         I8XPCnLYiQoQ8OUrfedLrSBA3UbbWPZITQofM33t2zWz8kWAoA4j0ELqoJ0xfXsqE2aj
         oZDQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1709231893; x=1709836693;
        h=mime-version:user-agent:message-id:date:references:in-reply-to
         :subject:cc:to:from:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=PgYQgIh/+KvNsPuseTkA2lB8InRhKLTlmDogJoVNi7w=;
        b=M8nUUauVTKTyUC/xULScW/xF4qn6UwdQdRC5BKPlyCuEiRRmXUsLDGPO9UGDedCsB2
         8/ed2ER4eTwBj7tH910KNIecd6obwTScSvqvh99ehic9rx19QYgGMlOV5nbjOMRGtT9Q
         c58mFJ4ip6GdGjyck24thP8mWqJU2OPDBvRuIX3YWP8zHZxdHgeuMpUHKU2ot3omJlnu
         kw0NpCeLmERxW25Xb1Eig+baldlj2htoaQB9MabTnbV40gII1KfzbdXPQVv/z/rqLl+Q
         aBSvBl51waYozZIFAER/5rOjy4A2rU3Z5oalVJBFBHnshn45bRcmRYYaAH4WlBuBooH6
         fO9w==
X-Forwarded-Encrypted: i=1; AJvYcCX36P38flUDylpOv6BVbtOh5/fdG/6sm5Vtjz9BsFcboSHPxKlNExuCh6hRoHiLjVHRwT2Th0zePruCrG8RMHWj3Nn4RmKMFjf5
X-Gm-Message-State: AOJu0YybCr5RZqic/Hmpr1K6GL5eVBM9he/sA0734Ex5OkADHBBQjCSC
	1vLqmIPiQr7fmyXFwiPubnH1JyhrpE48k0W4fxW7pvs7QxPzhmR9zga9lpj9ePs=
X-Google-Smtp-Source: AGHT+IHB+P6Jrz2R2o9akkLJe1SQR4BKVRZN+/IcYmRI4yBGEvo/TJiBaq6+e8PlRTNuZozbkAkbIg==
X-Received: by 2002:a17:906:ca49:b0:a44:1be1:66f0 with SMTP id jx9-20020a170906ca4900b00a441be166f0mr2056354ejb.57.1709231893636;
        Thu, 29 Feb 2024 10:38:13 -0800 (PST)
Received: from localhost ([2a09:bac5:4e26:15cd::22c:19])
        by smtp.gmail.com with ESMTPSA id vh4-20020a170907d38400b00a441e6669aesm932683ejc.5.2024.02.29.10.38.13
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Feb 2024 10:38:13 -0800 (PST)
From: Terin Stock <terin@cloudflare.com>
To: Julian Anastasov <ja@ssi.bg>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,  Terin Stock
 <terin@cloudflare.com>,  horms@verge.net.au,  kadlec@netfilter.org,
  fw@strlen.de,  netfilter-devel@vger.kernel.org,
  lvs-devel@vger.kernel.org,  kernel-team@cloudflare.com
Subject: Re: [PATCH] ipvs: generic netlink multicast event group
In-Reply-To: <ca382b0a-737c-e903-270b-7ec98549ecae@ssi.bg> (Julian Anastasov's
	message of "Thu, 29 Feb 2024 19:56:01 +0200 (EET)")
References: <20240205192828.187494-1-terin@cloudflare.com>
	<51c680c7-660a-329f-8c55-31b91c8357fd@ssi.bg> <ZeCy39VOYVB_r5bP@calendula>
	<ca382b0a-737c-e903-270b-7ec98549ecae@ssi.bg>
Date: Thu, 29 Feb 2024 18:38:12 +0000
Message-ID: <87msrjktez.fsf@gmail.com>
User-Agent: Gnus/5.13 (Gnus v5.13)
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain


Thanks, I'll work on implementing these suggestions in a v2 patch.
