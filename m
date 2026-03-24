Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D193440628F
	for <lvs-devel@vger.kernel.org>; Tue, 24 Mar 2026 15:19:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774365558; cv=none; b=B0povDeTZGcIP8o6rJZn0d3P7hn+X2cwbNm0OmkGMynCnA1zCv/4CLSkfUhCGWSc1D/LAZH6RDvzQuD82UMdLTkKNfgnKnmTZMecCVboKYriNXFmlD3lBwnOVaMusZaYtQqksVzgxm+pq89rhbcdbXWfmDOPMN/K6fdPaKsJohA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774365558; c=relaxed/simple;
	bh=Wx3rCjft+f2xsQztl0u/tUkCuC3NJhEmQV+HjeE0iDk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=TzWlUdJdmg09nT0KhuhCflWDXEnL9CJXxWjKL0Zum7XQdQjFufGEm3PTrXSYzDNY6L9k5wsCOQX3N0VJeZtPFFOMQCWZBcPs2bim7X4loIk1NMwRj0m+BZ3ljI+fbJGhADOY7faX9tjH142QygPVuABDtRY2yWPlMCVA2IzM6MI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=WlRLJGLa; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="WlRLJGLa"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1774365554;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=NM71jEPy1P0WHGHdPzJuToYXqWbTBefaY9NqYpg0IOU=;
	b=WlRLJGLaocWuv43wVheFfrNnOxaJkFrioOQ1vZ+6o59n4Gc8fIDqzcoT/ecZncmMrq6Gkd
	byJcNEF5v0oFAohAb6zZv6fehUItAud+Qtaa861Q51DzuFf7KQspSbu6sQobJ6yLA9mr4m
	EQrlQKXeda8h4O4BP26rNOPlU9M/3wo=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-352-M9C8THMbPsyL3eIxAPqsKA-1; Tue,
 24 Mar 2026 11:19:07 -0400
X-MC-Unique: M9C8THMbPsyL3eIxAPqsKA-1
X-Mimecast-MFC-AGG-ID: M9C8THMbPsyL3eIxAPqsKA_1774365545
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 363C61944DCB;
	Tue, 24 Mar 2026 15:19:04 +0000 (UTC)
Received: from llong-thinkpadp16vgen1.westford.csb (unknown [10.22.65.192])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id A712D18001FE;
	Tue, 24 Mar 2026 15:18:57 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	"David S. Miller" <davem@davemloft.net>,
	David Ahern <dsahern@kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	Frederic Weisbecker <frederic@kernel.org>,
	Chen Ridong <chenridong@huawei.com>,
	Phil Auld <pauld@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	sheviks <sheviks@gmail.com>,
	Waiman Long <longman@redhat.com>
Subject: [PATCH 1/2] sched/isolation: Make HK_TYPE_KTHREAD an alias of HK_TYPE_DOMAIN
Date: Tue, 24 Mar 2026 11:18:26 -0400
Message-ID: <20260324151827.2006656-2-longman@redhat.com>
In-Reply-To: <20260324151827.2006656-1-longman@redhat.com>
References: <20260324151827.2006656-1-longman@redhat.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.93

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

