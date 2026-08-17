Received: from mail-pl1-f181.google.com (mail-pl1-f181.google.com [209.85.214.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5D6223B6C0C
	for <lvs-devel@vger.kernel.org>; Mon, 17 Aug 2026 07:14:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.181
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786950879; cv=none; b=aCmA/TETuXsft4BCN5rwLcXK7dAR5+KhserdMvwZkIH3I8JJcXTbmkneLg2ikdnQt3NONGRZcBKbOhwwgKl0vTd9m9+sW9sqlF/zsjeUdUDN+3Q6HrNXp5b2dC+W4zm2TU9Cx+sgwLOAegRYW5+oHXgBuTj+oQhlYAE8zl/CYw8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786950879; c=relaxed/simple;
	bh=Ifn6OQnRHmSsxgixo8MsCSBtwEbCzzopUABgiunYuSM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Azte3BiXqo8vAvSIjYZaqiITpdrWcM6tRv/ZXypfOwBWpzAN4Do4jhGJOA+xf90BxC3BjoyLU/wZA8ZvvWcBULoCdgMQtnNKtHvuzZ7FAljPZlot0Yde5iWoPFCnLV9quHKtlPIsG38XsPaIwzP4fCdGnNeGsxnqUwixUVaVIVI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai; spf=pass smtp.mailfrom=nebusec.ai; dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b=LCVpSXr2; arc=none smtp.client-ip=209.85.214.181
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b="LCVpSXr2"
Received: by mail-pl1-f181.google.com with SMTP id d9443c01a7336-2cedda2ce6fso19197345ad.1
        for <lvs-devel@vger.kernel.org>; Mon, 17 Aug 2026 00:14:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=nebusec.ai; s=google; t=1786950878; x=1787555678; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=kJu7dQTeNe6m5Lnp0IlHAvUypghyn4/ScR3/79E4HJ4=;
        b=LCVpSXr26L+RZLRBq6dEufg8otOKqOCfOETWGvkirt08QN7nUHsVQ9F4bsd2kMZzFS
         OsfW0bo1+pQ/iQvo71PZaZfEEKISdnj1k/N4gAyvl+J+/uP6iQ8j0XV4ZWL/vZ9WDqWO
         rkmpPES0iD47062BIHd3Hmc2R5z0lOS4L9JRcD6paa3/WwZa/gbBJ5pz6tW2EO/U/EIZ
         Ujlm2XgrzfllUVsblC+tMxyet1xGECd5i0ZvnyD63g4C22w0H7tOAYvLHqHnWhF1sotk
         bFlUoIABHE1kMY6ehmWYU5vX/1TAT4L4pPBUgoYaE4n8p0iWfhZ0+7A3DM2z+irwH+u1
         YeFg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786950878; x=1787555678;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=kJu7dQTeNe6m5Lnp0IlHAvUypghyn4/ScR3/79E4HJ4=;
        b=KTR3FcYhrAGhbT+jqJfS2dwhHsLAddyo7GZ301XqUdYEQCaGktmNVGYtm/Mg6dM5p0
         kny6t9CEHFq1qndV1Y8txzoTTSOHNMyQsh+WdhQ9wpJaDohVh90x8Pk49BYNii6q8dmk
         yZg8rKQ/EB71Cjm2GFeuKHqw6LPZw/6hphjZ7xyouBnAkSAPUURfneCTF+I6ZowexcCO
         N7W5t+F/vTiiDXFZq3VbzyNBzU/K03H6iKVFSmMG7JpPIDNt4/69Rg5/8RwBIlwHn8aE
         mwBkHqSNG0zjWjSlaTDA8UmwKmpfstK9MtL6DtHbPi/FoH+QB6LEQ1BDZnV1qwevBT9F
         8BFw==
X-Gm-Message-State: AOJu0YwEkBSvNiCTM+Y0BOvtNRvxbF9NYSGdVltnIhLzFJBghBIbVUGN
	DprMji4XT4P1lntyEgnx2n2EfVRhTd1lqa5PLcWUHv6ptPydOoA4t4EP8lLsn0QEsPpGfALSNMf
	s/5zf+A==
X-Gm-Gg: AR+sD12PMLLjqFWfmuqRtyIE2qabe6AipzbhgPR5YX2+P8s2CXqH4Vl+N7qQTmVGJRf
	5i/50gyH+9ynAU0pxtRrJHAYONxyioX5h6yai6r5/wJ/Xx+RLZOMJeE4qFnuxBqszjqlJvDhRii
	Wkmk0DCQkOR5xuyCGpf9n+Fw6i5uZ2ijVdCl1qq35bRj2ZtZn6CRuap/Al5rmHTfXp57ULrPccI
	C/H+UMmD9dkVxapu/ssmtMYqpE8wjoCl+iVOQ/zJ6C6LhDBFYyPgIlqL7OR6jHjs3L9bdyyzRzT
	iOuNJ7PlamkZl/KMHNajiycJJ6quxX42vg+wuVBEZmGvjL/bA/GJzKDtkpamQtTi57buHfRUs85
	dCR6LCQ06u5qxhB3QPZM61i4tqLVLYM2WsEMRoDyuY0DVJOZ0cTSyjRLYn4BBUr3leE9mHuHmgM
	8BhnTmzWNBmcDxxJ7ETH+nz5AJqDqw9myeQ8S18SJEgytzgzvA/msEtVMxrxS03JjTwyRzX9dq1
	hGR2AJpsXN3UaVV/fF+1af5Qd5raQY5aqbl95Skcc1zaw==
X-Received: by 2002:a05:6a20:a126:b0:3c4:3112:3b with SMTP id adf61e73a8af0-3cc71ccf668mr24775404637.18.1786950877680;
        Mon, 17 Aug 2026 00:14:37 -0700 (PDT)
Received: from Roxy.localdomain (n220246089185.netvigator.com. [220.246.89.185])
        by smtp.gmail.com with ESMTPSA id 41be03b00d2f7-cc13bf0563esm272327a12.6.2026.08.17.00.14.34
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 17 Aug 2026 00:14:36 -0700 (PDT)
From: Zhiling Zou <zhilinz@nebusec.ai>
To: lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	ja@ssi.bg
Cc: horms@verge.net.au,
	pablo@netfilter.org,
	fw@strlen.de,
	phil@nwl.cc,
	vega@nebusec.ai,
	zhilinz@nebusec.ai
Subject: [PATCH nf v2 1/1] ipvs: bound LBLCR and LBLC cache growth
Date: Mon, 17 Aug 2026 15:14:22 +0800
Message-ID: <17cbb1d0649f4e19aa2e407ab4b528d42b8edac4.1786949472.git.zhilinz@nebusec.ai>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <cover.1786949472.git.zhilinz@nebusec.ai>
References: <cover.1786949472.git.zhilinz@nebusec.ai>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

ip_vs_lblcr_new() and ip_vs_lblc_new() create cache entries for
every previously unseen destination address. The table max_size only
tells the periodic collector to reclaim entries after the cache has
already exceeded the limit. It does not reclaim entries that the
attacker continues to use.

Reject new cache entries once either table grows beyond max_size. The
existing scheduler fallback continues to use the selected destination
when cache creation fails, so new traffic stays serviceable without
growing the tables further.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Cc: stable@vger.kernel.org
Reported-by: Vega <vega@nebusec.ai>
Suggested-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Zhiling Zou <zhilinz@nebusec.ai>
---
changes in v2:
- Change the LBLCR limit check from >= max_size to > max_size.
- Apply the same cache growth bound to LBLC.
- Add Suggested-by: Julian Anastasov <ja@ssi.bg>.
- v1 Link: https://lore.kernel.org/all/62790a9f94ac5318f107a1811cff5a1f2fc7e0bf.1786884824.git.zhilinz@nebusec.ai/

 net/netfilter/ipvs/ip_vs_lblc.c  | 3 +++
 net/netfilter/ipvs/ip_vs_lblcr.c | 3 +++
 2 files changed, 6 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 693bcc82ccb77..106eae24d3111 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -204,6 +204,9 @@ ip_vs_lblc_new(struct ip_vs_lblc_table *tbl, const union nf_inet_addr *daddr,
 			return en;
 		ip_vs_lblc_del(en);
 	}
+	if (atomic_read(&tbl->entries) > tbl->max_size)
+		return NULL;
+
 	en = kmalloc_obj(*en, GFP_ATOMIC);
 	if (!en)
 		return NULL;
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index f53f05ceea36f..6e76808063d69 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -363,6 +363,9 @@ ip_vs_lblcr_new(struct ip_vs_lblcr_table *tbl, const union nf_inet_addr *daddr,
 
 	en = ip_vs_lblcr_get(af, tbl, daddr);
 	if (!en) {
+		if (atomic_read(&tbl->entries) > tbl->max_size)
+			return NULL;
+
 		en = kmalloc_obj(*en, GFP_ATOMIC);
 		if (!en)
 			return NULL;
-- 
2.43.0
