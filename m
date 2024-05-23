Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A752B22334;
	Thu, 23 May 2024 16:54:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1716483291; cv=none; b=Gdg5t53hYGZrC870XLNnQ+JU0qJJZzc+zJMQQXb3SKMzY8fxXqzxJJZW3M6HzRyq6RKUIX7Y154fP/mD8g4rsKa+NaKaqpxrJXLRz/HpGhrzU7v0OA7yQjP0u3DM78wZB7paC/pjMFqpbR3ZjsbKjKlT66yN3qZ2+c/rzKiKW+g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1716483291; c=relaxed/simple;
	bh=eYRTP55zHPTx1wqIyD0CwxUVER7F1bNXTCqO7Z2cUeE=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:Content-Type; b=GCUgcKxLJ1/rX8D0QdNTmRrROvqCs/wNibo0vIvms5f3mNJAE7q9VTwwCpdBYOLRHFjUlGRSeXzBw52QnoS7f2OT1i0LQP+aLC4U++Kh8FeZC8qxE73nK6VVdOOUisZuv6Xs3Wn3Ovm0oP7E6Epio8LG0XIXoFiOqFnQLtcqBvM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de; spf=pass smtp.mailfrom=suse.de; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=lwgFh6Gu; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=Of5P/s3g; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=lwgFh6Gu; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=Of5P/s3g; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="lwgFh6Gu";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="Of5P/s3g";
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="lwgFh6Gu";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="Of5P/s3g"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 7ECC42036A;
	Thu, 23 May 2024 16:54:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1716483287; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding;
	bh=8dXeplD1JrXrU/dHr8hrBZ3Tb1p6ZC/7YwQd+1tVqb8=;
	b=lwgFh6Gubysg2jLJrdwJfqEdWiYVYdoeCQbmgSacaROl6wot0vSXiipzhGt+sADPA/moWN
	nPmF+gQeb3nF/z2pDA5sx9ksAZ84VSf8jCdv1IpRiVIsYzcD+yRa4S+Z3gZn/6XUWrGFPk
	nlJed8gFdnaU8P0xRtLyugf6wlAxCW4=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1716483287;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding;
	bh=8dXeplD1JrXrU/dHr8hrBZ3Tb1p6ZC/7YwQd+1tVqb8=;
	b=Of5P/s3g5djlbJvdQ9bIs63NtrddvumKnxoeHxqG6R0e76IfAXVDOx1JJzG6vCAXCNTmiP
	+ymvF9TG1pSyn1Bg==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1716483287; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding;
	bh=8dXeplD1JrXrU/dHr8hrBZ3Tb1p6ZC/7YwQd+1tVqb8=;
	b=lwgFh6Gubysg2jLJrdwJfqEdWiYVYdoeCQbmgSacaROl6wot0vSXiipzhGt+sADPA/moWN
	nPmF+gQeb3nF/z2pDA5sx9ksAZ84VSf8jCdv1IpRiVIsYzcD+yRa4S+Z3gZn/6XUWrGFPk
	nlJed8gFdnaU8P0xRtLyugf6wlAxCW4=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1716483287;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding;
	bh=8dXeplD1JrXrU/dHr8hrBZ3Tb1p6ZC/7YwQd+1tVqb8=;
	b=Of5P/s3g5djlbJvdQ9bIs63NtrddvumKnxoeHxqG6R0e76IfAXVDOx1JJzG6vCAXCNTmiP
	+ymvF9TG1pSyn1Bg==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 5B10313A6B;
	Thu, 23 May 2024 16:54:47 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id 9rFJE9d0T2bzeQAAD6G6ig
	(envelope-from <iluceno@suse.de>); Thu, 23 May 2024 16:54:47 +0000
From: Ismael Luceno <iluceno@suse.de>
To: linux-kernel@vger.kernel.org
Cc: Ismael Luceno <iluceno@suse.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	=?UTF-8?q?Michal=20Kube=C4=8Dek?= <mkubecek@suse.com>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org,
	coreteam@netfilter.org
Subject: [PATCH] ipvs: Avoid unnecessary calls to skb_is_gso_sctp
Date: Thu, 23 May 2024 18:54:44 +0200
Message-ID: <20240523165445.24016-1-iluceno@suse.de>
X-Mailer: git-send-email 2.44.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Spam-Flag: NO
X-Spam-Score: -3.30
X-Spam-Level: 
X-Spamd-Result: default: False [-3.30 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	MID_CONTAINS_FROM(1.00)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	ARC_NA(0.00)[];
	MIME_TRACE(0.00)[0:+];
	RCPT_COUNT_SEVEN(0.00)[10];
	RCVD_TLS_ALL(0.00)[];
	FUZZY_BLOCKED(0.00)[rspamd.com];
	TO_DN_SOME(0.00)[];
	FROM_HAS_DN(0.00)[];
	DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	FROM_EQ_ENVFROM(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	RCVD_COUNT_TWO(0.00)[2];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,netfilter.org:email,suse.de:email]

In the context of the SCTP SNAT/DNAT handler, these calls can only
return true.

Ref: e10d3ba4d434 ("ipvs: Fix checksumming on GSO of SCTP packets")
Signed-off-by: Ismael Luceno <iluceno@suse.de>
CC: Pablo Neira Ayuso <pablo@netfilter.org>
CC: Michal Kubeček <mkubecek@suse.com>
CC: Simon Horman <horms@verge.net.au>
CC: Julian Anastasov <ja@ssi.bg>
CC: lvs-devel@vger.kernel.org
CC: netfilter-devel@vger.kernel.org
CC: netdev@vger.kernel.org
CC: coreteam@netfilter.org
---
 net/netfilter/ipvs/ip_vs_proto_sctp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 1e689c714127..83e452916403 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -126,7 +126,7 @@ sctp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 	if (sctph->source != cp->vport || payload_csum ||
 	    skb->ip_summed == CHECKSUM_PARTIAL) {
 		sctph->source = cp->vport;
-		if (!skb_is_gso(skb) || !skb_is_gso_sctp(skb))
+		if (!skb_is_gso(skb))
 			sctp_nat_csum(skb, sctph, sctphoff);
 	} else {
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
@@ -175,7 +175,7 @@ sctp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 	    (skb->ip_summed == CHECKSUM_PARTIAL &&
 	     !(skb_dst(skb)->dev->features & NETIF_F_SCTP_CRC))) {
 		sctph->dest = cp->dport;
-		if (!skb_is_gso(skb) || !skb_is_gso_sctp(skb))
+		if (!skb_is_gso(skb))
 			sctp_nat_csum(skb, sctph, sctphoff);
 	} else if (skb->ip_summed != CHECKSUM_PARTIAL) {
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
-- 
2.44.0

