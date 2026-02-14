Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B7F3A189F43;
	Sat, 14 Feb 2026 15:17:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771082271; cv=none; b=oYB7vR9cuoVhYHa5a29P080J6jH83jLQmWABiLO9Nj1M7LO7F8IzWjskhvIbPLCOIZKSkbRNoaqXwKtPRkrNK4Wx+/AA7eBm+izpZlMcddhCnSa5An7pPN1sTyeL7hwGVXLwcTQaR7w9vIkxMo3oez7IvsiEZ9edG8j6qTcz6xI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771082271; c=relaxed/simple;
	bh=54lS2NmJ84vkDa6yMrYN0idTRRdkpRJq1Ulzqs3tMPo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Q3KTBtMOtc+d31IaxLoGlTA/9qmBrXfC8oVwGucXvSRlU4pEE6q3zEDZWAQxTRMHC9dA1Wsa9el4D9ZhaL4CjteTjG/l0UiBMbniTdKV+wp5ePHCqsSUKD+AfKlgTnjF7N+m6zLTivO1N3WbipiXY8VH9+8Pg5zMFtMmsRUPLnM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=Qsj862sU; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="Qsj862sU"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 9672A21D6C;
	Sat, 14 Feb 2026 17:17:47 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=XtTa0OgSPxuK9J2YweQaHlNrLxPSTRmAn1AQzekMyNc=; b=Qsj862sU8ejo
	I/d0kvyV4SborGReBGg8fmUpnvN7RkZyRO1MIUmbiSiPd5Zr45JjGb+lEjAMgS3E
	e+i8mQUogfcVqhYZFGNfTxNtrLWTotdSc1W6HE9Nfo8KyMjZdo4UoB4LQlAZ3ARE
	8PlqyvkE+8Y9p175tctSWT0rbXUObrrZZcFW8yl2w/G/NUaxtOz0/SrqQNPmbknq
	GrstDcAr1OVDj0c3rD5PuD49+pq7rryhTyQO35SpPxWLS/fBdmxuyNdNuDaWXGZV
	yRmJ6b0XYDH6Wi7LM68GmjqIrvkmYQuzzi4vlJhMPBY5twlBBNrUrCxaRxKJoJPd
	i6g+DWhERzFLF5E2QAKQPPQYHapuGnig/k/B75LqdUDbUQK7ENsdPFKjoYk/S1GC
	vE7S3lLSLtuYuEN5wkQGzdKsKutmeHgJAQAylspS8rGXSnaP9NYIwKYP9S+Ffuvz
	7+kgky/GFyujMwID45rvoDf1Zr+I7yvAbmCHBCIPrwUw1xD8YLT0/vmijGOHxjBo
	F1Sh2DQByMQP5eqaoWY1HQp8AoS25onacmCF0BrVyV0sVVlLvfljIgK7aqDchTQZ
	uv684pO0wDw9/Ec3sCy12viciybvx/47LXG6HecBp7AA7FTvQzUTyywIH5NgWBAv
	9GfTxQ68664prJ045wFmSulQPPZuaUE=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat, 14 Feb 2026 17:17:46 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id B7A66609BE;
	Sat, 14 Feb 2026 17:17:45 +0200 (EET)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 61EFCvWZ019358;
	Sat, 14 Feb 2026 17:12:57 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 61EFCvXn019357;
	Sat, 14 Feb 2026 17:12:57 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>
Subject: [PATCH nf-next 4/6] ipvs: do not keep dest_dst after dest is removed
Date: Sat, 14 Feb 2026 17:12:28 +0200
Message-ID: <20260214151230.18970-5-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260214151230.18970-1-ja@ssi.bg>
References: <20260214151230.18970-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Before now dest->dest_dst is not released when server is moved into
dest_trash list after removal. As result, we can keep dst/dev
references for long time without actively using them.

It is better to avoid walking the dest_trash list when
ip_vs_dst_event() receives dev events. So, make sure we do not
hold dev references in dest_trash list. As packets can be flying
while server is being removed, check the IP_VS_DEST_F_AVAILABLE
flag in slow path to ensure we do not save new dev references to
removed servers.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_ctl.c  | 20 ++++++++------------
 net/netfilter/ipvs/ip_vs_xmit.c | 12 ++++++++----
 2 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 2ef1f99dada6..7c0e2d9b5b98 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -809,7 +809,6 @@ static void ip_vs_dest_free(struct ip_vs_dest *dest)
 {
 	struct ip_vs_service *svc = rcu_dereference_protected(dest->svc, 1);
 
-	__ip_vs_dst_cache_reset(dest);
 	__ip_vs_svc_put(svc);
 	call_rcu(&dest->rcu_head, ip_vs_dest_rcu_free);
 }
@@ -1012,10 +1011,6 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 
 	dest->af = udest->af;
 
-	spin_lock_bh(&dest->dst_lock);
-	__ip_vs_dst_cache_reset(dest);
-	spin_unlock_bh(&dest->dst_lock);
-
 	if (add) {
 		list_add_rcu(&dest->n_list, &svc->destinations);
 		svc->num_dests++;
@@ -1023,6 +1018,10 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 		if (sched && sched->add_dest)
 			sched->add_dest(svc, dest);
 	} else {
+		spin_lock_bh(&dest->dst_lock);
+		__ip_vs_dst_cache_reset(dest);
+		spin_unlock_bh(&dest->dst_lock);
+
 		sched = rcu_dereference_protected(svc->scheduler, 1);
 		if (sched && sched->upd_dest)
 			sched->upd_dest(svc, dest);
@@ -1257,6 +1256,10 @@ static void __ip_vs_unlink_dest(struct ip_vs_service *svc,
 {
 	dest->flags &= ~IP_VS_DEST_F_AVAILABLE;
 
+	spin_lock_bh(&dest->dst_lock);
+	__ip_vs_dst_cache_reset(dest);
+	spin_unlock_bh(&dest->dst_lock);
+
 	/*
 	 *  Remove it from the d-linked destination list.
 	 */
@@ -1747,13 +1750,6 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
 	}
 	rcu_read_unlock();
 
-	mutex_lock(&ipvs->service_mutex);
-	spin_lock_bh(&ipvs->dest_trash_lock);
-	list_for_each_entry(dest, &ipvs->dest_trash, t_list) {
-		ip_vs_forget_dev(dest, dev);
-	}
-	spin_unlock_bh(&ipvs->dest_trash_lock);
-	mutex_unlock(&ipvs->service_mutex);
 	return NOTIFY_DONE;
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 4389bfe3050d..394b5b5f2ccd 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -336,9 +336,11 @@ __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 				goto err_unreach;
 			}
 			/* It is forbidden to attach dest->dest_dst if
-			 * device is going down.
+			 * device is going down or if server is removed and
+			 * stored in dest_trash.
 			 */
-			if (!rt_dev_is_down(dst_dev_rcu(&rt->dst)))
+			if (!rt_dev_is_down(dst_dev_rcu(&rt->dst)) &&
+			    dest->flags & IP_VS_DEST_F_AVAILABLE)
 				__ip_vs_dst_set(dest, dest_dst, &rt->dst, 0);
 			else
 				noref = 0;
@@ -513,9 +515,11 @@ __ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 			rt = dst_rt6_info(dst);
 			cookie = rt6_get_cookie(rt);
 			/* It is forbidden to attach dest->dest_dst if
-			 * device is going down.
+			 * device is going down or if server is removed and
+			 * stored in dest_trash.
 			 */
-			if (!rt_dev_is_down(dst_dev_rcu(&rt->dst)))
+			if (!rt_dev_is_down(dst_dev_rcu(&rt->dst)) &&
+			    dest->flags & IP_VS_DEST_F_AVAILABLE)
 				__ip_vs_dst_set(dest, dest_dst, &rt->dst, cookie);
 			else
 				noref = 0;
-- 
2.53.0


