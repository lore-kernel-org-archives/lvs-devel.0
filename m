Received: from mail-qv2-f12.google.com (mail-qv2-f12.google.com [74.125.230.140])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DEC0E4A4825
	for <lvs-devel@vger.kernel.org>; Fri, 25 Sep 2026 14:12:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.230.140
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790345523; cv=none; b=YPGrSv6XlklsZhU0eHaBG/eFN9mTb5zo+4YRcLz/wdE+vEbiE/zFRbXgFPvBwkxR26jHAaTfJJgimqa7fu7osYCOgJTxXvJweBasfPqgReWrFtZ/vCrBX/lPVK+L1eKNanope02TZ6FPMI/F9q0qtdMP55oQ5eCk8njuiiRD/XI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790345523; c=relaxed/simple;
	bh=kpB+P5IgBraa5hfYbRLKKdjLjknHhjJvEYrNAH8GIMc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=b+mopalMxWqklVoM6D1JbIlTD0XGhvdqjaSRQ9x4KIe8R8hROFSRkkKjruxCtTbXDF1G0WDIswZIc4Jf4r/QYuGwx+6IbzyN+rFz5upOwMAJ9G8zttTz92qKp2RXA+Nt6ALzzoHyW+eN66of66fFcLfJASmF4rmdJ9GWd54Ydcc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=1password.com; spf=pass smtp.mailfrom=agilebits.com; dkim=pass (1024-bit key) header.d=1password.com header.i=@1password.com header.b=nH+kadg8; arc=none smtp.client-ip=74.125.230.140
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=1password.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=agilebits.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=1password.com header.i=@1password.com header.b="nH+kadg8"
Received: by mail-qv2-f12.google.com with SMTP id 6a1803df08f44-91235f46716so8523036d6.1
        for <lvs-devel@vger.kernel.org>; Fri, 25 Sep 2026 07:12:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1password.com; s=google; t=1790345521; x=1790950321; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=FWmHRI/KalPjXKg4Cpy0gjt++WenU4Jtw+yVPdV0Dtg=;
        b=nH+kadg8ghdbHzRMicK38xeYz9eaoNXC/Vo+pCEl+iq42earwmE/qeQ6DVLZqfZjI/
         FaQBwuKAvlKmDVf8NA2pQ8dePGsXIBdgqh0PnM7/p6lmg6JHbyQpoxe/em9Bk5hvAIdV
         jaZu36q5haKidAKZ4bH+iTz3lgtNxxuVZ3DlY=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790345521; x=1790950321;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=FWmHRI/KalPjXKg4Cpy0gjt++WenU4Jtw+yVPdV0Dtg=;
        b=GTFplPGEv3xQEJ6rR8aD+n8hnnbUFXeuYKTcXLQQm16Pdrj//GYoRxHCrGfF0kbo5K
         8WO5i2j/07jUBLkfBeNb5Bo7bbeKxJk20idbAqZ5NFRfGXQ/yeX+Vr/llChltxaWj/Rv
         aQ7QTn6CtrbcMS2opArHp1FoQpoLkiCpz2TFNqfWbUVP+dusFENkD9TG8qjOa6/8bkoU
         q7jUeMZWHeikwWKKyGE+iTWY9Jg0jFa2IkTpAt7GDY8nf0R3OFQosT27WqvBzEtya8oS
         BX5LiIX0h6GzuJN06vvT72vdk1dzP2CB3O9hDHvvHGWGZyoE5KhZPQ6CHlsQBeRAwivf
         SzBQ==
X-Forwarded-Encrypted: i=1; AKwUvBzk8rDBKQM0gMZOcNfM+0fyBZZ/7Xt5exKAx4IlvDqPryQhngvbUSF0o5HFcfEXkRsxBpdnSe85DfQ=@vger.kernel.org
X-Gm-Message-State: AFuF++nWB70jErdFJg+vfCXfL64RIsg1ddmBiuBJ4lrek2yvSJfR5IdC
	+fkhGYJMBhjnbqm9zP5hi3Vec92teLlQTkXG848uOdG6gTJY06tBYro3CPc5PuiX2II=
X-Gm-Gg: AYBFou3pxGbC3OYnxtmYWJteMVsZtxd4l03lKIzt8SHKbr070McVnLlqyONYWixCQo7
	JFwO5rNu1iV/ce5jdfMM61j1R62o1RACzR4zagG8ouEYnavMYxjEqK004BL+xv9IthR/TBQ7Y7J
	5gtMxKPkf5rjPDYfpyJ+gbpgAk8tcC+7JjVc/NHr7aOfJ0PvdnhuNFhyecbgjas16arR1Cs7AkQ
	5f2tk+xzqwleqL4bTU9j5qhXNbcJhJqesUybFDRX28w5PGJ2crdGePlnE8YmUat+kX4WTrjkYF2
	qONc/xYlzJO2JYRS4nssuNuEU9IDTyum9Bycv0EfNch7gvj5vOw8Bo+ICOSamq/rDUpfjBzWG54
	nIuL+FZLp/r6qjt9XYurq3BK9KfHO7OPdI47Wkt73tStVDyB7vFY3s6PpP5wwCQky5sXM2FzgFQ
	OozN0NKR2lZoReCxsNyYFteq7XuRLgyUNQKVKoDgMQisT2PGtHPV+Qk9/3PoDZVkXi6XZXpGtf6
	vnC5cO8FTLFX4xuVM8nje+dY037+qfN2/rkqCsn
X-Received: by 2002:a05:6214:5f02:b0:912:5b19:ed61 with SMTP id 6a1803df08f44-9142f68bfcamr42218396d6.16.1790345520657;
        Fri, 25 Sep 2026 07:12:00 -0700 (PDT)
Received: from localhost ([2600:4041:59c3:300:7917:c7f6:28c6:182b])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-91430da9123sm17878676d6.16.2026.09.25.07.12.00
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 25 Sep 2026 07:12:00 -0700 (PDT)
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
Subject: [PATCH nf 2/2] ipv6: update *offset for non-first fragments in ipv6_find_hdr()
Date: Fri, 25 Sep 2026 10:11:55 -0400
Message-ID: <20260925141155.17603-3-axel.mierczuk@1password.com>
X-Mailer: git-send-email 2.50.1
In-Reply-To: <20260925141155.17603-1-axel.mierczuk@1password.com>
References: <20260925141155.17603-1-axel.mierczuk@1password.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The non-first fragment early return is the only successful exit of
ipv6_find_hdr() that leaves *offset untouched. IPVS used the initial
offset as if it had been updated.

For non-first fragments with target < 0, set *offset immediately
after the Fragment header, at the start of the fragment payload.
Callers must still account for the nonzero fragment offset. A
NEXTHDR_FRAGMENT search continues to return the Fragment header's
offset. Other target < 0 callers check the returned fragment offset
or ignore *offset here.

Suggested-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Axel Mierczuk <axel.mierczuk@1password.com>
---
 net/ipv6/exthdrs_core.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/exthdrs_core.c b/net/ipv6/exthdrs_core.c
index 4a9748338cf4..e27f5b8cc154 100644
--- a/net/ipv6/exthdrs_core.c
+++ b/net/ipv6/exthdrs_core.c
@@ -179,7 +179,10 @@ EXPORT_SYMBOL_GPL(ipv6_find_tlv);
  *
  * Note that non-1st fragment is special case that "the protocol number
  * of last header" is "next header" field in Fragment header. In this case,
- * *offset is meaningless and fragment offset is stored in *fragoff if fragoff
+ * for target < 0, *offset points immediately after the Fragment header,
+ * at the start of the fragment payload. Callers must still account for
+ * the nonzero fragment offset before interpreting the payload. The
+ * fragment offset is stored in *fragoff if fragoff
  * isn't NULL.
  *
  * if flags is not NULL and it's a fragment, then the frag flag
@@ -261,6 +264,7 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
 				     hp->nexthdr == NEXTHDR_NONE)) {
 					if (fragoff)
 						*fragoff = _frag_off;
+					*offset = start + sizeof(struct frag_hdr);
 					return hp->nexthdr;
 				}
 				if (!found)
-- 
2.43.0

