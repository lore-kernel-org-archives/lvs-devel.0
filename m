Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 222683812F4;
	Sat, 19 Sep 2026 18:09:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789841387; cv=none; b=PpjczylXDwgEXaQ1SXCggRePgJCR36q/hFNKX7/moeNrPwuAqEywdCmAiUdaYbgqzyQQZN8BDo1QU/e0HmAe0wX2KnPLWITuTxeu8U6DNciwJJdzqkhh/WwWE/l8WLyUZo4tXbyULAR8gDMc7XexgMHSyapwr5jSXcJMrxKqqFY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789841387; c=relaxed/simple;
	bh=HsbCpU838iwlGHlKJqCixBPlgVCO6JKV8BIJba2By/M=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=VWcaAcskdnbNGQuOVO9a0lxlUM26dP8qeMrIhIJBRu/c/otCK1AyUP842r3j3G4fjaK8u/+TnF6PtSimfQgfvS6M8ciaYQwq7clcmRoopjtKfoGSRqr4xoklGXsL8hUEKgWUtSuYhgM8pVkGevePHaTj77Hmenv+/njIGVp62Ds=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=ReN63SzP; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="ReN63SzP"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id B0F71213AA;
	Sat, 19 Sep 2026 21:09:37 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=43h158kMOxzT6RvJPQNofobsFVb80/Ql+uUnzfCLYS0=; b=ReN63SzPNm3c
	GS+UvKJsr4b4VZl8Bd8I2PPT5g9s6kzaqauvn6QzmJ9QOTpa8Rm6d2dYMSEdy4Pn
	Esd9Ksml1qudgKLiaajTE1AiS9rI6C5WWZZZRa9v7k0j+G8aTT/FJCWJsacjUjxg
	MInkYTOiQtojB42XBeeoqKHw/ipLTY1AQeR0NX3aeKDmWITkTy79JLP04FNIb9Y6
	sedelh0vu5JQVy3l7+EYpOv/z0MYJivMnD7QDlP3Ld9X1+M7+YrnpRPgk5Cn1ehT
	b7LjJ1KScJnNQCM13aV4Y/9wQfqXT/yLewprJqDvWGRtuGJcSwGcSzHAhonHVMq2
	jfe8bjhrU3ZPcxdyIv6xbzL+T1r85l7yKx5heLkwQm6WmLtvX5qKuUWZj5LT9S4l
	QWW3Pd1pE5+tsNzOEJadu9GaorJ0SbNoUOcpV6c8XZn6yx+GeAO391RtwyhZg0oj
	cZKi31a+s55QZcYPfynTW5GhlMle7iSvmwlqlWKLinLYwGaBZq128Z2NMBMlS1Mq
	k9Gcem2KNwSbg078pbaf5TGakJP3f0Uo9Qj9ndudW3n6Os3AFRVyP4oMLkY2LBUc
	NmbrqZ/hKmLnamc8pyXvc59I/yBpSuAuxbq+MiDR4WCL0LEL2TTfIOj7cR1J+/8z
	5A/l/4fnggGU9m2iYgzwvOCZOHODIYg=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat, 19 Sep 2026 21:09:37 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id D777160627;
	Sat, 19 Sep 2026 21:09:39 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68JI7ksA049520;
	Sat, 19 Sep 2026 21:07:46 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 68JI7kTj049519;
	Sat, 19 Sep 2026 21:07:46 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH v2 nf 1/2] ipvs: do not create invisible templates
Date: Sat, 19 Sep 2026 21:07:32 +0300
Message-ID: <20260919180733.49501-2-ja@ssi.bg>
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

The IP_VS_CONN_F_ONE_PACKET flag was implemented for normal
connections. When conn template inherits this flag from
dest->conn_flags it will not be hashed. As result, we will
create new template for every new normal connection.

Fix it to allow one template to be used by many normal
connections.

Fixes: 26ec037f9841 ("IPVS: one-packet scheduling")
Link: https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260916231652.127456-1-pablo%40netfilter.org
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_conn.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index ce0883f259cb..85fd2e5dde56 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1102,6 +1102,9 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 	if (cp->protocol != IPPROTO_UDP)
 		conn_flags &= ~IP_VS_CONN_F_ONE_PACKET;
 	flags = cp->flags;
+	/* Only visible templates can control multiple connections */
+	if (flags & IP_VS_CONN_F_TEMPLATE)
+		conn_flags &= ~IP_VS_CONN_F_ONE_PACKET;
 	/* Bind with the destination and its corresponding transmitter */
 	if (flags & IP_VS_CONN_F_SYNC) {
 		/* Synced conns are hashed, so they can not get this flag */
-- 
2.55.0


