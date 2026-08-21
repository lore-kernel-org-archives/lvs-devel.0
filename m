Received: from mail-pg1-f177.google.com (mail-pg1-f177.google.com [209.85.215.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BAE0047CA64
	for <lvs-devel@vger.kernel.org>; Fri, 21 Aug 2026 13:28:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.215.177
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787318923; cv=none; b=f6+d34JV+tv+hd1uqSA/UPKRRA1T3Lr5ricoDI8328cZUYdsWMspPxlEsGQb21aYO7Nfgq3TT078jJ41p9tM6wJx/VtPuL+H8wgoA/UiC7IdSh3nbOk7c/L+tzHGClZcvC5DCnUoZT55Bn2TwoGFGPQ0XlkUSOnUfqLPSKaRYV0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787318923; c=relaxed/simple;
	bh=DNZ6zBZT011tl2qw553oZ6NjXnPZB+FM8I+qiKNSuZg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=TiaWdlWQcpsCV6UjLtHu98qqjvFo5GZPn/LH+CmnTUfrgrWkOmbC+gx3Cvw37ox/SV2QsBRRSDwV076WL9DGScKohgxTGX9wbk6escT6Lazoa038eX7u5kRQxzO9FQ/H7HRAiZSX4ByJWZY1ZIJUE1qRzzdMAGJBwXGyUyE9E6g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai; spf=pass smtp.mailfrom=nebusec.ai; arc=none smtp.client-ip=209.85.215.177
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nebusec.ai
Received: by mail-pg1-f177.google.com with SMTP id 41be03b00d2f7-cc11a905ba5so725925a12.2
        for <lvs-devel@vger.kernel.org>; Fri, 21 Aug 2026 06:28:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787318921; x=1787923721;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=vCIVwv8l0A4pgZ5u7U++SMLBssX9hny7cJtv845iJQ8=;
        b=P6wlxfWiVLmS4H16ax3TppwiKf4sFFsBl5t77xZ9pi415kts4d4SF+O8qQ+LE0rPSb
         IOexXay838xxkivNpmtkW/FlxEHHzEHPyIkk0smdd44iCEoOsySxJdoP1MEKrd0JsVHd
         Yb2DbUK1ZuGW9d3XR63g2ZPtTnoHP+kGrie8GHGNBXrKbaOq5Zj8loybToQEC4ZqAdTW
         lAIjCfvEWpak1Uk83saBsWt9SnFhzKMSTGcL7D6Yv8QbdPV4RrMfvSeXqzAaiJzfDAv4
         /oqk1HBTCgVPxCrrTj5uDnHbVoNMBp9XicF1I+esjBnvekGQrCT2j3Po2B/K4duGUU87
         Tl9Q==
X-Forwarded-Encrypted: i=1; AHgh+RrCIEwHZLFnT91CM2hHKQ+4uhBkKGddectUPvQ7h3YvlzxHrQ2RWyhygfchIE7XlRDFSnJ3UH8HXGA=@vger.kernel.org
X-Gm-Message-State: AOJu0YyhAxWaLtEsx3qQwb08YScWRswsjRiGHQpgQuvpW1lbnnuVCwIT
	Sdo01ol19mkJuUjWfq0w/jcOWJyy69cTxSRmyKE4bBneoUYTaG+nsh26snx8smXNM/Yw
X-Gm-Gg: AR+sD12YOHrPGfKmrsHWRTLIWz5WF+4o8nsurQFeMWX60IAMhmsvQiLeTqDLfWf8yeT
	tMPQXrHQi73JZF2d9eRRet5Wgl7NrQXCwBWwHCYIRGzrNj0Bq44j1wtf3ucMg41qPNfY2cqE+uj
	mhOX3x6YC1dbNvdL07lP2nQ2yugraTNcekoFtM8Hi7GnQFRPxIinIMQqmTza4E82NQwTVE6OfCU
	cv4CFmseVTQ3uyZfrPmLRjqJPnwCPDJ0UJ6YXqufW2oHK9spypL5kRFuEttJZqI7GSfPsmgyQoI
	LJ6a2d06+I4WwFxYdwRfxmVoS/ATckfB3h6bwdBZG/7eCbskpuFOmMHXsb2eWQnZ4Bd9QieiHnE
	a/yyp0GdJXKul6XktnsKLOxYlBfG9XKwqluxzkgoF3JEigjF2IDH268NvY1GFY0bFrsjkx7WJlm
	kYoH0nX/44kKdMK78HLB56ShcXQeUoQCvbvgIjd0+fjJEQLw==
X-Received: by 2002:a05:6a20:450c:b0:3bf:6d96:ac40 with SMTP id adf61e73a8af0-3cd3007ce9bmr13242954637.12.1787318920741;
        Fri, 21 Aug 2026 06:28:40 -0700 (PDT)
Received: from Roxy.localdomain ([2602:feda:30:ae86:2bd:64ff:feda:6b7b])
        by smtp.gmail.com with ESMTPSA id a92af1059eb24-1416ad69638sm24671605c88.7.2026.08.21.06.28.36
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 21 Aug 2026 06:28:39 -0700 (PDT)
From: Zhiling Zou zhilinz@nebusec.ai
To: ja@ssi.bg,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Cc: horms@verge.net.au,
	pablo@netfilter.org,
	fw@strlen.de,
	phil@nwl.cc,
	vega@nebusec.ai,
	zhilinz@nebusec.ai
Subject: [PATCH nf v3 1/1] ipvs: bound LBLCR and LBLC cache growth
Date: Fri, 21 Aug 2026 21:28:19 +0800
Message-ID: <0bdd5abe9968ded7ca2b9cb6844ba83d94cc8d53.1787318053.git.zhilinz@nebusec.ai>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <cover.1787318053.git.zhilinz@nebusec.ai>
References: <cover.1787318053.git.zhilinz@nebusec.ai>
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
---
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
index 693bcc82ccb77..8180a7ba9f538 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -204,6 +204,9 @@ ip_vs_lblc_new(struct ip_vs_lblc_table *tbl, const union nf_inet_addr *daddr,
 			return en;
 		ip_vs_lblc_del(en);
 	}
+	if (atomic_read(&tbl->entries) >= tbl->max_size * 3 / 2)
+		return NULL;
+
 	en = kmalloc_obj(*en, GFP_ATOMIC);
 	if (!en)
 		return NULL;
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index f53f05ceea36f..858393b1d2d17 100644
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
2.43.0
