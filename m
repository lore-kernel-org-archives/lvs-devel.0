Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 234603EAC60;
	Wed, 22 Apr 2026 13:58:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776866326; cv=none; b=Lcjzbq5mzID/WO9Owkx4Ao/2A+jqNiK8uqx1jjNk34+hJwlk/kZzGhoGQCjwFJ/JFm6dQj+pUp3RcZq5QaU1ofC8Gc5XpqcJ5y7xK8cfi0uDj6jXxkahMI2TjNp9FQaerTX8Soy0iqB6q4i9q26Y9dVPbphQz3/qKlx9iOOHZPY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776866326; c=relaxed/simple;
	bh=QqMJ8APZXAv/jThgzkl48ZDqf4rg3RNwu38GuypsDSw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=MM1IQOz2dPVF8xRFgYzmg/D021NtpolM/kBQLrl6m5JATZZRvdJKpsb+XH6mHGUSrszVAoA53BOgQ92QxUTrV/TIiIgsqph5kiunddzUvbHaKhF1r+YpXSMBcTSah1HB0xzYC4GA0nY5FiWSadhuWeehHLZj2ra8epDNuI8gDrY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=YQ0zh3Tf; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="YQ0zh3Tf"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 5961021267;
	Wed, 22 Apr 2026 16:58:36 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=HWSPzETrY78Q6YnxMY7oGENlOhhIgC8vQ9vEXd3xBuI=; b=YQ0zh3TfLzLH
	j4Xf9adASkNRShzHUrGcT02kCSKodw9wm55zAyzjCDL9yrCjIuZUJ72Hv/bKrV8c
	OSAS8qAMPwjFdom8MIcLAh5pZJSEcxNGAeoMOiB2gViwuvRkPCj2S8n5PbqYq3tD
	YO5b89ICKfrOV37zCyEZWaqesgIommLFkaK96MrDp4cn/H1iHF3uIvr7SlC0dyID
	mSNTs4uI0CIvh601t0k8sOimyZeigVmfYOoJIzNJyMysqYAPVvfj1f32tNcQuG+U
	VibqGDm46Jsom4hIDSSiuzc6ihSu1U86ymoezhIBZl/llbfWhmXxl1eu64DsR/VD
	FitRhWflGxEMtlUyJUXGvriwOAAMYkmyZxL7poZjG16xeQSNupjyquS0ImnNMz/n
	AyQfPtHV9R7Uo+xFqjETJ2h+Kp2O5BYZyi8rd3345uoYZd5gs4SbLSx7+13uJtAc
	7TW0m18SiAfXoKSDMhmQbmwfIvIcjkoMqatCOW0FD8HdKA0ly2lLmzlcJVf+ajFP
	h2RSuVHkknrOGVM5QrohPgjP3xi047wcryCcthWW/PtXhgZdZBf9ni20/ytFJRwz
	Fxzxqnyzjs8GxfqPNC8e1yZUXXH21ta0hhdRcbGCEf5uTmVP+xVQJWFxH0/3DexB
	J9Pt7fVOgGb/pyzVhSxfgDqq/FkCqx0=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 22 Apr 2026 16:58:34 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 8ED3560EE6;
	Wed, 22 Apr 2026 16:58:34 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63MDwYS7050517;
	Wed, 22 Apr 2026 16:58:34 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 63MDwYPr050516;
	Wed, 22 Apr 2026 16:58:34 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCHv3 net 2/3] ipvs: fix races around the conn_lfactor and svc_lfactor sysctl vars
Date: Wed, 22 Apr 2026 16:58:22 +0300
Message-ID: <20260422135823.50489-3-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260422135823.50489-1-ja@ssi.bg>
References: <20260422135823.50489-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Sashiko warns that the new sysctls vars can be changed
after the hash tables are destroyed and their respective
resizing works canceled, leading to mod_delayed_work()
being called for canceled works.

Solve this in different ways. conn_tab can be present even
without services and is destroyed only on netns exit, so use
disable_delayed_work_sync() to disable the work instead of
adding more synchronization mechanisms.

As for the svc_table, it is destroyed when the services
are deleted, so we must be sure that netns exit is not
called yet (the check for 'enable') and the work is
not canceled by checking all under same mutex lock.

Also, use WRITE_ONCE when updating the sysctl vars as we
already read them with READ_ONCE.

Link: https://sashiko.dev/#/patchset/20260410112352.23599-1-fw%40strlen.de
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_conn.c |  2 +-
 net/netfilter/ipvs/ip_vs_ctl.c  | 12 +++++++++---
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 2082bfb2d93c..84a4921a7865 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1835,7 +1835,7 @@ static void ip_vs_conn_flush(struct netns_ipvs *ipvs)
 
 	if (!rcu_dereference_protected(ipvs->conn_tab, 1))
 		return;
-	cancel_delayed_work_sync(&ipvs->conn_resize_work);
+	disable_delayed_work_sync(&ipvs->conn_resize_work);
 	if (!atomic_read(&ipvs->conn_count))
 		goto unreg;
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 27e50afe9a54..caec516856e9 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2469,7 +2469,7 @@ static int ipvs_proc_conn_lfactor(const struct ctl_table *table, int write,
 		if (val < -8 || val > 8) {
 			ret = -EINVAL;
 		} else {
-			*valp = val;
+			WRITE_ONCE(*valp, val);
 			if (rcu_access_pointer(ipvs->conn_tab))
 				mod_delayed_work(system_unbound_wq,
 						 &ipvs->conn_resize_work, 0);
@@ -2496,10 +2496,16 @@ static int ipvs_proc_svc_lfactor(const struct ctl_table *table, int write,
 		if (val < -8 || val > 8) {
 			ret = -EINVAL;
 		} else {
-			*valp = val;
-			if (rcu_access_pointer(ipvs->svc_table))
+			mutex_lock(&ipvs->service_mutex);
+			WRITE_ONCE(*valp, val);
+			/* Make sure the services are present */
+			if (rcu_access_pointer(ipvs->svc_table) &&
+			    READ_ONCE(ipvs->enable) &&
+			    !test_bit(IP_VS_WORK_SVC_NORESIZE,
+				      &ipvs->work_flags))
 				mod_delayed_work(system_unbound_wq,
 						 &ipvs->svc_resize_work, 0);
+			mutex_unlock(&ipvs->service_mutex);
 		}
 	}
 	return ret;
-- 
2.53.0


