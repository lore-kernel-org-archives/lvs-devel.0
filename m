Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7C11925B0BE;
	Sat, 19 Sep 2026 18:09:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789841395; cv=none; b=pHr1vKbpcW4s5rrvjqwRPcsB1sCRVVFtI+ZIoUlVZeVrn1EXV+d7+JzrpNyis0kxF90dACQlzgKWKip1paGMkjlNI6U41oa9/u656/zf5Xf6GvbT6DlQSAxQ8xGd3/5IfkDNWWX+OrR05Yz/L9Mn/aaY9eTH6h2tHHzeSudETjI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789841395; c=relaxed/simple;
	bh=8V9ieGgXrC000Z+0T60dYf+aKralj853YFufcKZJZ3E=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=UzhR+VhzsPZKT4foL9s60UXqZ6HhVJT6f/KXW0DZ+PhIDg8vPbJYdhy2x6Rk3y3jI/tjTkOJCnUGONSN3Tn5znA1YvzJgC1b5lJvmdfh5/hVt3RNK30Esz/My9pGxGPZnPcEyH72Y1yy8EhDtaodeEb55Yvh10JAjSLJTgcLVgw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=ICDGL1uT; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="ICDGL1uT"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id D12CA213A5;
	Sat, 19 Sep 2026 21:09:37 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=VqbTpph1C/yIUf0JqgdI0FHIec0vHOTiJUARw/D/vmc=; b=ICDGL1uThZXh
	nE7MOYha9QbMZGN4SQ6wFuMNSNB194MOhe9u70rG+IS100XfvoCwepezdh+Eti7t
	b3r1nAlhhlgoOyHuaXp4CtuuMubwS13SqguKI1P2JvCeO/fAXSxJgzY0LYgOChPC
	m6gxBTKZTiLILPaEJckUYBp40xo2li4dOrnotwXVkYActAZLKWoF2BCzWuB66uyp
	67RtkuBIBwhLzIJ8CE6//L3kt1Arj6kYdkf4pQATLJEQeO/SdRi0LJ/kAr39pmbn
	xOu3B/Hk4OeOul/G5jWc2VfdYfXUERQa7STduvp1QChdV4Bkgm10SenlgYFZ6xms
	vw1hAvubHkeGDBKnxmF+WVUwVB+BqaV7spnS3jDW7s4UQOJWLfuaCLY/FeX4egB6
	bO5mqd0J7nM7OOlASwKG+jOS6saDv5LBSqk6G6M+Ox02Zd6T0PVxb/3BPRIYZETm
	wUUlc1BOrk7jG1YyAc61gyugrPC1EU9rXVjkqHNc3Dt5Lt4CP8rdJ1q7UJptpM8B
	0I0YTgUuE+Tq6BEk66g5dd9Gev265nTsA5zcnt38DneCiCHhF/Iy3p2uOQLAlxVh
	R5tFf3gVg2pXJ6n+76vB3fh1zaBgODteCgowI2vAsgP+VajG11mqiqs8A+sByROP
	K5W1lJ+kSCfmA1ABoT38RsGFVHRrvWU=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat, 19 Sep 2026 21:09:37 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 0587C60821;
	Sat, 19 Sep 2026 21:09:40 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68JI7kFG049525;
	Sat, 19 Sep 2026 21:07:46 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 68JI7kmO049523;
	Sat, 19 Sep 2026 21:07:46 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH v2 nf 2/2] ipvs: filter some flags received in the backup server
Date: Sat, 19 Sep 2026 21:07:33 +0300
Message-ID: <20260919180733.49501-3-ja@ssi.bg>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260919180733.49501-1-ja@ssi.bg>
References: <20260919180733.49501-1-ja@ssi.bg>
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
connections to hit template which can break in many ways.
While the master does not sync connections with NO_CPORT flag,
i.e. before they are established, we still accept NO_CPORT
without TEMPLATE.

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


