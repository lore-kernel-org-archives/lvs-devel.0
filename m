Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793608107;
	b=3mi7UEMU9/TOhB9GNOaC71+gdHnrx3OllRVaRe0gOG1qWxxshK3npl31mkIDFt2/zxvR
	 I3wmbcHIgXuUJsEfD/yqfxdv5D0EfctHXzJndFhO01PWjKoWEBEznDEUTIAPR+f/kuUr/
	 D8VfVOIOk7qmb/40kF6TE+3mWCcaK2MELQDsZldg/f93UZfRkbiLcnBuWr3uoQmaRKFD/
	 c9Jobd+l22JcP/kG8HFjRmXazB+3OTwEQebmY3hIWqB8c2+cjFZpKNIuMw0u4e6C9y71K
	 O17+XxLSAAfWshKseIRm+utezALr0weOAMbGvl3ytz1fXVUXvyA469zgwgln+kfTwqg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793608107;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=GiQHU6ryz3EhCu8sPOGXOgrcBx7Kp/x7eGCQeqeLpW4=;
	b=nzjvq4JwgyBx0xN1ZAMyJxIlHMsvTrvmXI6qhwUiJl9roS0u2/+DqTnzzI4YCwLV2Vha
	 2FE4giHMuihl6JcdjelbBpDlLsY/hwAqc1shXaFooeQkE2ieUQUJQDtn5kHbCkPvxmYal
	 zcVfjtHAEfspOPC+9+2KDggVwU9a+82axdY8Q2BRSwdptPE+e39TL31+6yzzsVSqiShrV
	 0GaJahElFMJrHidsCZog3Ph6uCUOtp3xzEK4Q+2uenQvg8L89yD+qtu96Zq1On9CJbkM0
	 KvIpt7sGYhm8URpNQ/AWADL3p3DCbk9o0TMdEwARiyU7BGnh70ndoNNePtGSnnad+Lw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=RzwfbIZa;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DD14C606A324;
	Mon,  2 Nov 2026 08:28:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org DD14C606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=RzwfbIZa
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 0D61A21F7B;
	Mon, 02 Nov 2026 10:28:25 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=GiQHU6ry
	z3EhCu8sPOGXOgrcBx7Kp/x7eGCQeqeLpW4=; b=RzwfbIZaCvu2Fgh3BXdhZo3W
	3FrYnOIzcFL4tKpUMNND51miriZJ5YL4SNy/M/+013kNJo4PSsXO135FzO3OO3FC
	cDlasab8Ucs9+LtRfIMSUvmwWl+tF4NNBWx2qz7AeED/l6k+pYT/mf3x7bPRlkME
	qW5XDOGpMByUHwLDWOFhD2OMojLPty0Zai9mQjFI/fuwZFFjk6/G8lNT1SBzSg8b
	IJS9KwBl/uF1Hv2r6W4pRmWHHiKIgtZNRwRtu1bhZJ9SeHBmzpEyFjYsVNzAObbr
	Svd+5DLJEKDQ6VUa8IG3rhOHefQps8LfpI/wzJwwXPDArgKeo+Wou9qwT1DHMKE+
	nm0mp5McZWp6803EfUa/OHaPVGTn9W0/qA/5YKihwyCxTemfzZDfLpmNSzRsK9vm
	1LrAIVD6xZ8qWNfieQ1jOB0OZmLm+SEoG+aHXhzRcS+vTx31bt+mAAM4PlHtEJ3f
	hYxVE1C2du4N6ddD4vfbS92W3a42fq8zMV8H2+J36i3Smuo/0mDqOrVmPejIPRSj
	peLyC4TsuZj7g8Dqq13Bv7UBKrYYBLhQfCh+ohPbjv4YPvc+kz28jTSGVYqrPJPK
	+FYRudQaGIm0EcfC2KohHIQdA/k2GzzInHbwbWXE//3KysBShShSQz8UWKowJygK
	iPg7uPl+9dwpju/Uv60=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 02 Nov 2026 10:28:24 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 7103D61FA7;
	Mon,  2 Nov 2026 10:28:24 +0200 (EET)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6A28SMPx025052;
	Mon, 2 Nov 2026 10:28:22 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 6A28SMXE025051;
	Mon, 2 Nov 2026 10:28:22 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf] ipvs: honor the overload state and do not enter it forever
Date: Mon,  2 Nov 2026 10:28:14 +0200
Message-ID: <20261102082814.25039-1-ja@ssi.bg>
X-Mailer: git-send-email 2.56.0
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Sashiko warns that we may enter the dest overload state forever
if setting the u_threshold to 1 races with the ip_vs_unbind_dest()
call for the last connection for dest. The problem is that we
prefer ip_vs_unbind_dest() to avoid using locks while reading the
threshold.

To avoid the race, add a smp_mb() in __ip_vs_dest_update_overload()
that is paired with the atomic_fetch_dec() in ip_vs_unbind_dest()
which allows to re-read the totalconns and to leave the overload
state if we are below l_threshold_val.

Also, remove the overload parameter from ip_vs_dest_update_overload()
because we just need to know the current state while deciding
which threshold ranges to use. This ip_vs_dest_is_overloaded() check
can be in __ip_vs_dest_update_overload() instead.

To avoid ip_vs_bind_dest() to enter lock just to initialize
u_threshold_val to INT_MAX, do it in ip_vs_new_dest().

The LBLC and LBLCR schedulers do not honor the global overload state
for cached dests, so add a ip_vs_dest_is_overloaded() check for
the situations where we may fallback from overloaded dest (LBLC and
LBLCR) or when we hit a cached dest (LBLC).

Also, move the ip_vs_dest_set_min() call in LBLCR after the
ip_vs_dest_set_erase() call that removes the most-loaded
server because due to races we may work with dest that is
in process of removing, i.e. ip_vs_dest_set_min() and
ip_vs_dest_set_max() may return same dest.

Link: https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20261019150249.1879516-2-pablo%40netfilter.org
Fixes: 3ba20137287f ("ipvs: fix more races around the overload flag")
Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h              |  2 +-
 net/netfilter/ipvs/ip_vs_conn.c  |  4 ++--
 net/netfilter/ipvs/ip_vs_ctl.c   | 30 ++++++++++++++++++------------
 net/netfilter/ipvs/ip_vs_lblc.c  |  8 +++++---
 net/netfilter/ipvs/ip_vs_lblcr.c | 13 +++++++------
 5 files changed, 33 insertions(+), 24 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 737a2982f857..b22bf062743b 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1925,7 +1925,7 @@ static inline void ip_vs_dest_put_and_free(struct ip_vs_dest *dest)
 		kfree(dest);
 }
 
-void ip_vs_dest_update_overload(struct ip_vs_dest *dest, bool overload);
+void ip_vs_dest_update_overload(struct ip_vs_dest *dest);
 
 /* Check if dest is in overloaded state */
 static inline bool ip_vs_dest_is_overloaded(const struct ip_vs_dest *dest)
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 7f20e8ea5598..b60fc15fc740 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1168,7 +1168,7 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 			atomic_inc(&dest->activeconns);
 		tc = atomic_inc_return(&dest->totalconns);
 		if (tc >= READ_ONCE(dest->u_threshold_val))
-			ip_vs_dest_update_overload(dest, true);
+			ip_vs_dest_update_overload(dest);
 	} else {
 		/* It is a persistent connection/template, so increase
 		   the persistent connection counter */
@@ -1261,7 +1261,7 @@ static inline void ip_vs_unbind_dest(struct ip_vs_conn *cp)
 			atomic_dec(&dest->activeconns);
 		tc = atomic_fetch_dec(&dest->totalconns);
 		if (tc <= READ_ONCE(dest->l_threshold_val))
-			ip_vs_dest_update_overload(dest, false);
+			ip_vs_dest_update_overload(dest);
 	} else {
 		/* It is a persistent connection/template, so decrease
 		   the persistent connection counter */
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 5de69404a5e0..15d28a2f81f5 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1304,12 +1304,12 @@ void ip_vs_stats_free(struct ip_vs_stats *stats)
 	}
 }
 
-/* Update overload flag based on number of dest conns and lower/upper
+/* Update overload state based on number of dest conns and lower/upper
  * connection thresholds:
- * - conns reach u_threshold and exceed it: set the flag
- * - conns go below l_threshold (or 75% of u_threshold): clear the flag
+ * - conns reach u_threshold and exceed it: set the overload state
+ * - conns go below l_threshold (or 75% of u_threshold): clear the state
  */
-static void __ip_vs_dest_update_overload(struct ip_vs_dest *dest, bool overload)
+static void __ip_vs_dest_update_overload(struct ip_vs_dest *dest)
 {
 	int conns;
 	u32 l, u;
@@ -1320,10 +1320,18 @@ static void __ip_vs_dest_update_overload(struct ip_vs_dest *dest, bool overload)
 		/* Low threshold defaults to 75% of upper threshold */
 		l = READ_ONCE(dest->l_threshold) ? : (u - (u >> 2));
 		conns = atomic_read(&dest->totalconns);
-		if (conns >= (overload ? l : u)) {
+		if (conns >= (ip_vs_dest_is_overloaded(dest) ? l : u)) {
 			WRITE_ONCE(dest->u_threshold_val, INT_MAX);
 			WRITE_ONCE(dest->l_threshold_val, l);
-			return;
+			/* Commit thresholds before repeating the check,
+			 * it is paired with atomic_fetch_dec() in
+			 * ip_vs_unbind_dest() to avoid entering the
+			 * overload state forever.
+			 */
+			smp_mb();
+			conns = atomic_read(&dest->totalconns);
+			if (conns >= l)
+				return;
 		}
 	}
 
@@ -1331,10 +1339,10 @@ static void __ip_vs_dest_update_overload(struct ip_vs_dest *dest, bool overload)
 	WRITE_ONCE(dest->l_threshold_val, 0);
 }
 
-void ip_vs_dest_update_overload(struct ip_vs_dest *dest, bool overload)
+void ip_vs_dest_update_overload(struct ip_vs_dest *dest)
 {
 	spin_lock_bh(&dest->dst_lock);
-	__ip_vs_dest_update_overload(dest, overload);
+	__ip_vs_dest_update_overload(dest);
 	spin_unlock_bh(&dest->dst_lock);
 }
 
@@ -1406,13 +1414,10 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 
 	if (READ_ONCE(dest->u_threshold) != udest->u_threshold ||
 	    READ_ONCE(dest->l_threshold) != udest->l_threshold) {
-		bool overload;
-
 		spin_lock_bh(&dest->dst_lock);
 		WRITE_ONCE(dest->u_threshold, udest->u_threshold);
 		WRITE_ONCE(dest->l_threshold, udest->l_threshold);
-		overload = ip_vs_dest_is_overloaded(dest);
-		__ip_vs_dest_update_overload(dest, overload);
+		__ip_vs_dest_update_overload(dest);
 		spin_unlock_bh(&dest->dst_lock);
 	}
 
@@ -1477,6 +1482,7 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	if (ret < 0)
 		goto err_stats;
 
+	dest->u_threshold_val = INT_MAX;
 	dest->af = udest->af;
 	dest->protocol = svc->protocol;
 	dest->vaddr = svc->addr;
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index e1111c3b2721..f5ce1f2afb86 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -467,10 +467,11 @@ is_overloaded(struct ip_vs_dest *dest, struct ip_vs_service *svc)
 		struct ip_vs_dest *d;
 
 		list_for_each_entry_rcu(d, &svc->destinations, n_list) {
-			if (atomic_read(&d->activeconns)*2
-			    < atomic_read(&d->weight)) {
+			if (ip_vs_dest_is_overloaded(d))
+				continue;
+			if (atomic_read(&d->activeconns) * 2 <
+			    atomic_read(&d->weight))
 				return 1;
-			}
 		}
 	}
 	return 0;
@@ -507,6 +508,7 @@ ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 
 		dest = en->dest;
 		if ((dest->cflags & IP_VS_DEST_CF_AVAILABLE) &&
+		    !ip_vs_dest_is_overloaded(dest) &&
 		    atomic_read(&dest->weight) > 0 && !is_overloaded(dest, svc))
 			goto out;
 	}
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index dfb5bf83750d..4046608922e7 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -630,10 +630,11 @@ is_overloaded(struct ip_vs_dest *dest, struct ip_vs_service *svc)
 		struct ip_vs_dest *d;
 
 		list_for_each_entry_rcu(d, &svc->destinations, n_list) {
-			if (atomic_read(&d->activeconns)*2
-			    < atomic_read(&d->weight)) {
+			if (ip_vs_dest_is_overloaded(d))
+				continue;
+			if (atomic_read(&d->activeconns) * 2 <
+			    atomic_read(&d->weight))
 				return 1;
-			}
 		}
 	}
 	return 0;
@@ -658,9 +659,6 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	if (en) {
 		en->lastuse = jiffies;
 
-		/* Get the least loaded destination */
-		dest = ip_vs_dest_set_min(&en->set);
-
 		/* More than one destination + enough time passed by, cleanup */
 		if (atomic_read(&en->set.size) > 1 &&
 		    time_after(jiffies, en->set.lastmod +
@@ -676,6 +674,9 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 			spin_unlock_bh(&svc->sched_lock);
 		}
 
+		/* Get the least loaded destination */
+		dest = ip_vs_dest_set_min(&en->set);
+
 		/* If the destination is not overloaded, use it */
 		if (dest && !is_overloaded(dest, svc))
 			goto out;
-- 
2.56.0


