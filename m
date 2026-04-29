Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 69DE53F166E;
	Wed, 29 Apr 2026 14:14:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777472053; cv=none; b=BV3k3b+YeJnH14APooHIcwZGZRvsPaV/UFKNhH+yuCXG4qLpbb3RUB+uVXHA1IGlM2nDpUCRshK8UzkYUOULXvGzTC2YHFj6s7bw0i4DD5vW2k9a6VoepeSjV7Pp8UIXaeGw0iTHFKxaboAsXjxG2p8JAPWeLzNAFmJU1XPRMLk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777472053; c=relaxed/simple;
	bh=q3hgn3XtgGXyTlNF4i4VVkcHuQBF9ThMMVu0/ffjyeo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=iUGe7yJT21lGItKYkCEo91zmTytwMMzhdHnR4qMiPZ6D5fYlvymh/A/a17x6SMlpwcCuLyj6nwz5ysoh+r1N/47d1QpLI8qcClG0tGyOGhZAxuG8QHT9J1UY9S5TE3ikFTaTEm1XTAx7T1HdE8Jn8M7jdZtJ/Y4wk3lnKcNnGIs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=C8zSWFFM; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="C8zSWFFM"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 3184D21C5F;
	Wed, 29 Apr 2026 17:14:09 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=gw69bEhoW4BCbmbNr3RmsbECGj6mMQOxqGgLHbtIkVE=; b=C8zSWFFMg/D1
	HARb5MdFd3h9xCNOmrIDyCbCoENCA2MN1XOMzLS9siBCKsRBL39wcTUH6n7X3QqX
	61MCx00++pGT1djV2og8Uu7pgvtqbCE5FvdNXKx5aXq03OvjwHrb419RUjLzFJu9
	lQU69wAju/BzCHX2oaIRWpnbUf7fgLca8cBa5P1spz7pxQVMabyGN6wHBf5TpWUm
	EIWzJVRLxYwXUkyEVgauNOFLD8y1nCXRX4tr1cs0aETRbZ/8IqkqV6NfBT0vNiyD
	E1UWJGJN6DO9LhLTFRwmjUqQ6PhD5QMfkDI9gsNy0eGX/rM2FQFAJ52rhmIr6e6o
	ImoYEOfzi9iU6QDEsyac09HTOqvTNunXBssVXdw1DxCcY92OEJJ9q3eLYQeRFGxp
	hZNL2Tb298GF9Dhvuaw6nAlXGTSLApyFAAHWG9DPqlccxEFHEdpwcasYvI87gL8x
	++9giJEBp4ZVQ7YVOIiMupOe9UbR6/XFxrGspom7WpxUPhatdu7QmkrpYhy0m/kJ
	JXVgbqcKUZ7qzt3dI5M9nNw0bp0SeFVxKZxlj85TdtDRXGmawoDyU/0Ox/QzrkLV
	mIXMmMGWH+8PWF9lnNiOcqj7/ZquZmYPsmJDsbK55HnRZuEUDeakZdoIbkqiWSE+
	ydbjTKsUNctBaYfFJ9OGjl5pr+vEDPc=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 29 Apr 2026 17:14:08 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 9FD966088F;
	Wed, 29 Apr 2026 17:14:07 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63TEBNAx085114;
	Wed, 29 Apr 2026 17:11:23 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 63TEBNE4085113;
	Wed, 29 Apr 2026 17:11:23 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        Waiman Long <longman@redhat.com>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org
Subject: [PATCHv2 nf 8/8] sched/isolation: Make HK_TYPE_KTHREAD an alias of HK_TYPE_DOMAIN
Date: Wed, 29 Apr 2026 17:10:55 +0300
Message-ID: <20260429141055.85052-9-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260429141055.85052-1-ja@ssi.bg>
References: <20260429141055.85052-1-ja@ssi.bg>
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
2.53.0


