Received: from mail-pj2-f12.google.com (mail-pj2-f12.google.com [74.125.227.140])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9986034D4E9
	for <lvs-devel@vger.kernel.org>; Sat, 12 Sep 2026 17:32:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.140
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789234358; cv=none; b=mE2ISNgsGAn77USDqF76uAPHa1hacTgXro+xaup+oVwkYF6rFZt2qEdg33frMHc1Ckks4+uEfvH3dkwX1MT6mTDYPLK9hBDSFNsNzoInqg45EDw6XZlkkl1HAfxcw9PbP9gRRDBgEu58vF6e1WOCaxen9q0sszO1+CHPhjjvhIs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789234358; c=relaxed/simple;
	bh=lve2EsB2hs9Y8E9j67jUUT/nDLV2/u9vDOpqbLUHmI8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=sU+aLrrTm9gRY7BWvC7r20O1qnZNbboNCk8+WnUNrPBtXF5/Ugnqa1uf4xTn0qxiFPOBv+X+GkVOcWjBGP25XUbipp3JXQlgyQfN0Qi73ipdh38LA8rZSWpOp/A5SE2nrb8n5WTdpHDRO9gvI/qhJYThkFsBguD91Z5Su+oZPLk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai; spf=pass smtp.mailfrom=nebusec.ai; dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b=S2THpxcz; arc=none smtp.client-ip=74.125.227.140
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b="S2THpxcz"
Received: by mail-pj2-f12.google.com with SMTP id d9443c01a7336-2db18fe433fso4239255ad.2
        for <lvs-devel@vger.kernel.org>; Sat, 12 Sep 2026 10:32:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=nebusec.ai; s=google; t=1789234357; x=1789839157; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Ec521DbyAbnsfPoQqBQrUW9bKkbot60dD0ws3n8tHwA=;
        b=S2THpxczX1FOvPf/t1rKCEmcPQAwNKj7wmcOYL502QM0007I0Un/X1VdTFaz/ee49K
         Vb6dp/VhGSv2InwhNC1930G8byRUVPSRYYZqpajfCNaZmgtVfb5w/m0lyCLU8GaPqOsF
         CJshUHkKx/qeirkl4Pwg8alptZRZS2fnn5IuyG2EHcvKitC+aiBHt4vkU375l7B+jHyi
         6IxryrEiNsO1mYOwLmxBGsEPOiCK91NODUHaxomsdXetsUS8EWbX98S1x0SBRPja1ioP
         bc17MXOCUkCaYeP55a9FCsEmW/FF2KXOj2DnbQnhMI4xtMH4oVLU2Oe2Y2BQtfZC/Yzc
         HeQg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1789234357; x=1789839157;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=Ec521DbyAbnsfPoQqBQrUW9bKkbot60dD0ws3n8tHwA=;
        b=DqzJqSzrm/shD7Ajuaea1gRzFCH+MNpxrOOtOGDb8YcNZJaJxbAO7ItGAfH3+WyJEV
         gTdk9XRkxdzhSaKivEDxsLI7hycOsw+cg2GxY4aU+AFwQrrh54B6Rj1eCgkRGb5xuGXf
         GDxvzL6JeAYq5eV3U4Mofrotktn6lueUsTvltJWqtcG2IEdwBqGmXSFf/V1dWPRH9RCq
         xb0Vk4138V3pdW3/wllqrAe4qyX1ps2tqoOgWO0WVdzZQzpj7av95fAJZUiSrebDhW8m
         HZQcMWCZn1ZwG6jLzlUqqqt3Z2hOQGmZZGx7s2gS/mP9XMUODinqN8hWfyp5ORDBqiNC
         Wnyg==
X-Gm-Message-State: AFuF++n06JeSP574G9wy6rrr2jQhj6ucm1ZZGHwRoMOaZwo/bXSR0NhC
	xddWzfIRde7XNbWVf+9sO+tGr0q4SL5vmyGkGomj5QPbQc/Ozbq6lXpiBJjRo4MVrC7VCaVGlaX
	w3URuR9g8
X-Gm-Gg: AYBFou3t9HvusI5Oq3x+EIGRCUOr0RN4lK7egFZeCqTOatz2vKS+B02SsjWZKPHicN1
	WnDIG1QlQlxAmxmDDeWvRLGQLRZc32usijaXsIirEPn9VbD1syUuW7nZTwb8nfcX9BOpF/XIK6N
	obVgsjGlgLncVtoKvBIKxzKM8NakzlejuJZo0fFZXtIPHvhxJvaRb16zzxyzQyYyyj8GwumWsmL
	cr7Xlal9JIL9+sZaBeItVnBHT0EQcOqDugfipv2iWN+IzbWhzIo+670cUs/VaoGrFUALVuaa4oE
	S24qLgQNX2trGuTMWF8kRbNHUxVITz4xBzyQZqisnenAjphRHclnSv3QzYbhqP0jNGQXvQf1oMU
	kQLbu2wAIuuIO/ULpk3fNg8p+BCo8gydXora+eY+OGbIVV4c5VRxCJYzIxGnB0W7HiWzSzlUQH/
	W17HKCBguihX4gR37STX7sK1MWvHWHRXeOLpbS06VXHg5Oh/Yt7YYmALe+gN3U3k+HSn9Q3QzRj
	oZKNOzCCg==
X-Received: by 2002:a17:902:dac4:b0:2db:20fa:9443 with SMTP id d9443c01a7336-2dd4bd64dbbmr62198645ad.13.1789234356998;
        Sat, 12 Sep 2026 10:32:36 -0700 (PDT)
Received: from enjou-Legion-Y7000P-2019 ([167.71.204.91])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-2dd2ce9c8besm25541255ad.18.2026.09.12.10.32.31
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 12 Sep 2026 10:32:36 -0700 (PDT)
From: Ren Wei <weir@nebusec.ai>
To: lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Cc: horms@verge.net.au,
	ja@ssi.bg,
	pablo@netfilter.org,
	fw@strlen.de,
	phil@nwl.cc,
	darby.payne@gmail.com,
	vega@nebusec.ai,
	zzyy19904204639@163.com,
	weir@nebusec.ai
Subject: [PATCH net 1/1] ipvs: bound twos scheduler destination walks
Date: Sun, 13 Sep 2026 01:31:49 +0800
Message-ID: <d8b3a70308530e670f94249ec28d31b23e6d5968.1789117690.git.zzyy19904204639@163.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1789117690.git.zzyy19904204639@163.com>
References: <cover.1789117690.git.zzyy19904204639@163.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Darong Lu <zzyy19904204639@163.com>

Bound both TWOS scheduler passes by the number of destinations in the
service. Destination list entries can be unlinked and reused while an RCU
reader is traversing the list. If a destination is relinked before the
reader completes, following the list can otherwise leave the original
service list and loop indefinitely.

Keep the existing RCU list traversal and scheduler behavior while ensuring
that a stale iterator cannot run without bound.

Fixes: 012da53d1afb ("ipvs: add weighted random twos choice algorithm")
Cc: stable@vger.kernel.org
Reported-by: Vega <vega@nebusec.ai>
Assisted-by: LLM
Signed-off-by: Darong Lu <zzyy19904204639@163.com>
Signed-off-by: Ren Wei <weir@nebusec.ai>
---
 net/netfilter/ipvs/ip_vs_twos.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_twos.c b/net/netfilter/ipvs/ip_vs_twos.c
index dbb7f5fd4688..42a9c07b94e4 100644
--- a/net/netfilter/ipvs/ip_vs_twos.c
+++ b/net/netfilter/ipvs/ip_vs_twos.c
@@ -44,14 +44,19 @@ static struct ip_vs_dest *ip_vs_twos_schedule(struct ip_vs_service *svc,
 					      const struct sk_buff *skb,
 					      struct ip_vs_iphdr *iph)
 {
-	struct ip_vs_dest *dest, *choice1 = NULL, *choice2 = NULL;
 	int rweight1, rweight2, weight1 = -1, weight2 = -1, overhead1 = 0;
+	struct ip_vs_dest *dest, *choice1 = NULL, *choice2 = NULL;
 	int overhead2, total_weight = 0, weight;
+	unsigned int num_dests;
 
 	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
 
+	num_dests = READ_ONCE(svc->num_dests);
+
 	/* Generate a random weight between [0,sum of all weights) */
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
+		if (!num_dests--)
+			break;
 		if (!(dest->flags & IP_VS_DEST_F_OVERLOAD)) {
 			weight = atomic_read(&dest->weight);
 			if (weight > 0) {
@@ -74,7 +79,10 @@ static struct ip_vs_dest *ip_vs_twos_schedule(struct ip_vs_service *svc,
 	rweight2 = get_random_u32_below(total_weight);
 
 	/* Pick two weighted servers */
+	num_dests = READ_ONCE(svc->num_dests);
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
+		if (!num_dests--)
+			break;
 		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
 
-- 
2.53.0
