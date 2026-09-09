Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5B849581234;
	Wed,  9 Sep 2026 15:55:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788969317; cv=none; b=t5enVzTvYwSnxb2szdi6VsecZUEZJomTBR5jVxwOI77lXOv3EW15YDanSAjwIKI5kbx0g6oMsoLMfssj4WuL9cVodr8k9TBC84VSpe7Gx/tTqd7TWxFTBMSblqOPvj+y/q886pXVRrlP1HnxaPdlX0Yxiu9FHr4N1G1NiKkYd54=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788969317; c=relaxed/simple;
	bh=cL0zduDZ+Uh7SypxcH47U7FhOhEzA5AXIsrQP794xwM=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=faarabQiFQN5lZ/1PRR+EpLU5BlupriuRIMD8ySUrQrXu/QtsvgfdCm4jkg5wf6RMYOMEbUP5g5C4JwEvCf0Lm+RvSeVtZSiG4gmdgq6vl4S8IFpR9uf7OPSqpJpuGSWR6aWG/HcJd7grCWoRF2PRRRZxd7hs54pc1OuII/cfPI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=AleeRk4/; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="AleeRk4/"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id A8AC322737;
	Wed, 09 Sep 2026 18:55:07 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=CJRqYoiX
	4mnD2csBwQEQCxhjzxrL6PbBq0k8ROtB8gM=; b=AleeRk4/TP7iD8rR4sJpiZeF
	6QbpkiRcPRtTth7vnoECjLwqJ/rKMEQgWT3uo4/cMb+T+6Mob7Mj1CDGAjcNbeq3
	IJVlyQswSwTc2DHFRuKZOiNiofgEUa3bRi9jPGQIZVw3b8lL/FIYl66Mz7L39nMY
	b6QmQBOBRMbHMpYvjqYDhVysxQZ6lBThvqUKi2WJt1pnQHaeeXXxqpzqzWnkjBzY
	t3SlTPUMhyB2355cK6ghoIO6j9gFtHv1Fw5gINahMXouKHD8QiCA0wK9UALYj+bZ
	kdZV5Ak18ro7Xt8QToi30VZnt8Hq13LpqYMwBQSF8V01VS8sF/wnnRIAeBk53LE6
	jZWNRpWCisIh6mH6+iiYbCe42F817C8oR9f2kjduPCOSFLsSNg0zJ5oGvYvCtUc8
	K60EBVL0DsYEqUtvu0CtWQta5UoY92NiLKUKERciloSZbMo5fGW61qow3F+X8vPa
	R7cfGQh+O3mpjkZhSt6eBi4tbQJta+N3jqWJpDJiM8yTKdwLLZe55T0QSTdRv3O+
	v/p682lJEoGyAJPerbSumO9LgdQuvkCW66Csqca8fKV3RXyV4dHy/fwMXnp1w1Nd
	AzrHOPG+dGc64342QnDgPPQgt8hYd+Op5w8qqiJka9JuXI0Yiu+IbSOOanUsfjM9
	f7on+JOFUiX2QNXAOMA=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 09 Sep 2026 18:55:07 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 2590E607B8;
	Wed,  9 Sep 2026 18:55:09 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 689Ft8ej068287;
	Wed, 9 Sep 2026 18:55:08 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 689Ft7OI068286;
	Wed, 9 Sep 2026 18:55:07 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf] ipvs: fix buffer overflow when sending sync messages
Date: Wed,  9 Sep 2026 18:55:00 +0300
Message-ID: <20260909155500.68273-1-ja@ssi.bg>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Sashiko reports for possible heap buffer overflow when
generating sync message for the v0 and v1 message formats.
We should read the cp->flags only once because another
CPU can concurrently set the SEQ_MASK between the two
reads.

Note that IPVS does not set the SEQ_MASK anymore for the
ip_vs_ftp.c helper starting from commit 7f1c40757951
("IPVS: make FTP work with full NAT support") (2.6.36+),
so the problem should not be reproducible.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Link: https://sashiko.dev/#/patchset/20260903004149.1037028-1-pablo%40netfilter.org
Link: https://sashiko.dev/#/patchset/20260909111338.44357-1-ja%40ssi.bg
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_sync.c | 23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 5383aeafb0ae..dfa8487ec0c2 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -543,13 +543,15 @@ static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
 	struct ip_vs_sync_conn_v0 *s;
 	struct ip_vs_sync_buff *buff;
 	struct ipvs_master_sync_state *ms;
-	int id;
+	u32 flags, seq_mask;
 	unsigned int len;
+	int id;
 
 	if (unlikely(cp->af != AF_INET))
 		return;
+	flags = READ_ONCE(cp->flags);
 	/* Do not sync ONE PACKET */
-	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
+	if (flags & IP_VS_CONN_F_ONE_PACKET)
 		return;
 
 	if (!ip_vs_sync_conn_needed(ipvs, cp, pkts))
@@ -564,8 +566,8 @@ static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
 	id = select_master_thread_id(ipvs, cp);
 	ms = &ipvs->ms[id];
 	buff = ms->sync_buff;
-	len = (cp->flags & IP_VS_CONN_F_SEQ_MASK) ? FULL_CONN_SIZE :
-		SIMPLE_CONN_SIZE;
+	seq_mask = flags & IP_VS_CONN_F_SEQ_MASK;
+	len = seq_mask ? FULL_CONN_SIZE : SIMPLE_CONN_SIZE;
 	if (buff) {
 		m = (struct ip_vs_sync_mesg_v0 *) buff->mesg;
 		/* Send buffer if it is for v1 */
@@ -597,9 +599,9 @@ static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
 	s->caddr = cp->caddr.ip;
 	s->vaddr = cp->vaddr.ip;
 	s->daddr = cp->daddr.ip;
-	s->flags = htons(cp->flags & ~IP_VS_CONN_F_HASHED);
+	s->flags = htons(flags & ~IP_VS_CONN_F_HASHED);
 	s->state = htons(cp->state);
-	if (cp->flags & IP_VS_CONN_F_SEQ_MASK) {
+	if (seq_mask) {
 		struct ip_vs_sync_conn_options *opt =
 			(struct ip_vs_sync_conn_options *)&s[1];
 		memcpy(opt, &cp->sync_conn_opt, sizeof(*opt));
@@ -635,6 +637,7 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
 	int id;
 	__u8 *p;
 	unsigned int len, pe_name_len, pad;
+	u32 flags, seq_mask;
 
 	/* Handle old version of the protocol */
 	if (sysctl_sync_ver(ipvs) == 0) {
@@ -647,6 +650,7 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
 sloop:
 	if (!ip_vs_sync_conn_needed(ipvs, cp, pkts))
 		goto control;
+	flags = READ_ONCE(cp->flags);
 
 	/* Sanity checks */
 	pe_name_len = 0;
@@ -674,7 +678,8 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
 #endif
 		len = sizeof(struct ip_vs_sync_v4);
 
-	if (cp->flags & IP_VS_CONN_F_SEQ_MASK)
+	seq_mask = flags & IP_VS_CONN_F_SEQ_MASK;
+	if (seq_mask)
 		len += sizeof(struct ip_vs_sync_conn_options) + 2;
 
 	if (cp->pe_data_len)
@@ -720,7 +725,7 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
 	/* Set message type  & copy members */
 	s->v4.type = (cp->af == AF_INET6 ? STYPE_F_INET6 : 0);
 	s->v4.ver_size = htons(len & SVER_MASK);	/* Version 0 */
-	s->v4.flags = htonl(cp->flags & ~IP_VS_CONN_F_HASHED);
+	s->v4.flags = htonl(flags & ~IP_VS_CONN_F_HASHED);
 	s->v4.state = htons(cp->state);
 	s->v4.protocol = cp->protocol;
 	s->v4.cport = cp->cport;
@@ -744,7 +749,7 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
 		s->v4.vaddr = cp->vaddr.ip;
 		s->v4.daddr = cp->daddr.ip;
 	}
-	if (cp->flags & IP_VS_CONN_F_SEQ_MASK) {
+	if (seq_mask) {
 		*(p++) = IPVS_OPT_SEQ_DATA;
 		*(p++) = sizeof(struct ip_vs_sync_conn_options);
 		hton_seq(&cp->in_seq, (struct ip_vs_seq *)p);
-- 
2.55.0


