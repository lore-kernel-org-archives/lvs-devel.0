Received: from mail-wm1-f46.google.com (mail-wm1-f46.google.com [209.85.128.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BE4FD481FC8
	for <lvs-devel@vger.kernel.org>; Fri, 15 May 2026 13:51:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.46
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1778853121; cv=none; b=Q/ASYA5UwGv8YQ9eeLuayxD2TCK/ZhnWlCQh0BgpvLIlI2tK5ZjWdFAx3Sj0wFweRlJT6OK7sTYyO12DrIZUGGfP/Bsw4hTBg6h/lnbOzlxDtf0FeZGBnUEgzsoiJ0cXE23A75Y+Q5SrDng2cPlYB8a3rBU5fhHaBob8STxoQec=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1778853121; c=relaxed/simple;
	bh=1BUYyH6FJjq+uusotHC0RGXtPrhUwifyqTlT3V5ZIPE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=eALsSWGECmqSgp0HeaSFTgokWTe1veW2EJ3mjieZUT1lRrHaq8P3ef1ZKiR409ab+9ScmsPgRFxlUMb4haJXeFKzlic1yHJN6+yx3MnYpUqlzDSmfkOk23C+d48HMg8sTQN+QOGEn8Dg8b7MPejhn8aIfvizFf4MoE2iXTzMfwI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=crNLsmaw; arc=none smtp.client-ip=209.85.128.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="crNLsmaw"
Received: by mail-wm1-f46.google.com with SMTP id 5b1f17b1804b1-48909558b3aso88631815e9.0
        for <lvs-devel@vger.kernel.org>; Fri, 15 May 2026 06:51:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1778853115; x=1779457915; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=VA+bG9JdAKJ8uzHR2B1IeGdcCKEHHSGhLn7eeSbzPvg=;
        b=crNLsmawSy5I0G7CrPgHYnHFdvt+hulqPo5UoyW92rWd76+QKownrE2B3DUYWlO1JL
         2/22skQB/KbImVFeu6hVTX9ex3e52K3JsaRa5wmBsb0k/u6nr7M3G9T6OHFtwilq65sW
         xwON24M9D5Ue3nFkwPQ0EaenIl9CDIOWvOme1bsTWeWi3cJMa2KErOp72g6lj3ASjczz
         tN2C7Cb3VGlaAz5yc2hQRGrjvEszxAa2qzS4983uqL5JYl0iZLxPKpvHDI4qGnnpF013
         1Y2qbng4JPUbuq2TYwUpPeD2xLWni6ZfPsnmTz11aZ/gIdO9NUhV7G7Qop9kYNUMCcpy
         nhYA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1778853115; x=1779457915;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=VA+bG9JdAKJ8uzHR2B1IeGdcCKEHHSGhLn7eeSbzPvg=;
        b=JrPzbnCZRsel8R+yTCxHinsmACIcikO2nm/nPDrraSrZqHkzvOcyOsPbLQIl8y6/gD
         KUqBEvttNxbKAdGi4Z5R7SnZUK60Yk3c4YW4Hq8AL+k4B4+klUfYY/wPfjzWbd7WWBnT
         +ndWeA2FE1+sZdQa8Y8xW0TQDllgNB8eMihpZ/VdUKf3Uw8MgJqlklp6U60aiwU0Cau/
         KMGH5daGL2EqtfyAZVw0kAyntZrtDocCDomnEYZBY3Ls3H7/1uTLPiLFnsGehiG+5HeT
         QXxYr0o0EjTjRsJWRROAMQqv6XXkKk9wOcoh5Ho/LrmGg2NiGkwLmKcpm9GZL2GLmo2R
         8vkQ==
X-Forwarded-Encrypted: i=1; AFNElJ99kZTDjamyN/C5v4YXfBxL6pgxxFPhebGgD0/qesRhiiIWPvDw4t+laKHAKnvGpmlkFvi9lqPvnhI=@vger.kernel.org
X-Gm-Message-State: AOJu0Yw60Cj/ii3WVppzpp/ngQddRVo49Pa/HPIVziwm3pp+CPl46dBx
	KSn13SSw5REl7+WoowSHJMZn7cPZTSCgUGTkzY24ofk/qzCmCX3gkh8uZBNuJXXpWhU=
X-Gm-Gg: Acq92OEQ1/gGsL4+AsBIAH7umEkdb/2khsXo6h9Tq5NHsQSSA4JjidI2ygnvfG1/FhY
	cR/G9LRRZ9dBuNsjiVIAnhZa8B6x5GsTQRf1QjAIg5uD9hjF+Qc9vRObRon8PhUlsXVfuKiRBne
	NZvCyFJA0xRrq1A4YI7NAhLxeTvliJRi6A0D9QnvFssL8oUmnynBo6wWZXu7oHWJipmDKKd2CHt
	5b85C+SaDk0hnfonrv4ITLmyTYLITraxhPGQAzBblYJRRSuV/eNEHmtGSNNYZ4ZnMo7IXVttv4x
	iHr/F57hOpC4HlSIhN+0jDSOFuul5mky3ZGQoDlTbg0AqyxO8uKFQwvSu6W/LGVvTgmD6ELA3RG
	XIH0Tg4ZcqCmL4LTmj5K5KAZ1kJ6kOHY029uqPN4HoOKisslba+TGTqw3Tk7noH5ZgqPKwFVJ19
	XTWudjbvnNzESpE4rDEoNwnxHx7ILd+DjRRgsGS6Y5V2Vp75w=
X-Received: by 2002:a05:600c:4fc9:b0:489:1c1f:35df with SMTP id 5b1f17b1804b1-48fe60e58ecmr54916975e9.10.1778853115149;
        Fri, 15 May 2026 06:51:55 -0700 (PDT)
Received: from localhost.localdomain ([2a00:6d43:105:c401:e307:1a37:2e76:ce91])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-48fdafc6741sm79592675e9.2.2026.05.15.06.51.54
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 15 May 2026 06:51:54 -0700 (PDT)
From: Marco Crivellari <marco.crivellari@suse.com>
To: linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>,
	Lai Jiangshan <jiangshanlai@gmail.com>,
	Frederic Weisbecker <frederic@kernel.org>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Marco Crivellari <marco.crivellari@suse.com>,
	Michal Hocko <mhocko@suse.com>,
	Simon Horman <horms@verge.net.au>,
	Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org
Subject: [PATCH v2 net-next 2/2] ipvs: Replace use of system_unbound_wq with system_dfl_long_wq
Date: Fri, 15 May 2026 15:51:37 +0200
Message-ID: <20260515135143.259669-3-marco.crivellari@suse.com>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260515135143.259669-1-marco.crivellari@suse.com>
References: <20260515135143.259669-1-marco.crivellari@suse.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This patch continues the effort to refactor workqueue APIs, which has begun
with the changes introducing new workqueues and a new alloc_workqueue flag:

   commit 128ea9f6ccfb ("workqueue: Add system_percpu_wq and system_dfl_wq")
   commit 930c2ea566af ("workqueue: Add new WQ_PERCPU flag")

The point of the refactoring is to eventually alter the default behavior of
workqueues to become unbound by default so that their workload placement is
optimized by the scheduler.

Before that to happen, workqueue users must be converted to the better named
new workqueues with no intended behaviour changes:

   system_wq -> system_percpu_wq
   system_unbound_wq -> system_dfl_wq

This way the old obsolete workqueues (system_wq, system_unbound_wq) can be
removed in the future.

This specific work is considered long, so enqueue it using
system_dfl_long_wq instead of system_dfl_wq.

Cc: Julian Anastasov <ja@ssi.bg>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Florian Westphal <fw@strlen.de>
Cc: Phil Sutter <phil@nwl.cc>
Cc: lvs-devel@vger.kernel.org
Cc: netfilter-devel@vger.kernel.org
Cc: coreteam@netfilter.org
Link: https://lore.kernel.org/all/20250221112003.1dSuoGyc@linutronix.de/
Suggested-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Marco Crivellari <marco.crivellari@suse.com>
---
 net/netfilter/ipvs/ip_vs_conn.c |  4 ++--
 net/netfilter/ipvs/ip_vs_ctl.c  | 10 +++++-----
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 9ea6b4fa78bf..4a5c6762489c 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -285,7 +285,7 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
 	/* Schedule resizing if load increases */
 	if (atomic_read(&ipvs->conn_count) > t->u_thresh &&
 	    !test_and_set_bit(IP_VS_WORK_CONN_RESIZE, &ipvs->work_flags))
-		mod_delayed_work(system_unbound_wq, &ipvs->conn_resize_work, 0);
+		mod_delayed_work(system_dfl_long_wq, &ipvs->conn_resize_work, 0);
 
 	return ret;
 }
@@ -916,7 +916,7 @@ static void conn_resize_work_handler(struct work_struct *work)
 
 out:
 	/* Monitor if we need to shrink table */
-	queue_delayed_work(system_unbound_wq, &ipvs->conn_resize_work,
+	queue_delayed_work(system_dfl_long_wq, &ipvs->conn_resize_work,
 			   more_work ? 1 : 2 * HZ);
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c7c7f6a7a9f6..49cbc7cfe770 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -800,7 +800,7 @@ static void svc_resize_work_handler(struct work_struct *work)
 	if (!READ_ONCE(ipvs->enable) || !more_work ||
 	    test_bit(IP_VS_WORK_SVC_NORESIZE, &ipvs->work_flags))
 		return;
-	queue_delayed_work(system_unbound_wq, &ipvs->svc_resize_work, 1);
+	queue_delayed_work(system_dfl_long_wq, &ipvs->svc_resize_work, 1);
 }
 
 static inline void
@@ -1833,7 +1833,7 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 	/* Schedule resize work */
 	if (t && ip_vs_get_num_services(ipvs) > t->u_thresh &&
 	    !test_and_set_bit(IP_VS_WORK_SVC_RESIZE, &ipvs->work_flags))
-		queue_delayed_work(system_unbound_wq, &ipvs->svc_resize_work,
+		queue_delayed_work(system_dfl_long_wq, &ipvs->svc_resize_work,
 				   1);
 
 	*svc_p = svc;
@@ -2078,7 +2078,7 @@ static int ip_vs_del_service(struct ip_vs_service *svc)
 	} else if (ns <= t->l_thresh &&
 		   !test_and_set_bit(IP_VS_WORK_SVC_RESIZE,
 				     &ipvs->work_flags)) {
-		queue_delayed_work(system_unbound_wq, &ipvs->svc_resize_work,
+		queue_delayed_work(system_dfl_long_wq, &ipvs->svc_resize_work,
 				   1);
 	}
 	return 0;
@@ -2511,7 +2511,7 @@ static int ipvs_proc_conn_lfactor(const struct ctl_table *table, int write,
 		} else {
 			WRITE_ONCE(*valp, val);
 			if (rcu_access_pointer(ipvs->conn_tab))
-				mod_delayed_work(system_unbound_wq,
+				mod_delayed_work(system_dfl_long_wq,
 						 &ipvs->conn_resize_work, 0);
 		}
 	}
@@ -2543,7 +2543,7 @@ static int ipvs_proc_svc_lfactor(const struct ctl_table *table, int write,
 			    READ_ONCE(ipvs->enable) &&
 			    !test_bit(IP_VS_WORK_SVC_NORESIZE,
 				      &ipvs->work_flags))
-				mod_delayed_work(system_unbound_wq,
+				mod_delayed_work(system_dfl_long_wq,
 						 &ipvs->svc_resize_work, 0);
 			mutex_unlock(&ipvs->service_mutex);
 		}
-- 
2.54.0

