Received: from mail.netfilter.org (mail.netfilter.org [217.70.190.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B94ED218845;
	Tue,  5 May 2026 00:17:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.190.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777940224; cv=none; b=oM0EKlXXVSOcPAifW2CvSZGLPxx9BcKA7FXC8dAWCU/Htqwjkfh2S4Qpy9LD+y9iZbAEfCSLAUYuldhEJiORrWsoQe0xn/p00y5FhVESRZuXZ560QIdpaq/4OYgDQWD4EH/eFWnxmPizbLZdiQNMbXpSnPsqfmGDegxUPdq6TfY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777940224; c=relaxed/simple;
	bh=sry9Qhd2bwqIioHsr5TCvkI/XyI2KLYqbJnT+ekWkVU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=iy/iPrX/LNVZwGtF4KVeLHquqrFcIXBrw8VshUowDYGvmsjf54CA2yX4NZ68I4NixuObLeM3aNzx1AWYBHimCdGaiUCAdL7QzsiEcYJZdZcWFT+qiVz5oQ3Ql42Hh2L8R3JZdMrHRNPYcrelJpqnQjOaYfzcb19/lrboJ1NL5Ww=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org; spf=pass smtp.mailfrom=netfilter.org; dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b=uw6+pUCg; arc=none smtp.client-ip=217.70.190.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netfilter.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b="uw6+pUCg"
Received: from localhost.localdomain (mail-agni [217.70.190.124])
	by mail.netfilter.org (Postfix) with ESMTPSA id 793C86024A;
	Tue,  5 May 2026 02:17:00 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1777940221;
	bh=c3VJS7/r1F0+7fUKmdL6bYHA6DtYex52pNXTuitQsN0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=uw6+pUCgsYK6AfD05RNlbwJz+5iIDkQHlcelMREwh2KIa87+d1tjIp77pjozzH5Io
	 XZKXbSjIVPHf/IWTLbedZIoV8IkFNAuiGxI8AIvZwmwWnuf/FC0CKPsge00VTDJy+9
	 2N9q6nHJCUT5RRLm/WvQtCWbKOo1H2kUfDinLMnHbjRmv3IBfDmgkVjCWM023jzw9z
	 QxQTaCL8Qu2bYwB78u00I6cdfNrGnGIyLSz/Xg9rop2kTMBmvzEv6GVUoc8M4SDA2Z
	 mNUYzpBa2oj4lNLCnZh2/OHz0RNQ17va1UV8GpaMhSwzuH04k9nq/TwLeVYPtWmSOa
	 Q0flO15QzggFQ==
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
Subject: [PATCH net 4/8] ipvs: do not leak dest after get from dest trash
Date: Tue,  5 May 2026 02:16:44 +0200
Message-ID: <20260505001648.360569-5-pablo@netfilter.org>
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

From: Julian Anastasov <ja@ssi.bg>

Sashiko warns about leaked dest if ip_vs_start_estimator()
fails in ip_vs_add_dest(). Add ip_vs_trash_put_dest() to
put back the dest into dest trash.

Link: https://sashiko.dev/#/patchset/20260428175725.72050-1-ja%40ssi.bg
Fixes: 705dd3444081 ("ipvs: use kthreads for stats estimation")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 37 ++++++++++++++++++++++------------
 1 file changed, 24 insertions(+), 13 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index caec516856e9..d81077c2457a 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1102,6 +1102,24 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, int dest_af,
 	return dest;
 }
 
+/* Put destination in trash */
+static void ip_vs_trash_put_dest(struct netns_ipvs *ipvs,
+				 struct ip_vs_dest *dest, unsigned long istart,
+				 bool cleanup)
+{
+	spin_lock_bh(&ipvs->dest_trash_lock);
+	IP_VS_DBG_BUF(3, "Moving dest %s:%u into trash, dest->refcnt=%d\n",
+		      IP_VS_DBG_ADDR(dest->af, &dest->addr), ntohs(dest->port),
+		      refcount_read(&dest->refcnt));
+	if (list_empty(&ipvs->dest_trash) && !cleanup)
+		mod_timer(&ipvs->dest_trash_timer,
+			  jiffies + (IP_VS_DEST_TRASH_PERIOD >> 1));
+	/* dest lives in trash with reference */
+	list_add(&dest->t_list, &ipvs->dest_trash);
+	dest->idle_start = istart;
+	spin_unlock_bh(&ipvs->dest_trash_lock);
+}
+
 static void ip_vs_dest_rcu_free(struct rcu_head *head)
 {
 	struct ip_vs_dest *dest;
@@ -1461,9 +1479,12 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 			      ntohs(dest->vport));
 
 		ret = ip_vs_start_estimator(svc->ipvs, &dest->stats);
+		/* On error put back dest into the trash */
 		if (ret < 0)
-			return ret;
-		__ip_vs_update_dest(svc, dest, udest, 1);
+			ip_vs_trash_put_dest(svc->ipvs, dest, dest->idle_start,
+					     false);
+		else
+			__ip_vs_update_dest(svc, dest, udest, 1);
 	} else {
 		/*
 		 * Allocate and initialize the dest structure
@@ -1533,17 +1554,7 @@ static void __ip_vs_del_dest(struct netns_ipvs *ipvs, struct ip_vs_dest *dest,
 	 */
 	ip_vs_rs_unhash(dest);
 
-	spin_lock_bh(&ipvs->dest_trash_lock);
-	IP_VS_DBG_BUF(3, "Moving dest %s:%u into trash, dest->refcnt=%d\n",
-		      IP_VS_DBG_ADDR(dest->af, &dest->addr), ntohs(dest->port),
-		      refcount_read(&dest->refcnt));
-	if (list_empty(&ipvs->dest_trash) && !cleanup)
-		mod_timer(&ipvs->dest_trash_timer,
-			  jiffies + (IP_VS_DEST_TRASH_PERIOD >> 1));
-	/* dest lives in trash with reference */
-	list_add(&dest->t_list, &ipvs->dest_trash);
-	dest->idle_start = 0;
-	spin_unlock_bh(&ipvs->dest_trash_lock);
+	ip_vs_trash_put_dest(ipvs, dest, 0, cleanup);
 
 	/* Queue up delayed work to expire all no destination connections.
 	 * No-op when CONFIG_SYSCTL is disabled.
-- 
2.47.3

