Received: from mail-wm1-f46.google.com (mail-wm1-f46.google.com [209.85.128.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3296517A2F0
	for <lvs-devel@vger.kernel.org>; Mon, 10 Mar 2025 07:45:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.46
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1741592762; cv=none; b=u0TI85Pv5cGiS9c3fr/G9Th0dY853Xghkw17uzNrXqF7FlYzo2VCrNztD4aVnfqUbxYo/BLJ9enEgyK8nmbHLU0lSrSdKdStKbvEzv4+yfz69GP97W5ymvEQpQteE8dHhjj1LzDHOy1J1zg5EnvKjc6HGAx5bnw+2XEpmxrcKAE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1741592762; c=relaxed/simple;
	bh=uq+RBhP/h+FMIgzluEf1PCwXpWJaNJhq0COCDp/8quw=;
	h=Date:From:To:Cc:Subject:Message-ID:MIME-Version:Content-Type:
	 Content-Disposition; b=aiJZIdszg5Xw63qgbdadS/YvFa7R86Onpn57t/m1oak/HvHLoetKcwlXWfouD6kHV40y9t0+ZPQ2Ng1YsaalmvIVo+ua8wCDzpKleRWytkrEOMyB/coMbx59+N9jx22zv4C18wcuur3VuzykHbOkDsvPku8VbFbt0JruFzNDwg4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linaro.org; spf=pass smtp.mailfrom=linaro.org; dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b=mL2jBZ37; arc=none smtp.client-ip=209.85.128.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linaro.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linaro.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="mL2jBZ37"
Received: by mail-wm1-f46.google.com with SMTP id 5b1f17b1804b1-43cf06eabdaso8710955e9.2
        for <lvs-devel@vger.kernel.org>; Mon, 10 Mar 2025 00:45:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google; t=1741592758; x=1742197558; darn=vger.kernel.org;
        h=content-disposition:mime-version:message-id:subject:cc:to:from:date
         :from:to:cc:subject:date:message-id:reply-to;
        bh=C3lkkkSZ9lA1P1K2ofoRJBLyFssjT+8CRdim7VJKkTI=;
        b=mL2jBZ37oD5j/AF2V1poC5kgShmm5YJx3Jk9qB/QJIe6MxRD9MzNzyea8s1WEkF5Ed
         nEqK9//wwUHsXtzB24I5mHUq6VEtIA+1/YulMlH99xE7jfuZqTxubFr627dwfPZ14lcq
         ZyCYvY8srm7X+uD4L+/Y3ZkYCRS2g4yJB3PGN9oZjCF3phoX9PbJuiLTLekB74OApGW/
         CbGPcJZOMS4OHJCoK2aGDxQWJJdg4ljnebRfzWFGOc0eGd8RLIJoFz+GuHzHGCgoE+48
         16aBO6ShtWg4V5l1vj4dubCmKh6FJZIxJmev8aY3sJnFKxBPNrnZD0vjag4LnmbzAbPf
         VHww==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1741592758; x=1742197558;
        h=content-disposition:mime-version:message-id:subject:cc:to:from:date
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=C3lkkkSZ9lA1P1K2ofoRJBLyFssjT+8CRdim7VJKkTI=;
        b=p4MVCznbR9C63feI44PhcYHiR3x+U4h9fHr7VuNPOSceBtWdoehUM4/AeJcbx1dqEm
         iuXn/LrZmyHGaRkPPA7+yTLK25vsEZBZENnL0nllOo5OVmjMAW00Fq88mCy6b9Cb3+tv
         iRcJdgpGRikRlmNYkKsr6P3KNy+KlNdO/j+8/9zTVe+qPm6gDI/NdI/EM1CDc+8nnpJp
         5qlVK3oo1xtTWvRLkXl0Yv+jcOk0jufeWQlxmg0MMAV/JBBTH3PiqD74xRclpF/Fu9+v
         VkxmxWS7N4dova6qSTM1En4K2pqgADRQA/h3GGSSY1Cz/+kV8Te9a5Om4dCSfxywxlBa
         +gIQ==
X-Forwarded-Encrypted: i=1; AJvYcCW4zJlm5+PXp8ZGS8Ap9/nkT/yOxFztMyMnQ7bk1YXew2A2Ik3H34lcRL/evvhFemVECQiaAmC3rx8=@vger.kernel.org
X-Gm-Message-State: AOJu0YwCzgxgFd/r26d4fyuJEvO9z7Zr5G2g9SDjuOl4ZVNh+XdGt3zO
	hPZZeUsymwuypOYZG6gljqtFVr5Zvpd4y7lWnBdC9QMhWLb8rRpf63GFlNYG8kg=
X-Gm-Gg: ASbGnctnsm2JjqZlHSz6kmbHWZ6BpCPeLuRbrq30X+SQ9GKMQgEj6j3B4ziE1M950gb
	Vi8ZzMpAJC9QWg+/xs23T3RP/bw1xVc7JtYEm2CLYHWNddaVJhhC/DKPDL/WeJlh0vUv22j1ZHC
	hEcFJtXfOnfPPshd/OioF6lh8Tgw/RtdFty6Rcjl54VGOCiCM9vv0iZLClraStD+M7y7Wl7rbme
	0qM50Y5HwHKCFO19VlQInwqlc52g1+9Nd7m8w4+ubqRIXhw/NMsZCUWW2cuT2pGKv1SpTdSR7NH
	oMt57RlSqAAaGCLLnmdJlpgVWi/y6ur7GbevK34+/pM6i8Zdig==
X-Google-Smtp-Source: AGHT+IH9Yu6cknGNfARy5AEaDBTYbcDuPmtRPvAATa0mAJpjpaU3fuTzU/G9tc7si//DtoCJEsSoqw==
X-Received: by 2002:a05:600c:1d1c:b0:43c:efed:732d with SMTP id 5b1f17b1804b1-43cefed7916mr30709585e9.16.1741592758516;
        Mon, 10 Mar 2025 00:45:58 -0700 (PDT)
Received: from localhost ([196.207.164.177])
        by smtp.gmail.com with UTF8SMTPSA id 5b1f17b1804b1-43cf7c8249bsm27791115e9.7.2025.03.10.00.45.57
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 10 Mar 2025 00:45:57 -0700 (PDT)
Date: Mon, 10 Mar 2025 10:45:53 +0300
From: Dan Carpenter <dan.carpenter@linaro.org>
To: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Cc: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@netfilter.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: [PATCH v2 net] ipvs: prevent integer overflow in do_ip_vs_get_ctl()
Message-ID: <1304e396-7249-4fb3-8337-0c2f88472693@stanley.mountain>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
X-Mailer: git-send-email haha only kidding

The get->num_services variable is an unsigned int which is controlled by
the user.  The struct_size() function ensures that the size calculation
does not overflow an unsigned long, however, we are saving the result to
an int so the calculation can overflow.

Both "len" and "get->num_services" come from the user.  This check is
just a sanity check to help the user and ensure they are using the API
correctly.  An integer overflow here is not a big deal.  This has no
security impact.

Save the result from struct_size() type size_t to fix this integer
overflow bug.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Signed-off-by: Dan Carpenter <dan.carpenter@linaro.org>
---
v2: fix %lu vs %zu in the printk().  It breaks the build on 32bit
    systems.
    Remove the CC stable.

 net/netfilter/ipvs/ip_vs_ctl.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 7d13110ce188..0633276d96bf 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3091,12 +3091,12 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	case IP_VS_SO_GET_SERVICES:
 	{
 		struct ip_vs_get_services *get;
-		int size;
+		size_t size;
 
 		get = (struct ip_vs_get_services *)arg;
 		size = struct_size(get, entrytable, get->num_services);
 		if (*len != size) {
-			pr_err("length: %u != %u\n", *len, size);
+			pr_err("length: %u != %zu\n", *len, size);
 			ret = -EINVAL;
 			goto out;
 		}
@@ -3132,12 +3132,12 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	case IP_VS_SO_GET_DESTS:
 	{
 		struct ip_vs_get_dests *get;
-		int size;
+		size_t size;
 
 		get = (struct ip_vs_get_dests *)arg;
 		size = struct_size(get, entrytable, get->num_dests);
 		if (*len != size) {
-			pr_err("length: %u != %u\n", *len, size);
+			pr_err("length: %u != %zu\n", *len, size);
 			ret = -EINVAL;
 			goto out;
 		}
-- 
2.47.2

