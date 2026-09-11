Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F1D094BB286;
	Fri, 11 Sep 2026 18:35:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789151713; cv=none; b=cYbPQxPlSpa3EjyqlgSEpB8Bvk8Xk/Frq+Uiq1YLcZC6j9I5slgadZdJwKFqVo4VjKEQTVbvYUTe2wUJB8U8bLe+2b6SDTJnt9rJgVJlZSaldHPUffa2GlneHrC5xGlqOzagildPSZHVoACK2JXtM2+trWvhUnaEH+2FGLy2Hc8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789151713; c=relaxed/simple;
	bh=j0HSsYmgt2/44/bdjWEMXVRVeo/KHZOQP+3jyumGF20=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=hxMNQzDN4zoDBHbI8rhOTxwjQWbvqZUm9MN3bfRvUzRxVacWQHHI8g0NMH4T5K2aWvx/vzDQODe5nxPvfC249xyLmuMPeC/+B+BWh7Vmn4JILHfnCQCubzg7gI5CB+yABBdRxsWEFWkH52d9eGrEqoG4IbLAQGPb3SCNk7TLsIQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=5eM0Slaj; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="5eM0Slaj"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 832C92273F;
	Fri, 11 Sep 2026 21:34:53 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=vglOpQ4Z
	fvJMYsB362bRvZqbl5+CVLjJdtE0pY8zIh8=; b=5eM0SlajpIIvQ3y/Aza7yfm3
	0D/nwgaVp2OQtLmz3GAY1gfidTKpgDGkN/zdoCYupt7VdgMoCCcRAf8g7b9WhPL1
	owkrzv2NElZEUPsEEjPNb2bmo9wSVPhmZf7WUjn+6Lc8gyx19SCF+tElA9AkaLN+
	HxWGHazKXqXUEZAmLosX2niaUbPVGO6dDe5TBz3OCLKmPr6N3CQ1W7GqO64CWCjZ
	V12DbqZ1tuDsVlPFRyqq9Ah1gj7k1xPyJ6EBdt71ra4CI/F5ba0nBcq/o7yK+lZB
	jvvEaul8+IFt1/MNfiewNpDVf0Jiq66NQ8DAIahSE1TqLPJK5nBLysN2O0SS3HJm
	bk23iCP2Gh+O5mSYiMxFBBoES3Q3sbTd3CU0GyQDCWvmoj5pvmrcxOFkdcyVn4HA
	5xOWFVT9WxrJlFID7YAocPF1lZDddZ05OJqBm6ky3BhdJ/Gp9pWF8UjoIZOI/4gq
	mza9z4ophs2pxTq6IC+WbxiUtE9bcRobcceky0tm78bYniGUkLHUCxJ7va6lxmbi
	0wkHmM1912t/X8OGBvzmLZ6ilmdXBo4vf8egtClbUw206NC1duAmtj74aC1BsDcl
	j0zhn1iTGG4bsFIJktFmWfdAsSmTQsIPa9L4friIp8G6Ph25eE3yiVPfkWAajSQz
	NQ1h/hZw4u+8OUnSuQ8=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri, 11 Sep 2026 21:34:53 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 1A38360888;
	Fri, 11 Sep 2026 21:34:55 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68BIYmXD071228;
	Fri, 11 Sep 2026 21:34:48 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 68BIYjOP071226;
	Fri, 11 Sep 2026 21:34:45 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf] ipvs: filter some flags received in the backup server
Date: Fri, 11 Sep 2026 21:34:29 +0300
Message-ID: <20260911183429.71212-1-ja@ssi.bg>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

While the IPVS SYNC protocol is not secure by design
we can still protect the backup server from messages that
can wreak havoc.

This commit addresses problems from received connection flags
or their combinations. We now drop messages as follows:

1. the NO_CPORT+TEMPLATE combination allows lookups for normal
connections to hit template which can break in many ways

2. ONE_PACKET: it is not sent by master, so we do not
expect it in backup. Before now it was ignored by
IP_VS_CONN_F_BACKUP_MASK for protocol v1 while protocol
v0 created connections that are not hashed and dropped
immediately. Better to apply the IP_VS_CONN_F_BACKUP_MASK
also to the flags from v0 messages for consistency with v1.

Fixes: 87375ab47cd0 ("[IPVS]: ip_vs_ftp breaks connections using persistence")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_sync.c | 33 ++++++++++++++++++++++++++++++---
 1 file changed, 30 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index dfa8487ec0c2..1a30817fbbaf 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -954,6 +954,21 @@ static void ip_vs_proc_conn(struct netns_ipvs *ipvs, struct ip_vs_conn_param *pa
 	ip_vs_conn_put(cp);
 }
 
+/* Check for incompatible flags */
+static bool ip_vs_sync_validate_flags(u32 flags)
+{
+	/* We do not expect NO_CPORT, especially to allow lookups
+	 * to hit templates
+	 */
+	if (flags & IP_VS_CONN_F_NO_CPORT) {
+		if (flags & IP_VS_CONN_F_TEMPLATE)
+			return false;
+	}
+	if (flags & IP_VS_CONN_F_ONE_PACKET)
+		return false;
+	return true;
+}
+
 /*
  *  Process received multicast message for Version 0
  */
@@ -977,8 +992,7 @@ static void ip_vs_process_message_v0(struct netns_ipvs *ipvs, const char *buffer
 			return;
 		}
 		s = (struct ip_vs_sync_conn_v0 *) p;
-		flags = ntohs(s->flags) | IP_VS_CONN_F_SYNC;
-		flags &= ~IP_VS_CONN_F_HASHED;
+		flags = ntohs(s->flags);
 		if (flags & IP_VS_CONN_F_SEQ_MASK) {
 			opt = (struct ip_vs_sync_conn_options *)&s[1];
 			p += FULL_CONN_SIZE;
@@ -991,6 +1005,13 @@ static void ip_vs_process_message_v0(struct netns_ipvs *ipvs, const char *buffer
 			p += SIMPLE_CONN_SIZE;
 		}
 
+		if (!ip_vs_sync_validate_flags(flags)) {
+			IP_VS_DBG(2, "BACKUP v0, Invalid flags 0x%X\n", flags);
+			continue;
+		}
+		flags &= IP_VS_CONN_F_BACKUP_MASK;
+		flags |= IP_VS_CONN_F_SYNC;
+
 		state = ntohs(s->state);
 		if (!(flags & IP_VS_CONN_F_TEMPLATE)) {
 			pp = ip_vs_proto_get(s->protocol);
@@ -1146,7 +1167,13 @@ static inline int ip_vs_proc_sync_conn(struct netns_ipvs *ipvs, __u8 *p, __u8 *m
 	}
 
 	/* Get flags and Mask off unsupported */
-	flags  = ntohl(s->v4.flags) & IP_VS_CONN_F_BACKUP_MASK;
+	flags = ntohl(s->v4.flags);
+	if (!ip_vs_sync_validate_flags(flags)) {
+		IP_VS_DBG(3, "BACKUP, Invalid flags 0x%X\n", flags);
+		retc = 25;
+		goto out;
+	}
+	flags &= IP_VS_CONN_F_BACKUP_MASK;
 	flags |= IP_VS_CONN_F_SYNC;
 	state = ntohs(s->v4.state);
 
-- 
2.55.0


