Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 978B33B6343;
	Thu, 10 Sep 2026 10:13:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789035203; cv=none; b=RgBHwUdJjfcgVxI+KXNpLVQyF2gnFrtis+eQt5qSxh+I8J/ukOY0pzcrjkmkDsK9yCLjed1/DpQzoOr0YJTRP6dz47uySiWqicxD4MZQC+ETGb50uVpfcoqvqC2R8bIz5w8kl+kjsAob1ZvmTvaomMWKUWG1hdFGyQObQ2LppnA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789035203; c=relaxed/simple;
	bh=llODsaFdqp6SaI4qzf5u4O4XcRUKYm3WONbLP7gf1sY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=VGhWEIYJ/iG14l703OlyNINWPDpBdvsydrJy1CQW3e35PTLCqumMcnC7kIRV7MWWrQo3AtDGbQw1zEFxaWOA+iRVKYPY0h4c13aEAxt7pWJaI3kfNP5VpBjMsCoTRutISmA+CfOHrbLLImM4/3eRpxy7kCGx9B/Ubz26thjxfuE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=L0W+WmIB; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="L0W+WmIB"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 4D97C2273F;
	Thu, 10 Sep 2026 13:13:03 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=3n2fNSgCAG5uea1aKYMPoV3IdfsSXmoiL5v8lsLFGdw=; b=L0W+WmIBrgJP
	Ocb7guMvxw3nkFVp0z9q/1X6EhWrG7vFR93loW0r+gveMfMZDr5NuycwBitEX+ZM
	W6WY0MC7viNp2nOTAE341ijan21vaIDUWH7RWVVgoctPQY4x7XFI1KIJyZLx57qJ
	2O4bVUVTnCZfrAqdFCZEa9Gz4b9i+7Ne0ACngfpHfopOeyfcSE6rH4ovTTDvo8vc
	SSM/IZcnvnMUVa5JP0/HFeZjLNUUXjB78xnZEuW1AEBp4ogZVwJh618MpucNN/QW
	cGQtt5kuZSH48PeP0AeJb0K58Hi6DRCZAE5aCJ1uVRgUYK5FgWUAjUrGHWiEgf0f
	5LFClxiJkkBOBb8I9x26wSXGRxnroOGL7eLxvXFusaPnrMKoMunMEMkRIUOMm27q
	dodX97WsZqGEhRGE4cntAWLPAZuXdjFBepdTg5Ga/Fq2ASySCSvP/ljG7JZL7+Lp
	zoviCsq2SpQS2IJKBsi6JIIt+aaqR6NJu9Dk3CzDOnbLUs3CJlE2KbRqtJxOevKC
	bPlxPLbJfIX/YGmtlIHQIA96QIt0y3vXh/aVww+0VAi2bdhOo/U4baWx8DTLuQ0T
	FUGWqwwyjm9SeHjgNZb+2t9FqomR7NJKlDrsA0uhDRv0ID8cUlEKHP9nJwrwRX2p
	8ixZpgkLTP4UKEPuIXlKAx1HsvDX+x0=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 10 Sep 2026 13:13:03 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id A88AC60457;
	Thu, 10 Sep 2026 13:13:04 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68AA8p30036030;
	Thu, 10 Sep 2026 13:08:51 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 68AA8pmu036029;
	Thu, 10 Sep 2026 13:08:51 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Zhiling Zou <zhilinz@nebusec.ai>, vega@nebusec.ai
Subject: [PATCH v4 nf 2/2] ipvs: bound LBLCR and LBLC cache growth
Date: Thu, 10 Sep 2026 13:08:32 +0300
Message-ID: <20260910100832.36004-3-ja@ssi.bg>
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

From: Zhiling Zou <zhilinz@nebusec.ai>

ip_vs_lblcr_new() and ip_vs_lblc_new() create cache entries for
every previously unseen destination address. The table max_size only
tells the periodic collector to reclaim entries after the cache has
already exceeded the limit. It does not reclaim entries that the
attacker continues to use.

Reject new cache entries once either table reaches max_size * 3 / 2.
The extra headroom lets the periodic collector catch up while the
existing scheduler fallback continues to use the selected destination
when cache creation fails. New traffic therefore stays serviceable
without growing the tables further.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Cc: stable@vger.kernel.org
Reported-by: Vega <vega@nebusec.ai>
Suggested-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Zhiling Zou <zhilinz@nebusec.ai>
Acked-by: Julian Anastasov <ja@ssi.bg>
---

changes in v4 (Julian):
- apply on top of "ipvs: fix missing counter decrement in lblc"
- v3 Link: https://lore.kernel.org/all/0bdd5abe9968ded7ca2b9cb6844ba83d94cc8d53.1787318053.git.zhilinz@nebusec.ai/

changes in v3:
- Allow 50% headroom above max_size before rejecting new cache entries,
  as suggested by Julian Anastasov.
- Apply the max_size * 3 / 2 cutoff to both LBLC and LBLCR.
- v2 Link: https://lore.kernel.org/all/17cbb1d0649f4e19aa2e407ab4b528d42b8edac4.1786949472.git.zhilinz@nebusec.ai/

changes in v2:
- Change the LBLCR limit check from >= max_size to > max_size.
- Apply the same cache growth bound to LBLC.
- Add Suggested-by: Julian Anastasov <ja@ssi.bg>.
- v1 Link: https://lore.kernel.org/all/62790a9f94ac5318f107a1811cff5a1f2fc7e0bf.1786884824.git.zhilinz@nebusec.ai/

 net/netfilter/ipvs/ip_vs_lblc.c  | 3 +++
 net/netfilter/ipvs/ip_vs_lblcr.c | 3 +++
 2 files changed, 6 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 4d36c83d84cb..e1111c3b2721 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -205,6 +205,9 @@ ip_vs_lblc_new(struct ip_vs_lblc_table *tbl, const union nf_inet_addr *daddr,
 		ip_vs_lblc_del(en);
 		atomic_dec(&tbl->entries);
 	}
+	if (atomic_read(&tbl->entries) >= tbl->max_size * 3 / 2)
+		return NULL;
+
 	en = kmalloc_obj(*en, GFP_ATOMIC);
 	if (!en)
 		return NULL;
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index c2853e07e787..dfb5bf83750d 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -363,6 +363,9 @@ ip_vs_lblcr_new(struct ip_vs_lblcr_table *tbl, const union nf_inet_addr *daddr,
 
 	en = ip_vs_lblcr_get(af, tbl, daddr);
 	if (!en) {
+		if (atomic_read(&tbl->entries) >= tbl->max_size * 3 / 2)
+			return NULL;
+
 		en = kmalloc_obj(*en, GFP_ATOMIC);
 		if (!en)
 			return NULL;
-- 
2.55.0


