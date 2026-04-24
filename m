Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E20ED3264CC;
	Fri, 24 Apr 2026 04:11:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777003878; cv=none; b=FtwZrVf4ORQ0DhWlBrHgWZNlmkk4t9zL9ZgdA9v8+zu/WnmLDB0gxtFrHnQ8JkUqIxhrzkRv+CPHRRb4YEZfLub4QGp8MdCHkKBeV5K3bmcvdO5RvyGO61Bnt9eBMjn1TuzWwfbKY4u+vXE961kDzlrYTE6+fOW/xvaY4u8NJXM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777003878; c=relaxed/simple;
	bh=QqMJ8APZXAv/jThgzkl48ZDqf4rg3RNwu38GuypsDSw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=WuVdhHsoECFGiZe5PqZ67G7+pL5w0PsNbThHixs+TRoBAAWtV7oYr5GZWqFk2udir6/Zq3OA6RNqIfyaYO7qEP1bBlCeP/UaHF6BV/hWMDzWmRJ0vg9a74R2Z3afR1jkFM8N8tJik2x1ADcTyu7cyHF83LK0OTrm46hc36zGDJI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=kbzAM6gf; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="kbzAM6gf"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id ACB512126E;
	Fri, 24 Apr 2026 07:11:13 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=HWSPzETrY78Q6YnxMY7oGENlOhhIgC8vQ9vEXd3xBuI=; b=kbzAM6gfPYOO
	pGuMzsZRD4ttVkAYkzOOqaHL+pF9SGA6r7Swkn8Fl/GOk+jdmcamdJu6mSjkTNYw
	vUg+sj/N4g1aj8zlChR9oZaKg0/K7EZX59mso1dWZcu9JS9GvNTm9HebPCiiO2Ht
	Yog343N51m60Eedc+NBmRXn1JM57hF3eV75OEv87XR/5Hd1zJe5BENkmqP5U7Xih
	uS425+/r5NMS2XtdyWdprW9QP2oSVL6p2Bv+M1wyOD3bAVhpDkRLfLpU88Vml182
	DoYMSmCn+ce7n8t+SV3hYEJ7pOjc2Ii0Wy8NZ6hduz6KoNr9++zsdftYyUvFUOa9
	04P1Ozqgn/cffjGZeRjaX5hstfz4pPVqcgEFH8GyN+0dm6QIQEqvWo4j4I0uM6Iy
	U75Ragy2/41CUdFlPTCfR0JyuICcmVlHOP/n+IoNu7wl9IraAAZQCBUYh6cj5/WI
	gF9jMZJ53nHSXli2AWk9/DQ1UmeP3NVu7WbY/LuvX0ulN+aU7WLVVNOD16ubgI3e
	fSs7je22kkd05yTESCpMCNnOLg2Rw3TmAePQKuBUQyhM370kQ0S7cGeHeqHj0bX2
	h+SBXG8SC/jC7J+WG74YnRYzAcatbd+o+FAkfs0kuszAOrnpSubJK9I1tZ3/BRN8
	ezWJm1exdnCPexNL9V5mTJVmv8NKn+Y=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri, 24 Apr 2026 07:11:12 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 1A8E560B2A;
	Fri, 24 Apr 2026 07:11:12 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63O47gjT006130;
	Fri, 24 Apr 2026 07:07:42 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 63O47gnI006129;
	Fri, 24 Apr 2026 07:07:42 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCHv4 net 2/3] ipvs: fix races around the conn_lfactor and svc_lfactor sysctl vars
Date: Fri, 24 Apr 2026 07:07:22 +0300
Message-ID: <20260424040723.6104-3-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260424040723.6104-1-ja@ssi.bg>
References: <20260424040723.6104-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Sashiko warns that the new sysctls vars can be changed
after the hash tables are destroyed and their respective
resizing works canceled, leading to mod_delayed_work()
being called for canceled works.

Solve this in different ways. conn_tab can be present even
without services and is destroyed only on netns exit, so use
disable_delayed_work_sync() to disable the work instead of
adding more synchronization mechanisms.

As for the svc_table, it is destroyed when the services
are deleted, so we must be sure that netns exit is not
called yet (the check for 'enable') and the work is
not canceled by checking all under same mutex lock.

Also, use WRITE_ONCE when updating the sysctl vars as we
already read them with READ_ONCE.

Link: https://sashiko.dev/#/patchset/20260410112352.23599-1-fw%40strlen.de
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_conn.c |  2 +-
 net/netfilter/ipvs/ip_vs_ctl.c  | 12 +++++++++---
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 2082bfb2d93c..84a4921a7865 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1835,7 +1835,7 @@ static void ip_vs_conn_flush(struct netns_ipvs *ipvs)
 
 	if (!rcu_dereference_protected(ipvs->conn_tab, 1))
 		return;
-	cancel_delayed_work_sync(&ipvs->conn_resize_work);
+	disable_delayed_work_sync(&ipvs->conn_resize_work);
 	if (!atomic_read(&ipvs->conn_count))
 		goto unreg;
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 27e50afe9a54..caec516856e9 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2469,7 +2469,7 @@ static int ipvs_proc_conn_lfactor(const struct ctl_table *table, int write,
 		if (val < -8 || val > 8) {
 			ret = -EINVAL;
 		} else {
-			*valp = val;
+			WRITE_ONCE(*valp, val);
 			if (rcu_access_pointer(ipvs->conn_tab))
 				mod_delayed_work(system_unbound_wq,
 						 &ipvs->conn_resize_work, 0);
@@ -2496,10 +2496,16 @@ static int ipvs_proc_svc_lfactor(const struct ctl_table *table, int write,
 		if (val < -8 || val > 8) {
 			ret = -EINVAL;
 		} else {
-			*valp = val;
-			if (rcu_access_pointer(ipvs->svc_table))
+			mutex_lock(&ipvs->service_mutex);
+			WRITE_ONCE(*valp, val);
+			/* Make sure the services are present */
+			if (rcu_access_pointer(ipvs->svc_table) &&
+			    READ_ONCE(ipvs->enable) &&
+			    !test_bit(IP_VS_WORK_SVC_NORESIZE,
+				      &ipvs->work_flags))
 				mod_delayed_work(system_unbound_wq,
 						 &ipvs->svc_resize_work, 0);
+			mutex_unlock(&ipvs->service_mutex);
 		}
 	}
 	return ret;
-- 
2.53.0


