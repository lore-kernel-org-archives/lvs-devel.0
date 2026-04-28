Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5FE121448D5;
	Tue, 28 Apr 2026 18:00:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777399257; cv=none; b=bK5XhoqH6NLvfiL+VeIrXNkLPKpMSM6oU8lId2833lw6ByrfHWhp4yQDss2G/4C3gmtRP7QE//gVoKVNsPXmoyJluYEISZfjSpfQnaTOTS2A6Vzp9VZZikvOsMVEogVcS2xCK8R47ZAjeOUp19wZ70aeKiBl2BQ9l+37p1MEt4c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777399257; c=relaxed/simple;
	bh=cHpTXYdncN0sHiHi0Ms7JpGzF7pP+YHf+1oy4qGGudY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=GbfP9QU72tHopDJZne9oZPsOtD3SaEV0aQEhe5Jk5aBXi1t+byi5jrM+dKNt8d7VKCBpgXs1UnXeBZMky0Pop+exz+g+B+0HxTYU0d2z4Bm3XXju3wDVpn/9HjJHuILmQU+u1NhDK6K5/iLn358bIJ8z2WLcQSKlGSBWsnyjMYg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=VKbQLraQ; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="VKbQLraQ"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 45122211C1;
	Tue, 28 Apr 2026 21:00:53 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=ze54CW2mwfMfZTw+E7Thpy8KpJFaQca7HuFNShQe8X4=; b=VKbQLraQnBZN
	+9bYPZ4TKJU7wANWg9otMVdlZVcR/mqF1IQAXhQiFiwDKbsmceMuKY1LhFsQKjS8
	uXBxglQWcIpcLdzpUSrPTQdDaQm+12JV04kOaPjTiIq1TTvn/+ZxYZ+DO9KFp7a/
	9hR12XTSt5+JPwlivrzG2obDrgyRNOXYOUpiIohGkIqUIbHc4PUZ88CufgjHoNCb
	eTDt2gOF5Pa6YUmBIoWPVMK+/M+KwJ8VTCXET/pu6u0U1l+yM+5tqBB/xXaqEVP0
	mxCAr1PfdQ7B24yGO3aO3GerTGA17jF+0O3YtlIfavwvhc/NdD5uI24WyPk5hJz5
	i+q5lDq7hNnSLNvCODbeeoerUZFBp2dz4ANCJ+wMKl//ZiurI/ONMORZ8PLCkCKs
	6aFi7iWTwUPhhCHyoiAXm3W1goSj8oeexOnJiY5YUo88ssF0KDM1eEHIqu62V4gf
	B1V9MgfLJjtkAeD5ivKT5gEdxXRMG+CCyrbflFLkDSNwgA16njeZrashfOVvcaUF
	fMAm4OfGPVXBbJrJshJIfyz8UjyoF0UL2l5ricHmfu0VAoTLp0XcFP57WzrF/mre
	vPnWmtD7W/P7eAnMHFHO9arEBcT5ANPl/nRZ0TkjW0ZDU4GGKrLqQzRXgbNJZjw7
	4HkKnrqQpKE8wHcgT/CjxlmEwi7X6qM=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 28 Apr 2026 21:00:52 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 9B12B6089A;
	Tue, 28 Apr 2026 21:00:51 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63SHvogF072102;
	Tue, 28 Apr 2026 20:57:50 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 63SHvoCC072101;
	Tue, 28 Apr 2026 20:57:50 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        Waiman Long <longman@redhat.com>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org
Subject: [PATCH nf 6/7] sched/isolation: Make HK_TYPE_KTHREAD an alias of HK_TYPE_DOMAIN
Date: Tue, 28 Apr 2026 20:57:24 +0300
Message-ID: <20260428175725.72050-7-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260428175725.72050-1-ja@ssi.bg>
References: <20260428175725.72050-1-ja@ssi.bg>
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


