Received: from mail-wm1-f42.google.com (mail-wm1-f42.google.com [209.85.128.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 590971D95AA
	for <lvs-devel@vger.kernel.org>; Wed, 11 Dec 2024 15:56:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1733932620; cv=none; b=iLKi92uGhxHTus0+Gxyef2JIPClBQHeRZzCBmXXRGyQzkC6tmBGDw6MHDfBfPE7Uqn8bgs2I3J+2MS1xpb4iNGOLF9VMajLal1VL8fYSpNIi8wxcnOZNlH9iA6o8di3JCmXO+/50udcoi7PCmU7xV2lvd2O6m+/53224/TE/tl8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1733932620; c=relaxed/simple;
	bh=Rv+K7hKMlEcxfuBPqiseeoq83C5g31oqxKPW9FfS0H8=;
	h=Date:From:To:Cc:Subject:Message-ID:MIME-Version:Content-Type:
	 Content-Disposition; b=Q8sk4SET8/6IKYFCshIEficqBuykfxkL0ZDaE31xS8Uf/FJQZLDWfwqysw/dY6yH0KyBobpxhu1Q3ICEO0GzR8/QETf4MgCLlSvXvy1ZKE7r4V/U/MagKNQdPzB8XkOQhfrx2dlTSaVjyAjFeHnhY23k0Aw4km2hFzmkvl3oAnM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linaro.org; spf=pass smtp.mailfrom=linaro.org; dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b=cVqfmndc; arc=none smtp.client-ip=209.85.128.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linaro.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linaro.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="cVqfmndc"
Received: by mail-wm1-f42.google.com with SMTP id 5b1f17b1804b1-4361ecebc4dso5041655e9.0
        for <lvs-devel@vger.kernel.org>; Wed, 11 Dec 2024 07:56:58 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google; t=1733932617; x=1734537417; darn=vger.kernel.org;
        h=content-disposition:mime-version:message-id:subject:cc:to:from:date
         :from:to:cc:subject:date:message-id:reply-to;
        bh=nkg3+gqCHZyZ6Sl2qTzJB3+MN185d7FZdzLmb7C7pz0=;
        b=cVqfmndcU8ORqb/WAs3hyt8lTr4dUf+4XymZz6uPD/WxWt8yHla3SV8YlD0CU6a4Gy
         3TpqlHJOfkOj4V3RMYw1FKEtzg1zGBg14Ii7subePb5KL3GWfBuCNVaIOzkJ0ge9xh6a
         6yEV9b6z9jRLIEzdSQFx56dn/7bq5KAGWechEwBvG7MW9yPpwhfjdUrcZTE+KWYrg1W0
         VY4fHsKfaw89qhDLaXDa3vkCvrkaIXF5DGLvRTtTAqspKxZz/feNwrfL76YlmX84WepO
         kFi1NUhB6srZ/IuzW+ObeXZ+EGgjerXDDcTEn2DcObGEY1miOIFJ9G6fuuAE183gQ0ry
         Hz0g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1733932617; x=1734537417;
        h=content-disposition:mime-version:message-id:subject:cc:to:from:date
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=nkg3+gqCHZyZ6Sl2qTzJB3+MN185d7FZdzLmb7C7pz0=;
        b=ngGNPPfj9nOhkd/vkdQHu3J6qpG7rxLnrnOOX5omfL6yhb/BBFw63QSgX2ZIwMmBUi
         5cvEptioPOmHm7dSFa9wFiG/1BJHoPpxn8P+VP3LmDqxwVybyXyTLrC7wmmHk0jktuA6
         azHrT2/Rbj2eWTMM8D5/0K0WkoEQypRdOGxF9+WygpkplNOrGE5N2UTwiqeltpbb4YR2
         FtsFnbwbqBaNIh1ETwwj+nmAMRvQm8qpYMeLLe0VoOakC8qj32AmIpgH+Hd6GHRvgA5w
         G4A+wGVojOCk2WC3jVy0t4L6HFVLcAz9b+4zmppfIZSFKpgOGaTNiWZjkNTq0GeXO97E
         ovXg==
X-Forwarded-Encrypted: i=1; AJvYcCVZUpMOd5XU+BWHKO+3FRVdYPa+4N4pgvbsjKYSrc2VlOoI/thLD20VUoEKlTYS5rzg+Yyuc10WlaQ=@vger.kernel.org
X-Gm-Message-State: AOJu0YzK/+g+w6FxLu278BoMTn1b9Oz/KeNKD6I1GogzEC4tis8oyWPl
	ekR8Dv0chaNjyz6PbKEXcqXiyp9neNFD0+4aL+/xdc34ppOgPxu7Re+m+CU1mxQ=
X-Gm-Gg: ASbGnctqCUn0f58lKZCgcRiDauS5F/uLXwxX+crUGg+0SCS0BCQVnxzb7XUmCfPhc3U
	VMVUkVwIsFmu6pzC+/xCIfWfBzTZ2OBQTGeciqMyaXo+eA232eFQm5WwYI0quP7Q1D/l2pVhMyM
	iwMtfNV5KUecVmJbWv5m0xx2iuu6DL3q8EMOFvb+lwr1pwrhk0SeSLfImmxeYW8nM9/PMVSIYGu
	5EaYm8XABeuvwpOsS2cp9hH+aBJRnegg7gQedBparPEL0OhCvFMKnoTGAw=
X-Google-Smtp-Source: AGHT+IHswNBtDtvurvta3UIe1snbeW4EpMGUksBi4IExyjMEcI6lUxkxBWzCbW9NdBKAwxVrirF4eA==
X-Received: by 2002:a05:600c:3541:b0:431:93dd:8e77 with SMTP id 5b1f17b1804b1-4362286bc7bmr2392765e9.31.1733932616850;
        Wed, 11 Dec 2024 07:56:56 -0800 (PST)
Received: from localhost ([196.207.164.177])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-38782514ec8sm1598464f8f.75.2024.12.11.07.56.55
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 11 Dec 2024 07:56:56 -0800 (PST)
Date: Wed, 11 Dec 2024 18:56:53 +0300
From: Dan Carpenter <dan.carpenter@linaro.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@netfilter.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	linux-kernel@vger.kernel.org, Bartosz Golaszewski <brgl@bgdev.pl>,
	David Laight <David.Laight@aculab.com>
Subject: [PATCH v2 net] ipvs: Fix clamp() order in ip_vs_conn_init()
Message-ID: <Z1m2RVCy-lkXdDUa@stanley.mountain>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

We recently added some build time asserts to detect incorrect calls to
clamp and it detected this bug which breaks the build.  The variable
in this clamp is "max_avail" and it should be the first argument.  The
code currently is the equivalent to max = min(max_avail, max).

There probably aren't very many systems out there where we actually can
hit the minimum value so this doesn't affect runtime for most people.

Reported-by: Linux Kernel Functional Testing <lkft@linaro.org>
Closes: https://lore.kernel.org/all/CA+G9fYsT34UkGFKxus63H6UVpYi5GRZkezT9MRLfAbM3f6ke0g@mail.gmail.com/
Suggested-by: David Laight <David.Laight@ACULAB.COM>
Fixes: 4f325e26277b ("ipvs: dynamically limit the connection hash table")
Signed-off-by: Dan Carpenter <dan.carpenter@linaro.org>
Tested-by: Bartosz Golaszewski <bartosz.golaszewski@linaro.org>
Reviewed-by: Bartosz Golaszewski <bartosz.golaszewski@linaro.org>
---
v2: In the commit message, I said max() but it should have been min().
    I added a note that this bug probably doesn't affect too many
    people in real life.  I also added David Laight as a Suggested-by
    because he did all the work root causing this bug and he already
    sent a similar patch last week.

    Added Bartosz's tested by tags.

 net/netfilter/ipvs/ip_vs_conn.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 98d7dbe3d787..9f75ac801301 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1495,7 +1495,7 @@ int __init ip_vs_conn_init(void)
 	max_avail -= 2;		/* ~4 in hash row */
 	max_avail -= 1;		/* IPVS up to 1/2 of mem */
 	max_avail -= order_base_2(sizeof(struct ip_vs_conn));
-	max = clamp(max, min, max_avail);
+	max = clamp(max_avail, min, max);
 	ip_vs_conn_tab_bits = clamp_val(ip_vs_conn_tab_bits, min, max);
 	ip_vs_conn_tab_size = 1 << ip_vs_conn_tab_bits;
 	ip_vs_conn_tab_mask = ip_vs_conn_tab_size - 1;
-- 
2.45.2
