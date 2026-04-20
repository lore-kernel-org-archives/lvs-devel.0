Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 000A737996B;
	Mon, 20 Apr 2026 16:59:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776704351; cv=none; b=X88vcaeaF4JbbFCyzVN/4tju23JWptWvuRAN/OUO/Ezq2dDNTVDNrxpNxQWaccRojAUGNqMTS9gy5vlsHgwkzjvnjrjqMxQUXZEsw49MxbcCO4NSUnh1jMvBjYGIaJrGutXd4iJJUL3W70FsayiY5yxeyOtkLWDKFziztD5epgQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776704351; c=relaxed/simple;
	bh=QqMJ8APZXAv/jThgzkl48ZDqf4rg3RNwu38GuypsDSw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=lzJ8vtTuHmLdN1sAs8rq1RZKBigfBbi2z5boqGWfOEANjLcS9aOCL/J98rekqqw0FavQtIviZgpiGRYqEpycNsJumH3PHEI9aUsGta8rZlqRLKCe0a1Y+WZ8rpMtezNM6LTnBOJZL/l1QrrCC9YhBfG6/hknPHoeNtVLXqo0yyU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=DOcYey31; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="DOcYey31"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 52FD621108;
	Mon, 20 Apr 2026 19:59:06 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=HWSPzETrY78Q6YnxMY7oGENlOhhIgC8vQ9vEXd3xBuI=; b=DOcYey31egKm
	Fo2I/xj2N5U3ACSTdvp5kT9x91rRfmnzfCYOItg1TNqK6iVhZwtgVlDp1ao3Uh3C
	zmHuK3Hn39ncGpUOBrH81/yXONENnW0LGdsN6/whBIsYruI8x1wP9qB5xE2JlcQR
	q0tUyZU7AUGLqFDW+ck0iGvd/96QB2KVDFc6bBBw659BeRGVVVlnxy5g3x76vsoS
	1IyfUGVSfnUq0KqfqMWPFldCeMj+7PqBEUuDcBE/CDDHfjhpKUFxWzmXeABM1PHR
	r5YdQeSIndOTsgvgi/4P3MGIEbpP52i9arxuKJb163Ajv9gUbxBWuMXLBrNUYX7+
	SRZhxu9BMQFASHRZXxdu3VfovIoiaeKiT2I3Zc4LQI0i/UvgTSWC44EVypq39XVA
	EfUsBrvAvXYyWAmUbeuPqYzvVZ3oovmGuZ18YzmPoZNJCExW4k++9gUFKySmonhP
	rRR3HyThsQ256H8GBq8SCsDkS6UfXb0mZaQk1bG49wvb38VUbSIeDsrbKVTbj+vI
	z+dZcReURq4rFLQ8dLeaODzSZyMqM22nxdukKPteBll4i/tnIDTC2ol6tsAOmfWb
	4i9+q94QyO/FfnEME1oyz7To8xKL0HDDKCXLgbUYG6HR4b7nfnYO7iD0ejHXxOr0
	7P6snHGGJSNTtXVGYIgP4AmlmPltv2w=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 20 Apr 2026 19:59:05 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id E3CF6601B7;
	Mon, 20 Apr 2026 19:59:04 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63KGu4hv085560;
	Mon, 20 Apr 2026 19:56:04 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 63KGu4RX085559;
	Mon, 20 Apr 2026 19:56:04 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCHv2 net 2/3] ipvs: fix races around the conn_lfactor and svc_lfactor sysctl vars
Date: Mon, 20 Apr 2026 19:55:38 +0300
Message-ID: <20260420165539.85174-3-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260420165539.85174-1-ja@ssi.bg>
References: <20260420165539.85174-1-ja@ssi.bg>
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


