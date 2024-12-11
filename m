Received: from mail-wm1-f49.google.com (mail-wm1-f49.google.com [209.85.128.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4E6E5225A5F
	for <lvs-devel@vger.kernel.org>; Wed, 11 Dec 2024 13:16:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.49
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1733922998; cv=none; b=HdaIWKmQgMb5bImrQxoJf+WfRfOSKPSOc1En+xsV3o7RIwTObNfzI1YkgeX1rKH3qSE+dNUK1jp2p5ZN/18raK9d1fKOtMcdETWQA/UPKmylnTiKLEWC4ek+o1DJQknbmT6vYrp5A1BDMYlJfKeOSBpyFDXQbqVxMxQDtYBcXOs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1733922998; c=relaxed/simple;
	bh=vHnOqrE9U3DzgtMQ2aewHIsU1Cqb1sBnG7bs/0nghbw=;
	h=Date:From:To:Cc:Subject:Message-ID:MIME-Version:Content-Type:
	 Content-Disposition; b=S+MeWwacsGU0Zxds1uuQSI19LazF7I8MRoxZ14BFTabf3do6qm4k+EtVI3v9uGsMmttn93sURdJ5VbvCiIMrwbwl2yLnvT9hsQ5irsgNVlq7RaYKlQR0FutrYQBq/E69gi3gbzGxHaqpqJTuiGLoqi2bdlPUOOeAhhnRw89mI3c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linaro.org; spf=pass smtp.mailfrom=linaro.org; dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b=M3C0fLXs; arc=none smtp.client-ip=209.85.128.49
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linaro.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linaro.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="M3C0fLXs"
Received: by mail-wm1-f49.google.com with SMTP id 5b1f17b1804b1-434e69857d9so4119995e9.0
        for <lvs-devel@vger.kernel.org>; Wed, 11 Dec 2024 05:16:36 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google; t=1733922995; x=1734527795; darn=vger.kernel.org;
        h=content-disposition:mime-version:message-id:subject:cc:to:from:date
         :from:to:cc:subject:date:message-id:reply-to;
        bh=U0uQFK6fLtwRvjcx8HTnxkyo0H7NF49q4SiozMOoHr0=;
        b=M3C0fLXsAXtW9jjA7Dw43HxhJb/ma2hwbeaSImzzX7Wu7RYcE42u9NHmp+NsU0LxVR
         udhLSSw6LSOGvUhrV0RjqVPLYf7nmiof1q/OnqAqWOxYdhUlA3OiI6gcPW9UPqUIVx+B
         XeB3l1tY3OAa76qITBRVjT/LsZKCc1Oyf7qj5tLDzDw4KdFRJAui6XPZBA6BtPDCv+QL
         aH6S4yeBmVOaaxDEHVJ6uk72umhFvGCRwdRvTf/AnokJ90+ZLpqQWusrWyp9I+OYSKJo
         qMFq4jihLNTzIn+KtRcb9w8X5QY3hdoRuQHdWvdW4IaBXzhVbyRu48X3+j5L7neRv2C1
         nFjQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1733922995; x=1734527795;
        h=content-disposition:mime-version:message-id:subject:cc:to:from:date
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=U0uQFK6fLtwRvjcx8HTnxkyo0H7NF49q4SiozMOoHr0=;
        b=cHTMZrum5qRK78jsHnJD4RcjtJq6rj1E1cxr05j8+yNfuWXpWzY2VeSFOEVjOZmbPv
         TQ3KBDuDv98HLSUqt7XrzITM9ALbTJeFtqi2K9ojVByc2Ri9ttWePQDI9uS3mNslI68i
         VNVrB5rIpxqBmwdvqcQa+RW0MdLA4z3eTbeQcz5jvoL6IREGA/Mbi9fPPbHurDV7SO55
         HYtaxEHXEqs8F8xdeywn+JbZOo2LJNnvCFAiAoxYg+AZlH0+BbiUjb2V05q4IZ/MrBcH
         Bnc61rQKgLcgErSvVNjK2hEbYyfJO2EJrA0kP8BJJEo/6OH1rsesA4gCKXm4JkiP3DTl
         Nfgg==
X-Forwarded-Encrypted: i=1; AJvYcCVEk/TYWTIZRtB07hvCSRZUGoPAia47ysnOC8RWlGetkGluTYcjem/MMO9RIvmnGAGyP40GprxWwrk=@vger.kernel.org
X-Gm-Message-State: AOJu0Yy4+Vs0526jkOYKw09UzChZrzvoYUSH+CRmnOfRcC8lhZR+cDYb
	/eNEHhkpY6Ig5Mi7X8VbItJqSyFQvt6j1iAcoFVnZEZYa1Cy7uOnPGO48lzssG8dP0IWiD8XfsN
	N
X-Gm-Gg: ASbGncu82uAZ3c0Pt82bZnXQMNmhCwE0J2iBRJ/g2uvILXTOs9uYnK4P7M3CeOteG0q
	pTk0OUu2M4dKZYC9nziy1/qWel0rqlaZULa6YhcFO1jU8ZnkjrJD424Q1f+0frPJbhzrUyk0aiU
	zDiMsPdGSQUjjaH2nF4SGEMznKr5PEipHS+tApIx4/wwjgsPPGMSuyhi5L4sAlxwKRBAml6Ewfg
	hrrV4Y3hA9c16nlvjFG9Q8uk4u2yjMRT28W7d5r1SvWZMn7xTd+7vaAtos=
X-Google-Smtp-Source: AGHT+IE+WdWttoicHGnSAYRa/Js50ySh4oFF39e3AO71tMfwm775Hmc486swefhbNY2eUNQZK3siyw==
X-Received: by 2002:a05:600c:1c1c:b0:434:f1bd:1e40 with SMTP id 5b1f17b1804b1-4361c5d9386mr19966765e9.6.1733922994659;
        Wed, 11 Dec 2024 05:16:34 -0800 (PST)
Received: from localhost ([196.207.164.177])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-434f1125e69sm142392845e9.32.2024.12.11.05.16.33
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 11 Dec 2024 05:16:34 -0800 (PST)
Date: Wed, 11 Dec 2024 16:16:30 +0300
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
Subject: [PATCH net] ipvs: Fix clamp() order in ip_vs_conn_init()
Message-ID: <1e0cf09d-406f-4b66-8ff5-25ddc2345e54@stanley.mountain>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
X-Mailer: git-send-email haha only kidding

We recently added some build time asserts to detect incorrect calls to
clamp and it detected this bug which breaks the build.  The variable
in this clamp is "max_avail" and it should be the first argument.  The
code currently is the equivalent to max = max(max_avail, max).

Reported-by: Linux Kernel Functional Testing <lkft@linaro.org>
Closes: https://lore.kernel.org/all/CA+G9fYsT34UkGFKxus63H6UVpYi5GRZkezT9MRLfAbM3f6ke0g@mail.gmail.com/
Fixes: 4f325e26277b ("ipvs: dynamically limit the connection hash table")
Signed-off-by: Dan Carpenter <dan.carpenter@linaro.org>
---
I've been trying to add stable CC's to my commits but I'm not sure the
netdev policy on this.  Do you prefer to add them yourself?

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

