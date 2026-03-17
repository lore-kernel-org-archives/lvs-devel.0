Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3D1A93E1212
	for <lvs-devel@vger.kernel.org>; Tue, 17 Mar 2026 14:01:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773756068; cv=none; b=CMl2p1c6YweEsnfe1Hu6+a6I0zL2gOpKaDTTC68FIEJ/5b9F6YHuvK0rvegUJSasCsXz7PBu+fARbBY49YvfNaOUsNlNyvP4CkHRzkAdrQ+PlNYe9qh2/kUb5JXpAS3BSSFhrs8QaBkUVpNARwBxxhI32pzH06qT6qiRe4VMRrA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773756068; c=relaxed/simple;
	bh=gyxmVw9w8IIW8kTl7ewnjbhQM9u6OeTRE5QFfrT/5N0=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=WRzGQ3TIp2JSM9fMSP3fOYOTcLsaOkptVUjzgrKxlWg4nAGvRsg/09/d5H1K69OpSgyOxwni/Nxm80umFIKbxE3dJUh8D6cGAiUp9z276mv/GBLQjleIY7xiLWHy4N2mcAWogBgGnodPEIX7QWsQ72OrHQ50LY2l0r7BA6WvHHk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de; spf=pass smtp.mailfrom=suse.de; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=X2ml0pbA; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=nz8bGRKe; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=PzLpze84; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=cbS+TY6W; arc=none smtp.client-ip=195.135.223.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="X2ml0pbA";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="nz8bGRKe";
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="PzLpze84";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="cbS+TY6W"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 58AA24D337;
	Tue, 17 Mar 2026 14:01:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1773756065; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:  content-transfer-encoding:content-transfer-encoding;
	bh=Z42gc913v7qs82hn1hB8yx7ErxPW9ggLXqvAyIcz4oU=;
	b=X2ml0pbAFz/6aqKGt6pgRhQL2Hl/w2d00SJVS1d3/5Q/qixaw5J6Vg5Il628neoi7RGf9K
	3iKg/q5tCHivR2YRENH8bkKwFERBNJL9wXOg4CqwOyzcv8EP/fjQgNuHboQnzTZQZOOGph
	BSbzSCO8QLeaHJ3liB/AjpEvUTQ4Nf8=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1773756065;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:  content-transfer-encoding:content-transfer-encoding;
	bh=Z42gc913v7qs82hn1hB8yx7ErxPW9ggLXqvAyIcz4oU=;
	b=nz8bGRKefAFc1zH48fLvTHd8x8eVYwyQv9s+xoo0my4hQlYqwORkLGVER8EuznKvuj7Hjv
	DN7pw2uIdq08ndDg==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1773756062; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:  content-transfer-encoding:content-transfer-encoding;
	bh=Z42gc913v7qs82hn1hB8yx7ErxPW9ggLXqvAyIcz4oU=;
	b=PzLpze84/YZswWKbOpqheJUOTvlrxh2kCUc8N1qRZxvh5FfpY56/Rl20eg/FWJXMlnbAMj
	NQcpP5Jxk9L1gt3SjwpJ+EulLpUeKVrhxuK4oYnhig/lxAVwysW2z3z0FeyWzrB/ao/qNj
	Ys+LIGU0agQautlsYYHuHQjXdUp/i/Y=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1773756062;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:  content-transfer-encoding:content-transfer-encoding;
	bh=Z42gc913v7qs82hn1hB8yx7ErxPW9ggLXqvAyIcz4oU=;
	b=cbS+TY6W/h6Kw4wDA0lmiglzupArg2cW7RfwkwQM0ant1e4YuLVUnw0dMYVowzSmNzK9/b
	jR/JSY0wjT3N+ZAQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 395684273B;
	Tue, 17 Mar 2026 14:01:02 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id HNbyDZ5euWmjYgAAD6G6ig
	(envelope-from <iluceno@suse.de>); Tue, 17 Mar 2026 14:01:02 +0000
From: Ismael Luceno <iluceno@suse.de>
To: linux-kernel@vger.kernel.org,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	"David S . Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>
Cc: Ismael Luceno <iluceno@suse.de>,
	Marco Crivellari <marco.crivellari@suse.com>,
	Federico Pinca <federico.pinca@suse.com>,
	Andreas Taschner <andreas.taschner@suse.com>,
	Brad Bendily <brad.bendily@suse.com>,
	Brendon Caligari <brendon.caligari@suse.com>,
	Clemens Famulla-Conrad <cfamullaconrad@suse.com>,
	Firo Yang <firo.yang@suse.com>,
	Gabriel Krisman Bertazi <gabriel.bertazi@suse.com>,
	Hans van den Heuvel <hvdheuvel@suse.com>,
	Jean Delvare <jdelvare@suse.com>,
	Michal Hocko <mhocko@suse.com>,
	=?UTF-8?q?Michal=20Koutn=C3=BD?= <mkoutny@suse.com>,
	Petr Mladek <pmladek@suse.com>,
	Petr Tesarik <ptesarik@suse.com>,
	Richard Thompson <richard.thompson@suse.com>,
	William Preston <wpreston@suse.com>,
	Yu Xu <yu.xu@suse.com>,
	Simon Horman <horms@kernel.org>,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org
Subject: [PATCH] ipvs: Move defense_work to system_dfl_long_wq
Date: Tue, 17 Mar 2026 15:00:59 +0100
Message-ID: <20260317140100.24993-2-iluceno@suse.de>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Spamd-Result: default: False [-2.80 / 50.00];
	BAYES_HAM(-3.00)[99.99%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_CONTAINS_FROM(1.00)[];
	R_MISSING_CHARSET(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	FROM_HAS_DN(0.00)[];
	ARC_NA(0.00)[];
	MIME_TRACE(0.00)[0:+];
	TO_DN_SOME(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[33];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:helo,suse.de:mid,suse.de:email];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	RCVD_COUNT_TWO(0.00)[2];
	FUZZY_RATELIMITED(0.00)[rspamd.com];
	DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	R_RATELIMIT(0.00)[to_ip_from(RL4e5bdig4hxau1598td9p5syh)];
	RCVD_TLS_ALL(0.00)[]
X-Spam-Flag: NO
X-Spam-Score: -2.80
X-Spam-Level: 

Under synflood conditions binding defense_work to system_long_wq may
pin it to a saturated CPU.

We've observed improved throughtput on a DPDK/VPP application with
this change. We attribute this to the reduced context switching.

The defense_work handler has no per-CPU data dependencies and no cache
locality requirements that would justify this.

Signed-off-by: Ismael Luceno <iluceno@suse.de>
---
Depends-on: wq/for-7.1 c116737e972e ("workqueue: Add system_dfl_long_wq for long unbound works")

 net/netfilter/ipvs/ip_vs_ctl.c | 6 +++---
 net/netfilter/ipvs/ip_vs_est.c | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 35642de2a0fe..948ae5882a70 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -234,7 +234,7 @@ #define DEFENSE_TIMER_PERIOD	1*HZ
 	update_defense_level(ipvs);
 	if (atomic_read(&ipvs->dropentry))
 		ip_vs_random_dropentry(ipvs);
-	queue_delayed_work(system_long_wq, &ipvs->defense_work,
+	queue_delayed_work(system_dfl_long_wq, &ipvs->defense_work,
 			   DEFENSE_TIMER_PERIOD);
 }
 #endif
@@ -273,7 +273,7 @@ #define DEFENSE_TIMER_PERIOD	1*HZ
 	atomic_set(&ipvs->est_genid_done, genid);
 
 	if (repeat)
-		queue_delayed_work(system_long_wq, &ipvs->est_reload_work,
+		queue_delayed_work(system_dfl_long_wq, &ipvs->est_reload_work,
 				   delay);
 
 unlock:
@@ -4377,7 +4377,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 		goto err;
 
 	/* Schedule defense work */
-	queue_delayed_work(system_long_wq, &ipvs->defense_work,
+	queue_delayed_work(system_dfl_long_wq, &ipvs->defense_work,
 			   DEFENSE_TIMER_PERIOD);
 
 	return 0;
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index b17de33314da..454ea24828cc 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -235,7 +235,7 @@ #define pr_fmt(fmt) "IPVS: " fmt
 	ip_vs_est_stopped_recalc(ipvs);
 	/* Bump the kthread configuration genid */
 	atomic_inc(&ipvs->est_genid);
-	queue_delayed_work(system_long_wq, &ipvs->est_reload_work, 0);
+	queue_delayed_work(system_dfl_long_wq, &ipvs->est_reload_work, 0);
 }
 
 /* Start kthread task with current configuration */
