Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C17F035CB81;
	Tue, 29 Sep 2026 11:35:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790681711; cv=none; b=ULGc9YKKwIf7EvBgydtdKUgdI5lhsd26k6fM3eyBZkk+nonnk5qDDhSmV9ljesPKgW2PEwbZ4K7Apaxx0onSTfIfz7VSPMC245JbVYFdbMfFiRIv8x9Glc+4YEzGOrThf39247O1s9J3JTB9aBsHNV1qdWtAYrpeAd+ouGHQ6uk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790681711; c=relaxed/simple;
	bh=FSZg7VcF4YIGq9yldmSgD28pDxS0QWAYSC2mhwh3k2U=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=GaamL48J9Tv2bXjvV0ucxKMCqEBkBhGQTXtls/S4slLQPpBagmKQo27mJPJ3GEVtV67nOUDr1clpuWBOEJAm4V4cIUDrLjiYl3NH61vhR3+m3iKCxn+eUc9qjtQNN5zTI2Wn7OeOz3F32CGT1WvVPephyk+pStErZUWBz6SjxT8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=ttORj8rB; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="ttORj8rB"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 9659F21ABA;
	Tue, 29 Sep 2026 14:34:54 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=IewI9+W8avs8QfTuNMv9P5sMAn8/oLezzXD5glGc4A4=; b=ttORj8rBZfKb
	nGs7YP694EOUQcqvPZZ4Kge3NUbv2Bn6ZuaRJGOjSVzD+uQCpRnDUVAXtZV8J9n5
	UMB5jHppouyBI082NJxSKqt3NLIVu413tQdO0esY7iN3xazwpYF6026PkqNMR7Du
	9/ddmL88XjNKUfW+CBhPrPOzcmmSgWDt1u4+CGBe7ffHOGKctpDZUQ/UXjh2hoQ3
	2Nw4jT7NmUsSP2aJIQ9ignpGu+8lq7ogTLu9qrgezfPeQ9Ck90jnVsC0TFUelGsP
	4oLZtG5SslmNu608nW864sORP9qIyOg51z4pzEzsTFakJmNS69/awI6AcWU819I0
	qfBu82Mw45RCsR5wf2DV+rSJnA4c5FnrW3JlvO+ptaBX7o8Zq+McT3dZDnUnWpOT
	H1RJhqeMAkH4+e+aby1cxQHj1EvfQ1AX3cItf4ST5Em1KKulxZ3QW3nbWYzlgijd
	GxURjMDRHdNch5LXUN//8ToKuiEAuq1yuftKvdoByKeAUgT/nKUUwqgC8gQ56nRk
	TqjCOLYqUp+XfqqJSUMKzNHa7h4q75gXCHjee738fT6rgxeSU/NaxhrZkRrUVyQg
	dHpvHHIsb/2EwpSco0HI3UGzzHTD5UADfP00SttNYHk1pKVtTz34iIFsApnY+dgc
	gT7pXp+QoIpJvcCX0l50q62rw1D0DtQ=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 29 Sep 2026 14:34:54 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id D27D4609F6;
	Tue, 29 Sep 2026 14:34:56 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68TBYtI5044331;
	Tue, 29 Sep 2026 14:34:55 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 68TBYtPR044329;
	Tue, 29 Sep 2026 14:34:55 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf v2 1/2] ipvs: update flags and seqs in backup server under lock
Date: Tue, 29 Sep 2026 14:34:35 +0300
Message-ID: <20260929113436.44306-2-ja@ssi.bg>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260929113436.44306-1-ja@ssi.bg>
References: <20260929113436.44306-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Sashiko reports that we modify the conn flags and seq values in
the backup server without holding cp->lock. The same is true for
other fields such as state, old_state and timeout which are
modified by protocols under lock.

Extend the locked region in ip_vs_proc_conn() to update the
fields atomically.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Link: https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260927220816.268206-1-pablo%40netfilter.org
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_sync.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 5383aeafb0ae..f1f89240b8c5 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -845,6 +845,7 @@ static void ip_vs_proc_conn(struct netns_ipvs *ipvs, struct ip_vs_conn_param *pa
 			    unsigned long timeout, __u32 fwmark,
 			    struct ip_vs_sync_conn_options *opt)
 {
+	struct ip_vs_conn *cp_new = NULL;
 	struct ip_vs_dest *dest;
 	struct ip_vs_conn *cp;
 
@@ -886,9 +887,6 @@ static void ip_vs_proc_conn(struct netns_ipvs *ipvs, struct ip_vs_conn_param *pa
 		flags &= IP_VS_CONN_F_BACKUP_UPD_MASK;
 		flags |= cp->flags & ~IP_VS_CONN_F_BACKUP_UPD_MASK;
 		cp->flags = flags;
-		spin_unlock_bh(&cp->lock);
-		if (!dest)
-			ip_vs_try_bind_dest(cp);
 	} else {
 		/*
 		 * Find the appropriate destination for the connection.
@@ -915,6 +913,8 @@ static void ip_vs_proc_conn(struct netns_ipvs *ipvs, struct ip_vs_conn_param *pa
 		}
 		if (!(flags & IP_VS_CONN_F_TEMPLATE))
 			kfree(param->pe_data);
+		cp_new = cp;
+		spin_lock_bh(&cp->lock);
 	}
 
 	if (opt) {
@@ -946,6 +946,9 @@ static void ip_vs_proc_conn(struct netns_ipvs *ipvs, struct ip_vs_conn_param *pa
 		else
 			cp->timeout = (3*60*HZ);
 	}
+	spin_unlock_bh(&cp->lock);
+	if (!dest && !cp_new)
+		ip_vs_try_bind_dest(cp);
 	ip_vs_conn_put(cp);
 }
 
-- 
2.55.0


