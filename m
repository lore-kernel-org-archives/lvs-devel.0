Received: from mail-qv2-f12.google.com (mail-qv2-f12.google.com [74.125.230.140])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1467736C9CC
	for <lvs-devel@vger.kernel.org>; Fri, 25 Sep 2026 14:11:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.230.140
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790345520; cv=none; b=Aa3B/c1MtdZ7GtvIrs5bWfTvsQ5Cc18qqKA5qqtu20KRVyV6vO1SF+XgFFT3dnpn0Juhm+VS/90MFumzYSjL4J3ihkwZad96XZjGPSG7wEaZ3Q2itdB+kyGKFWEDE5O2zRU3DUWD9wYC7oT6VKkWo/hZyPPEq8DdHI02/wSlrIM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790345520; c=relaxed/simple;
	bh=bClgww2PEDEwfXY5iR7JQeRsyjdwM433YNLMHw0EdVc=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=GHKJwP+vY6z7h4no1YPShuKDdFMCATGZnJS1DD6EZV9lGCR7ss4kC3G5gCjI2q++RYalyUZQ7TLdU1w0RU3GOs3Bmpv9/Pz0ATwlnMaquyzCoFLNP4EDSc4/klI+w1p3njk95yfqvtFZfDelMFBqlgXkrLErphZWJhDcDzv99vw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=1password.com; spf=pass smtp.mailfrom=agilebits.com; dkim=pass (1024-bit key) header.d=1password.com header.i=@1password.com header.b=B5iFfF/4; arc=none smtp.client-ip=74.125.230.140
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=1password.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=agilebits.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=1password.com header.i=@1password.com header.b="B5iFfF/4"
Received: by mail-qv2-f12.google.com with SMTP id 6a1803df08f44-90cdfe57a3aso9287596d6.2
        for <lvs-devel@vger.kernel.org>; Fri, 25 Sep 2026 07:11:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1password.com; s=google; t=1790345518; x=1790950318; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=dO7NZCxAxiVThQ0A8dmI8vnZ3FIyuKMw3NNH1me1PFc=;
        b=B5iFfF/4mvlPPw3BphhIrn1bZb4aH/fj7RRA3eZ4zH2usE2JEeIerXfGQjx+dGHsdt
         +wAmuiF8z7s4ZnY6toCfecMo1pSDnmtKS73c3aVF8YDg6Jq3SyJmUO60QEGO0ugpvuXn
         BzTN9n4LbfuWhtFFaimkUHgi/T8zdtoo1I7zY=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790345518; x=1790950318;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=dO7NZCxAxiVThQ0A8dmI8vnZ3FIyuKMw3NNH1me1PFc=;
        b=XheT4WEZJlw+0jI2CbHudFlvgviNReQlmocItnMrf5zDzpGiICswzg/xr6Me9KrWEn
         dIeVmPF0F3wfTNGRgvy6LXW15gjw81hR2fgmzi/uN9JQJepowE2XJrBmV7TUBN+A9o/L
         kKKRyK0jm6R5mc/aWxXry5T8nHxNEJ/93Gteircw+LlsPr8gzcKk1fmtpXtzVWwrYz4S
         AxNo+dP+a+YyN9aJUI6Dgp/BkmYHk/IkW35v6EOYE2D4cOgGTvueH/UDUwUERa6ccIDy
         G2tzFF3Dtp7qDx9ED7hXaT01rlOih5GgxmtG7zbO+fq22vegJAO9vFY7Gg/dSDcfj3jd
         jiFQ==
X-Forwarded-Encrypted: i=1; AKwUvByA290SZcdeaX2ggxUFPb3WH1AaR8dN1Dbn0iGR14WSdipUUuYXLTCT+4iZhcvNM1U+Uiym2KM8G04=@vger.kernel.org
X-Gm-Message-State: AFuF++k49VzuU2r7lBOvvRTr3AX8B97FvZfQBymeIyfzAYjo1uLaXKje
	MLCmk9sAapn6Yyku30iQkYFfWiZIVEdFAVIRnLhwX5w91OzOfsFq/x7buQi8kI/gFhg=
X-Gm-Gg: AYBFou0khgZaDMqECAhgwSc8CkvNd3eTcvNDgV0qS4G6cwEZIDk+4v8xRwV8g/u7ilx
	Qhc2DvaEXl0tX9YPpANy0QpWztBRPTIj+B6ktszQNDynTzAF+VejWefmf9KQ34OQLfnZjpJa649
	6arDOc2ibIHIWJH3H0Ernrv5u7mQa9YEjdk3i3P6gBHPKjyA9fzKyTfeJCKhLBtQeVHjkd9SDgs
	AlZ9JkI9CtrMK/zNtwFUiXMjcUq1OwKksAV09VwTOIW4FIwz1v6MuVU4SPjUPbuU7gPGcDSuBj8
	sdtcUF8AYaiQ5OgBQuJirix0YDLtKgQd6G+s7Fjw9iDm3p8Xj76V1lulv79jU57/H2bgiv23O8F
	nygcQ62K0G3Q00x9RjU2vhASqFNt1E+M424WQT6Lo6oITY8K53znf7pA3tn7mIOilq23a/wAvmQ
	sBw00MuLHCvu0HD1CzbYfXNIYmxfWiD4jJvEWlOHEvjKMi23aI4/7a2luUGQwNTdlaJ2s2oUKVb
	rGxvu5q+rRGLrAPQrAvNOkJhjdgyw==
X-Received: by 2002:a05:6214:20cf:b0:907:c025:e4 with SMTP id 6a1803df08f44-9142f7af5eemr44633636d6.13.1790345517807;
        Fri, 25 Sep 2026 07:11:57 -0700 (PDT)
Received: from localhost ([2600:4041:59c3:300:7917:c7f6:28c6:182b])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-91430ecf80csm17564456d6.49.2026.09.25.07.11.56
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 25 Sep 2026 07:11:57 -0700 (PDT)
From: Axel Mierczuk <axel.mierczuk@1password.com>
To: Julian Anastasov <ja@ssi.bg>,
	Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	David Ahern <dsahern@kernel.org>,
	Ido Schimmel <idosch@nvidia.com>,
	Eric Dumazet <edumazet@google.com>,
	netfilter-devel@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	coreteam@netfilter.org,
	netdev@vger.kernel.org,
	Willy Tarreau <w@1wt.eu>,
	Keith Hoodlet <keith.hoodlet@1password.com>,
	Axel Mierczuk <axel.mierczuk@1password.com>
Subject: [PATCH nf 0/2] ipvs: fix OOB write when NATing ICMPv6 errors quoting non-first fragments
Date: Fri, 25 Sep 2026 10:11:53 -0400
Message-ID: <20260925141155.17603-1-axel.mierczuk@1password.com>
X-Mailer: git-send-email 2.50.1
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This series fixes a 16-byte OOB write past the verified skb area,
reachable through ICMPv6 errors that quote non-first fragments.
Following Julian's suggestion, it preserves ESP ICMPv6 handling.

Patch 1 includes the embedded IP header in ciph.len at both ICMPv6
call sites when parsing stops at a non-first fragment. The change
follows the ip_vs_fill_iph_skb_icmp() calls and does not depend on
patch 2.

Patch 2 makes ipv6_find_hdr() set *offset to the fragment payload
for non-first fragments when target < 0, so every successful return
updates it. It carries no Fixes tag because it defines an offset
that was previously unspecified.

Axel Mierczuk (2):
  ipvs: avoid out-of-bounds write in ip_vs_nat_icmp_v6
  ipv6: update *offset for non-first fragments in ipv6_find_hdr()

 net/ipv6/exthdrs_core.c         |  6 +++++-
 net/netfilter/ipvs/ip_vs_core.c | 14 ++++++++++++++
 2 files changed, 19 insertions(+), 1 deletion(-)

-- 
2.43.0

