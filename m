Received: from mail-pg1-f178.google.com (mail-pg1-f178.google.com [209.85.215.178])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 76F1F3A8747
	for <lvs-devel@vger.kernel.org>; Sun, 16 Aug 2026 15:23:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.215.178
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786893782; cv=none; b=fZAdL2Ms6lG+n7trhN0VWcP94Xx6CCK3U+MIp/x5fEK4HBpvm2ViE021NNuJQhGHtXX6SAwGcmis1MbYecjN+JWla5vJyIcliuIlOICDzjY9a099wGzHfllx03beszpeegl0ad00bdbFlsn9ZTtym9TnLR2IUk5mlLh9KQpo1so=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786893782; c=relaxed/simple;
	bh=mQJTq0f6+lqaotU7la+SCTqZYgpv/z4fQK/LUIpysFU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ees2jAHKUWUikasfH3wR/G4UVDLYN7NOFhuR67TsxUXvhxRvtlQcZtDcGaYVCLndpI6Jqppr/+8SS5bKKOVWHCnKB1+jo9Ul3kXu+SkcqGBK7tIW9Wf+AA6za7WR9lpJ6Got4wG0G94rEbFCgdzqDm6vxBO05VFtpa2F9kUoKK0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai; spf=pass smtp.mailfrom=nebusec.ai; dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b=DdBiiXyI; arc=none smtp.client-ip=209.85.215.178
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b="DdBiiXyI"
Received: by mail-pg1-f178.google.com with SMTP id 41be03b00d2f7-cc11a30a259so1532730a12.3
        for <lvs-devel@vger.kernel.org>; Sun, 16 Aug 2026 08:23:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=nebusec.ai; s=google; t=1786893781; x=1787498581; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=fDUCcFtiGS+0AQzyulJldc/gdnA/Tuwf1iE/FWDjOo0=;
        b=DdBiiXyI+wZKid+EQRJbR0nKqRmMD+mJVoqKmWbw0JEUSU4B7bcNqWCy+fxBUq8fNC
         /dVCaQb8wuyupt+cjrxZO5XlrC3sVWdxVAUOPQtGEuRjF3dkc+VjYaPzaaBZWl4MwAdU
         nkxejCU/yNyU1e/F+/gsNHJFjmqsfzERZWyJHJjFa2kXCytk8gCc8lsGvWV+PX/uLaLq
         OUV3MGosFj+sPulcv/ZNjWvVw8fmk/hhUhXAe86g8VMx2IkEzTN+4AOkPxxSwjV0//XH
         1TWjZmlRYiX3PFAygzQKlSt7+HVRMY6v0ccvrXV0FNQYIaFffAXsvewRu8cXXOMV9jZp
         gYrA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786893781; x=1787498581;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=fDUCcFtiGS+0AQzyulJldc/gdnA/Tuwf1iE/FWDjOo0=;
        b=Xvq/ltHFnUkkcSBcyyZliYLRJT7OwNMmadp29jIU2WlsTqJKyagVKMTvSAuDQcXreZ
         Wd10+VXszTeXkbiz4wxMlbSd1lE0gIoCIiQm7foVdZiSSjFykxAIgb+0Jw+W09F/dqRc
         IiJfVRvIteYNdmRuMoXy8ehJKI4gvxJ8dw22F6Xo1hfnJXyr3QWpGnYhtnS+As8CwaQE
         bbfdaXFYnz5a0u71/Mm+9+uIp//sdfzvuAQA6Lt0KZUUFQgm0AAlhCILntgn3SWdGDPw
         Yxqs08rdT56aOHJ/TQ8aIG3NdYYJg80jZ4TkjcWKnxMfmaQokRwEJuzo71ScYQAdJ+eV
         KEZA==
X-Gm-Message-State: AOJu0Yz+RLuPP9U9cogoqW5+f7Av4N9iKTtjeE4LAasJGnP5iZgsKDPQ
	LQ5PT7d8k413MX/fkMn3cUqmJBtrOHh3dz4vhxvu5PLv8hjEcHCFuBunBK6hE5NmpMCIKX67V7P
	CAomhxuk8e2EdYg==
X-Gm-Gg: AR+sD11o07a6rY1yk8oFU5khS4HZkwODxK1h6k0b3kedRl6J5lCX7cSm+WjhIMSuUCR
	H39kPjHczRIdek/u/sy7zan7KMky3df5yv/Gt8mO1JT8h+76iwGhhc2tf6KjZo2FSv9uO40Wusn
	1E6Iv4HdXdmLuf8jWFWUO6nb+fJjrb5AMxpjnpJrT+ZRvIMveetDPoppsgL/L18DIQCzneUL6R4
	9dHPkozAOkzhllnh0RDFtaSXGTEHDZX0OpHQrSYrFW5QbDJSx5v5R9izTrEv4NfrU9C6ZusPf85
	UCWMDrXxWCW+GU0fQIF0IqwoKKTDANB3K8gNqRB+MAcQ8/9EiFrcw67aaeYmr7VO/XpBjZj4uvP
	7vLj1s2UEbeTy6dTFPg4Coe0MVAv8zxXOUlQcGsmkwGWfaFNKPdxHp3ILNoQgMj4Qs1pv3qbp5K
	x9X8r2X47daPa3tNs/L6YEuI6JBIsrCeZAofRT0N2KbUjWyE6BK8t7K6r2Myg6qurvyXdl
X-Received: by 2002:a05:6a20:d4c:b0:3bf:8604:9a3c with SMTP id adf61e73a8af0-3cc71e020aamr22812606637.28.1786893780673;
        Sun, 16 Aug 2026 08:23:00 -0700 (PDT)
Received: from Roxy.localdomain ([2602:feda:30:ae86:216:b3ff:fe40:dc4])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-320e9df03d4sm24352629eec.15.2026.08.16.08.22.56
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 16 Aug 2026 08:22:59 -0700 (PDT)
From: Zhiling Zou <zhilinz@nebusec.ai>
To: lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Cc: horms@verge.net.au,
	ja@ssi.bg,
	pablo@netfilter.org,
	fw@strlen.de,
	phil@nwl.cc,
	vega@nebusec.ai,
	zhilinz@nebusec.ai
Subject: [PATCH nf 1/1] ipvs: bound LBLCR cache growth
Date: Sun, 16 Aug 2026 23:22:13 +0800
Message-ID: <62790a9f94ac5318f107a1811cff5a1f2fc7e0bf.1786884824.git.zhilinz@nebusec.ai>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <cover.1786884824.git.zhilinz@nebusec.ai>
References: <cover.1786884824.git.zhilinz@nebusec.ai>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

ip_vs_lblcr_new() creates a cache entry for every previously unseen
destination address. The table's max_size only tells the periodic
collector to reclaim entries after the cache has already exceeded the
limit. It does not reclaim entries that the attacker continues to use.

Reject new cache entries at max_size. The scheduler's existing fallback
continues to use the selected destination when cache creation fails, so
new traffic stays serviceable without growing the table.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Cc: stable@vger.kernel.org
Reported-by: Vega <vega@nebusec.ai>
Signed-off-by: Zhiling Zou <zhilinz@nebusec.ai>
---
 net/netfilter/ipvs/ip_vs_lblcr.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index f53f05ceea36f..91fa39edec0b5 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -363,6 +363,9 @@ ip_vs_lblcr_new(struct ip_vs_lblcr_table *tbl, const union nf_inet_addr *daddr,
 
 	en = ip_vs_lblcr_get(af, tbl, daddr);
 	if (!en) {
+		if (atomic_read(&tbl->entries) >= tbl->max_size)
+			return NULL;
+
 		en = kmalloc_obj(*en, GFP_ATOMIC);
 		if (!en)
 			return NULL;
-- 
2.43.0

