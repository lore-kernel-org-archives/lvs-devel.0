Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B5C3735836B;
	Thu, 30 Apr 2026 07:48:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777535298; cv=none; b=rfWq4Qwh9tvlcoQpEb25aY1S6mUwmNshuBz6SYvQSZQLNbUojsvptPugYgEcHrtRciddtjzXBFTvfMnXzGoAs/s7GtgKujZBrE6IL0HJIkGn2t6LLQCu8464NfRIOvpNV4lC3b/sLjQz/IIi+FaU3N9vlU7Pfo0ICuPfTvzwU/w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777535298; c=relaxed/simple;
	bh=ftM5ukXQISH48XnQp4wEHNTt7YUjmI2Y/ZpTwXIbrFY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=IQzqsONUeC+G8+kM49ISsToLPbqY+TjOkw05ugvCE3IqJslyr/2WTf652QDj25ZMzh/nM+UrE9DFPJ6WT3L7S8ocdi6cpwPN+btv6b6O4C8V4Cpvb2SDEv5oowFv9alffyaeQhrszMCAFLR/s9C8U/k+XlCZTsxjZ0B1Ov/E5CI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=t3D3iJ6u; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="t3D3iJ6u"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 2BA1E2292F;
	Thu, 30 Apr 2026 10:47:55 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=CGEZvvNmG16fhPrQ1MGOmC9UlX+Su1JVXJPJ01Yi0Ys=; b=t3D3iJ6udtUA
	5vy67EJOsa+ZdNRbgj4x2Bcn8ia7XLH8abfFBGq9oSqX6FMiiBXXIMAawuO56NcH
	AfbGucllLY027SuyIDw69tCS1eAl55TKRC0JTCYDHnFsErcvekZgYDT6FwhAAX3K
	AdQo7FK85QDMekHZ5JUNKIB8SbOws09AUrMH1MqoiGWsyAlqp2eZ7OH2dR0u3YEz
	iB3XdAdzZ26n8+AcchmGHn300XkTLkkWp+mEvIhZytN2AfWtNiskOp4CN/sOfsRH
	yK+nuiCgg7Qu6d2L+Q07JgfTGrB3W033uv3VSp2MkYD8rZuGT2Rk6HQO5ZNi7Rzn
	3vNrfl09gEkuIg39JKeqlr2VLoky3m4GWQ37jA5FIEWTZJ5Zxq4kzY5/BpLwWmEZ
	ujbUHMv6IavrphKubjGjY2su5PyX//7E4fvhs1Nf5b6Qy3ZdjdxssECjE4WlYxSD
	Mph6q19NWBXpu7HNsD5OO/5TcGbjxOE8BM2RBudgrwUiStQCbKAf8Af+8SEnp1+w
	+ys7YKNjA5B29tTW5c2aTBV2KLQCCZpIidVdhKRNZg902acDo2ZfJqeNjVLAhOlf
	7Igg9RbYPK14hvE27SFVqTttso4JKkNz3/k+MaFiHhqsTXqNZbq12qxiC9MRWOAd
	qO9K4MQqvaGqPM/lpxWTiAr+WKYhquA=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 30 Apr 2026 10:47:53 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id BA6986296D;
	Thu, 30 Apr 2026 10:47:52 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63U7iwIp027457;
	Thu, 30 Apr 2026 10:44:58 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 63U7iwfR027456;
	Thu, 30 Apr 2026 10:44:58 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        Waiman Long <longman@redhat.com>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org
Subject: [PATCHv3 nf 2/8] ipvs: fix races around the conn_lfactor and svc_lfactor sysctl vars
Date: Thu, 30 Apr 2026 10:44:14 +0300
Message-ID: <20260430074420.26697-3-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260430074420.26697-1-ja@ssi.bg>
References: <20260430074420.26697-1-ja@ssi.bg>
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


