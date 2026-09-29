Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5551B5158A7;
	Tue, 29 Sep 2026 11:37:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790681864; cv=none; b=c/rQCeq4khCRH72g5d77XCJMiMwj/+iMQu0tdVLqFDNDFdfAcLuenM3jIu+D0L7mAfMhX1WJ8ct3W+UvUjgZIvchTtUAKTco+5Jzu7sk5jHIJJWf/bh4b9YIWB7P+CCgD0I+BFLMehyG9Z5oGco/3Wnm6ZZkbCBTqQjwBbWDJj8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790681864; c=relaxed/simple;
	bh=IAB5cfp0I2JSHgurbFPTEzXii9sHVNXb4BHRvUipkiM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=dkJv441NKXO7+IKcnDAG62k6GdoQGmBFbNiAciY1Sj3JmaeSkbF1cYycUS+fnvku3uxk9mXjeONG9cuCcL61G3H23C0691ZZUxbY42eC+++5TQIfIzkfaNTyUmMqmSnfenV+yIWB1I94Knvjueau/TjvPTXeGvrL+BTga5vfjSo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=JqNevoXa; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="JqNevoXa"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 9E796213E5;
	Tue, 29 Sep 2026 14:37:28 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=p2JJ0JPXuJv3LI7/fTOtgzYyJ76XLpFJkvFBlaQp5NA=; b=JqNevoXaOSMc
	apwrLI2zRoxeGv4z8HDMc2PpiIdQHOEJA9GoK024LBcUI81n5l62fcRDnx7iNP0o
	n5TGQX7KH56+W+HLYOscBZ8WYRaNOCAwTMcrStukNyuq2GMmzyH7Z/Gy5lgDQ0P0
	JhQKS2VZ5GZ6F4s9P7SIrJVlZ6UlR3zJ9lWfg0K5bES+A41vrav10wetuV0Kjlce
	J53oLI5zMx1mj+5g2YIQY8R1Vjf2+XPeuACxUGuFo3meVEbm5STdiTXZHBHqtdll
	eN654WuUZsh7tOMLvmejk/hTUi7+ebuGK8Oh8YqQcQplfldG2oe9VB/9PJQijjOa
	vPjWfeiYYcuBZAcU5a78hvZZJe0dMmcO68QSZeXvYDHa0iB/DnYLsbMVjrXLpSvS
	ZYS3fRAugFH+sXM6eI6lGYqGyoq133LReALgHJ3WTkfDjJElzdm7P4E5h56ym1OT
	+SLK+3DVf6E3C6GBQ4D/Z/10u/c1yPcq4K6hdwCblxPVByrvvlftImwgAxad9eQm
	dkPUToslT9NY6wm8PLa80sV4HzkPzyMOyZ3h+f0CRJAcTfEgRQYw49hOB3gKRupR
	ofcEv95YJSoYGrEB/G6SIAL822xXBqaYQUIa7al5eW92lUNtFwwYI428tmlm/UXU
	GI8IW39g2OaHoBHGLYnidQGI22kgpzQ=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 29 Sep 2026 14:37:28 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id ED831620E7;
	Tue, 29 Sep 2026 14:37:30 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68TBYt7K044335;
	Tue, 29 Sep 2026 14:34:55 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 68TBYtR6044334;
	Tue, 29 Sep 2026 14:34:55 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf v2 2/2] ipvs: fix buffer overflow when sending sync messages
Date: Tue, 29 Sep 2026 14:34:36 +0300
Message-ID: <20260929113436.44306-3-ja@ssi.bg>
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

Sashiko reports for possible heap buffer overflow when
generating sync message for the v0 and v1 message formats.
We should read the cp->flags only once because another
CPU can concurrently set the SEQ_MASK between the two
reads. If the SEQ_MASK is set, re-read the flags and the
seq mask under cp->lock atomically.

Note that IPVS does not set the SEQ_MASK anymore for the
ip_vs_ftp.c helper starting from commit 7f1c40757951
("IPVS: make FTP work with full NAT support") (2.6.36+)
but we still accept it from received sync messages
in the backup and the mask can be resent if the backup
and master roles are active together.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Link: https://sashiko.dev/#/patchset/20260903004149.1037028-1-pablo%40netfilter.org
Link: https://sashiko.dev/#/patchset/20260909111338.44357-1-ja%40ssi.bg
Link: https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260927220816.268206-1-pablo%40netfilter.org
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_sync.c | 46 ++++++++++++++++++++++++---------
 1 file changed, 34 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index f1f89240b8c5..7a9ad6d0eb61 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -539,22 +539,33 @@ static int ip_vs_sync_conn_needed(struct netns_ipvs *ipvs,
 static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
 			       int pkts)
 {
+	struct ip_vs_sync_conn_options opts;
 	struct ip_vs_sync_mesg_v0 *m;
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
 		return;
 
+	if (flags & IP_VS_CONN_F_SEQ_MASK) {
+		/* Take atomic snapshot of flags and seqs */
+		spin_lock_bh(&cp->lock);
+		flags = cp->flags;
+		memcpy(&opts, &cp->sync_conn_opt, sizeof(opts));
+		spin_unlock_bh(&cp->lock);
+	}
+
 	spin_lock_bh(&ipvs->sync_buff_lock);
 	if (!(ipvs->sync_state & IP_VS_STATE_MASTER)) {
 		spin_unlock_bh(&ipvs->sync_buff_lock);
@@ -564,8 +575,8 @@ static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
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
@@ -597,12 +608,12 @@ static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
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
-		memcpy(opt, &cp->sync_conn_opt, sizeof(*opt));
+		memcpy(opt, &opts, sizeof(*opt));
 	}
 
 	m->nr_conns++;
@@ -628,6 +639,7 @@ static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
  */
 void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
 {
+	struct ip_vs_sync_conn_options opts;
 	struct ip_vs_sync_mesg *m;
 	union ip_vs_sync_conn *s;
 	struct ip_vs_sync_buff *buff;
@@ -635,6 +647,7 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
 	int id;
 	__u8 *p;
 	unsigned int len, pe_name_len, pad;
+	u32 flags, seq_mask;
 
 	/* Handle old version of the protocol */
 	if (sysctl_sync_ver(ipvs) == 0) {
@@ -647,6 +660,14 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
 sloop:
 	if (!ip_vs_sync_conn_needed(ipvs, cp, pkts))
 		goto control;
+	flags = READ_ONCE(cp->flags);
+	if (flags & IP_VS_CONN_F_SEQ_MASK) {
+		/* Take atomic snapshot of flags and seqs */
+		spin_lock_bh(&cp->lock);
+		flags = cp->flags;
+		memcpy(&opts, &cp->sync_conn_opt, sizeof(opts));
+		spin_unlock_bh(&cp->lock);
+	}
 
 	/* Sanity checks */
 	pe_name_len = 0;
@@ -674,7 +695,8 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
 #endif
 		len = sizeof(struct ip_vs_sync_v4);
 
-	if (cp->flags & IP_VS_CONN_F_SEQ_MASK)
+	seq_mask = flags & IP_VS_CONN_F_SEQ_MASK;
+	if (seq_mask)
 		len += sizeof(struct ip_vs_sync_conn_options) + 2;
 
 	if (cp->pe_data_len)
@@ -720,7 +742,7 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
 	/* Set message type  & copy members */
 	s->v4.type = (cp->af == AF_INET6 ? STYPE_F_INET6 : 0);
 	s->v4.ver_size = htons(len & SVER_MASK);	/* Version 0 */
-	s->v4.flags = htonl(cp->flags & ~IP_VS_CONN_F_HASHED);
+	s->v4.flags = htonl(flags & ~IP_VS_CONN_F_HASHED);
 	s->v4.state = htons(cp->state);
 	s->v4.protocol = cp->protocol;
 	s->v4.cport = cp->cport;
@@ -744,12 +766,12 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
 		s->v4.vaddr = cp->vaddr.ip;
 		s->v4.daddr = cp->daddr.ip;
 	}
-	if (cp->flags & IP_VS_CONN_F_SEQ_MASK) {
+	if (seq_mask) {
 		*(p++) = IPVS_OPT_SEQ_DATA;
 		*(p++) = sizeof(struct ip_vs_sync_conn_options);
-		hton_seq(&cp->in_seq, (struct ip_vs_seq *)p);
+		hton_seq(&opts.in_seq, (struct ip_vs_seq *)p);
 		p += sizeof(struct ip_vs_seq);
-		hton_seq(&cp->out_seq, (struct ip_vs_seq *)p);
+		hton_seq(&opts.out_seq, (struct ip_vs_seq *)p);
 		p += sizeof(struct ip_vs_seq);
 	}
 	/* Handle pe data */
-- 
2.55.0


