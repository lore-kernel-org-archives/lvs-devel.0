Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5B15811CA9;
	Thu, 10 Sep 2026 10:13:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789035193; cv=none; b=OrbBL53Sa3YWfJ+sl0DFXPOK7LQHLj0rhY36KZOLhKnpckBC36OaSXSZtyd4fgpCzx3871zBUUyuh+do5213qp5FEIefpe+IHzyaHBLBX9BNvXG6B66EusVHHpoj+3jierQPg90YGJt8tVwlC0DRcRWPtY7v7IPPHeVZODAkoZg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789035193; c=relaxed/simple;
	bh=lBs3tv1f/poNw+ggNFuo+a9U1b5O5ZLw0/bHAEABrWs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=VhaJTjO4jvRoI0/GwIc0n5MfIBDR7OhgavFCMKOpG9rCHr9XEnPWj5vxBXPUOv7s3hX3TVSlbHdeUprX8umvPwfl0XjrSDbAAa6uohq6hc3jZIvN5FBNrBM8nP+eHaGF01GqPr2BHXajyGBg5cVvqeWgeRqLwTuF42okuk91tLk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=SS6WZTnF; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="SS6WZTnF"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 747592273A;
	Thu, 10 Sep 2026 13:13:02 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=O8YCirpJJGa6BmQs/iFQT1hmiaNAEmnym5oIUjS6OLI=; b=SS6WZTnFh8/q
	YUj8Ga/r3DnMXa32Bop+Y/JW2UXNcU4GgJniJYVBProyFsjVJ5A7E7MADnAMHs4m
	sbdPLMtWQZfD62xaEM+pZ2eACAuIgCitEO47GxKEuoSP2f1cggkETVdWN4w0utCu
	+IPPPtnbMlqkd5xAJUBovjCo+RkDCsAY7TEJvOXB/ikmvBj0oXGAzr/4SIEumCQ0
	xHIbQfAc9GqLYEpKquyJnbs+n16OqlC4YH9y2pzMVbOP782Zx8WJMjylAOQ+2BTg
	sDMx+WAi9zt1e9l4G/th4YslBy5JU8kXjL0/Tey6fS3F7BrKX4Grrc+IFfgzlz/k
	6ofZ9UYErrRhmek39xZ5C6pX+ocLQ3K3WN5fqdroOWjQKDY+QiCvPa6OCucju2O1
	EufYc7kwDdp2pq5t92E39nskZccfNpPHl+uzFBfOISso5LUTRTo/MgQvsqkkUq2a
	30LRgPgm9sgDHnhHPCq8JRks3X4oS7f1wvxJKLA8RMnJQQIU2A6YURyA86GdQ8Cx
	uKtPL+v4j7d3h8NfKP0w5bwqW5UYjDx1fg0CRNmQ7AwYOGf47/951TuxH2k85kTs
	C32lfwK1dYhPlDkRuc+6XFpB0aejQwOz0g6nydUZ50tEKcVeRRm3q/l2GeZMiV5Z
	A6OEzVSsCsxqgyr4CG+8h1LRboZZF58=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 10 Sep 2026 13:13:02 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 0669E60457;
	Thu, 10 Sep 2026 13:13:04 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68AA8oGF036026;
	Thu, 10 Sep 2026 13:08:50 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 68AA8oaG036025;
	Thu, 10 Sep 2026 13:08:50 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Zhiling Zou <zhilinz@nebusec.ai>, vega@nebusec.ai
Subject: [PATCH v4 nf 1/2] ipvs: fix missing counter decrement in lblc
Date: Thu, 10 Sep 2026 13:08:31 +0300
Message-ID: <20260910100832.36004-2-ja@ssi.bg>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260910100832.36004-1-ja@ssi.bg>
References: <20260910100832.36004-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

LBLC may delete cache entries for destinations that are
removed or overloaded and replace them with available ones.
But ip_vs_lblc_new() forgets to decrement the tbl->entries
counter after calling ip_vs_lblc_del(). This can lead to
increased shrinking of the cache with every new garbage
collection.

Fixes: 2f3d771a35fe ("ipvs: do not use dest after ip_vs_dest_put in LBLC")
Link: https://sashiko.dev/#/patchset/0bdd5abe9968ded7ca2b9cb6844ba83d94cc8d53.1787318053.git.zhilinz%40nebusec.ai
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_lblc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index bff109c1c959..4d36c83d84cb 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -203,6 +203,7 @@ ip_vs_lblc_new(struct ip_vs_lblc_table *tbl, const union nf_inet_addr *daddr,
 		if (en->dest == dest)
 			return en;
 		ip_vs_lblc_del(en);
+		atomic_dec(&tbl->entries);
 	}
 	en = kmalloc_obj(*en, GFP_ATOMIC);
 	if (!en)
-- 
2.55.0


