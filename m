Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.222.172
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793725159;
	b=COQBvPPqdlu98M1Lx6YWhKhlaYu0Kv2KBVV0EW2D2UT3ij18R2io1Q22IttX5WhWkQoA
	 RbGkqu2vqZAlXkQz9OBOtT1MzOhPIbsUJoVOrIeAJLexRUx2HrNvMe0wi6cCXQifN8F9b
	 80ka9PKNzldFyhewtM8UIFoz/vLuDgS5dxPIaA1eVPBD5fhjNiweEyQNwSxv5VdnQp+Dn
	 rpO3yUmKRfd4j8vb3ErRqEOmX2RdSJPU/K0LJZO4L7prCtPPOXtZ8C8eUWFAlI9gYieat
	 2TebwPtOtJzXMnCdIs0/tx4lwgRZWzZH8hw6AMg3ZtGNQ18I3KsryFyK3rZRAkBFfBA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793725159;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=qyie3lp94voMetIz4ZK0UyMQldPElbkTK8vbvrxDQEs=;
	b=HawY06xItfoe29j2KVP6BxlTnDOERJ4Ep+IpfVtOiKM9aKKGu/yyKp7SQo3o6y1u1y+H
	 Fn+qRR8vEDHCcZeOL/8fF53wGq1WcbVdiQ6pOj32EX2sKkIbsT1rwL9b/Jvq19L4pWqrQ
	 Nx92pTsS+0n/FHrvw0lyZxckEi4Zxzl91hDAWpY95U1LvDKBQnhiz0piYiYc+5rY1LODk
	 LNYLT1tisNBLWM/ikRPT8Vk4LYOsGf2/Bx25jAjbmd6oWbN/h8iSY031amWnWg/8eneQz
	 W0Nz0DMFU9wqw7bzFt7mWWE10e/mfd4bDfVw2M7F1WywBgYZbKkadLdOmePmFYzp8RA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=1password.com;
	spf=pass smtp.mailfrom=agilebits.com;
	dkim=pass header.d=1password.com header.i=@1password.com header.a=rsa-sha256 header.s=google header.b=e2u4H5ji;
	arc=none smtp.remote-ip=209.85.222.172
Received: from mail-qk1-f172.google.com (mail-qk1-f172.google.com [209.85.222.172])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BD07B606A32D
	for <lvs-devel@vger.kernel.org>; Tue,  3 Nov 2026 16:59:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org BD07B606A32D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=1password.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=agilebits.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=1password.com header.i=@1password.com header.a=rsa-sha256 header.s=google header.b=e2u4H5ji
Received: by mail-qk1-f172.google.com with SMTP id af79cd13be357-9440304604aso97898285a.0
        for <lvs-devel@vger.kernel.org>; Tue, 03 Nov 2026 08:59:18 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1password.com; s=google; t=1793725158; x=1794329958; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=qyie3lp94voMetIz4ZK0UyMQldPElbkTK8vbvrxDQEs=;
        b=e2u4H5jiGKGo9r6gEd2se4tGTZwmdU5p9nRdnHtOCSYXWlvFZj83tcGAwxxRpJ9zAV
         Mro8wC0WTq2rpRb1Ji8FduryNwdXihHaxmOaRYFBF1Tw8cmDMDaeaikwpbhBcj0Ovq4t
         1zp7PeTOuJVNUfTKrkm+Y2EsfuDAtAvurwlTY=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793725158; x=1794329958;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=qyie3lp94voMetIz4ZK0UyMQldPElbkTK8vbvrxDQEs=;
        b=VeL1itA8i1eKiPZr2aA+WFvJxLllL6me2+UkzbsN/jJCdjtfkWZFf+fR2NVfg4Xdzb
         ZTugGbBfWtqcsaW8Sh9cLQpkcOcWcEQTcrRlA1uiGjEjmfo2rEu5L5HzDLDUiiydesUo
         QdCq6m2CX5pyGMsxDqoXO5u3rNmRlKrqiGYZbtbtxWRskkHgRCV2866Iz8jazoBKxpm5
         tzz2S+zo0bTikpBtqHvq5eNRFeoWFWAkf40pKYJESLf/3Ie8hIzo/Bw003NDhE9SDugS
         RSolVCXZ2DUuM4Y7khzbrVd/w7DHub0v5ZvzV+Mb/Z79Wf/1cwsIM9Cc3LeihR4uRuOV
         IyvQ==
X-Forwarded-Encrypted: i=1; AKwUvBxzSE1Fgiv2Mc3Df4MkEEPXWUwdTGRyxugP/hYf3zkiyCLI+mfxH+jnuPjedYzG/qxf1073a+bT+G4=@vger.kernel.org
X-Gm-Message-State: APuU4Z/ueBmnq/4hPxTciK6SN6J65gYxGJeTjvrzRVnWUY5fXMwqaC7s
	FtAokRLnQ4vBeFN9aOIgqlaEVK1JnwP0jX8fHjf10Vg69es6MAmvTi/qMDas4OSTkJEi8Mdf2dP
	wqLkRAiU=
X-Gm-Gg: AYBFou2CRb2cYsvbzBxw1EQlSAU2PEdEVXT89lZ7JawS32GRkvHB0gZpaAcAB1RUxL0
	rVv4ZSLLHBBQ5qVjN+237m0LE37WrAuXAQ45ePfrkZ3sGM4nqPzI49fIAWVee2pjAgEaCBp16Jd
	rwK7eGB6BILe2z6DBfAhsjWLvLrVgnCOPjaounzMHO4lPSVmT7zBI0Nc3FMb2Ak+rdw5MVCEOZx
	uhX5xZFKkq+5ChHoDfkpeRonoguuGD24P/NSeGH1BF/LWh9efXbxolEELSBf3ZPBbebPq1RPl3m
	YFKI2d+VZLmP74cPW6/n8/VQ9AEGlPpbN6g5I6YxOaWRFQr3e5UcvmsiRzYfP2CoGlrAfA3j9bF
	dG1l2dyeGk5Z2qlqWfjr97201UqC6BmJHyTgdOFGVf6o1yIYaNhjWXEdq7x7xVX8zoKDx4idCKQ
	XjdMx8QaCXFMkKHNe7sujCDqMU5kwqn7X8RtAUdsCQxAoS3g+tsI0qCIq0SIuw8hem+Nx1nuQ04
	RRy3E5ZGSIjskU04vpxwkTCJ7ioFO4EWBTqOKtK3N3/dVWmEvNankFf8JziK/0p9O6zOUz0WLNB
	x7g4Kcilj0JRb7+edqZmS4SjYKawg4grEabN0psUu6eadOMpuxA4U/E+WpdEBd1Fw97PwU7J/RG
	NjBPXGg==
X-Received: by 2002:a05:620a:4613:b0:93f:1789:8359 with SMTP id af79cd13be357-944133bf945mr2719600885a.31.1793725157802;
        Tue, 03 Nov 2026 08:59:17 -0800 (PST)
Received: from localhost ([2600:4041:59c3:300:a850:2af1:eb93:4121])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-945d3410ae4sm5514285a.26.2026.11.03.08.59.17
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 03 Nov 2026 08:59:17 -0800 (PST)
From: Axel Mierczuk <axel.mierczuk@1password.com>
To: ja@ssi.bg,
	horms@verge.net.au,
	pablo@netfilter.org
Cc: fw@strlen.de,
	phil@nwl.cc,
	netfilter-devel@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	coreteam@netfilter.org,
	netdev@vger.kernel.org,
	w@1wt.eu,
	Axel Mierczuk <axel.mierczuk@1password.com>,
	stable@vger.kernel.org
Subject: [PATCH nf v2 1/2] ipvs: validate cport in received sync records
Date: Tue,  3 Nov 2026 11:57:45 -0500
Message-ID: <20261103165746.39516-2-axel.mierczuk@1password.com>
X-Mailer: git-send-email 2.50.1
In-Reply-To: <20261103165746.39516-1-axel.mierczuk@1password.com>
References: <20261103165746.39516-1-axel.mierczuk@1password.com>
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

Local templates have cport 0 and IP_VS_CONN_F_NO_CPORT clear, so
ip_vs_conn_in_get() cannot match them. A template received over the
unauthenticated sync protocol with a nonzero cport can reach the
protocol state machine. Before template state validation, this
could cause out-of-bounds reads, crashes and kernel data leaks.

Ordinary records with cport 0 and IP_VS_CONN_F_NO_CPORT clear, or
with a nonzero cport and IP_VS_CONN_F_NO_CPORT set, create connections
that incoming lookups cannot match. The latter also keeps the
cport-zero fallback in ip_vs_conn_in_get() enabled.

Reject all three cases. Continue accepting ordinary connections
with cport 0 and IP_VS_CONN_F_NO_CPORT. The companion patch
"ipvs: filter some flags received in the backup server" rejects
template records carrying IP_VS_CONN_F_NO_CPORT.

Fixes: 87375ab47cd0 ("[IPVS]: ip_vs_ftp breaks connections using persistence")
Cc: stable@vger.kernel.org
Suggested-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Axel Mierczuk <axel.mierczuk@1password.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_sync.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 157f5c8361ab..a85dc95e29cc 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -853,6 +853,25 @@ static void ip_vs_proc_conn(struct netns_ipvs *ipvs, struct ip_vs_conn_param *pa
 	struct ip_vs_dest *dest;
 	struct ip_vs_conn *cp;
 
+	/* Templates require cport 0. Ordinary connections require
+	 * NO_CPORT exactly when cport is 0.
+	 */
+	if (flags & IP_VS_CONN_F_TEMPLATE) {
+		if (param->cport) {
+			IP_VS_DBG(2, "BACKUP, template with cport dropped\n");
+			kfree(param->pe_data);
+			return;
+		}
+	} else if (!param->cport && !(flags & IP_VS_CONN_F_NO_CPORT)) {
+		IP_VS_DBG(2, "BACKUP, conn without cport dropped\n");
+		kfree(param->pe_data);
+		return;
+	} else if (param->cport && (flags & IP_VS_CONN_F_NO_CPORT)) {
+		IP_VS_DBG(2, "BACKUP, conn with cport and NO_CPORT dropped\n");
+		kfree(param->pe_data);
+		return;
+	}
+
 	if (!(flags & IP_VS_CONN_F_TEMPLATE)) {
 		cp = ip_vs_conn_in_get(param);
 		if (cp && ((cp->dport != dport) ||
-- 
2.50.1 (Apple Git-155)

