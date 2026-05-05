Received: from mail.netfilter.org (mail.netfilter.org [217.70.190.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9C9B8218845;
	Tue,  5 May 2026 00:16:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.190.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777940221; cv=none; b=KywYeQjkKr4xwvHi01iolHhMMEa7kA1vbiAFGNEkkyeoHYSygugwDPVnYhZpYrd1iHGC0yxmxKBBrsxp6p2PzriUex+uynnUSep45BrsgyrE2vFuJGi4F30rN8FiXMOZCHOgeapvd1KFPPPqyCuDlXjV7r5/EMA99w2hWbg5WB4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777940221; c=relaxed/simple;
	bh=npGhvdKzkfMC4qabIVyLBSFR74w4EY3wRMgIRq6ovGw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Y7WeuhavMlBfsYCZKB6abAfxki4Fkdb90DQ/B0SUTycdpf0WPfD8wmIjg5fzL0rh8aSubeiIGmj8WYXCVFn6MrdbS3aVNbXhzDFbzgB+88x5ObZZ4CrqgL+E+KVU0AU4KwPtfNb6hWLLjzihDRHg+7AsINCmqYVebDNE+w8E0kY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org; spf=pass smtp.mailfrom=netfilter.org; dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b=F1jAKcj4; arc=none smtp.client-ip=217.70.190.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netfilter.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b="F1jAKcj4"
Received: from localhost.localdomain (mail-agni [217.70.190.124])
	by mail.netfilter.org (Postfix) with ESMTPSA id 68E4E60190;
	Tue,  5 May 2026 02:16:57 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1777940218;
	bh=eLZqmbXpHb+G/imfF0SlVGzLkv43Dceyd28jwXnq7Sk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=F1jAKcj4fC8Y4sbcvyny8zyLScoDC/nhq5DF0s0NcVgn3CD+V2mkQ0f7Vf2cHyP/P
	 0Uuuu+1Fwgfy1qwVMo1FrsCqNOdYtcTj7lNfnt4UkSSFA2SCoRhQHDid0Pvhai/ix3
	 ofJClg+2A5kmEm1jdXhx0hhMVgtwc9j1ECgO+Mj4VwF7GX69wo5H/NcFELLiHLy5II
	 HsJlK8jhz8AC2Wp8GF08Jsdg9jJOHMVjqs21tbEyg40NxUdeyTX2X0GLN+QXfcDJzp
	 CE755ofKTKuDpicfbhEjsjrCUazRAyzl5GDbnljqYMstpVesoRyAOd7ZYTGV3dcWci
	 Eq/gsPkEZ8M2A==
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
Subject: [PATCH net 2/8] ipvs: fix races around the conn_lfactor and svc_lfactor sysctl vars
Date: Tue,  5 May 2026 02:16:42 +0200
Message-ID: <20260505001648.360569-3-pablo@netfilter.org>
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
Fixes: 8d7de5477e47 ("ipvs: add conn_lfactor and svc_lfactor sysctl vars")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
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
2.47.3

