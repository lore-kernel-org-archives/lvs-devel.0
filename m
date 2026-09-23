Received: from mail-pj2-f13.google.com (mail-pj2-f13.google.com [74.125.227.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 25B5747D44D
	for <lvs-devel@vger.kernel.org>; Wed, 23 Sep 2026 09:54:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.141
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790157275; cv=none; b=ba2rITZPi4wKijzI06Ug1njdxUKo3EqfF0WHWdO0Ki+GV+ijprHaH4lrqP4auobtWA9yF8zYifu/ZRVnmn3X/TyMdVXCRdebzLP5iocUTT1iTIjD8CKVBLiHCsGvobngoJ2AxAUumUiChd0VXYHPBAzwrqWan5MPnus41yT7JWs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790157275; c=relaxed/simple;
	bh=QP2zeCcSlOzjBL2aqTVUS2P4u++MGbpIG9oq+g1c7lQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=KlvSd3E46Hlyiie08n4XhH2S4ZoGwo2FGFonFhMKiulOA7wpXGKOc8JOZO7Fi74so4kqlAzECh9+wjmXQTefYNM6etB0Nd4AJAPasvTiSd5XmyRe8ZxNnA4mOtfdV35TzociUUH6OxuO9zI338vLGbg+TOIGEBSGu+VJEkD57lE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai; spf=pass smtp.mailfrom=nebusec.ai; dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b=YK0zlITG; arc=none smtp.client-ip=74.125.227.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b="YK0zlITG"
Received: by mail-pj2-f13.google.com with SMTP id 98e67ed59e1d1-396ccb1a990so557521a91.3
        for <lvs-devel@vger.kernel.org>; Wed, 23 Sep 2026 02:54:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=nebusec.ai; s=google; t=1790157271; x=1790762071; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=QR9bfHIsQ04W27fHUOP8MJLUlZC8gKLrUSCQoHM5E/g=;
        b=YK0zlITGRivyVw8kvh9uo8E3kdcGFbjx6uH1k5rhAuvGF436fdqBL//z1I2r5Dwd/P
         MutqWptlu2xsUoGIaU6t5zc5T93Jq7CsBcwV7+9cCHwel5qGL8Yk/i1+Q+SqhHs8wbWF
         7SJetVz0w1Zvy6KLMkAbSK6Ytn34a9rVjkDfNkS099sjwAzNMZE2AgBV63iFMmsPFlcB
         oEA6uKqbfPDJA4XXVz4Ri0TMhYSXy+dQ7d7+7pvPu1k0KH0hlsAC5IyWZDWq8SiQMihm
         4dOMlX6zqT5T38FPaXm5W5k1ozHliIUGxw8QWwPEczwZMXlPPVHq1iAYqpZtzOajNuoc
         Jgaw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790157271; x=1790762071;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=QR9bfHIsQ04W27fHUOP8MJLUlZC8gKLrUSCQoHM5E/g=;
        b=jy4UdDZ+LLG0pTx64l54ECI5bZ7LHsTWfH2aUvZ4iSNVLehdqNplJQeDdSrIkm4h36
         zuc7o1Gk9ntDMpQAafXQLLofHS/LxUYVAZ3V30JpYNYg11eDCEWm/y0yz0DtBO5S5vbH
         jXnCLrZLjiipAMmVjDPHF5l5xSqMw0lV6zpQdiapK392vRjZZ6gBc2TiRR2RaVkQ4syH
         CV8Hn+NTCFsI3Ub4EWQZVtjlHzPGlY9iiUsDuDQU+U2wbXslBp0dg3ioAhw5pXODvvym
         yWwXmHdsGssN4adfHJAUv/AaRJDJeDPcyM8iB0NQDDSlB27Ba8+w5ns2kIQBe9+vJ5h6
         ncjw==
X-Forwarded-Encrypted: i=1; AKwUvByTNLJ4tpRchgWzVtpVymjLrKu4VQDc2KyWsLCu2Iyz6pBsqZaB/DqpQqTNaC8u2Xr7KMsBVjm7sSA=@vger.kernel.org
X-Gm-Message-State: AFuF++n2PP/C7yZ6Pnj4wwjKCx32Eb4w2XrC6wEurN0CSA+2T4FrI0Nd
	05MR1I+rtv5lk+KcavcubOkHbb2VmCEOkHbjOBZHrSSXNLtS79+MFL9k2dMMxmKNDztG
X-Gm-Gg: AYBFou35SJ2cxBqhE3qlUcrn2xiPdO4CF2A7GYDejcj5ac0l2x/nX2mXjj93zN4za37
	G9uJsXv9GMvCcFOyWnCILnNRNC3dU8PT6yfiDbnM2Rzd/NsAc0GZiqDWilDW1LvaqKIVMFIqBZX
	duqpcs7vVF/cFl/mOSAZ8aLtFFk2cWNZd3G4wGnXRHKoan96dxfQl6RbcIPJMu1JZmzPAbJshLV
	9LfmQ5eGQhXYhaJ5uRdMyl/JRAJQFyOa1YHOb4x+zLCo2lejISoishX1GnzsA1TSf+gE6MFFUtt
	UjIYID24J1bt4zd+BqX3E4MwrEQ4ehOS8/IAunNjwuMt4oQvWqFdJPaZgnY1mAdMfo+rS/MVM2D
	uasfcSSwxpvJqHFM2HzYF3PDVHLYoCLGL7yMRvTtV5GCQEqnFM7F2IGTsCJ2larETV91T8mzf8j
	QZ82xqT9s6SUzrfjuXCvmj27TDi/UEGgmMXUyDXkHHlg/Mw3+OAOY2XuB08BCWouCJs0ezU1y1A
	kUH1AVzpvTl5G0t5AD0eobFiggWxg==
X-Received: by 2002:a17:90b:51c8:b0:39e:4c80:44bd with SMTP id 98e67ed59e1d1-3a07e5ea39dmr1698414a91.32.1790157271227;
        Wed, 23 Sep 2026 02:54:31 -0700 (PDT)
Received: from 954df21a5119.. ([122.51.212.64])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3a07dc5f3d7sm4793862a91.16.2026.09.23.02.54.26
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 23 Sep 2026 02:54:30 -0700 (PDT)
From: Zihan Xi <zihanx@nebusec.ai>
To: netfilter-devel@vger.kernel.org
Cc: netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	coreteam@netfilter.org,
	linux-kernel@vger.kernel.org,
	horms@verge.net.au,
	ja@ssi.bg,
	zihanx@nebusec.ai,
	pablo@netfilter.org,
	fw@strlen.de,
	phil@nwl.cc,
	davem@davemloft.net,
	edumazet@google.com,
	kuba@kernel.org,
	pabeni@redhat.com
Subject: [PATCH nf v4 1/3] ipvs: wait the running timer cb on conn deletion
Date: Wed, 23 Sep 2026 09:54:13 +0000
Message-ID: <dfc9f33299baa890537aacdc3082c85e1a6eccc9.1790146910.git.zihanx@nebusec.ai>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <cover.1790146910.git.zihanx@nebusec.ai>
References: <cover.1790146910.git.zihanx@nebusec.ai>
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
index 6fa3e1dc534c3..32cfc02aa2912 100644
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
+		refcount_inc(&cp->refcnt);
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

