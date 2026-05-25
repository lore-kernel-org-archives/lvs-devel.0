Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B193614AD20;
	Mon, 25 May 2026 04:08:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779682083; cv=none; b=ODMFevvJwCn97uydwCnpGGdELy6RVlo9OfPdrjt3J4gDAHJKSMQMru3FZkLfhqk2K7R9rWd2Sy5WxKGwwW2giUuMgyd3k64Co/tniaBZAatiV9iUSd3ytFjyHOGzsqlSGo8Jikh7wTVzA+tSKXRJwAOFF3kvK1w0Uk7f3Nx5GoE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779682083; c=relaxed/simple;
	bh=lheOmNVUKSvglpmSlq5arDP4J1wXsJJ1oMSHGlFTrv0=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=pe3t/oKoFY4TaHfkHre937xd5if2btO1ZM9wYiJOF25k8Eg9BpwJwab4LkLJnNHk+gInyWtOw1VjfX9hkCcoL/0w+bjCu6qHPIklPEyK6FQQ/kxTjwxNgrHK1FkgcpP6CzcpmaFaCbnEsxS6sjfotEjltAnJswHKradzGuwWFjg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=acxM7IJV; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="acxM7IJV"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 756D820FA4;
	Mon, 25 May 2026 07:07:57 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=NceVd9kV
	H2smUxJA+lh6cjwALi6y9NGew8uCWO4/9DY=; b=acxM7IJVhlxsSc3Ie6dQSZy9
	3GUyQ1TQ3UBVyW98swE2NXuQ4Pumy+fXVYMrUJzZTbtWGQiIV3nBwKPhjP7DjNfu
	dHg9eL0gwW2R2sAUPhCOxB0K1nN8SYdR1PYLIZaAWX4ZTn/Ejwk4WYrlYcisZaGA
	u/MjXlZfIvnCJR3ilx+7Pro3+QGt0cC+y/LcvzEtBDsOqYpOwzw1GR7Nm/XZlZLN
	7wXtlmKRvL7tSquNakR3BuMnp4cHjwfjJh1Idb8gdiHfZ18K5ZseXqqGZnTsY3iE
	x5SyZ2I9lTYlHnxVAetVHVwGv/K7h1I69x3RsPCzdeX/DpDtoijXkZI9A/7F2V/r
	gWapGIX2dGn3Ocr6E96p8wDV329tGp7qucbII72Kdfsvpd4AMVRcF+ID30IBFM0b
	mDCoyOfId415me3/KSVxyR6Md+nyy7ZXUI+dI2gENxT0VijiRIRcd4/kJPSNCZwf
	7jvOJUHLcEBAX6+qBtc4f4ZJlwpc0VbcpJvOTsp/+eIWhM60iQqvd+Hr4jZxETwS
	H1xoiV1LFm224hAbS/QAXAaFm0ekT3lxWrkAQaMl/EfQZ3Rm9nhgkwP2+O+vB2Zl
	rID610G7xRlXcaDbhdEqz8ON7++hJUhejwY08NHKG0PJLSHEOZYYvPDg5psMVwrl
	bPM9b/WYSoPcqDGJl8A=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 25 May 2026 07:07:57 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 9BCAE60764;
	Mon, 25 May 2026 07:07:57 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.1) with ESMTP id 64P47umo006526;
	Mon, 25 May 2026 07:07:56 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 64P47uJM006525;
	Mon, 25 May 2026 07:07:56 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf] ipvs: clear the svc scheduler ptr early on edit
Date: Mon, 25 May 2026 07:07:44 +0300
Message-ID: <20260525040744.6509-1-ja@ssi.bg>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

ip_vs_edit_service() while unbinding the old scheduler clears
the svc->scheduler ptr after the scheduler module initiates
RCU callbacks. This can cause packets to use the old
scheduler at the time when svc->sched_data is already freed
after RCU grace period.

Fix it by clearing the ptr early in ip_vs_unbind_scheduler(),
before the done_service method schedules any RCU callbacks.

Also, if the new scheduler fails to initialize when replacing
the old scheduler, try to restore the old scheduler while still
returning the error code.

Link: https://sashiko.dev/#/patchset/20260519015506.634185-1-rosenp%40gmail.com
Fixes: 05f00505a89a ("ipvs: fix crash if scheduler is changed")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h              |  3 +--
 net/netfilter/ipvs/ip_vs_ctl.c   | 13 ++++++++-----
 net/netfilter/ipvs/ip_vs_sched.c | 14 +++++++-------
 3 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 5b3d1c681231..49297fec448a 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1846,8 +1846,7 @@ int register_ip_vs_scheduler(struct ip_vs_scheduler *scheduler);
 int unregister_ip_vs_scheduler(struct ip_vs_scheduler *scheduler);
 int ip_vs_bind_scheduler(struct ip_vs_service *svc,
 			 struct ip_vs_scheduler *scheduler);
-void ip_vs_unbind_scheduler(struct ip_vs_service *svc,
-			    struct ip_vs_scheduler *sched);
+void ip_vs_unbind_scheduler(struct ip_vs_service *svc);
 struct ip_vs_scheduler *ip_vs_scheduler_get(const char *sched_name);
 void ip_vs_scheduler_put(struct ip_vs_scheduler *scheduler);
 struct ip_vs_conn *
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index cca44d46f3e0..f765d1506839 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1898,7 +1898,7 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 	if (ret_hooks >= 0)
 		ip_vs_unregister_hooks(ipvs, u->af);
 	if (svc != NULL) {
-		ip_vs_unbind_scheduler(svc, sched);
+		ip_vs_unbind_scheduler(svc);
 		ip_vs_service_free(svc);
 	}
 	ip_vs_scheduler_put(sched);
@@ -1962,9 +1962,8 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
 	old_sched = rcu_dereference_protected(svc->scheduler, 1);
 	if (sched != old_sched) {
 		if (old_sched) {
-			ip_vs_unbind_scheduler(svc, old_sched);
-			RCU_INIT_POINTER(svc->scheduler, NULL);
-			/* Wait all svc->sched_data users */
+			ip_vs_unbind_scheduler(svc);
+			/* Wait all svc->scheduler/sched_data users */
 			synchronize_rcu();
 		}
 		/* Bind the new scheduler */
@@ -1972,6 +1971,10 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
 			ret = ip_vs_bind_scheduler(svc, sched);
 			if (ret) {
 				ip_vs_scheduler_put(sched);
+				/* Try to restore the old_sched */
+				if (old_sched &&
+				    !ip_vs_bind_scheduler(svc, old_sched))
+					old_sched = NULL;
 				goto out;
 			}
 		}
@@ -2027,7 +2030,7 @@ static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup)
 
 	/* Unbind scheduler */
 	old_sched = rcu_dereference_protected(svc->scheduler, 1);
-	ip_vs_unbind_scheduler(svc, old_sched);
+	ip_vs_unbind_scheduler(svc);
 	ip_vs_scheduler_put(old_sched);
 
 	/* Unbind persistence engine, keep svc->pe */
diff --git a/net/netfilter/ipvs/ip_vs_sched.c b/net/netfilter/ipvs/ip_vs_sched.c
index c6e421c4e299..24adc38942a0 100644
--- a/net/netfilter/ipvs/ip_vs_sched.c
+++ b/net/netfilter/ipvs/ip_vs_sched.c
@@ -56,19 +56,19 @@ int ip_vs_bind_scheduler(struct ip_vs_service *svc,
 /*
  *  Unbind a service with its scheduler
  */
-void ip_vs_unbind_scheduler(struct ip_vs_service *svc,
-			    struct ip_vs_scheduler *sched)
+void ip_vs_unbind_scheduler(struct ip_vs_service *svc)
 {
-	struct ip_vs_scheduler *cur_sched;
+	struct ip_vs_scheduler *sched;
 
-	cur_sched = rcu_dereference_protected(svc->scheduler, 1);
-	/* This check proves that old 'sched' was installed */
-	if (!cur_sched)
+	sched = rcu_dereference_protected(svc->scheduler, 1);
+	if (!sched)
 		return;
 
+	/* Reset the scheduler before initiating any RCU callbacks */
+	rcu_assign_pointer(svc->scheduler, NULL);
+	smp_wmb();	/* paired with smp_rmb() in ip_vs_schedule() */
 	if (sched->done_service)
 		sched->done_service(svc);
-	/* svc->scheduler can be set to NULL only by caller */
 }
 
 
-- 
2.54.0


