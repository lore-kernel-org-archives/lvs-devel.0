Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B327D277C9D;
	Wed, 29 Apr 2026 14:14:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777472075; cv=none; b=jsUd8TYaoEYn732wljxDxh53GyonEI8urjTxfDWGslGJf8kbM0BOHDGOpab0vAzBqti9VHn7QSJir0knk2Gyg7mKxfKi1ewJOkDi3NEYpHWDQ1NFzBJyIQKttTVplLUb0eFZswFZ1hW0Bso7D2kVOJzG2VHvoCDol0I0Q91RjyA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777472075; c=relaxed/simple;
	bh=dTo9HHruW8QVv/6+G5t8xN35S3zWzyhJt4phdhyCqTE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=mKzaZUb4C2qIRZqHgxMAaAbCJ6AZwtUBn/E2SpQB/e3yF6t3yYeNMRrKCEXimCRXqxOKxYNDDST1UP9/aVPx7Jv5wlWphtbqfA4ot63Hx6ApZ4S2+McNTD+WWH5dd1Vbo2F8bhatOeXNLEvqbseWBs9D18Sr71/GpfFr/NW/4SA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=lL1CGDvl; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="lL1CGDvl"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 8008821A73;
	Wed, 29 Apr 2026 17:14:11 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=+5l6HjIa6pEN1i6IQbOcoo3u2ww0YtZrxpJ29skJSz0=; b=lL1CGDvlbthX
	raUjuGFSummZQkxq0baV/vrrR5TCfOWjtoq+ZAKUcXWuFS6Zh2NNxnq1tGJQhnvk
	ZgjIjuAIHSzm7R9njqdnArqIbuWJwN8zSZGFpvLzGbcX4ZlKbTznkl85GLA1JkP0
	jYKaT6/OkffO9VStSsYbd9YwKipb4k3dVGdUaTYuZ6Qw+THbaQ9mk/MyJpzLJFcB
	PeLhrfLMnhCNh8cmd/PX0llnoGNlQ4euxeyJn/UTymBNn7KXqxG3s//NUeL0gNtL
	ivESio5JZRgEc05uMZ6khMu60bvgD7SaIYPgBlttwAPdZPy0zXrxm5J6SxJClSbH
	ar8CLjAPtlKvs3yx5qQ0ofjAc9azdfWUnGBXnOfUHuSwaolCwSxppKjLp1bvfY4t
	CKTwH3/Z52FLxcZ+yhXCcmO/1iTbL11A+tVUAKUN7U8YENS+UN83bth9wLq9/RXB
	NMOI2hVOmFU3VlRJruWV3md/qYgO0WGhZXJUBNL5pDm8R0eK0SkoLZTM9iImUsq3
	IjXVTPI9P9s2QwiU9MMNGwUcIGktU6FrBkSihJ+n8ce/c6poR79BmS/yBzcFEjfg
	iDHWBhhy8++C288U0yMADe4h1BB31HfQ+dbRWT91qnJViHM228oJW3I9TrRssLcK
	OxAdaKIpqQD3EmDb76a9VGGgywPQVhE=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 29 Apr 2026 17:14:10 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id D693B62AE2;
	Wed, 29 Apr 2026 17:14:09 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63TEBMIP085098;
	Wed, 29 Apr 2026 17:11:22 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 63TEBMDZ085097;
	Wed, 29 Apr 2026 17:11:22 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        Waiman Long <longman@redhat.com>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org
Subject: [PATCHv2 nf 4/8] ipvs: do not leak dest after get from dest trash
Date: Wed, 29 Apr 2026 17:10:51 +0300
Message-ID: <20260429141055.85052-5-ja@ssi.bg>
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

Sashiko warns about leaked dest if ip_vs_start_estimator()
fails in ip_vs_add_dest(). Add ip_vs_trash_put_dest() to
put back the dest into dest trash.

Link: https://sashiko.dev/#/patchset/20260428175725.72050-1-ja%40ssi.bg
Fixes: 705dd3444081 ("ipvs: use kthreads for stats estimation")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
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
2.53.0


