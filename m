Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A4C3253ECE4;
	Wed,  9 Sep 2026 11:14:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788952459; cv=none; b=X3Xk4+6VgujIZJroWZpYCOR+H/K0IsekiBglqr9lFMkW0Z23nrfnASOi7FYbY3nPxj8PayHdqtdzLYtUOeo00Ibd9WFi0tTPhghPh1RPBqKjOfXZ3m5+OTsk7FloZvl4/ifus9db3pgvXgHyRpvRzcm6VCf7J73PY3fWMni3hWc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788952459; c=relaxed/simple;
	bh=6AkcFA8xvJQiWJbVmV/wdENsC1jXvpnqPDdQZttbXH4=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=AGVwMrf6yuuNY6RrRmATdRYFkVEQz1FnUa68qFbXilUBEHOinETACImPEV4YoA62UaXwEu3cIGKPZgFbjwVLLvEM8KKRe7nRyb0Ss+/OtzXVmIy0M8BM0UTrg2SrxYWc4Ad6ej/mzze0rU4bYU8+fOVW75RtMpx/tPGuTTlvpVc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=aTnDa8Pi; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="aTnDa8Pi"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 723CB22737;
	Wed, 09 Sep 2026 14:14:02 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=5QruN4Vp
	ZoHQ4a2Sz35ZjBi85b7VTPQqg+tsn0HgrYc=; b=aTnDa8PiAv+dW+FgqozUP5oT
	plCMlXx1agxbxoeI41RSE3mm9QBivna8RTJ2qSnpBo8dQ6pTuc7aLk+yXFNl1bco
	GrmrdER3DJlIylNajgs3csd4yDq5zmlozid7FzbZF1DcgPSbRroNRgTNW2t2Y+y2
	XwIPrp42/crNUtAqXiDYM8oLiXXAx/gruAJfcWyFreOOxrcLJIwB1yXa/aTKRAqn
	IDCtgXoqO6kizveq8aArpixWk0QwaJd/Pr/cqwJ+DqB3a2bIx3nPBXiPQaB/fohI
	BbP69eBXupx73uyLirAh9/NameCkZY1D1F+B21FVvCVIZzc6xKj79AVa4cOZB+Rp
	/kl3EGxQKgsJBWtiHozz1FVcoR4WImGTgKBtak27GwM31GNkYQXmYn0uUZRq55J8
	vMQP20wm83wN4T6clR4GirMoiTIHVqNAIfctUdjI9uAy4DcyZboQyr3E8TlM3vng
	uu13ScvLVk6G+uUKYmWg1P8M3qh9Dgu1QFWpg+yc5JKUSKPjwXUpPWK39WOzA+z0
	w/3KtYNquGF9H4Sqi0VGIF9RES9SQkgc0imtOHkShKLtAp34n4CYFqPjNvnnLFK8
	atIYtlaAm4Oai0LtiX0DhW1CpJ4Aaf6Qjez/YF0FYg14X1pv2kAI4CwcfU/++Y+K
	xHBmk8IlWjSn5szyAYo=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 09 Sep 2026 14:14:02 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id BD65C61EF9;
	Wed,  9 Sep 2026 14:14:03 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 689BDuX1044381;
	Wed, 9 Sep 2026 14:13:56 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 689BDs3i044375;
	Wed, 9 Sep 2026 14:13:54 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf] ipvs: read the seq_mask only once on sync
Date: Wed,  9 Sep 2026 14:13:38 +0300
Message-ID: <20260909111338.44357-1-ja@ssi.bg>
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
We should read the seq_mask from cp->flags only once because
another CPU can concurrently set the mask between the two
reads. Note that IPVS does not set the seq_mask anymore
for the ip_vs_ftp.c helper starting from commit 7f1c40757951
("IPVS: make FTP work with full NAT support") (2.6.36+).

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Link: https://sashiko.dev/#/patchset/20260903004149.1037028-1-pablo%40netfilter.org
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_sync.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 5383aeafb0ae..07303d74e39f 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -543,8 +543,8 @@ static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
 	struct ip_vs_sync_conn_v0 *s;
 	struct ip_vs_sync_buff *buff;
 	struct ipvs_master_sync_state *ms;
+	unsigned int seq_mask, len;
 	int id;
-	unsigned int len;
 
 	if (unlikely(cp->af != AF_INET))
 		return;
@@ -564,8 +564,8 @@ static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
 	id = select_master_thread_id(ipvs, cp);
 	ms = &ipvs->ms[id];
 	buff = ms->sync_buff;
-	len = (cp->flags & IP_VS_CONN_F_SEQ_MASK) ? FULL_CONN_SIZE :
-		SIMPLE_CONN_SIZE;
+	seq_mask = READ_ONCE(cp->flags) & IP_VS_CONN_F_SEQ_MASK;
+	len = seq_mask ? FULL_CONN_SIZE : SIMPLE_CONN_SIZE;
 	if (buff) {
 		m = (struct ip_vs_sync_mesg_v0 *) buff->mesg;
 		/* Send buffer if it is for v1 */
@@ -599,7 +599,7 @@ static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
 	s->daddr = cp->daddr.ip;
 	s->flags = htons(cp->flags & ~IP_VS_CONN_F_HASHED);
 	s->state = htons(cp->state);
-	if (cp->flags & IP_VS_CONN_F_SEQ_MASK) {
+	if (seq_mask) {
 		struct ip_vs_sync_conn_options *opt =
 			(struct ip_vs_sync_conn_options *)&s[1];
 		memcpy(opt, &cp->sync_conn_opt, sizeof(*opt));
@@ -635,6 +635,7 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
 	int id;
 	__u8 *p;
 	unsigned int len, pe_name_len, pad;
+	unsigned int seq_mask;
 
 	/* Handle old version of the protocol */
 	if (sysctl_sync_ver(ipvs) == 0) {
@@ -674,7 +675,8 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
 #endif
 		len = sizeof(struct ip_vs_sync_v4);
 
-	if (cp->flags & IP_VS_CONN_F_SEQ_MASK)
+	seq_mask = READ_ONCE(cp->flags) & IP_VS_CONN_F_SEQ_MASK;
+	if (seq_mask)
 		len += sizeof(struct ip_vs_sync_conn_options) + 2;
 
 	if (cp->pe_data_len)
@@ -744,7 +746,7 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
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


