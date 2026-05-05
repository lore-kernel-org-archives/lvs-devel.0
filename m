Received: from mail.netfilter.org (mail.netfilter.org [217.70.190.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7D9E0C2FF;
	Tue,  5 May 2026 00:17:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.190.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777940231; cv=none; b=qEPndgUSHECeI1Wql2mdC0B+tp4d2a6NkvQPW5fZU1nHs1eE0svcETeFGRMPkEXOYiLzFsFRGr/YRVduYssEPVBJXBUDrxx10AGd1sahfAfZxC9569wVHr5HPe6utHNCtXVJnNIUPrAcKp7KbGUl3684dR2fVkzmg+mRN4qxm9o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777940231; c=relaxed/simple;
	bh=Y7XuH2T1xYAX8hmAwPeNJJEjlmyWEM2E97iT4uoi/FU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=hywF5mrT+s54mqTexRvfs7LLOOewvkHUK/g33MQTfLBnyulAHoM7LM5jD2FC7eFBVYtEAWZyLvPfD7s9j8uIN4PyBxrDtsTauVSwRpUofLsjgGXcI0MlGHzmCS3dixOr+P0vTcE97El25skayFi7tIWIFB7ecr4jQgkQPZgU6ec=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org; spf=pass smtp.mailfrom=netfilter.org; dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b=P1Lr1FtW; arc=none smtp.client-ip=217.70.190.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netfilter.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b="P1Lr1FtW"
Received: from localhost.localdomain (mail-agni [217.70.190.124])
	by mail.netfilter.org (Postfix) with ESMTPSA id 5AF7B60190;
	Tue,  5 May 2026 02:17:08 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1777940228;
	bh=eWoO6PceGx0ZuInGBG/K/cgrSUbT8QnGRHaTYrs6CQE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=P1Lr1FtWCcDUlL0P0R2iurYETzLNiCnEThA3U/b8sx1v6RnZXfZwTl8qTDHQjgt5C
	 VvckLis/zOZ8UeoUQiYeX+J7Hj5fP1RMYxlHl5r501KV8MitV7Mc9a6ItP2Lka4qSn
	 LClI+rv9qqa9JZyEVH4PZO+Gr40zrBAV1dtSbH8gDMEinWgZ7OBhjTIpKsvmMmt8JN
	 x0a+IssH/JxnAnAmkybvYo6Gh9laoD2SXLl7U9OQPjWygwRkdY/ZFC4SlcMwuST7P3
	 ufjqTg/mgwzXGCYUCyaJcUGQs9ChT/hBGAavycuVxh7YXTtOGM9PEuTgfJZjSmBS1N
	 v6DGRNckXXOYg==
From: Pablo Neira Ayuso <pablo@netfilter.org>
To: netfilter-devel@vger.kernel.org
Cc: davem@davemloft.net,
	netdev@vger.kernel.org,
	kuba@kernel.org,
	pabeni@redhat.com,
	edumazet@google.com,
	fw@strlen.de,
	horms@kernel.org,
	ja@ssi.bg,
	longman@redhat.com,
	lvs-devel@vger.kernel.org
Subject: [PATCH net 8/8] sched/isolation: Make HK_TYPE_KTHREAD an alias of HK_TYPE_DOMAIN
Date: Tue,  5 May 2026 02:16:48 +0200
Message-ID: <20260505001648.360569-9-pablo@netfilter.org>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20260505001648.360569-1-pablo@netfilter.org>
References: <20260505001648.360569-1-pablo@netfilter.org>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Waiman Long <longman@redhat.com>

Since commit 041ee6f3727a ("kthread: Rely on HK_TYPE_DOMAIN for preferred
affinity management"), kthreads default to use the HK_TYPE_DOMAIN
cpumask. IOW, it is no longer affected by the setting of the nohz_full
boot kernel parameter.

That means HK_TYPE_KTHREAD should now be an alias of HK_TYPE_DOMAIN
instead of HK_TYPE_KERNEL_NOISE to correctly reflect the current kthread
behavior. Make the change as HK_TYPE_KTHREAD is still being used in
some networking code.

Fixes: 041ee6f3727a ("kthread: Rely on HK_TYPE_DOMAIN for preferred affinity management")
Signed-off-by: Waiman Long <longman@redhat.com>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/sched/isolation.h | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/linux/sched/isolation.h b/include/linux/sched/isolation.h
index dc3975ff1b2e..cf0fd03dd7a2 100644
--- a/include/linux/sched/isolation.h
+++ b/include/linux/sched/isolation.h
@@ -20,6 +20,11 @@ enum hk_type {
 	HK_TYPE_KERNEL_NOISE,
 	HK_TYPE_MAX,
 
+	/*
+	 * HK_TYPE_KTHREAD is now an alias of HK_TYPE_DOMAIN
+	 */
+	HK_TYPE_KTHREAD = HK_TYPE_DOMAIN,
+
 	/*
 	 * The following housekeeping types are only set by the nohz_full
 	 * boot commandline option. So they can share the same value.
@@ -29,7 +34,6 @@ enum hk_type {
 	HK_TYPE_RCU     = HK_TYPE_KERNEL_NOISE,
 	HK_TYPE_MISC    = HK_TYPE_KERNEL_NOISE,
 	HK_TYPE_WQ      = HK_TYPE_KERNEL_NOISE,
-	HK_TYPE_KTHREAD = HK_TYPE_KERNEL_NOISE
 };
 
 #ifdef CONFIG_CPU_ISOLATION
-- 
2.47.3

