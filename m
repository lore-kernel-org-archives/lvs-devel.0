Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793606892;
	b=3l2VdmufL62w2ArEFjNnVv6I9ur2xvTjd2CQnIlwfvsJa5lQcIclbHKDU+1hianQE35L
	 kavFVBS/KV++1kXXiqtmcOT4Sw6mEbMo7150Hr5gW1tmhbgLznzJzn7bijXCVPNMA5dww
	 oQg1SLOJjNLKuJVIMcAta72LlTrVWg9Om5UsDB574x14hijwsiXCtwapO7aPtK0WVi6/g
	 vNO53Hx7qCI1TCEygPgMczlVhYkm3oZqa6BBgVGtXkqwzfZ2eHggFGt2mkOpLdNjJc5q7
	 2dXslY8RQd4KYLuuezMWD0eeLf1mXWFvNLl5nZ8K4PQQJyjtLAR9cFLPEYs3sj4b7xw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793606892;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:MIME-Version:Content-Transfer-Encoding;
	bh=EPhhyHfUqeA/AqJpPK7Juor0oP5kBUqRo6h5mmhp0B4=;
	b=L6n5LsO0dZTKMHJUjDLU3/xxjTPf2EGDVnDdK0Yauwp6j49mg7KWx4fV0JZS+MYesLBF
	 uNl7A8t8B6BzBaalQVeQiux8tj3aqYlMdXmmOS1vG2LefCF+MzcR1ZaH/0hausHICxoo3
	 Q06CKDJnQAv2iOsNwuojf9kseGL04SwzSfww1pMpMnxE1Aopb/1oJoETQj2ceZqCCXaEm
	 14MrRhiTqCPXBvFAR5LISiLZ9NWzT8Pr0pGXMJf0ZhpaxfRjlLNBeUj2dZsd8tXWUSly3
	 BNYDorzJ+UiIHpx6kwny0wuQrGQePLk339HMZN4O+h9WCNabOCpm4NN4PxFuKyoalBg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=UmsFVW85;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2D277606A324;
	Mon,  2 Nov 2026 08:08:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2D277606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=UmsFVW85
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id B093521F92;
	Mon, 02 Nov 2026 10:07:57 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=EPhhyHfUqeA/AqJpPK7Juor0oP5kBUqRo6h5mmhp0B4=; b=UmsFVW85bBsi
	4JzxlsC7QZ+cMBSAj3p3vqKYvbAyDSS0i83rEj6fRYP6QpIx4SZmuqiKlPHtEiKr
	9jN1YhIjfH0b8vRBN2RrW61ijZhGyUuF6GkMQvkiQi9thpXlP6Ty86eCU+WBrz/V
	2McD+SouN54oFqoFRgV2CXhZ9fmKluAuDMQ6HJ5DbEgPipvoWYHsVE4RuzLL2/r2
	ckVoVtwA27YeugSfhV34V7XHi2fu/LypA60q1SRX6fyDoNuR7wlc+Lbfhj7ibbbv
	AGDfH2fOOZxQykWA+ED8XxHMGpbeoWSB1M0fVp5M0vUxYSVg9Zd7BSC4HwxuxJx7
	bjnrdqL29G3ldFxbtFcul0n0L0pLyXjqgg2k3TBcNfBWkcl12ZduW4mOaKIi1HmN
	oLJgOpIoMDUJn2omaWRy4QyXE0P1Z8dwu9JEK/X5Rk9Tp0NUnuq7NkKOTvSN2VB9
	fiQsrnAnWiAlQodk2OikrTXjMOs8ay+kL5V9oysP6b4rdCt0lSeVMwfIqM0oHmif
	QrAPbSxQTU91Ot6dMPPoe+n5O4sDyNoCCdAc1JYWlPA/FNVMI7qzFRvk1r78c1Dm
	nrMyzoU3/C+GO2+fOzJdCgZNQMLOz9Wn3oQEiER6+igjkekNY2MCzCK/dqPSIKq6
	kNlxV4QGFesWY+UW6U2z8OylCsvcsPI=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 02 Nov 2026 10:07:57 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 0A08360BAF;
	Mon,  2 Nov 2026 10:07:57 +0200 (EET)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6A287fSw022203;
	Mon, 2 Nov 2026 10:07:41 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 6A287fCW022202;
	Mon, 2 Nov 2026 10:07:41 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf v3 2/2] ipvs: read flags and seqs in master atomically
Date: Mon,  2 Nov 2026 10:07:28 +0200
Message-ID: <20261102080728.22178-3-ja@ssi.bg>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261102080728.22178-1-ja@ssi.bg>
References: <20261102080728.22178-1-ja@ssi.bg>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

After we fixed the double read of cp->flags in the master with
commit 3e3fe49e8678 ("ipvs: fix buffer overflow when sending sync messages")
Sashiko reports that we should also read the cp->flags and the seqs
atomically. So if the SEQ_MASK is set, re-read the flags and the
seqs under cp->lock to provide a snapshot when sending the sync
message.

Fixes: 3e3fe49e8678 ("ipvs: fix buffer overflow when sending sync messages")
Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Link: https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260927220816.268206-1-pablo%40netfilter.org
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_sync.c | 23 ++++++++++++++++++++---
 1 file changed, 20 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 39b9bd83bc5c..33179852faf6 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -539,6 +539,7 @@ static int ip_vs_sync_conn_needed(struct netns_ipvs *ipvs,
 static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
 			       int pkts)
 {
+	struct ip_vs_sync_conn_options opts;
 	struct ip_vs_sync_mesg_v0 *m;
 	struct ip_vs_sync_conn_v0 *s;
 	struct ip_vs_sync_buff *buff;
@@ -557,6 +558,14 @@ static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
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
@@ -604,7 +613,7 @@ static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
 	if (seq_mask) {
 		struct ip_vs_sync_conn_options *opt =
 			(struct ip_vs_sync_conn_options *)&s[1];
-		memcpy(opt, &cp->sync_conn_opt, sizeof(*opt));
+		memcpy(opt, &opts, sizeof(*opt));
 	}
 
 	m->nr_conns++;
@@ -630,6 +639,7 @@ static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
  */
 void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
 {
+	struct ip_vs_sync_conn_options opts;
 	struct ip_vs_sync_mesg *m;
 	union ip_vs_sync_conn *s;
 	struct ip_vs_sync_buff *buff;
@@ -651,6 +661,13 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
 	if (!ip_vs_sync_conn_needed(ipvs, cp, pkts))
 		goto control;
 	flags = READ_ONCE(cp->flags);
+	if (flags & IP_VS_CONN_F_SEQ_MASK) {
+		/* Take atomic snapshot of flags and seqs */
+		spin_lock_bh(&cp->lock);
+		flags = cp->flags;
+		memcpy(&opts, &cp->sync_conn_opt, sizeof(opts));
+		spin_unlock_bh(&cp->lock);
+	}
 
 	/* Sanity checks */
 	pe_name_len = 0;
@@ -752,9 +769,9 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
 	if (seq_mask) {
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
2.56.0


