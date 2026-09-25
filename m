Received: from mail-pj2-f12.google.com (mail-pj2-f12.google.com [74.125.227.140])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0CB724E4332
	for <lvs-devel@vger.kernel.org>; Fri, 25 Sep 2026 16:41:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.140
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790354487; cv=none; b=TRk1Vv7TrQYLZlinsofFhitWEA21mm4EioZDxm/teQuzf0yb/pBoS6MhTlBWZO5p27PKLHZZiwe1YYaKUDQ/Fy3ndsLkGj+Fmbl9gGbHPlBgNx8g9fBec+QCowfrSgBpXFZZXiyaGP/E5kCE2kQVMSlUa44XfgLCiaRjV5uZe3Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790354487; c=relaxed/simple;
	bh=uErEj7xXzrGiuvpih0CLQN+xUS1ynJdsI6gvvhsGifA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=XD17nrpRXmMbEuiywjkt9o5HyWnoGxcCxHhPPTAPBCLXi5oUEBF1kozIuyFHQ2lpcKSo7MHBYaByK9Z4hmVvnftDb8olaResVhKCxOSohO3vQfei9G7GlhR0PZyMx72wxFV65VAKsGfSf+WW4Hp1HbZvgID+sAW3QzjCrD4+HgA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai; spf=pass smtp.mailfrom=nebusec.ai; dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b=CNzWojUX; arc=none smtp.client-ip=74.125.227.140
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b="CNzWojUX"
Received: by mail-pj2-f12.google.com with SMTP id d9443c01a7336-2d747f066d8so2768745ad.1
        for <lvs-devel@vger.kernel.org>; Fri, 25 Sep 2026 09:41:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=nebusec.ai; s=google; t=1790354469; x=1790959269; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=TA+H9EVBy7FAiP8LLZdGujo/BX0RLZ9e9NCfBhtpMyQ=;
        b=CNzWojUX6dXLzXEkFQoIhwvKuYL0CtK2Y2Au5wYqsvm8JaUzRcp8d9fEpT+bU0oH0F
         AvjnJj4UcpMmqEL9rjX1cm7oGnPMW00tsC8MRKxO5mUe5yJsKCvh2AFSAvA3/1/lLAmS
         4tCge0RzUGL3nTr6/tcQyhBNpxNUG8FfDdD6NRQOTNZ1xqoHJ5A6DbkqpLYkgq1KSxpj
         Uf5WuldNeGCM3WO5PvsSgR1yPjOEpuN37FsMTu7JxvbRuK8rgRd3Lx3iHCrBTlH2EJZ8
         /+hRdRzsXbd2eWh79gXC4Be+SZGnn7cZIclGV6ooqn6sBNfAoNmU+qpTNv975Q+7DnnC
         zU2Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790354469; x=1790959269;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=TA+H9EVBy7FAiP8LLZdGujo/BX0RLZ9e9NCfBhtpMyQ=;
        b=tea1U0MnrCBJf9D1G4KsTZ1Hpdbft7yAnklBeKhuiZhONcDK8j+AKoxvTxpSuKx3IO
         QxWe6rmiRjJlCmMhRP9DU/+XtyVV/CpVRZQ7Ch+e7YqWC34Lv0Kuj9kk461W5XZLNvXZ
         9P6gRPcimIU2efCJaJwk6nHyx0hlv+/hle/ABgLPtA1SAKmOXGWqPcYgcwv1IZ3e9FhU
         ZHqAATk0TCF1wEVlQmB4uLYu3ZsWbYyaYnLnnvknLUA/1Y1net2bdG72qIDFOKipJuCr
         SwjsSjDjbfMpmZ0P0/vyKxZ8tNnRswv+IF7N6Vgdm8q/MVrqzslOmsiVfxotlqy5W9Kt
         /Imw==
X-Forwarded-Encrypted: i=1; AKwUvBz3i7gGfkQfnXn5DHEvjPk1+bXR4Lt6w4ZpGsw1PkiuOL7h5oUPi0M8HZ7Pcl1mmrxXO9kH+x1gCV0=@vger.kernel.org
X-Gm-Message-State: AFuF++mX506Kpv6gUR5/wT1LMr6VN3NCLHLoWKvTdaEemKMLk/2d2rGt
	lwlsez6h8qIP27AmAEFaMs2+oPin/OeIwvRMPgnNSyk3rmojBuRqBrqTkwowl0C/6lWH
X-Gm-Gg: AYBFou3O/etjf3E6MqRk1aQBQPiSYrS3CCf1S26rCtcsRPoi+XEgz1FPp4oNNHIa4FP
	Wh2+JfZtzlSHl4zXsJsQI/ekUXtFjux8TRT3FpYY6DjyzuULvOrWwON/3uVMiwpOCu0g51bXLx+
	xkSH4qVAOCn1ihaD4UWV95zpIkVHEPbiEuSMSUUo9b3ZfYT6zzFqE9/vtq3+EVvUcN0C7tucHRB
	0bovAdLrKx2EcPs8GVs21NwiQUmbaGgIs/KTr0C7OfmdHJ+gun0FC57k37UtTdiNiGBNllJ7b8E
	i59wQHXdwUn3tXrs24Wn0f/YI5Jdwv0aJeyR8IxaDeSZSy6tWrvjCxl2jZ7LIffwT/XAGUHsXp9
	FxybOvA7lbofOh26rn3Z8ojrqmZ4cYdn9ogb8f1nly1HfJKwRmho5veQuwKmQni9GoGGkJBpYK4
	h1GdXhdmk9tfoBXnpbC5Sf/LZPmUuvQczdapG0l2vgLlnzryYPt/UujoijkMfD6ujH69v8ODbDN
	R+n0MZHZR3tvidwr8q3hpFCaBMKNQ==
X-Received: by 2002:a17:903:1209:b0:2df:92df:baa0 with SMTP id d9443c01a7336-2df92dfbd16mr16643095ad.5.1790354469324;
        Fri, 25 Sep 2026 09:41:09 -0700 (PDT)
Received: from 954df21a5119.. ([122.51.212.64])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-2df9146edb4sm13855275ad.81.2026.09.25.09.41.05
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 25 Sep 2026 09:41:08 -0700 (PDT)
From: Zihan Xi <zihanx@nebusec.ai>
To: netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Cc: horms@verge.net.au,
	ja@ssi.bg,
	pablo@netfilter.org,
	fw@strlen.de,
	phil@nwl.cc,
	zihanx@nebusec.ai
Subject: [PATCH nf v5 1/3] ipvs: wait the running timer cb on conn deletion
Date: Fri, 25 Sep 2026 16:40:46 +0000
Message-ID: <77588fc74c9f2051fefa31be15e86ab6ce657ffd.1790266803.git.zihanx@nebusec.ai>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <cover.1790266803.git.zihanx@nebusec.ai>
References: <cover.1790266803.git.zihanx@nebusec.ai>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Julian Anastasov <ja@ssi.bg>

Sashiko reports for problem when deleting connections.

If connection timer expires, its callback can not be
concurrently running but if connection is deleted
the callback can be running on another CPU even
after all references are released. Before now we
continued with the connection freeing, risking the
callback to access the deleted connection after it
is freed. As ip_vs_conn_del*() run under RCU lock
there is no risk accessing a freed connection by
concurrent timer callback as Sashiko warns, may
be only if our timer expires and we try to delete
the cp->control chain.

Fix that by failing the ip_vs_conn_unlink() call after
refcnt is restored to 1 allowing the timer callback
to be scheduled for new execution which should happen
after the detected running callback finishes.

One of two things can happen when we detect the
running callback:

1. the concurrent timer callback can see refcnt 0 and
do nothing, so we will schedule new timer callback to
expire the connection after the running one finishes

2. the concurrent timer callback can see refcnt 1 and
to expire the connection as usually, in this case we
will see refcnt 0 and will do nothing

Add explicit rcu_read_lock() while deleting the cp->control
chain to protect from concurrent timer callback for ct to
expire it before us.

During such races, try to keep 0 in cp->timeout as it is
a request for deleting our cp->control chain immediately.

Link: https://sashiko.dev/#/patchset/cover.1789435989.git.zihanx%40nebusec.ai
Fixes: f9200a52eedf ("ipvs: avoid expiring many connections from timer")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_conn.c | 103 +++++++++++++++++---------------
 1 file changed, 54 insertions(+), 49 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 6fa3e1dc534c3..eac185496a8a6 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -313,17 +313,34 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
 /* Try to unlink ip_vs_conn from conn_tab.
  * returns bool success.
  */
-static inline bool ip_vs_conn_unlink(struct ip_vs_conn *cp)
+static inline bool ip_vs_conn_unlink(struct ip_vs_conn *cp, bool my_cb)
 {
 	struct netns_ipvs *ipvs = cp->ipvs;
 	struct hlist_bl_head *head, *head2;
 	u32 hash_key, hash_key2;
 	struct ip_vs_rht *t;
-	bool ret = false;
 	bool use2;
 
+	if (!refcount_dec_if_one(&cp->refcnt))
+		return false;
+
 	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
-		return refcount_dec_if_one(&cp->refcnt);
+		return true;
+
+	/* Revalidate after conn is excluded from traffic:
+	 * - not controlling other conns
+	 * - no pending/running timer callback
+	 *
+	 * And the winner is ...
+	 */
+	if (atomic_read(&cp->n_control) ||
+	    (!timer_delete(&cp->timer) && !my_cb)) {
+		/* Not me? Give the timer callback another chance, even
+		 * if one is concurrently running during the conn deletion.
+		 */
+		refcount_set(&cp->refcnt, 1);
+		return false;
+	}
 
 	rcu_read_lock();
 	local_bh_disable();
@@ -337,15 +354,11 @@ static inline bool ip_vs_conn_unlink(struct ip_vs_conn *cp)
 		      false /* new_hash2 */, &head, &head2);
 
 	if (cp->flags & IP_VS_CONN_F_HASHED) {
-		/* Decrease refcnt and unlink conn only if we are last user */
-		if (use2 == ip_vs_conn_use_hash2(cp) &&
-		    refcount_dec_if_one(&cp->refcnt)) {
-			hlist_bl_del_rcu(&cp->hn0.node);
-			if (use2)
-				hlist_bl_del_rcu(&cp->hn1.node);
-			cp->flags &= ~IP_VS_CONN_F_HASHED;
-			ret = true;
-		}
+		/* Unlink conn as we are the last user */
+		hlist_bl_del_rcu(&cp->hn0.node);
+		if (use2)
+			hlist_bl_del_rcu(&cp->hn1.node);
+		cp->flags &= ~IP_VS_CONN_F_HASHED;
 	}
 
 	conn_tab_unlock(head, head2);
@@ -353,7 +366,7 @@ static inline bool ip_vs_conn_unlink(struct ip_vs_conn *cp)
 	local_bh_enable();
 	rcu_read_unlock();
 
-	return ret;
+	return true;
 }
 
 
@@ -1319,34 +1332,29 @@ static void ip_vs_conn_rcu_free(struct rcu_head *head)
 	kmem_cache_free(ip_vs_conn_cachep, cp);
 }
 
-/* Try to delete connection while not holding reference */
+/* Try to delete connection while not holding reference.
+ * It can be called concurrently and always under RCU lock.
+ */
 static void ip_vs_conn_del(struct ip_vs_conn *cp)
 {
-	if (timer_delete(&cp->timer)) {
-		/* Drop cp->control chain too */
-		if (cp->control)
-			cp->timeout = 0;
-		ip_vs_conn_expire(&cp->timer);
-	}
-}
+	struct timer_list *t = (void *)((unsigned long)(&cp->timer) | 1UL);
 
-/* Try to delete connection while holding reference */
-static void ip_vs_conn_del_put(struct ip_vs_conn *cp)
-{
-	if (timer_delete(&cp->timer)) {
-		/* Drop cp->control chain too */
-		if (cp->control)
-			cp->timeout = 0;
-		__ip_vs_conn_put(cp);
-		ip_vs_conn_expire(&cp->timer);
-	} else {
-		__ip_vs_conn_put(cp);
-	}
+	/* Drop cp->control chain too */
+	if (cp->control)
+		cp->timeout = 0;
+	ip_vs_conn_expire(t);
 }
 
+/* Connection is removed in the following steps:
+ * - timer expires or connection is deleted
+ * - there should be no more references (n_control>0 and refcnt>1)
+ * - there should be no pending timer or a running timer callback (on deletion)
+ */
 static void ip_vs_conn_expire(struct timer_list *t)
 {
-	struct ip_vs_conn *cp = timer_container_of(cp, t, timer);
+	bool my_cb = !((unsigned long)t & 1);
+	struct timer_list *t2 = (void *)((unsigned long)t & ~1UL);
+	struct ip_vs_conn *cp = timer_container_of(cp, t2, timer);
 	struct netns_ipvs *ipvs = cp->ipvs;
 
 	/*
@@ -1356,26 +1364,21 @@ static void ip_vs_conn_expire(struct timer_list *t)
 		goto expire_later;
 
 	/* Unlink conn if not referenced anymore */
-	if (likely(ip_vs_conn_unlink(cp))) {
+	if (likely(ip_vs_conn_unlink(cp, my_cb))) {
 		struct ip_vs_conn *ct = cp->control;
 
-		/* delete the timer if it is activated by other users */
-		timer_delete(&cp->timer);
-
 		/* does anybody control me? */
 		if (ct) {
-			bool has_ref = !cp->timeout && __ip_vs_conn_get(ct);
-
+			rcu_read_lock();
 			ip_vs_control_del(cp);
 			/* Drop CTL or non-assured TPL if not used anymore */
-			if (has_ref && !atomic_read(&ct->n_control) &&
+			if (!cp->timeout && !atomic_read(&ct->n_control) &&
 			    (!(ct->flags & IP_VS_CONN_F_TEMPLATE) ||
 			     !(ct->state & IP_VS_CTPL_S_ASSURED))) {
 				IP_VS_DBG(4, "drop controlling connection\n");
-				ip_vs_conn_del_put(ct);
-			} else if (has_ref) {
-				__ip_vs_conn_put(ct);
+				ip_vs_conn_del(ct);
 			}
+			rcu_read_unlock();
 		}
 
 		if ((cp->flags & IP_VS_CONN_F_NFCT) &&
@@ -1410,13 +1413,15 @@ static void ip_vs_conn_expire(struct timer_list *t)
 		  refcount_read(&cp->refcnt),
 		  atomic_read(&cp->n_control));
 
-	refcount_inc(&cp->refcnt);
-	cp->timeout = 60*HZ;
+	if (__ip_vs_conn_get(cp)) {
+		if (cp->timeout || atomic_read(&cp->n_control))
+			cp->timeout = 60 * HZ;
 
-	if (ipvs->sync_state & IP_VS_STATE_MASTER)
-		ip_vs_sync_conn(ipvs, cp, sysctl_sync_threshold(ipvs));
+		if (ipvs->sync_state & IP_VS_STATE_MASTER)
+			ip_vs_sync_conn(ipvs, cp, sysctl_sync_threshold(ipvs));
 
-	__ip_vs_conn_put_timer(cp);
+		__ip_vs_conn_put_timer(cp);
+	}
 }
 
 /* Modify timer, so that it expires as soon as possible.
-- 
2.43.0

