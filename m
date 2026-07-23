Received: from mail-pj1-f47.google.com (mail-pj1-f47.google.com [209.85.216.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AE0843C0604
	for <lvs-devel@vger.kernel.org>; Thu, 23 Jul 2026 18:46:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.216.47
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784832397; cv=none; b=ULg1NKGSBAgl20cbBYyFl+OFnJBV7FQQNfQQEjJhZ0iZ7tARozSLpWcUjbacnx7GC1uBUpQEoobLqF+InreK7r2T+JvRTBMbtkIT5caZIhoBy3/ldJ1JHozAaWTH2f7Sdni4xjAggLdxfEYfTS/PYQFvl7y5bexCCQHcYDkNYEQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784832397; c=relaxed/simple;
	bh=zNsz4g/9jlKYeSwyAkgTCr/mWLvx1XT3kgMf7ziCe00=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=KY5uMhtlqQZrnVpvOhYoKMswARILaZrCSQXVk1M6/UZ5Fb56UULYKv3NYvLAkQjcBkvLgIKnLgkqjH+TkoTK7lCJtnYtTSn3LobrkNJlyd+wnMLjf1nVNjxb1vvPFvEg74nEgoz1I3JU78snNwbj+MaYYozhxnDh+VFtFzNjkPA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=K0l4Ru16; arc=none smtp.client-ip=209.85.216.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="K0l4Ru16"
Received: by mail-pj1-f47.google.com with SMTP id 98e67ed59e1d1-383cb94f742so1021013a91.3
        for <lvs-devel@vger.kernel.org>; Thu, 23 Jul 2026 11:46:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1784832387; x=1785437187; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=gvjX2o7DFFzayFyUFs0i0LzhZ1PMgAv+++MqFVj9d/o=;
        b=K0l4Ru163rF4tHzGTfr2Y6xJ94fETN8xR+E/v70yXifc5TWJyT/ns7xFE3HlW7IyTD
         rqFWUZNU2xbwXbJJ1kiA1M1KqTloup2DbD3GBhCY0oOULOs0I4n/Vdg4mIcymMlkPNom
         05jLtTGTKRJ0Pzk8hjXMOONkFpkz+VY4UwFIjGT84rQtiBIBCB+9x/pivh1eGHGZRW44
         +GdoCQnS9tVrL/aSqdMx4D8wp0LB2bkofN2fZ2xbC+men9lMu3Hcn45yk9f+i+mhD2zK
         NgGr698RE1H7S/wYh3nCthw1DAH2T2tBGG1mmirAZJ+Omth19hkwtQUlOjVlojge2ypQ
         56+A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784832387; x=1785437187;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=gvjX2o7DFFzayFyUFs0i0LzhZ1PMgAv+++MqFVj9d/o=;
        b=sUd2vhsbHQRjxxdkr7UKhgOM9t1Um1tRJItbFDY2QUQk+FIt1MCx8jUEG2JjG8Qi8K
         8qUd+S7pOIgaxxf/KQYX81zwX7hi1XEQBC70a7IuF0Oqo7JtztKU+cTpwpAei3PE/W9C
         Oj6CjquS2fcVSW0b/LSsIBrAOG+bdmr7JeXo0fceZOjroei98BJfceQ/tGIdPxfnpf2o
         0BId+opjPf78XEgkV+ol9YrIXrpeUm7gR8gM7HAOKxg8u3prfsoDbHQBMr7o0CctG+TB
         4h522eZJAwlFTPyGj/n1KmpfG/MmdaLR3u+quOqpMJzXAYjKHKPsSQYwork3++nqlElL
         j/EA==
X-Forwarded-Encrypted: i=1; AHgh+RrCZ8aW+fOfR1KleHkHLbv1Bxh1PXh7c1enKzQtgjtxHsPYmTEK+TaBE/FfKeyaISH/IRIqpL31qmA=@vger.kernel.org
X-Gm-Message-State: AOJu0YyRHc5vO0mKxXT1LHbrsi6h0pgE25uGEcTFu5o1ipjbJEQ7lZ2h
	/+d73oe4WM3hKH4W1/32ov5zWk1f9kNanuByGHiyS8mYsqHsRHdJo5or
X-Gm-Gg: AR+sD11KUmexiAD4ap78IhA/YT+AVsVJrYe7VihO3sd6rxj9OvPAcM+pp1VL99/pbyc
	2ZSs/WbVJICnGqTp8xJvR9GfGoTnmfs0TgJWMllklfTYuhsI2JhG6QkrkWFd2NiDS/ALei9JNQA
	PDZi9jXE07VjOqYuJTmHdZru1WtTUB+vJV1ICFuG+gEz8tk/hHlmaSSPjatr/4ywuoxIHkSPNMa
	2XeqyGw0/02PUN0f1CYNy3SritrN6JXwdlvaVHhM2qhhOQz9iJeAr3bK6rJT48fZqbZDa/3xodu
	WYs934CxawvfmOunDXdfK3amInK/HlqfXuOCx/mrqLAhJhQjNFXo1gC8I1MB6wMPIlkU3VSK8vc
	DSTKP1L+C4myjPluAImecK07xwfTslNaN1ByriGOIFephdscEbCdy/lPsEatrQcDMqBXlcRPJjL
	ElTUhxVQ0=
X-Received: by 2002:a17:90b:3ccf:b0:37f:fda5:8d9a with SMTP id 98e67ed59e1d1-38ec6a5115dmr4284232a91.25.1784832387385;
        Thu, 23 Jul 2026 11:46:27 -0700 (PDT)
Received: from ubuntu.. ([110.9.142.4])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-38f03af8a45sm308155a91.10.2026.07.23.11.46.24
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 23 Jul 2026 11:46:26 -0700 (PDT)
From: Sang-Heon Jeon <ekffu200098@gmail.com>
To: Julia.Lawall@inria.fr,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>
Cc: cocci@inria.fr,
	coreteam@netfilter.org,
	linux-kernel@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Phil Sutter <phil@nwl.cc>,
	Simon Horman <horms@kernel.org>
Subject: [PATCH 11/36] ipvs: remove conditional return with no effect
Date: Fri, 24 Jul 2026 03:45:13 +0900
Message-ID: <20260723184538.3888637-12-ekffu200098@gmail.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20260723184538.3888637-1-ekffu200098@gmail.com>
References: <20260723184538.3888637-1-ekffu200098@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Both branches of the check return the same value, so the check has
no effect. Remove it and return the value directly.

This is the result of running the Coccinelle script from
scripts/coccinelle/misc/cond_return_no_effect.cocci.

Signed-off-by: Sang-Heon Jeon <ekffu200098@gmail.com>
---
 net/netfilter/ipvs/ip_vs_sync.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 93038abbf5e0..bd4f7e906cf7 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1603,15 +1603,10 @@ ip_vs_receive(struct socket *sock, char *buffer, const size_t buflen)
 {
 	struct msghdr		msg = {NULL,};
 	struct kvec		iov = {buffer, buflen};
-	int			len;
 
 	/* Receive a packet */
 	iov_iter_kvec(&msg.msg_iter, ITER_DEST, &iov, 1, buflen);
-	len = sock_recvmsg(sock, &msg, MSG_DONTWAIT);
-	if (len < 0)
-		return len;
-
-	return len;
+	return sock_recvmsg(sock, &msg, MSG_DONTWAIT);
 }
 
 /* Wakeup the master thread for sending */
-- 
2.43.0

