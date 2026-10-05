Received: from mail-pz2-f40.google.com (mail-pz2-f40.google.com [74.125.228.40])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7B7A645DF49
	for <lvs-devel@vger.kernel.org>; Mon,  5 Oct 2026 13:07:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.228.40
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791205642; cv=none; b=TRD6BEOA/Dceky/EqnUuG6kz4GXZ4P13oxdLQa5nKs3G2J+n5GqI9geCWWOnwuRmLgesfCTCGHUszIR5t1VY0Wr3f7rdlUICoz/T2oYBecOFlLqNTpKoNFSt7uBCKKfbWkdijea77ZRQ9PHFisc/zFpucZoCWQaDwiCHKkrvMQQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791205642; c=relaxed/simple;
	bh=NOmCfmWZ5OYjyeJt33xeBqQsa/xlb1PiagSWT7wD7Xg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=a5oengnuriNgfRS+8L+t2hNaGeQB9jMC+Myl2sUpDbusE3SnElWNh4Pwfr1lRhx7qrpcwu3Cho1Co1uMIfdRV9bxdVgUtmb9DyfS5Dbx5G4wlrxolxUL/bIEjkBetRz8E+A8LIa7si5Q8pnXmpBqGKcvmVJaQHsYgvGADED5TaA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai; spf=pass smtp.mailfrom=nebusec.ai; dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b=tO8//F6b; arc=none smtp.client-ip=74.125.228.40
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b="tO8//F6b"
Received: by mail-pz2-f40.google.com with SMTP id 41be03b00d2f7-cc74520b20bso374635a12.1
        for <lvs-devel@vger.kernel.org>; Mon, 05 Oct 2026 06:07:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=nebusec.ai; s=google; t=1791205641; x=1791810441; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Po7hEeJ6c5N6N8lVIIUjkLh+Mo7McigzXlftFVQL6Mo=;
        b=tO8//F6bmcjkJ2Z7DYT6h33707Cbr482+rFYLFwj6gfEzr0uZijzsbjdhln2dOpyCI
         fgPMIYO0y1kD5/6A6It9T6xUJ9Mdfk1KevvCCtErzIZlCrvlsTVXSK10NWb4drXP9ZnX
         0Hctu2UF12qdqMWWNKWgRrHwmLzTSB18gEnACmr5Z+54Tjq1woWaXX8xkfkgB7kx/wlo
         BRPkZmITRjWe4nm0nursFHcoBTSByjiHbgtC7uMEeuhFpjU5gyJcXdyE6LMrkvH/bUYq
         iJP8hqSnc3g38jn1AB+n2XA0+E7lsqzACjr5RQ214ip+ZuRpzSW3OFJA/K6RrJVoP1JN
         aQRQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791205641; x=1791810441;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=Po7hEeJ6c5N6N8lVIIUjkLh+Mo7McigzXlftFVQL6Mo=;
        b=SVYXgjqOTYpFI5Anix9n/3KmurbVEfQA2k3z6yTtVRt1RqZP6QMGPttn0u1vtfzLUz
         7+00DumqvmHlhBvRpifU1CzWhu8H5dvUevsGXkGUI/pQAqNLdr40sIF5keDFejCrqSYc
         0553qUCaFck3w6K94x80EQkpFnLpAICBFlUfL6R1z7DCh3GBTtrJ5YaajS+wRs6LQWUi
         rYfuQdDkDc8tpbc1rH/XQwceDpiPVN6/rvcZpXTA1RN8ZXevquluil+sIB4jdSFCMkgC
         PyAmnV8wiYMG5+CCypec5UlNiJrQkC/sW1R09POY/vS2SnWo2nAybztN79bZno/6BRLg
         TJcw==
X-Gm-Message-State: AFuF++mLml+ixH2wQvFX2TooYPpzcfyo0TYFWfYxxhWXg90f/t49IyWT
	/dl3jH9E4Rg+n63sQ2hR2ZSjvJ6khsB86EfzItbRE5gF1n8OnTAOfZ8BYQmzg68RwEVrkrsZdr/
	Ic9yX0Sj2rb0=
X-Gm-Gg: AYBFou0srVK0DAoi0sbHkB60ovj3VbenKzirft1A6DWdOER4emu+RJRuOboqYy2gD/E
	yyaTCDe+HSzoJW9YV3SEuwEa99dODfSD/qIsmHal6o8aWygWi5rzbv2ONE8T8XeYsym45k1aqL2
	tZBMp5zNUQtMMRHXCLpqGFUviYQ2lPu02Mw6RLWK8Yn8F0EcuMEC2KHhaYamKUUmg9bYjWEF8dB
	G8mBOWE4dJCwVRwsX7w39U85YMwuMkuKOAK8L5vzbQML9b9V4mYcwPTPGDOrZuI0voXXrCTjM+J
	6hXL7npgFKaSIm4na9764A18TNIJHX1mFAOMtruw6v+Bx9i83up85tIzZf1K60w9A9ec5jIFMpj
	tU+4Mj/QtqeymdaGcFYyadhUX9OPo2EmoB/6/zVpgTZJJCfkb8suYNyC3HoDdwTWtF9vEtP6k3x
	fbuUv7r22Cy2pW2qimcQ+j9w5BN6NS1Ep7rIywmNu+EzY6gTiCZu//epeshvtnEjjOma8lWlTsZ
	H2dH59X+/s9e6UpGTBFKzndSduGiw==
X-Received: by 2002:a05:6a20:e18a:b0:3dd:a196:ffcf with SMTP id adf61e73a8af0-3e0bd4099abmr6153367637.31.1791205603927;
        Mon, 05 Oct 2026 06:06:43 -0700 (PDT)
Received: from 954df21a5119.. ([122.51.212.64])
        by smtp.gmail.com with ESMTPSA id 41be03b00d2f7-cce6d334dd6sm785236a12.9.2026.10.05.06.06.37
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 05 Oct 2026 06:06:42 -0700 (PDT)
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
Subject: [PATCH nf v6 2/3] ipvs: avoid stack overflow from recursive connection expiration
Date: Mon,  5 Oct 2026 13:06:18 +0000
Message-ID: <766c069e460660b20d405a87444399decceae9c0.1791194172.git.zihanx@nebusec.ai>
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

When a controlled IPVS connection expires, its controller may be expired
synchronously if it has no remaining controlled connections. A chain of
controlled connections can then recurse through ip_vs_conn_expire() and
exhaust the kernel stack during namespace cleanup.

Continue expiration with the controller after the current connection has
been fully cleaned up instead of calling ip_vs_conn_del() recursively. Keep
the expiration walk under RCU, preserve the immediate-drop timeout for a
controller with its own controller, and switch to deletion mode before the
next iteration.

This keeps controlled-connection cleanup synchronous while using one stack
frame for the whole chain. The timer callback race during connection
deletion is handled by the preceding connection-deletion fix.

This patch depends on "ipvs: fix problems during connection deletion" to
protect the iterative controller cleanup from the timer callback race.

Fixes: f9200a52eedf ("ipvs: avoid expiring many connections from timer")
Cc: stable@vger.kernel.org
Reported-by: Vega <vega@nebusec.ai>
Assisted-by: LLM
Co-developed-by: Luxing Yin <root@tr0jan.top>
Signed-off-by: Luxing Yin <root@tr0jan.top>
Signed-off-by: Zihan Xi <zihanx@nebusec.ai>
---
changes in v6:
  - Rebase the iterative cleanup on ip_vs_conn_del_reference() from
    Julian Anastasov's latest connection-deletion fix.
  - v5 Link: https://lore.kernel.org/all/cover.1790266803.git.zihanx@nebusec.ai/
changes in v5:
  - Rebase the iterative cleanup on Julian Anastasov's v3 fix.
  - v4 Link: https://lore.kernel.org/all/cover.1790146910.git.zihanx@nebusec.ai/
changes in v4:
  - Rebase controller cleanup on the timer-callback deletion fix.
  - v3 Link: https://lore.kernel.org/all/cover.1789877273.git.zihanx@nebusec.ai/
changes in v3:
  - Keep controller cleanup iterative and synchronous.
  - v2 Link: https://lore.kernel.org/all/cover.1789435989.git.zihanx@nebusec.ai/
changes in v2:
  - Replace recursive controller expiration with an iterative path.
  - v1 Link: https://lore.kernel.org/all/cover.1789110326.git.zihanx@nebusec.ai/
 net/netfilter/ipvs/ip_vs_conn.c | 40 ++++++++++++++++++++++++---------
 1 file changed, 29 insertions(+), 11 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 862731c94bce..72fe609bf4ac 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1333,9 +1333,23 @@ static void ip_vs_conn_rcu_free(struct rcu_head *head)
 	kmem_cache_free(ip_vs_conn_cachep, cp);
 }
 
-/* Try to delete connection while not holding reference.
+/* Try to steal the reference from the pending timer.
  * It can be called concurrently and always under RCU lock
  * to protect from connection deletion from others.
+ */
+static bool ip_vs_conn_del_reference(struct ip_vs_conn *cp)
+{
+	/* Steal reference from the pending timer */
+	if (!timer_delete(&cp->timer))
+		return false;
+
+	/* Drop cp->control chain too */
+	if (cp->control)
+		cp->timeout = 0;
+	return true;
+}
+
+/* Try to delete connection while not holding reference.
  * Used when we need to remove the connection immediately
  * and without overloading the timer processing.
  * OTOH, we use ip_vs_conn_expire_now() when we prefer to
@@ -1344,13 +1358,8 @@ static void ip_vs_conn_rcu_free(struct rcu_head *head)
  */
 static void ip_vs_conn_del(struct ip_vs_conn *cp)
 {
-	/* Steal reference from the pending timer */
-	if (timer_delete(&cp->timer)) {
-		/* Drop cp->control chain too */
-		if (cp->control)
-			cp->timeout = 0;
+	if (ip_vs_conn_del_reference(cp))
 		ip_vs_conn_expire(&cp->timer);
-	}
 }
 
 /* Connection is removed in the following steps:
@@ -1363,6 +1372,9 @@ static void ip_vs_conn_expire(struct timer_list *t)
 	struct ip_vs_conn *cp = timer_container_of(cp, t, timer);
 	struct netns_ipvs *ipvs = cp->ipvs;
 
+	rcu_read_lock();
+
+repeat:
 	/*
 	 *	do I control anybody?
 	 */
@@ -1372,19 +1384,18 @@ static void ip_vs_conn_expire(struct timer_list *t)
 	/* Unlink conn if not referenced anymore */
 	if (likely(ip_vs_conn_unlink(cp))) {
 		struct ip_vs_conn *ct = cp->control;
+		bool next = false;
 
 		/* does anybody control me? */
 		if (ct) {
-			rcu_read_lock();
 			ip_vs_control_del(cp);
 			/* Drop CTL or non-assured TPL if not used anymore */
 			if (!cp->timeout && !atomic_read(&ct->n_control) &&
 			    (!(ct->flags & IP_VS_CONN_F_TEMPLATE) ||
 			     !(ct->state & IP_VS_CTPL_S_ASSURED))) {
 				IP_VS_DBG(4, "drop controlling connection\n");
-				ip_vs_conn_del(ct);
+				next = ip_vs_conn_del_reference(ct);
 			}
-			rcu_read_unlock();
 		}
 
 		if ((cp->flags & IP_VS_CONN_F_NFCT) &&
@@ -1411,7 +1422,11 @@ static void ip_vs_conn_expire(struct timer_list *t)
 		else
 			call_rcu(&cp->rcu_head, ip_vs_conn_rcu_free);
 		atomic_dec(&ipvs->conn_count);
-		return;
+		if (next) {
+			cp = ct;
+			goto repeat;
+		}
+		goto out;
 	}
 
   expire_later:
@@ -1426,6 +1441,9 @@ static void ip_vs_conn_expire(struct timer_list *t)
 		ip_vs_sync_conn(ipvs, cp, sysctl_sync_threshold(ipvs));
 
 	__ip_vs_conn_put_timer(cp);
+
+out:
+	rcu_read_unlock();
 }
 
 /* Modify timer, so that it expires as soon as possible.
-- 
2.43.0

