Received: from mail-pg1-f175.google.com (mail-pg1-f175.google.com [209.85.215.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 077612F6918
	for <lvs-devel@vger.kernel.org>; Mon,  5 Oct 2026 13:06:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.215.175
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791205601; cv=none; b=OPb6z/o9OFOzV9bzAPMZ+HEN7jgq3GeS1ReWrsAPbokCBsekgITQLMayuBu3tDXxhAX9h9wBfExGxNJJ9HlABCgqUKDq5oXFC01e8nzU2Bojycytyr4G6adkPkpdEu2sMGQyCM87sjcxZ5FZ2gkVVtCpuCgnt5GtDh81xmFWMcg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791205601; c=relaxed/simple;
	bh=QMIU/UZ6KPPbqGEF4cZOHenQIHLxdgqZ3pyLgWHXBlc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=d8ERSdihcEnko+GZX64uIAB4ziFb5Noc5OCjOXsTpvG1Q6wM1vnpe8WbvrGFoTnbdQHTUGIWYebLuqLAwy2kHjF5UZMWciXmW94FeGwS/kPLdbd+qeC4cHS9iEfpyvDfsy7vLQAXZe8eP3HxSxt48XmfIZiaaQM7Tdigx6eUBXg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai; spf=pass smtp.mailfrom=nebusec.ai; dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b=cX3PyVoy; arc=none smtp.client-ip=209.85.215.175
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b="cX3PyVoy"
Received: by mail-pg1-f175.google.com with SMTP id 41be03b00d2f7-cc4aa02a269so664109a12.2
        for <lvs-devel@vger.kernel.org>; Mon, 05 Oct 2026 06:06:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=nebusec.ai; s=google; t=1791205597; x=1791810397; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=tPSpZrKZnbvScFphhWC9G5tiQWEcRUY/kCemh7t9Obs=;
        b=cX3PyVoyD8YpFVIZXeTfk3URyTVXWarIN4r4XzSu/lIcLbUoJwY3hKQByrGCeOq20i
         p+rVFRogYp/Czxzwkj99HKAwulHVBAQc50hZmMDj5ILFH24RclaFoWDnkMPaWsMllwHp
         NsA9w5N9Nvit+q158zTr6YBKzvqH2zzAlUQqXMhgysWiAZ8X99PPAqejhDN4p6oCg/Z1
         uervxUpWEMtY9RyZ5809ai+eMSieNNl5AMm3ZkMbM1Qf3h8jlnfRASd4MNqi1H7vN7bi
         dAsPt8BtWquNNuMWIWS+XYNajf/ahCaWqU/O+aIMuh8Uh6ZoJdrCmMMypdBSVlQVjHHb
         n/7w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791205597; x=1791810397;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=tPSpZrKZnbvScFphhWC9G5tiQWEcRUY/kCemh7t9Obs=;
        b=b0X/Nt+VVjlTVHUfzkNkqwgEICC3E413KUHcdGyNEDwTD3ckKY7gjfiHTiW6mbJssv
         dQ5N/ytthLur2gIS1O6zadKRSHtYhzMWb0weNIZ9sMLYBJLG24IWYY4N1O8crql7QJca
         rnYpVOs9OEM6N1Id5GMSJWswqq9lIcaHcwvW2BRuk1UsYOXA9wTVktjepwSnRxbuJWVa
         EAuaRtzvJw8x7/KdJKNWD+iI6eb+8+1yKohdTJdex36hONClLuvEOA7Hw3GH84Bv8R03
         JzJGxWqQQb9T7K5Emq0VfrTS5vGLprqfFs8/CUWClJti3WMbvT+72mS1g3OY45qe7f/s
         UhMQ==
X-Gm-Message-State: AFuF++lyeHdSNrKhVA2jt19c5O8SZAvEZCjAce4Rm+l7m10hRCqVixPG
	4BHymJG0hs8QdhFQuHvKegMUkyKplM3S8BP9K2oZFD0BT/K1Jc0Gxkhgad/PcNFjReCzQJw0EH5
	CFCKg72drnoM=
X-Gm-Gg: AYBFou3/G7fZSsr4o965ffCAh9zscoMearVbyRSkM1+SrF6/PORpBcX1WsefoEuDvHa
	6ldpgMa+UXK4xcAwzxxrRbBIEdLtAx8iP2tgS3qe+xsBCffLMlhoaWbM8G13io/VHF1ku5lo7DJ
	4HIRiRG1AOnlPLaLGCuCD/baHMOemwaFDz5fqb1piKrb45f1yCuOCs+WtIMREQ69o3/KKrHkEBo
	AveZRjibOdjMb25tZlMQScrBL1KqnQAnLnbRrT615OL3Ncq7WwZ64g7OtpTSA/d2ln/Ixz3wW4c
	U6OZvPubj5q6N9fgPKZg36xnIjCc6qFAwpQ0RcA3NfKDXTfAFuSL9l5VZluix1Wazk8WZ4Am+mZ
	8RagHByaIbiMeUm/BJNQgoCygZONrr0k90nMsvso+MmqV3b6yjOuefhFL0oQTs6vy48Ie6wl+wr
	jbcPk6pRgMkTUgQCOyDijI5Lgl/Ujw58R5u7ae1buxgUpPxYqREeD7Y7PRo67VZBwrFlrk3htCA
	pnWOuva+T8pGVWX8lJqTkBA55SCFHfHxIN8PiTS
X-Received: by 2002:a05:6a21:1518:b0:3e0:b937:8841 with SMTP id adf61e73a8af0-3e0d6d40bb5mr7033306637.48.1791205596953;
        Mon, 05 Oct 2026 06:06:36 -0700 (PDT)
Received: from 954df21a5119.. ([122.51.212.64])
        by smtp.gmail.com with ESMTPSA id 41be03b00d2f7-cce6d334dd6sm785236a12.9.2026.10.05.06.06.30
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 05 Oct 2026 06:06:35 -0700 (PDT)
From: Zihan Xi <zihanx@nebusec.ai>
To: lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Cc: dsahern@kernel.org,
	idosch@nvidia.com,
	horms@verge.net.au,
	ja@ssi.bg,
	davem@davemloft.net,
	edumazet@kernel.org,
	pabeni@redhat.com,
	pablo@netfilter.org,
	fw@strlen.de,
	phil@nwl.cc,
	vega@nebusec.ai,
	root@tr0jan.top,
	zihanx@nebusec.ai
Subject: [PATCH nf v6 1/3] ipvs: fix problems during connection deletion
Date: Mon,  5 Oct 2026 13:06:17 +0000
Message-ID: <1a6f23159d5633177b04d340dff903f92ab1518b.1791194172.git.zihanx@nebusec.ai>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <cover.1791194172.git.zihanx@nebusec.ai>
References: <cover.1791194172.git.zihanx@nebusec.ai>
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
is freed. As ip_vs_conn_del() runs under RCU lock
there is no risk for accessing a connection freed
by concurrent timer callback. As Sashiko warns, the
risk is present if normal connection expires and
tries to delete its cp->control chain with
ip_vs_conn_del_put() without holding a RCU read lock.

It is evident that as the pending timer and the
running timer callback do not hold reference for
the connection, there are races which is difficult
to avoid.

Change the connection refcounting as follows:

* the connection hashing does not take reference anymore

* new connection handoffs its reference to the timer
if started in __ip_vs_conn_put_timer(), to hold it
while it is pending.

* if user finds connection in hash table it gets reference
and can handoff this reference to the pending timer if
this timer is started in __ip_vs_conn_put_timer(),
otherwise puts its reference if the timer was already
pending which is the common case.

* the pending timer handoffs its reference to the
running timer callback implicitly. By this way, the
timer callback in the common case has the last reference.
In rare cases, while the timer callback is running and
before it changes refcnt from 1 to 0, other users can get
reference and to handoff it again to the pending timer
they arm. In this case, the expiration is deferred
for later time.

As result, cp->refcnt accounts all current connection
users and the pending and running timer.

Two paths can try to delete the connection: the
normal expiration path and ip_vs_conn_del() if it
successfully steals the connection reference from the
pending timer. refcount_dec_if_one() will tell us if
we were the last active user with no packets accessing
the connection and no pending/running timers.

Change ip_vs_conn_unlink() to directly unhash the
connection because when we are the last user the
connection's forwarding method can not change.
Use smp_acquire__after_ctrl_dep() after refcount_dec_if_one()
and before reading the connection fields.

ip_vs_conn_expire() does not need to call timer_delete()
anymore because the pending timer is already accounted
in refcnt.

Add explicit rcu_read_lock() while deleting the cp->control
chain to protect from concurrent timer callback for ct to
expire it before us and to cause use-after-free.

During such races, try to keep 0 in cp->timeout as it is
a request for deleting our cp->control chain immediately.
Make sure we do not send timeout 0 (seconds) in the
v1 sync message because the backup server will select some
large default value which is not desired for small timeouts.

Remove the smp_mb__before_atomic() call from __ip_vs_conn_put(),
it is from the atomic_dec() era, now refcount_dec() has
RELEASE semantics.

Link: https://sashiko.dev/#/patchset/cover.1789435989.git.zihanx%40nebusec.ai
Link: https://netdev-ai.bots.linux.dev/sashiko/#/patchset/cover.1790266803.git.zihanx%40nebusec.ai
Fixes: f9200a52eedf ("ipvs: avoid expiring many connections from timer")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h             |  1 -
 net/netfilter/ipvs/ip_vs_conn.c | 99 ++++++++++++++++++---------------
 net/netfilter/ipvs/ip_vs_sync.c |  2 +-
 3 files changed, 55 insertions(+), 47 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 32fde731bceb..94023d17f648 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1677,7 +1677,6 @@ static inline bool __ip_vs_conn_get(struct ip_vs_conn *cp)
 /* put back the conn without restarting its timer */
 static inline void __ip_vs_conn_put(struct ip_vs_conn *cp)
 {
-	smp_mb__before_atomic();
 	refcount_dec(&cp->refcnt);
 }
 void ip_vs_conn_put(struct ip_vs_conn *cp);
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 6fa3e1dc534c..862731c94bce 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -293,7 +293,6 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
 	cp->flags |= IP_VS_CONN_F_HASHED;
 	WRITE_ONCE(cp->hn0.hash_key, hash_key);
 	WRITE_ONCE(cp->hn1.hash_key, hash_key2);
-	refcount_inc(&cp->refcnt);
 	hlist_bl_add_head_rcu(&cp->hn0.node, head);
 	if (use2)
 		hlist_bl_add_head_rcu(&cp->hn1.node, head2);
@@ -319,11 +318,27 @@ static inline bool ip_vs_conn_unlink(struct ip_vs_conn *cp)
 	struct hlist_bl_head *head, *head2;
 	u32 hash_key, hash_key2;
 	struct ip_vs_rht *t;
-	bool ret = false;
 	bool use2;
 
+	/* No more users and no running/pending timer except us? */
+	if (!refcount_dec_if_one(&cp->refcnt))
+		return false;
+
+	/* The ONE_PACKET connection is special:
+	 * - the flag is present only for normal connections, not for templates
+	 * - its timer is never started
+	 * - it is never hashed, so you can not find it and delete it
+	 * - it is not synced
+	 * - it has only one user
+	 * - it is freed after use immediately
+	 */
 	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
-		return refcount_dec_if_one(&cp->refcnt);
+		return true;
+
+	/* Add the needed ACQUIRE barrier between the above
+	 * refcount_dec_if_one() call and the read of cp fields
+	 */
+	smp_acquire__after_ctrl_dep();
 
 	rcu_read_lock();
 	local_bh_disable();
@@ -337,15 +352,11 @@ static inline bool ip_vs_conn_unlink(struct ip_vs_conn *cp)
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
@@ -353,7 +364,7 @@ static inline bool ip_vs_conn_unlink(struct ip_vs_conn *cp)
 	local_bh_enable();
 	rcu_read_unlock();
 
-	return ret;
+	return true;
 }
 
 
@@ -621,9 +632,12 @@ static void __ip_vs_conn_put_timer(struct ip_vs_conn *cp)
 {
 	unsigned long t = (cp->flags & IP_VS_CONN_F_ONE_PACKET) ?
 		0 : cp->timeout;
-	mod_timer(&cp->timer, jiffies+t);
 
-	__ip_vs_conn_put(cp);
+	/* Handoff our reference to the timer if it was just armed,
+	 * put the reference if timer was already pending.
+	 */
+	if (mod_timer(&cp->timer, jiffies + t))
+		__ip_vs_conn_put(cp);
 }
 
 void ip_vs_conn_put(struct ip_vs_conn *cp)
@@ -1319,9 +1333,18 @@ static void ip_vs_conn_rcu_free(struct rcu_head *head)
 	kmem_cache_free(ip_vs_conn_cachep, cp);
 }
 
-/* Try to delete connection while not holding reference */
+/* Try to delete connection while not holding reference.
+ * It can be called concurrently and always under RCU lock
+ * to protect from connection deletion from others.
+ * Used when we need to remove the connection immediately
+ * and without overloading the timer processing.
+ * OTOH, we use ip_vs_conn_expire_now() when we prefer to
+ * leave the current context (packet processing) and to
+ * remove the connection from timer.
+ */
 static void ip_vs_conn_del(struct ip_vs_conn *cp)
 {
+	/* Steal reference from the pending timer */
 	if (timer_delete(&cp->timer)) {
 		/* Drop cp->control chain too */
 		if (cp->control)
@@ -1330,20 +1353,11 @@ static void ip_vs_conn_del(struct ip_vs_conn *cp)
 	}
 }
 
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
-}
-
+/* Connection is removed in the following steps:
+ * - timer expires (with ref) or connection is deleted (with stolen ref)
+ * - there should be no more users except us (pending/running timer,
+ * n_control>0 or refcnt>1)
+ */
 static void ip_vs_conn_expire(struct timer_list *t)
 {
 	struct ip_vs_conn *cp = timer_container_of(cp, t, timer);
@@ -1359,23 +1373,18 @@ static void ip_vs_conn_expire(struct timer_list *t)
 	if (likely(ip_vs_conn_unlink(cp))) {
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
@@ -1410,8 +1419,8 @@ static void ip_vs_conn_expire(struct timer_list *t)
 		  refcount_read(&cp->refcnt),
 		  atomic_read(&cp->n_control));
 
-	refcount_inc(&cp->refcnt);
-	cp->timeout = 60*HZ;
+	if (cp->timeout || atomic_read(&cp->n_control))
+		cp->timeout = 60 * HZ;
 
 	if (ipvs->sync_state & IP_VS_STATE_MASTER)
 		ip_vs_sync_conn(ipvs, cp, sysctl_sync_threshold(ipvs));
@@ -1429,7 +1438,7 @@ static void ip_vs_conn_expire(struct timer_list *t)
 void ip_vs_conn_expire_now(struct ip_vs_conn *cp)
 {
 	/* Using mod_timer_pending will ensure the timer is not
-	 * modified after the final timer_delete in ip_vs_conn_expire.
+	 * started without giving it new reference.
 	 */
 	if (timer_pending(&cp->timer) &&
 	    time_after(cp->timer.expires, jiffies))
@@ -1497,9 +1506,9 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p, int dest_af,
 	spin_lock_init(&cp->lock);
 
 	/*
-	 * Set the entry is referenced by the current thread before hashing
-	 * it in the table, so that other thread run ip_vs_random_dropentry
-	 * but cannot drop this entry.
+	 * Set the entry as referenced by the current thread before starting
+	 * the timer and giving it our reference to allow other threads to
+	 * run ip_vs_random_dropentry() or any deletion method safely.
 	 */
 	refcount_set(&cp->refcnt, 1);
 
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 5383aeafb0ae..0036ace13fdb 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -727,7 +727,7 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
 	s->v4.vport = cp->vport;
 	s->v4.dport = cp->dport;
 	s->v4.fwmark = htonl(cp->fwmark);
-	s->v4.timeout = htonl(cp->timeout / HZ);
+	s->v4.timeout = htonl(max(1UL, cp->timeout / HZ));
 	m->nr_conns++;
 
 #ifdef CONFIG_IP_VS_IPV6
-- 
2.43.0

