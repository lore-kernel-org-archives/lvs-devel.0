Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 01E553BA243;
	Wed, 29 Apr 2026 14:14:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777472069; cv=none; b=Oy+pSPmKGAZCUnAtZUn4wlkTRN2OPsNcni0C1nornOegVxc+cF/4MBVUpUdiWQuLtFGyxumfVqJ6CvMjQFFruvp421QNP42qT03jkb6ifMH53BY3VfSdSpds49m8j4xCqv7SBj4+ZAsTi8EbRFpLpTIV1kEBhQ1ExtZ0edGrHkw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777472069; c=relaxed/simple;
	bh=ftM5ukXQISH48XnQp4wEHNTt7YUjmI2Y/ZpTwXIbrFY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=c6E1jXsznWlnItNbb8L0BRa93AvsKn8rCQcmlrzRLMgqNsF0H9Ds+KkApxYl1CUOKkoKOEPBd0PZk3Qzb5K36DIfP/1H0AJ1nJvFqUK9jZc6lkaujt51B8NxzSLI6ef6O8IEPX0wvhqsS1lepc2KOypDmslb4hQ71FK4vmBJXTw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=bQHwYHqG; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="bQHwYHqG"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id B623121CBA;
	Wed, 29 Apr 2026 17:14:10 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=CGEZvvNmG16fhPrQ1MGOmC9UlX+Su1JVXJPJ01Yi0Ys=; b=bQHwYHqGxWAu
	XNOrd+VOeQZBLzZZ9lKg/obxf4gQOM4ZSBDHfgZwMQ88X8Nn4caFmgT173KIHNuI
	11SEerwjFeuPcUPYjBKay8dx7ItuEmDs3C4HWkiK5Wd9tqH+zjChj1W1eSzYSJfc
	eVnllTcnIBGvTCMC/VlqiLNOZYVUz1VmIOKlDa8NIKo4EkbNkDvN6ttlXNS7HBaH
	x6VLWpn5/8iDrSAPr5m48i3WINB8xukIElrjPNO/pqEVjyyDSzq7ekV5uXVtc89f
	fawlC+NuFEgDrlLSR7+RVmTP6uSPu6rqP2Gan8o6YcJYQ0gJGU8ygC5IQ+u7/gQ7
	aMqzrRkK5cLgpmrvWKsOmh7qDIaCT9eP0fgkktmk9Vo4u4p6KmGL3jZXoPkHKRPQ
	ZaqX/ZKTXA+L2CeLsXfbdHyBXNryXujdhxXtBUJqRAzVE0u7NODSWY3gp6/H+Wlk
	DPi/e7pp2+oe7ztiViKlotr7ylyQYBN+DwJ5S7IkOAmHALCrnWXkPT6p/pPvkADT
	hOmbAUhVy2tI+MSboBWiJ9c0DYjUcr84IUfhyydtKv9WKonerX3FMNcjv4KZ2L2n
	Nqu0t1eKN7JSmK9pahiQ5bm9MXpSKRkZ57VdQhDyq/VfDoB95GkFpTsoi//OBYfY
	XR9EVOX94jHU2XTXbqzBc5hrmIic8ok=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 29 Apr 2026 17:14:09 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 2F9DF6088F;
	Wed, 29 Apr 2026 17:14:09 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63TEBLdP085089;
	Wed, 29 Apr 2026 17:11:21 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 63TEBLNr085088;
	Wed, 29 Apr 2026 17:11:21 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        Waiman Long <longman@redhat.com>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org
Subject: [PATCHv2 nf 2/8] ipvs: fix races around the conn_lfactor and svc_lfactor sysctl vars
Date: Wed, 29 Apr 2026 17:10:49 +0300
Message-ID: <20260429141055.85052-3-ja@ssi.bg>
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


