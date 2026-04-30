Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A8EA635836B;
	Thu, 30 Apr 2026 07:47:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777535278; cv=none; b=P5sDkaan1J0y/gOpIrgkPOpBFKRBEMOk53jsiv0XwOERgUKAkXlW6JbI/3tE5Yv1gvQ1VwrC7zB4IrCJskMX4K6JFQdtmRiAaAozT5+CVaKa+kOVMUngkJqLA4jyc7u0WymDOtrRA3F9MasNKcyOfYcP3MBUVclAUWEZ335rIu8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777535278; c=relaxed/simple;
	bh=q3hgn3XtgGXyTlNF4i4VVkcHuQBF9ThMMVu0/ffjyeo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=KURNvfakzSbV/DB4IDZ7vKs3sOwtx1DotBCRxmP6Man+50Hx1udnv5ZfWn+1ypECe1mIiOCx2nREFTyLOiDoCAGfyYVyL9wax/OkbZUq52O/MvU5G+BhR2iVCjDVC6JVoHMwmnRa2gNPRhfC5NzNv8441Os+hSQilPnfy/HQHig=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=KqkpTx22; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="KqkpTx22"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 0AAF42292A;
	Thu, 30 Apr 2026 10:47:54 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=gw69bEhoW4BCbmbNr3RmsbECGj6mMQOxqGgLHbtIkVE=; b=KqkpTx22L3Oa
	TLwMSmeBpYhgPiW2Wevu0/M0bu2dNqTHPsU7oX32OmqzBxn7WoqrDEfjtgsCOe5M
	sjR4FYAb7uwcAy2+CxcxfSdSvahRm9gRzb8W55b/vydnPTGwMAynwfcC7/ljKt0t
	OcCZMWKGVtqN71Wc3HklOvC2VOb7zXi6E4XD6OEtAiAtIA0o4id6QVaMNpsQxB7j
	Ad/GSJ9bCphRxXe4weTg5s6a/a6vuUW2sigLh7PpEqC/KvhaDofJxbx4976J1EOd
	Fp6+kIj+YlQMfPu241iHRh4FiWVw/0eyMoHi3QRrH4lQDP79PhMPEI+sDdxavgyW
	ck2WQmyeWtYmkacWt+np+jfI0q2O9ZMCApi8OH/kXYAFB6YUxwRN/LxmW2zQ3f5A
	FBhOdKRDjTG3f34jga2ivdssJweUqdK/EpgTpGMaFfEpnjybXL55OaPbqPKLIYpj
	+oh2pJzFchL+GhflBu+KQFGLqZkRyCeJ4NI3zkQPVf5eZjHsYIkxZEfGI3TiIcJ8
	0tjs/aKGwlClRv1oee7PLlbJ9PypjvyBEYxW1gezEWE/0kPsZ1fJHtq5e49J3bRU
	zgg7iaIY0KcPM2Yvz96mGz8P6Ad4N3XkldCGEFaUUUUniUnYcF4u+WqXHPoOEsF+
	zPp2n+Sm1otSn5EHUUVBi/n+DVj4Lh4=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 30 Apr 2026 10:47:52 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 6859B60818;
	Thu, 30 Apr 2026 10:47:52 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63U7ixT4027482;
	Thu, 30 Apr 2026 10:44:59 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 63U7ixHa027481;
	Thu, 30 Apr 2026 10:44:59 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        Waiman Long <longman@redhat.com>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org
Subject: [PATCHv3 nf 8/8] sched/isolation: Make HK_TYPE_KTHREAD an alias of HK_TYPE_DOMAIN
Date: Thu, 30 Apr 2026 10:44:20 +0300
Message-ID: <20260430074420.26697-9-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260430074420.26697-1-ja@ssi.bg>
References: <20260430074420.26697-1-ja@ssi.bg>
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


